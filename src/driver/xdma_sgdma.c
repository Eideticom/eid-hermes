/*******************************************************************************
 *
 * Xilinx XDMA IP Core Linux Driver
 * Copyright(c) 2015 - 2020 Xilinx, Inc.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms and conditions of the GNU General Public License,
 * version 2, as published by the Free Software Foundation.
 *
 * This program is distributed in the hope it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * The full GNU General Public License is included in this distribution in
 * the file called "LICENSE".
 *
 * Karen Xie <karen.xie@xilinx.com>
 *
 ******************************************************************************/
#define pr_fmt(fmt)     KBUILD_MODNAME ":%s: " fmt, __func__

#include <linux/types.h>
#include <asm/cacheflush.h>
#include "libxdma.h"
#include "xdma_sgdma.h"

#define PAGE_PTRS_PER_SGL (sizeof(struct scatterlist) / sizeof(struct page *))

/* Module Parameters */
unsigned int sgdma_timeout = 10;
module_param(sgdma_timeout, uint, 0644);
MODULE_PARM_DESC(sgdma_timeout, "timeout in seconds for sgdma, default is 10 sec.");

int hpdev_init_channels(struct hermes_pci_dev *hpdev)
{
	struct xdma_dev *xdev = hpdev->xdev;
	struct xdma_engine *engine;
	int i;

	/* iterate over channels */
	for (i = 0; i < hpdev->h2c_channel_max; i++) {
		engine = &xdev->engine_h2c[i];

		if (engine->magic != MAGIC_ENGINE)
			continue;

		hpdev->xdma_h2c_chnl[i].engine = engine;
		hpdev->xdma_h2c_chnl[i].xdev = xdev;
	}

	for (i = 0; i < hpdev->c2h_channel_max; i++) {
		engine = &xdev->engine_c2h[i];

		if (engine->magic != MAGIC_ENGINE)
			continue;

		hpdev->xdma_c2h_chnl[i].engine = engine;
		hpdev->xdma_c2h_chnl[i].xdev = xdev;
	}

	return 0;
}

static int check_transfer_align(struct xdma_engine *engine,
	const char __user *buf, size_t count, loff_t pos, int sync)
{
	if (!engine) {
		pr_err("Invalid DMA engine\n");
		return -EINVAL;
	}

	/* AXI ST or AXI MM non-incremental addressing mode? */
	if (engine->non_incr_addr) {
		int buf_lsb = (int)((uintptr_t)buf) & (engine->addr_align - 1);
		size_t len_lsb = count & ((size_t)engine->len_granularity - 1);
		int pos_lsb = (int)pos & (engine->addr_align - 1);

		dbg_tfr("AXI ST or MM non-incremental\n");
		dbg_tfr("buf_lsb = %d, pos_lsb = %d, len_lsb = %ld\n", buf_lsb,
			pos_lsb, len_lsb);

		if (buf_lsb != 0) {
			dbg_tfr("FAIL: non-aligned buffer address %p\n", buf);
			return -EINVAL;
		}

		if ((pos_lsb != 0) && (sync)) {
			dbg_tfr("FAIL: non-aligned AXI MM FPGA addr 0x%llx\n",
				(unsigned long long)pos);
			return -EINVAL;
		}

		if (len_lsb != 0) {
			dbg_tfr("FAIL: len %d is not a multiple of %d\n",
				(int)count,
				(int)engine->len_granularity);
			return -EINVAL;
		}
		/* AXI MM incremental addressing mode */
	} else {
		int buf_lsb = (int)((uintptr_t)buf) & (engine->addr_align - 1);
		int pos_lsb = (int)pos & (engine->addr_align - 1);

		if (buf_lsb != pos_lsb) {
			dbg_tfr("FAIL: Misalignment error\n");
			dbg_tfr("host addr %p, FPGA addr 0x%llx\n", buf, pos);
			return -EINVAL;
		}
	}

	return 0;
}

/* xdma_channel_read_write() -- Read from or write to the device
 *
 * @iter iov_iter to iterate on
 * @pos byte-address in device
 *
 * Iterate over the iov_iter and issue XDMA requests.
 *
 */
ssize_t xdma_channel_read_write(struct xdma_channel *chnl,
		struct iov_iter *iter, loff_t pos)
{
	int rc, i, pages_nr;
	ssize_t res = 0;
	struct xdma_dev *xdev;
	struct xdma_engine *engine;
	struct page **pages;
	struct sg_table sgt;
	ssize_t size, left;
	size_t offset, len;
	bool write;
	struct sg_page_iter sg_iter;

	xdev = chnl->xdev;
	engine = chnl->engine;

	write = iov_iter_rw(iter);

	if ((write && engine->dir != DMA_TO_DEVICE) ||
	    (!write && engine->dir != DMA_FROM_DEVICE)) {
		pr_err("r/w mismatch. W %d, dir %d.\n",
			write, engine->dir);
		return -EINVAL;
	}

	rc = sg_alloc_table(&sgt, SG_MAX_SINGLE_ALLOC, GFP_KERNEL);
	if (rc)
		return -ENOMEM;

	while (iov_iter_count(iter)) {
		pages = (struct page **) sgt.sgl;
		pages += SG_MAX_SINGLE_ALLOC * (PAGE_PTRS_PER_SGL - 1);

		size = iov_iter_get_pages(iter, pages, LONG_MAX,
				SG_MAX_SINGLE_ALLOC, &offset);
		if (size < 0) {
			res = size;
			goto out;
		}

		rc = check_transfer_align(engine, (void *) offset, size, pos,
				1);
		if (rc) {
			pr_info("Invalid transfer alignment detected\n");
			res = rc;
			goto out;
		}

		for (left = size, i = 0; left > 0; left -= len, i++) {
			len = min_t(size_t, PAGE_SIZE - offset, left);
			sg_set_page(&sgt.sgl[i], pages[i], len, offset);
			offset = 0;
		}
		sgt.nents = pages_nr = i;
		sg_mark_end(&sgt.sgl[i - 1]);

		size = xdma_xfer_submit(xdev, engine->channel, write, pos, &sgt,
					0, sgdma_timeout * 1000);
		if (size < 0) {
			res = size;
			goto out;
		}

		iov_iter_advance(iter, size);

		pos += size;
		res += size;

		for_each_sg_page(sgt.sgl, &sg_iter, pages_nr, 0) {
			struct page *page = sg_page_iter_page(&sg_iter);
			if (!write)
				set_page_dirty_lock(page);
			put_page(page);
		}

		sg_unmark_end(&sgt.sgl[pages_nr - 1]);
	}

out:
	sg_free_table(&sgt);

	return res;
}

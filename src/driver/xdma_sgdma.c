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

/*
 * Map a user memory range into a scatterlist
 * inspired by vhost_scsi_map_to_sgl()
 * Returns the number of scatterlist entries used or -errno on error.
 */

static void xdma_channel_unmap_user_buf(struct xdma_io_cb *cb, bool write)
{
	int i;

	sg_free_table(&cb->sgt);

	if (!cb->pages || !cb->pages_nr)
		return;

	for (i = 0; i < cb->pages_nr; i++) {
		if (cb->pages[i]) {
			if (!write)
				set_page_dirty_lock(cb->pages[i]);
			put_page(cb->pages[i]);
		} else
			break;
	}

	if (i != cb->pages_nr)
		pr_info("sgl pages %d/%u.\n", i, cb->pages_nr);

	kfree(cb->pages);
	cb->pages = NULL;
}

static int xdma_channel_map_user_buf_to_sgl(struct xdma_io_cb *cb, bool write)
{
	struct sg_table *sgt = &cb->sgt;
	unsigned long len = cb->len;
	char __user *buf = cb->buf;
	struct scatterlist *sg;
	unsigned int pages_nr = (((unsigned long)buf + len + PAGE_SIZE - 1) -
				 ((unsigned long)buf & PAGE_MASK))
				>> PAGE_SHIFT;
	int i;
	int rv;

	if (pages_nr == 0)
		return -EINVAL;

	if (sg_alloc_table(sgt, pages_nr, GFP_KERNEL)) {
		pr_err("sgl OOM.\n");
		return -ENOMEM;
	}

	cb->pages = kcalloc(pages_nr, sizeof(struct page *), GFP_KERNEL);
	if (!cb->pages) {
		pr_err("pages OOM.\n");
		rv = -ENOMEM;
		goto err_out;
	}

	rv = get_user_pages_fast((unsigned long)buf, pages_nr, 1/* write */,
				cb->pages);
	/* No pages were pinned */
	if (rv < 0) {
		pr_err("unable to pin down %u user pages, %d.\n",
			pages_nr, rv);
		goto err_out;
	}
	/* Less pages pinned than wanted */
	if (rv != pages_nr) {
		pr_err("unable to pin down all %u user pages, %d.\n",
			pages_nr, rv);
		cb->pages_nr = rv;
		rv = -EFAULT;
		goto err_out;
	}

	for (i = 1; i < pages_nr; i++) {
		if (cb->pages[i - 1] == cb->pages[i]) {
			pr_err("duplicate pages, %d, %d.\n",
				i - 1, i);
			rv = -EFAULT;
			cb->pages_nr = pages_nr;
			goto err_out;
		}
	}

	sg = sgt->sgl;
	for (i = 0; i < pages_nr; i++, sg = sg_next(sg)) {
		unsigned int offset = offset_in_page(buf);
		unsigned int nbytes = min_t(unsigned int,
					PAGE_SIZE - offset, len);

		flush_dcache_page(cb->pages[i]);
		sg_set_page(sg, cb->pages[i], nbytes, offset);

		buf += nbytes;
		len -= nbytes;
	}

	if (len) {
		pr_err("Invalid user buffer length. Cannot map to sgl\n");
		return -EINVAL;
	}

	cb->pages_nr = pages_nr;
	return 0;

err_out:
	xdma_channel_unmap_user_buf(cb, write);

	return rv;
}

/* xdma_channel_read_write() -- Read from or write to the device
 *
 * @buf userspace buffer
 * @count number of bytes in the userspace buffer
 * @pos byte-address in device
 * @dir_to_device If !0, a write to the device is performed
 *
 * Iterate over the userspace buffer, taking at most 255 * PAGE_SIZE bytes for
 * each DMA transfer.
 *
 * For each transfer, get the user pages, build a sglist, map, build a
 * descriptor table. submit the transfer. wait for the interrupt handler
 * to wake us on completion.
 */

static ssize_t xdma_channel_read_write(struct file *file, const char __user *buf,
		size_t count, loff_t *pos, bool write)
{
	int rv;
	ssize_t res = 0;
	struct xdma_cdev *xcdev = (struct xdma_cdev *)file->private_data;
	struct xdma_dev *xdev;
	struct xdma_engine *engine;
	struct xdma_io_cb cb;

	xdev = xcdev->xdev;
	engine = xcdev->engine;

	dbg_tfr("file 0x%p, priv 0x%p, buf 0x%p,%llu, pos %llu, W %d, %s.\n",
		file, file->private_data, buf, (u64)count, (u64)*pos, write,
		engine->name);

	if ((write && engine->dir != DMA_TO_DEVICE) ||
	    (!write && engine->dir != DMA_FROM_DEVICE)) {
		pr_err("r/w mismatch. W %d, dir %d.\n",
			write, engine->dir);
		return -EINVAL;
	}

	rv = check_transfer_align(engine, buf, count, *pos, 1);
	if (rv) {
		pr_info("Invalid transfer alignment detected\n");
		return rv;
	}

	memset(&cb, 0, sizeof(struct xdma_io_cb));
	cb.buf = (char __user *)buf;
	cb.len = count;
	rv = xdma_channel_map_user_buf_to_sgl(&cb, write);
	if (rv < 0)
		return rv;

	res = xdma_xfer_submit(xdev, engine->channel, write, *pos, &cb.sgt,
				0, sgdma_timeout * 1000);	
	xdma_channel_unmap_user_buf(&cb, write);

	return res;
}

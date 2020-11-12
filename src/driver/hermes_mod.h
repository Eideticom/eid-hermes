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

#ifndef __XDMA_MODULE_H__
#define __XDMA_MODULE_H__

#include <linux/types.h>
#include <linux/module.h>
#include <linux/cdev.h>
#include <linux/dma-mapping.h>
#include <linux/delay.h>
#include <linux/fb.h>
#include <linux/fs.h>
#include <linux/init.h>
#include <linux/interrupt.h>
#include <linux/io.h>
#include <linux/jiffies.h>
#include <linux/kernel.h>
#include <linux/mm.h>
#include <linux/mm_types.h>
#include <linux/poll.h>
#include <linux/pci.h>
#include <linux/sched.h>
#include <linux/slab.h>
#include <linux/vmalloc.h>
#include <linux/workqueue.h>
#include <linux/aio.h>
#include <linux/splice.h>
#include <linux/version.h>
#include <linux/uio.h>
#include <linux/spinlock_types.h>

#include "libxdma.h"

#define MAGIC_ENGINE	0xEEEEEEEEUL
#define MAGIC_DEVICE	0xDDDDDDDDUL
#define MAGIC_CHAR	0xCCCCCCCCUL
#define MAGIC_BITSTREAM 0xBBBBBBBBUL

#define MB              (1<<20)

extern unsigned int desc_blen_max;
extern unsigned int sgdma_timeout;

struct xdma_cdev {
	unsigned long magic;		/* structure ID for sanity checks */
	struct hermes_pci_dev *hpdev;
	struct xdma_dev *xdev;
	dev_t cdevno;			/* character device major:minor */
	struct cdev cdev;		/* character device embedded struct */
	int bar;			/* PCIe BAR for HW access, if needed */
	unsigned long base;		/* bar access offset */
	struct xdma_engine *engine;	/* engine instance, if needed */
	struct device *sys_device;	/* sysfs device */
	spinlock_t lock;
};

struct __attribute__((__packed__)) hermes_cfg {
	uint32_t ehver;
	char ehbld[48];
	uint8_t eheng;
	uint8_t ehpslot;
	uint8_t ehdslot;
	uint8_t rsv0;
	uint32_t ehpsoff;
	uint32_t ehpssze;
	uint32_t ehdsoff;
	uint32_t ehdssze;
};

struct hermes_dev {
	struct device dev;
	struct pci_dev *pdev;
	struct hermes_pci_dev *hpdev;
	struct cdev cdev;
	int id;
};

/* XDMA PCIe device specific book-keeping */
struct hermes_pci_dev {
	unsigned long magic;		/* structure ID for sanity checks */
	struct pci_dev *pdev;	/* pci device struct from probe() */
	struct xdma_dev *xdev;
	struct hermes_dev *hdev;
	int major;		/* major number */
	int instance;		/* instance number */
	int c2h_channel_max;
	int h2c_channel_max;

	unsigned int flags;
	/* character device structures */
	struct xdma_cdev sgdma_c2h_cdev[XDMA_CHANNEL_NUM_MAX];
	struct xdma_cdev sgdma_h2c_cdev[XDMA_CHANNEL_NUM_MAX];

	struct xdma_cdev xvc_cdev;

	struct hermes_cfg cfg;
	void __iomem *bar0;
	void *data;
};

struct xdma_io_cb {
	void __user *buf;
	size_t len;
	unsigned int pages_nr;
	struct sg_table sgt;
	struct page **pages;
};

#endif /* ifndef __XDMA_MODULE_H__ */
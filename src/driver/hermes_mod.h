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

#define EBPF_ENG_NUM_MAX	XDMA_CHANNEL_NUM_MAX

extern unsigned int desc_blen_max;
extern unsigned int sgdma_timeout;

struct xdma_channel {
	struct xdma_dev *xdev;
	struct xdma_engine *engine;	/* engine instance, if needed */
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

	struct hermes_cfg cfg;
	struct ida prog_slots;
	struct ida data_slots;

	/* MSI-X vector for eBPF engines */
	int irq_lines[EBPF_ENG_NUM_MAX];
};

struct ida_wq {
	struct ida ida;
	unsigned int max;
	wait_queue_head_t wq;
};

/* XDMA PCIe device specific book-keeping */
struct hermes_pci_dev {
	unsigned long magic;		/* structure ID for sanity checks */
	struct pci_dev *pdev;	/* pci device struct from probe() */
	struct xdma_dev *xdev;
	struct hermes_dev *hdev;
	int c2h_channel_max;
	int h2c_channel_max;

	struct xdma_channel xdma_c2h_chnl[XDMA_CHANNEL_NUM_MAX];
	struct xdma_channel xdma_h2c_chnl[XDMA_CHANNEL_NUM_MAX];

	struct ida_wq c2h_ida_wq;
	struct ida_wq h2c_ida_wq;
};

struct xdma_channel *xdma_get_c2h(struct hermes_pci_dev *hpdev);
struct xdma_channel *xdma_get_h2c(struct hermes_pci_dev *hpdev);
void xdma_release_c2h(struct xdma_channel *chnl);
void xdma_release_h2c(struct xdma_channel *chnl);

int hermes_cdev_init(void);
void hermes_cdev_cleanup(void);

void hermes_cdev_destroy(struct hermes_pci_dev *hpdev);
int hermes_cdev_create(struct hermes_pci_dev *hpdev);

#endif /* ifndef __XDMA_MODULE_H__ */

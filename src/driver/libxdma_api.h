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

#ifndef __XDMA_BASE_API_H__
#define __XDMA_BASE_API_H__

#include <linux/types.h>
#include <linux/scatterlist.h>
#include <linux/interrupt.h>

/*
 * functions exported by the xdma driver
 */

typedef struct {
	u64 write_submitted;
	u64 write_completed;
	u64 read_requested;
	u64 read_completed;
	u64 restart;
	u64 open;
	u64 close;
	u64 msix_trigger;
} xdma_statistics;

/*
 * This struct should be constantly updated by XMDA using u64_stats_* APIs
 * The front end will read the structure without locking (That's why updating atomically is a must)
 * every time it prints the statistics.
 */
//static XDMA_Statistics stats;

/* 
 * xdma_device_open - read the pci bars and configure the fpga
 *	should be called from probe()
 * @pdev: ptr to pci_dev
 * @mod_name: the module name to be used for request_irq
 * @channel_max: max # of c2h and h2c channels to be configured
 * returns
 *	a opaque handle (for libxdma to identify the device)
 *	NULL, in case of error  
 */
void *xdma_device_open(const char *mod_name, struct pci_dev *pdev,
		 int *h2c_channel_max, int *c2h_channel_max);

/* 
 * xdma_device_close - prepare fpga for removal: disable all interrupts (users
 * and xdma) and release all resources
 *	should called from remove()
 * @pdev: ptr to struct pci_dev
 * @tuples: from xdma_device_open()
 */
void xdma_device_close(struct pci_dev *pdev, void *dev_handle);

/* 
 * xdma_device_restart - restart the fpga
 * @pdev: ptr to struct pci_dev
 * return < 0 in case of error
 */
int xdma_device_restart(struct pci_dev *pdev, void *dev_handle);

/*
 * xdma_xfer_submit - submit data for dma operation (for both read and write)
 *	This is a blocking call
 * @channel: channle number (< channel_max)
 *	== channel_max means libxdma can pick any channel available:q

 * @dir: DMA_FROM/TO_DEVICE
 * @offset: offset into the DDR/BRAM memory to read from or write to
 * @sg_tbl: the scatter-gather list of data buffers
 * @timeout: timeout in mili-seconds, *currently ignored
 * return # of bytes transfered or
 *	 < 0 in case of error
 */
ssize_t xdma_xfer_submit(void *dev_hndl, int channel, bool write, u64 ep_addr,
			struct sg_table *sgt, bool dma_mapped, int timeout_ms);

#endif

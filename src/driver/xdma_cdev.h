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

#ifndef __XDMA_CHRDEV_H__
#define __XDMA_CHRDEV_H__

#include <linux/kernel.h>
#include <linux/types.h>
#include <linux/uaccess.h>
#include <linux/errno.h>
#include "hermes_mod.h"

#define XDMA_NODE_NAME	"xdma"
#define XDMA_MINOR_BASE (0)
#define XDMA_MINOR_COUNT (255)

void xdma_cdev_cleanup(void);
int xdma_cdev_init(void);

int char_open(struct inode *inode, struct file *file);
int char_close(struct inode *inode, struct file *file);
int xcdev_check(const char *fname, struct xdma_cdev *xcdev, bool check_engine);
void cdev_xvc_init(struct xdma_cdev *xcdev);
void cdev_sgdma_init(struct xdma_cdev *xcdev);
struct xdma_cdev *cdev_get_c2h(struct hermes_pci_dev *hpdev);
struct xdma_cdev *cdev_get_h2c(struct hermes_pci_dev *hpdev);

void hpdev_destroy_interfaces(struct hermes_pci_dev *hpdev);
int hpdev_create_interfaces(struct hermes_pci_dev *hpdev);

int bridge_mmap(struct file *file, struct vm_area_struct *vma);

#endif /* __XDMA_CHRDEV_H__ */
/*******************************************************************************
 *
 * Hermes Linux Driver
 * Copyright(c) 2020 Eideticom, Inc.
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
 * Martin Oliveira <martin.oliveira@eideticom.com>
 *
 ******************************************************************************/

#ifndef __HERMES_CHRDEV_H__
#define __HERMES_CHRDEV_H__

#include <linux/kernel.h>
#include <linux/types.h>
#include <linux/uaccess.h>
#include <linux/errno.h>

int hermes_cdev_init(void);
void hermes_cdev_cleanup(void);

void hermes_cdev_destroy(struct hermes_pci_dev *hpdev);
int hermes_cdev_create(struct hermes_pci_dev *hpdev);

#endif /* __HERMES_CHRDEV_H__ */

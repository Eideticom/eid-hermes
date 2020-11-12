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

#define pr_fmt(fmt)	KBUILD_MODNAME ":%s: " fmt, __func__

#include <linux/cdev.h>
#include <linux/module.h>
#include <linux/pci.h>

#include "hermes.h"
#include "hermes_mod.h"
#include "xdma_cdev.h"
#include "cdev_sgdma.h"

#define HERMES_MINOR_BASE	0
#define HERMES_MINOR_COUNT	16
#define HERMES_NAME		"hermes"

static struct class *hermes_class;
DEFINE_IDA(hermes_ida);
static dev_t hermes_devt;

static long handle_xdma(struct hermes_cmd_req *req,
			struct hermes_pci_dev *hpdev)
{
	struct xdma_cdev *xcdev;
	uint32_t slot_size;
	long res;
	loff_t pos;

	pr_debug("opcode: 0x%x cid: 0x%x slot_type: 0x%x slot_id: 0x%x addr: 0x%llx len: 0x%x\n",
			req->opcode, req->cid, req->xdma.slot_type,
			req->xdma.slot_id, req->xdma.addr, req->xdma.len);

	if (req->opcode == HERMES_WR)
		xcdev = cdev_get_h2c(hpdev);
	else
		xcdev = cdev_get_c2h(hpdev);

	if (!xcdev) {
		pr_err("No DMA channel available");
		return -HERMES_GENERIC_ERROR;
	}

	if (req->xdma.slot_type == HERMES_SLOT_PROG) {
		if (req->xdma.slot_id >= hpdev->cfg.ehpslot) {
			pr_err("Invalid program slot id: 0x%x\n",
					req->xdma.slot_id);
			return -HERMES_STATUS_INV_PROG_SLOT;
		}
		pos = hpdev->cfg.ehpsoff;
		slot_size = hpdev->cfg.ehpssze;
	} else if (req->xdma.slot_type == HERMES_SLOT_DATA) {
		if (req->xdma.slot_id >= hpdev->cfg.ehdslot) {
			pr_err("Invalid data slot id: 0x%x\n",
					req->xdma.slot_id);
			return -HERMES_STATUS_INV_DATA_SLOT;
		}
		pos = hpdev->cfg.ehdsoff;
		slot_size = hpdev->cfg.ehdssze;
	} else {
		pr_err("Invalid slot type: %#x\n", HERMES_STATUS_INV_SLOT_TYPE);
		return -HERMES_STATUS_INV_SLOT_TYPE;
	}

	if (req->xdma.len > slot_size) {
		pr_err("DMA length greater than slot size: %#x > %#x\n",
				req->xdma.len, slot_size);
		return -HERMES_STATUS_NO_SPACE;
	}

	pos += slot_size * req->xdma.slot_id;

	res = char_sgdma_read_write(xcdev, (char *) req->xdma.addr,
			req->xdma.len, &pos, req->opcode == HERMES_WR);

	if (res == -EFAULT) {
		pr_err("Invalid DMA address: %#llx\n", req->xdma.addr);
		return -HERMES_STATUS_INV_ADDR;
	} else if (res < 0) {
		return -HERMES_GENERIC_ERROR;
	}

	return res;
}

static int hermes_open(struct inode *inode, struct file *filp)
{
	struct hermes_dev *hermes;

	hermes = container_of(inode->i_cdev, struct hermes_dev, cdev);
	filp->private_data = hermes;

	return 0;
}

static long hermes_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
{
	struct hermes_dev *hermes = filp->private_data;
	struct hermes_pci_dev *hpdev = hermes->hpdev;
	struct hermes_cmd_req_res *req_res = (struct hermes_cmd_req_res *) arg;
	struct hermes_cmd_req *req = &req_res->req;
	struct hermes_cmd_res *res = &req_res->res;
	long ret = 0;

	switch(req_res->req.opcode) {
	case HERMES_WR:
	case HERMES_RD:
		ret = handle_xdma(req, hpdev);
		if (ret >= 0) {
			res->xdma.bytes = ret;
			res->status = HERMES_STATUS_SUCCESS;
		} else {
			res->status = -ret;
		}
		ret = 0;
		break;
	case HERMES_REQ_SLOT:
	case HERMES_REL_SLOT:
	case HERMES_RUN:
		/* Not implemented */
		ret = -ENOSYS;
		break;
	default:
		res->status = HERMES_STATUS_INV_OPCODE;
	}

	res->cid = req->cid;
	pr_debug("cid: %#x status: %#x cmd_specific[0]: %#x cmd_specific[1]: %#x\n", res->cid, res->status, res->cmd_specific[0], res->cmd_specific[1]);

	return ret;
}

static const struct file_operations hermes_fops = {
	.owner = THIS_MODULE,
	.open = hermes_open,
	.unlocked_ioctl = hermes_ioctl,
};

static struct hermes_dev *to_hermes(struct device *dev)
{
	return container_of(dev, struct hermes_dev, dev);
}

static void hermes_release(struct device *dev)
{
	struct hermes_dev *hermes = to_hermes(dev);

	kfree(hermes);
}

static int hermes_read_cfg(struct hermes_pci_dev *hpdev)
{
	struct hermes_cfg *cfg;
	hpdev->bar0 = pci_iomap(hpdev->pdev, 0, 32*MB);
	if (!hpdev->bar0)
		return -EFAULT;

	cfg = &hpdev->cfg;

	memcpy_fromio(cfg, hpdev->bar0, sizeof(*cfg));
	pr_debug("ehver: 0x%x ehbld: %s eheng: 0x%x ehpslot: 0x%x ehdslot: 0x%x ehpsoff: 0x%x ehpssze: 0x%x ehdsoff: 0x%x ehdssze: 0x%x\n",
			cfg->ehver, cfg->ehbld, cfg->eheng, cfg->ehpslot,
			cfg->ehdslot, cfg->ehpsoff, cfg->ehpssze, cfg->ehdsoff,
			cfg->ehdssze);
	return 0;
}

int hermes_cdev_create(struct hermes_pci_dev *hpdev)
{
	struct pci_dev *pdev = hpdev->pdev;
	struct hermes_dev *hermes;
	int err;

	hermes = kzalloc(sizeof(*hermes), GFP_KERNEL);
	if (!hermes)
		return -ENOMEM;

	hermes->pdev = pdev;
	hermes->hpdev = hpdev;

	err = hermes_read_cfg(hpdev);
	if (err)
		goto out_free;

	device_initialize(&hermes->dev);
	hermes->dev.class = hermes_class;
	hermes->dev.parent = &pdev->dev;
	hermes->dev.release = hermes_release;

	hermes->id = ida_simple_get(&hermes_ida, 0, 0, GFP_KERNEL);
	if (hermes->id < 0) {
		err = hermes->id;
		goto out_free;
	}

	dev_set_name(&hermes->dev, "hermes%d", hermes->id);
	hermes->dev.devt = MKDEV(MAJOR(hermes_devt), hermes->id);

	cdev_init(&hermes->cdev, &hermes_fops);
	hermes->cdev.owner = THIS_MODULE;
	err = cdev_device_add(&hermes->cdev, &hermes->dev);
	if (err)
		goto out_ida;

	hpdev->hdev = hermes;
	dev_info(&hermes->dev, "device created");

	return 0;

out_ida:
	ida_simple_remove(&hermes_ida, hermes->id);
out_free:
	kfree(hermes);
	return err;
}

void hermes_cdev_destroy(struct hermes_pci_dev *hpdev)
{
	struct hermes_dev *hermes = hpdev->hdev;

	dev_info(&hermes->dev, "device removed");

	cdev_device_del(&hermes->cdev, &hermes->dev);
	ida_simple_remove(&hermes_ida, hermes->id);
	put_device(&hermes->dev);
}

int hermes_cdev_init(void)
{
	int rc;

	hermes_class = class_create(THIS_MODULE, HERMES_NAME);
	if (IS_ERR(hermes_class))
		return PTR_ERR(hermes_class);

	rc = alloc_chrdev_region(&hermes_devt, HERMES_MINOR_BASE,
			HERMES_MINOR_COUNT, HERMES_NAME);
	if (rc)
		goto err_class;

	return rc;

err_class:
	class_destroy(hermes_class);
	return rc;
}

void hermes_cdev_cleanup(void)
{
	unregister_chrdev_region(hermes_devt, HERMES_MINOR_COUNT);
	class_destroy(hermes_class);
}

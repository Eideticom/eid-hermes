/*
 * Hermes eBPF-based PCIe Accelerator driver
 * Copyright (c) 2020 Eidetic Communications Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

#include <linux/cdev.h>
#include <linux/module.h>
#include <linux/pci.h>

#ifdef __HERMES_DEBUG__
#define hermes_dbg  pr_err
#else
#define hermes_dbg(...)
#endif

#define PCI_VENDOR_EIDETICOM	0x1de5
#define PCI_HERMES_DEVICE_ID	0x3000

#define HERMES_MINOR_BASE	0
#define HERMES_MINOR_COUNT	16
#define HERMES_NAME		"hermes"

extern int xdma_probe_one(struct pci_dev *pdev, const struct pci_device_id *id);
extern void xdma_remove_one(struct pci_dev *pdev);
extern void *xdma_pci_dev_get_priv(void *xpdev);
extern void *xdma_pci_dev_set_priv(void *xpdev, void *x);
extern void *xdma_get_xcdev_h2c(void *xpdev);
extern void *xdma_get_xcdev_c2h(void *xpdev);
extern ssize_t xdma_char_sgdma_read_write(void *xcdev, const char __user *buf,
		size_t count, loff_t *pos, bool write);

static struct class *hermes_class;
DEFINE_IDA(hermes_ida);
static dev_t hermes_devt;

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
	struct cdev cdev;
	struct hermes_cfg cfg;
	int id;

	void *xpdev;
};

struct __attribute__((__packed__)) hermes_cmd_req {
	uint8_t opcode;
	uint8_t rsv0;
	uint16_t cid;
	uint32_t rsv1;
	union {
		struct __attribute__((__packed__)) {
			uint8_t slot_type;
			uint8_t slot_id;
			uint16_t rsv;
			uint64_t addr;
			uint32_t len;
		} xdma;
		uint32_t cmd_specific[6];
	};
};

enum hermes_opcode {
	HERMES_REQ_SLOT = 0x00,
	HERMES_REL_SLOT,
	HERMES_WR = 0x10,
	HERMES_RD,
	HERMES_RUN = 0x80,
};

enum hermes_slot_type {
	HERMES_SLOT_PROG,
	HERMES_SLOT_DATA,
};

static struct pci_device_id pci_ids[] = {
	{ PCI_DEVICE(PCI_VENDOR_EIDETICOM, PCI_HERMES_DEVICE_ID), },
	{ 0, }
};
MODULE_DEVICE_TABLE(pci, pci_ids);

void handle_xdma(struct hermes_cmd_req *req, struct hermes_dev *hermes)
{
	void *xcdev, *xpdev;
	uint32_t slot_size;
	loff_t pos;

	xpdev = hermes->xpdev;

	hermes_dbg("%s: opcode: 0x%x cid: 0x%x slot_type: 0x%x slot_id: 0x%x addr: 0x%llx len: 0x%x\n",
			__func__, req->opcode, req->cid, req->xdma.slot_type,
			req->xdma.slot_id, req->xdma.addr, req->xdma.len);

	if (req->opcode == HERMES_WR)
		xcdev = xdma_get_xcdev_h2c(xpdev);
	else if (req->opcode == HERMES_RD)
		xcdev = xdma_get_xcdev_c2h(xpdev);
	else
		goto invalid_opcode;

	if (!xcdev)
		goto no_xcdev;

	if (req->xdma.slot_type == HERMES_SLOT_PROG) {
		if (req->xdma.slot_id >= hermes->cfg.ehpslot)
			goto invalid_slot_id;
		pos = hermes->cfg.ehpsoff;
		slot_size = hermes->cfg.ehpssze;
	} else if (req->xdma.slot_type == HERMES_SLOT_DATA) {
		if (req->xdma.slot_id >= hermes->cfg.ehdslot)
			goto invalid_slot_id;
		pos = hermes->cfg.ehdsoff;
		slot_size = hermes->cfg.ehdssze;
	} else {
		goto invalid_slot_type;
	}

	if (req->xdma.len > slot_size)
		goto invalid_length;

	pos += slot_size * req->xdma.slot_id;

	xdma_char_sgdma_read_write(xcdev, (char *) req->xdma.addr,
			req->xdma.len, &pos, req->opcode == HERMES_WR);
	return;

invalid_opcode:
	pr_err("%s: Invalid opcode: 0x%x\n", __func__, req->opcode);
	return;
no_xcdev:
	pr_err("%s: No DMA channel available", __func__);
	return;
invalid_slot_id:
	pr_err("%s: Invalid slot id: 0x%x\n", __func__, req->xdma.slot_id);
	return;
invalid_slot_type:
	pr_err("%s: Invalid slot type: 0x%x\n", __func__, req->xdma.slot_type);
	return;
invalid_length:
	pr_err("%s: DMA length greater than slot size: 0x%x > 0x%x\n", __func__,
			req->xdma.len, slot_size);
	return;
}

static int hermes_open(struct inode *inode, struct file *filp)
{
	struct hermes_dev *hermes;

	hermes = container_of(inode->i_cdev, struct hermes_dev, cdev);
	filp->private_data = hermes;

	return 0;
}

static ssize_t hermes_read(struct file *filp, char __user *buf, size_t len,
		    loff_t *off)
{
	return 0;
}

static ssize_t hermes_write(struct file *filp, const char __user *buf,
		size_t len, loff_t *off)
{
	int ret = 0;
	struct hermes_cmd_req req;

	if (len != sizeof(req)) {
		ret = -ENOSPC;
		goto out;
	}

	if (copy_from_user(&req, buf, len)) {
		ret = -EFAULT;
		goto out;
	}

	switch(req.opcode) {
	case HERMES_WR:
	case HERMES_RD:
		handle_xdma(&req, filp->private_data);
		ret = len;
		break;
	case HERMES_REQ_SLOT:
	case HERMES_REL_SLOT:
	case HERMES_RUN:
		/* Not implemented */
		ret = -ENOSYS;
		break;
	default:
		ret = -EINVAL;
		goto out;
	}

out:
	return ret;
}

static const struct file_operations hermes_fops = {
    .owner = THIS_MODULE,
    .open =  hermes_open,
    .read =  hermes_read,
    .write = hermes_write,
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

static int hermes_read_cfg(struct hermes_dev *hermes)
{
	struct hermes_cfg *cfg;
	void __iomem *bar0 = pci_iomap(hermes->pdev, 0, sizeof(*cfg));
	if (!bar0)
		return -EFAULT;

	cfg = &hermes->cfg;

	memcpy_fromio(cfg, bar0, sizeof(*cfg));
	hermes_dbg("%s: ehver: 0x%x ehbld: %s eheng: 0x%x ehpslot: 0x%x ehdslot: 0x%x ehpsoff: 0x%x ehpssze: 0x%x ehdsoff: 0x%x ehdssze: 0x%x\n",
			__func__, cfg->ehver, cfg->ehbld, cfg->eheng,
			cfg->ehpslot, cfg->ehdslot, cfg->ehpsoff, cfg->ehpssze,
			cfg->ehdsoff, cfg->ehdssze);
	return 0;
}

static struct hermes_dev *hermes_create(struct pci_dev *pdev)
{
	struct hermes_dev *hermes;
	int err;

	hermes = kzalloc(sizeof(*hermes), GFP_KERNEL);
	if (!hermes)
		return ERR_PTR(-ENOMEM);

	hermes->pdev = pdev;

	err = hermes_read_cfg(hermes);
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

	dev_info(&hermes->dev, "device created");

	return hermes;

out_ida:
	ida_simple_remove(&hermes_ida, hermes->id);
out_free:
	kfree(hermes);
	return ERR_PTR(err);
}

static void hermes_destroy(struct pci_dev *pdev)
{
	void *xpdev = pci_get_drvdata(pdev);
	struct hermes_dev *hermes = xdma_pci_dev_get_priv(xpdev);

	dev_info(&hermes->dev, "device removed");

	cdev_device_del(&hermes->cdev, &hermes->dev);
	ida_simple_remove(&hermes_ida, hermes->id);
	put_device(&hermes->dev);
}

static int hermes_probe(struct pci_dev *pdev, const struct pci_device_id *id)
{
	struct hermes_dev *hermes;
	void *xpdev;
	int err;

	err = xdma_probe_one(pdev, id);
	if (err)
		goto out;

	hermes = hermes_create(pdev);
	if (IS_ERR(hermes)) {
		err = PTR_ERR(hermes);
		goto xdma_remove;
	}

	xpdev = pci_get_drvdata(pdev);
	xdma_pci_dev_set_priv(xpdev, hermes);
	hermes->xpdev = xpdev;

	return 0;

xdma_remove:
	xdma_remove_one(pdev);
out:
	return err;
}

static void hermes_remove(struct pci_dev *pdev)
{
	hermes_destroy(pdev);
	xdma_remove_one(pdev);
}

static struct pci_driver hermes_driver = {
	.name = "hermes",
	.id_table = pci_ids,
	.probe = hermes_probe,
	.remove = hermes_remove,
};

static int __init hermes_init(void)
{
	int rc;

	hermes_class = class_create(THIS_MODULE, HERMES_NAME);
	if (IS_ERR(hermes_class))
		return PTR_ERR(hermes_class);

	rc = alloc_chrdev_region(&hermes_devt, HERMES_MINOR_BASE,
			HERMES_MINOR_COUNT, HERMES_NAME);
	if (rc)
		goto err_class;

	rc = pci_register_driver(&hermes_driver);
	if (rc)
		goto err_chdev;

	pr_info(KBUILD_MODNAME ": module loaded\n");

	return rc;
err_chdev:
	unregister_chrdev_region(hermes_devt, HERMES_MINOR_COUNT);
err_class:
	class_destroy(hermes_class);
	return rc;
}

static void __exit hermes_exit(void)
{
	pci_unregister_driver(&hermes_driver);
	unregister_chrdev_region(hermes_devt, HERMES_MINOR_COUNT);
	class_destroy(hermes_class);

	pr_info(KBUILD_MODNAME ": module unloaded\n");
}

module_init(hermes_init);
module_exit(hermes_exit);
MODULE_LICENSE("GPL");
MODULE_AUTHOR("Martin Oliveira");
MODULE_DESCRIPTION("Hermes driver");
MODULE_VERSION("0.1");

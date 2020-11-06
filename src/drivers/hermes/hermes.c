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

#define PCI_VENDOR_EIDETICOM	0x1de5
#define PCI_HERMES_DEVICE_ID	0x3000

#define HERMES_MINOR_BASE	0
#define HERMES_MINOR_COUNT	16
#define HERMES_NAME		"hermes"

extern int xdma_probe_one(struct pci_dev *pdev, const struct pci_device_id *id);
extern void xdma_remove_one(struct pci_dev *pdev);
extern void *xdma_pci_dev_get_priv(void *xpdev);
extern void *xdma_pci_dev_set_priv(void *xpdev, void *x);

static struct class *hermes_class;
DEFINE_IDA(hermes_ida);
static dev_t hermes_devt;

struct hermes_dev {
	struct device dev;
	struct pci_dev *pdev;
	struct cdev cdev;
	int id;
};

static struct pci_device_id pci_ids[] = {
	{ PCI_DEVICE(PCI_VENDOR_EIDETICOM, PCI_HERMES_DEVICE_ID), },
	{ 0, }
};
MODULE_DEVICE_TABLE(pci, pci_ids);

static ssize_t hermes_read(struct file *filp, char __user *buf, size_t len,
		    loff_t *off)
{
	return 0;
}

static ssize_t hermes_write(struct file *filp, const char __user *buf,
		size_t len, loff_t *off)
{
	return len;
}

static const struct file_operations hermes_fops = {
    .owner = THIS_MODULE,
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

static struct hermes_dev *hermes_create(struct pci_dev *pdev)
{
	struct hermes_dev *hermes;
	int err;

	hermes = kzalloc(sizeof(*hermes), GFP_KERNEL);
	if (!hermes)
		return ERR_PTR(-ENOMEM);

	hermes->pdev = pdev;

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

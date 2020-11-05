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

#include <linux/module.h>
#include <linux/pci.h>

#define PCI_VENDOR_EIDETICOM	0x1de5
#define PCI_HERMES_DEVICE_ID	0x3000

extern int xdma_probe_one(struct pci_dev *pdev, const struct pci_device_id *id);
extern void xdma_remove_one(struct pci_dev *pdev);

static struct pci_device_id pci_ids[] = {
	{ PCI_DEVICE(PCI_VENDOR_EIDETICOM, PCI_HERMES_DEVICE_ID), },
	{ 0, }
};
MODULE_DEVICE_TABLE(pci, pci_ids);

static int hermes_probe(struct pci_dev *pdev, const struct pci_device_id *id)
{
	return xdma_probe_one(pdev, id);
}

static void hermes_remove(struct pci_dev *pdev)
{
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
	return pci_register_driver(&hermes_driver);
}

static void __exit hermes_exit(void)
{
	pci_unregister_driver(&hermes_driver);
}

module_init(hermes_init);
module_exit(hermes_exit);
MODULE_LICENSE("GPL");
MODULE_AUTHOR("Martin Oliveira");
MODULE_DESCRIPTION("Hermes driver");
MODULE_VERSION("0.1");

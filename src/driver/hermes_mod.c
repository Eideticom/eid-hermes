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

#include <linux/ioctl.h>
#include <linux/types.h>
#include <linux/errno.h>
#include <linux/aer.h>
/* include early, to verify it depends only on the headers above */
#include "libxdma_api.h"
#include "libxdma.h"
#include "hermes_mod.h"
#include "xdma_cdev.h"
#include "version.h"

#define DRV_MODULE_NAME		"hermes"
#define DRV_MODULE_DESC		"Hermes driver"

static char version[] =
	DRV_MODULE_DESC " " DRV_MODULE_NAME " v" DRV_MODULE_VERSION "\n";

MODULE_AUTHOR("Xilinx, Inc.");
MODULE_AUTHOR("Eideticom Inc.");
MODULE_DESCRIPTION(DRV_MODULE_DESC);
MODULE_VERSION(DRV_MODULE_VERSION);
MODULE_LICENSE("GPL v2");

/* SECTION: Module global variables */
static int hpdev_cnt;

static const struct pci_device_id pci_ids[] = {
	{ PCI_DEVICE(0x1de5, 0x3000), },
	{0,}
};
MODULE_DEVICE_TABLE(pci, pci_ids);

static void hpdev_free(struct hermes_pci_dev *hpdev)
{
	struct xdma_dev *xdev = hpdev->xdev;

	pr_info("hpdev 0x%p, destroy_interfaces, xdev 0x%p.\n", hpdev, xdev);
	hpdev_destroy_interfaces(hpdev);
	hpdev->xdev = NULL;
	pr_info("hpdev 0x%p, xdev 0x%p xdma_device_close.\n", hpdev, xdev);
	xdma_device_close(hpdev->pdev, xdev);
	hpdev_cnt--;

	kfree(hpdev);
}

static struct hermes_pci_dev *hpdev_alloc(struct pci_dev *pdev)
{
	struct hermes_pci_dev *hpdev = kmalloc(sizeof(*hpdev), GFP_KERNEL);

	if (!hpdev)
		return NULL;
	memset(hpdev, 0, sizeof(*hpdev));

	hpdev->magic = MAGIC_DEVICE;
	hpdev->pdev = pdev;
	hpdev->h2c_channel_max = XDMA_CHANNEL_NUM_MAX;
	hpdev->c2h_channel_max = XDMA_CHANNEL_NUM_MAX;

	hpdev_cnt++;
	return hpdev;
}

static int probe_one(struct pci_dev *pdev, const struct pci_device_id *id)
{
	int rv = 0;
	struct hermes_pci_dev *hpdev = NULL;
	struct xdma_dev *xdev;
	void *hndl;

	hpdev = hpdev_alloc(pdev);
	if (!hpdev)
		return -ENOMEM;

	hndl = xdma_device_open(DRV_MODULE_NAME, pdev, &hpdev->h2c_channel_max,
			&hpdev->c2h_channel_max);
	if (!hndl) {
		rv = -EINVAL;
		goto err_out;
	}

	if (hpdev->h2c_channel_max > XDMA_CHANNEL_NUM_MAX) {
		pr_err("Maximun H2C channel limit reached\n");
		rv = -EINVAL;
		goto err_out;
	}

	if (hpdev->c2h_channel_max > XDMA_CHANNEL_NUM_MAX) {
		pr_err("Maximun C2H channel limit reached\n");
		rv = -EINVAL;
		goto err_out;
	}

	if (!hpdev->h2c_channel_max && !hpdev->c2h_channel_max)
		pr_warn("NO engine found!\n");

	/* make sure no duplicate */
	xdev = xdev_find_by_pdev(pdev);
	if (!xdev) {
		pr_warn("NO xdev found!\n");
		rv =  -EINVAL;
		goto err_out;
	}

	if (hndl != xdev) {
		pr_err("xdev handle mismatch\n");
		rv =  -EINVAL;
		goto err_out;
	}

	pr_info("%s xdma%d, pdev 0x%p, xdev 0x%p, 0x%p, ch %d,%d.\n",
		dev_name(&pdev->dev), xdev->idx, pdev, hpdev, xdev,
		hpdev->h2c_channel_max, hpdev->c2h_channel_max);

	hpdev->xdev = hndl;

	rv = hpdev_create_interfaces(hpdev);
	if (rv)
		goto err_out;

	dev_set_drvdata(&pdev->dev, hpdev);

	return 0;

err_out:
	pr_err("pdev 0x%p, err %d.\n", pdev, rv);
	hpdev_free(hpdev);
	return rv;
}

static void remove_one(struct pci_dev *pdev)
{
	struct hermes_pci_dev *hpdev;

	if (!pdev)
		return;

	hpdev = dev_get_drvdata(&pdev->dev);
	if (!hpdev)
		return;

	pr_info("pdev 0x%p, xdev 0x%p, 0x%p.\n",
		pdev, hpdev, hpdev->xdev);
	hpdev_free(hpdev);

	dev_set_drvdata(&pdev->dev, NULL);
}

static pci_ers_result_t xdma_error_detected(struct pci_dev *pdev,
					pci_channel_state_t state)
{
	struct hermes_pci_dev *hpdev = dev_get_drvdata(&pdev->dev);

	switch (state) {
	case pci_channel_io_normal:
		return PCI_ERS_RESULT_CAN_RECOVER;
	case pci_channel_io_frozen:
		pr_warn("dev 0x%p,0x%p, frozen state error, reset controller\n",
			pdev, hpdev);
		xdma_device_offline(pdev, hpdev->xdev);
		pci_disable_device(pdev);
		return PCI_ERS_RESULT_NEED_RESET;
	case pci_channel_io_perm_failure:
		pr_warn("dev 0x%p,0x%p, failure state error, req. disconnect\n",
			pdev, hpdev);
		return PCI_ERS_RESULT_DISCONNECT;
	}
	return PCI_ERS_RESULT_NEED_RESET;
}

static pci_ers_result_t xdma_slot_reset(struct pci_dev *pdev)
{
	struct hermes_pci_dev *hpdev = dev_get_drvdata(&pdev->dev);

	pr_info("0x%p restart after slot reset\n", hpdev);
	if (pci_enable_device_mem(pdev)) {
		pr_info("0x%p failed to renable after slot reset\n", hpdev);
		return PCI_ERS_RESULT_DISCONNECT;
	}

	pci_set_master(pdev);
	pci_restore_state(pdev);
	pci_save_state(pdev);
	xdma_device_online(pdev, hpdev->xdev);

	return PCI_ERS_RESULT_RECOVERED;
}

static void xdma_error_resume(struct pci_dev *pdev)
{
	struct hermes_pci_dev *hpdev = dev_get_drvdata(&pdev->dev);

	pr_info("dev 0x%p,0x%p.\n", pdev, hpdev);
	pci_cleanup_aer_uncorrect_error_status(pdev);
}

#if KERNEL_VERSION(4, 13, 0) <= LINUX_VERSION_CODE
static void xdma_reset_prepare(struct pci_dev *pdev)
{
	struct hermes_pci_dev *hpdev = dev_get_drvdata(&pdev->dev);

	pr_info("dev 0x%p,0x%p.\n", pdev, hpdev);
	xdma_device_offline(pdev, hpdev->xdev);
}

static void xdma_reset_done(struct pci_dev *pdev)
{
	struct hermes_pci_dev *hpdev = dev_get_drvdata(&pdev->dev);

	pr_info("dev 0x%p,0x%p.\n", pdev, hpdev);
	xdma_device_online(pdev, hpdev->xdev);
}

#elif KERNEL_VERSION(3, 16, 0) <= LINUX_VERSION_CODE
static void xdma_reset_notify(struct pci_dev *pdev, bool prepare)
{
	struct hermes_pci_dev *hpdev = dev_get_drvdata(&pdev->dev);

	pr_info("dev 0x%p,0x%p, prepare %d.\n", pdev, hpdev, prepare);

	if (prepare)
		xdma_device_offline(pdev, hpdev->xdev);
	else
		xdma_device_online(pdev, hpdev->xdev);
}
#endif

static const struct pci_error_handlers xdma_err_handler = {
	.error_detected	= xdma_error_detected,
	.slot_reset	= xdma_slot_reset,
	.resume		= xdma_error_resume,
#if KERNEL_VERSION(4, 13, 0) <= LINUX_VERSION_CODE
	.reset_prepare	= xdma_reset_prepare,
	.reset_done	= xdma_reset_done,
#elif KERNEL_VERSION(3, 16, 0) <= LINUX_VERSION_CODE
	.reset_notify	= xdma_reset_notify,
#endif
};

static struct pci_driver pci_driver = {
	.name = DRV_MODULE_NAME,
	.id_table = pci_ids,
	.probe = probe_one,
	.remove = remove_one,
	.err_handler = &xdma_err_handler,
};

static int __init hermes_mod_init(void)
{
	int rv;

	pr_info("%s", version);

	if (desc_blen_max > XDMA_DESC_BLEN_MAX)
		desc_blen_max = XDMA_DESC_BLEN_MAX;
	pr_info("desc_blen_max: 0x%x/%u, sgdma_timeout: %u sec.\n",
		desc_blen_max, desc_blen_max, sgdma_timeout);

	rv = xdma_cdev_init();
	if (rv < 0)
		return rv;

	return pci_register_driver(&pci_driver);
}

static void __exit hermes_mod_exit(void)
{
	/* unregister this driver from the PCI bus driver */
	dbg_init("pci_unregister_driver.\n");
	pci_unregister_driver(&pci_driver);
	xdma_cdev_cleanup();
}

module_init(hermes_mod_init);
module_exit(hermes_mod_exit);

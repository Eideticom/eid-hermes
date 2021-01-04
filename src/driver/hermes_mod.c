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
#include "libxdma.h"
#include "hermes_mod.h"
#include "xdma_sgdma.h"

#define DRV_MODULE_VERSION	"v0.1"
#define DRV_MODULE_NAME		"hermes"
#define DRV_MODULE_DESC		"Hermes driver"

static char version[] =
	DRV_MODULE_DESC " " DRV_MODULE_NAME " " DRV_MODULE_VERSION "\n";

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

struct ebpf_irq_arg {
	struct hermes_dev *hdev;
	int eng;
} ebpf_irq_args[EBPF_ENG_NUM_MAX];

static void ebpf_msix_teardown(struct hermes_dev *hdev)
{
	int i;

	for (i = 0; i < hdev->cfg.eheng; i++) {
		if (!hdev->irq_lines[i])
			break;
		pr_debug("Release IRQ#%d for eBPF engine %d\n",
			hdev->irq_lines[i], i);
		free_irq(hdev->irq_lines[i], &ebpf_irq_args[i]);
	}
}

static void irq_teardown(struct hermes_pci_dev *hpdev)
{
	xdma_irq_teardown(hpdev->xdev);
	ebpf_msix_teardown(hpdev->hdev);
}

static irqreturn_t ebpf_irq(int irq, void *ptr)
{
	struct ebpf_irq_arg *arg = ptr;
	pr_debug("(irq=%d) eBPF interrupt handler\n", irq);
	wake_up_interruptible(&arg->hdev->wq[arg->eng]);

	return IRQ_HANDLED;
}

static int ebpf_irq_setup(struct hermes_dev *hdev, int first)
{
	unsigned int vector;
	int i, rc;

	for (i = 0; i < hdev->cfg.eheng; i++) {
		vector = pci_irq_vector(hdev->pdev, first + i);
		init_waitqueue_head(&hdev->wq[i]);
		ebpf_irq_args[i].hdev = hdev;
		ebpf_irq_args[i].eng = i;
		rc = request_irq(vector, ebpf_irq, 0, DRV_MODULE_NAME,
				 &ebpf_irq_args[i]);
		if (rc) {
			pr_err("request irq#%d failed %d, eBPF engine %d.\n",
				vector, rc, i);
			return rc;
		}
		pr_info("eBPF engine %d, irq#%d.\n", i, vector);
		hdev->irq_lines[i] = vector;
	}

	return 0;
}

static int irq_setup(struct hermes_pci_dev *hpdev)
{
	struct xdma_dev *xdev = hpdev->xdev;
	int rc;

	rc = xdma_irq_setup(xdev);
	if (rc)
		goto out;

	rc = ebpf_irq_setup(hpdev->hdev, xdev->h2c_channel_max +
			xdev->c2h_channel_max);
out:
	return rc;
}

static void disable_msi_msix(struct pci_dev *pdev)
{
	pci_disable_msix(pdev);
}

static int enable_msi_msix(struct hermes_pci_dev *hpdev)
{
	struct hermes_dev *hdev = hpdev->hdev;
	struct xdma_dev *xdev = hpdev->xdev;
	struct pci_dev *pdev = hpdev->pdev;
	int rv, req_nvec;

	if (unlikely(!xdev || !pdev)) {
		pr_err("xdev 0x%p, pdev 0x%p.\n", xdev, pdev);
		return -EINVAL;
	}

	req_nvec = xdev->c2h_channel_max + xdev->h2c_channel_max +
		hdev->cfg.eheng;

	pr_debug("Enabling MSI-X\n");
	rv = pci_alloc_irq_vectors(pdev, req_nvec, req_nvec,
				PCI_IRQ_MSIX);
	if (rv < 0)
		pr_debug("Couldn't enable MSI-X mode: %d\n", rv);

	return rv;
}

static void hpdev_free(struct hermes_pci_dev *hpdev)
{
	struct xdma_dev *xdev = hpdev->xdev;

	ida_destroy(&hpdev->c2h_ida_wq.ida);
	ida_destroy(&hpdev->h2c_ida_wq.ida);
	ida_destroy(&hpdev->hdev->ebpf_engines_ida_wq.ida);

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

static void init_ida_wq(struct ida_wq *ida_wq, unsigned int max)
{
	ida_init(&ida_wq->ida);
	ida_wq->max = max;
	init_waitqueue_head(&ida_wq->wq);
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

	rv = hpdev_init_channels(hpdev);
	if (rv)
		goto err_out;

	rv = hermes_cdev_create(hpdev);
	if (rv)
		goto err_out;

	rv = enable_msi_msix(hpdev);
	if (rv < 0)
		goto err_enable_msix;

	rv = irq_setup(hpdev);
	if (rv < 0)
		goto err_interrupts;

	init_ida_wq(&hpdev->c2h_ida_wq, hpdev->c2h_channel_max - 1);
	init_ida_wq(&hpdev->h2c_ida_wq, hpdev->h2c_channel_max - 1);
	init_ida_wq(&hpdev->hdev->ebpf_engines_ida_wq, hpdev->hdev->cfg.eheng);

	dev_set_drvdata(&pdev->dev, hpdev);

	return 0;

err_interrupts:
	irq_teardown(hpdev);
err_enable_msix:
	disable_msi_msix(pdev);
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

	irq_teardown(hpdev);
	disable_msi_msix(pdev);

	hermes_cdev_destroy(hpdev);
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
		irq_teardown(hpdev);
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
	irq_setup(hpdev);

	return PCI_ERS_RESULT_RECOVERED;
}

static void xdma_error_resume(struct pci_dev *pdev)
{
	struct hermes_pci_dev *hpdev = dev_get_drvdata(&pdev->dev);

	pr_info("dev 0x%p,0x%p.\n", pdev, hpdev);
	pci_cleanup_aer_uncorrect_error_status(pdev);
}

static int __ida_wq_get(struct ida_wq *ida_wq, int *id)
{
	int ret;

	ret = ida_alloc_max(&ida_wq->ida, ida_wq->max, GFP_KERNEL);
	if (ret == -ENOSPC)
		return 0;
	*id = ret;
	return 1;
}

static int ida_wq_get(struct ida_wq *ida_wq)
{
	int id, ret;

	ret = wait_event_interruptible(ida_wq->wq, __ida_wq_get(ida_wq, &id));
	if (ret)
		return ret;

	return id;
}

static void ida_wq_release(struct ida_wq *ida_wq, unsigned int id)
{
	ida_free(&ida_wq->ida, id);
	wake_up_interruptible(&ida_wq->wq);
}

static const struct pci_error_handlers xdma_err_handler = {
	.error_detected	= xdma_error_detected,
	.slot_reset	= xdma_slot_reset,
	.resume		= xdma_error_resume,
};

static inline struct xdma_channel *xdma_get_chnl(struct xdma_channel *channels,
		struct ida_wq *ida_wq)
{
	int id = ida_wq_get(ida_wq);
	if (id < 0)
		return ERR_PTR(id);
	return &channels[id];
}

struct xdma_channel *xdma_get_c2h(struct hermes_pci_dev *hpdev)
{
	return xdma_get_chnl(hpdev->xdma_c2h_chnl, &hpdev->c2h_ida_wq);
}

struct xdma_channel *xdma_get_h2c(struct hermes_pci_dev *hpdev)
{
	return xdma_get_chnl(hpdev->xdma_h2c_chnl, &hpdev->h2c_ida_wq);
}

void xdma_release_c2h(struct xdma_channel *chnl)
{
	unsigned int id = chnl->engine->channel;
	struct hermes_pci_dev *hpdev;

	hpdev = container_of(chnl, struct hermes_pci_dev, xdma_c2h_chnl[id]);
	ida_wq_release(&hpdev->c2h_ida_wq, id);
}

void xdma_release_h2c(struct xdma_channel *chnl)
{
	unsigned int id = chnl->engine->channel;
	struct hermes_pci_dev *hpdev;

	hpdev = container_of(chnl, struct hermes_pci_dev, xdma_h2c_chnl[id]);
	ida_wq_release(&hpdev->h2c_ida_wq, id);
}

int hermes_get_ebpf_eng(struct hermes_dev *hdev)
{
	return ida_wq_get(&hdev->ebpf_engines_ida_wq);
}

void hermes_release_ebpf_eng(struct hermes_dev *hdev, int engine)
{
	ida_wq_release(&hdev->ebpf_engines_ida_wq, engine);
}

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

	rv = hermes_cdev_init();
	if (rv < 0)
		return rv;

	return pci_register_driver(&pci_driver);
}

static void __exit hermes_mod_exit(void)
{
	/* unregister this driver from the PCI bus driver */
	pr_debug("pci_unregister_driver.\n");
	pci_unregister_driver(&pci_driver);
	hermes_cdev_cleanup();
}

module_init(hermes_mod_init);
module_exit(hermes_mod_exit);

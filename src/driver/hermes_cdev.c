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

#include "hermes_uapi.h"
#include "hermes_mod.h"
#include "xdma_sgdma.h"

#define HERMES_MINOR_BASE	0
#define HERMES_MINOR_COUNT	16
#define HERMES_NAME		"hermes"

static struct class *hermes_class;
DEFINE_IDA(hermes_ida);
static dev_t hermes_devt;

struct hermes_env {
	struct hermes_dev *hermes;
	int32_t prog_slot;
	int32_t data_slot;
};

static inline void hermes_release_slot_prog(struct hermes_env *env)
{
	if (env->prog_slot >= 0)
		ida_simple_remove(&env->hermes->prog_slots, env->prog_slot);
}

static inline void hermes_release_slot_data(struct hermes_env *env)
{
	if (env->data_slot >= 0)
		ida_simple_remove(&env->hermes->data_slots, env->data_slot);
}

static inline int32_t hermes_request_slot_prog(struct hermes_dev *hermes)
{
	return ida_simple_get(&hermes->prog_slots, 0, hermes->cfg.ehpslot,
			      GFP_KERNEL);
}

static inline int32_t hermes_request_slot_data(struct hermes_dev *hermes)
{
	return ida_simple_get(&hermes->data_slots, 0, hermes->cfg.ehdslot,
			      GFP_KERNEL);
}

static int hermes_open(struct inode *inode, struct file *filp)
{
	struct hermes_dev *hermes;
	struct hermes_env *env;

	hermes = container_of(inode->i_cdev, struct hermes_dev, cdev);
	env = kzalloc(sizeof(*env), GFP_KERNEL);
	env->hermes = hermes;
	env->prog_slot = -1;
	env->data_slot = -1;
	filp->private_data = env;

	return 0;
}

static int hermes_close(struct inode *inode, struct file *filp)
{
	struct hermes_env *env = filp->private_data;

	hermes_release_slot_prog(env);
	hermes_release_slot_data(env);

	kfree(env);

	return 0;
}

static ssize_t hermes_read_write_iter(struct kiocb *iocb, struct iov_iter *to)
{
	struct hermes_env *env = iocb->ki_filp->private_data;
	struct hermes_pci_dev *hpdev = env->hermes->hpdev;
	struct hermes_cfg *cfg = &hpdev->hdev->cfg;
	struct xdma_channel *chnl;
	loff_t offset = iocb->ki_pos, pos;
	bool write = (iov_iter_rw(to) == WRITE);
	long res;

	if (iocb->ki_flags & (IOCB_DSYNC | IOCB_SYNC | IOCB_APPEND |
				IOCB_NOWAIT))
		return -EOPNOTSUPP;

	if (offset == -1)
		return -EOPNOTSUPP;
	else if (offset < 0)
		return -EINVAL;

	if (env->prog_slot < 0) {
		dev_err(&env->hermes->dev,
			"Program has not been downloaded to device. Aborting.\n");
		return -EBADFD;
	}

	if (env->data_slot < 0) {
		if (write) {
			env->data_slot = hermes_request_slot_data(hpdev->hdev);
			if (env->data_slot < 0)
				return env->data_slot;
		} else {
			return -ENODATA;
		}
	}

	if (write)
		chnl = xdma_get_h2c(hpdev);
	else
		chnl = xdma_get_c2h(hpdev);
	if (IS_ERR(chnl))
		return PTR_ERR(chnl);

	pos = cfg->ehdsoff + offset + env->data_slot * cfg->ehdssze;
	iov_iter_truncate(to, cfg->ehdssze - offset);
	res = xdma_channel_read_write(chnl, to, pos);

	if (write)
		xdma_release_h2c(chnl);
	else
		xdma_release_c2h(chnl);

	return res;
}

static long hermes_download_program(struct hermes_env *env,
				    struct hermes_download_prog_ioctl_argp *argp)
{
	struct hermes_pci_dev *hpdev = env->hermes->hpdev;
	struct hermes_cfg *cfg = &hpdev->hdev->cfg;
	struct iov_iter iter;
	struct iovec iovec = {
		.iov_base = (void *) argp->prog,
		.iov_len = argp->len,
	};
	struct xdma_channel *chnl;
	long res;
	loff_t pos;

	if (argp->flags)
		return -EINVAL;

	if (argp->len > cfg->ehpssze) {
		dev_err(&env->hermes->dev,
			"Program size greater than program slot size: 0x%x > 0x%x\n",
			argp->len, cfg->ehpssze);
		return -EINVAL;
	}

	if (env->prog_slot < 0) {
		env->prog_slot = hermes_request_slot_prog(hpdev->hdev);
		if (env->prog_slot < 0)
			return env->prog_slot;
	}

	chnl = xdma_get_h2c(hpdev);
	if (IS_ERR(chnl))
		return PTR_ERR(chnl);

	pos = cfg->ehpsoff + env->prog_slot * cfg->ehpssze;

	iov_iter_init(&iter, WRITE, &iovec, 1, argp->len);
	res = xdma_channel_read_write(chnl, &iter, pos);

	xdma_release_h2c(chnl);

	if (res < 0)
		return res;
	else if (res != argp->len)
		return -EIO;

	return 0;
}

static long hermes_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
{
	struct hermes_env *env = filp->private_data;

	switch(cmd) {
	case HERMES_DOWNLOAD_PROG_IOCTL:
		return hermes_download_program(env,
				(struct hermes_download_prog_ioctl_argp *) arg);
	default:
		return -EINVAL;
	}
}

static const struct file_operations hermes_fops = {
	.owner = THIS_MODULE,
	.open = hermes_open,
	.release = hermes_close,
	.unlocked_ioctl = hermes_ioctl,
	.read_iter = hermes_read_write_iter,
	.write_iter = hermes_read_write_iter,
};

static struct hermes_dev *to_hermes(struct device *dev)
{
	return container_of(dev, struct hermes_dev, dev);
}

static void hermes_release(struct device *dev)
{
	struct hermes_dev *hermes = to_hermes(dev);

	kfree(hermes->irq);
	kfree(hermes);
}

static int hermes_read_cfg(struct hermes_pci_dev *hpdev)
{
	struct hermes_cfg *cfg;
	void __iomem *bar0 = pci_iomap(hpdev->pdev, 0, sizeof(*cfg));
	if (!bar0)
		return -EFAULT;

	cfg = &hpdev->hdev->cfg;

	memcpy_fromio(cfg, bar0, sizeof(*cfg));
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

	hpdev->hdev = hermes;
	hermes->pdev = pdev;
	hermes->hpdev = hpdev;

	err = hermes_read_cfg(hpdev);
	if (err)
		goto out_free;

	device_initialize(&hermes->dev);
	hermes->dev.class = hermes_class;
	hermes->dev.parent = &pdev->dev;
	hermes->dev.release = hermes_release;

	hermes->irq = kcalloc(hermes->cfg.eheng, sizeof(*hermes->irq),
			GFP_KERNEL);
	if (!hermes->irq)
		goto out_free;

	hermes->id = ida_simple_get(&hermes_ida, 0, 0, GFP_KERNEL);
	if (hermes->id < 0) {
		err = hermes->id;
		goto out_free_irq;
	}

	dev_set_name(&hermes->dev, "hermes%d", hermes->id);
	hermes->dev.devt = MKDEV(MAJOR(hermes_devt), hermes->id);

	cdev_init(&hermes->cdev, &hermes_fops);
	hermes->cdev.owner = THIS_MODULE;
	err = cdev_device_add(&hermes->cdev, &hermes->dev);
	if (err)
		goto out_ida;

	ida_init(&hermes->prog_slots);
	ida_init(&hermes->data_slots);

	dev_info(&hermes->dev, "device created");

	return 0;

out_ida:
	ida_simple_remove(&hermes_ida, hermes->id);
out_free_irq:
	kfree(hermes->irq);
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
	ida_destroy(&hermes->prog_slots);
	ida_destroy(&hermes->data_slots);
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

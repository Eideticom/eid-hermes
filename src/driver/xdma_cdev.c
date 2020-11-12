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

#include "xdma_cdev.h"

static struct class *g_xdma_class;

struct kmem_cache *cdev_cache;

enum cdev_type {
	CHAR_XVC,
	CHAR_XDMA_H2C,
	CHAR_XDMA_C2H,
};

static const char * const devnode_names[] = {
	XDMA_NODE_NAME "%d_xvc",
	XDMA_NODE_NAME "%d_h2c_%d",
	XDMA_NODE_NAME "%d_c2h_%d",
};

enum hpdev_flags_bits {
	XDF_CDEV_XVC,
	XDF_CDEV_SG,
};

struct xdma_cdev *cdev_get_c2h(struct hermes_pci_dev *hpdev)
{
	if (hpdev->c2h_channel_max)
		return &hpdev->sgdma_c2h_cdev[0];
	return NULL;
}

struct xdma_cdev *cdev_get_h2c(struct hermes_pci_dev *hpdev)
{
	if (hpdev->h2c_channel_max)
		return &hpdev->sgdma_h2c_cdev[0];
	return NULL;
}

static inline void hpdev_flag_set(struct hermes_pci_dev *hpdev,
				enum hpdev_flags_bits fbit)
{
	hpdev->flags |= 1 << fbit;
}

static inline void xcdev_flag_clear(struct hermes_pci_dev *hpdev,
				enum hpdev_flags_bits fbit)
{
	hpdev->flags &= ~(1 << fbit);
}

static inline int hpdev_flag_test(struct hermes_pci_dev *hpdev,
				enum hpdev_flags_bits fbit)
{
	return hpdev->flags & (1 << fbit);
}

#ifdef __XDMA_SYSFS__
ssize_t xdma_dev_instance_show(struct device *dev,
		struct device_attribute *attr,
		char *buf)
{
	struct hermes_pci_dev *hpdev =
		(struct hermes_pci_dev *)dev_get_drvdata(dev);

	return snprintf(buf, PAGE_SIZE, "%d\t%d\n",
			hpdev->major, hpdev->xdev->idx);
}

static DEVICE_ATTR_RO(xdma_dev_instance);
#endif

static int config_kobject(struct xdma_cdev *xcdev, enum cdev_type type)
{
	int rv = -EINVAL;
	struct xdma_dev *xdev = xcdev->xdev;
	struct xdma_engine *engine = xcdev->engine;

	switch (type) {
	case CHAR_XDMA_H2C:
	case CHAR_XDMA_C2H:
		if (!engine) {
			pr_err("Invalid DMA engine\n");
			return rv;
		}
		rv = kobject_set_name(&xcdev->cdev.kobj, devnode_names[type],
			xdev->idx, engine->channel);
		break;
	case CHAR_XVC:
		rv = kobject_set_name(&xcdev->cdev.kobj, devnode_names[type],
			xdev->idx);
		break;
	default:
		pr_warn("%s: UNKNOWN type 0x%x.\n", __func__, type);
		break;
	}

	if (rv)
		pr_err("%s: type 0x%x, failed %d.\n", __func__, type, rv);
	return rv;
}

int xcdev_check(const char *fname, struct xdma_cdev *xcdev, bool check_engine)
{
	struct xdma_dev *xdev;

	if (!xcdev || xcdev->magic != MAGIC_CHAR) {
		pr_info("%s, xcdev 0x%p, magic 0x%lx.\n",
			fname, xcdev, xcdev ? xcdev->magic : 0xFFFFFFFF);
		return -EINVAL;
	}

	xdev = xcdev->xdev;
	if (!xdev || xdev->magic != MAGIC_DEVICE) {
		pr_info("%s, xdev 0x%p, magic 0x%lx.\n",
			fname, xdev, xdev ? xdev->magic : 0xFFFFFFFF);
		return -EINVAL;
	}

	if (check_engine) {
		struct xdma_engine *engine = xcdev->engine;

		if (!engine || engine->magic != MAGIC_ENGINE) {
			pr_info("%s, engine 0x%p, magic 0x%lx.\n", fname,
				engine, engine ? engine->magic : 0xFFFFFFFF);
			return -EINVAL;
		}
	}

	return 0;
}

int char_open(struct inode *inode, struct file *file)
{
	struct xdma_cdev *xcdev;

	/* pointer to containing structure of the character device inode */
	xcdev = container_of(inode->i_cdev, struct xdma_cdev, cdev);
	if (xcdev->magic != MAGIC_CHAR) {
		pr_err("xcdev 0x%p inode 0x%lx magic mismatch 0x%lx\n",
			xcdev, inode->i_ino, xcdev->magic);
		return -EINVAL;
	}
	/* create a reference to our char device in the opened file */
	file->private_data = xcdev;

	return 0;
}

/*
 * Called when the device goes from used to unused.
 */
int char_close(struct inode *inode, struct file *file)
{
	struct xdma_dev *xdev;
	struct xdma_cdev *xcdev = (struct xdma_cdev *)file->private_data;

	if (!xcdev) {
		pr_err("char device with inode 0x%lx xcdev NULL\n",
			inode->i_ino);
		return -EINVAL;
	}

	if (xcdev->magic != MAGIC_CHAR) {
		pr_err("xcdev 0x%p magic mismatch 0x%lx\n",
				xcdev, xcdev->magic);
		return -EINVAL;
	}

	/* fetch device specific data stored earlier during open */
	xdev = xcdev->xdev;
	if (!xdev) {
		pr_err("char device with inode 0x%lx xdev NULL\n",
			inode->i_ino);
		return -EINVAL;
	}

	if (xdev->magic != MAGIC_DEVICE) {
		pr_err("xdev 0x%p magic mismatch 0x%lx\n", xdev, xdev->magic);
		return -EINVAL;
	}

	return 0;
}

/* create_xcdev() -- create a character device interface to data bus
 *
 * If at least one SG DMA engine is specified, the character device interface
 * is coupled to the SG DMA file operations which operate on the data bus.
 */

static int create_sys_device(struct xdma_cdev *xcdev, enum cdev_type type)
{
	struct xdma_dev *xdev = xcdev->xdev;
	struct xdma_engine *engine = xcdev->engine;
	int last_param;

	last_param = engine ? engine->channel : 0;

	xcdev->sys_device = device_create(g_xdma_class, &xdev->pdev->dev,
		xcdev->cdevno, NULL, devnode_names[type], xdev->idx,
		last_param);

	if (!xcdev->sys_device) {
		pr_err("device_create(%s) failed\n", devnode_names[type]);
		return -1;
	}

	return 0;
}

static int destroy_xcdev(struct xdma_cdev *cdev)
{
	if (!cdev) {
		pr_warn("cdev NULL.\n");
		return -EINVAL;
	}
	if (cdev->magic != MAGIC_CHAR) {
		pr_warn("cdev 0x%p magic mismatch 0x%lx\n", cdev, cdev->magic);
		return -EINVAL;
	}

	if (!cdev->xdev) {
		pr_err("xdev NULL\n");
		return -EINVAL;
	}

	if (!g_xdma_class) {
		pr_err("g_xdma_class NULL\n");
		return -EINVAL;
	}

	if (!cdev->sys_device) {
		pr_err("cdev sys_device NULL\n");
		return -EINVAL;
	}

	if (cdev->sys_device)
		device_destroy(g_xdma_class, cdev->cdevno);

	cdev_del(&cdev->cdev);

	return 0;
}

static int create_xcdev(struct hermes_pci_dev *hpdev, struct xdma_cdev *xcdev,
			int bar, struct xdma_engine *engine,
			enum cdev_type type)
{
	int rv;
	int minor;
	struct xdma_dev *xdev = hpdev->xdev;
	dev_t dev;

	spin_lock_init(&xcdev->lock);
	/* new instance? */
	if (!hpdev->major) {
		/* allocate a dynamically allocated char device node */
		int rv = alloc_chrdev_region(&dev, XDMA_MINOR_BASE,
					XDMA_MINOR_COUNT, XDMA_NODE_NAME);

		if (rv) {
			pr_err("unable to allocate cdev region %d.\n", rv);
			return rv;
		}
		hpdev->major = MAJOR(dev);
	}

	/*
	 * do not register yet, create kobjects and name them,
	 */
	xcdev->magic = MAGIC_CHAR;
	xcdev->cdev.owner = THIS_MODULE;
	xcdev->hpdev = hpdev;
	xcdev->xdev = xdev;
	xcdev->engine = engine;
	xcdev->bar = bar;

	rv = config_kobject(xcdev, type);
	if (rv < 0)
		return rv;

	switch (type) {
	case CHAR_XVC:
		/* minor number is type index for non-SGDMA interfaces */
		minor = type;
		cdev_xvc_init(xcdev);
		break;
	case CHAR_XDMA_H2C:
		minor = 32 + engine->channel;
		cdev_sgdma_init(xcdev);
		break;
	case CHAR_XDMA_C2H:
		minor = 36 + engine->channel;
		cdev_sgdma_init(xcdev);
		break;
	default:
		pr_info("type 0x%x NOT supported.\n", type);
		return -EINVAL;
	}
	xcdev->cdevno = MKDEV(hpdev->major, minor);

	/* bring character device live */
	rv = cdev_add(&xcdev->cdev, xcdev->cdevno, 1);
	if (rv < 0) {
		pr_err("cdev_add failed %d, type 0x%x.\n", rv, type);
		goto unregister_region;
	}

	dbg_init("xcdev 0x%p, %u:%u, %s, type 0x%x.\n",
		xcdev, hpdev->major, minor, xcdev->cdev.kobj.name, type);

	/* create device on our class */
	if (g_xdma_class) {
		rv = create_sys_device(xcdev, type);
		if (rv < 0)
			goto del_cdev;
	}

	return 0;

del_cdev:
	cdev_del(&xcdev->cdev);
unregister_region:
	unregister_chrdev_region(xcdev->cdevno, XDMA_MINOR_COUNT);
	return rv;
}

void hpdev_destroy_interfaces(struct hermes_pci_dev *hpdev)
{
	int i = 0;
	int rv;
#ifdef __XDMA_SYSFS__
	device_remove_file(&hpdev->pdev->dev, &dev_attr_xdma_dev_instance);
#endif

	if (hpdev_flag_test(hpdev, XDF_CDEV_SG)) {
		/* iterate over channels */
		for (i = 0; i < hpdev->h2c_channel_max; i++) {
			/* remove SG DMA character device */
			rv = destroy_xcdev(&hpdev->sgdma_h2c_cdev[i]);
			if (rv < 0)
				pr_err("Failed to destroy h2c xcdev %d error :0x%x\n",
						i, rv);
		}
		for (i = 0; i < hpdev->c2h_channel_max; i++) {
			rv = destroy_xcdev(&hpdev->sgdma_c2h_cdev[i]);
			if (rv < 0)
				pr_err("Failed to destroy c2h xcdev %d error 0x%x\n",
						i, rv);
		}
	}


	if (hpdev_flag_test(hpdev, XDF_CDEV_XVC)) {
		rv = destroy_xcdev(&hpdev->xvc_cdev);
		if (rv < 0)
			pr_err("Failed to destroy xvc cdev %d error 0x%x\n",
				i, rv);
	}

	if (hpdev->major)
		unregister_chrdev_region(
				MKDEV(hpdev->major, XDMA_MINOR_BASE),
				XDMA_MINOR_COUNT);
}

int hpdev_create_interfaces(struct hermes_pci_dev *hpdev)
{
	struct xdma_dev *xdev = hpdev->xdev;
	struct xdma_engine *engine;
	int i;
	int rv = 0;

	/* iterate over channels */
	for (i = 0; i < hpdev->h2c_channel_max; i++) {
		engine = &xdev->engine_h2c[i];

		if (engine->magic != MAGIC_ENGINE)
			continue;

		rv = create_xcdev(hpdev, &hpdev->sgdma_h2c_cdev[i], i, engine,
				 CHAR_XDMA_H2C);
		if (rv < 0) {
			pr_err("create char h2c %d failed, %d.\n", i, rv);
			goto fail;
		}
	}

	for (i = 0; i < hpdev->c2h_channel_max; i++) {
		engine = &xdev->engine_c2h[i];

		if (engine->magic != MAGIC_ENGINE)
			continue;

		rv = create_xcdev(hpdev, &hpdev->sgdma_c2h_cdev[i], i, engine,
				 CHAR_XDMA_C2H);
		if (rv < 0) {
			pr_err("create char c2h %d failed, %d.\n", i, rv);
			goto fail;
		}
	}
	hpdev_flag_set(hpdev, XDF_CDEV_SG);

#ifdef __XDMA_SYSFS__
	/* sys file */
	rv = device_create_file(&hpdev->pdev->dev,
				&dev_attr_xdma_dev_instance);
	if (rv) {
		pr_err("Failed to create device file\n");
		goto fail;
	}
#endif

	return 0;

fail:
	rv = -1;
	hpdev_destroy_interfaces(hpdev);
	return rv;
}

int xdma_cdev_init(void)
{
	g_xdma_class = class_create(THIS_MODULE, XDMA_NODE_NAME);
	if (IS_ERR(g_xdma_class)) {
		dbg_init(XDMA_NODE_NAME ": failed to create class");
		return -EINVAL;
	}

	return 0;
}

void xdma_cdev_cleanup(void)
{
	if (g_xdma_class)
		class_destroy(g_xdma_class);
}
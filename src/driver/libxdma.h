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
#ifndef XDMA_LIB_H
#define XDMA_LIB_H

#include <linux/version.h>
#include <linux/types.h>
#include <linux/uaccess.h>
#include <linux/module.h>
#include <linux/dma-mapping.h>
#include <linux/init.h>
#include <linux/interrupt.h>
#include <linux/jiffies.h>
#include <linux/kernel.h>
#include <linux/pci.h>
#include <linux/workqueue.h>

#if LINUX_VERSION_CODE < KERNEL_VERSION(4, 14, 0)
#error The Hermes driver requires Linux 4.14+
#endif

/*
 * if the config bar is fixed, the driver does not neeed to search through
 * all of the bars
 */

/* SECTION: Preprocessor macros/constants */
#define XDMA_BAR_NUM		(6)

/* maximum amount of register space to map */
#define XDMA_BAR_SIZE		(0x8000UL)

#define XDMA_CHANNEL_NUM_MAX	(4)
/*
 * interrupts per engine, rad2_vul.sv:237
 * .REG_IRQ_OUT	(reg_irq_from_ch[(channel*2) +: 2]),
 */
#define XDMA_ENG_IRQ_NUM	(1)
#define MAX_EXTRA_ADJ		(0x3F)

/* Target internal components on XDMA control BAR */
#define XDMA_OFS_INT_CTRL	(0x2000UL)
#define XDMA_OFS_CONFIG		(0x3000UL)

/* maximum number of desc per transfer request */
#define XDMA_TRANSFER_MAX_DESC (2048)

/* maximum size of a single DMA transfer descriptor */
#define XDMA_DESC_BLEN_BITS	28
#define XDMA_DESC_BLEN_MAX	((1 << (XDMA_DESC_BLEN_BITS)) - 1)

/* bits of the SG DMA control register */
#define XDMA_CTRL_RUN_STOP			(1UL << 0)
#define XDMA_CTRL_IE_DESC_STOPPED		(1UL << 1)
#define XDMA_CTRL_IE_DESC_COMPLETED		(1UL << 2)
#define XDMA_CTRL_IE_DESC_ALIGN_MISMATCH	(1UL << 3)
#define XDMA_CTRL_IE_MAGIC_STOPPED		(1UL << 4)
#define XDMA_CTRL_IE_IDLE_STOPPED		(1UL << 6)
#define XDMA_CTRL_IE_READ_ERROR			(0x1FUL << 9)
#define XDMA_CTRL_IE_DESC_ERROR			(0x1FUL << 19)
#define XDMA_CTRL_NON_INCR_ADDR			(1UL << 25)

/* bits of the SG DMA status register */
#define XDMA_STAT_BUSY			(1UL << 0)
#define XDMA_STAT_DESC_STOPPED		(1UL << 1)
#define XDMA_STAT_DESC_COMPLETED	(1UL << 2)
#define XDMA_STAT_ALIGN_MISMATCH	(1UL << 3)
#define XDMA_STAT_MAGIC_STOPPED		(1UL << 4)
#define XDMA_STAT_INVALID_LEN		(1UL << 5)
#define XDMA_STAT_IDLE_STOPPED		(1UL << 6)

#define XDMA_STAT_COMMON_ERR_MASK \
	(XDMA_STAT_ALIGN_MISMATCH | XDMA_STAT_MAGIC_STOPPED | \
	 XDMA_STAT_INVALID_LEN)

/* desc_error, C2H & H2C */
#define XDMA_STAT_DESC_UNSUPP_REQ	(1UL << 19)
#define XDMA_STAT_DESC_COMPL_ABORT	(1UL << 20)
#define XDMA_STAT_DESC_PARITY_ERR	(1UL << 21)
#define XDMA_STAT_DESC_HEADER_EP	(1UL << 22)
#define XDMA_STAT_DESC_UNEXP_COMPL	(1UL << 23)

#define XDMA_STAT_DESC_ERR_MASK	\
	(XDMA_STAT_DESC_UNSUPP_REQ | XDMA_STAT_DESC_COMPL_ABORT | \
	 XDMA_STAT_DESC_PARITY_ERR | XDMA_STAT_DESC_HEADER_EP | \
	 XDMA_STAT_DESC_UNEXP_COMPL)

/* read error: H2C */
#define XDMA_STAT_H2C_R_UNSUPP_REQ	(1UL << 9)
#define XDMA_STAT_H2C_R_COMPL_ABORT	(1UL << 10)
#define XDMA_STAT_H2C_R_PARITY_ERR	(1UL << 11)
#define XDMA_STAT_H2C_R_HEADER_EP	(1UL << 12)
#define XDMA_STAT_H2C_R_UNEXP_COMPL	(1UL << 13)

#define XDMA_STAT_H2C_R_ERR_MASK	\
	(XDMA_STAT_H2C_R_UNSUPP_REQ | XDMA_STAT_H2C_R_COMPL_ABORT | \
	 XDMA_STAT_H2C_R_PARITY_ERR | XDMA_STAT_H2C_R_HEADER_EP | \
	 XDMA_STAT_H2C_R_UNEXP_COMPL)

/* write error, H2C only */
#define XDMA_STAT_H2C_W_DECODE_ERR	(1UL << 14)
#define XDMA_STAT_H2C_W_SLAVE_ERR	(1UL << 15)

#define XDMA_STAT_H2C_W_ERR_MASK	\
	(XDMA_STAT_H2C_W_DECODE_ERR | XDMA_STAT_H2C_W_SLAVE_ERR)

/* read error: C2H */
#define XDMA_STAT_C2H_R_DECODE_ERR	(1UL << 9)
#define XDMA_STAT_C2H_R_SLAVE_ERR	(1UL << 10)

#define XDMA_STAT_C2H_R_ERR_MASK	\
	(XDMA_STAT_C2H_R_DECODE_ERR | XDMA_STAT_C2H_R_SLAVE_ERR)

/* all combined */
#define XDMA_STAT_H2C_ERR_MASK	\
	(XDMA_STAT_COMMON_ERR_MASK | XDMA_STAT_DESC_ERR_MASK | \
	 XDMA_STAT_H2C_R_ERR_MASK | XDMA_STAT_H2C_W_ERR_MASK) 

#define XDMA_STAT_C2H_ERR_MASK	\
	(XDMA_STAT_COMMON_ERR_MASK | XDMA_STAT_DESC_ERR_MASK | \
	 XDMA_STAT_C2H_R_ERR_MASK)

/* bits of the SGDMA descriptor control field */
#define XDMA_DESC_STOPPED	(1UL << 0)
#define XDMA_DESC_COMPLETED	(1UL << 1)
#define XDMA_DESC_EOP		(1UL << 4)

/* upper 16-bits of engine identifier register */
#define XDMA_ID_H2C 0x1fc0U
#define XDMA_ID_C2H 0x1fc1U

#define LS_BYTE_MASK 0x000000FFUL

#define BLOCK_ID_MASK 0xFFF00000
#define BLOCK_ID_HEAD 0x1FC00000

#define IRQ_BLOCK_ID 0x1fc20000UL
#define CONFIG_BLOCK_ID 0x1fc30000UL

#define DESC_MAGIC 0xAD4B0000UL

#define H2C_CHANNEL_OFFSET 0x1000
#define SGDMA_OFFSET_FROM_CHANNEL 0x4000
#define CHANNEL_SPACING 0x100

/* obtain the 32 most significant (high) bits of a 32-bit or 64-bit address */
#define PCI_DMA_H(addr) ((addr >> 16) >> 16)
/* obtain the 32 least significant (low) bits of a 32-bit or 64-bit address */
#define PCI_DMA_L(addr) (addr & 0xffffffffUL)

/* SECTION: Enum definitions */
enum transfer_state {
	TRANSFER_STATE_NEW = 0,
	TRANSFER_STATE_SUBMITTED,
	TRANSFER_STATE_COMPLETED,
	TRANSFER_STATE_FAILED,
	TRANSFER_STATE_ABORTED
};

enum shutdown_state {
	ENGINE_SHUTDOWN_NONE = 0,	/* No shutdown in progress */
	ENGINE_SHUTDOWN_REQUEST = 1,	/* engine requested to shutdown */
	ENGINE_SHUTDOWN_IDLE = 2	/* engine has shutdown and is idle */
};

enum dev_capabilities {
	CAP_64BIT_DMA = 2,
	CAP_64BIT_DESC = 4,
	CAP_ENGINE_WRITE = 8,
	CAP_ENGINE_READ = 16
};

/* SECTION: Structure definitions */

struct config_regs {
	u32 identifier;
	u32 reserved_1[4];
};

/**
 * SG DMA Controller status and control registers
 *
 * These registers make the control interface for DMA transfers.
 *
 * It sits in End Point (FPGA) memory BAR[0] for 32-bit or BAR[0:1] for 64-bit.
 * It references the first descriptor which exists in Root Complex (PC) memory.
 *
 * @note The registers must be accessed using 32-bit (PCI DWORD) read/writes,
 * and their values are in little-endian byte ordering.
 */
struct engine_regs {
	u32 identifier;
	u32 control;
	u32 control_w1s;
	u32 control_w1c;
	u32 reserved_1[12];	/* padding */

	u32 status;
	u32 status_rc;
	u32 completed_desc_count;
	u32 alignments;
	u32 reserved_2[14];	/* padding */

	u32 poll_mode_wb_lo;
	u32 poll_mode_wb_hi;
	u32 interrupt_enable_mask;
	u32 interrupt_enable_mask_w1s;
	u32 interrupt_enable_mask_w1c;
	u32 reserved_3[9];	/* padding */

	u32 perf_ctrl;
	u32 perf_cyc_lo;
	u32 perf_cyc_hi;
	u32 perf_dat_lo;
	u32 perf_dat_hi;
	u32 perf_pnd_lo;
	u32 perf_pnd_hi;
} __packed;

struct engine_sgdma_regs {
	u32 identifier;
	u32 reserved_1[31];	/* padding */

	/* bus address to first descriptor in Root Complex Memory */
	u32 first_desc_lo;
	u32 first_desc_hi;
	/* number of adjacent descriptors at first_desc */
	u32 first_desc_adjacent;
	u32 credits;
} __packed;

struct msix_vec_table_entry {
	u32 msi_vec_addr_lo;
	u32 msi_vec_addr_hi;
	u32 msi_vec_data_lo;
	u32 msi_vec_data_hi;
} __packed;

struct msix_vec_table {
	struct msix_vec_table_entry entry_list[32];
} __packed;

struct interrupt_regs {
	u32 identifier;
	u32 user_int_enable;
	u32 user_int_enable_w1s;
	u32 user_int_enable_w1c;
	u32 channel_int_enable;
	u32 channel_int_enable_w1s;
	u32 channel_int_enable_w1c;
	u32 reserved_1[9];	/* padding */

	u32 user_int_request;
	u32 channel_int_request;
	u32 user_int_pending;
	u32 channel_int_pending;
	u32 reserved_2[12];	/* padding */

	u32 user_msi_vector[8];
	u32 channel_msi_vector[8];
} __packed;

struct sgdma_common_regs {
	u32 padding[8];
	u32 credit_mode_enable;
	u32 credit_mode_enable_w1s;
	u32 credit_mode_enable_w1c;
} __packed;

/**
 * Descriptor for a single contiguous memory block transfer.
 *
 * Multiple descriptors are linked by means of the next pointer. An additional
 * extra adjacent number gives the amount of extra contiguous descriptors.
 *
 * The descriptors are in root complex memory, and the bytes in the 32-bit
 * words must be in little-endian byte ordering.
 */
struct xdma_desc {
	u32 control;
	u32 bytes;		/* transfer length in bytes */
	u32 src_addr_lo;	/* source address (low 32-bit) */
	u32 src_addr_hi;	/* source address (high 32-bit) */
	u32 dst_addr_lo;	/* destination address (low 32-bit) */
	u32 dst_addr_hi;	/* destination address (high 32-bit) */
	/*
	 * next descriptor in the single-linked list of descriptors;
	 * this is the PCIe (bus) address of the next descriptor in the
	 * root complex memory
	 */
	u32 next_lo;		/* next desc address (low 32-bit) */
	u32 next_hi;		/* next desc address (high 32-bit) */
} __packed;

/* 32 bytes (four 32-bit words) or 64 bytes (eight 32-bit words) */
struct xdma_result {
	u32 status;
	u32 length;
	u32 reserved_1[6];	/* padding */
} __packed;

struct sw_desc {
	dma_addr_t addr;
	unsigned int len;
};

/* Describes a (SG DMA) single transfer for the engine */
struct xdma_transfer {
	struct list_head entry;		/* queue of non-completed transfers */
	struct xdma_desc *desc_virt;	/* virt addr of the 1st descriptor */
	dma_addr_t desc_bus;		/* bus addr of the first descriptor */
	int desc_adjacent;		/* adjacent descriptors at desc_bus */
	int desc_num;			/* number of descriptors in transfer */
	enum dma_data_direction dir;
	wait_queue_head_t wq;		/* wait queue for transfer completion */

	enum transfer_state state;	/* state of the transfer */
	unsigned int flags;
#define XFER_FLAG_NEED_UNMAP	0x1
	int last_in_request;		/* flag if last within request */
	unsigned int len;
	struct sg_table *sgt;
};

struct xdma_request_cb {
	struct sg_table *sgt;
	unsigned int total_len;
	u64 ep_addr;

	struct xdma_transfer xfer;

	unsigned int sw_desc_idx;
	unsigned int sw_desc_cnt;
	struct sw_desc sdesc[0];
};

struct xdma_engine {
	unsigned long magic;	/* structure ID for sanity checks */
	struct xdma_dev *xdev;	/* parent device */
	char name[5];		/* name of this engine */
	int version;		/* version of this engine */

	/* HW register address offsets */
	struct engine_regs *regs;		/* Control reg BAR offset */
	struct engine_sgdma_regs *sgdma_regs;	/* SGDAM reg BAR offset */

	/* Engine state, configuration and flags */
	enum shutdown_state shutdown;	/* engine shutdown mode */
	enum dma_data_direction dir;
	int running;		/* flag if the driver started engine */
	int non_incr_addr;	/* flag if non-incremental addressing used */
	int addr_align;		/* source/dest alignment in bytes */
	int len_granularity;	/* transfer length multiple */
	int channel;		/* engine indices */
	int desc_dequeued;	/* num descriptors of completed transfers */
	u32 status;		/* last known status of device */
	/* only used for MSIX mode to store per-engine interrupt mask value */
	u32 interrupt_enable_mask_value;

	/* Transfer list management */
	struct list_head transfer_list;	/* queue of transfers */

	/* Members associated with interrupt mode support */
	spinlock_t lock;		/* protects concurrent access */
	int msix_irq_line;		/* MSI-X vector for this engine */
	struct work_struct work;	/* Work queue for interrupt handling */

	struct mutex desc_lock;		/* protects concurrent access */
	dma_addr_t desc_bus;
	struct xdma_desc *desc;
};

/* XDMA PCIe device specific book-keeping */
#define XDEV_FLAG_OFFLINE	0x1
struct xdma_dev {
	struct list_head list_head;
	struct list_head rcu_node;

	unsigned long magic;		/* structure ID for sanity checks */
	struct pci_dev *pdev;	/* pci device struct from probe() */
	int idx;		/* dev index */

	const char *mod_name;		/* name of module owning the dev */

	spinlock_t lock;		/* protects concurrent access */
	unsigned int flags;

	/* PCIe BAR management */
	void __iomem *bar[XDMA_BAR_NUM];	/* addresses for mapped BARs */
	int config_bar_idx;	/* BAR index of XDMA config logic */
	int regions_in_use;	/* flag if dev was in use during probe() */
	int got_regions;	/* flag if probe() obtained the regions */

	int c2h_channel_max;
	int h2c_channel_max;

	/* Interrupt management */
	int irq_line;		/* flag if irq allocated successfully */

	/* XDMA engine management */
	struct xdma_engine engine_h2c[XDMA_CHANNEL_NUM_MAX];
	struct xdma_engine engine_c2h[XDMA_CHANNEL_NUM_MAX];
};

static inline int xdma_device_flag_check(struct xdma_dev *xdev, unsigned int f)
{
	unsigned long flags;

	spin_lock_irqsave(&xdev->lock, flags);
	if (xdev->flags & f) {
		spin_unlock_irqrestore(&xdev->lock, flags);
		return 1;
	}
	spin_unlock_irqrestore(&xdev->lock, flags);
	return 0;
}

static inline void xdma_device_flag_set(struct xdma_dev *xdev, unsigned int f)
{
	unsigned long flags;

	spin_lock_irqsave(&xdev->lock, flags);
	xdev->flags |= f;
	spin_unlock_irqrestore(&xdev->lock, flags);
}

static inline void xdma_device_flag_clear(struct xdma_dev *xdev, unsigned int f)
{
	unsigned long flags;

	spin_lock_irqsave(&xdev->lock, flags);
	xdev->flags &= ~f;
	spin_unlock_irqrestore(&xdev->lock, flags);
}

void write_register(u32 value, void *iomem);
u32 read_register(void *iomem);

struct xdma_dev *xdev_find_by_pdev(struct pci_dev *pdev);

void xdma_device_offline(struct pci_dev *pdev, void *dev_handle);
void xdma_device_online(struct pci_dev *pdev, void *dev_handle);
/*
 * xdma_device_open - read the pci bars and configure the fpga
 *	should be called from probe()
 * @pdev: ptr to pci_dev
 * @mod_name: the module name to be used for request_irq
 * @channel_max: max # of c2h and h2c channels to be configured
 * returns
 *	a opaque handle (for libxdma to identify the device)
 *	NULL, in case of error
 */
void *xdma_device_open(const char *mod_name, struct pci_dev *pdev,
		 int *h2c_channel_max, int *c2h_channel_max);

/*
 * xdma_device_close - prepare fpga for removal: disable all interrupts (users
 * and xdma) and release all resources
 *	should called from remove()
 * @pdev: ptr to struct pci_dev
 * @tuples: from xdma_device_open()
 */
void xdma_device_close(struct pci_dev *pdev, void *dev_handle);

/*
 * xdma_xfer_submit - submit data for dma operation (for both read and write)
 *	This is a blocking call
 * @channel: channle number (< channel_max)
 *	== channel_max means libxdma can pick any channel available:q

 * @dir: DMA_FROM/TO_DEVICE
 * @offset: offset into the DDR/BRAM memory to read from or write to
 * @sg_tbl: the scatter-gather list of data buffers
 * @timeout: timeout in mili-seconds, *currently ignored
 * return # of bytes transfered or
 *	 < 0 in case of error
 */
ssize_t xdma_xfer_submit(void *dev_hndl, int channel, bool write, u64 ep_addr,
			struct sg_table *sgt, bool dma_mapped, int timeout_ms);

void xdma_irq_teardown(struct xdma_dev *xdev);
int xdma_irq_setup(struct xdma_dev *xdev);
#endif /* XDMA_LIB_H */

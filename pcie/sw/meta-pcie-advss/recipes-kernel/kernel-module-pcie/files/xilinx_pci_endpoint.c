/**************************************************************************
 * Copyright (C) 2021 Xilinx, Inc.
 *
 * Copyright(C) 2022-2026 Advanced Micro Devices, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 *
 **************************************************************************/
#include <linux/cdev.h>
#include <linux/clk.h>
#include <linux/dma-mapping.h>
#include <linux/fs.h>
#include <linux/init.h>
#include <linux/interrupt.h>
#include <linux/io.h>
#include <linux/ioport.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/mutex.h>
#include <linux/of.h>
#include <linux/of_device.h>
#include <linux/delay.h>
#include <linux/sched.h>
#include <linux/device.h>
#include <linux/platform_device.h>
#include <linux/slab.h>
#include <linux/string.h>
#include <linux/sysctl.h>
#include <linux/types.h>
#include <linux/uaccess.h>
#include <linux/scatterlist.h>
#include <linux/pagemap.h>
#include <linux/list.h>
#include <linux/spinlock.h>
#include <linux/version.h>
#include <linux/of_address.h>
#include <linux/of_irq.h>
#include <linux/dma-buf.h>
#include <linux/dma-mapping.h>
#include <asm/page.h>
#include <asm/byteorder.h>
#include <linux/of_reserved_mem.h>
#include <linux/iosys-map.h>

#define DEVICE_MAX_NUM      256
#define MAX_INSTANCES	    4
#define DRIVER_NAME        "pciep"
#define DEVICE_NAME_FORMAT "pciep%d"

/* PCIe registers to perform file read */
#define PCIEP_READ_BUFFER_READY   		0x00
#define PCIEP_READ_BUFFER_ADDR_LOW   		0x04
#define PCIEP_READ_BUFFER_OFFSET 		0x08
#define PCIEP_READ_BUFFER_SIZE   		0x0c
#define PCIEP_READ_BUFFER_ADDR_HIGH   		0x3c
#define PCIEP_READ_TRANSFER_DONE   		0x20
#define PCIEP_READ_TRANSFER_CLR    		0x28
#define PCIEP_READ_BUFFER_HOST_INTR 		0x2c

/* PCIe registers to perfrom file write */
#define PCIEP_WRITE_BUFFER_READY   		0x10
#define PCIEP_WRITE_BUFFER_ADDR_LOW   		0x14
#define PCIEP_WRITE_BUFFER_OFFSET 		0x18
#define PCIEP_WRITE_BUFFER_SIZE   		0x1c
#define PCIEP_WRITE_TRANSFER_DONE  		0x24
#define PCIEP_WRITE_TRANSFER_CLR  		0x30
#define PCIEP_WRITE_BUFFER_ADDR_HIGH   		0x38

/* HOST PARAMETERS INFO */
#define PCIRC_READ_FILE_LENGTH     		0x84
#define PCIRC_READ_BUFFER_TRANSFER_DONE 	0x88
#define PCIRC_WRITE_BUFFER_TRANSFER_DONE 	0x8c
#define PCIRC_HDMI_PID_SET 			0x90
#define PCIRC_FILTER_TYPE         		0x94
#define PCIRC_RAW_RESOLUTION      		0x98
#define PCIRC_FORMAT_SET        		0x9c
#define PCIRC_UCASE_SET       			0xa0
#define PCIRC_KERNEL_MODE	      		0xa4
#define PCIRC_SET_FPS        			0xa8
#define PCIEP_FILTER_KERNEL_NAME  		0xac
#define PCIRC_READ_SIG  			0xb4

/* Interrupt registers to interrupt ps from host machine */
#define PCIRC_READ_BUFFER_TRANSFER_DONE_INTR 	0xf0
#define PCIRC_WRITE_BUFFER_TRANSFER_DONE_INTR 	0xf4 
#define PCIRC_HOST_DONE_INTR			0xf8 

/* Macro's to mask PCIe registers */
#define PCIEP_CLR_REG            	0x0
#define SET_BUFFER_RDY           	0x1

/* IOCTL numbers */ 
#define GET_FILE_LENGTH			0x0
#define GET_KERNEL_MODE			0x1
#define SET_READ_OFFSET			0x2
#define SET_WRITE_OFFSET		0x3
#define SET_READ_TRANSFER_DONE    	0x5
#define CLR_READ_TRANSFER_DONE    	0x6
#define SET_WRITE_TRANSFER_DONE   	0x7
#define CLR_WRITE_TRANSFER_DONE   	0x8
#define GET_RESOLUTION            	0x9
#define GET_HDMI_PID              	0xa
#define GET_FPS                   	0xb
#define GET_FORMAT                	0xc
#define GET_FILTER_TYPE           	0xd
#define ALLOC_DMA_BUFF            	0xe
#define RELEASE_DMA_BUFF          	0xf
#define PCIE_DMABUF_IMPORT        	0x1b
#define GET_KERNEL_NAME        	  	0x1c
#define GET_USE_CASE        	  	0x1d
#define MAP_DMA_BUFF		  	0x1e
#define UNMAP_DMA_BUFF            	0x1f
#define READ_SIG		  	0x20
#define NUM_DMA_BUF		  	0x21

/* Macro's used for masking resoltion */
#define WIDTH_SHIFT               	0x0
#define WIDTH_MASK                	0xFFFF
#define HEIGHT_SHIFT              	16
#define HEIGHT_MASK               	0xFFFF

/*Macro's used for masking offset */
#define READ_BUF_HIGH_OFFSET      0xFFFF0000
#define WRITE_BUF_HIGH_OFFSET     0xFFFF0000

/*
 * ============================================================================
 * EP DMA BUFFER POOL DEPTH  --  SINGLE SOURCE OF TRUTH
 * ============================================================================
 * Number of DMA-coherent frame buffers this driver allocates out of the
 * reserved-memory pool and exports as dma-bufs to userspace.
 *
 * THIS VALUE MUST STAY EQUAL TO MAX_BUFFER_POOL_SIZE IN
 *   pcie_gst_app/include/pcie_abstract.h
 * The endpoint application cycles exactly MAX_BUFFER_POOL_SIZE of these
 * buffers; if the driver allocates fewer, MAP_DMA_BUFF fails, and if it
 * allocates more the extra memory is simply never used.
 *
 * Why 6 -- 4 minimum in-flight + 2 headroom:
 *   1. H2C DMA in progress          (host writing into the buffer)
 *   2. queued in perf/appsink       (handed downstream by pciesrc)
 *   3. held by appsink until its PTS (appsink sync=TRUE for UC2+)
 *   4. C2H DMA in progress          (host reading out of the buffer)
 *   5-6. headroom for GStreamer scheduling jitter, slow appsink,
 *        or pipeline element queuing that temporarily holds an extra
 *        buffer -- prevents the critical H2C/C2H collision that
 *        causes the 10 s QDMA timeout.
 *
 * Do NOT reduce this below 4.  With a shallower pool pciesrc re-arms a
 * buffer for H2C while pciesink is still C2H-ing it.  The host QDMA then
 * reads and writes the same 24.8 MB region concurrently over the NoC, the
 * transaction never retires, and the host hits its 10 s DMA timeout
 * ("W off 0x... failed -1", EIO), followed by read_complete / write_complete
 * timeouts here.
 *
 * Cost: NUM_BUFFERS x frame_size.  At 4K RGB888 that is 6 x 24 883 200 B
 * = 149.3 MB, which must fit in the reserved-memory region declared in the
 * device tree (currently 0x31000000, size 0x10000000 = 256 MB).
 *
 * NOTE: this is unrelated to the host application's staging ring depths
 * (HOST_DISPLAY_RING_DEPTH / HOST_FILE_RING_DEPTH in pcie_host.h).  Those
 * are plain malloc'd buffers in host DDR and are deliberately sized
 * differently -- see the comment there.
 * ============================================================================
 */
#define NUM_BUFFERS		6

/* dma_buf export names, one per buffer -- must have NUM_BUFFERS entries.
 * A missing entry leaves exp_name NULL, which shows up as "(null)" in
 * /sys/kernel/debug/dma_buf/bufinfo. */
char *fd_names[NUM_BUFFERS] = {
	"fd1",
	"fd2",
	"fd3",
	"fd4",
	"fd5",
	"fd6"
};
/**
 * struct pcie_dmabuf_mem - Tracks a dma-buf imported from userspace.
 * @dbuf_fd:     The userspace file descriptor for this dma-buf.
 * @flag:        Import state (1=imported, 0=released).
 * @dbuf:        Kernel dma_buf pointer obtained via dma_buf_get().
 * @dbuf_attach: Attachment to this driver's device.
 * @sgt:         Scatter-gather table for the attachment.
 * @dir:         DMA direction (DMA_BIDIRECTIONAL for PCIe endpoint).
 * @list:        Linked into pciep_driver_data.attachments.
 */
struct pcie_dmabuf_mem {
    int dbuf_fd;
    int flag;
    struct dma_buf *dbuf;
    struct dma_buf_attachment *dbuf_attach;
    struct sg_table *sgt;
    enum dma_data_direction dir;
    struct list_head list;
};

enum pcie_dmabuf_dir {
    PCIE_DMABUF_DIR_BIDIR    = 1,
    PCIE_DMABUF_DIR_TO_DEV   = 2,
    PCIE_DMABUF_DIR_FROM_DEV = 3,
    PCIE_DMABUF_DIR_NONE     = 4,
};
/**
 * struct pcie_dmabuf_args : User data for dma importing.
 * dbuf_fd : dma buffer fd.
 * flag : flag to import or release imported dma buffer.
 * dir : Direction of dma buffer.
 */
struct pcie_dmabuf_args {
    __s32   dbuf_fd;
    __s32   flag;
    __u64   dma_addr;
    __u64   size;
    __u8    dir;
};


/**
 * struct pciep_file_priv - per-open-file private data
 * Stores the active buffer index selected by the last MAP_DMA_BUFF ioctl
 * so that concurrent opens of the same device do not share a single index.
 */
struct pciep_file_priv {
	struct pciep_driver_data *driver;
	int active_index;  /* index into read_phys_addr[] set by MAP_DMA_BUFF */
};

static DEFINE_IDA(pciep_device_ida);
static dev_t  pciep_device_number;
static bool pciep_platform_driver_done;
static struct class *pciep_sys_class;
static DEFINE_MUTEX(pcie_read_mutex);
static DEFINE_MUTEX(pcie_write_mutex);

/**
 * struct pciep_driver_data - Plmem driver data
 * @sys_dev: character device pointer
 * @dma_dev: Device pointer
 * @regs: points to BARMAP region
 * @read_virt_addr: virtual address for read memory region
 * @cdev: character device structure
 * @read_complete: completion variable for read
 * @write_complete: completion variable for write
 * @mutex_lock: lock for dma buf attachments
 * @attachments: list of dma_buf_attachment 
 * @device_number: Minor number
 * @read_phys_addr: physical address for read memory region
 * @write_phys_addr: physical address for write memory region
 * @alloc_size: size of memory pool
 * @rd_irq: read interrupt number
 * @wr_irq: write interrupt number
 * @host_done_irq: Host done interrupt number
 * @read_req: Read or write request from application.
 */
struct pciep_driver_data {
	struct device *sys_dev;
	struct device *dma_dev;
	void __iomem *regs;
	void *read_virt_addr[NUM_BUFFERS];
	struct cdev cdev;
	struct completion read_complete;
	struct completion write_complete;
	struct mutex lock;
	struct list_head attachments;
	dev_t device_number;
	dma_addr_t read_phys_addr[NUM_BUFFERS];
	dma_addr_t write_phys_addr;
	size_t alloc_size;
	int rd_irq;
	int wr_irq;
	int host_done_irq;
	int read_req;
    	int fd[NUM_BUFFERS];	/* fd */
   	int fd_inuse[NUM_BUFFERS];
	int active_index;
	/* Atomic flags set by IRQ handlers to record that the interrupt
	 * fired.  Checked by the tiered-timeout recovery path in file_read
	 * and file_write.  Unlike the pcie-reg-space TRANSFER_DONE data
	 * register (0x88/0x8c), these flags are owned entirely by the
	 * driver — the host cannot clear them.  This avoids the race where
	 * the host re-clears TRANSFER_DONE at the start of the next loop
	 * iteration before the EP times out and polls the register. */
	atomic_t read_irq_fired;
	atomic_t write_irq_fired;
};

struct pciep_alloc_dma_buf {
	int fd;	/* fd */
	unsigned int flags;/* flags to map with */
	size_t size;	/* size */
};

struct pciep_dma_buf_attachment {
	struct device *dev;
	struct sg_table sgt;
	struct list_head node;
};


typedef struct resolution {
    unsigned int      width;
    unsigned int      height;
} resolution;

static inline u32 reg_read(struct pciep_driver_data *this, u32 reg)
{
	return ioread32(this->regs + reg);
}

static inline void reg_write(struct pciep_driver_data *this, u32 reg,
				u32 value)
{
	iowrite32(value, this->regs + reg);
}


static int pcie_reset_all(struct pciep_driver_data *this)
{
	if (this) {
		/* NOTE: PCIEP_READ_TRANSFER_DONE and PCIEP_WRITE_TRANSFER_DONE are
		 * intentionally NOT cleared here.  The EP application writes 0xef
		 * to these registers as an end-of-stream signal just before exiting.
		 * Clearing them in release() would erase that signal before the host
		 * has a chance to read it, leaving the host's READY=1 poll spinning
		 * indefinitely.  The registers are cleared in pciep_driver_file_open()
		 * (start of the next session) to guarantee a clean state for new runs. */
		reg_write(this, PCIEP_READ_BUFFER_OFFSET, PCIEP_CLR_REG);
		reg_write(this, PCIEP_READ_BUFFER_SIZE, PCIEP_CLR_REG);
		reg_write(this, PCIEP_WRITE_BUFFER_SIZE, PCIEP_CLR_REG);
		reg_write(this, PCIEP_READ_BUFFER_READY, PCIEP_CLR_REG);
		reg_write(this, PCIEP_WRITE_BUFFER_READY, PCIEP_CLR_REG);
	}
	else {
		return -EINVAL;
	}

	return 0;
}

/**
 * pciep_driver_file_open() - This is the driver open function.
 * @inode:	Pointer to the inode structure of this device.
 * @file:	Pointer to the file structure.
 * Return:      Success(=0) or error status(<0).
 */
static int pciep_driver_file_open(struct inode *inode, struct file *file)
{
	struct pciep_driver_data *this;
	struct pciep_file_priv *priv;
	int status = 0;

	this = container_of(inode->i_cdev, struct pciep_driver_data, cdev);

	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
	if (!priv)
		return -ENOMEM;
	priv->driver = this;
	priv->active_index = 0;  /* default; overwritten by MAP_DMA_BUFF ioctl */
	file->private_data = priv;

	INIT_LIST_HEAD(&this->attachments);
	mutex_init(&this->lock);

	pcie_reset_all(this);

	/* Reset completion counters to zero so that stale complete() calls
	 * from the previous session's IRQ burst (visible as "N callbacks
	 * suppressed" on re-open) do not cause spurious immediate returns
	 * from wait_for_completion_interruptible_timeout() in the new session.
	 * Without this, leftover .done counts (e.g. appsrc_frames > appsink_frames
	 * at pipeline teardown) make the first N read/write calls skip the actual
	 * DMA handshake, desyncing the H2C/C2H protocol and causing
	 * "write_complete: host ack timeout" on the second run. */
	reinit_completion(&this->read_complete);
	reinit_completion(&this->write_complete);
	atomic_set(&this->read_irq_fired, 0);
	atomic_set(&this->write_irq_fired, 0);
	/* Clear the EOS transfer-done signals from the previous session.
	 * These are NOT cleared in pcie_reset_all()/release() so that the
	 * host can read the 0xef end-of-stream value written by the EP app
	 * before it exits.  Clearing here (open = start of a new session)
	 * guarantees the host sees 0 when the new pipeline begins. */
	reg_write(this, PCIEP_READ_TRANSFER_DONE,  PCIEP_CLR_REG);
	reg_write(this, PCIEP_WRITE_TRANSFER_DONE, PCIEP_CLR_REG);

	return status;
}

/**
 * pciep_driver_file_release() - This is the driver release function.
 * @inode:	Pointer to the inode structure of this device.
 * @file:	Pointer to the file structure.
 * Return:      Success(=0) or error status(<0).
 */
static int pciep_driver_file_release(struct inode *inode, struct file *file)
{
	struct pciep_file_priv *priv = file->private_data;
	struct pciep_driver_data *this = priv->driver;
	struct pcie_dmabuf_mem *dbuf_mem, *tmp;

	/* Fully disarm the hardware BEFORE releasing any DMA mappings.
	 *
	 * After a QDMA DMA timeout (read_complete / write_complete timeout)
	 * pciep_driver_file_read/write() returns while PCIEP_READ_BUFFER_READY
	 * bit-0 (SET_BUFFER_RDY) is still 1 — the read IRQ never fired to
	 * clear it.  If the process is then killed (^C / SIGKILL) the
	 * in-flight hardware state combined with dma_buf_unmap_attachment()
	 * tearing down the DMA mapping creates an AXI protocol violation:
	 * the QDMA issues another AXI transaction to the unmapped address,
	 * CPM4 asserts an SError to the ARM cores and the board hangs.
	 *
	 * pcie_reset_all() writes 0 to ALL ready/transfer registers including
	 * SET_BUFFER_RDY, guaranteeing the QDMA sees no active buffer before
	 * we touch the DMA mappings. */
	pcie_reset_all(this);
	/* Give the CPM4/QDMA one bus cycle to observe the register clear
	 * before we unmap. */
	wmb();

	/* Drain any completion counts that accumulated from IRQs that fired
	 * between the last wait_for_completion() return and now (e.g. during
	 * pipeline teardown).  reinit_completion() resets .done to 0 so the
	 * next open() starts from a guaranteed clean state. */
	reinit_completion(&this->read_complete);
	reinit_completion(&this->write_complete);
	atomic_set(&this->read_irq_fired, 0);
	atomic_set(&this->write_irq_fired, 0);

	/* Release any dma_buf imports that the process left attached.
	 * Happens when pcie_gst_app is killed (SIGKILL) while a
	 * PCIE_DMABUF_IMPORT flag=1 is still in effect: the kernel-side
	 * dma_buf_get() reference is never balanced by a flag=0 call,
	 * so the dma_buf's file refcount stays >0 and the exported dmabufs
	 * hold THIS_MODULE via dma_buf_export(owner), keeping the module
	 * refcount above zero — rmmod then fails with "Module is in use"
	 * even though fuser shows no open file descriptors. */
	mutex_lock(&this->lock);
	list_for_each_entry_safe(dbuf_mem, tmp, &this->attachments, list) {
		list_del(&dbuf_mem->list);
		dma_buf_unmap_attachment(dbuf_mem->dbuf_attach,
					 dbuf_mem->sgt, dbuf_mem->dir);
		dma_buf_detach(dbuf_mem->dbuf, dbuf_mem->dbuf_attach);
		dma_buf_put(dbuf_mem->dbuf);
		kfree(dbuf_mem);
	}
	mutex_unlock(&this->lock);

	kfree(priv);
	file->private_data = NULL;
	return 0;
}

/**
 * pciep_driver_file_mmap() - This is the driver memory map function.
 * @file:	Pointer to the file structure.
 * @vma:        Pointer to the vm area structure.
 * Return:      Success(=0) or error status(<0).
 */
static int pciep_driver_file_mmap(struct file *file, struct vm_area_struct *vma)
{
	return 0;
}


static int pciep_dma_buf_attach(struct dma_buf *dmabuf,
				  struct dma_buf_attachment *attachment)
{
	struct pciep_driver_data *this = dmabuf->priv;
	struct pciep_dma_buf_attachment *a;
	int ret;
	void *virt = NULL;
	dma_addr_t phys = 0;
	int i;

	a = kzalloc(sizeof(*a), GFP_KERNEL);
	if (!a)
		return -ENOMEM;

	/* Look up the buffer index by matching the dma_buf export name
	 * (fd_names[]) against the dmabuf's exp_name.  This is scalable
	 * for any NUM_BUFFERS value — no hardcoded "fd1"/"fd2"/... checks. */
	for (i = 0; i < NUM_BUFFERS; i++) {
		if (!strcmp(dmabuf->exp_name, fd_names[i])) {
			virt = this->read_virt_addr[i];
			phys = this->read_phys_addr[i];
			break;
		}
	}
	if (i == NUM_BUFFERS) {
		dev_err(this->dma_dev, "dma_buf_attach: unknown exp_name '%s'\n",
			dmabuf->exp_name);
		kfree(a);
		return -EINVAL;
	}

	ret = dma_get_sgtable(this->dma_dev, &a->sgt, virt,
			      phys, this->alloc_size);
	if (ret < 0) {
		dev_err(this->dma_dev, "failed to get scatterlist from DMA API\n");
		kfree(a);
		return -EINVAL;
	}

	a->dev = attachment->dev;
	INIT_LIST_HEAD(&a->node);
	attachment->priv = a;

	mutex_lock(&this->lock);
	list_add(&a->node, &this->attachments);
	mutex_unlock(&this->lock);

	return 0;
}

static void pciep_dma_buf_detatch(struct dma_buf *dmabuf,
				    struct dma_buf_attachment *attachment)
{
	struct pciep_dma_buf_attachment *a = attachment->priv;
	struct pciep_driver_data *this = dmabuf->priv;

	mutex_lock(&this->lock);
	list_del(&a->node);
	mutex_unlock(&this->lock);
	sg_free_table(&a->sgt);
	kfree(a);
}


static struct sg_table *
pciep_map_dma_buf(struct dma_buf_attachment *attachment,
		    enum dma_data_direction dir)
{
	struct pciep_dma_buf_attachment *a = attachment->priv;
	struct sg_table *table;

	table = &a->sgt;

	if (!dma_map_sg(attachment->dev, table->sgl, table->nents, dir))
		return ERR_PTR(-ENOMEM);

	return table;
}

static void pciep_unmap_dma_buf(struct dma_buf_attachment *attach,
				  struct sg_table *table,
				  enum dma_data_direction dir)
{
	dma_unmap_sg(attach->dev, table->sgl, table->nents, dir);
}

static int pciep_mmap(struct dma_buf *dmabuf,
			struct vm_area_struct *vma)
{
	struct pciep_driver_data *this = dmabuf->priv;
	void *virt = NULL;
	dma_addr_t phys = 0;
	int i;

	/* Look up buffer index by export name — same pattern as pciep_dma_buf_attach */
	for (i = 0; i < NUM_BUFFERS; i++) {
		if (!strcmp(dmabuf->exp_name, fd_names[i])) {
			virt = this->read_virt_addr[i];
			phys = this->read_phys_addr[i];
			break;
		}
	}
	if (i == NUM_BUFFERS) {
		dev_err(this->dma_dev, "mmap: unknown exp_name '%s'\n",
			dmabuf->exp_name);
		return -EINVAL;
	}

	return dma_mmap_coherent(this->dma_dev, vma, virt,
				 phys, this->alloc_size);
}

/**
 * pciep_dmabuf_import : DMA Import function to import fd's from an exporter.
 * @ pciep_driver_data : pciep platform data to map attachments.
 * @ user_args : args to send or receive data from application	
 */
static int pciep_dmabuf_import(struct pciep_driver_data *this,
	char __user *user_args)
{
	struct pcie_dmabuf_args args;
	struct pcie_dmabuf_mem *dbuf_mem;
	struct dma_buf *dbuf;
	struct dma_buf_attachment *dbuf_attach;
	enum dma_data_direction dir;
	struct sg_table *sgt;
	long ret;
	
	if (copy_from_user(&args, user_args, sizeof(args))) {
		ret = -EFAULT;
		dev_err(this->dma_dev, "failed to copy from user\n");
		goto err;
	}
	/* if flag is 1 fd is imported */
	if (args.flag == 1) {
		dbuf = dma_buf_get(args.dbuf_fd);
		if (IS_ERR(dbuf)) {
			dev_err(this->dma_dev, "failed to get dmabuf\n");
			ret = -1;
			goto err;
		}
		dbuf_attach = dma_buf_attach(dbuf, this->dma_dev);
		if (IS_ERR(dbuf_attach)) {
			dev_err(this->dma_dev, "failed to attach dmabuf\n");
			ret = PTR_ERR(dbuf_attach);
			goto err_put;
		}
		args.dir = PCIE_DMABUF_DIR_BIDIR;
		switch (args.dir) {
			case PCIE_DMABUF_DIR_BIDIR:
				dir = DMA_BIDIRECTIONAL;
				break;
			case PCIE_DMABUF_DIR_TO_DEV:
				dir = DMA_TO_DEVICE;
				break;
			case PCIE_DMABUF_DIR_FROM_DEV:
				dir = DMA_FROM_DEVICE;
				break;
			default:
				/* Not needed with check. Just here for any future change  */
				dev_err(this->dma_dev, "invalid direction\n");
				ret = -EINVAL;
				goto err_detach;
		}

		sgt = dma_buf_map_attachment(dbuf_attach, dir);
		if (IS_ERR(sgt)) {
			dev_err(this->dma_dev, "failed to get dmabuf scatterlist\n");
			ret = PTR_ERR(sgt);
			goto err_detach;
		}
		/* Accept only contiguous one */
		if (sgt->nents != 1) {
			dma_addr_t next_addr = sg_dma_address(sgt->sgl);
			struct scatterlist *s;
			unsigned int i;
			for_each_sg(sgt->sgl, s, sgt->nents, i) {
				if (!sg_dma_len(s))
					continue;
				if (sg_dma_address(s) != next_addr) {
					dev_err(this->dma_dev,
							"dmabuf not contiguous\n");
					ret = -EINVAL;
					goto err_unmap;
				}
				next_addr = sg_dma_address(s) + sg_dma_len(s);
			}
		}
		/* Use the physical page address (not the SMMU/IOMMU DMA address)
		 * so that the QDMA AXI master—which bypasses the SMMU and accesses
		 * EP DDR via NOC using physical addresses—can reach the camera
		 * framebuffer directly.  sg_dma_address() returns an IOMMU-remapped
		 * virtual address when the PCIe EP device is behind the SMMU;
		 * that address (e.g. 0x804a00000) is outside Versal's physical DDR
		 * range and causes a 10-second NOC timeout → QDMA C2H EIO. */
		{
			struct page *cam_page = sg_page(sgt->sgl);
			if (cam_page)
				this->write_phys_addr = page_to_phys(cam_page)
							+ sgt->sgl->offset;
			else
				this->write_phys_addr = sg_dma_address(sgt->sgl);
		}
		dbuf_mem = kzalloc(sizeof(*dbuf_mem), GFP_KERNEL);
		if (!dbuf_mem) {
			ret = -ENOMEM;
			goto err_unmap;
		}
		dbuf_mem->dbuf_fd = args.dbuf_fd;
		dbuf_mem->dbuf = dbuf;
		dbuf_mem->dbuf_attach = dbuf_attach;
		dbuf_mem->sgt = sgt;
		dbuf_mem->dir = dir;
		mutex_lock(&this->lock);
		list_add(&dbuf_mem->list, &this->attachments);
		mutex_unlock(&this->lock);
	}
	/* else if flag is 0 release attached dma buf that are imported */
	else if (args.flag == 0) {
		mutex_lock(&this->lock);
		/* fetch attachments from list into dbuf_mem */
		list_for_each_entry(dbuf_mem, &this->attachments, list) {
			/* if fd from list matches to the user provided fd break the loop*/
			if (dbuf_mem->dbuf_fd == args.dbuf_fd)
				break;
		}	

		if (dbuf_mem->dbuf_fd != args.dbuf_fd) {
			dev_err(this->dma_dev, "failed to find the dmabuf (%d)\n",
					args.dbuf_fd);
			mutex_unlock(&this->lock);
			ret = -EINVAL;
			goto err;
		}
		list_del(&dbuf_mem->list);
		mutex_unlock(&this->lock);
		/* unmap attachments */
		dma_buf_unmap_attachment(dbuf_mem->dbuf_attach, dbuf_mem->sgt,
		dbuf_mem->dir);
		/*detach*/
		dma_buf_detach(dbuf_mem->dbuf, dbuf_mem->dbuf_attach);
		dma_buf_put(dbuf_mem->dbuf);
		kfree(dbuf_mem);
	}
	
	return 0;
err_unmap:
    dma_buf_unmap_attachment(dbuf_attach, sgt, dir);
err_detach:
    dma_buf_detach(dbuf, dbuf_attach);
err_put:
    dma_buf_put(dbuf);
err:
    return ret;
}

static int pciep_dmabuf_free(struct pciep_driver_data *this, char __user *argp)
{

	void *virt;
	dma_addr_t phys;
	int i;

	for (i = 0; i < NUM_BUFFERS; i++) {
		virt = this->read_virt_addr[i];
		phys = this->read_phys_addr[i];
		dma_free_coherent(this->dma_dev, this->alloc_size,
				virt, phys);
	}
	this->alloc_size = 0; 
	return 0;
}

static void pciep_release(struct dma_buf *dmabuf)
{

}

static int pciep_dma_buf_vmap(struct dma_buf *dmabuf, struct iosys_map *map)
{
    struct pciep_driver_data *this = dmabuf->priv;
    int i;

    /* Look up buffer index by export name — same pattern as
     * pciep_dma_buf_attach / pciep_mmap.  Using this->active_index
     * would be a race if multiple dma-bufs are vmap'd concurrently. */
    for (i = 0; i < NUM_BUFFERS; i++) {
        if (!strcmp(dmabuf->exp_name, fd_names[i])) {
            iosys_map_set_vaddr(map, this->read_virt_addr[i]);
            return 0;
        }
    }

    dev_err(this->dma_dev, "vmap: unknown exp_name '%s'\n",
            dmabuf->exp_name);
    return -EINVAL;
}

static const struct dma_buf_ops pciep_dma_buf_ops = {
	.attach = pciep_dma_buf_attach,
	.detach = pciep_dma_buf_detatch,
	.map_dma_buf = pciep_map_dma_buf,
	.unmap_dma_buf = pciep_unmap_dma_buf,
	.mmap = pciep_mmap,
	.vmap = pciep_dma_buf_vmap,
	.release = pciep_release,
};

/**
 * pciep_dmabuf_map : To map unused that is exported from pciep 
 *		driver with bufferpool implementation.
 * @ pciep_driver_data : pciep platform data to map attachments.
 * @ user_args : args to send or receive data from application.
 */
static int pciep_dmabuf_map(struct pciep_driver_data *this, char __user *argp,
			    struct pciep_file_priv *priv)
{
	struct pciep_alloc_dma_buf bp;
	int i;
	int fd;

	for (i = 0; i < NUM_BUFFERS; i++) {
		if (!this->fd_inuse[i]) {
			fd = this->fd[i];
			this->fd_inuse[i] = 1;
			priv->active_index = i;  /* per-open-file, no shared-state race */
			break;
		}
	}
	/* if i == NUM_BUFFERS all buffers are in use — return error */
	if (i == NUM_BUFFERS)
		return -EFAULT;

	bp.size = this->alloc_size;
	bp.fd   = fd;

	if (copy_to_user(argp, &bp, sizeof(bp)))
		return -EFAULT;
	return 0;
}
/**
 * pciep_dmabuf_unmap : To unmap used that is exported from pciep 
 *              driver with bufferpool implementation.
 * @ pciep_driver_data : pciep platform data to map attachments.
 * @ user_args : args to send or receive data from application.
 */
static int pciep_dmabuf_unmap(struct pciep_driver_data *this, char __user *argp)
{
	struct pciep_alloc_dma_buf bp;
	int i;	
	
	if (copy_from_user(&bp, argp, sizeof(bp)))
		return -EFAULT;
	
	for (i = 0; i < NUM_BUFFERS; i++) {
		if (this->fd[i] == bp.fd) {
			this->fd_inuse[i] = 0;
			break;
		}
	}
	bp.size = 0;
	return 0;
}

/**
 * pciep_dmabuf_alloc : To Export dma buffer fd's to user space via buffer pool.
 * @ pciep_driver_data : pciep platform data to map attachments.
 * @ user_args : args to send or receive data from application  
 */
static int pciep_dmabuf_alloc(struct pciep_driver_data *this, char __user *argp)
{
	struct pciep_alloc_dma_buf bp;
	/* Heap-allocate exp_info to avoid kernel stack overflow on deep ioctl
	 * call paths (kernel >=6.13: struct dma_buf_export_info grew, and the
	 * ioctl chain is deeper than in 6.12, pushing a 3-element stack array
	 * past the guard page at pciep_dmabuf_alloc+0xfc). */
	struct dma_buf_export_info *exp_info;
	int i,j;
	void *virt;
	dma_addr_t phys;
	struct dma_buf *dmabuf;
	int fd;

	if (copy_from_user(&bp, argp, sizeof(bp)))
		return -EFAULT;

	exp_info = kcalloc(NUM_BUFFERS, sizeof(*exp_info), GFP_KERNEL);
	if (!exp_info)
		return -ENOMEM;

	/* allocate read buffer */
	for (i = 0; i < NUM_BUFFERS; i++) {
		virt = dma_alloc_coherent(this->dma_dev, bp.size,
				&phys, GFP_KERNEL);
		if (IS_ERR_OR_NULL(virt)) {
			dev_err(this->dma_dev, "%s dma_alloc_coherent() failed\n",
					__func__);
			goto err_alloc;
		}
		this->read_virt_addr[i] = virt;
		/* dma_alloc_coherent() allocates from the reserved-memory CMA
		 * pool (set up by of_reserved_mem_device_init in the probe).
		 * The reserved region must be in the QDMA-accessible address
		 * range (0x800000000+ on VEK385 EDF).  Print the address so
		 * it can be verified against the DTS reserved-memory node. */
		this->read_phys_addr[i] = phys;
		dev_info(this->dma_dev,
			 "[DBG] buf[%d]: virt=%p dma/phys=0x%llx size=0x%zx\n",
			 i, virt, (u64)phys, bp.size);
		exp_info[i].owner = THIS_MODULE;
		exp_info[i].exp_name = fd_names[i];
		exp_info[i].ops = &pciep_dma_buf_ops;
		exp_info[i].size = bp.size;
		exp_info[i].flags = O_RDWR;
		exp_info[i].priv = this;
		dmabuf = dma_buf_export(&exp_info[i]);
		if (IS_ERR(dmabuf)) {
			dev_err(this->dma_dev, "%s dma_buf_export() failed\n",__func__);
			goto err_export;
		}
		fd = dma_buf_fd(dmabuf, O_ACCMODE);
		if (fd < 0) {
			dev_err(this->dma_dev, "%s dma_buf_fd() failed\n",__func__);
			goto err_buf_fd;
		}
		this->fd[i] = fd;
		this->fd_inuse[i] = 0;
		this->alloc_size = bp.size;
	}
	bp.fd = 0;
	if (copy_to_user(argp, &bp, sizeof(bp))) {
		dev_err(this->dma_dev, "%s copy to user failed\n",__func__);
		goto err_buf_fd;
	}
	kfree(exp_info);
	return 0;

err_buf_fd: 
	dma_buf_put(dmabuf);
err_export:
	virt = this->read_virt_addr[i];
	phys = this->read_phys_addr[i];
	this->read_virt_addr[i] = 0;
	this->read_phys_addr[i] = 0;
	dma_free_coherent(this->dma_dev, this->alloc_size,
			virt, phys);
err_alloc:
	for (j = i-1; j >= 0; j--) {
		virt = this->read_virt_addr[j];
		phys = this->read_phys_addr[j];
		this->read_virt_addr[j] = 0;
		this->read_phys_addr[j] = 0;
		dma_free_coherent(this->dma_dev, this->alloc_size,
				virt, phys);
	}
	kfree(exp_info);
	bp.size = 0;
	return -1;
}

static long pciep_driver_file_ioctl(struct file *file, unsigned int cmd,
			unsigned long arg)
{
	struct pciep_file_priv *priv = file->private_data;
	struct pciep_driver_data *this = priv->driver;
	unsigned int value;
	u64 offset_64;
	u64 size;
	struct resolution res;
	int ret;
	char __user *argp = (char __user *)arg;

	switch (cmd) {
	case GET_FILE_LENGTH:
			value = reg_read(this, PCIRC_READ_FILE_LENGTH);
			offset_64 = reg_read(this, (PCIRC_READ_FILE_LENGTH - 4));
			size = value | offset_64 << 32;
			ret = copy_to_user((u64 *) arg, &size, sizeof(size));
			return ret;
	
	case GET_KERNEL_MODE:
			value = reg_read(this, PCIRC_KERNEL_MODE);
			ret = copy_to_user((u32 *) arg, &value, sizeof(value));
			return ret;

	case GET_FILTER_TYPE:
			value = reg_read(this, PCIRC_FILTER_TYPE);
			ret = copy_to_user((u32 *) arg, &value, sizeof(value));
			return ret;

	case GET_RESOLUTION:
			value = reg_read(this, PCIRC_RAW_RESOLUTION);
			res.width = (value>>WIDTH_SHIFT) & WIDTH_MASK;
			res.height = (value>>HEIGHT_SHIFT) & HEIGHT_MASK;
			ret = copy_to_user((struct resolution *) arg, &res, sizeof(res));
			return ret;
	
	case GET_HDMI_PID :
	    		value = reg_read(this, PCIRC_HDMI_PID_SET);
	    		ret = copy_to_user((u32 *) arg, &value, sizeof(value));
	    		return ret;

	case SET_READ_OFFSET:
			ret = copy_from_user(&offset_64, (u64 *) arg, sizeof(offset_64));
			reg_write(this, PCIEP_READ_BUFFER_OFFSET, offset_64);
			value = reg_read(this, PCIEP_READ_BUFFER_READY);
			value &= ~READ_BUF_HIGH_OFFSET;
			value |= (offset_64 >> 16) & READ_BUF_HIGH_OFFSET;
			reg_write(this, PCIEP_READ_BUFFER_READY, value);
			return ret;

	case SET_WRITE_OFFSET:
			ret = copy_from_user(&offset_64, (u64 *) arg, sizeof(offset_64));
			reg_write(this, PCIEP_WRITE_BUFFER_OFFSET, offset_64);
		    value = reg_read(this, PCIEP_WRITE_BUFFER_READY);
		    value &= ~WRITE_BUF_HIGH_OFFSET;
		    value |= (offset_64 >> 16) & WRITE_BUF_HIGH_OFFSET;
		    reg_write(this, PCIEP_WRITE_BUFFER_READY, value);
			return ret;

	case SET_READ_TRANSFER_DONE:
			reg_write(this, PCIEP_READ_TRANSFER_DONE, 0xef);
			return 0;

	case SET_WRITE_TRANSFER_DONE:
			reg_write(this, PCIEP_WRITE_TRANSFER_DONE, 0xef);
			return 0;

	case CLR_READ_TRANSFER_DONE:
			reg_write(this, PCIEP_READ_TRANSFER_DONE, 0x00);
			return 0;

	case CLR_WRITE_TRANSFER_DONE:
			reg_write(this, PCIEP_WRITE_TRANSFER_DONE, 0x00);
			return 0;

	case GET_FPS:
			value = reg_read(this, PCIRC_SET_FPS);
			ret = copy_to_user((u32 *) arg, &value, sizeof(value));
			return ret;

	case GET_FORMAT:
			value = reg_read(this, PCIRC_FORMAT_SET);
			ret = copy_to_user((u32 *) arg, &value, sizeof(value));
			return ret;

	case GET_USE_CASE:
	   		value = reg_read(this, PCIRC_UCASE_SET);
	   		ret = copy_to_user((u32 *) arg, &value, sizeof(value));
	   		return ret;

	case GET_KERNEL_NAME:
	   		value = reg_read(this, PCIEP_FILTER_KERNEL_NAME);
	   		ret = copy_to_user((u32 *) arg, &value, sizeof(value));
	   		return ret;

	case ALLOC_DMA_BUFF:
			ret = pciep_dmabuf_alloc(this, argp);
			return ret;
    
	case RELEASE_DMA_BUFF:
			ret = pciep_dmabuf_free(this, argp);
			return ret;

	case MAP_DMA_BUFF:
			ret = pciep_dmabuf_map(this, argp, priv);
			return ret;

	case UNMAP_DMA_BUFF:
	   		ret = pciep_dmabuf_unmap(this, argp);
	   		return ret;

	case PCIE_DMABUF_IMPORT:
	   		ret = pciep_dmabuf_import(this, argp);
	   		return ret;
	
	case READ_SIG:
	   		value = reg_read(this, PCIRC_READ_SIG);
			ret = copy_to_user((u32 *) arg, &value, sizeof(value));
	   		return ret;

	case NUM_DMA_BUF:
                        return NUM_BUFFERS;

 
	default:
			return -ENOTTY;
	}
}

/**
 * pciep_irq_recover - Recover from a lost interrupt.
 *
 * Two failure modes are handled:
 *
 * Mode A — IRQ fired, CPU received it, but the complete() wakeup was lost
 *   (extremely rare software race).  Detected by the atomic flag set by the
 *   IRQ handler BEFORE calling complete().
 *
 * Mode B — pcie-reg-space IP generated the interrupt (set its internal INTR
 *   register at 0xF0/0xF4) but the GIC / interrupt delivery chain to the
 *   EP CPU failed silently.  This is the OBSERVED failure mode: the host DMA
 *   completes, the IP detects the 0→1 TRANSFER_DONE transition and asserts
 *   the interrupt line, but the GIC never delivers it to the ARM core.
 *   The INTR register stays non-zero until explicitly read (acked).
 *   Unlike the TRANSFER_DONE data register (0x88/0x8c) — which the host
 *   clears on its next loop iteration — the INTR register is DRIVER-OWNED:
 *   only a read by the EP clears it.  So it reliably holds the "interrupt
 *   pending" state regardless of what the host does.
 *
 * @this:       Driver private data
 * @comp:       Completion variable to reinitialise on recovery
 * @fired:      Atomic flag set by the IRQ handler (read_irq_fired / write_irq_fired)
 * @ready_reg:  BUFFER_READY register to clear (0x00 or 0x10)
 * @intr_reg:   INTR register to poll and ack (0xF0 or 0xF4)
 *
 * Return: true if recovery was performed, false if host has not yet completed.
 */
static bool pciep_irq_recover(struct pciep_driver_data *this,
			      struct completion *comp,
			      atomic_t *fired,
			      u32 ready_reg, u32 intr_reg)
{
	u32 intr_val;
	u32 value;

	/* Mode A: IRQ handler ran but completion wakeup was lost. */
	if (atomic_read(fired)) {
		atomic_set(fired, 0);
		value = reg_read(this, ready_reg);
		value &= ~SET_BUFFER_RDY;
		reg_write(this, ready_reg, value);
		reinit_completion(comp);
		/* INTR already acked by the IRQ handler that ran. */
		return true;
	}

	/* Mode B: IP generated interrupt but GIC never delivered it.
	 * Reading the INTR register both detects the pending interrupt and
	 * acks/clears it at the IP level, deasserting the interrupt line so
	 * the GIC does not attempt a spurious late delivery. */
	intr_val = reg_read(this, intr_reg);
	if (intr_val) {
		value = reg_read(this, ready_reg);
		value &= ~SET_BUFFER_RDY;
		reg_write(this, ready_reg, value);
		reinit_completion(comp);
		return true;
	}

	return false;
}

/**
 * pciep_driver_file_read() - This is the driver read function.
 * @file:	Pointer to the file structure.
 * @buff:	Pointer to the user buffer.
 * @count:	The number of bytes to be written.
 * @ppos:	Pointer to the offset value.
 * Return:	Transferred size.
 */
static ssize_t pciep_driver_file_read(struct file *file, char __user *buff,
				      size_t count, loff_t *ppos)
{
	struct pciep_file_priv *priv = file->private_data;
	struct pciep_driver_data *this = priv->driver;
	u32 value;
	int ret = 0;
	u32 read_phys;
	int idx = priv->active_index;  /* per-open index â€” no shared-state race */

	/* check the size */
	if (count <= 0)
		return -EINVAL;
	
	read_phys = this->read_phys_addr[idx] >> 32;	
    	reg_write(this, PCIEP_READ_BUFFER_ADDR_HIGH, read_phys);
    	
	read_phys = this->read_phys_addr[idx] ;	
    	reg_write(this, PCIEP_READ_BUFFER_ADDR_LOW,read_phys );

	reg_write(this, PCIEP_READ_BUFFER_SIZE, count);
	/* Clear IRQ flag before arming the buffer so a stale set from a
	 * previous frame never causes a false recovery on this frame's wait. */
	atomic_set(&this->read_irq_fired, 0);
	value = reg_read(this, PCIEP_READ_BUFFER_READY);
    	value |= SET_BUFFER_RDY;
        reg_write(this, PCIEP_READ_BUFFER_READY, value);

	dev_dbg(this->dma_dev,
		"[DBG] READ: addr=0x%llx size=%zu READY=0x%08x\n",
		(u64)this->read_phys_addr[idx], count, value);

	/* --- 200 ms wait for host H2C completion ---
	 *
	 * The host writes TRANSFER_DONE=1 only AFTER write_from_buffer()
	 * returns success, which means the QDMA DMA is already complete when
	 * TD=1 is written.  If the 200 ms timeout fires it means the interrupt
	 * was lost somewhere in the INTC/GIC delivery chain — NOT that the DMA
	 * is still in progress.  There is therefore NO reason to wait an
	 * additional 14.8 s: the data in the EP buffer IS valid and we can
	 * recover immediately.
	 *
	 * A 15 s stall is fatal for streaming: GStreamer's appsink drops all
	 * remaining frames due to clock skew (max-lateness hit), ending the
	 * stream early even though all DMA transfers completed successfully.
	 */
	{
		long rem = wait_for_completion_interruptible_timeout(
				&this->read_complete, msecs_to_jiffies(200));
		if (rem == 0) {
			if (pciep_irq_recover(this, &this->read_complete,
					&this->read_irq_fired,
					PCIEP_READ_BUFFER_READY,
					PCIRC_READ_BUFFER_TRANSFER_DONE_INTR)) {
				dev_info_ratelimited(this->dma_dev,
					"read: IRQ lost — recovered via flag/INTR\n");
			} else {
				/* INTR register also 0 — INTC consumed the edge
				 * without setting INTR or forwarding to GIC.
				 * DMA is confirmed complete; force recovery now. */
				dev_warn_ratelimited(this->dma_dev,
					"read: IRQ lost (INTR=0) — forced 200 ms recovery\n");
				reinit_completion(&this->read_complete);
				value = reg_read(this, PCIEP_READ_BUFFER_READY);
				value &= ~SET_BUFFER_RDY;
				reg_write(this, PCIEP_READ_BUFFER_READY, value);
			}
		} else if (rem < 0) {
			pcie_reset_all(this);
			wmb();
			dev_dbg(this->dma_dev, "read_complete: interrupted by signal\n");
		}
	}

	return ret ? ret : (ssize_t)count;
}

/**
 * pciep_driver_file_write() - This is the driver write function.
 * @file:	Pointer to the file structure.
 * @buff:	Pointer to the user buffer.
 * @count:	The number of bytes to be written.
 * @ppos:	Pointer to the offset value
 * Return:	Transferred size.
 */
static ssize_t pciep_driver_file_write(struct file *file,
				       const char __user *buff,
				       size_t count, loff_t *ppos)
{
	struct pciep_file_priv *priv = file->private_data;
	struct pciep_driver_data *this = priv->driver;
	int ret = 0;
	u32 value;
	u32 write_phys;
	/* check the size */
	if (count <= 0)
		return -EINVAL;
    	
	
	write_phys = this->write_phys_addr >> 32;	
	reg_write(this, PCIEP_WRITE_BUFFER_ADDR_HIGH, write_phys);
    	write_phys = this->write_phys_addr;	
	reg_write(this, PCIEP_WRITE_BUFFER_ADDR_LOW,write_phys);
	
	reg_write(this, PCIEP_WRITE_BUFFER_SIZE, count);
	atomic_set(&this->write_irq_fired, 0);
	value = reg_read(this, PCIEP_WRITE_BUFFER_READY);
	value |= SET_BUFFER_RDY;
	reg_write(this, PCIEP_WRITE_BUFFER_READY, value);

	dev_dbg(this->dma_dev,
		"[DBG] WRITE: addr=0x%llx size=%zu READY=0x%08x\n",
		(u64)this->write_phys_addr, count, value);

	/* --- 200 ms wait for host C2H completion (same reasoning as file_read) */
	{
		long rem = wait_for_completion_interruptible_timeout(
				&this->write_complete, msecs_to_jiffies(200));
		if (rem == 0) {
			if (pciep_irq_recover(this, &this->write_complete,
					&this->write_irq_fired,
					PCIEP_WRITE_BUFFER_READY,
					PCIRC_WRITE_BUFFER_TRANSFER_DONE_INTR)) {
				dev_info_ratelimited(this->dma_dev,
					"write: IRQ lost — recovered via flag/INTR\n");
			} else {
				dev_warn_ratelimited(this->dma_dev,
					"write: IRQ lost (INTR=0) — forced 200 ms recovery\n");
				reinit_completion(&this->write_complete);
				value = reg_read(this, PCIEP_WRITE_BUFFER_READY);
				value &= ~SET_BUFFER_RDY;
				reg_write(this, PCIEP_WRITE_BUFFER_READY, value);
			}
		} else if (rem < 0) {
			pcie_reset_all(this);
			wmb();
			dev_dbg(this->dma_dev, "write_complete: interrupted by signal\n");
		}
	}
	return ret ? ret : (ssize_t)count;
}


static loff_t pciep_driver_file_lseek(struct file *file,loff_t offset, int orig)
{
	struct pciep_file_priv *priv = file->private_data;
	struct pciep_driver_data *this = priv->driver;
	u32 value;

	reg_write(this, PCIEP_READ_BUFFER_OFFSET, offset);
	value = reg_read(this, PCIEP_READ_BUFFER_READY);
	value &= ~READ_BUF_HIGH_OFFSET;
	value |= (offset >> 16) & READ_BUF_HIGH_OFFSET;
	reg_write(this, PCIEP_READ_BUFFER_READY, value);
	return offset;
}

static const struct file_operations pciep_driver_file_ops = {
	.owner   = THIS_MODULE,
	.open    = pciep_driver_file_open,
	.release = pciep_driver_file_release,
	.mmap    = pciep_driver_file_mmap,
	.read    = pciep_driver_file_read,
	.write   = pciep_driver_file_write,
	.llseek  = pciep_driver_file_lseek,
	.unlocked_ioctl = pciep_driver_file_ioctl,
};


/**
 * xilinx_pciep_read_irq_handler - Interrupt handler
 * @irq: IRQ number
 * @data: Pointer to the driver data structure
 *
 * Return: IRQ_HANDLED/IRQ_NONE
 */
static irqreturn_t xilinx_pciep_read_irq_handler(int irq, void *data)
{
	struct pciep_driver_data *driver_data = data;
	u32 value;

	value = reg_read(driver_data, PCIEP_READ_BUFFER_READY);
	/* If READY is already 0 the recovery path in file_read already handled
	 * this interrupt (cleared READY, reinit'd completion, acked INTR).
	 * Calling complete() here would give a spurious +1 to .done, making
	 * the NEXT frame's wait_for_completion return immediately and skipping
	 * the DMA handshake entirely — causing a protocol desync. */
	if (!(value & SET_BUFFER_RDY)) {
		reg_read(driver_data, PCIRC_READ_BUFFER_TRANSFER_DONE_INTR);
		return IRQ_HANDLED;
	}

	/* Record that the IRQ fired before clearing READY and signalling the
	 * completion — the recovery path checks this flag (Mode A). */
	atomic_set(&driver_data->read_irq_fired, 1);
	value &= ~SET_BUFFER_RDY;
	reg_write(driver_data, PCIEP_READ_BUFFER_READY, value);
	complete(&driver_data->read_complete);
	reg_read(driver_data, PCIRC_READ_BUFFER_TRANSFER_DONE_INTR);

	return IRQ_HANDLED;
}

/**
 * xilinx_pciep_write_irq_handler - Interrupt handler
 * @irq: IRQ number
 * @data: Pointer to the driver data structure
 *
 * Return: IRQ_HANDLED/IRQ_NONE
 */
static irqreturn_t xilinx_pciep_write_irq_handler(int irq, void *data)
{
	u32 value;
	struct pciep_driver_data *driver_data = data;

	value = reg_read(driver_data, PCIEP_WRITE_BUFFER_READY);
	if (!(value & SET_BUFFER_RDY)) {
		reg_read(driver_data, PCIRC_WRITE_BUFFER_TRANSFER_DONE_INTR);
		return IRQ_HANDLED;
	}

	atomic_set(&driver_data->write_irq_fired, 1);
	value &= ~SET_BUFFER_RDY;
	reg_write(driver_data, PCIEP_WRITE_BUFFER_READY, value);
	complete(&driver_data->write_complete);
	reg_read(driver_data, PCIRC_WRITE_BUFFER_TRANSFER_DONE_INTR);

	return IRQ_HANDLED;
}

/**
 * xilinx_pciep_host_done_irq_handler - Host-done interrupt handler
 * @irq: IRQ number
 * @data: Pointer to the driver data structure
 *
 * Fired when the host writes PCIRC_HOST_DONE=0x1 (end of streaming session).
 * Clears both transfer-done registers so the EP app's polling loops detect
 * the end-of-stream condition.
 *
 * Return: IRQ_HANDLED
 */
static irqreturn_t xilinx_pciep_host_done_irq_handler(int irq, void *data)
{
	struct pciep_driver_data *driver_data = data;

	reg_read(driver_data, PCIRC_HOST_DONE_INTR);
	reg_write(driver_data, PCIEP_READ_TRANSFER_DONE, PCIEP_CLR_REG);
	reg_write(driver_data, PCIEP_WRITE_TRANSFER_DONE, PCIEP_CLR_REG);

	return IRQ_HANDLED;
}
/**
 * pciep_driver_create() -  Create pciep driver data structure.
 * @name:       device name   or NULL.
 * @parent:     parent device or NULL.
 * @minor:	minor_number.
 * @size:	buffer size.
 * @channel:    DMA channel name
 * Return:      Pointer to the pciep driver data structure or NULL.
 *
 * It does all the memory allocation and registration for the device.
 */
static struct pciep_driver_data *pciep_driver_create(const char *name,
						     struct device *parent,
						     u32 minor, u32 size,
						     char *channel)
{
	struct pciep_driver_data *this = NULL;
	const unsigned int DONE_ALLOC_MINOR   = (1 << 0);
	const unsigned int DONE_CHRDEV_ADD    = (1 << 1);
	const unsigned int DONE_ALLOC_CMA     = (1 << 2);
	const unsigned int DONE_DEVICE_CREATE = (1 << 3);
	unsigned int done = 0;

	/* allocate device minor number */
	if (minor < DEVICE_MAX_NUM) {
		if (ida_alloc_range(&pciep_device_ida, minor, minor,
				    GFP_KERNEL) < 0) {
			dev_err(parent, "couldn't allocate minor number(=%d)\n",
				minor);
			goto failed;
		}
	} else {
		dev_err(parent, "invalid minor num(=%d),valid range: 0 to %d\n",
			minor, DEVICE_MAX_NUM-1);
		goto failed;
	}
	done |= DONE_ALLOC_MINOR;
	/* create (pciep_driver_data*) this. */
	this = kzalloc(sizeof(*this), GFP_KERNEL);
	if (IS_ERR_OR_NULL(this))
		goto failed;
	/* make this->device_number */
	this->device_number = MKDEV(MAJOR(pciep_device_number), minor);
	/* register /sys/class/ */
	this->sys_dev = device_create(pciep_sys_class,
			parent,
			this->device_number,
			(void *)this,
			DEVICE_NAME_FORMAT, MINOR(this->device_number));

	if (IS_ERR_OR_NULL(this->sys_dev)) {
		this->sys_dev = NULL;
		goto failed;
	}
	done |= DONE_DEVICE_CREATE;

	/* setup dma_dev */
	this->dma_dev = parent;

	/* Do NOT call of_dma_configure() here.  Calling it before
	 * of_reserved_mem_device_init() (which runs later in the probe)
	 * causes kernel 6.13+ to install DMA ops that override the reserved-
	 * memory CMA allocator, so dma_alloc_coherent() falls back to general
	 * low-DDR system RAM (<1 GB).  The CPM4 QDMA AXI master in the VEK385
	 * EDF NoC design is only connected to the high-DDR bank (0x800000000+),
	 * so any buffer below that range triggers a 10-second NOC timeout.
	 * DMA mask and reserved-memory pool are configured in the probe
	 * function after of_reserved_mem_device_init() succeeds. */

	done |= DONE_ALLOC_CMA;

	/* add chrdev */
	cdev_init(&this->cdev, &pciep_driver_file_ops);
	this->cdev.owner = THIS_MODULE;
	if (cdev_add(&this->cdev, this->device_number, MAX_INSTANCES) != 0) {
		dev_err(parent, "cdev_add() failed\n");
		goto failed;
	}
	done |= DONE_CHRDEV_ADD;

	dev_info(this->sys_dev, "major number   = %d\n",
		 MAJOR(this->device_number));
	dev_info(this->sys_dev, "minor number   = %d\n",
		MINOR(this->device_number));
	init_completion(&this->read_complete);
	init_completion(&this->write_complete);
	atomic_set(&this->read_irq_fired, 0);
	atomic_set(&this->write_irq_fired, 0);

	pr_err("pcie end point driver initialization success\n");
	return this;
failed:
	if (done & DONE_CHRDEV_ADD)
		cdev_del(&this->cdev);
	if (done & DONE_DEVICE_CREATE)
		device_destroy(pciep_sys_class, this->device_number);
	if (done & DONE_ALLOC_MINOR)
		ida_free(&pciep_device_ida, minor);
	if (this != NULL)
		kfree(this);
	return NULL;
}

/**
 * pciep_platform_driver_probe() -  Probe call for the device.
 * @pdev:	handle to the platform device structure.
 * Return:      Success(=0) or error status(<0).
 *
 * It does all the memory allocation and registration for the device.
 */
static int pciep_platform_driver_probe(struct platform_device *pdev)
{
	u32 minor_number = 0;
	struct pciep_driver_data *driver_data;
	struct device_node *node = pdev->dev.of_node;
	struct resource *res;
	int ret;
	u32 size=4096;
	char channel[5];

	/* create (pciep_driver_data*)this. */
	driver_data = pciep_driver_create(DRIVER_NAME, &pdev->dev, minor_number,
					  size, channel);
	if (IS_ERR_OR_NULL(driver_data)) {
		dev_err(&pdev->dev, "driver create fail.\n");
		ret = IS_ERR(driver_data) ? PTR_ERR(driver_data) : -ENOMEM;
		goto failed;
	}

	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	driver_data->regs= devm_ioremap_resource(&pdev->dev, res);
	if (IS_ERR_OR_NULL(driver_data->regs)){
		ret = PTR_ERR(driver_data->regs);
		goto failed;
	}
	driver_data->rd_irq = irq_of_parse_and_map(node, 0);
	dev_info(&pdev->dev,
		 "[DBG] rd_irq Linux#=%d (DTS SPI 143 → expect ~175)\n",
		 driver_data->rd_irq);
	if (driver_data->rd_irq <= 0) {
		pr_err("Unable to get IRQ for pcie (rd_irq=%d)\n",
		       driver_data->rd_irq);
		ret = -EINVAL;
		goto failed;
	}

	ret = devm_request_irq(&pdev->dev, driver_data->rd_irq,
			       xilinx_pciep_read_irq_handler, IRQF_SHARED,
			       "xilinx_pciep_read", driver_data);
	if (ret < 0) {
	    dev_info(&pdev->dev, "MM: pcie ret: %d\n", ret);
		dev_err(&pdev->dev, "Unable to register IRQ\n");
		goto failed;
	}

	driver_data->wr_irq = irq_of_parse_and_map(node, 1);
	dev_info(&pdev->dev,
		 "[DBG] wr_irq Linux#=%d (DTS SPI 144 → expect ~176)\n",
		 driver_data->wr_irq);
	if (driver_data->wr_irq <= 0) {
		pr_err("Unable to get IRQ1 for pcie (wr_irq=%d)\n",
		       driver_data->wr_irq);
		ret = -EINVAL;
		goto free_rd_irq;
	}

	ret = devm_request_irq(&pdev->dev, driver_data->wr_irq,
			       xilinx_pciep_write_irq_handler, IRQF_SHARED,
			       "xilinx_pciep_write", driver_data);
	if (ret < 0) {
	    dev_info(&pdev->dev, "MM: pcie ret: %d\n", ret);
		dev_err(&pdev->dev, "Unable to register IRQ\n");
		goto free_rd_irq;
	}

	driver_data->host_done_irq = irq_of_parse_and_map(node, 2);
	dev_info(&pdev->dev,
		 "[DBG] host_done_irq Linux#=%d (DTS SPI 145 → expect ~177)\n",
		 driver_data->host_done_irq);
	if (driver_data->host_done_irq <= 0) {
		pr_err("Unable to get host_done IRQ (host_done_irq=%d)\n",
		       driver_data->host_done_irq);
		ret = -EINVAL;
		goto free_wr_irq;
	}

	ret = devm_request_irq(&pdev->dev, driver_data->host_done_irq,
			       xilinx_pciep_host_done_irq_handler, IRQF_SHARED,
			       "xilinx_host_done", driver_data);
	if (ret < 0) {
		dev_err(&pdev->dev, "Unable to register IRQ\n");
		goto free_wr_irq;
	}
	/* Initialize reserved memory resources */
	ret = of_reserved_mem_device_init(&pdev->dev);
	dev_info(&pdev->dev,
		 "[DBG] of_reserved_mem_device_init ret=%d (0=ok, -ENODEV=no binding)\n",
		 ret);
	if (ret) {
		dev_err(&pdev->dev, "Could not get reserved memory\n");
		goto free_host_done_irq;
	}

	/* Configure DMA mask AFTER of_reserved_mem_device_init so the reserved-
	 * memory CMA allocator is already in place and dma_alloc_coherent()
	 * allocates from the QDMA-accessible high-DDR region. */
	dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64));

	dev_set_drvdata(&pdev->dev, driver_data);
	dev_info(&pdev->dev, "pcie driver probe success.\n");
	return 0;

free_host_done_irq :
	if(driver_data->host_done_irq) {
		devm_free_irq(&pdev->dev, driver_data->host_done_irq, driver_data);
		driver_data->host_done_irq = 0;
	}
free_wr_irq :
	if(driver_data->wr_irq){
		devm_free_irq(&pdev->dev, driver_data->wr_irq, driver_data);
		driver_data->wr_irq = 0;
	}
free_rd_irq :
	if(driver_data->rd_irq){
		devm_free_irq(&pdev->dev, driver_data->rd_irq, driver_data);
		driver_data->rd_irq = 0;
	}
failed:
	dev_info(&pdev->dev, "driver install failed.\n");
	return ret;
}

/**
 * pciep_driver_destroy() -  Remove the pciep driver data structure.
 * @this:       Pointer to the pciep driver data structure.
 * Return:      Success(=0) or error status(<0).
 *
 * Unregister the device after releasing the resources.
 */
static int pciep_driver_destroy(struct pciep_driver_data *this)
{
	if (!this)
		return -ENODEV;

	ida_free(&pciep_device_ida, MINOR(this->device_number));
	cdev_del(&this->cdev);
	device_destroy(pciep_sys_class, this->device_number);
	kfree(this);
	return 0;
}

/**
 * pciep_platform_driver_remove() -  Remove call for the device.
 * @pdev:	Handle to the platform device structure.
 * Return:      Success(=0) or error status(<0).
 *
 * Unregister the device after releasing the resources.
 */
static void pciep_platform_driver_remove(struct platform_device *pdev)
{
	struct pciep_driver_data *this = dev_get_drvdata(&pdev->dev);
	int retval = 0;
	
	if(this->host_done_irq) {
		devm_free_irq(&pdev->dev, this->host_done_irq, this);
		this->host_done_irq = 0;
	}
	if(this->wr_irq){
		devm_free_irq(&pdev->dev, this->wr_irq, this);
		this->wr_irq = 0;
	}
	if(this->rd_irq){
		devm_free_irq(&pdev->dev, this->rd_irq, this);
		this->rd_irq = 0;
	}
	retval = pciep_driver_destroy(this);
	if (retval != 0)
		dev_warn(&pdev->dev, "pciep_driver_destroy returned %d\n", retval);
	dev_set_drvdata(&pdev->dev, NULL);
}

/**
 * Open Firmware Device Identifier Matching Table
 */
static const struct of_device_id pciep_of_match[] = {
	{ .compatible = "xlnx,pcie-reg-space-v1-0-1.0", },
	{ .compatible = "xlnx,pcie-reg-space-1.2", },
	{ /* end of table */}
};
MODULE_DEVICE_TABLE(of, pciep_of_match);

/**
 * Platform Driver Structure
 */
static struct platform_driver pciep_platform_driver = {
	.probe  = pciep_platform_driver_probe,
	.remove = pciep_platform_driver_remove,
	.driver = {
		.owner = THIS_MODULE,
		.name  = DRIVER_NAME,
		.of_match_table = pciep_of_match,
	},
};


/**
 * pciep_module_cleanup() - common teardown shared by init error path and exit.
 * Not marked __init or __exit so it lives in .text and can be referenced
 * from both .init.text (pciep_module_init failure) and .exit.text
 * (pciep_module_exit) without a modpost section-mismatch error.
 */
static void pciep_module_cleanup(void)
{
	if (pciep_platform_driver_done)
		platform_driver_unregister(&pciep_platform_driver);
	if (pciep_device_number != 0)
		unregister_chrdev_region(pciep_device_number, 0);
	if (pciep_sys_class)
		class_destroy(pciep_sys_class);
	ida_destroy(&pciep_device_ida);
}

/**
 * pciep_module_exit()
 */
static void __exit pciep_module_exit(void)
{
	pciep_module_cleanup();
}

/**
* pciep_devnode() - To provide permissions to non-root user
*/
static char *pciep_devnode(const struct device *dev, umode_t *mode)
{
       if (mode)
          *mode = 0666; /* or whatever permissions you want */
       return NULL; 
}

/**
 * pciep_module_init()
 */
static int __init pciep_module_init(void)
{
	int retval = 0;

	ida_init(&pciep_device_ida);
	retval = alloc_chrdev_region(&pciep_device_number, 0, MAX_INSTANCES,
				     DRIVER_NAME);
	if (retval != 0) {
		pr_err("%s: couldn't allocate device major number\n",
		       DRIVER_NAME);
		pciep_device_number = 0;
		goto failed;
	}
	pciep_sys_class = class_create(DRIVER_NAME);
	if (IS_ERR_OR_NULL(pciep_sys_class)) {
		pr_err("%s: couldn't create sys class\n", DRIVER_NAME);
		retval = PTR_ERR(pciep_sys_class);
		pciep_sys_class = NULL;
		goto failed;
	}
	pciep_sys_class->devnode = pciep_devnode;
	retval = platform_driver_register(&pciep_platform_driver);
	if (retval)
		pr_err("%s: couldn't register platform driver\n", DRIVER_NAME);
	else
		pciep_platform_driver_done = 1;
	return 0;
failed:
	pciep_module_cleanup();
	return retval;
}

module_init(pciep_module_init);
module_exit(pciep_module_exit);

MODULE_AUTHOR("Xilinx, Inc.");
MODULE_DESCRIPTION("PCIe usersapce register device driver");
MODULE_LICENSE("GPL v2");
/* kernel >= 5.16: dma_buf_* symbols live in the DMA_BUF namespace.
 * kernel >= 6.13: MODULE_IMPORT_NS() takes a string literal. */
MODULE_IMPORT_NS("DMA_BUF");

/*********************************************************************
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
 ********************************************************************/

#ifndef _PCIE_ABSTRACT_H_
#define _PCIE_ABSTRACT_H_

#include <assert.h>
#include <fcntl.h>
#include <getopt.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <time.h>

#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <linux/dma-buf.h>
#include <glib.h>
#include <gst/gst.h>

#define DEVICE_NAME             "/dev/pciep0"

/*
 * ============================================================================
 * EP DMA BUFFER POOL DEPTH
 * ============================================================================
 * Number of endpoint dma-bufs cycled by pciesrc / pciesink.
 *
 * THIS VALUE MUST STAY EQUAL TO NUM_BUFFERS IN
 *   driver_src/xilinx_pci_endpoint.c
 * The driver allocates NUM_BUFFERS DMA-coherent buffers at probe time and
 * exports them; this app maps them one at a time via MAP_DMA_BUFF.  If this
 * value exceeds NUM_BUFFERS the map ioctl fails; if it is smaller the extra
 * driver buffers are never used.
 *
 * Why 6 -- 4 minimum in-flight + 2 headroom:
 *   1. H2C DMA in progress          (host writing into the buffer)
 *   2. queued in perf/appsink       (handed downstream by pciesrc)
 *   3. held by appsink until its PTS (appsink sync=TRUE for UC2+)
 *   4. C2H DMA in progress          (host reading out of the buffer)
 *   5-6. headroom for GStreamer scheduling jitter, slow appsink,
 *        or pipeline element queuing that temporarily holds an extra
 *        buffer -- prevents the critical H2C/C2H collision.
 *
 * Do NOT reduce this below 4.  With a shallower pool pciesrc re-arms a buffer
 * for H2C while pciesink is still C2H-ing it.  The host QDMA then reads and
 * writes the same 24.8 MB EP DDR region concurrently over the NoC, the
 * transaction never retires, and the host hits its 10 s DMA timeout
 * ("W off 0x... failed -1", EIO), followed by read_complete / write_complete
 * timeouts on the endpoint.
 *
 * This value also sets the recycle lag in pcie_src.c: a buffer is unmapped
 * MAX_BUFFER_POOL_SIZE frames after it was mapped, so raising it increases
 * both the pool depth and the safety margin.
 *
 * NOTE: unrelated to the host application's staging ring depths
 * (HOST_DISPLAY_RING_DEPTH / HOST_FILE_RING_DEPTH in pcie_host.h) -- those
 * are host-DDR queues, not EP DMA buffers.
 * ============================================================================
 */
#define MAX_BUFFER_POOL_SIZE    6

typedef struct resolution {
    guint width;
    guint height;
} resolution;

typedef struct dma_buf_export {
    gint fd;
    guint flags;
    size_t size;
} dma_buf_export;

typedef struct dma_buf_imp {
    gint32 dbuf_fd;
    gint32 dma_imp_flag;
    guint64 dma_addr;
    guint64 size;
    gint8  dir;
} dma_buf_imp;

/**
 * @brief opens pcie end point device node
 *
 * @return pcie end-point device fd
 */
gint pcie_open();

/**
 * @brief get file length of file to be transferred.
 *
 * @param[in] fpga_fd pcie ep device node file descriptor.
 * @param[out] file_length length of file
 *
 * @return  0 on success
 */
gulong pcie_get_file_length(gint fpga_fd, gulong *file_length);

/**
 * @brief Trigger dma read (use after dma map)
 *
 * @param[in] fpga_fd pcie ep device node file descriptor.
 * @param[in] size size of data to be transferred.
 * @param[in] offset offset of the buffer.
 * @param[in] buff address of the buffer to be transferred.
 *
 * @return 0 on success
 */
gint pcie_read(gint fpga_fd, gint size, gulong offset, gchar* buff);

/**
 * @brief Trigger dma write (use after dma import)
 *
 * @param[in] fpga_fd pcie ep device node file descriptor.
 * @param[in] size size of data to be read.
 * @param[in] offset offset of the buffer.
 * @param[out] buff address of the buffer to be read.
 *
 * @return 0 on success
 */
gint pcie_write(gint fpga_fd, gint size, gint offset, gchar *buff);

/**
 * @brief set read transfer done register
 *
 * @param[in] fpga_fd pcie ep device node file descriptor.
 *
 * @return 0 on success
 */
gint pcie_set_read_transfer_done(gint fpga_fd);

/**
 * @brief set write transfer done register
 *
 * @param[in] fpga_fd pcie ep device node file descriptor.
 *
 * @return 0 on success
 */
gint pcie_set_write_transfer_done(gint fpga_fd);

/**
 * @brief clear read transfer done register
 *
 * @param[in] fpga_fd pcie ep device node file descriptor.
 *
 * @return 0 on success
 */
gint pcie_clr_read_transfer_done(gint fpga_fd);

/**
 * @brief clear write transfer done register
 *
 * @param[in] fpga_fd pcie ep device node file descriptor.
 *
 * @return 0 on success
 */
gint pcie_clr_write_transfer_done(gint fpga_fd);

/**
 * @brief  Get input resolution of file.
 *
 * @param[in] fpga_fd pcie ep device node file descriptor.
 * @param[out] input_res input resolution from host
 *
 * @return 0 on success
 */
gint pcie_get_input_resolution(gint fpga_fd, struct resolution* input_res);

/**
 * @brief Get kernel mode
 *
 * @param[in] fpga_fd pcie ep device node file descriptor.
 * @param[out] kernel_mode kernel mode from host
 *
 * @return 0 on success
 */
gint pcie_get_kernel_mode(gint fpga_fd, guint *kernel_mode);

/**
 * @brief Get filter type
 *
 * @param[in] fpga_fd pcie ep device node file descriptor.
 * @param[out] filter type from host
 *
 * @return 0 on success
 */
gint pcie_get_filter_type(gint fpga_fd, guint *filter_type);

/**
 * @brief Get frame rate of frames to be transferred
 *
 * @param[in] fpga_fd pcie ep device node file descriptor.
 * @param[out] fps output fps
 *
 * @return 0 on success
 */
gint pcie_get_fps(gint fpga_fd, guint *fps);

/**
 * @brief Read mipi feed stopped signal
 *
 * @param[in] fpga_fd pcie ep device node file descriptor.
 * @param[out] mipi_feed set when host-app stopped mipi use-case
 *
 * @return 0 on success
 */
gint pcie_read_stop_mipi_feed(gint fpga_fd, guint *mipi_feed);

/**
 * @brief Initialize bufferpool
 *
 * Driver will allocate memory and store FDs internally. It won't export any FD
 * to user. User need to use pcie_dma_map/unmap calls in order to get available
 * FD from driver.
 *
 * @param[in] fpga_fd pcie ep device node file descriptor.
 * @param[in] dma_export dma buffer export object
 *
 * @return 0 on success
 */
gint pcie_dma_export(gint fpga_fd, struct dma_buf_export* dma_export);

/**
 * @brief Release allocated bufferpool memory
 *
 * @param[in] fpga_fd pcie ep device node file descriptor.
 * @param[in] dma_export dma buffer export object
 *
 * @return 0 on success
 */
gint pcie_dma_export_release(gint fpga_fd, struct dma_buf_export* dma_export);

/**
 * @brief Export the available FD from bufferpool. It should be unmap using
 * pcie_dma_unmap() after usage.
 *
 * @param[in] fpga_fd pcie ep device node file descriptor.
 * @param[out] dma_map object to store mapped fd
 *
 * @return 0 on success
 */
gint pcie_dma_map(gint fpga_fd, struct dma_buf_export *dma_map);

/**
 * @brief Unmap the already mapped FD
 *
 * @param[in] fpga_fd pcie ep device node file descriptor.
 * @param[in] dma_map mapped fd
 *
 * @return 0 on success
 */
gint pcie_dma_unmap(gint fpga_fd, struct dma_buf_export *dma_map);

/**
 * @brief Import the dma buf file descriptor
 *
 * @param[in] fpga_fd pcie ep device node file descriptor.
 * @param[in] dma_import dma import object
 *
 * @return 0 on success
 */
gint pcie_dma_import(gint fpga_fd, struct dma_buf_imp* dma_import);

/**
 * @brief release Import the dma buf file descriptor
 *
 * @param[in] fpga_fd pcie ep device node file descriptor.
 * @param[in] dma_import dma import object
 *
 * @return 0 on success
 */
gint pcie_dma_import_release(gint fpga_fd, struct dma_buf_imp* dma_import);

/**
 * @brief To specify number of dma buf to be allocated
 *
 * @param[in] fpga_fd pcie ep device node file descriptor.
 * @param[in] number of dma buffers to be allocated (value 1-3)
 *
 * @return 0 on success
 */
gint pcie_num_dma_buf(gint fpga_fd);

/**
 * @brief get the supported usecase type
 *
 * @param[in] fpga_fd pcie ep device node file descriptor.
 * @param[out] usecase usecase type
 *
 * @return 0 on success
 */
gint pcie_get_usecase_type(gint fpga_fd, guint *usecase);

/**
 * @brief Get video format (NV12, YUY2, BGR) set by the host application.
 *
 * Reads the PCIRC_FORMAT_SET register via the GET_FORMAT ioctl.
 * Returns VGST_FORMAT_YUY2 (1), VGST_FORMAT_BGR (2), or VGST_FORMAT_NV12 (3).
 *
 * @param[in]  fpga_fd pcie ep device node file descriptor.
 * @param[out] format  format value written by host (VGST_FORMAT_*)
 *
 * @return 0 on success, negative on error
 */
gint pcie_get_format(gint fpga_fd, guint *format);

/**
 * @brief closes pcie end point device node.
 *
 * @param[in] fpga_fd pcie ep device node file descriptor.
 */
void pcie_close(gint fpga_fd);

#endif //_PCIE_ABSTRACT_H_


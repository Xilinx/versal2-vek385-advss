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

#ifndef _PCIE_MAIN_H_
#define _PCIE_MAIN_H_

#include <stdio.h>
#include <gst/app/gstappsrc.h>
#include <gst/gst.h>
#include <string.h>
#include <gst/app/gstappsink.h>
#include <gst/allocators/gstdmabuf.h>
#include <pcie_abstract.h>
#include <gst/video/video.h>
#include <glib.h>

#define INPUT_SRC                       "/dev/video0"
#define VGST_V4L2_IO_MODE_DMABUF_EXPORT 4
#define MAX_FRAME_RATE_DENOM            1
#define YUY2_MULTIPLIER                 2.0    /* YUY2 = 16 bpp packed = 2 bytes/pixel */
#define NV12_MULTIPLIER                 1.5    /* NV12 = 12 bpp semi-planar = 1.5 bytes/pixel */
#define RGB888_MULTIPLIER               3.0    /* RGB888 = 24 bpp packed = 3 bytes/pixel */
#define VIDEOPARSE_FORMAT_NV12          "NV12"
#define VIDEOPARSE_FORMAT_YUY2          "YUY2"
#define VIDEOPARSE_FORMAT_RGB           "RGB"  /* RGB888 packed, R byte first */
#define PCIE_GST_APP_FAIL               -1
#define HOST_APP_REG_READ_TIMEOUT_US    50000  /* 50 ms — faster quit response */

typedef struct {
    guint64 length;
    guint input_format, fps;
    guint usecase;
    resolution input_res;
} host_params;

typedef struct {
    gint fd;
    guint sourceid, dma_map_idx;
    GMainLoop *loop;
    gboolean eos_flag, exit_thread;
    host_params h_param;
    dma_buf_imp dma_import;
    dma_buf_export dma_export, dma_map[MAX_BUFFER_POOL_SIZE];
    GstElement *inputsrc, *perf;
    GstElement *pipeline, *pciesrc, *capsfilter, *pciesink;
    guint64 appsrc_framecnt, appsink_framecnt;
    guint64 read_offset, yuv_frame_size, export_fd_size;
    GstAllocator *dmabuf_allocator; /* cached per-App; created once, reused every frame */
} App;

typedef enum {
    VGST_FORMAT_YUY2  = 1,  /* YUY2  packed 4:2:2, 16 bpp */
    VGST_FORMAT_NV12  = 2,  /* NV12  semi-planar 4:2:0, 12 bpp */
    VGST_FORMAT_RGB   = 3,  /* RGB888 packed, 24 bpp (R byte first) */
    VGST_FORMAT_MAX,
} VGST_FORMAT_TYPE;

/*
 * Only two use cases are currently supported:
 *   UC1 (user menu "1") = MIPI live → bypass → host display
 *   UC2 (user menu "2") = File from host → bypass → host display
 *
 * Enum values 1 and 2 are written to the BAR2 PCIRC_UCASE_SET register
 * by the host and read back here via GET_USE_CASE ioctl.
 */
typedef enum {
    VGST_USECASE_TYPE_NONE                  = 0,
    VGST_USECASE_TYPE_MIPISRC_TO_HOST_BYPASS = 1,  /* UC1 */
    VGST_USECASE_TYPE_APPSRC_TO_HOST_BYPASS  = 2,  /* UC2 */
    VGST_USECASE_TYPE_MAX,                          /* = 3 */
} VGST_USECASE_TYPE;

#endif /* _PCIE_MAIN_H_ */



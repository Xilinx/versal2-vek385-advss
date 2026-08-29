/*
 * Copyright (C) 2020 Xilinx, Inc.  All rights reserved.
 *
 * Copyright(C) 2022-2026 Advanced Micro Devices, Inc. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * XILINX BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * Except as contained in this notice, the name of the Xilinx shall not be used
 * in advertising or otherwise to promote the sale, use or other dealings in
 * this Software without prior written authorization from Xilinx.
 */

#ifndef PCIE_HOST_APP_CIRC_H
#define PCIE_HOST_APP_CIRC_H
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <signal.h>
#include <stdbool.h>

/*
 * ============================================================================
 * HOST-SIDE STAGING RING DEPTHS
 * ============================================================================
 * These are plain malloc'd frame queues in HOST DDR.  They are NOT the
 * endpoint DMA buffers and are deliberately NOT the same number as those.
 *
 *   EP DMA buffers  : NUM_BUFFERS            (xilinx_pci_endpoint.c)
 *                   = MAX_BUFFER_POOL_SIZE   (pcie_abstract.h)
 *                   = 6 (4 minimum in-flight + 2 headroom), capped by the
 *                     reserved-memory region and by how many frames the
 *                     GStreamer pipeline holds at once.
 *
 *   Host rings      : the two constants below, capped only by host RAM.
 *
 * queue_frame (C2H -> display), depth 8
 *   Absorbs jitter between the C2H DMA thread (which delivers a frame every
 *   ~33 ms but in bursts) and the Qt convert/display worker (which is paced
 *   by the 16 ms UI timer and can stall on compositor vsync).  A shallower
 *   ring shows up as "[convertWorker] WARNING: frame overwritten before
 *   display".
 *
 * queue_file_frame (file read -> H2C), depth 4
 *   Read-ahead for the file reader thread feeding the H2C DMA.  Deeper is
 *   pointless: reads from /dev/shm complete in ~2.5 ms, so 4 frames is
 *   already ~130 ms of read-ahead.  A shallower ring shows up as
 *   "[cb_enque] WARN: buffer full ... frame dropped".
 *
 * Memory cost at 4K RGB888 (24 883 200 B/frame):
 *   8 x 24.8 MB = 199 MB  +  4 x 24.8 MB = 99.5 MB  ~= 300 MB of host RAM.
 * ============================================================================
 */
#define HOST_DISPLAY_RING_DEPTH   8   /* queue_frame      : C2H -> display   */
#define HOST_FILE_RING_DEPTH      4   /* queue_file_frame : file -> H2C      */

typedef struct circular_buffer
{
char *buffer;
char *buffer_end;
size_t capacity;
size_t index;
size_t sz;
char *head;
char *tail;
pthread_mutex_t lock;     /* protects index, head, tail */
size_t drop_count;        /* frames silently dropped when full */
} circular_buffer;

extern "C"{
extern circular_buffer queue_frame;
extern bool app_running;
/**
 * mipi_displayonhost 	: Function to provide control from host to Endpoint and initialize a mipi capture pipeline from endpoint (i.e., appsrc)    *			    and process frames into filter plugin then to displayonhost through appsink.
 * frm 			: A Qtwindow frame to display on host.
 * c2h_device		: qdma channel to host device node for dma read transaction.
 */
int mipi_displayonhost(struct MainWindow *frm,const char *c2h_device );

/**
 * host2host_without_filter   : Function to provide control from host to Endpoint and transfer a video file from host to EP via pcie.(i.e.,appsrc)
 *               		and process frames into filter plugin then to displayonhost through appsink.
 * frm         		      : A Qtwindow frame to display on host.
 * h2c_device  		      : qdma host to channel device node for dma write transaction
 * c2h_device  : qdma channel to host device node for dma read transaction.
 */

int host2host_without_filter(struct MainWindow *frm,const char *h2c_device,const char *c2h_device);

/**
 * pcie_dma_read :  Thread function to start dma write transaction from host to channel.
 * @vargp : takes nothing as argument.
 */
void *pcie_dma_read(void *);
/**
 * pcie_dma_write : Thread function to start dma read transaction from channel to host.
 * @vargp : takes nothing as argument.
 */
void *pcie_dma_write(void *);
/**
 * file_read : Read input file and strat dma transaction between channel and host.
 */
void *file_read(void * vargp);
int cb_deque(circular_buffer *cb, char *data);
int cmaincall(struct MainWindow *frm);


}
#endif // PCIE_HOST_APP_H

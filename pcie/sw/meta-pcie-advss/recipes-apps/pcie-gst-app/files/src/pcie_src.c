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

#include <pcie_src.h>

GST_DEBUG_CATEGORY_EXTERN (pcie_gst_app_debug);
#define GST_CAT_DEFAULT pcie_gst_app_debug

gboolean feed_data (gpointer user_data)
{
    GstBuffer*    buffer     = NULL;
    GstMemory*    memory     = NULL;
    GstAllocator* allocator  = NULL;
    gint          ret        = 0;
    gint          unmap_idx  = 0;

    App *app = (App *)user_data;
    if(app == NULL) {

        GST_DEBUG ("feed_data() NULL app pointer data 34\n");
        return FALSE;
    };

    /* Check for end-of-stream BEFORE incrementing the frame counter so
     * appsrc_framecnt reflects only frames actually pushed, and return
     * G_SOURCE_REMOVE to stop the g_idle_add handler from spinning. */
    if (app->read_offset >= app->h_param.length) {
        if(!app->eos_flag) {
          g_signal_emit_by_name (app->pciesrc, "end-of-stream", &ret);
          app->eos_flag = TRUE;
          GST_DEBUG ("Appsrc: Emitting EOS at frame %lu", app->appsrc_framecnt);
        }
        app->sourceid = 0;
        return G_SOURCE_REMOVE;
    }

    app->appsrc_framecnt++;

    /* Create the DMA-buf allocator once and cache it for the lifetime of the
     * pipeline.  gst_dmabuf_allocator_new() is a GLib object allocation — calling
     * it every frame adds per-frame overhead proportional to buffer size (GLib
     * type-system init, refcount machinery) and leaks the old allocator. */
    if (!app->dmabuf_allocator)
        app->dmabuf_allocator = gst_dmabuf_allocator_new();

    buffer = gst_buffer_new ();
    app->dma_map[app->dma_map_idx].fd   = 0;
    app->dma_map[app->dma_map_idx].size = app->export_fd_size;

    GST_DEBUG ("Appsrc: frame-count - %lu", app->appsrc_framecnt);

    /* request driver to map available fd */
    ret = pcie_dma_map(app->fd, &(app->dma_map[app->dma_map_idx]));
    if (ret < 0) {
        GST_ERROR ("Appsrc: dma fd map failed with %d", ret);
        return FALSE;
    }
    GST_DEBUG ("Appsrc: dmabuf bufferpool fd - %d",
               app->dma_map[app->dma_map_idx].fd);

    /* trigger dma transfer */
    pcie_read(app->fd, app->yuv_frame_size, 0, NULL);

    allocator = app->dmabuf_allocator;

    /* allocate dmabuf type memory */
    memory = gst_dmabuf_allocator_alloc (allocator,
                                         app->dma_map[app->dma_map_idx].fd,
                                         app->dma_map[app->dma_map_idx].size);
    if(!memory) {
        GST_ERROR ("Appsrc: Not able to allocate dma type memory");
        return FALSE;
    }

    /* check if the momory is dmabuf type or not */
    if (gst_is_dmabuf_memory (memory)) {
        GST_DEBUG ("Appsrc: allocated memory is dmabuf type");
    } else {
        GST_ERROR ("Appsrc: allocated Memory is non-dmabuf type");
        return FALSE;
    }

    /* Update the valid data, when export fd size and frame size is different */
    if(app->dma_export.size != app->yuv_frame_size)
        memory->size = app->yuv_frame_size;

    /* Add memory to buffer */
    gst_buffer_append_memory(buffer,memory);

    /* Get buffer timestamp */
    GST_BUFFER_TIMESTAMP(buffer) = (GstClockTime)
        ((app->appsrc_framecnt/(float)app->h_param.fps) * 1e9);

    /* push buffer to next element */
    gst_buffer_ref(buffer);
    g_signal_emit_by_name (app->pciesrc, "push-buffer", buffer, &ret);
    if(ret != GST_FLOW_OK) {
        GST_ERROR ("Appsrc: Push-buffer failed, frame-count - %lu, error - %d",
                    app->appsrc_framecnt, ret);
    }

    /* This will help to decide when to send EOS */
    app->read_offset += app->yuv_frame_size;

    /* start unmaping at MAX_BUFFER_POOL_SIZE frame */
    if(app->appsrc_framecnt >= MAX_BUFFER_POOL_SIZE) {
        unmap_idx = app->appsrc_framecnt % MAX_BUFFER_POOL_SIZE;
        GST_DEBUG ("Appsrc: Unmapping dmabuf fd[%d] - %d",
                    unmap_idx, app->dma_map[unmap_idx].fd);

        /* unmap oldest fd  */
        ret = pcie_dma_unmap(app->fd, &(app->dma_map[unmap_idx]));
        if (ret < 0)
            GST_ERROR ("Appsrc: dma unmap failed with %d", ret);
    }

    /* circulate within available bufferpool */
    if(app->dma_map_idx >= (MAX_BUFFER_POOL_SIZE-1)) {
        app->dma_map_idx = 0;
    }
    else
        app->dma_map_idx++;

    gst_buffer_unref (buffer);
    /* Do NOT unref the allocator here — it is cached in app->dmabuf_allocator
     * and reused across frames.  It is freed once in pcie_main.c cleanup. */

    return TRUE;
}

void start_feed (GstElement *source, guint size, gpointer data)
{
    App *app = (App *)data;
    if (!app) {
        GST_DEBUG("start_feed() user_data pointer is NULL\n");
        return;
    }
    if (app->sourceid == 0) {
        GST_DEBUG ("Start feeding at frame %lu", app->appsrc_framecnt);
        app->sourceid = g_idle_add ((GSourceFunc) feed_data, app);
    }
}

void stop_feed (GstElement *source, App *data)
{
    if (data->sourceid != 0) {
        GST_DEBUG ("Stop feeding at frame %lu", data->appsrc_framecnt);
        g_source_remove (data->sourceid);
        data->sourceid  = 0;
    }
}


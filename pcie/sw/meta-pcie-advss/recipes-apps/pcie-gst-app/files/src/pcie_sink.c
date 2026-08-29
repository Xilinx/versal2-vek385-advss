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

#include <pcie_sink.h>
#include <time.h>
#include <unistd.h>  /* usleep */

GST_DEBUG_CATEGORY_EXTERN (pcie_gst_app_debug);
#define GST_CAT_DEFAULT pcie_gst_app_debug

GstFlowReturn new_sample_cb (GstElement* elt, App* app)
{
    GstSample *sample = NULL;
    GstBuffer *buffer = NULL;
    GstMemory *mem    = NULL;
    gint      ret     = 0;
    static struct timespec ts_last = {0, 0};
    static guint64 local_count = 0;

    /* ── Frame-rate limiter ────────────────────────────────────────────
     * After a stall (e.g. read_complete timeout), running_time advances
     * far past all buffer PTS values.  GstBaseSink's sync=TRUE detects
     * every buffer as "late" and renders without waiting, causing a
     * 1000+ fps burst that overwhelms the host display queue and
     * overwrites frames before they are displayed.
     *
     * Enforce a minimum inter-frame interval of 1000/fps ms so the C2H
     * rate never exceeds the target fps, regardless of clock drift.
     * This does NOT fire during normal operation because sync=TRUE
     * already spaces frames at ~33 ms (30 fps). */
    {
        static struct timespec ts_prev_write = {0, 0};
        struct timespec ts_now;
        clock_gettime(CLOCK_MONOTONIC, &ts_now);
        if (ts_prev_write.tv_sec != 0 && app->h_param.fps > 0) {
            double elapsed_ms = (ts_now.tv_sec - ts_prev_write.tv_sec) * 1000.0
                              + (ts_now.tv_nsec - ts_prev_write.tv_nsec) / 1e6;
            double frame_ms = 1000.0 / app->h_param.fps;
            if (elapsed_ms < frame_ms) {
                long sleep_us = (long)((frame_ms - elapsed_ms) * 1000.0);
                if (sleep_us > 0 && sleep_us < 100000)  /* cap at 100 ms */
                    usleep(sleep_us);
                clock_gettime(CLOCK_MONOTONIC, &ts_now);
            }
        }
        ts_prev_write = ts_now;
    }

    app->appsink_framecnt++;
    local_count++;

    /* get the sample from appsink */
    sample = gst_app_sink_pull_sample (GST_APP_SINK (elt));

    /* get buffer from sample */
    buffer = gst_sample_get_buffer (sample);
    if (!buffer) {
        GST_ERROR ("Appsink: received NULL buffer");
        return GST_FLOW_EOS;
    }

    /* get memory from buffer */
    mem = gst_buffer_peek_memory (buffer, 0);
    if(!mem) {
        GST_ERROR ("Appsink: recieved NULL memory");
        return GST_FLOW_EOS;
    }

    /* is memory dmabuf type? */
    if (gst_is_dmabuf_memory (mem)) {
        GST_DEBUG ("Appsink: pulled dmabuf element, frame-count -> %lu",
                  app->appsink_framecnt);
    } else {
        GST_ERROR ("Appsink: pulled non-dmabuf memory");
        return GST_FLOW_EOS;
    }

    /* get fd from memory */
    app->dma_import.dbuf_fd = gst_dmabuf_memory_get_fd (mem);
    GST_DEBUG ("Appsink: received fd - %d", app->dma_import.dbuf_fd);

    /* request driver to import the fd */
    ret = pcie_dma_import(app->fd,&app->dma_import);
    if (ret < 0 ) {
        GST_ERROR ("Failed to get import fd");
    }
    GST_DEBUG ("Appsink: dma import successful");

    /* initiate dma write operation */
    ret = pcie_write(app->fd, app->yuv_frame_size, 0, NULL);
    if (ret < 0) {
        GST_ERROR ("pcie_write failed, err - %d", ret);
    }
    GST_DEBUG ("Appsink: pcie write successful");

    /* all done, release the fd */
    ret = pcie_dma_import_release(app->fd,&app->dma_import);
    if (ret < 0 ) {
        GST_ERROR ("Failed to release import dma buf fd - %d",
                app->dma_import.dbuf_fd);
    }
    GST_DEBUG ("Appsink: dma import release successful");

    gst_sample_unref (sample);
    GST_DEBUG ("Appsink: processed frame-count -> %lu", app->appsink_framecnt);

    /* Per-30-frame throughput log */
    if (local_count % 30 == 0) {
        struct timespec ts_now;
        clock_gettime(CLOCK_MONOTONIC, &ts_now);
        if (ts_last.tv_sec != 0) {
            double elapsed = (ts_now.tv_sec  - ts_last.tv_sec) +
                             (ts_now.tv_nsec - ts_last.tv_nsec) / 1e9;
            g_print("[pcie_sink] 30 frames in %.3f s (%.1f fps) "
                    "total_appsink=%lu\n",
                    elapsed, 30.0 / elapsed, app->appsink_framecnt);
        }
        ts_last = ts_now;
    }

    return GST_FLOW_OK;
}


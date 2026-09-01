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

#include <pcie_main.h>
#include <pcie_src.h>
#include <pcie_sink.h>
#include <unistd.h>  /* usleep */
#include <signal.h>

#define KMSSINK_BUS_ID "edd00000.mmi_dc"
#define KMSSINK_PLAN_ID 36

App s_app = {0};
GST_DEBUG_CATEGORY (pcie_gst_app_debug);

#define GST_CAT_DEFAULT pcie_gst_app_debug

/* ── SIGINT / Ctrl+C handler ───────────────────────────────────────────────
 * On Ctrl+C, quit the GLib main loop so the normal cleanup path in main()
 * runs.  This ensures /dev/pciep0 is closed (which triggers the driver's
 * release(), clearing buffer-ready bits and resetting completions) and
 * read_write_transfer_done() signals the host that the EP is done.
 * SA_RESETHAND makes a second Ctrl+C do a hard kill (escape hatch).
 * ──────────────────────────────────────────────────────────────────────── */
static void sigint_quit_handler(int sig)
{
    (void)sig;
    g_print("\n[SIGINT] Ctrl+C received — shutting down gracefully\n");
    if (s_app.loop && g_main_loop_is_running(s_app.loop))
        g_main_loop_quit(s_app.loop);
}

static gboolean bus_message (GstBus *bus, GstMessage *message, App *app)
{
    GError* err   = NULL;
    gchar*  debug = NULL;

    switch (GST_MESSAGE_TYPE (message)) {

        case GST_MESSAGE_INFO:
            gst_message_parse_info (message, &err, &debug);
            if (debug) {
                GST_INFO ("INFO: %s", debug);
                g_free (debug);
            }
            if (err)
                g_error_free (err);
            break;

        case GST_MESSAGE_ERROR:
            gst_message_parse_error (message, &err, &debug);
            if(err && message) {
                GST_ERROR ("Received ERROR from %s: %s",
                GST_MESSAGE_SRC_NAME (message), err->message);
                g_error_free (err);
            }
            if (debug) {
                GST_ERROR ("ERROR: %s", debug);
                g_free (debug);
            }
            if (app->loop && g_main_loop_is_running(app->loop)) {
                g_main_loop_quit (app->loop);
                GST_ERROR ("Quitting the loop");
                g_main_loop_unref (app->loop);
                app->loop = NULL;
            }
            break;

        case GST_MESSAGE_EOS:
            if (g_main_loop_is_running (app->loop)) {
                if (app->loop) {
                    g_main_loop_quit (app->loop);
                    GST_DEBUG ("Quitting the loop");
                    g_main_loop_unref (app->loop);
                    app->loop = NULL;
                }
            }
            break;

        default:
            break;
    }

    return TRUE;
}

static void read_write_transfer_done (App* app)
{
    gint ret = 0;

    GST_INFO ("[pcie_main] read_write_transfer_done: signalling host");

    /* Avoid sending read transfer done in mipi use-case */
    if (app->h_param.usecase > VGST_USECASE_TYPE_MIPISRC_TO_HOST_BYPASS) {
        ret = pcie_set_read_transfer_done(app->fd);
        if (ret >= 0)
            GST_DEBUG ("set read transfer done");
    }

    /* Send write transfer done for all use-case types */
    ret = pcie_set_write_transfer_done(app->fd);
    if (ret >= 0)
        GST_DEBUG ("set write transfer done");

    /* RW_DONE_SET_AND_CLEAR_DELAY is 0 — no sleep needed */

    /* Avoid clearing read transfer done in mipi use-case */
    if (app->h_param.usecase > VGST_USECASE_TYPE_MIPISRC_TO_HOST_BYPASS) {
        ret = pcie_clr_read_transfer_done(app->fd);
        if (ret >= 0)
            GST_DEBUG ("clear read transfer done");
    }

    /* Clear write transfer done for all use-case types */
    ret = pcie_clr_write_transfer_done(app->fd);
    if (ret >= 0)
        GST_DEBUG ("clear write transfer done");

    GST_INFO ("[pcie_main] read_write_transfer_done: complete");
}

static GstPadProbeReturn appsink_query_cb (GstPad *pad G_GNUC_UNUSED,
             GstPadProbeInfo *info, gpointer user_data G_GNUC_UNUSED)
{
    GstQuery *query = info->data;

    if (GST_QUERY_TYPE (query) != GST_QUERY_ALLOCATION)
        return GST_PAD_PROBE_OK;

    gst_query_add_allocation_meta (query, GST_VIDEO_META_API_TYPE, NULL);

    return GST_PAD_PROBE_HANDLED;
}

static guint64 get_export_fd_size(guint64 framesize)
{
    guint   diff     = 0;
    guint   rem      = 0;
    guint   pagesize = 0;
    guint64 expfd_sz = 0;

    /* Get page size */
    pagesize = sysconf(_SC_PAGESIZE);

    /* Get reminder */
    rem = framesize % pagesize;

    if(rem != 0) {
        /* Get difference that we need to add in framesize */
        diff = pagesize - rem;

        /* Update the export fd size, so that the resultant framesize will be in
           multiple of the pagesize */
        expfd_sz = framesize + diff;
    }
    else
        expfd_sz = framesize;

    return expfd_sz;
}

static gint set_host_parameters(App *app)
{
    gint ret = 0;

    /* Get usecase type */
    ret = pcie_get_usecase_type(app->fd, &(app->h_param.usecase));
    if (ret < 0) {
        GST_ERROR ("Failed to get usecase type");
        return PCIE_GST_APP_FAIL;
    }

    GST_INFO ("Usecase type is %d", app->h_param.usecase);
    if (app->h_param.usecase != VGST_USECASE_TYPE_MIPISRC_TO_HOST_BYPASS &&
        app->h_param.usecase != VGST_USECASE_TYPE_APPSRC_TO_HOST_BYPASS) {
        GST_ERROR ("Unsupported usecase type %u — only UC1 (1) and UC2 (2) are supported",
                   app->h_param.usecase);
        return PCIE_GST_APP_FAIL;
    }

    /* Get input file length (UC2 only — file from host) */
    if (app->h_param.usecase == VGST_USECASE_TYPE_APPSRC_TO_HOST_BYPASS) {
        ret = pcie_get_file_length(app->fd, &(app->h_param.length));
        if (ret < 0) {
            GST_ERROR ("Failed to get file length");
            return PCIE_GST_APP_FAIL;
        }
        GST_INFO("Input file length is %lu", app->h_param.length);
    }

    /* Get input resolution */
    ret = pcie_get_input_resolution(app->fd, &app->h_param.input_res);
    if (ret < 0) {
        GST_ERROR ("Failed to get input resolution");
        return PCIE_GST_APP_FAIL;
    }
    if (app->h_param.input_res.width == 0 || app->h_param.input_res.height == 0) {
        GST_ERROR ("Invalid resolution %ux%u from host (register not yet written?)",
                   app->h_param.input_res.width, app->h_param.input_res.height);
        return PCIE_GST_APP_FAIL;
    }
    GST_INFO("Resolution is %d x %d", app->h_param.input_res.width,
                                        app->h_param.input_res.height);

    /* Get the input fps */
    ret = pcie_get_fps(app->fd, &(app->h_param.fps));
    if (ret < 0) {
        GST_ERROR ("Failed to get fps");
        return PCIE_GST_APP_FAIL;
    }
    if (app->h_param.fps == 0) {
        GST_WARNING ("FPS from host is 0 — defaulting to 30");
        app->h_param.fps = 30;
    }
    GST_INFO("FPS is %d", app->h_param.fps);

    /* Get format type from host via PCIRC_FORMAT_SET register.
     * Values: VGST_FORMAT_YUY2=1, VGST_FORMAT_NV12=2, VGST_FORMAT_RGB=3.
     * Default to NV12 if register read fails or returns 0. */
    {
        guint fmt_val = 0;
        ret = pcie_get_format(app->fd, &fmt_val);
        if (ret < 0 || fmt_val == 0 || fmt_val >= VGST_FORMAT_MAX)
            fmt_val = VGST_FORMAT_NV12;
        app->h_param.input_format = fmt_val;
        GST_INFO("Video format from host: %u (%s)", fmt_val,
                 (fmt_val == VGST_FORMAT_YUY2) ? "YUY2"   :
                 (fmt_val == VGST_FORMAT_RGB)  ? "RGB888" : "NV12");
    }

    /* Compute per-frame byte size based on format */
    if (app->h_param.input_format == VGST_FORMAT_YUY2) {
        app->yuv_frame_size = app->h_param.input_res.width *
                              app->h_param.input_res.height * YUY2_MULTIPLIER;
    } else if (app->h_param.input_format == VGST_FORMAT_RGB) {
        app->yuv_frame_size = app->h_param.input_res.width *
                              app->h_param.input_res.height * RGB888_MULTIPLIER;
    } else {
        /* NV12 (default) */
        app->yuv_frame_size = app->h_param.input_res.width *
                              app->h_param.input_res.height * NV12_MULTIPLIER;
    }
    GST_INFO("Frame size is %lu bytes", app->yuv_frame_size);

    /* Always-visible summary */
    g_print("[pcie_gst_app] Host config: %ux%u @ %u fps | Format: %s | UC%u\n",
            app->h_param.input_res.width,
            app->h_param.input_res.height,
            app->h_param.fps,
            (app->h_param.input_format == VGST_FORMAT_YUY2) ? "YUY2"   :
            (app->h_param.input_format == VGST_FORMAT_RGB)  ? "RGB888" : "NV12",
            (app->h_param.usecase == VGST_USECASE_TYPE_MIPISRC_TO_HOST_BYPASS) ? 1u : 2u);

    return ret;
}

static gint gst_set_elements (App *app)
{
    gint ret = 0;

    app->pipeline       = gst_pipeline_new          ("pipeline");
    app->inputsrc       = gst_element_factory_make  ("v4l2src",         NULL);
    app->capsfilter     = gst_element_factory_make  ("capsfilter",      NULL);
    app->pciesrc        = gst_element_factory_make  ("appsrc",          NULL);
    app->pciesink       = gst_element_factory_make  ("appsink",         NULL);
    app->perf           = gst_element_factory_make  ("perf",            NULL);
    if (!app->pipeline || !app->inputsrc  || !app->capsfilter  ||
        !app->pciesrc  || !app->pciesink  || !app->perf) {
      GST_ERROR ("Failed to create required GStreamer elements");
      return PCIE_GST_APP_FAIL;
    }
    GST_INFO("Created all required GStreamer elements");

    return ret;
}

static void gst_reset_elements (App *app)
{
    gst_object_unref (GST_OBJECT (app->pipeline));
    gst_object_unref (GST_OBJECT (app->inputsrc));
    gst_object_unref (GST_OBJECT (app->capsfilter));
    gst_object_unref (GST_OBJECT (app->pciesrc));
    gst_object_unref (GST_OBJECT (app->pciesink));
    gst_object_unref (GST_OBJECT (app->perf));
    GST_INFO("Released GStreamer elements");
}

static void set_property (App *app)
{
    GstCaps* srcCaps = NULL;
    const char *fmt_str;

    /* Pick GStreamer format string from the host-selected format */
    fmt_str = (app->h_param.input_format == VGST_FORMAT_YUY2) ? VIDEOPARSE_FORMAT_YUY2
            : (app->h_param.input_format == VGST_FORMAT_RGB)  ? VIDEOPARSE_FORMAT_RGB
            :                                                    VIDEOPARSE_FORMAT_NV12;

    if (app->h_param.usecase == VGST_USECASE_TYPE_APPSRC_TO_HOST_BYPASS) {
        /* UC2: appsrc — file from host */
        GST_INFO("Setting up appsrc plugin");
        g_object_set (G_OBJECT (app->pciesrc),
                "stream-type", GST_APP_STREAM_TYPE_STREAM,
                "format",      GST_FORMAT_TIME,
                "is-live",     FALSE,
                "block",       TRUE,
                "max-bytes",   app->yuv_frame_size,
                NULL);
        srcCaps = gst_caps_new_simple ("video/x-raw",
                "format",     G_TYPE_STRING,  fmt_str,
                "width",      G_TYPE_INT,     app->h_param.input_res.width,
                "height",     G_TYPE_INT,     app->h_param.input_res.height,
                "framerate",  GST_TYPE_FRACTION,
                              app->h_param.fps, MAX_FRAME_RATE_DENOM, NULL);
        GST_INFO("New Caps for appsrc %" GST_PTR_FORMAT, srcCaps);
        g_object_set (G_OBJECT (app->pciesrc),  "caps",  srcCaps, NULL);
        gst_caps_unref (srcCaps);
    } else {
        /* UC1: v4l2src — MIPI camera */
        GST_INFO("Setting up v4l2src plugin");
        g_object_set (G_OBJECT(app->inputsrc),
                "io-mode",   VGST_V4L2_IO_MODE_DMABUF_EXPORT,
                "device",    INPUT_SRC,
                NULL);
        srcCaps = gst_caps_new_simple ("video/x-raw",
                "width",     G_TYPE_INT,     app->h_param.input_res.width,
                "height",    G_TYPE_INT,     app->h_param.input_res.height,
                "format",    G_TYPE_STRING,  fmt_str,
                "framerate", GST_TYPE_FRACTION,
                             app->h_param.fps, MAX_FRAME_RATE_DENOM,
                NULL);
        GST_INFO("New Caps for capsfilter %" GST_PTR_FORMAT, srcCaps);
        g_object_set (G_OBJECT (app->capsfilter),  "caps",  srcCaps, NULL);
        gst_caps_unref (srcCaps);
    }

    /* Configure appsink.
     * UC1 (MIPI live): sync=FALSE — live source, never block on clock.
     * UC2 (file):      sync=TRUE  — clock paces C2H DMA at exactly fps. */
    g_object_set (G_OBJECT (app->pciesink),
            "emit-signals", TRUE,
            "sync",  (app->h_param.usecase == VGST_USECASE_TYPE_APPSRC_TO_HOST_BYPASS),
            "async",        FALSE,
            NULL);
}

static gint create_pipeline (App *app)
{
    gint ret = 0;

    if (app->h_param.usecase == VGST_USECASE_TYPE_MIPISRC_TO_HOST_BYPASS) {
        /* UC1: v4l2src → capsfilter → perf → pciesink (appsink) → host display */
        gst_bin_add_many (GST_BIN (app->pipeline), app->inputsrc,
                app->capsfilter, app->perf, app->pciesink, NULL);
        if (gst_element_link_many (app->inputsrc, app->capsfilter,
                app->perf, app->pciesink, NULL) != TRUE) {
            GST_ERROR ("Error linking v4l2src → capsfilter → perf → pciesink");
            ret = PCIE_GST_APP_FAIL;
        } else {
            GST_INFO("Linked v4l2src → capsfilter → perf → pciesink");
        }
    }
    else if (app->h_param.usecase == VGST_USECASE_TYPE_APPSRC_TO_HOST_BYPASS) {
        /* UC2: pciesrc (appsrc) → perf → pciesink (appsink) → host display */
        gst_bin_add_many (GST_BIN (app->pipeline), app->pciesrc,
                app->perf, app->pciesink, NULL);
        if (gst_element_link_many (app->pciesrc, app->perf,
                app->pciesink, NULL) != TRUE) {
            GST_ERROR ("Error linking pciesrc → perf → pciesink");
            ret = PCIE_GST_APP_FAIL;
        } else {
            GST_INFO("Linked pciesrc → perf → pciesink");
        }
    }
    return ret;
}

static void destroy_pipeline (App *app)
{
    gst_object_ref (app->pipeline);
    gst_object_ref (app->perf);

    if (app->h_param.usecase == VGST_USECASE_TYPE_MIPISRC_TO_HOST_BYPASS) {
        gst_element_unlink_many (app->inputsrc, app->capsfilter,
                app->perf, app->pciesink, NULL);
        gst_object_ref (app->inputsrc);
        gst_object_ref (app->capsfilter);
        gst_object_ref (app->pciesink);
        gst_bin_remove_many (GST_BIN (app->pipeline), app->inputsrc,
                app->capsfilter, app->perf, app->pciesink, NULL);
        GST_INFO("Destroyed v4l2src → capsfilter → perf → pciesink");
    }
    else if (app->h_param.usecase == VGST_USECASE_TYPE_APPSRC_TO_HOST_BYPASS) {
        gst_element_unlink_many (app->pciesrc, app->perf, app->pciesink, NULL);
        gst_object_ref (app->pciesrc);
        gst_object_ref (app->pciesink);
        gst_bin_remove_many (GST_BIN (app->pipeline), app->pciesrc,
                app->perf, app->pciesink, NULL);
        GST_INFO("Destroyed pciesrc → perf → pciesink");
    }
}

static gpointer host_app_reg_read (gpointer data)
{
    gint       ret            = 0;
    guint      stop_mipi_feed = 0;
    App*       app            = (App*) data;

    GST_INFO("starting hostapp register read thread");

    while(!app->exit_thread) {

        /* Check for stop signal for ALL use cases — not only MIPI.
         * When the host sends PCIEP_SET_SIG=1 (q+Enter for UC1 or
         * end-of-transfer for UC2), send EOS to the GStreamer pipeline
         * so the EP application exits cleanly without user intervention. */
        if (app->loop) {

            stop_mipi_feed = 0;
            ret = pcie_read_stop_mipi_feed (app->fd, &stop_mipi_feed);
            if (ret < 0) {
                GST_WARNING ("Failed to read stop mipi feed signal");
            }

            if (stop_mipi_feed) {
                g_print("[pcie_gst_app] Stop signal from host — closing ISP pipeline gracefully\n");
                /* Mark thread for exit so the polling loop stops */
                app->exit_thread = TRUE;

                /* Call g_main_loop_quit() directly — this is the exact equivalent
                 * of the user pressing Ctrl+C on the terminal:
                 *
                 *   Ctrl+C → SIGINT → GLib signal handler → g_main_loop_quit()
                 *   Host stop signal → host_app_reg_read → g_main_loop_quit()
                 *
                 * Both paths cause g_main_loop_run() in main() to return, which
                 * then runs:
                 *   gst_element_set_state(pipeline, GST_STATE_NULL)
                 *     → v4l2src stops acquiring frames
                 *     → camera / ISP resources freed
                 *     → RPU mailbox communication terminated cleanly
                 *   pcie_dma_export_release()  (UC2: DMA pool freed)
                 *   read_write_transfer_done()  (host notified)
                 *
                 * Note: sending EOS to a live pipeline (v4l2src) does NOT work
                 * because v4l2src never generates a natural EOS — the pipeline
                 * hangs waiting for it and the ISP is never properly freed. */
                if (app->loop && g_main_loop_is_running(app->loop)) {
                    GST_INFO("[pcie_main] Calling g_main_loop_quit (usecase=%d)",
                             app->h_param.usecase);
                    g_main_loop_quit(app->loop);
                }
            }
        }

        /* Poll stop-mipi-feed signal every HOST_APP_REG_READ_TIMEOUT_US (50 ms) */
        usleep(HOST_APP_REG_READ_TIMEOUT_US);
    }

    GST_DEBUG("Exit thread is set, quitting hostapp register read thread");
    g_thread_exit(0);
    return NULL;
}

gint main (gint argc, gchar *argv[])
{
    App*        app         = &s_app;
    GstBus*     bus         = NULL;
    GstPad*     pad         = NULL;
    GThread*    thread      = NULL;
    gint        ret         = 0;
    gulong      hid_need    = 0;   /* handler id - need data signal       */
    gulong      hid_enough  = 0;   /* handler id - enough data signal     */
    gulong      hid_sample  = 0;   /* handler id - new sample signal      */
    gulong      pid_query   = 0;   /* probe   id - appsink query callback */
    memset (app, 0, sizeof(App));

    gst_init (&argc, &argv);

    /* Install SIGINT/SIGTERM handler so Ctrl+C quits the GMainLoop instead
     * of killing the process. */
    {
        struct sigaction sa;
        sa.sa_handler = sigint_quit_handler;
        sa.sa_flags   = SA_RESETHAND;   /* second Ctrl+C = hard kill */
        sigemptyset(&sa.sa_mask);
        sigaction(SIGINT,  &sa, NULL);
        sigaction(SIGTERM, &sa, NULL);
    }

    GST_DEBUG_CATEGORY_INIT(pcie_gst_app_debug, "pcie_gst_app", 0,
            "PCIe endpoint device GStreamer application");

    app->fd = pcie_open();
    if (app->fd < 0) {
        g_printerr ("Failed to open device %d\n", app->fd);
        return PCIE_GST_APP_FAIL;
    }
    GST_INFO("PCIe open success, fd = %d", app->fd);

    thread = g_thread_new ("host-app reg read thread",
                           &host_app_reg_read,
                           app);

    /* Verify the app and the driver agree on the EP DMA buffer pool depth. */
    {
        gint drv_bufs = pcie_num_dma_buf(app->fd);

        if (drv_bufs < MAX_BUFFER_POOL_SIZE) {
            g_printerr ("FATAL: driver exports %d DMA buffers but this app "
                        "needs %d.\n"
                        "       Align NUM_BUFFERS in xilinx_pci_endpoint.c "
                        "with MAX_BUFFER_POOL_SIZE in pcie_abstract.h.\n",
                        drv_bufs, MAX_BUFFER_POOL_SIZE);
            goto PCIE_DEV_CLOSE;
        }
        if (drv_bufs != MAX_BUFFER_POOL_SIZE)
            GST_WARNING ("Driver exports %d DMA buffers, app uses %d; "
                         "the remaining %d are unused reserved memory.",
                         drv_bufs, MAX_BUFFER_POOL_SIZE,
                         drv_bufs - MAX_BUFFER_POOL_SIZE);
        else
            GST_INFO ("EP DMA buffer pool depth = %d (app and driver agree)",
                      MAX_BUFFER_POOL_SIZE);
    }

    /* Setting up the gst elements */
    ret = gst_set_elements(app);
    if (ret < 0) {
        g_printerr ("Failed to set the gst elements\n");
        goto PCIE_DEV_CLOSE;
    }

    /* Read host-configured parameters (usecase, resolution, fps, format) */
    ret = set_host_parameters(app);
    if (ret < 0) {
        g_printerr ("Failed to set the host parameters\n");
        goto GST_RESET_ELEMENTS;
    }

    GST_INFO ("Usecase=%d  FPS=%d", app->h_param.usecase, app->h_param.fps);

    /* Set GStreamer element properties for pipeline */
    set_property (app);

    /* Create GStreamer pipeline */
    ret = create_pipeline(app);
    if (ret < 0) {
        g_printerr("Failed to create pipeline\n");
        goto GST_RESET_ELEMENTS;
    }

    /* Create a mainloop  */
    app->loop = g_main_loop_new (NULL, TRUE);

    bus = gst_pipeline_get_bus (GST_PIPELINE (app->pipeline));

    /* UC2 (appsrc): register need-data / enough-data callbacks */
    if (app->h_param.usecase == VGST_USECASE_TYPE_APPSRC_TO_HOST_BYPASS) {
        hid_need   = g_signal_connect(app->pciesrc,
                "need-data",   G_CALLBACK(start_feed), app);
        hid_enough = g_signal_connect(app->pciesrc,
                "enough-data", G_CALLBACK(stop_feed),  app);
        GST_INFO ("start_feed/stop_feed callbacks registered for UC2");
    }

    /* Both UC1 and UC2 use appsink → register new-sample callback */
    hid_sample = g_signal_connect(app->pciesink,
            "new-sample", G_CALLBACK(new_sample_cb), app);

    pad = gst_element_get_static_pad (app->pciesink, "sink");
    pid_query = gst_pad_add_probe (pad,
            GST_PAD_PROBE_TYPE_QUERY_DOWNSTREAM,
            appsink_query_cb, NULL, NULL);

    /* Add watch for messages */
    gst_bus_add_watch (bus, (GstBusFunc) bus_message, app);

    /* Set export fd size */
    app->export_fd_size = get_export_fd_size(app->yuv_frame_size);
    GST_INFO("export fd size = %lu", app->export_fd_size);

    /* UC2: allocate DMA buffer pool in the driver */
    if (app->h_param.usecase == VGST_USECASE_TYPE_APPSRC_TO_HOST_BYPASS) {
        app->dma_export.fd = 0;
        app->dma_export.size = app->export_fd_size;
        ret = pcie_dma_export(app->fd, &app->dma_export);
        if (ret < 0) {
            g_printerr ("Failed to initialize bufferpool");
            goto DESTROY_PIPELINE;
        }
    }

    /* Move pipeline to PLAYING */
    gst_element_set_state (app->pipeline, GST_STATE_PLAYING);
    g_print("[pcie_main] Pipeline PLAYING: UC%u %dx%d @ %d fps\n",
            (app->h_param.usecase == VGST_USECASE_TYPE_MIPISRC_TO_HOST_BYPASS) ? 1u : 2u,
            app->h_param.input_res.width, app->h_param.input_res.height,
            app->h_param.fps);

    g_main_loop_run (app->loop);
    g_print("[pcie_main] Exiting: appsink_frames=%lu appsrc_frames=%lu\n",
            app->appsink_framecnt, app->appsrc_framecnt);

    gst_element_set_state (app->pipeline, GST_STATE_NULL);

    /* UC2: release bufferpool memory */
    if (app->h_param.usecase == VGST_USECASE_TYPE_APPSRC_TO_HOST_BYPASS) {
        ret = pcie_dma_export_release(app->fd, &app->dma_export);
        if (ret < 0)
            g_printerr ("Failed to release bufferpool");
    }

    /* Signal host that EP is done */
    read_write_transfer_done(app);

DESTROY_PIPELINE:

    /* Remove and unref pad probe */
    gst_pad_remove_probe (pad, pid_query);
    gst_object_unref (pad);
    pad = NULL;

    /* Disconnect signal handlers */
    if (app->h_param.usecase == VGST_USECASE_TYPE_APPSRC_TO_HOST_BYPASS) {
        g_signal_handler_disconnect (app->pciesrc,  hid_need);
        g_signal_handler_disconnect (app->pciesrc,  hid_enough);
    }
    g_signal_handler_disconnect (app->pciesink, hid_sample);
    GST_DEBUG ("Disconnected registered signal callbacks");

    /* Remove and unref bus watch */
    gst_bus_remove_watch (bus);
    gst_object_unref (bus);
    bus = NULL;

    /* Unref loop */
    if (app->loop)
        g_main_loop_unref(app->loop);
    app->loop = NULL;

    /* Release cached DMA-buf allocator (created once in feed_data, reused per frame) */
    if (app->dmabuf_allocator) {
        gst_object_unref (app->dmabuf_allocator);
        app->dmabuf_allocator = NULL;
    }

    /* Destroy GStreamer pipeline */
    destroy_pipeline (app);

GST_RESET_ELEMENTS:

    /* Release GStreamer elements */
    gst_reset_elements(app);

PCIE_DEV_CLOSE:

    /* join thread */
    app->exit_thread = TRUE;
    g_thread_join (thread);

    pcie_close(app->fd);
    GST_DEBUG ("Closed PCIe FD");

    gst_debug_category_free(pcie_gst_app_debug);
    gst_deinit();

    return 0;
}


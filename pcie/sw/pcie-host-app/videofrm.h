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

#ifndef VIDEO_H
#define VIDEO_H

#include <QWidget>
#include <QPixmap>
#include <QDateTime>
#include <thread>
#include <mutex>
#include <atomic>
#include <time.h>

class videofrm : public QWidget
{
    Q_OBJECT
public:
    explicit videofrm(QWidget *parent = nullptr);
    ~videofrm();

    int fmcount = 0;
    bool waitBuf = false;
    QTimer * t;
    uchar *b;
    QByteArray ba;
    int sizeval = 0;
    QString vfilename;
    char * yuvfrm = nullptr;
    uchar * dfrm = nullptr;
    QDateTime dg;
    int WID = 1920;
    int HEI = 1080;
    int FPS = 30;
    bool hasWindow = false;
    int convert_yuv_to_rgb_buffer(unsigned char *yuv, unsigned char *rgb, unsigned int width, unsigned int height);
    void config_frame();
    void setResolution(int wi, int he, int fp);
public slots:
    void updateframe();
    void updateFPSslot(int val);
    void stopTimer();
    void exitApp();
signals:
    void updateFPS(int);
    void stopTimersig();
    void ctrlc();

private:
    /* --- conversion worker thread (Issue #4 fix) --- */
    std::thread         convert_thread_;
    std::mutex          dfrm_mutex_;      /* guards dfrm_work_/dfrm_ready_ swap and new_frame_ready_ */
    std::atomic<bool>   worker_running_{false};
    uchar              *dfrm_work_  = nullptr;   /* worker writes converted BGR here   */
    uchar              *dfrm_ready_ = nullptr;   /* Qt timer reads BGR from here        */
    bool                new_frame_ready_ = false; /* set by worker, cleared by timer    */

    /* --- diagnostics --- */
    std::atomic<uint64_t> frames_displayed_{0};    /* frames actually shown via imshow    */
    std::atomic<uint64_t> frames_overwritten_{0};  /* TRUE drops: worker overwrote unconsumed frame */
    struct timespec       fps_ts_start_{};         /* set on first imshow, not config_frame */
    struct timespec       fps_ts_window_{};        /* window start for per-30-frame display fps */
    bool                  fps_ts_initialized_{false};

    void convertAndDisplayWorker();
    void stopConvertThread();
};

#endif // VIDEO_H

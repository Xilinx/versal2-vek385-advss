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

#include "videofrm.h"
#include <QApplication>
#include <QDebug>
#include <QPainter>
#include <QTimer>
#include <QFile>
#include "opencv2/opencv.hpp"
#include "opencv2/core/core.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/highgui/highgui.hpp"
#include <QDateTime>
#include "pcie_host.h"
#include <unistd.h>   /* usleep */
#include <fstream>
#include <chrono>
#define yuvfrac (1.5)
using namespace cv;
extern int format_type;  /* FMT_NV12=2 or FMT_YUY2=1 or FMT_RGB=3, set in cmaincall() */
#define FMT_YUY2 1       /* must match pcie_host.cpp */
#define FMT_NV12 2
#define FMT_RGB  3       /* RGB888 packed 24bpp */

videofrm::videofrm(QWidget *parent) : QWidget(parent)
{
	t = new QTimer();
	QObject::connect(this,SIGNAL(updateFPS(int)),this,SLOT(updateFPSslot(int)));
	QObject::connect(this,SIGNAL(stopTimersig()),this,SLOT(stopTimer()));
	QObject::connect(t,SIGNAL(timeout()),this,SLOT(updateframe()));
	QObject::connect(this,SIGNAL(ctrlc()),this,SLOT(exitApp()));
	t->setInterval(15);   /* poll at ~66 Hz — always > 2× the 30fps source rate */
	t->start();
}

videofrm::~videofrm()
{
	stopConvertThread();
}

void videofrm::stopConvertThread()
{
	if (worker_running_.exchange(false)) {
		if (convert_thread_.joinable())
			convert_thread_.join();
		printf("[videofrm] Convert thread joined. displayed=%lu overwritten=%lu\n",
		       frames_displayed_.load(), frames_overwritten_.load());
	}
}

void videofrm::exitApp()
{
	stopConvertThread();
	QApplication::quit();   /* graceful Qt exit — runs destructors and cleanup */
}

void videofrm::updateFPSslot(int fps)
{
	/* Poll at 2× source fps to guarantee the frame is caught within one poll period.
	 * Floor at 10ms (100 Hz) to avoid excessive timer overhead. */
	int poll_ms = (fps > 0) ? (1000 / (fps * 2)) : 15;
	if (poll_ms < 10) poll_ms = 10;
	printf("[videofrm] Timer poll interval: %d ms (source %d fps)\n", poll_ms, fps);
	t->setInterval(poll_ms);
	t->start();
}

void videofrm::stopTimer()
{
	t->stop();
}

void videofrm::setResolution(int wi, int he, int fp)
{
	WID = wi;
	HEI = he;
	FPS = fp;
}

void videofrm::config_frame()
{
	/* Clean up previous run's thread and buffers (safe on first call too) */
	stopConvertThread();
	free(yuvfrm);    yuvfrm    = NULL;
	free(dfrm_work_); dfrm_work_ = NULL;
	free(dfrm_ready_); dfrm_ready_ = NULL;
	dfrm = NULL;

	/* Reset per-run counters */
	frames_displayed_    = 0;
	frames_overwritten_  = 0;
	new_frame_ready_     = false;
	fps_ts_initialized_  = false;

	sizeval = WID * HEI;

	/* YUV input buffer — size depends on format:
	 *   YUY2:   2 bytes/pixel (packed 4:2:2)
	 *   RGB888: 3 bytes/pixel (packed 24bpp)
	 *   NV12:   1.5 bytes/pixel (semi-planar 4:2:0) */
	if (format_type == FMT_YUY2)
		yuvfrm = (char*)malloc(2 * WID * HEI * sizeof(char));       /* YUY2 16bpp */
	else if (format_type == FMT_RGB)
		yuvfrm = (char*)malloc(3 * WID * HEI * sizeof(char));       /* RGB888 24bpp */
	else
		yuvfrm = (char*)malloc((size_t)(WID * HEI * yuvfrac) * sizeof(char)); /* NV12 */

	/* Double BGR output buffers — worker writes dfrm_work_, Qt reads dfrm_ready_ */
	size_t bgr_sz = (size_t)WID * HEI * 3 * sizeof(char);
	dfrm_work_  = (uchar*)malloc(bgr_sz);
	dfrm_ready_ = (uchar*)malloc(bgr_sz);

	if (!yuvfrm || !dfrm_work_ || !dfrm_ready_) {
		fprintf(stderr, "[videofrm] OOM: failed to allocate frame buffers "
				"(%dx%d)\n", WID, HEI);
		free(yuvfrm);    yuvfrm    = NULL;
		free(dfrm_work_);  dfrm_work_  = NULL;
		free(dfrm_ready_); dfrm_ready_ = NULL;
		return;
	}

	dfrm        = dfrm_ready_;   /* keep public ptr valid for convert_yuv_to_rgb_buffer compat */

	clock_gettime(CLOCK_MONOTONIC, &fps_ts_start_);  /* provisional; reset on first imshow */

	/* Start conversion worker */
	worker_running_ = true;
	convert_thread_ = std::thread(&videofrm::convertAndDisplayWorker, this);

	emit updateFPS(FPS);
	printf("[videofrm] config_frame: %dx%d @ %d fps. Worker thread started.\n",
	       WID, HEI, FPS);
}

/* ---------------------------------------------------------------------------
 * convertAndDisplayWorker
 * Runs on a dedicated thread. Pulls YUV frames from queue_frame, converts
 * NV12→BGR (the expensive step) off the Qt timer thread, then makes the
 * converted buffer available for imshow().
 * --------------------------------------------------------------------------*/
void videofrm::convertAndDisplayWorker()
{
	uint64_t local_count = 0;
	struct timespec ts_last, ts_now;
	clock_gettime(CLOCK_MONOTONIC, &ts_last);

	printf("[convertWorker] Thread started\n");

	while (worker_running_ || queue_frame.index > 0) {
		/* Wait for a frame — yield rather than spin */
		if (queue_frame.index == 0) {
			if (!worker_running_)
				break;
			usleep(500);
			continue;
		}

		int rc = cb_deque(&queue_frame, yuvfrm);
		if (rc != 0) {
			usleep(500);
			continue;
		}

		/* Heavy colour conversion — off the Qt timer thread */
		if (format_type == FMT_YUY2) {
			/* YUY2 packed 4:2:2: CV_8UC2 (width x height) */
			cv::Mat mat_src = cv::Mat(HEI, WID, CV_8UC2,
			                         (unsigned char *)yuvfrm);
			cv::Mat mat_dst = cv::Mat(HEI, WID, CV_8UC3, dfrm_work_);
			cv::cvtColor(mat_src, mat_dst, cv::COLOR_YUV2BGR_YUYV);
		} else if (format_type == FMT_RGB) {
			/* RGB888: sensor/pipeline output is R-G-B packed.
			 * OpenCV imshow expects BGR — swap R and B channels. */
			cv::Mat mat_src = cv::Mat(HEI, WID, CV_8UC3,
			                         (unsigned char *)yuvfrm);
			cv::Mat mat_dst = cv::Mat(HEI, WID, CV_8UC3, dfrm_work_);
			cv::cvtColor(mat_src, mat_dst, cv::COLOR_RGB2BGR);
		} else {
			/* NV12 semi-planar 4:2:0 */
			cv::Mat mat_src = cv::Mat(HEI + (HEI / 2), WID, CV_8UC1,
			                         (unsigned char *)yuvfrm);
			cv::Mat mat_dst = cv::Mat(HEI, WID, CV_8UC3, dfrm_work_);
			cv::cvtColor(mat_src, mat_dst, cv::COLOR_YUV2BGR_NV12);
		}

		/* Swap work ↔ ready under brief lock.
		 * If Qt timer hasn't consumed the previous frame yet,
		 * it will be silently overwritten — count as a true drop. */
		{
			std::lock_guard<std::mutex> lk(dfrm_mutex_);
			if (new_frame_ready_) {
				frames_overwritten_++;  /* previous converted frame never shown */
				if (frames_overwritten_ % 30 == 1)
					printf("[convertWorker] WARNING: frame overwritten before display "
					       "total_overwritten=%lu\n", frames_overwritten_.load());
			}
			std::swap(dfrm_work_, dfrm_ready_);
			new_frame_ready_ = true;
		}
		local_count++;

		/* FPS log every 30 frames */
		if (local_count % 30 == 0) {
			clock_gettime(CLOCK_MONOTONIC, &ts_now);
			double elapsed = (ts_now.tv_sec  - ts_last.tv_sec) +
			                 (ts_now.tv_nsec - ts_last.tv_nsec) / 1e9;
			printf("[convertWorker] 30 frames in %.3f s (%.1f fps) "
			       "queue_depth=%zu overwritten=%lu\n",
			       elapsed, 30.0 / elapsed,
			       queue_frame.index,
			       frames_overwritten_.load());
			ts_last = ts_now;
		}
	}

	printf("[convertWorker] Exiting. total_converted=%lu true_drops(overwritten)=%lu\n",
	       local_count, frames_overwritten_.load());
}

/* ---------------------------------------------------------------------------
 * updateframe  (QTimer slot — Qt main thread, must be fast)
 * Only calls imshow() with the already-converted BGR buffer.
 * --------------------------------------------------------------------------*/
void videofrm::updateframe()
{
	/* Display any BGR frame the worker has ready */
	{
		std::lock_guard<std::mutex> lk(dfrm_mutex_);
		if (new_frame_ready_) {
			hasWindow = true;
			cv::Mat mat_bgr = cv::Mat(HEI, WID, CV_8UC3, dfrm_ready_);
			imshow("Video", mat_bgr);
			cv::waitKey(1);
			new_frame_ready_ = false;

			/* Latch fps_ts_start_ on the very first displayed frame */
			if (!fps_ts_initialized_) {
				clock_gettime(CLOCK_MONOTONIC, &fps_ts_start_);
				clock_gettime(CLOCK_MONOTONIC, &fps_ts_window_);
				fps_ts_initialized_ = true;
			}

			frames_displayed_++;
			uint64_t disp = frames_displayed_.load();

			/* Per-30-frame window FPS + cumulative avg */
			if (disp % 30 == 0) {
				struct timespec ts_now;
				clock_gettime(CLOCK_MONOTONIC, &ts_now);

				double win_elapsed = (ts_now.tv_sec  - fps_ts_window_.tv_sec) +
				                     (ts_now.tv_nsec - fps_ts_window_.tv_nsec) / 1e9;
				double avg_elapsed = (ts_now.tv_sec  - fps_ts_start_.tv_sec) +
				                     (ts_now.tv_nsec - fps_ts_start_.tv_nsec) / 1e9;

				printf("[updateframe] displayed=%lu  window_fps=%.1f  avg_fps=%.1f  "
				       "queue_depth=%zu  overwritten=%lu\n",
				       disp,
				       30.0 / win_elapsed,
				       disp / avg_elapsed,
				       queue_frame.index,
				       frames_overwritten_.load());
				fps_ts_window_ = ts_now;
			}
		}
		/* No else-drop counting here — timer firing with no frame ready is
		 * expected when polling faster than the source rate. */
	}

	/* Pipeline teardown */
	if (app_running == false && queue_frame.index == 0 && !new_frame_ready_) {
		stopConvertThread();
		emit stopTimersig();
		waitBuf   = false;
		hasWindow = false;
		destroyAllWindows();
		free(yuvfrm);    yuvfrm    = nullptr;
		free(dfrm_work_); dfrm_work_ = nullptr;
		free(dfrm_ready_); dfrm_ready_ = nullptr;
		dfrm = nullptr;
	}
}

std::string getTimestamp() {
    auto now = std::chrono::system_clock::now();
    auto duration = now.time_since_epoch();

    auto minutes = std::chrono::duration_cast<std::chrono::minutes>(duration) % 60;
    auto seconds = std::chrono::duration_cast<std::chrono::seconds>(duration) % 60;
    auto milliseconds = std::chrono::duration_cast<std::chrono::milliseconds>(duration) % 1000;

    std::ostringstream oss;
    oss << minutes.count() << "_"
        << seconds.count() << "_"
        << milliseconds.count();

    return oss.str();
}

/* convert_yuv_to_rgb_buffer — retained for compatibility / file-dump path.
 * In normal display flow the worker calls cvtColor directly into dfrm_work_.
 * imshow is now called from updateframe() so it stays on the Qt thread.     */
int videofrm::convert_yuv_to_rgb_buffer(unsigned char *yuv, unsigned char *rgb,
                                         unsigned int width, unsigned int height)
{
	if (format_type == FMT_YUY2) {
		cv::Mat mat_src = cv::Mat(height, width, CV_8UC2, yuv);
		cv::Mat mat_dst = cv::Mat(height, width, CV_8UC3, rgb);
		cv::cvtColor(mat_src, mat_dst, cv::COLOR_YUV2BGR_YUYV);
		imshow("Video", mat_dst);
	} else if (format_type == FMT_RGB) {
		cv::Mat mat_src = cv::Mat(height, width, CV_8UC3, yuv);
		cv::Mat mat_dst = cv::Mat(height, width, CV_8UC3, rgb);
		cv::cvtColor(mat_src, mat_dst, cv::COLOR_RGB2BGR);
		imshow("Video", mat_dst);
	} else {
		/* NV12 */
		cv::Mat mat_src = cv::Mat(height + (height / 2), width, CV_8UC1, yuv);
		cv::Mat mat_dst = cv::Mat(height, width, CV_8UC3, rgb);
		cv::cvtColor(mat_src, mat_dst, cv::COLOR_YUV2BGR_NV12);
		imshow("Video", mat_dst);
	}

	return 0;
}


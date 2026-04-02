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
#include <fstream>
#include <chrono>
#define yuvfrac (1.5)
//#define yuvfrac (2)
using namespace cv;
extern int usecase_sel;
videofrm::videofrm(QWidget *parent) : QWidget(parent)
{
	counter = 0;
	t = new QTimer();
	QObject::connect(this,SIGNAL(updateFPS(int)),this,SLOT(updateFPSslot(int)));
	QObject::connect(this,SIGNAL(stopTimersig()),this,SLOT(stopTimer()));
	QObject::connect(t,SIGNAL(timeout()),this,SLOT(updateframe()));
	QObject::connect(this,SIGNAL(ctrlc()),this,SLOT(exitApp()));
	t->setInterval(1000.0/(30)); // TODO NEED to modify.
	t->start();
}
void videofrm :: exitApp(){
	exit(1);
}
void videofrm :: updateFPSslot(int fps){
	t->setInterval(1000.0/(fps));
	t->start();
}
void videofrm :: stopTimer(){
	t->stop();
}
void videofrm :: setResolution(int wi, int he, int fp){
	WID = wi;
	HEI = he;
	FPS = fp;
	//    t->setInterval(1000.0/(fp));
}

void videofrm :: config_frame(){
	sizeval = WID * HEI;
	dfrm = (uchar*)malloc(WID * HEI * 5 * sizeof(char));
	if (usecase_sel == 2)
		yuvfrm = (char*)malloc( 3 * WID * HEI *5 * sizeof(char));
	else
		yuvfrm = (char*)malloc(WID * HEI *5 * sizeof(char));
	emit updateFPS(FPS);
	namedWindow("Video",1);
}
void videofrm:: updateframe(){
	if(waitBuf || queue_frame.index >= 30 || app_running == false)  {
		hasWindow = true;
		waitBuf = true;
		int val = sizeval*yuvfrac;
		int rc = cb_deque(&queue_frame, yuvfrm);
		if (rc != 0 && app_running == true) {
			return;
		}
		counter += val;
		if(counter == sizeval*yuvfrac){

			convert_yuv_to_rgb_buffer((unsigned char*)(yuvfrm),dfrm,WID,HEI);
			counter = 0;
		}
		if(queue_frame.index == 0){
			waitBuf = false;
		}
	}

	if(app_running == false && queue_frame.index == 0 ){
		//destroyWindow("Video");
		emit stopTimersig();
		waitBuf = false;
		hasWindow = false;
		destroyAllWindows();
		free(dfrm);
		free(yuvfrm);
		//exit(0);
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

int videofrm::convert_yuv_to_rgb_buffer(unsigned char *yuv, unsigned char *rgb, unsigned int width, unsigned int height)
{
#if 1
	if (usecase_sel != 2) {
		cv::Mat mat_src = cv::Mat(height + (height / 2), width, CV_8UC1,yuv );
		//cv::Mat mat_src = cv::Mat(height, width, CV_8UC2,yuv );
		cv::Mat mat_dst = cv::Mat(height, width, CV_8UC3,rgb);
		cv::cvtColor(mat_src, mat_dst, cv::COLOR_YUV2BGR_NV12);
		//cv::cvtColor(mat_src, mat_dst, cv::COLOR_YUV2BGR_YUYV);
		imshow("Video", mat_dst);
	}
	else {
		cv::Mat mat_src = cv::Mat(height, width, CV_8UC3,yuv );
		imshow("Video", mat_src);
	}
#else // below code is to dump frames into file instead of displaying on openCV window using imshow()
	if (usecase_sel != 2) {
		cv::Mat mat_src = cv::Mat(height + (height / 2), width, CV_8UC1,yuv );
		//cv::Mat mat_src = cv::Mat(height, width, CV_8UC2,yuv );
		cv::Mat mat_dst = cv::Mat(height, width, CV_8UC3,rgb);
		//cv::cvtColor(mat_src, mat_dst, cv::COLOR_YUV2BGR_NV12);
		//cv::cvtColor(mat_src, mat_dst, cv::COLOR_YUV2BGR_YUYV);
		//imshow("Video", mat_dst);

        static unsigned int frameCount = 0;
        std::string filename = "output_frm/frame_" + std::to_string(frameCount) + "_" + getTimestamp() + ".raw";
        //cv::imwrite(filename, mat_dst);
        std::ofstream file(filename, std::ios::binary);

        if (file.is_open()) {
            file.write(reinterpret_cast<const char*>(mat_src.data),
                       mat_src.total() * mat_src.elemSize());
            file.close();
            //std::cout << "Frame data saved successfully!" << std::endl;
        } else {
            //std::cerr << "Error opening file!" << std::endl;
        }
        frameCount++;

	}
	else {
		cv::Mat mat_src = cv::Mat(height, width, CV_8UC3,yuv );
		imshow("Video", mat_src);
	}
#endif

	return 0;
}


/****************************************************************************
Copyright(C) 2023-2026 Advanced Micro Devices, Inc. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*****************************************************************************/

#include <errno.h>
#include <fcntl.h>
#include <gst/gst.h>
#include <iostream>
#include <linux/v4l2-subdev.h>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <sys/ioctl.h>
#include <unistd.h>
#include <vector>
#include <glib.h>
#include <pcie_main.h>
#include "pcie_main.h"


#define assert2(cond, ...)                                                     \
    do {                                                                       \
        if (!(cond)) {                                                         \
            int errsv = errno;                                                 \
            fprintf(stderr, "ERROR(%s:%d) : ", __FILE__, __LINE__);            \
            errno = errsv;                                                     \
            fprintf(stderr, __VA_ARGS__);                                      \
            abort();                                                           \
        }                                                                      \
    } while (0)

#define ARRAY_SIZE(array) (sizeof(array) / sizeof((array)[0]))

struct PipelineInfo {
    gboolean single;
    gboolean verbose;
    gboolean performance;
    gboolean passthrough;
    gint channel_num;
    gint width;
    gint height;
    gint media_device;
    gchar *task;
    std::vector<gchar *> tasks;
    gchar *xclbin_location;
    gchar *config_dir;
};

PipelineInfo info = {false,
                     false,
                     false,
                     false,
                     4,
                     3840,
                     2160,
                     1,
                     (gchar *)"yolov3",
                     {(gchar *)"refinedet", (gchar *)"facedetect",
                      (gchar *)"ssd", (gchar *)"yolov3"},
                     (gchar *)"/boot/binary_container_1.xclbin",
                     (gchar *)"/usr/share/vvas/pcie-gst-app"};

struct ChannelInfo {
    int plane_id;
    std::string input_format;
    std::vector<int> coordinate;
    std::string task;
};

char* pipeline_string(int type);

extern "C" {

int Set_config_info(int w, int h, char* task)
{
    info.width = w;
    info.height = h;
    info.task = task;

    return 0;
}

char* Get_pipeline_str(int type)
{
    char* ret = pipeline_string(type);
    return ret;
}

}

std::string get_channel_inference_string(int channel) {
    std::string s = std::to_string(channel);
    std::string result =
	std::string("")
        + " vvas_xinfer preprocess-config="
        + info.config_dir + "/" + info.task
	+ "/preprocess.json  infer-config="
        + info.config_dir + "/" + info.task
	+ "/aiinference.json  "
        + " ! queue " + " ! vvas_xmetaconvert config-location="
        + info.config_dir + "/" + info.task
        + "/drawresult.json ! vvas_xoverlay ! queue "
	;
    return result;
}

std::string get_channel_display_string(int channel) {
    std::string result = " ! perf ! videoconvert !  kmssink driver-name=xlnx plane-id=" +
                         std::string("36") + " sync=false ";
    return result;
}

std::string channel_string(int type) {
    std::string result;

    if (type == VGST_USECASE_TYPE_APPSRC_DPU_TO_KMSSINK) {
	result =  std::string(" queue ! ")
	       + get_channel_inference_string(type);

    }
    else if (type == VGST_USECASE_TYPE_MIPISRC_DPU_TO_HOST)
        result =
	       get_channel_inference_string(type) +
		" !  perf ";

    return result;
}

std::string single_channel_pipeline_string(int type) {
    std::string result = channel_string(type);
    return result;
}

char* pipeline_string(int type) {
    std::string result;
    if (type == VGST_USECASE_TYPE_MIPISRC_DPU_TO_HOST)
        result = single_channel_pipeline_string(type);
    else if (type == VGST_USECASE_TYPE_APPSRC_DPU_TO_KMSSINK)
        result = single_channel_pipeline_string(type);

    result = single_channel_pipeline_string(type);
    return strdup(result.c_str());
}


###############################################################################
# /****************************************************************************
# Copyright(C) 2022-2026 Advanced Micro Devices, Inc. All rights reserved.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# *****************************************************************************/
###############################################################################

bin_PROGRAMS = pcie_gst_app

AM_DEFAULT_SOURCE_EXT = .c .cpp

pcie_gst_app_INC_DIR = ./include
pcie_gst_app_SRC_DIR  = ./src

PCI_CFLAGS_PKG_CONFIG = $$(pkg-config --cflags  gstreamer-1.0 gstreamer-plugins-base-1.0 gstreamer-app-1.0 libdrm libv4l2 libmediactl)
PCI_LIBS_PKG_CONFIG = $$(pkg-config --libs gstreamer-1.0 gstreamer-plugins-base-1.0 gstreamer-app-1.0 gstreamer-video-1.0 libdrm libmediactl libv4l2)


pcie_gst_app_SOURCES = $(pcie_gst_app_SRC_DIR)/pcie_main.c \
                       $(pcie_gst_app_SRC_DIR)/pcie_src.c \
                       $(pcie_gst_app_SRC_DIR)/pcie_abstract.c \
                       $(pcie_gst_app_SRC_DIR)/pcie_sink.c

nodist_pcie_gst_app_SOURCES = $(pcie_gst_app_INC_DIR)/pcie_main.h \
                              $(pcie_gst_app_INC_DIR)/pcie_src.h \
                              $(pcie_gst_app_INC_DIR)/pcie_abstract.h \
                              $(pcie_gst_app_INC_DIR)/pcie_sink.h

pcie_gst_app_CFLAGS = $(PCI_CFLAGS_PKG_CONFIG) -I$(pcie_gst_app_INC_DIR) -g
pcie_gst_app_CPPFLAGS = $(PCI_CFLAGS_PKG_CONFIG) -I$(pcie_gst_app_INC_DIR) -g

pcie_gst_app_LDFLAGS = $(PCI_LIBS_PKG_CONFIG) -lm  -lgstvideo-1.0 -lgstallocators-1.0

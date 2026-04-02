#############################################################################
#   Copyright(C) 2022-2026 Advanced Micro Devices, Inc. All rights reserved.
#   
#   Permission is hereby granted, free of charge, to any person obtaining a copy
#   of this software and associated documentation files (the "Software"), to deal
#   in the Software without restriction, including without limitation the rights
#   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#   copies of the Software, and to permit persons to whom the Software is
#   furnished to do so, subject to the following conditions:
#   
#   The above copyright notice and this permission notice shall be included in
#   all copies or substantial portions of the Software.
#   
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#   THE SOFTWARE.
#############################################################################

#
# PCIe GStreamer application recipe
#
SUMMARY = "PCIe GStreamer application"
DESCRIPTION = "PCIe GStreamer application driven by a PCIe host application to run mipi and file display use-cases with and without filter"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE.md;md5=d2885aee2b0091050ceb0e64fb301bef"

SRC_URI = " file://Makefile.am \
            file://LICENSE.md \
            file://configure.ac \
            file://autogen.sh \
            file://src/pcie_main.c \
            file://src/pcie_src.c \
            file://src/pcie_sink.c \
            file://src/pcie_abstract.c \
            file://src/dpu_pipe.cpp \
            file://include/pcie_main.h \
            file://include/pcie_src.h \
            file://include/pcie_abstract.h \
            file://include/pcie_sink.h \
            file://include/dpu_pipe.h \
          "

S = "${WORKDIR}"

CFLAGS:prepend = "-I${S}/include/ -O0"
CPPFLAGS:prepend = "-I${S}/include/ -O0"

# NOTE: if this software is not capable of being built in a separate build directory
# from the source, you should replace autotools with autotools-brokensep in the
# inherit line
inherit pkgconfig autotools

DEPENDS += "gstreamer1.0 gstreamer1.0-plugins-base gstreamer1.0-plugins-bad v4l-utils libdrm"
# Specify any options you want to pass to the configure script using EXTRA_OECONF:
EXTRA_OECONF = ""
EXTRA_OEMAKE += 'CFLAGS="${CFLAGS} $(pkg-config --cflags glib-2.0 gstreamer-1.0 gstreamer-app-1.0)"'
EXTRA_OEMAKE += 'CPPFLAGS="${CFLAGS} $(pkg-config --cflags glib-2.0 gstreamer-1.0 gstreamer-app-1.0)"'
EXTRA_OEMAKE += 'LDFLAGS="${LDFLAGS} $(pkg-config --libs glib-2.0 gstreamer-1.0 gstreamer-app-1.0)"'

FILES:${PN} += "/usr/bin/pcie_gst_app"

do_install() {
	install -d ${D}${bindir}
	oe_runmake install DESTDIR=${D}
	install -m 0755 ${B}/pcie_gst_app ${D}${bindir}
}

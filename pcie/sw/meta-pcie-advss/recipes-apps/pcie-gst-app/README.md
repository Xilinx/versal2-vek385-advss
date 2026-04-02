#################################################################################
#  Copyright(C) 2022-2026 Advanced Micro Devices, Inc. All rights reserved.
#  
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#  
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#  
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.
#################################################################################

Steps to run the pcie-gst-app
-----------------------------

NOTE: Assuming setup has been done correctly.

1. Launch the host application with required use-case
2. Once host application is running, launch the pcie-gst-app with below command

# pcie-gst-app

# To check the fps information
GST_DEBUG="*pcie*:4" GST_DEBUG_FILE=/run/fps.log pcie-gst-app

# To check latency data
GST_DEBUG="GST_TRACER:7" GST_TRACERS="latency" GST_DEBUG_FILE=/run/latency.log pcie-gst-app

# To check interlatency data
GST_DEBUG="GST_TRACER:7" GST_TRACERS="interlatency" GST_DEBUG_FILE=/run/interlatency.log pcie-gst-app

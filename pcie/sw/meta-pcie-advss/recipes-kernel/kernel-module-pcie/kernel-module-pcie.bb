# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------

# kernel-module-pcie – PCIe endpoint kernel module for VEK385 EDF 2026.06
#
# .ko installed at : /lib/modules/<kver>/extra/xilinx_pci_endpoint.ko
# Auto-load entry  : /etc/modules-load.d/xilinx_pci_endpoint.conf
#
# To pull into your rootfs, add to your image recipe or local.conf:
#   IMAGE_INSTALL:append = " kernel-module-pcie"

SUMMARY = "PCIe endpoint user-register-space kernel driver for VEK385"
DESCRIPTION = "Out-of-tree kernel module for the Xilinx/AMD PCIe endpoint \
register-space IP.  Binds to compatible strings \
'xlnx,pcie-reg-space-1.2' and 'xlnx,pcie-reg-space-v1-0-1.0'. \
Provides /dev/pciep0 and manages 6 × 24.8 MB DMA-coherent buffers \
for 4K RGB888 / NV12 / YUY2 streaming at 30 fps over PCIe."

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PV = "1.0"
PR = "r0"

inherit module

SRC_URI = " \
    file://xilinx_pci_endpoint.c \
    file://Makefile \
"

S = "${WORKDIR}"
B = "${S}"

do_configure[noexec] = "1"

KERNEL_MODULE_AUTOLOAD += "xilinx_pci_endpoint"

# This module is built and verified on VEK385 board
COMPATIBLE_MACHINE = "amd-cortexa78-mali-common"

# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------
# Define variables
SHELL := /bin/bash
current_dir = $(shell pwd)
 
REPO_URL := https://github.com/Xilinx/yocto-manifests.git  
BRANCH := refs/tags/amd-edf-rel-v25.11
MANIFEST := default-edf.xml
XSA:= $(current_dir)/../hw/runs/hdmi_advss_ced_prj/hdmi_advss.xsa
SDTDIR := $(current_dir)/sdt_out_hdmi_advss
#MACHINE_NAME := l20-mrmac
 
# Default target
all: sdt-gen repo-init env-setup build custom-pl-dtsi artifacts


# Generate System Device Tree using
sdt-gen:
	source /proj/xbuilds/2025.2_released/installs/lin64/2025.2/Vivado/settings64.sh && \
	sdtgen << EOF
set_dt_param -dir sdt_out_hdmi_advss -xsa $(XSA) -board_dts versal2-vek385-revb
generate_sdt
exit
EOF

# Initialize the repo
repo-init:
	repo init -u $(REPO_URL) -b $(BRANCH) -m $(MANIFEST)
	repo sync

# Source the build environment
env-setup:
	source edf-init-build-env && \
	sed -i "/^TMPDIR/d" conf/local.conf && \
	echo "TMPDIR = \"/tmp/$(shell whoami)/tmp_$(shell date +%Y%m%d_%H%M%S)_hdmi_advss\"" >> conf/local.conf && \
	gen-machineconf parse-sdt --template ../sources/meta-amd-adaptive-socs/meta-amd-adaptive-socs-bsp/conf/machineyaml/versal-2ve-2vm-vek385-revb-sdt-seg.yaml --hw-description $(SDTDIR) \

# Build the edf-ospi and edf-linux-disk-image 
build:
	source edf-init-build-env && \
	MACHINE=versal-2ve-2vm-vek385-revb-sdt-seg bitbake edf-ospi && \
	MACHINE=amd-cortexa78-mali-common bitbake edf-linux-disk-image

# Apply custom changes to pl.dtsi if hdmi_custom.dtsi exists
custom-pl-dtsi:
	@echo "Checking for hdmi_custom.dtsi to apply to pl.dtsi..."
	@if [ -f "hdmi_custom.dtsi" ]; then \
		echo "Applying hdmi_custom.dtsi to pl.dtsi..."; \
		if [ -f "./build/conf/dts/versal-2ve-2vm-vek385-revb-sdt-seg/pl-overlay-full/pl.dtsi" ]; then \
			echo "Appending hdmi_custom.dtsi content to pl.dtsi..."; \
			echo "" >> ./build/conf/dts/versal-2ve-2vm-vek385-revb-sdt-seg/pl-overlay-full/pl.dtsi; \
			echo "/* HDMI customizations from hdmi_custom.dtsi */" >> ./build/conf/dts/versal-2ve-2vm-vek385-revb-sdt-seg/pl-overlay-full/pl.dtsi; \
			cat hdmi_custom.dtsi >> ./build/conf/dts/versal-2ve-2vm-vek385-revb-sdt-seg/pl-overlay-full/pl.dtsi; \
			echo "hdmi_custom.dtsi applied successfully."; \
		else \
			echo "Error: pl.dtsi file not found. Build may have failed."; \
			exit 1; \
		fi; \
	else \
		echo "No hdmi_custom.dtsi file found. Skipping HDMI customization step."; \
	fi
	@echo "Checking for system_user.dtsi to apply to pl.dtsi..."
	@if [ -f "system_user.dtsi" ]; then \
		echo "Applying system_user.dtsi to pl.dtsi..."; \
		if [ -f "./build/conf/dts/versal-2ve-2vm-vek385-revb-sdt-seg/pl-overlay-full/pl.dtsi" ]; then \
			echo "Appending system_user.dtsi content to pl.dtsi..."; \
			echo "" >> ./build/conf/dts/versal-2ve-2vm-vek385-revb-sdt-seg/pl-overlay-full/pl.dtsi; \
			echo "/* System user customizations from system_user.dtsi */" >> ./build/conf/dts/versal-2ve-2vm-vek385-revb-sdt-seg/pl-overlay-full/pl.dtsi; \
			cat system_user.dtsi >> ./build/conf/dts/versal-2ve-2vm-vek385-revb-sdt-seg/pl-overlay-full/pl.dtsi; \
			echo "system_user.dtsi applied successfully."; \
		else \
			echo "Error: pl.dtsi file not found. Build may have failed."; \
			exit 1; \
		fi; \
	else \
		echo "No system_user.dtsi file found. Skipping system user customization step."; \
	fi
# copy the artifacts to images directory 
artifacts:
	@TMPDIR=$$(grep '^TMPDIR' ./build/conf/local.conf | cut -d '=' -f2 | tr -d ' "') && \
	echo "Copying from $$TMPDIR..." && \
	mkdir -p ./images && \
	cp $$TMPDIR/deploy/images/versal-2ve-2vm-vek385-revb-sdt-seg/edf-ospi-versal-2ve-2vm-vek385-revb-sdt-seg.bin ./images/ && \
	cp $$TMPDIR/deploy/images/amd-cortexa78-mali-common/edf-linux-disk-image-amd-cortexa78-mali-common.rootfs.wic.xz ./images/ && \
	echo "Copying pl.dtsi..." && \
	cp  $(current_dir)/conf/dts/versal-2ve-2vm-vek385-revb-sdt-seg/pl-overlay-full/pl.dtsi ./images/
	

# Clean the build
clean:
	bitbake -c cleanall edf-ospi

.PHONY: all sdt-gen repo-init env-setup build custom-pl-dtsi artifacts clean



# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------

CP = cp -f

PWD = $(shell readlink -f .)

HWDIR = $(PWD)/hw
SWDIR = $(PWD)/sw

.PHONY: help
help:
	@echo 'Usage:'
	@echo ''
	@echo '  make all'
	@echo '    Build both hardware (hw) and software (sw) components.'
	@echo ''
	@echo '  make hw'
	@echo '    Build hardware components (Vivado design).'
	@echo ''
	@echo '  make sw'
	@echo '    Build software components (Yocto images).'
	@echo ''
	@echo '  make artifacts'
	@echo '    Collect all build artifacts from hw and sw builds.'
	@echo ''
	@echo '  make docs'
	@echo '    Generate html documentation using sphinx'
	@echo ''
	@echo '  make clean'
	@echo '    Clean runs'
	@echo ''

.PHONY: all
all: hw sw

.PHONY: hw
hw:
	@echo 'Building hardware components...'
	$(MAKE) -C $(HWDIR) all

.PHONY: sw
sw: 
	@echo 'Building software components...'
	$(MAKE) -C $(SWDIR) all

.PHONY: docs
docs:
	$(MAKE) -C docs html


.PHONY: clean
clean:
	@echo 'Cleaning hardware components...'
	$(MAKE) -C $(HWDIR) clean
	@echo 'Cleaning software components...'
	$(MAKE) -C $(SWDIR) clean
	
.PHONY: artifacts
artifacts: hw sw
	@echo 'Collecting artifacts from both hw and sw...'
	mkdir -p artifacts
	# Collect hardware artifacts
	if [ -d "$(HWDIR)" ]; then \
		echo "Copying hardware artifacts..."; \
		cp -f $(HWDIR)/runs/hdmi/versal_gen2_platform.xsa ./artifacts/ 2>/dev/null || true; \
		cp -f $(HWDIR)/*.log ./artifacts/ 2>/dev/null || true; \
		cp -f $(HWDIR)/*.jou ./artifacts/ 2>/dev/null || true; \
	fi
	# Collect software artifacts
	if [ -d "$(SWDIR)" ]; then \
		echo "Copying software artifacts..."; \
		cp -f $(SWDIR)/images/edf-ospi-versal-2ve-2vm-vek385-revb-sdt-seg.bin ./artifacts/ 2>/dev/null || true; \
		cp -f $(SWDIR)/images/edf-linux-disk-image-amd-cortexa78-mali-common.rootfs.wic.xz ./artifacts/ 2>/dev/null || true; \
		cp -f $(SWDIR)/images/pl.dtsi ./artifacts/ 2>/dev/null || true; \
	fi
	@echo 'Artifacts collection complete!'

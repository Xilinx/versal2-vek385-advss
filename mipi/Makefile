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


.PHONY: clean
clean:
	@echo 'Cleaning hardware components...'
	$(MAKE) -C $(HWDIR) clean
	@echo 'Cleaning software components...'
	$(MAKE) -C $(SWDIR) clean

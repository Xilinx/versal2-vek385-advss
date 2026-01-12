# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------
SHELL := /bin/bash

RM = rm -rf
PWD = $(shell readlink -f .)

VIVADO = $(XILINX_VIVADO)/bin/vivado
JOBS ?= 8
VIV_PRJ_DIR = $(PWD)/runs/hdmi_advss_ced_prj
VIV_SCRIPTS_DIR = scripts

VIV_DESIGN = versal_gen2_platform
VIV_XSA = $(VIV_PRJ_DIR)/$(VIV_DESIGN).xsa
VIV_SRC = $(VIV_SCRIPTS_DIR)/main.tcl

.PHONY: help
help:
	@echo 'Usage:'
	@echo ''
	@echo '  make xsa [JOBS=<n>]'
	@echo '    Generate xsa'
	@echo ''
	@echo '  Options:'
	@echo '    JOBS: optional param to set number of synthesis jobs (default: 8)'
	@echo ''

.PHONY: all
all: xsa

xsa: $(VIV_XSA)
$(VIV_XSA): $(VIV_SRC)
	$(VIVADO) -mode batch -notrace -source $(VIV_SRC) -tclargs -jobs $(JOBS)
	@grep $(VIV_TIMING_ERROR) vivado.log; if [ $$? = 0 ]; then exit 1; fi

.PHONY: clean
clean:
	$(RM) $(VIV_PRJ_DIR) vivado* .Xil *dynamic* *.log *.xpe .crashReporter hd_visual *.swp
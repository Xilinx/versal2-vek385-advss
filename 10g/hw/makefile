# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------
SHELL := /bin/bash

RM = rm -rf
PWD = $(shell readlink -f .)

VIVADO = $(XILINX_VIVADO)/bin/vivado
SDTGEN = $(XILINX_VIVADO)/bin/sdtgen
JOBS ?= 8
VIV_PRJ_DIR = $(PWD)/runs/MMI_10G
VIV_SCRIPTS_DIR = scripts

VIV_TIMING_ERROR = "CRITICAL WARNING: \[Timing 38-282\] The design failed to meet the timing requirements"

VIV_DESIGN = MMI_10G
VIV_XSA = $(VIV_PRJ_DIR)/$(VIV_DESIGN).xsa
VIV_SRC = $(VIV_SCRIPTS_DIR)/main.tcl

SDT_SRC = $(PWD)/gen_sdt.tcl

.PHONY: help
help:
	@echo 'Usage:'
	@echo ''
	@echo '  make xsa [JOBS=<n>]'
	@echo '    Generate xsa '
	@echo ''
	@echo '  make sdt'
	@echo '    Generate sdt files'
	@echo ''
	@echo '  make all [JOBS=<n>]'
	@echo '    Generate xsa and sdt files'
	@echo ''
	@echo '  Options:'
	@echo '    JOBS: optional param to set number of synthesis jobs (default: 8)'
	@echo ''

.PHONY: all
all: xsa sdt

xsa: $(VIV_XSA)
$(VIV_XSA): $(VIV_SRC)
	$(VIVADO) -mode batch -notrace -source $(VIV_SRC) -tclargs -jobs $(JOBS)
	@grep $(VIV_TIMING_ERROR) vivado.log; if [ $$? = 0 ]; then exit 1; fi

sdt: $(SDT_SRC) $(VIV_XSA)
	$(SDTGEN) $(SDT_SRC) -xsa_path $(VIV_XSA)

.PHONY: clean
clean:
	$(RM) $(VIV_PRJ_DIR) vivado* .Xil *dynamic* *.log *.xpe .crashReporter hd_visual *.swp

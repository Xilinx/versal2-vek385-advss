# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------

RM = rm -rf
VIVADO = $(XILINX_VIVADO)/bin/vivado

NPROC := $(shell nproc)
JOBS := $(shell echo $$(( $(NPROC) - 2 )))

DESIGN ?= pcie

# valid designs
DESIGN_LIST = pcie


.PHONY: help all clean 
help:
	@echo 'Usage:'
	@echo ''
	@echo '  make all DESIGN=<design> '
	@echo '    Generate xsa for platform generation'
	@echo '    Valid options for DESIGN: ${DESIGN_LIST}'
	@echo ''

all: runs/pcie/pcie.xsa

runs/pcie/pcie.xsa:
	@if [ -d runs ]; then echo "Removing existing runs/ ..."; $(RM) runs; fi
	${VIVADO} -mode batch -s ./scripts/main.tcl -tclargs -jobs $(JOBS)

clean:
	rm -rf runs README.hw vivado*.log vivado*.jou

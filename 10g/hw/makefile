# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------



RM = rm -rf
VIVADO = $(XILINX_VIVADO)/bin/vivado

NPROC := $(shell nproc)
JOBS := $(shell echo $$(( $(NPROC) - 2 )))

DESIGN ?= MMI_10g

# valid designs
DESIGN_LIST = MMI_10g


.PHONY: help
help:
	@echo 'Usage:'
	@echo ''
	@echo '  make all DESIGN=<design> '
	@echo '    Generate xsa for platform generation'
	@echo '    Valid options for DESIGN: ${DESIGN_LIST}'
	@echo ''

.PHONY: all
all: runs/MMI_10G/MMI_10G.xsa

.PHONY: runs/MMI_10G/MMI_10G.xsa
runs/MMI_10G/MMI_10G.xsa:
	@if [ -d runs ]; then echo "Removing existing runs/ ..."; $(RM) runs; fi
	${VIVADO} -mode batch -s ./scripts/main.tcl -tclargs -jobs $(JOBS)

.PHONY: clean
clean:
	$(RM) runs vivado*.log vivado*.jou *.str README.hw address_map.json

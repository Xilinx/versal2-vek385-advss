# ==============================================================================
# Makefile for EDF Yocto Build Automation
# Platform: VEK385 with HDMI Design
# ==============================================================================

#===============================================================================
# Build Configuration Variables
#===============================================================================

# Use current directory where Makefile is running
WORK_DIR := $(shell pwd)
BUILD_BASE := $(WORK_DIR)

# Yocto repository configuration (clones to current path)
REPO_URL := https://storage.googleapis.com/git-repo-downloads/repo
REPO_MANIFEST_URL := https://github.com/Xilinx/yocto-manifests.git
REPO_BRANCH := refs/tags/amd-edf-rel-v25.11
REPO_MANIFEST_FILE := default-edf.xml
YOCTO_DIR := $(BUILD_BASE)/yocto-edf-25.11

# Build target configuration
MACHINE := versal-2ve-2vm-vek385-revb-sdt-seg
SDT_DIR := $(BUILD_BASE)/../hw/hdmi_sdt
IMAGE_OSPI := edf-ospi
IMAGE_ROOTFS := edf-linux-disk-image

VEK385_TEMPLATE := ../sources/meta-amd-adaptive-socs/meta-amd-adaptive-socs-bsp/conf/machineyaml/versal-2ve-2vm-vek385-revb-sdt-seg.yaml

# Detect if current path is on NFS filesystem
# Checks for 'nfs' or 'nfs4' filesystem type
IS_NFS := $(shell df -T $(WORK_DIR) 2>/dev/null | awk 'NR==2 {print $$2}' | grep -qE '^nfs' && echo "yes" || echo "no")

# Set YOCTO_TMP_DIR based on NFS detection
# NFS builds should use /scratch
ifeq ($(IS_NFS),yes)
    YOCTO_TMP_DIR := /scratch/$(USER)/yocto_tmp
    $(info *** NFS filesystem detected ***)
    $(info *** Using /scratch for TMP_DIR: $(YOCTO_TMP_DIR) ***)
else
    YOCTO_TMP_DIR := $(BUILD_BASE)/tmp
    $(info *** Local filesystem detected ***)
    $(info *** Using local TMP_DIR: $(YOCTO_TMP_DIR) ***)
endif

# Build environment
SHELL := /bin/bash

# Parallel build jobs (adjust based on your system)
PARALLEL_MAKE ?= $(shell nproc)
BB_NUMBER_THREADS ?= $(shell nproc)

#===============================================================================
# Color output for better readability
#===============================================================================

COLOR_RESET := \033[0m
COLOR_BOLD := \033[1m
COLOR_GREEN := \033[32m
COLOR_YELLOW := \033[33m
COLOR_BLUE := \033[34m
COLOR_CYAN := \033[36m

#===============================================================================
# Phony Targets
#===============================================================================

.PHONY: all setup sync configure gen-machine build-ospi build-rootfs build images \
        clean-machineconf

#===============================================================================
# Default Target
#===============================================================================

all: build
	@echo ""
	@printf "%b\n" "$(COLOR_GREEN)$(COLOR_BOLD)================================================$(COLOR_RESET)"
	@printf "%b\n" "$(COLOR_GREEN)$(COLOR_BOLD)  Build Complete!$(COLOR_RESET)"
	@printf "%b\n" "$(COLOR_GREEN)$(COLOR_BOLD)================================================$(COLOR_RESET)"
	@echo ""
	@echo "Output images location:"
	@echo "  $(YOCTO_TMP_DIR)/deploy/images/$(MACHINE)/"
	@echo ""

#===============================================================================
# Setup: Create directories and download repo tool
#===============================================================================

setup:
	@if [ ! -f $(BUILD_BASE)/repo ]; then \
		printf "%b\n" "$(COLOR_CYAN)$(COLOR_BOLD)=== Setting up build environment ===$(COLOR_RESET)"; \
		echo "Downloading repo tool from Google..."; \
		curl -s -o $(BUILD_BASE)/repo $(REPO_URL) || { \
			printf "%b\n" "$(COLOR_YELLOW)Error: Failed to download repo tool$(COLOR_RESET)"; \
			exit 1; \
		}; \
		chmod +x $(BUILD_BASE)/repo; \
		echo "Repo tool downloaded successfully"; \
	else \
		echo "Repo tool already exists at $(BUILD_BASE)/repo"; \
	fi
	@echo ""
	@printf "%b\n" "$(COLOR_GREEN)Setup complete$(COLOR_RESET)"
	@echo ""

#===============================================================================
# Sync: Initialize and sync Yocto repositories
#===============================================================================

sync: setup
	@if [ ! -d $(YOCTO_DIR)/.repo ]; then \
		printf "%b\n" "$(COLOR_CYAN)$(COLOR_BOLD)=== Syncing Yocto repositories ===$(COLOR_RESET)"; \
		echo "Initializing repo in $(YOCTO_DIR)..."; \
		mkdir -p $(YOCTO_DIR); \
		cd $(YOCTO_DIR) && $(BUILD_BASE)/repo init \
			-u $(REPO_MANIFEST_URL) \
			-b $(REPO_BRANCH) \
			-m $(REPO_MANIFEST_FILE) || { \
			printf "%b\n" "$(COLOR_YELLOW)Error: repo init failed$(COLOR_RESET)"; \
			exit 1; \
		}; \
		echo "Repo initialized successfully"; \
	else \
		echo "Repo already initialized in $(YOCTO_DIR)"; \
	fi
	@if [ ! -d $(YOCTO_DIR)/sources ]; then \
		echo "Syncing repositories (this may take 10-30 minutes on first run)..."; \
		cd $(YOCTO_DIR) && $(BUILD_BASE)/repo sync -j$(PARALLEL_MAKE) || { \
			printf "%b\n" "$(COLOR_YELLOW)Error: repo sync failed$(COLOR_RESET)"; \
			echo "Try running: cd $(YOCTO_DIR) && $(BUILD_BASE)/repo sync"; \
			exit 1; \
		} \
	fi
	@printf "%b\n" "$(COLOR_GREEN)Repository sync complete$(COLOR_RESET)"

#===============================================================================
# Configure: Set up build environment variables
#===============================================================================

configure: sync
	@if [ ! -f $(YOCTO_DIR)/edf-init-build-env ]; then \
		printf "%b\n" "$(COLOR_YELLOW)Error: edf-init-build-env not found at $(YOCTO_DIR)/edf-init-build-env$(COLOR_RESET)"; \
		echo "Please ensure repo sync completed successfully"; \
	fi

	@if [ ! -f $(YOCTO_DIR)/build/conf/local.conf ]; then \
		printf "%b\n" "$(COLOR_CYAN)$(COLOR_BOLD)=== Configuring build environment ===$(COLOR_RESET)"; \
		echo ""; \
		echo "Sourcing edf-init-build-env and configuring local.conf..."; \
		cd $(YOCTO_DIR); \
		source edf-init-build-env; \
		if [ '$(IS_NFS)' = 'yes' ]; then \
			if ! grep -q '^TMPDIR = ' conf/local.conf 2>/dev/null; then \
				echo 'TMPDIR = "$(YOCTO_TMP_DIR)"' >> conf/local.conf; \
				echo '  Added TMPDIR = $(YOCTO_TMP_DIR) to local.conf'; \
			else \
				sed -i 's|^TMPDIR = .*|TMPDIR = "$(YOCTO_TMP_DIR)"|' conf/local.conf; \
				echo '  Updated TMPDIR = $(YOCTO_TMP_DIR) in local.conf'; \
			fi; \
		else \
			echo '  Local filesystem - using default TMPDIR from conf/local.conf'; \
		fi && \
		if ! grep -q '^PARALLEL_MAKE = ' conf/local.conf 2>/dev/null; then \
			echo 'PARALLEL_MAKE = "-j $(PARALLEL_MAKE)"' >> conf/local.conf; \
			echo '  Set PARALLEL_MAKE to -j$(PARALLEL_MAKE)'; \
		fi && \
		if ! grep -q '^BB_NUMBER_THREADS = ' conf/local.conf 2>/dev/null; then \
			echo 'BB_NUMBER_THREADS = "$(BB_NUMBER_THREADS)"' >> conf/local.conf; \
			echo '  Set BB_NUMBER_THREADS to $(BB_NUMBER_THREADS)'; \
		fi && \
		if ! grep -q 'IMAGE_INSTALL:append = ' conf/local.conf 2>/dev/null; then \
			echo 'IMAGE_INSTALL:append = "kernel-module-hdmi21"' >> conf/local.conf; \
			echo 'hdmi modules added in the local.conf '; \
		fi; \
	else \
		echo ""; \
		echo "conf/local.conf file exist"; \
	fi

	@echo "Build configuration:"
	@echo "  Working directory: $(WORK_DIR)"
	@echo "  Yocto location:    $(YOCTO_DIR)"
	@echo "  TMP_DIR:           $(YOCTO_TMP_DIR)"
	@echo "  NFS detected:      $(IS_NFS)"
	@echo "  PARALLEL_MAKE:     -j$(PARALLEL_MAKE)"
	@echo "  BB_NUMBER_THREADS: $(BB_NUMBER_THREADS)"
	@echo ""
	@printf "%b\n" "$(COLOR_GREEN)Build environment configuration complete$(COLOR_RESET)"
	@echo ""


#===============================================================================
# Generate Machine: Parse SDT and generate machine configuration
#===============================================================================

gen-machine: configure
	@if [ ! -d $(YOCTO_DIR)/build/conf/dts ]; then \
		printf "%b\n" "$(COLOR_CYAN)$(COLOR_BOLD)=== Generating machine configuration ===$(COLOR_RESET)"; \
		echo ""; \
		echo "Machine:      $(MACHINE)"; \
		echo ""; \
		echo "Parsing hardware description and generating device tree..."; \
		cd $(YOCTO_DIR); \
		source edf-init-build-env; \
		gen-machineconf parse-sdt --template $(VEK385_TEMPLATE) --hw-description $(SDT_DIR) || { \
			printf "%b\n" "$(COLOR_YELLOW)Error: Failed to generate machine configuration$(COLOR_RESET)"; \
			exit 1; \
		}; \
		echo ""; \
		echo "Generated machine file as $(YOCTO_DIR)/build/conf/machine/versal-2ve-2vm-vek385-revb-sdt-seg.conf"; \
		ls -lh $(YOCTO_DIR)/build/output 2>/dev/null || echo "  (directory listing unavailable)"; \
		echo ""; \
		printf "%b\n" "$(COLOR_GREEN)Machine configuration generated: $(MACHINE)$(COLOR_RESET)"; \
		echo ""; \
	else \
		echo ""; \
		echo "gen-machineconf already configured"; \
	fi
	@printf "%b\n" "$(COLOR_GREEN)gen-machineconf complete$(COLOR_RESET)"


#===============================================================================
# Build OSPI: Build OSPI boot image
#===============================================================================

build-ospi: gen-machine
	@printf "%b\n" "$(COLOR_CYAN)$(COLOR_BOLD)=== Building OSPI boot image ===$(COLOR_RESET)"
	@echo ""
	@echo "Target:  $(IMAGE_OSPI)"
	@echo "Machine: $(MACHINE)"
	@echo ""
	@cd $(YOCTO_DIR) && \
		bash -c "source edf-init-build-env && \
		MACHINE=$(MACHINE) bitbake $(IMAGE_OSPI)" || { \
		printf "%b\n" "$(COLOR_YELLOW)Error: OSPI image build failed$(COLOR_RESET)"; \
		exit 1; \
	}
	@echo ""
	@printf "%b\n" "$(COLOR_GREEN)OSPI image build complete$(COLOR_RESET)"
	@echo ""

#===============================================================================
# Build RootFS: Build root filesystem and kernel image
#===============================================================================

build-rootfs: configure
	@printf "%b\n" "$(COLOR_CYAN)$(COLOR_BOLD)=== Building root filesystem ===$(COLOR_RESET)"
	@echo ""
	@echo "Target:       $(IMAGE_ROOTFS)"
	@echo "Machine:      $(MACHINE)"
	@echo ""
	@cd $(YOCTO_DIR) && \
		bash -c "source edf-init-build-env && \
		MACHINE=amd-cortexa78-mali-common bitbake $(IMAGE_ROOTFS)" || { \
		printf "%b\n" "$(COLOR_YELLOW)Error: Root filesystem build failed$(COLOR_RESET)"; \
		exit 1; \
	}
	@echo ""
	@printf "%b\n" "$(COLOR_GREEN)Root filesystem build complete$(COLOR_RESET)"
	@echo ""

#===============================================================================
# Copy Images: Copy built images to local images directory
#===============================================================================
artifacts: build-ospi build-rootfs
	@printf "%b\n" "$(COLOR_CYAN)$(COLOR_BOLD)=== Copying images to local directory ===$(COLOR_RESET)"
	@mkdir -p $(BUILD_BASE)/artifacts
	@set -e; \
	if [ "$(IS_NFS)" = "yes" ]; then \
		DEPLOY_DIR_OSPI="$(YOCTO_TMP_DIR)/deploy/images/$(MACHINE)"; \
		DEPLOY_DIR_ROOTFS="$(YOCTO_TMP_DIR)/deploy/images/amd-cortexa78-mali-common"; \
	else \
		DEPLOY_DIR_OSPI="$(YOCTO_DIR)/build/tmp/deploy/images/$(MACHINE)"; \
		DEPLOY_DIR_ROOTFS="$(YOCTO_DIR)/build/tmp/deploy/images/amd-cortexa78-mali-common"; \
	fi; \
	OSPI_SRC="$$DEPLOY_DIR_OSPI/edf-ospi-$(MACHINE).bin"; \
	ROOTFS_SRC="$$DEPLOY_DIR_ROOTFS/edf-linux-disk-image-amd-cortexa78-mali-common.rootfs.wic.xz"; \
	echo "OSPI Source:   $$OSPI_SRC"; \
	echo "RootFS Source: $$ROOTFS_SRC"; \
	echo ""; \
	if [ -f "$$OSPI_SRC" ]; then \
		cp "$$OSPI_SRC" $(BUILD_BASE)/artifacts/; \
		printf "%b\n" "$(COLOR_GREEN)✓$(COLOR_RESET) Copied edf-ospi-$(MACHINE).bin"; \
	else \
		printf "%b\n" "$(COLOR_YELLOW)⚠$(COLOR_RESET) OSPI NOT FOUND"; \
	fi; \
	if [ -f "$$ROOTFS_SRC" ]; then \
		cp "$$ROOTFS_SRC" $(BUILD_BASE)/artifacts/; \
		printf "%b\n" "$(COLOR_GREEN)✓$(COLOR_RESET) Copied edf-linux-disk-image-amd-cortexa78-mali-common.rootfs.wic.xz"; \
	else \
		printf "%b\n" "$(COLOR_YELLOW)⚠$(COLOR_RESET) RootFS NOT FOUND"; \
	fi; \
	PL_DTSI="$(YOCTO_DIR)/build/conf/dts/$(MACHINE)/pl-overlay-full/pl.dtsi"; \
	if [ -f "$$PL_DTSI" ]; then \
		cp "$$PL_DTSI" $(BUILD_BASE)/artifacts/pl.dtsi; \
		printf "%b\n" "$(COLOR_GREEN)✓$(COLOR_RESET) Copied pl.dtsi"; \
	else \
		printf "%b\n" "$(COLOR_YELLOW)⚠$(COLOR_RESET) pl.dtsi not found: $(YOCTO_DIR)/build/conf/dts/$(MACHINE)/pl-overlay-full/pl.dtsi"; \
	fi
	@echo ""
	@ls -lh $(BUILD_BASE)/artifacts/ 2>/dev/null
	@printf "%b\n" "$(COLOR_GREEN)Images copy complete$(COLOR_RESET)"

#===============================================================================
# Build: Build both OSPI and RootFS images
#===============================================================================

build: artifacts
	@printf "%b\n" "$(COLOR_GREEN)$(COLOR_BOLD)=== All images built successfully ===$(COLOR_RESET)"
	@echo ""
	@echo "Output directory:"
	@if [ "$(IS_NFS)" = "yes" ]; then \
		echo "  $(YOCTO_TMP_DIR)/deploy/images/$(MACHINE)/"; \
	else \
		echo "  $(YOCTO_DIR)/build/tmp/deploy/images/$(MACHINE)/"; \
	fi
	@echo ""
	@echo "Local images directory:"
	@echo "  $(BUILD_BASE)/artifacts/"
	@echo ""
	@echo "Key files copied:"
	@echo "  - ospi.bin (OSPI boot image)"
	@echo "  - edf-linux.wic.xz (rootfs)"
	@echo "  - pl.dtsi (device tree overlay)"
	@echo ""

#===============================================================================
# Clean Machine Configuration: Remove generated machine config files
#===============================================================================

clean-machineconf:
	@printf "%b\n" "$(COLOR_CYAN)$(COLOR_BOLD)=== Cleaning machine configuration ===$(COLOR_RESET)"
	@if [ -d "$(YOCTO_DIR)/build/conf/dts" ]; then \
		rm -rf "$(YOCTO_DIR)/build/conf/dts"; \
		printf "%b\n" "$(COLOR_GREEN)Removed directory: $(YOCTO_DIR)/build/conf/dts$(COLOR_RESET)"; \
	else \
		printf "%b\n" "$(COLOR_YELLOW)Directory does not exist: $(YOCTO_DIR)/build/conf/dts$(COLOR_RESET)"; \
	fi
	@echo ""
	@printf "%b\n" "$(COLOR_GREEN)Machine configuration cleanup complete$(COLOR_RESET)"
	@echo ""



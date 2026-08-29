## License

# Copyright(C) 2026 Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT


## PCIe ADVSS Hardware Design

The PCIe ADVSS hardware design targets:
- **MIPI CSI2Rx → ISP → PS DP Display passthrough pipeline** at **4Kp30 @ 8bpp**
- **MIPI CSI2Rx → ISP → PCIe → Host QT application Display pipeline** at **4Kp30 @ 8bpp**

The hardware design is targeted for the **VEK385 Rev-B1** board.

### Tools Version

- **Vivado™ 2026.1**

### Build Instructions

The following sections describe the steps required to build the hardware design and software artifacts.

#### Steps to build the hardware design

1. Navigate to the `pcie/hw` folder.
2. Run the following command:
   ```bash
   make all
3. The output XSA file will be available in `pcie/hw/runs/pcie/`

#### Steps to build software components

1. Navigate to the pcie/sw folder.
2. Run the following command:
   ```bash
   make build
3. Output images will be available in `/pcie/sw/artifacts` directory.

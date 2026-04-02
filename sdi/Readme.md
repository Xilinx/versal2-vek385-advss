## License

# Copyright(C) 2026 Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT


## 12G SDI ADVSS Hardware Design

The 12G SDI ADVSS hardware design targets:
- **SDI RX → SDI TX passthrough pipeline** at **8Kp30 @ 8bpp**
- **SDI RX → VCU2 encode → decode → SDI TX pipeline** at **4Kp30**

The hardware design is targeted for the **VEK385 Rev-B1** board.

### Tools Version

- **Vivado™ 2025.2**

### Build Instructions

The following sections describe the steps required to build the hardware design and software artifacts.

#### Steps to build the hardware design

1. Navigate to the `sdi/hw` folder.
2. Run the following command:
   ```bash
   make all
3. The output XSA file will be available in `sdi/hw/runs/sdi/`

#### Steps to build software components
Please follow the SDI wiki page to build SW boot images using belowe commands:
1. Apply [AR](https://adaptivesupport.amd.com/s/article/000039987?language=en_US) by following instruction to fix I2C and SPI0 aliasing issue.
2. Navigate to the sdi/sw folder.
3. Run the following command:
   ```bash
   make artifacts
4. Output images will be available in `/pcie/sw/artifacts` directory.

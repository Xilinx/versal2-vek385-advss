## License

#Copyright (C) 2026 Advanced Micro Devices, Inc.
#SPDX-License-Identifier: MIT


## MIPI ADVSS Hardware Design

The MIPI ADVSS supports below pipelines

- **MIPI-4x Capture + ISP-MCM +Mixer+HDMI-2.1 Tx@4kp60**

The hardware design is targeted for the **VEK385 Rev-B1  board**.

### Tools Version

- **Vivado™ 2025.2**

### Build Instructions

To build the hardware design and system design tree:

1. Navigate to the `\mipi\hw` folder.
2. Run the following command:
   ```bash
   make all

3. The output XSA file will be available in `\mipi\hw\runs\MIPI\`

## Steps to build software components

To build the software artifats:

1. Navigate to the \mipi\sw folder.
2. Run the following command:
   ```bash
   make artifacts

3. The output boot images will be available in `\mipi\sw\artifacts`

## License

#Copyright (C) 2026 Advanced Micro Devices, Inc.
#SPDX-License-Identifier: MIT


## 10g ADVSS Hardware Design

The 10g ADVSS hardware design targets:
- **MIPI-4x Capture + ISP-Non-MCM +Mixer + HDMI-2.1 Tx@8kp30
- **MIPI-4x Capture + ISP-Non-MCM +VCU encode + decode + Mixer +HDMI-2.1 Tx@8kp30
- **MIPI-4x Capture + ISP-Non-MCM +VCU encode + 10g streamout 

The hardware design is targeted for the **VEK385 Rev-B1 board**.

### Tools Version

- **Vivado™ 2025.2**

### Build Instructions

To build the hardware design:

1. Navigate to the `\10g\hw` folder.
2. Run the following command:
   ```bash
   make all

3. The output XSA file will be available in `\10g\hw\runs\MMI_10g\`

## Steps to build software components

To build the software artifats:

1. Navigate to the \10g\sw folder.
2. Run the following command:
   ```bash
   make artifacts

3. The output boot images will be available in `\10g\sw\artifacts`

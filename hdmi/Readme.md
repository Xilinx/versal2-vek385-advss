## License

#Copyright (C) 2026 Advanced Micro Devices, Inc.
#SPDX-License-Identifier: MIT


## HDMI ADVSS Hardware Design

The HDMI ADVSS hardware design targets:
- **HDMI 2.1 RX → HDMI 2.1 TX passthrough pipeline** at **8Kp30 @ 8bpp**
- **HDMI 2.1 RX → VCU encode → decode → HDMI 2.1 TX pipeline** at **4Kp60 @ 8bpp**

The hardware design is targeted for the **VEK385 Rev-B board**.

### Tools Version

- **Vivado™ 2025.2**

### Build Instructions

To build the hardware design and sdt generation:

1. Navigate to the `\hdmi\hw` folder.
2. Run the following command:
   ```bash
   make all

3. The output XSA file will be available in `\hdmi\hw\runs\hdmi\`



## Build Instructions to build software components 

To build the software artifats:

1. Navigate to the `\hdmi\sw` folder.
2. Run the following command:
   ```bash
   make all
   ```
3. The output boot images will be available in `\hdmi\sw\yocto-edf-25.11\build\tmp\deploy\images\versal-2ve-2vm-vek385-revb-sdt-seg\`

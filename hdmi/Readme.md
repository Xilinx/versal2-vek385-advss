## License

#Copyright (C) 2026 Advanced Micro Devices, Inc.
#SPDX-License-Identifier: MIT


## HDMI ADVSS Hardware Design

The HDMI ADVSS hardware design targets:
- **HDMI-2.1 Rx → VPSS → FBWR → DDR → FBRD → HDMI-2.1 Tx passthrough pipeline** at **8Kp30 @ 8bpp**
- **HDMI-2.1 RX → VPSS → FBWR → DDR → VCU2 Encode → DDR → VCU2 Decode → DDR → FBRD → HDMI-2.1 TX pipeline** at **4Kp60 @ 8bpp**

The hardware design is targeted for the **VEK385 Rev-B1 board**.

### Tools Version

- **Vivado™ 2026.1**

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
   make artifacts
   ```
3. The output boot images will be available in `\hdmi\sw\artifacts`

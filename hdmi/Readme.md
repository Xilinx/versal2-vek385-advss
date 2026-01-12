# HDMI ADVSS Hardware Design

## Introduction

The HDMI ADVSS hardware design targets:
- **HDMI 2.1 RX → HDMI 2.1 TX passthrough pipeline** at **8Kp30 @ 8bpp**
- **HDMI 2.1 RX → VCU encode → decode → HDMI 2.1 TX pipeline** at **4Kp60 @ 8bpp**

The hardware design is targeted for the **VEK385 Rev-B board**.

## Tools Version

- **Vivado™ 2025.2**

## Build Instructions

To build the hardware design:

1. Navigate to the `\hdmi\hw` folder.
2. Run the following command:
   ```bash
   make xsa

3. The output XSA file will be available in `\hdmi\hw\runs\hdmi_advss_ced_prj\`


## License

Copyright (C) 2026 Advanced Micro Devices, Inc.
SPDX-License-Identifier: MIT

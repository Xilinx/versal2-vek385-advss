<table class="sphinxhide">
 <tr>
   <td align="center"><img src="https://raw.githubusercontent.com/Xilinx/Image-Collateral/main/xilinx-logo.png" width="30%"/><h1> Versal AI Edge Series Gen 2 - VEK385 Advanced Subsystem Design </h1>
   </td>
 </tr>
</table>

This project demonstrates five Advanced Subsystems (ADVSS) targeting the **VEK385 Rev-B1 board**. Each subsystem showcases different video/streaming capabilities and interfaces, providing comprehensive examples for high-performance video processing and data streaming applications.

The following is a list of Platform Designs available:
| Platform Name  | Description | Links |
| ---------------|------------- | -------------- |
|HDMI AdvSS | The HDMI AdvSS provides high-performance HDMI 2.1 video processing capabilities:<ul><li>HDMI-2.1 Rx → HDMI-2.1 Tx passthrough pipeline at 8Kp30 @ 8bpp</li><li>HDMI-2.1 Rx → VCU2 encode → decode → HDMI-2.1 Tx pipeline at 4Kp60 @ 8bpp</li><li>Supports both hardware and software components</li><li>Optimized for ultra-high definition video processing</li></ul> | <ul><li>[Documentation](https://xilinx-wiki.atlassian.net/wiki/x/A4AX2)</li><li>[Prebuilt images](https://account.amd.com/en/forms/downloads/design-license-xef.html?filename=vek385-hdmi-prebuilt-images.zip)</li><li>[Sources and License](https://account.amd.com/en/forms/downloads/design-license-xef.html?filename=sources-licenses.zip)</li></ul>|
|MIPI AdvSS | The VEK385 MIPI AdvSS platform captures video from MIPI 4x capture source (1920x1080 @ 30 fps) and displays it on the 4K HDMI-2.1 Tx monitor. <ul><li> 4x MIPI -> ISP-MCM → Mixer → HDMI-2.1 Tx at 4kp60 @8bpp</li></ul> | <ul><li>[Documentation](https://xilinx-wiki.atlassian.net/wiki/x/KgCx2w)</li><li>[Prebuilt images](https://account.amd.com/en/forms/downloads/design-license-xef.html?filename=vek385-mipi-prebuilt-images.zip)</li><li>[Sources and License](https://account.amd.com/en/forms/downloads/design-license-xef.html?filename=vek385-mipi-advss-sources-licenses.zip)</li></ul> |
|10Gb Ethernet AdvSS | The VEK385 10G AdvSS platform captures video from MIPI 4x capture source (3840x2160 @ 15 fps) and displays it on the 8K HDMI-2.1 Tx monitor and sending MIPI capture + ISP Non-MCM + VCU2 Encoded data over 10G stream out.<ul><li>MIPI 4x Capture + ISP Non-MCM + Mixer + HDMI-2.1 Tx at 8kp30@8bpp</li><li>MIPI 4x Capture + ISP Non-MCM + VCU2 + Encoder + Decoder + Mixer + HDMI-2.1 Tx at 8kp30 @8bpp</li><li>MIPI 4x Capture + ISP Non-MCM + VCU2 + Encoder + 10G stream out</li></ul> | <ul><li>[Documentation](https://xilinx-wiki.atlassian.net/wiki/x/bwDt2g)</li><li>[Prebuilt images](https://account.amd.com/en/forms/downloads/design-license-xef.html?filename=vek385-10g-prebuilt-images.zip)</li><li>[Sources and License](https://account.amd.com/en/forms/downloads/design-license-xef.html?filename=vek385-10g-advss-sources-licenses.zip)</li></ul>
 
# License
Copyright (C) 2026 Advanced Micro Devices, Inc. 
SPDX-License-Identifier: MIT

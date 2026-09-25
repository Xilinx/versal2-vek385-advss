<table class="sphinxhide">
 <tr>
   <td align="center"><img src="https://raw.githubusercontent.com/Xilinx/Image-Collateral/main/xilinx-logo.png" width="30%"/><h1> Versal AI Edge Series Gen 2 - VEK385 Advanced Subsystem Design </h1>
   </td>
 </tr>
</table>

This project demonstrates five Advanced Subsystems (AdvSS) targeting the **VEK385 Rev-B1 and B2 Board**. Each subsystem showcases different video/streaming capabilities and interfaces, providing comprehensive examples for high-performance video processing and data streaming applications.

The following is a list of Platform Designs available:
| Platform Name  | Description | Links |
| ---------------|------------- | -------------- |
|HDMI AdvSS | The HDMI AdvSS provides high-performance HDMI 2.1 video processing and VCU2 capabilities:<ul><li>HDMI-2.1 Rx → VPSS → FBWR → DDR → FBRD → HDMI-2.1 Tx passthrough pipeline at 8Kp30 </li><li>HDMI-2.1 RX → VPSS → FBWR → DDR → VCU2 Encode → DDR → VCU2 Decode → DDR → FBRD → HDMI-2.1 TX pipeline at 4Kp60 </li><li>Supports both hardware and software components</li><li>Optimized for ultra-high definition video processing</li></ul> | <ul><li>[Documentation](https://xilinx-wiki.atlassian.net/wiki/x/GwBp8)</li><li>[Prebuilt images](https://account.amd.com/en/forms/downloads/design-license-xef.html?filename=vek385-hdmi-2026.1-prebuilt-images.zip)</li><li>[Sources and License](https://account.amd.com/en/forms/downloads/design-license-xef.html?filename=vek385-hdmi-2026.1-sources-licenses.zip)</li></ul>|
|MIPI AdvSS | The VEK385 MIPI AdvSS platform captures video from MIPI 4x capture source (1920x1080 @ 30 fps) and displays it on the 4K HDMI-2.1 Tx monitor. <ul><li> 4x MIPI -> ISP-MCM → Mixer → HDMI-2.1 Tx at 4kp30</li></ul> | <ul><li>[Documentation](https://xilinx-wiki.atlassian.net/wiki/x/wgBp8)</li><li>[Prebuilt images](https://account.amd.com/en/forms/downloads/design-license-xef.html?filename=vek385-mipi-2026.1-prebuilt-images.zip)</li><li>[Sources and License](https://account.amd.com/en/forms/downloads/design-license-xef.html?filename=vek385-mipi-2026.1-sources-licenses.zip)</li></ul> |
|10Gb Ethernet AdvSS |  The VEK385 10G AdvSS platform captures video from MIPI 4x capture source (3840x2160 @ 30 fps) and displays it on the 8K HDMI-2.1 Tx monitor and sending MIPI capture + ISP Non-MCM + VCU2 Encoded data over 10G stream out. <ul><li>MIPI 4x Capture + ISP Non-MCM + Mixer + HDMI-2.1 Tx at 8kp30</li><li>MIPI 4x Capture + ISP Non-MCM + VCU2 + Encoder + Decoder + Mixer + HDMI-2.1 Tx at 8kp30</li><li>MIPI 4x Capture + ISP Non-MCM + VCU2 + Encoder + 10G stream out</li></ul> | <ul><li>[Documentation](https://xilinx-wiki.atlassian.net/wiki/x/owFp8)</li><li>[Prebuilt images](https://account.amd.com/en/forms/downloads/design-license-xef.html?filename=vek385-10g-2026.1-prebuilt-images.zip)</li><li>[Sources and License](https://account.amd.com/en/forms/downloads/design-license-xef.html?filename=vek385-10g-2026.1-sources-licenses.zip)</li></ul> ||
|12G SDI AdvSS |  Yet to Publish |  ||
|PCIe AdvSS | The VEK385 PCIe AdvSS platform captures video from a 8 MP Sony IMX728 camera sensor at 3840x2160 @ 30 fps, processes it through the on-chip ISP, and either displays it on a PS DisplayPort (DP) monitor or streams it over a PCIe Gen4 x8 endpoint link to an x86 host for OpenCV-based display.<ul><li>MIPI CSI2-Rx → ISP (LIMO) → DDR → PS DP at 4Kp30 @ 8bpp (RGB, YUY2, NV12)</li><li>MIPI CSI2-Rx → ISP → DDR → appsink → PCIe Gen4 x8 EP → OpenCV display on host at 4Kp30 @ 8bpp (RGB, YUY2, NV12)</li><li>4Kp30 RAW video file on host → appsrc → PCIe Gen4 x8 EP → appsink → OpenCV display on host</li></ul> | <ul><li>[Documentation](https://xilinx-wiki.atlassian.net/wiki/x/0QJp8)</li><li>[Prebuilt images](https://account.amd.com/en/forms/downloads/trd-license-versal-xef.html?filename=vek385-pcie-prebuilt-images-26.1.zip)</li><li>[Sources and License](https://account.amd.com/en/forms/downloads/trd-license-versal-xef.html?filename=vek385-pcie-sources-license-26.1.zip)</li></ul>|
 
# License
Copyright (C) 2026 Advanced Micro Devices, Inc. 
SPDX-License-Identifier: MIT

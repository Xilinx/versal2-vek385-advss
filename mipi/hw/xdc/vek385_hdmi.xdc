# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------

#####
## Constraints for VERSAL VEK385 HDMI 2.1
## Version 1.0
#####
#####
## Pins
#####
set_property PACKAGE_PIN B36 [get_ports {GT_Serial_grx_p[0]}]
set_property PACKAGE_PIN E37 [get_ports {GT_Serial_gtx_p[0]}]
set_property PACKAGE_PIN B34 [get_ports {GT_Serial_grx_p[1]}]
set_property PACKAGE_PIN E35 [get_ports {GT_Serial_gtx_p[1]}]
set_property PACKAGE_PIN B32 [get_ports {GT_Serial_grx_p[2]}]
set_property PACKAGE_PIN E33 [get_ports {GT_Serial_gtx_p[2]}]
set_property PACKAGE_PIN B30 [get_ports {GT_Serial_grx_p[3]}]
set_property PACKAGE_PIN E31 [get_ports {GT_Serial_gtx_p[3]}]

# HDMI RX
#SI570_8A34001_MUX_BUF0_C_P
set_property PACKAGE_PIN K38 [get_ports {GT_DRU_FRL_CLK_IN_clk_p[0]}]
create_clock -period 2.500 [get_ports GT_DRU_FRL_CLK_IN_clk_p]

# HDMI TX
set_property PACKAGE_PIN G40 [get_ports {TX_REFCLK_P_IN_V_clk_p[0]}]
create_clock -period 3.367 [get_ports TX_REFCLK_P_IN_V_clk_p]

set_property PACKAGE_PIN AU15 [get_ports TX_HPD_IN]
set_property IOSTANDARD LVCMOS12 [get_ports TX_HPD_IN]

#HDMI_8T49N241_LOL_IN
set_property PACKAGE_PIN BC18 [get_ports IDT8T49N241_LOL_IN]
set_property IOSTANDARD LVCMOS12 [get_ports IDT8T49N241_LOL_IN]

set_property PACKAGE_PIN AT16 [get_ports TX_DDC_OUT_scl_io]
set_property IOSTANDARD LVCMOS12 [get_ports TX_DDC_OUT_scl_io]
set_property PACKAGE_PIN AU17 [get_ports TX_DDC_OUT_sda_io]
set_property IOSTANDARD LVCMOS12 [get_ports TX_DDC_OUT_sda_io]

set_property PACKAGE_PIN AT15 [get_ports {TX_TI_ENABLE}]
set_property IOSTANDARD LVCMOS12 [get_ports {TX_TI_ENABLE}]

# HDMI_RX_ENABLE_N
set_property PACKAGE_PIN AW16 [get_ports {RX_TI_ENABLE}]
set_property IOSTANDARD LVCMOS12 [get_ports {RX_TI_ENABLE}]

# Misc
set_property PACKAGE_PIN BF18 [get_ports LED0]
set_property IOSTANDARD LVCMOS12 [get_ports LED0]

# PL IIC
set_property PACKAGE_PIN AW18 [get_ports HDMI_CTRL_sda_io]
set_property PACKAGE_PIN BA17 [get_ports HDMI_CTRL_scl_io]
set_property IOSTANDARD LVCMOS12 [get_ports HDMI_CTRL_scl_io]
set_property IOSTANDARD LVCMOS12 [get_ports HDMI_CTRL_sda_io]
#######
## End
#######


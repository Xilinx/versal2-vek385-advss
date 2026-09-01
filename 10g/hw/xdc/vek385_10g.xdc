# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------

#MIPI FMC IIC

set_property PACKAGE_PIN AN45 [get_ports FMC_IIC_2_scl_io]
set_property PACKAGE_PIN AM46 [get_ports FMC_IIC_2_sda_io]
set_property IOSTANDARD LVCMOS12 [get_ports FMC_IIC_2_s*]


set_property PACKAGE_PIN BC15 [get_ports FMC_IIC_3_scl_io]
set_property PACKAGE_PIN BC14 [get_ports FMC_IIC_3_sda_io]
set_property IOSTANDARD LVCMOS12 [get_ports FMC_IIC_3_s*]



#CLK
set_property PACKAGE_PIN BD22     [get_ports "MIPI1_clk_p"]
set_property PACKAGE_PIN BD23     [get_ports "MIPI1_clk_n"]
#D0
set_property PACKAGE_PIN BC23     [get_ports "MIPI1_data_p[0]"]
set_property PACKAGE_PIN BC24     [get_ports "MIPI1_data_n[0]"]
#D1
set_property PACKAGE_PIN BF20     [get_ports "MIPI1_data_p[1]"]
set_property PACKAGE_PIN BF21     [get_ports "MIPI1_data_n[1]"]
#D2
set_property PACKAGE_PIN BD19     [get_ports "MIPI1_data_p[2]"]
set_property PACKAGE_PIN BD20     [get_ports "MIPI1_data_n[2]"]
#D3
set_property PACKAGE_PIN BE19     [get_ports "MIPI1_data_p[3]"]
set_property PACKAGE_PIN BF19     [get_ports "MIPI1_data_n[3]"]

set_property IOSTANDARD MIPI_DPHY [get_ports "MIPI1_*"]

#CLK
set_property PACKAGE_PIN AL42     [get_ports "MIPI2_clk_p"]
set_property PACKAGE_PIN AM43     [get_ports "MIPI2_clk_n"]
#D0
set_property PACKAGE_PIN AM41     [get_ports "MIPI2_data_p[0]"]
set_property PACKAGE_PIN AL41     [get_ports "MIPI2_data_n[0]"]
#D1
set_property PACKAGE_PIN AM44     [get_ports "MIPI2_data_p[1]"]
set_property PACKAGE_PIN AL44     [get_ports "MIPI2_data_n[1]"]
#D2
set_property PACKAGE_PIN AN42     [get_ports "MIPI2_data_p[2]"]
set_property PACKAGE_PIN AN43     [get_ports "MIPI2_data_n[2]"]
#D3
set_property PACKAGE_PIN AP44     [get_ports "MIPI2_data_p[3]"]
set_property PACKAGE_PIN AP45     [get_ports "MIPI2_data_n[3]"]

set_property IOSTANDARD MIPI_DPHY [get_ports "MIPI2_*"]

#CLK
set_property PACKAGE_PIN AR41     [get_ports "MIPI3_clk_p"]
set_property PACKAGE_PIN AT42     [get_ports "MIPI3_clk_n"]
#D0
set_property PACKAGE_PIN AU41     [get_ports "MIPI3_data_p[0]"]
set_property PACKAGE_PIN AU42     [get_ports "MIPI3_data_n[0]"]
#D1
set_property PACKAGE_PIN AV37     [get_ports "MIPI3_data_p[1]"]
set_property PACKAGE_PIN AV38     [get_ports "MIPI3_data_n[1]"]
#D2
set_property PACKAGE_PIN AU38     [get_ports "MIPI3_data_p[2]"]
set_property PACKAGE_PIN AU39     [get_ports "MIPI3_data_n[2]"]
#D3
set_property PACKAGE_PIN AR38     [get_ports "MIPI3_data_p[3]"]
set_property PACKAGE_PIN AT39     [get_ports "MIPI3_data_n[3]"]

set_property IOSTANDARD MIPI_DPHY [get_ports "MIPI3_*"]


#CLK
set_property PACKAGE_PIN AL36     [get_ports "MIPI4_clk_p"]
set_property PACKAGE_PIN AM37     [get_ports "MIPI4_clk_n"]
#D0
set_property PACKAGE_PIN AL39     [get_ports "MIPI4_data_p[0]"]
set_property PACKAGE_PIN AM40     [get_ports "MIPI4_data_n[0]"]
#D1
set_property PACKAGE_PIN AR35     [get_ports "MIPI4_data_p[1]"]
set_property PACKAGE_PIN AP36     [get_ports "MIPI4_data_n[1]"]
#D2
set_property PACKAGE_PIN AP41     [get_ports "MIPI4_data_p[2]"]
set_property PACKAGE_PIN AP42     [get_ports "MIPI4_data_n[2]"]
#D3
set_property PACKAGE_PIN AM38     [get_ports "MIPI4_data_p[3]"]
set_property PACKAGE_PIN AL38     [get_ports "MIPI4_data_n[3]"]

set_property IOSTANDARD MIPI_DPHY [get_ports "MIPI4_*"]


#HDMI
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

# HDMI CLKs
set_property PACKAGE_PIN K38 [get_ports {GT_DRU_FRL_CLK_IN_clk_p[0]}]
create_clock -period 2.500 [get_ports GT_DRU_FRL_CLK_IN_clk_p]

set_property PACKAGE_PIN G40 [get_ports {TX_REFCLK_P_IN_V_clk_p[0]}]
create_clock -period 3.367 [get_ports TX_REFCLK_P_IN_V_clk_p]

set_property PACKAGE_PIN J40 [get_ports {HDMI_RX_CLK_P_IN_V_clk_p[0]}]
create_clock -period 3.367 [get_ports HDMI_RX_CLK_P_IN_V_clk_p]

set_property PACKAGE_PIN AY15 [get_ports RX_REFCLK_P_OUT]
set_property IOSTANDARD LVDS12 [get_ports RX_REFCLK_P_OUT]

#HDMI_TX_SRC_HPD
set_property PACKAGE_PIN AU15 [get_ports TX_HPD_IN]
set_property IOSTANDARD LVCMOS12 [get_ports TX_HPD_IN]

#HDMI_TX_SRC_SCL
set_property PACKAGE_PIN AT16 [get_ports TX_DDC_OUT_scl_io]
set_property IOSTANDARD LVCMOS12 [get_ports TX_DDC_OUT_scl_io]


#HDMI_TX_SRC_SDA
set_property PACKAGE_PIN AU17 [get_ports TX_DDC_OUT_sda_io]
set_property IOSTANDARD LVCMOS12 [get_ports TX_DDC_OUT_sda_io]

# Misc
#GPIO_LED_0_LS
set_property PACKAGE_PIN BF10 [get_ports LED0]
set_property IOSTANDARD LVCMOS12 [get_ports LED0]

#HDMI_8T49N241_LOL_IN
set_property PACKAGE_PIN BC18 [get_ports IDT8T49N241_LOL_IN]
set_property IOSTANDARD LVCMOS12 [get_ports IDT8T49N241_LOL_IN]

# HDMI_RX_ENABLE_N
set_property PACKAGE_PIN AW16 [get_ports {RX_TI_ENABLE}]
set_property IOSTANDARD LVCMOS12 [get_ports {RX_TI_ENABLE}]

#HDMI_TX_ENABLE_N
set_property PACKAGE_PIN AT15 [get_ports {TX_TI_ENABLE}]
set_property IOSTANDARD LVCMOS12 [get_ports {TX_TI_ENABLE}]

# PL IIC
set_property PACKAGE_PIN AW18 [get_ports HDMI_CTRL_sda_io]
set_property PACKAGE_PIN BA17 [get_ports HDMI_CTRL_scl_io]
set_property IOSTANDARD LVCMOS12 [get_ports HDMI_CTRL_scl_io]
set_property IOSTANDARD LVCMOS12 [get_ports HDMI_CTRL_sda_io]



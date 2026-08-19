# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------

##MIPI6## 707
#set_property PACKAGE_PIN BD22 [get_ports mipi_phy_if_1_0_clk_p]
#set_property PACKAGE_PIN BD23 [get_ports mipi_phy_if_1_0_clk_n]

#set_property PACKAGE_PIN BF20 [get_ports {mipi_phy_if_1_0_data_p[0]}]
#set_property PACKAGE_PIN BC23 [get_ports {mipi_phy_if_1_0_data_p[1]}]
#set_property PACKAGE_PIN BD19 [get_ports {mipi_phy_if_1_0_data_p[2]}]
#set_property PACKAGE_PIN BE19 [get_ports {mipi_phy_if_1_0_data_p[3]}]

#set_property PACKAGE_PIN BF21 [get_ports {mipi_phy_if_1_0_data_n[0]}]
#set_property PACKAGE_PIN BC24 [get_ports {mipi_phy_if_1_0_data_n[1]}]
#set_property PACKAGE_PIN BD20 [get_ports {mipi_phy_if_1_0_data_n[2]}]
#set_property PACKAGE_PIN BF19 [get_ports {mipi_phy_if_1_0_data_n[3]}]


#set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_1_0_data_n[3]}]
#set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_1_0_data_n[2]}]
#set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_1_0_data_n[1]}]
#set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_1_0_data_n[0]}]
#set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_1_0_data_p[3]}]
#set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_1_0_data_p[2]}]
#set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_1_0_data_p[1]}]
#set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_1_0_data_p[0]}]
#set_property IOSTANDARD MIPI_DPHY [get_ports mipi_phy_if_1_0_clk_n]
#set_property IOSTANDARD MIPI_DPHY [get_ports mipi_phy_if_1_0_clk_p]

###MIPI2## 713
#set_property PACKAGE_PIN AL42 [get_ports mipi_phy_if_0_0_clk_p]
#set_property PACKAGE_PIN AM43 [get_ports mipi_phy_if_0_0_clk_n]
#set_property PACKAGE_PIN AM41 [get_ports {mipi_phy_if_0_0_data_p[0]}]
#set_property PACKAGE_PIN AL41 [get_ports {mipi_phy_if_0_0_data_n[0]}]
#set_property PACKAGE_PIN AM44 [get_ports {mipi_phy_if_0_0_data_p[1]}]
#set_property PACKAGE_PIN AL44 [get_ports {mipi_phy_if_0_0_data_n[1]}]
#set_property PACKAGE_PIN AP44 [get_ports {mipi_phy_if_0_0_data_p[2]}]
#set_property PACKAGE_PIN AP45 [get_ports {mipi_phy_if_0_0_data_n[2]}]
#set_property PACKAGE_PIN AN42 [get_ports {mipi_phy_if_0_0_data_p[3]}]
#set_property PACKAGE_PIN AN43 [get_ports {mipi_phy_if_0_0_data_n[3]}]
#set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_0_0_data_n[3]}]
#set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_0_0_data_n[2]}]
#set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_0_0_data_n[1]}]
#set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_0_0_data_n[0]}]
#set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_0_0_data_p[3]}]
#set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_0_0_data_p[2]}]
#set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_0_0_data_p[1]}]
#set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_0_0_data_p[0]}]
#set_property IOSTANDARD MIPI_DPHY [get_ports mipi_phy_if_0_0_clk_n]
#set_property IOSTANDARD MIPI_DPHY [get_ports mipi_phy_if_0_0_clk_p]



set_property PACKAGE_PIN AN45 [get_ports FMC_IIC_2_scl_io]
set_property PACKAGE_PIN AM46 [get_ports FMC_IIC_2_sda_io]
set_property IOSTANDARD LVCMOS12 [get_ports FMC_IIC_2_s*]

#set_property PACKAGE_PIN BD22     [get_ports "FMCP1_LA18_CC_P"] ;# Bank 707 VCCO - VADJ_FMC - IO_L25P_XCC_H1O2P2_707
#set_property PACKAGE_PIN BD23     [get_ports "FMCP1_LA18_CC_N"] ;# Bank 707 VCCO - VADJ_FMC - IO_L25N_XCC_H1O2P3_707

set_property PACKAGE_PIN BD22     [get_ports "mipi_phy_if_0_0_clk_p"]
set_property PACKAGE_PIN BD23     [get_ports "mipi_phy_if_0_0_clk_n"]


#D0

#set_property PACKAGE_PIN BC23     [get_ports "FMCP1_LA23_P"] ;# Bank 707 VCCO - VADJ_FMC - IO_L24P_H1O2P0_707
#set_property PACKAGE_PIN BC24     [get_ports "FMCP1_LA23_N"] ;# Bank 707 VCCO - VADJ_FMC - IO_L24N_H1O2P1_707

set_property PACKAGE_PIN BC23     [get_ports "mipi_phy_if_0_0_data_p[0]"]
set_property PACKAGE_PIN BC24     [get_ports "mipi_phy_if_0_0_data_n[0]"]

#D1

#set_property PACKAGE_PIN BF20     [get_ports "FMCP1_LA17_CC_P"] ;# Bank 707 VCCO - VADJ_FMC - IO_L28P_H1O3P0_707
#set_property PACKAGE_PIN BF21     [get_ports "FMCP1_LA17_CC_N"] ;# Bank 707 VCCO - VADJ_FMC - IO_L28N_H1O3P1_707

set_property PACKAGE_PIN BF20     [get_ports "mipi_phy_if_0_0_data_p[1]"]
set_property PACKAGE_PIN BF21     [get_ports "mipi_phy_if_0_0_data_n[1]"]


#D2

#set_property PACKAGE_PIN BD19     [get_ports "FMCP1_LA24_P"] ;# Bank 707 VCCO - VADJ_FMC - IO_L26P_H1O2P4_707
#set_property PACKAGE_PIN BD20     [get_ports "FMCP1_LA24_N"] ;# Bank 707 VCCO - VADJ_FMC - IO_L26N_H1O2P5_707

set_property PACKAGE_PIN BD19     [get_ports "mipi_phy_if_0_0_data_p[2]"]
set_property PACKAGE_PIN BD20     [get_ports "mipi_phy_if_0_0_data_n[2]"]

#D3

#set_property PACKAGE_PIN BE19     [get_ports "FMCP1_LA25_P"] ;# Bank 707 VCCO - VADJ_FMC - IO_L27P_H1O2P6_707
#set_property PACKAGE_PIN BF19     [get_ports "FMCP1_LA25_N"] ;# Bank 707 VCCO - VADJ_FMC - IO_L27N_H1O2P7_707

set_property PACKAGE_PIN BE19     [get_ports "mipi_phy_if_0_0_data_p[3]"]
set_property PACKAGE_PIN BF19     [get_ports "mipi_phy_if_0_0_data_n[3]"]

set_property IOSTANDARD MIPI_DPHY [get_ports "mipi_phy_if_0_0_*"]


#set_property PACKAGE_PIN AL42     [get_ports "FMCP1_LA31_P"] ;# Bank 713 VCCO - VADJ_FMC - IO_L25P_XCC_H1O2P2_M3P114_713
#set_property PACKAGE_PIN AM43     [get_ports "FMCP1_LA31_N"] ;# Bank 713 VCCO - VADJ_FMC - IO_L25N_XCC_H1O2P3_M3P115_713
set_property PACKAGE_PIN AL42     [get_ports "mipi_phy_if_1_0_clk_p"]
set_property PACKAGE_PIN AM43     [get_ports "mipi_phy_if_1_0_clk_n"]

#D0
#set_property PACKAGE_PIN AM41     [get_ports "FMCP1_LA30_P"] ;# Bank 713 VCCO - VADJ_FMC - IO_L24P_H1O2P0_M3P112_713
#set_property PACKAGE_PIN AL41     [get_ports "FMCP1_LA30_N"] ;# Bank 713 VCCO - VADJ_FMC - IO_L24N_H1O2P1_M3P113_713
set_property PACKAGE_PIN AM41     [get_ports "mipi_phy_if_1_0_data_p[0]"]
set_property PACKAGE_PIN AL41     [get_ports "mipi_phy_if_1_0_data_n[0]"]

#D1
#set_property PACKAGE_PIN AM44     [get_ports "FMCP1_LA29_P"] ;# Bank 713 VCCO - VADJ_FMC - IO_L28P_H1O3P0_M3P120_713
#set_property PACKAGE_PIN AL44     [get_ports "FMCP1_LA29_N"] ;# Bank 713 VCCO - VADJ_FMC - IO_L28N_H1O3P1_M3P121_713
set_property PACKAGE_PIN AM44     [get_ports "mipi_phy_if_1_0_data_p[1]"]
set_property PACKAGE_PIN AL44     [get_ports "mipi_phy_if_1_0_data_n[1]"]

#D2
#set_property PACKAGE_PIN AN42     [get_ports "FMCP1_LA32_P"] ;# Bank 713 VCCO - VADJ_FMC - IO_L26P_H1O2P4_M3P116_713
#set_property PACKAGE_PIN AN43     [get_ports "FMCP1_LA32_N"] ;# Bank 713 VCCO - VADJ_FMC - IO_L26N_H1O2P5_M3P117_713
set_property PACKAGE_PIN AN42     [get_ports "mipi_phy_if_1_0_data_p[2]"]
set_property PACKAGE_PIN AN43     [get_ports "mipi_phy_if_1_0_data_n[2]"]

#D3
#set_property PACKAGE_PIN AP44     [get_ports "FMCP1_LA33_P"] ;# Bank 713 VCCO - VADJ_FMC - IO_L27P_H1O2P6_M3P118_713
#set_property PACKAGE_PIN AP45     [get_ports "FMCP1_LA33_N"] ;# Bank 713 VCCO - VADJ_FMC - IO_L27N_H1O2P7_M3P119_713
set_property PACKAGE_PIN AP44     [get_ports "mipi_phy_if_1_0_data_p[3]"]
set_property PACKAGE_PIN AP45     [get_ports "mipi_phy_if_1_0_data_n[3]"]

set_property IOSTANDARD MIPI_DPHY [get_ports "mipi_phy_if_1_0_*"]


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
#set_property PACKAGE_PIN L40 [get_ports {GT_DRU_FRL_CLK_IN_clk_p[0]}]
set_property PACKAGE_PIN K38 [get_ports {GT_DRU_FRL_CLK_IN_clk_p[0]}]
create_clock -period 2.500 [get_ports GT_DRU_FRL_CLK_IN_clk_p]

# HDMI TX
#FMCP1_GBTCLK1_M2C_C_P
set_property PACKAGE_PIN G40 [get_ports {TX_REFCLK_P_IN_V_clk_p[0]}]
create_clock -period 3.367 [get_ports TX_REFCLK_P_IN_V_clk_p]

set_property PACKAGE_PIN J40 [get_ports {HDMI_RX_CLK_P_IN_V_clk_p[0]}]
create_clock -period 3.367 [get_ports HDMI_RX_CLK_P_IN_V_clk_p]

set_property PACKAGE_PIN AY15 [get_ports RX_REFCLK_P_OUT]
set_property IOSTANDARD LVDS12 [get_ports RX_REFCLK_P_OUT]

#HDMI_TX_SRC_HPD
#set_property PACKAGE_PIN AU15     [get_ports "HDMI_TX_SRC_HPD"] ;# Bank 706 VCCO - VADJ_FMC - IO_L15N_H0O3P7_706

set_property PACKAGE_PIN AU15 [get_ports TX_HPD_IN]
set_property IOSTANDARD LVCMOS12 [get_ports TX_HPD_IN]

#HDMI_TX_SRC_SCL
#set_property PACKAGE_PIN AT16     [get_ports "HDMI_TX_SRC_SCL"] ;# Bank 706 VCCO - VADJ_FMC - IO_L14P_H0O3P4_706

set_property PACKAGE_PIN AT16 [get_ports TX_DDC_OUT_scl_io]
set_property IOSTANDARD LVCMOS12 [get_ports TX_DDC_OUT_scl_io]


#HDMI_TX_SRC_SDA
#set_property PACKAGE_PIN AU17     [get_ports "HDMI_TX_SRC_SDA"] ;# Bank 706 VCCO - VADJ_FMC - IO_L14N_H0O3P5_706

set_property PACKAGE_PIN AU17 [get_ports TX_DDC_OUT_sda_io]
set_property IOSTANDARD LVCMOS12 [get_ports TX_DDC_OUT_sda_io]

# Misc
#GPIO_LED_0_LS
#set_property PACKAGE_PIN BF10     [get_ports "GPIO_LED0"] ;# Bank 705 VCCO - VADJ_FMC - IO_L23P_H1O1P6_M1P174_705

set_property PACKAGE_PIN BF10 [get_ports LED0]
set_property IOSTANDARD LVCMOS12 [get_ports LED0]

#HDMI_8T49N241_LOL_IN
#set_property PACKAGE_PIN BC18     [get_ports "HDMI_8T49N241_LOL_IN"] ;# Bank 706 VCCO - VADJ_FMC - IO_L7N_H0O1P7_706

set_property PACKAGE_PIN BC18 [get_ports IDT8T49N241_LOL_IN]
set_property IOSTANDARD LVCMOS12 [get_ports IDT8T49N241_LOL_IN]

# HDMI_RX_ENABLE_N
#set_property PACKAGE_PIN AW16     [get_ports "HDMI_RX_ENABLE_N"] ;# Bank 706 VCCO - VADJ_FMC - IO_L12N_H0O3P1_706

set_property PACKAGE_PIN AW16 [get_ports {RX_TI_ENABLE}]
set_property IOSTANDARD LVCMOS12 [get_ports {RX_TI_ENABLE}]

#HDMI_TX_ENABLE_N
#set_property PACKAGE_PIN AT15     [get_ports "HDMI_TX_ENABLE_N"] ;# Bank 706 VCCO - VADJ_FMC - IO_L15P_H0O3P6_706

set_property PACKAGE_PIN AT15 [get_ports {TX_TI_ENABLE}]
set_property IOSTANDARD LVCMOS12 [get_ports {TX_TI_ENABLE}]

# PL IIC
#set_property PACKAGE_PIN AW18     [get_ports "HDMI_CTL_VERSAL_SDA"] ;# Bank 706 VCCO - VADJ_FMC - IO_L11P_H0O2P6_706
#set_property PACKAGE_PIN BA17     [get_ports "HDMI_CTL_VERSAL_SCL"] ;# Bank 706 VCCO - VADJ_FMC - IO_L10N_H0O2P5_706

set_property PACKAGE_PIN AW18 [get_ports HDMI_CTRL_sda_io]
set_property PACKAGE_PIN BA17 [get_ports HDMI_CTRL_scl_io]
set_property IOSTANDARD LVCMOS12 [get_ports HDMI_CTRL_scl_io]
set_property IOSTANDARD LVCMOS12 [get_ports HDMI_CTRL_sda_io]



## HDMI interface
#set_property PACKAGE_PIN BA17 [get_ports HDMI_CTRL_0_0_scl_io]
#set_property PACKAGE_PIN AW18 [get_ports HDMI_CTRL_0_0_sda_io]
#set_property IOSTANDARD LVCMOS12 [get_ports HDMI_CTRL_0_0_scl_io]
#set_property IOSTANDARD LVCMOS12 [get_ports HDMI_CTRL_0_0_sda_io]
#set_property PACKAGE_PIN AT16 [get_ports TX_DDC_OUT_0_0_scl_io]
#set_property PACKAGE_PIN AU17 [get_ports TX_DDC_OUT_0_0_sda_io]
#set_property IOSTANDARD LVCMOS12 [get_ports TX_DDC_OUT_0_0_scl_io]
#set_property IOSTANDARD LVCMOS12 [get_ports TX_DDC_OUT_0_0_sda_io]
#set_property PACKAGE_PIN G40 [get_ports {TX_REFCLK_P_IN_V_0_0_clk_p[0]}]
#set_property PACKAGE_PIN AT15 [get_ports {RX_TI_ENABLE_0_0[0]}]
#set_property IOSTANDARD LVCMOS12 [get_ports {RX_TI_ENABLE_0_0[0]}]
#set_property PACKAGE_PIN BF18 [get_ports LED0_0_0]
#set_property PACKAGE_PIN BC18 [get_ports IDT8T49N241_LOL_IN_0_0]
#set_property PACKAGE_PIN AU15 [get_ports TX_HPD_IN_0_0]
#set_property IOSTANDARD LVCMOS12 [get_ports IDT8T49N241_LOL_IN_0_0]
#set_property IOSTANDARD LVCMOS12 [get_ports LED0_0_0]
#set_property IOSTANDARD LVCMOS12 [get_ports TX_HPD_IN_0_0]
#set_property PACKAGE_PIN E37 [get_ports {GT_Serial_0_0_gtx_p[0]}]
#set_property PACKAGE_PIN K38 [get_ports {GT_DRU_FRL_CLK_IN_0_0_clk_p[0]}]

#set_property PACKAGE_PIN J40 [get_ports {HDMI_RX_CLK_P_IN_V_clk_p[0]}]
#create_clock -period 3.367 [get_ports HDMI_RX_CLK_P_IN_V_clk_p]

#set_property PACKAGE_PIN AY15 [get_ports RX_REFCLK_P_OUT]
#set_property IOSTANDARD LVDS12 [get_ports RX_REFCLK_P_OUT]


#create_clock -period 3.367 [get_ports {TX_REFCLK_P_IN_V_0_0_clk_p[0]}]
#create_clock -period 2.500 [get_ports {GT_DRU_FRL_CLK_IN_0_0_clk_p[0]}]

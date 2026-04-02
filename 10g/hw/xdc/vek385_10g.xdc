# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------

##MIPI6## 707
set_property PACKAGE_PIN BD22 [get_ports mipi_phy_if_1_clk_p]
set_property PACKAGE_PIN BD23 [get_ports mipi_phy_if_1_clk_n]

set_property PACKAGE_PIN BF20 [get_ports {mipi_phy_if_1_data_p[0]}]
set_property PACKAGE_PIN BC23 [get_ports {mipi_phy_if_1_data_p[1]}]
set_property PACKAGE_PIN BD19 [get_ports {mipi_phy_if_1_data_p[2]}]
set_property PACKAGE_PIN BE19 [get_ports {mipi_phy_if_1_data_p[3]}]

set_property PACKAGE_PIN BF21 [get_ports {mipi_phy_if_1_data_n[0]}]
set_property PACKAGE_PIN BC24 [get_ports {mipi_phy_if_1_data_n[1]}]
set_property PACKAGE_PIN BD20 [get_ports {mipi_phy_if_1_data_n[2]}]
set_property PACKAGE_PIN BF19 [get_ports {mipi_phy_if_1_data_n[3]}]


set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_1_data_n[3]}]
set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_1_data_n[2]}]
set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_1_data_n[1]}]
set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_1_data_n[0]}]
set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_1_data_p[3]}]
set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_1_data_p[2]}]
set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_1_data_p[1]}]
set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_1_data_p[0]}]
set_property IOSTANDARD MIPI_DPHY [get_ports mipi_phy_if_1_clk_n]
set_property IOSTANDARD MIPI_DPHY [get_ports mipi_phy_if_1_clk_p]

##MIPI2## 713
set_property PACKAGE_PIN AL42 [get_ports mipi_phy_if_0_clk_p]
set_property PACKAGE_PIN AM43 [get_ports mipi_phy_if_0_clk_n]
set_property PACKAGE_PIN AM41 [get_ports {mipi_phy_if_0_data_p[0]}]
set_property PACKAGE_PIN AL41 [get_ports {mipi_phy_if_0_data_n[0]}]
set_property PACKAGE_PIN AM44 [get_ports {mipi_phy_if_0_data_p[1]}]
set_property PACKAGE_PIN AL44 [get_ports {mipi_phy_if_0_data_n[1]}]
set_property PACKAGE_PIN AP44 [get_ports {mipi_phy_if_0_data_p[2]}]
set_property PACKAGE_PIN AP45 [get_ports {mipi_phy_if_0_data_n[2]}]
set_property PACKAGE_PIN AN42 [get_ports {mipi_phy_if_0_data_p[3]}]
set_property PACKAGE_PIN AN43 [get_ports {mipi_phy_if_0_data_n[3]}]
set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_0_data_n[3]}]
set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_0_data_n[2]}]
set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_0_data_n[1]}]
set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_0_data_n[0]}]
set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_0_data_p[3]}]
set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_0_data_p[2]}]
set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_0_data_p[1]}]
set_property IOSTANDARD MIPI_DPHY [get_ports {mipi_phy_if_0_data_p[0]}]
set_property IOSTANDARD MIPI_DPHY [get_ports mipi_phy_if_0_clk_n]
set_property IOSTANDARD MIPI_DPHY [get_ports mipi_phy_if_0_clk_p]


## HDMI interface
set_property PACKAGE_PIN BA17 [get_ports HDMI_CTRL_0_0_scl_io]
set_property PACKAGE_PIN AW18 [get_ports HDMI_CTRL_0_0_sda_io]
set_property IOSTANDARD LVCMOS12 [get_ports HDMI_CTRL_0_0_scl_io]
set_property IOSTANDARD LVCMOS12 [get_ports HDMI_CTRL_0_0_sda_io]
set_property PACKAGE_PIN AT16 [get_ports TX_DDC_OUT_0_0_scl_io]
set_property PACKAGE_PIN AU17 [get_ports TX_DDC_OUT_0_0_sda_io]
set_property IOSTANDARD LVCMOS12 [get_ports TX_DDC_OUT_0_0_scl_io]
set_property IOSTANDARD LVCMOS12 [get_ports TX_DDC_OUT_0_0_sda_io]
set_property PACKAGE_PIN G40 [get_ports {TX_REFCLK_P_IN_V_0_0_clk_p[0]}]
set_property PACKAGE_PIN AT15 [get_ports {RX_TI_ENABLE_0_0[0]}]
set_property IOSTANDARD LVCMOS12 [get_ports {RX_TI_ENABLE_0_0[0]}]
set_property PACKAGE_PIN BF18 [get_ports LED0_0_0]
set_property PACKAGE_PIN BC18 [get_ports IDT8T49N241_LOL_IN_0_0]
set_property PACKAGE_PIN AU15 [get_ports TX_HPD_IN_0_0]
set_property IOSTANDARD LVCMOS12 [get_ports IDT8T49N241_LOL_IN_0_0]
set_property IOSTANDARD LVCMOS12 [get_ports LED0_0_0]
set_property IOSTANDARD LVCMOS12 [get_ports TX_HPD_IN_0_0]
set_property PACKAGE_PIN E37 [get_ports {GT_Serial_0_0_gtx_p[0]}]
set_property PACKAGE_PIN K38 [get_ports {GT_DRU_FRL_CLK_IN_0_0_clk_p[0]}]

create_clock -period 3.367 [get_ports {TX_REFCLK_P_IN_V_0_0_clk_p[0]}]
create_clock -period 2.500 [get_ports {GT_DRU_FRL_CLK_IN_0_0_clk_p[0]}]

create_clock -name clk_pl_0 -period 3.333 [get_pins versal_gen2_platform_i/ps_wizard_0/inst/ps11_0/inst/PS11_inst/PMCRCLKCLKINT[0]]
create_clock -name clk_pl_1 -period 6.667 [get_pins versal_gen2_platform_i/ps_wizard_0/inst/ps11_0/inst/PS11_inst/PMCRCLKCLKINT[1]]
set_clock_groups -asynchronous -group {clk_pl_0} -group {clk_pl_1}


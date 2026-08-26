# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------
#Get parameters from base instance
#CLK

#set_property PACKAGE_PIN BD22     [get_ports "FMCP1_LA18_CC_P"] ;# Bank 707 VCCO - VADJ_FMC - IO_L25P_XCC_H1O2P2_707
#set_property PACKAGE_PIN BD23     [get_ports "FMCP1_LA18_CC_N"] ;# Bank 707 VCCO - VADJ_FMC - IO_L25N_XCC_H1O2P3_707

set_property PACKAGE_PIN BD22     [get_ports "MIPI1_clk_p"]
set_property PACKAGE_PIN BD23     [get_ports "MIPI1_clk_n"]


#D0

#set_property PACKAGE_PIN BC23     [get_ports "FMCP1_LA23_P"] ;# Bank 707 VCCO - VADJ_FMC - IO_L24P_H1O2P0_707
#set_property PACKAGE_PIN BC24     [get_ports "FMCP1_LA23_N"] ;# Bank 707 VCCO - VADJ_FMC - IO_L24N_H1O2P1_707

set_property PACKAGE_PIN BC23     [get_ports "MIPI1_data_p[0]"]
set_property PACKAGE_PIN BC24     [get_ports "MIPI1_data_n[0]"]

#D1

#set_property PACKAGE_PIN BF20     [get_ports "FMCP1_LA17_CC_P"] ;# Bank 707 VCCO - VADJ_FMC - IO_L28P_H1O3P0_707
#set_property PACKAGE_PIN BF21     [get_ports "FMCP1_LA17_CC_N"] ;# Bank 707 VCCO - VADJ_FMC - IO_L28N_H1O3P1_707

set_property PACKAGE_PIN BF20     [get_ports "MIPI1_data_p[1]"]
set_property PACKAGE_PIN BF21     [get_ports "MIPI1_data_n[1]"]


#D2

#set_property PACKAGE_PIN BD19     [get_ports "FMCP1_LA24_P"] ;# Bank 707 VCCO - VADJ_FMC - IO_L26P_H1O2P4_707
#set_property PACKAGE_PIN BD20     [get_ports "FMCP1_LA24_N"] ;# Bank 707 VCCO - VADJ_FMC - IO_L26N_H1O2P5_707

set_property PACKAGE_PIN BD19     [get_ports "MIPI1_data_p[2]"]
set_property PACKAGE_PIN BD20     [get_ports "MIPI1_data_n[2]"]

#D3

#set_property PACKAGE_PIN BE19     [get_ports "FMCP1_LA25_P"] ;# Bank 707 VCCO - VADJ_FMC - IO_L27P_H1O2P6_707
#set_property PACKAGE_PIN BF19     [get_ports "FMCP1_LA25_N"] ;# Bank 707 VCCO - VADJ_FMC - IO_L27N_H1O2P7_707

set_property PACKAGE_PIN BE19     [get_ports "MIPI1_data_p[3]"]
set_property PACKAGE_PIN BF19     [get_ports "MIPI1_data_n[3]"]

set_property IOSTANDARD MIPI_DPHY [get_ports "MIPI1_*"]

#MIPI2
#set_property PACKAGE_PIN AL42     [get_ports "MIPI2_0_clk_p"]
#set_property PACKAGE_PIN AM43     [get_ports "MIPI2_0_clk_n"]
#set_property PACKAGE_PIN AM41     [get_ports "MIPI2_0_data_p[0]"]
#set_property PACKAGE_PIN AL41     [get_ports "MIPI2_0_data_n[0]"]
#set_property PACKAGE_PIN AM44     [get_ports "MIPI2_0_data_p[1]"]
#set_property PACKAGE_PIN AL44     [get_ports "MIPI2_0_data_n[1]"]
#set_property PACKAGE_PIN AP44     [get_ports "MIPI2_0_data_p[2]"]
#set_property PACKAGE_PIN AP45     [get_ports "MIPI2_0_data_n[2]"]
#set_property PACKAGE_PIN AN42     [get_ports "MIPI2_0_data_p[3]"]
#set_property PACKAGE_PIN AN43     [get_ports "MIPI2_0_data_n[3]"]
#set_property IOSTANDARD MIPI_DPHY [get_ports "MIPI2_0_*"]
#set_property DIFF_TERM_ADV TERM_100 [get_ports "MIPI2_0_*"]

#FMC Ports
set_property PACKAGE_PIN AN45 [get_ports IIC_0_scl_io]
set_property PACKAGE_PIN AM46 [get_ports IIC_0_sda_io]
set_property IOSTANDARD LVCMOS12 [get_ports IIC_0_s*]

set_property CLOCK_DEDICATED_ROUTE ANY_CMT_REGION [get_nets edf_base_i/ISP_hier/clkx5_wiz_0/inst/clock_primitive_inst/clk_out2]

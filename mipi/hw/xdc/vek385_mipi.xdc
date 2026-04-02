# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------

#Get parameters from base instance
####
## Constraints for VERSAL VEK385 MIPI 2 & 6
## Version 1.0
#####



#MIPI2
#LA29_N	MIPI2_D1N
#LA29_P	MIPI2_D1P
#LA33_N	MIPI2_D2N
#LA33_P	MIPI2_D2P
#LA32_N	MIPI2_D3N
#LA32_P	MIPI2_D3P
#LA31_N	MIPI2_CLKN
#LA31_P	MIPI2_CLKP
#LA30_N	MIPI2_D0N
#LA30_P	MIPI2_D0P

#CLK
#set_property PACKAGE_PIN AL42     [get_ports "FMCP1_LA31_P"] ;# Bank 713 VCCO - VADJ_FMC - IO_L25P_XCC_H1O2P2_M3P114_713
#set_property PACKAGE_PIN AM43     [get_ports "FMCP1_LA31_N"] ;# Bank 713 VCCO - VADJ_FMC - IO_L25N_XCC_H1O2P3_M3P115_713
set_property PACKAGE_PIN AL42     [get_ports "MIPI2_clk_p"]
set_property PACKAGE_PIN AM43     [get_ports "MIPI2_clk_n"]

#D0
#set_property PACKAGE_PIN AM41     [get_ports "FMCP1_LA30_P"] ;# Bank 713 VCCO - VADJ_FMC - IO_L24P_H1O2P0_M3P112_713
#set_property PACKAGE_PIN AL41     [get_ports "FMCP1_LA30_N"] ;# Bank 713 VCCO - VADJ_FMC - IO_L24N_H1O2P1_M3P113_713
set_property PACKAGE_PIN AM41     [get_ports "MIPI2_data_p[0]"]
set_property PACKAGE_PIN AL41     [get_ports "MIPI2_data_n[0]"]

#D1
#set_property PACKAGE_PIN AM44     [get_ports "FMCP1_LA29_P"] ;# Bank 713 VCCO - VADJ_FMC - IO_L28P_H1O3P0_M3P120_713
#set_property PACKAGE_PIN AL44     [get_ports "FMCP1_LA29_N"] ;# Bank 713 VCCO - VADJ_FMC - IO_L28N_H1O3P1_M3P121_713
set_property PACKAGE_PIN AM44     [get_ports "MIPI2_data_p[1]"]
set_property PACKAGE_PIN AL44     [get_ports "MIPI2_data_n[1]"]

#D2
#set_property PACKAGE_PIN AP44     [get_ports "FMCP1_LA33_P"] ;# Bank 713 VCCO - VADJ_FMC - IO_L27P_H1O2P6_M3P118_713
#set_property PACKAGE_PIN AP45     [get_ports "FMCP1_LA33_N"] ;# Bank 713 VCCO - VADJ_FMC - IO_L27N_H1O2P7_M3P119_713
set_property PACKAGE_PIN AP44     [get_ports "MIPI2_data_p[2]"]
set_property PACKAGE_PIN AP45     [get_ports "MIPI2_data_n[2]"]

#D3
#set_property PACKAGE_PIN AN42     [get_ports "FMCP1_LA32_P"] ;# Bank 713 VCCO - VADJ_FMC - IO_L26P_H1O2P4_M3P116_713
#set_property PACKAGE_PIN AN43     [get_ports "FMCP1_LA32_N"] ;# Bank 713 VCCO - VADJ_FMC - IO_L26N_H1O2P5_M3P117_713
set_property PACKAGE_PIN AN42     [get_ports "MIPI2_data_p[3]"]
set_property PACKAGE_PIN AN43     [get_ports "MIPI2_data_n[3]"]

set_property IOSTANDARD MIPI_DPHY [get_ports "MIPI2_*"]
set_property DIFF_TERM_ADV TERM_100 [get_ports "MIPI2_*"]

#MIPI6
#LA17_N_CC MIPI6_D0N
#LA17_P_CC MIPI6_D0P
#LA25_N    MIPI6_D3P
#LA25_P    MIPI6_D3N
#LA24_N    MIPI6_D2P
#LA24_P    MIPI6_D2N
#LA18_N_CC MIPI6_CLKN
#LA18_P_CC MIPI6_CLKP
#LA23_N    MIPI6_D1N
#LA23_P    MIPI6_D1P

#CLK

#set_property PACKAGE_PIN BD22     [get_ports "FMCP1_LA18_CC_P"] ;# Bank 707 VCCO - VADJ_FMC - IO_L25P_XCC_H1O2P2_707
#set_property PACKAGE_PIN BD23     [get_ports "FMCP1_LA18_CC_N"] ;# Bank 707 VCCO - VADJ_FMC - IO_L25N_XCC_H1O2P3_707

set_property PACKAGE_PIN BD22     [get_ports "MIPI6_clk_p"]
set_property PACKAGE_PIN BD23     [get_ports "MIPI6_clk_n"]

#D0

#set_property PACKAGE_PIN BF20     [get_ports "FMCP1_LA17_CC_P"] ;# Bank 707 VCCO - VADJ_FMC - IO_L28P_H1O3P0_707
#set_property PACKAGE_PIN BF21     [get_ports "FMCP1_LA17_CC_N"] ;# Bank 707 VCCO - VADJ_FMC - IO_L28N_H1O3P1_707

set_property PACKAGE_PIN BF20     [get_ports "MIPI6_data_p[0]"]
set_property PACKAGE_PIN BF21     [get_ports "MIPI6_data_n[0]"]

#D1

#set_property PACKAGE_PIN BC23     [get_ports "FMCP1_LA23_P"] ;# Bank 707 VCCO - VADJ_FMC - IO_L24P_H1O2P0_707
#set_property PACKAGE_PIN BC24     [get_ports "FMCP1_LA23_N"] ;# Bank 707 VCCO - VADJ_FMC - IO_L24N_H1O2P1_707

set_property PACKAGE_PIN BC23     [get_ports "MIPI6_data_p[1]"]
set_property PACKAGE_PIN BC24     [get_ports "MIPI6_data_n[1]"]

#D2

#set_property PACKAGE_PIN BD19     [get_ports "FMCP1_LA24_P"] ;# Bank 707 VCCO - VADJ_FMC - IO_L26P_H1O2P4_707
#set_property PACKAGE_PIN BD20     [get_ports "FMCP1_LA24_N"] ;# Bank 707 VCCO - VADJ_FMC - IO_L26N_H1O2P5_707

set_property PACKAGE_PIN BD19     [get_ports "MIPI6_data_p[2]"]
set_property PACKAGE_PIN BD20     [get_ports "MIPI6_data_n[2]"]

#D3

#set_property PACKAGE_PIN BE19     [get_ports "FMCP1_LA25_P"] ;# Bank 707 VCCO - VADJ_FMC - IO_L27P_H1O2P6_707
#set_property PACKAGE_PIN BF19     [get_ports "FMCP1_LA25_N"] ;# Bank 707 VCCO - VADJ_FMC - IO_L27N_H1O2P7_707

set_property PACKAGE_PIN BE19     [get_ports "MIPI6_data_p[3]"]
set_property PACKAGE_PIN BF19     [get_ports "MIPI6_data_n[3]"]

set_property IOSTANDARD MIPI_DPHY [get_ports "MIPI6_*"]
set_property DIFF_TERM_ADV TERM_100 [get_ports "MIPI6_*"]


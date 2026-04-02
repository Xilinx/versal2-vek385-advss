# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------

##########################################################################################################################
# # # #                            User Time Names / User Time Groups / Time Specs                                 # # # #
##########################################################################################################################
create_clock -name sys_clk -period 10 [get_ports pcie_refclk_0_clk_p]

#
set_property IOSTANDARD LVCMOS12 [get_ports sys_reset_0]
set_property PACKAGE_PIN BC12 [get_ports sys_reset_0]
#set_false_path -from [get_ports sys_rst_n]
set_property PULLUP true [get_ports sys_reset_0]
#
##########################################################################################################################
# # # #                                                                                                            # # # #
##########################################################################################################################
set gt_quads [get_cells -hierarchical -filter  PRIMITIVE_SUBGROUP==GT]
# set_property LOC GTYP_REFCLK_X0Y4  [get_cells -hierarchical -filter REF_NAME==IBUFDS_GTE5]
set_property LOC GTYP_REFCLK_X0Y4  [get_cells */pl_pcie/qdma_0_support/refclk_ibuf/U0/USE_IBUFDS_GTE5.GEN_IBUFDS_GTE5[0].IBUFDS_GTE5_I]
set_property LOC GTYP_QUAD_X0Y2    [get_cells $gt_quads -filter NAME=~*/gt_quad_base_1_inst/*]
set_property LOC GTYP_QUAD_X0Y1    [get_cells $gt_quads -filter NAME=~*/gt_quad_base_0_inst/*]
#########################################################################
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]
set_property BITSTREAM.GENERAL.WRITE0FRAMES No [current_design]
set_property BITSTREAM.GENERAL.PROCESSALLVEAMS true [current_design]
########################################################################
set_multicycle_path -setup -to [get_pins -filter {REF_PIN_NAME=~PCIELTSSM[*]} -of_objects [get_cells -hierarchical -filter { PRIMITIVE_TYPE =~ ADVANCED.GT.* }]] 2
set_multicycle_path -hold  -to [get_pins -filter {REF_PIN_NAME=~PCIELTSSM[*]} -of_objects [get_cells -hierarchical -filter { PRIMITIVE_TYPE =~ ADVANCED.GT.* }]] 1
#




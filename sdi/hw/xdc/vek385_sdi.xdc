# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------

#####
## Constraints for VERSAL VEK385 SDI
## Version 1.0
#####

#####
## Pins
#####

##BANK205 for GT_Serial_0

set_property PACKAGE_PIN N45 [get_ports {GT_Serial_0_grx_p[0]}]
set_property PACKAGE_PIN P42 [get_ports {GT_Serial_0_gtx_p[0]}] 
#set_property PACKAGE_PIN L45 [get_ports {GT_Serial_0_grx_p[1]}]
#set_property PACKAGE_PIN M42 [get_ports {GT_Serial_0_gtx_p[1]}]
#set_property PACKAGE_PIN J45 [get_ports {GT_Serial_0_grx_p[2]}]
#set_property PACKAGE_PIN K42 [get_ports {GT_Serial_0_gtx_p[2]}]
#set_property PACKAGE_PIN G45 [get_ports {GT_Serial_0_grx_p[3]}]
#set_property PACKAGE_PIN H42 [get_ports {GT_Serial_0_gtx_p[3]}]

##BANK205 for GTREF_CLK1 
set_property PACKAGE_PIN M38 [get_ports {gt_refclk2_clk_p[0]}]
set_property PACKAGE_PIN N40 [get_ports {gt_refclk_clk_p[0]}]

#DIP switch:: J34/J35/H37/H36 LVCMOS18
#set_property PACKAGE_PIN BF9 [get_ports reset]


##BANK(707,712 & 713)FZETTON_PINS

set_property PACKAGE_PIN BB21 [get_ports fzetton_i2c_scl_s00] 

set_property PACKAGE_PIN BB22 [get_ports fzetton_i2c_sda_s01] 

set_property PACKAGE_PIN AU41 [get_ports FZETTON_LNH1983_MOSI] 

set_property PACKAGE_PIN AU42 [get_ports FZETTON_LNH1983_MISO] 

set_property PACKAGE_PIN AV38 [get_ports FZETTON_LNH1983_INIT]
 
set_property PACKAGE_PIN BF20 [get_ports FZETTON_LNH1983_SCLK]

set_property PACKAGE_PIN BC21 [get_ports FZETTON_RCLKR_SEL] 

set_property PACKAGE_PIN BC20 [get_ports FZETTON_DRVR_SEL] 

set_property PACKAGE_PIN AR40 [get_ports FZETTON_RCVR_SEL] 

set_property PACKAGE_PIN AT40 [get_ports FZETTON_F_SPI_S0_CH_SEL] 

set_property PACKAGE_PIN AY21 [get_ports FZETTON_F_SPI_S1_CH_SEL] 

set_property PACKAGE_PIN AR41 [get_ports FZETTON_SWT_CH3_DIR] 

##BANK ( 705 & 706 )

##set_property PACKAGE_PIN BF10 [get_ports led_cnt_txusrclk] 

##set_property PACKAGE_PIN BF18 [get_ports led_cnt_rxusrclk] 

##set_property PACKAGE_PIN BF15 [get_ports led_cnt_freerun] 

##set_property PACKAGE_PIN BF16 [get_ports led_link_status]

##

#set_property BLOCK_SYNTH.USER_PROVIDED {rt::set_parameter datapathAddThreshold 10000;rt::set_parameter datapathAddTimingThreshold 10000;rt::set_parameter datapathEqThreshold 10000;rt::set_parameter datapathEqTimingThreshold 10000; rt::set_parameter datapathComparatorThreshold 10000; rt::set_parameter datapathComparatorTimingThreshold 10000; rt::set_parameter datapathAddThresholdCarry8 10000} [get_cells -hier *axis_vio*]

###

#set_property IOSTANDARD LVCMOS12 [get_ports led_cnt_txusrclk]
#set_property IOSTANDARD LVCMOS12 [get_ports led_cnt_rxusrclk]
#set_property IOSTANDARD LVCMOS12 [get_ports led_cnt_freerun]
#set_property IOSTANDARD LVCMOS12 [get_ports led_link_status]
#set_property IOSTANDARD LVSTL_11 [get_ports reset]
create_clock -period 6.734 [get_ports gt_refclk_clk_p]
create_clock -period 6.740 [get_ports gt_refclk2_clk_p]


set_property IOSTANDARD LVCMOS12 [get_ports fzetton_i2c_scl_s00]
set_property IOSTANDARD LVCMOS12 [get_ports fzetton_i2c_sda_s01]
set_property IOSTANDARD LVCMOS12 [get_ports FZETTON_LNH1983_MOSI]
set_property IOSTANDARD LVCMOS12 [get_ports FZETTON_LNH1983_MISO]
set_property IOSTANDARD LVCMOS12 [get_ports FZETTON_LNH1983_SCLK]
set_property IOSTANDARD LVCMOS12 [get_ports FZETTON_DRVR_SEL]
set_property IOSTANDARD LVCMOS12 [get_ports FZETTON_RCLKR_SEL]
set_property IOSTANDARD LVCMOS12 [get_ports FZETTON_RCVR_SEL]
set_property IOSTANDARD LVCMOS12 [get_ports FZETTON_F_SPI_S0_CH_SEL]
set_property IOSTANDARD LVCMOS12 [get_ports FZETTON_LNH1983_INIT]
set_property IOSTANDARD LVCMOS12 [get_ports FZETTON_F_SPI_S1_CH_SEL]
set_property IOSTANDARD LVCMOS12 [get_ports FZETTON_SWT_CH3_DIR]
#set_false_path -through [get_pins -hier *axis_vio*probe*out*]


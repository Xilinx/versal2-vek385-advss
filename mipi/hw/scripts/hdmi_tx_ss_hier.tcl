# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------

################################################################
# This is a generated script based on design: versal_gen2_platform
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2025.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   common::send_gid_msg -ssname BD::TCL -id 2040 -severity "CRITICAL WARNING" "This script was generated using Vivado <$scripts_vivado_version> without IP versions in the create_bd_cell commands, but is now being run in <$current_vivado_version> of Vivado. There may have been changes to the IP between Vivado <$scripts_vivado_version> and <$current_vivado_version>, which could impact the functionality and configuration of the design."

}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source versal_gen2_platform_script.tcl

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:smartconnect:*\
xilinx.com:inline_hdl:ilconstant:*\
xilinx.com:ip:axi_gpio:*\
xilinx.com:ip:v_mix:*\
xilinx.com:inline_hdl:ilslice:*\
xilinx.com:ip:axi_noc2:*\
xilinx.com:ip:v_hdmi_txss1:*\
xilinx.com:ip:axi_iic:*\
xilinx.com:ip:axi_timer:*\
xilinx.com:ip:clkx5_wiz:*\
xilinx.com:ip:util_ds_buf:*\
xilinx.com:ip:hdmi_gt_controller:*\
xilinx.com:inline_hdl:ilreduced_logic:*\
xilinx.com:inline_hdl:ilconcat:*\
xilinx.com:ip:bufg_gt:*\
xilinx.com:ip:gtwiz_versal:*\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: vfmc_ctlr_ss_0
proc create_hier_cell_vfmc_ctlr_ss_0 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_vfmc_ctlr_ss_0() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI


  # Create pins
  create_bd_pin -dir O -from 0 -to 0 VFMC_TX_CH4_FRLSELn
  create_bd_pin -dir O -from 0 -to 0 VFMC_TX_LED0
  create_bd_pin -dir O -from 0 -to 0 VFMC_TX_LED1
  create_bd_pin -dir O -from 0 -to 0 VFMC_RX_CH4_FRLSELn
  create_bd_pin -dir O -from 0 -to 0 VFMC_RX_LED0
  create_bd_pin -dir O -from 0 -to 0 VFMC_RX_LED1
  create_bd_pin -dir O -from 0 -to 0 VFMC_RX_ONSEMI_ENABLE
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn

  # Create instance: vfmc_gpio, and set properties
  set vfmc_gpio [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio vfmc_gpio ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_GPIO_WIDTH {32} \
  ] $vfmc_gpio


  # Create instance: vfmc_slice_bit0, and set properties
  set vfmc_slice_bit0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice vfmc_slice_bit0 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {0} \
    CONFIG.DIN_TO {0} \
    CONFIG.DIN_WIDTH {32} \
    CONFIG.DOUT_WIDTH {1} \
  ] $vfmc_slice_bit0


  # Create instance: vfmc_slice_bit1, and set properties
  set vfmc_slice_bit1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice vfmc_slice_bit1 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {1} \
    CONFIG.DIN_TO {1} \
    CONFIG.DIN_WIDTH {32} \
    CONFIG.DOUT_WIDTH {1} \
  ] $vfmc_slice_bit1


  # Create instance: vfmc_slice_bit2, and set properties
  set vfmc_slice_bit2 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice vfmc_slice_bit2 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {2} \
    CONFIG.DIN_TO {2} \
    CONFIG.DIN_WIDTH {32} \
    CONFIG.DOUT_WIDTH {1} \
  ] $vfmc_slice_bit2


  # Create instance: vfmc_slice_bit16, and set properties
  set vfmc_slice_bit16 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice vfmc_slice_bit16 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {16} \
    CONFIG.DIN_TO {16} \
    CONFIG.DIN_WIDTH {32} \
    CONFIG.DOUT_WIDTH {1} \
  ] $vfmc_slice_bit16


  # Create instance: vfmc_slice_bit17, and set properties
  set vfmc_slice_bit17 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice vfmc_slice_bit17 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {17} \
    CONFIG.DIN_TO {17} \
    CONFIG.DIN_WIDTH {32} \
    CONFIG.DOUT_WIDTH {1} \
  ] $vfmc_slice_bit17


  # Create instance: vfmc_slice_bit18, and set properties
  set vfmc_slice_bit18 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice vfmc_slice_bit18 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {18} \
    CONFIG.DIN_TO {18} \
    CONFIG.DIN_WIDTH {32} \
    CONFIG.DOUT_WIDTH {1} \
  ] $vfmc_slice_bit18


  # Create instance: vfmc_slice_bit19, and set properties
  set vfmc_slice_bit19 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice vfmc_slice_bit19 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {19} \
    CONFIG.DIN_TO {19} \
    CONFIG.DIN_WIDTH {32} \
    CONFIG.DOUT_WIDTH {1} \
  ] $vfmc_slice_bit19


  # Create interface connections
  connect_bd_intf_net -intf_net intf_net_bdry_in_S_AXI [get_bd_intf_pins S_AXI] [get_bd_intf_pins vfmc_gpio/S_AXI]

  # Create port connections
  connect_bd_net -net net_bdry_in_s_axi_aclk  [get_bd_pins s_axi_aclk] \
  [get_bd_pins vfmc_gpio/s_axi_aclk]
  connect_bd_net -net net_bdry_in_s_axi_aresetn  [get_bd_pins s_axi_aresetn] \
  [get_bd_pins vfmc_gpio/s_axi_aresetn]
  connect_bd_net -net net_vfmc_gpio_gpio_io_o  [get_bd_pins vfmc_gpio/gpio_io_o] \
  [get_bd_pins vfmc_slice_bit0/Din] \
  [get_bd_pins vfmc_slice_bit1/Din] \
  [get_bd_pins vfmc_slice_bit2/Din] \
  [get_bd_pins vfmc_slice_bit16/Din] \
  [get_bd_pins vfmc_slice_bit17/Din] \
  [get_bd_pins vfmc_slice_bit18/Din] \
  [get_bd_pins vfmc_slice_bit19/Din]
  connect_bd_net -net net_vfmc_slice_bit0_Dout  [get_bd_pins vfmc_slice_bit0/Dout] \
  [get_bd_pins VFMC_TX_LED0]
  connect_bd_net -net net_vfmc_slice_bit16_Dout  [get_bd_pins vfmc_slice_bit16/Dout] \
  [get_bd_pins VFMC_RX_LED0]
  connect_bd_net -net net_vfmc_slice_bit17_Dout  [get_bd_pins vfmc_slice_bit17/Dout] \
  [get_bd_pins VFMC_RX_LED1]
  connect_bd_net -net net_vfmc_slice_bit18_Dout  [get_bd_pins vfmc_slice_bit18/Dout] \
  [get_bd_pins VFMC_RX_CH4_FRLSELn]
  connect_bd_net -net net_vfmc_slice_bit19_Dout  [get_bd_pins vfmc_slice_bit19/Dout] \
  [get_bd_pins VFMC_RX_ONSEMI_ENABLE]
  connect_bd_net -net net_vfmc_slice_bit1_Dout  [get_bd_pins vfmc_slice_bit1/Dout] \
  [get_bd_pins VFMC_TX_LED1]
  connect_bd_net -net net_vfmc_slice_bit2_Dout  [get_bd_pins vfmc_slice_bit2/Dout] \
  [get_bd_pins VFMC_TX_CH4_FRLSELn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: hdmiphy_ss_0
proc create_hier_cell_hdmiphy_ss_0 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_hdmiphy_ss_0() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 phy_data

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 vid_phy_tx_axi4s_ch0

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 vid_phy_tx_axi4s_ch1

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 vid_phy_tx_axi4s_ch2

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 vid_phy_tx_axi4s_ch3

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 vid_phy_axi4lite

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 vid_phy_status_sb_tx


  # Create pins
  create_bd_pin -dir I -type clk tx_ref_clk_in
  create_bd_pin -dir I -type clk tx_ref_clk_odiv2_in
  create_bd_pin -dir I tx_refclk_rdy
  create_bd_pin -dir I -type clk vid_phy_axi4lite_aclk
  create_bd_pin -dir I -type rst vid_phy_axi4lite_aresetn
  create_bd_pin -dir I -type clk drpclk
  create_bd_pin -dir I -type clk vid_phy_sb_aclk
  create_bd_pin -dir I -type rst vid_phy_sb_aresetn
  create_bd_pin -dir I -type rst vid_phy_tx_axi4s_aresetn
  create_bd_pin -dir O -type clk tx_tmds_clk
  create_bd_pin -dir O -type clk tx_video_clk
  create_bd_pin -dir O -type gt_usrclk txoutclk
  create_bd_pin -dir O irq
  create_bd_pin -dir I -type clk dru_ref_clk_in
  create_bd_pin -dir I -type clk dru_ref_clk_odiv2_in

  # Create instance: hdmi_gt_controller, and set properties
  set hdmi_gt_controller [ create_bd_cell -type ip -vlnv xilinx.com:ip:hdmi_gt_controller hdmi_gt_controller ]
  set_property -dict [list \
    CONFIG.C_GT_DIRECTION {SIMPLEX_TX} \
    CONFIG.C_NEW_WIZ {1} \
    CONFIG.C_RX_PLL_SELECTION {8} \
    CONFIG.C_RX_REFCLK_SEL {0} \
    CONFIG.C_Rx_Protocol {None} \
    CONFIG.C_TX_FRL_REFCLK_SEL {2} \
    CONFIG.C_TX_PLL_SELECTION {7} \
    CONFIG.C_TX_REFCLK_SEL {1} \
    CONFIG.C_Tx_Protocol {HDMI 2.1} \
    CONFIG.C_Txrefclk_Rdy_Invert {true} \
    CONFIG.Rx_GT_Line_Rate {6.0} \
    CONFIG.Rx_GT_Ref_Clock_Freq {400} \
    CONFIG.Tx_GT_Line_Rate {8.0} \
    CONFIG.Tx_GT_Ref_Clock_Freq {400} \
    CONFIG.Tx_Max_GT_Line_Rate {8.0} \
    CONFIG.check_refclk_selection {0} \
  ] $hdmi_gt_controller


  # Create instance: urlp, and set properties
  set urlp [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilreduced_logic urlp ]
  set_property CONFIG.C_SIZE {1} $urlp


  # Create instance: ilcp, and set properties
  set ilcp [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat ilcp ]
  set_property CONFIG.NUM_PORTS {1} $ilcp


  # Create instance: bufg_gt_tx, and set properties
  set bufg_gt_tx [ create_bd_cell -type ip -vlnv xilinx.com:ip:bufg_gt bufg_gt_tx ]
  set_property CONFIG.FREQ_HZ {297000000.0} $bufg_gt_tx


  # Create instance: gtwiz_versal, and set properties
  set gtwiz_versal [ create_bd_cell -type ip -vlnv xilinx.com:ip:gtwiz_versal gtwiz_versal ]
  set_property -dict [list \
    CONFIG.ENABLE_REG_INTERFACE {false} \
    CONFIG.INTF0_GT_DIRECTION {SIMPLEX_TX} \
    CONFIG.INTF0_GT_SETTINGS(GT_DIRECTION) {SIMPLEX_TX} \
    CONFIG.INTF0_GT_SETTINGS(GT_TYPE) {GTYP} \
    CONFIG.INTF0_GT_SETTINGS(LR0_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_TX TX_PLL_TYPE LCPLL TX_DATA_ENCODING RAW TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE TXPROGDIVCLK TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE\
LCPLL TX_LANE_DESKEW_HDMI_ENABLE true TX_REFCLK_SOURCE R2 TX_USER_DATA_WIDTH 20 TX_INT_DATA_WIDTH 20 TX_LINE_RATE 2.5 TX_REFCLK_FREQUENCY 400.00} \
    CONFIG.INTF0_GT_SETTINGS(LR1_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_TX TX_PLL_TYPE LCPLL TX_DATA_ENCODING RAW TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE TXPROGDIVCLK TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE\
LCPLL TX_LANE_DESKEW_HDMI_ENABLE true TX_REFCLK_SOURCE R1 TX_USER_DATA_WIDTH 40 TX_INT_DATA_WIDTH 40 TX_LINE_RATE 1.625 TX_REFCLK_FREQUENCY 162.5} \
    CONFIG.INTF0_GT_SETTINGS(LR2_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_TX TX_PLL_TYPE LCPLL TX_DATA_ENCODING RAW TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE TXPROGDIVCLK TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE\
LCPLL TX_LANE_DESKEW_HDMI_ENABLE true TX_REFCLK_SOURCE R1 TX_USER_DATA_WIDTH 40 TX_INT_DATA_WIDTH 40 TX_LINE_RATE 2.485 TX_REFCLK_FREQUENCY 248.5} \
    CONFIG.INTF0_GT_SETTINGS(LR3_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_TX TX_PLL_TYPE LCPLL TX_DATA_ENCODING RAW TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE TXPROGDIVCLK TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE\
LCPLL TX_LANE_DESKEW_HDMI_ENABLE true TX_REFCLK_SOURCE R1 TX_USER_DATA_WIDTH 40 TX_INT_DATA_WIDTH 40 TX_LINE_RATE 3.700 TX_REFCLK_FREQUENCY 92.5} \
    CONFIG.INTF0_GT_SETTINGS(LR4_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_TX TX_PLL_TYPE LCPLL TX_DATA_ENCODING RAW TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE TXPROGDIVCLK TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE\
LCPLL TX_LANE_DESKEW_HDMI_ENABLE true TX_REFCLK_SOURCE R1 TX_USER_DATA_WIDTH 40 TX_INT_DATA_WIDTH 40 TX_LINE_RATE 5.94 TX_REFCLK_FREQUENCY 148.5} \
    CONFIG.INTF0_GT_SETTINGS(LR5_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_TX TX_PLL_TYPE LCPLL TX_DATA_ENCODING RAW TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE TXPROGDIVCLK TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE\
LCPLL TX_LANE_DESKEW_HDMI_ENABLE true TX_REFCLK_SOURCE R2 TX_USER_DATA_WIDTH 40 TX_INT_DATA_WIDTH 40 TX_LINE_RATE 3.0 TX_REFCLK_FREQUENCY 400.0} \
    CONFIG.INTF0_GT_SETTINGS(LR6_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_TX TX_PLL_TYPE LCPLL TX_DATA_ENCODING RAW TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE TXPROGDIVCLK TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE\
LCPLL TX_LANE_DESKEW_HDMI_ENABLE true TX_REFCLK_SOURCE R2 TX_USER_DATA_WIDTH 40 TX_INT_DATA_WIDTH 40 TX_LINE_RATE 6.0 TX_REFCLK_FREQUENCY 400.0} \
    CONFIG.INTF0_GT_SETTINGS(LR7_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_TX TX_PLL_TYPE LCPLL TX_DATA_ENCODING RAW TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE TXPROGDIVCLK TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE\
LCPLL TX_LANE_DESKEW_HDMI_ENABLE true TX_REFCLK_SOURCE R2 TX_USER_DATA_WIDTH 40 TX_INT_DATA_WIDTH 40 TX_LINE_RATE 8.0 TX_REFCLK_FREQUENCY 400.0} \
    CONFIG.INTF0_GT_SETTINGS(LR8_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_TX TX_PLL_TYPE LCPLL TX_DATA_ENCODING RAW TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE TXPROGDIVCLK TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE\
LCPLL TX_LANE_DESKEW_HDMI_ENABLE true TX_REFCLK_SOURCE R2 TX_USER_DATA_WIDTH 40 TX_INT_DATA_WIDTH 40 TX_LINE_RATE 8.0 TX_REFCLK_FREQUENCY 400.0} \
    CONFIG.INTF0_GT_SETTINGS(LR9_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_TX TX_PLL_TYPE LCPLL TX_DATA_ENCODING RAW TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE TXPROGDIVCLK TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE\
LCPLL TX_LANE_DESKEW_HDMI_ENABLE true TX_REFCLK_SOURCE R2 TX_USER_DATA_WIDTH 40 TX_INT_DATA_WIDTH 40 TX_LINE_RATE 8.0 TX_REFCLK_FREQUENCY 400.0} \
    CONFIG.INTF0_PARENTID {versal_gen2_platform_hdmi_gt_controller_0} \
    CONFIG.INTF_PARENT_PIN_LIST {QUAD0_TX0 /hdmi_tx_ss_hier/hdmi_ss/hdmiphy_ss_0/hdmi_gt_controller/gt_tx0 QUAD0_TX1 /hdmi_tx_ss_hier/hdmi_ss/hdmiphy_ss_0/hdmi_gt_controller/gt_tx1 QUAD0_TX2 /hdmi_tx_ss_hier/hdmi_ss/hdmiphy_ss_0/hdmi_gt_controller/gt_tx2\
QUAD0_TX3 /hdmi_tx_ss_hier/hdmi_ss/hdmiphy_ss_0/hdmi_gt_controller/gt_tx3} \
    CONFIG.NO_OF_INTERFACE {1} \
    CONFIG.QUAD0_CH0_DEBUG_EN {true} \
    CONFIG.QUAD0_CH0_ILORESETDONE_EN {true} \
    CONFIG.QUAD0_CH1_DEBUG_EN {true} \
    CONFIG.QUAD0_CH1_ILORESETDONE_EN {true} \
    CONFIG.QUAD0_CH2_DEBUG_EN {true} \
    CONFIG.QUAD0_CH2_ILORESETDONE_EN {true} \
    CONFIG.QUAD0_CH3_DEBUG_EN {true} \
    CONFIG.QUAD0_CH3_ILORESETDONE_EN {true} \
    CONFIG.QUAD0_GT_DEBUG_EN {true} \
    CONFIG.QUAD0_HSCLK0_LCPLLRESET_EN {true} \
    CONFIG.QUAD0_HSCLK0_LCPLL_LOCK_EN {true} \
    CONFIG.QUAD0_HSCLK0_RPLLRESET_EN {true} \
    CONFIG.QUAD0_HSCLK0_RPLL_LOCK_EN {true} \
    CONFIG.QUAD0_HSCLK1_LCPLLRESET_EN {true} \
    CONFIG.QUAD0_HSCLK1_LCPLL_LOCK_EN {true} \
    CONFIG.QUAD0_HSCLK1_RPLLRESET_EN {true} \
    CONFIG.QUAD0_HSCLK1_RPLL_LOCK_EN {true} \
    CONFIG.QUAD0_NO_PROT {1} \
    CONFIG.QUAD0_PROT0_TX1_EN {true} \
    CONFIG.QUAD0_PROT0_TX2_EN {true} \
    CONFIG.QUAD0_PROT0_TX3_EN {true} \
    CONFIG.QUAD0_REFCLK_STRING {HSCLK0_LCPLLGTREFCLK1 refclk_PROT0_R1_multiple_ext_freq HSCLK0_LCPLLNORTHREFCLK0 refclk_PROT0_R2_400_MHz_unique1 HSCLK1_LCPLLGTREFCLK1 refclk_PROT0_R1_multiple_ext_freq\
HSCLK1_LCPLLNORTHREFCLK0 refclk_PROT0_R2_400_MHz_unique1} \
  ] $gtwiz_versal

  set_property -dict [list \
    CONFIG.INTF0_GT_SETTINGS.VALUE_MODE {auto} \
    CONFIG.INTF0_PARENTID.VALUE_MODE {auto} \
    CONFIG.INTF_PARENT_PIN_LIST.VALUE_MODE {auto} \
  ] $gtwiz_versal


  # Create interface connections
  connect_bd_intf_net -intf_net intf_net_bdry_in_vid_phy_axi4lite [get_bd_intf_pins vid_phy_axi4lite] [get_bd_intf_pins hdmi_gt_controller/axi4lite]
  connect_bd_intf_net -intf_net intf_net_bdry_in_vid_phy_tx_axi4s_ch0 [get_bd_intf_pins vid_phy_tx_axi4s_ch0] [get_bd_intf_pins hdmi_gt_controller/tx_axi4s_ch0]
  connect_bd_intf_net -intf_net intf_net_bdry_in_vid_phy_tx_axi4s_ch1 [get_bd_intf_pins vid_phy_tx_axi4s_ch1] [get_bd_intf_pins hdmi_gt_controller/tx_axi4s_ch1]
  connect_bd_intf_net -intf_net intf_net_bdry_in_vid_phy_tx_axi4s_ch2 [get_bd_intf_pins vid_phy_tx_axi4s_ch2] [get_bd_intf_pins hdmi_gt_controller/tx_axi4s_ch2]
  connect_bd_intf_net -intf_net intf_net_bdry_in_vid_phy_tx_axi4s_ch3 [get_bd_intf_pins vid_phy_tx_axi4s_ch3] [get_bd_intf_pins hdmi_gt_controller/tx_axi4s_ch3]
  connect_bd_intf_net -intf_net intf_net_gtwiz_versal_Quad0_GT_Serial [get_bd_intf_pins gtwiz_versal/Quad0_GT_Serial] [get_bd_intf_pins phy_data]
  connect_bd_intf_net -intf_net intf_net_hdmi_gt_controller_ch0_debug [get_bd_intf_pins hdmi_gt_controller/ch0_debug] [get_bd_intf_pins gtwiz_versal/Quad0_CH0_DEBUG]
  connect_bd_intf_net -intf_net intf_net_hdmi_gt_controller_ch1_debug [get_bd_intf_pins hdmi_gt_controller/ch1_debug] [get_bd_intf_pins gtwiz_versal/Quad0_CH1_DEBUG]
  connect_bd_intf_net -intf_net intf_net_hdmi_gt_controller_ch2_debug [get_bd_intf_pins hdmi_gt_controller/ch2_debug] [get_bd_intf_pins gtwiz_versal/Quad0_CH2_DEBUG]
  connect_bd_intf_net -intf_net intf_net_hdmi_gt_controller_ch3_debug [get_bd_intf_pins hdmi_gt_controller/ch3_debug] [get_bd_intf_pins gtwiz_versal/Quad0_CH3_DEBUG]
  connect_bd_intf_net -intf_net intf_net_hdmi_gt_controller_gt_debug [get_bd_intf_pins hdmi_gt_controller/gt_debug] [get_bd_intf_pins gtwiz_versal/QUAD0_GT_DEBUG]
  connect_bd_intf_net -intf_net intf_net_hdmi_gt_controller_gt_tx0 [get_bd_intf_pins hdmi_gt_controller/gt_tx0] [get_bd_intf_pins gtwiz_versal/INTF0_TX0_GT_IP_Interface]
  connect_bd_intf_net -intf_net intf_net_hdmi_gt_controller_gt_tx1 [get_bd_intf_pins hdmi_gt_controller/gt_tx1] [get_bd_intf_pins gtwiz_versal/INTF0_TX1_GT_IP_Interface]
  connect_bd_intf_net -intf_net intf_net_hdmi_gt_controller_gt_tx2 [get_bd_intf_pins hdmi_gt_controller/gt_tx2] [get_bd_intf_pins gtwiz_versal/INTF0_TX2_GT_IP_Interface]
  connect_bd_intf_net -intf_net intf_net_hdmi_gt_controller_gt_tx3 [get_bd_intf_pins hdmi_gt_controller/gt_tx3] [get_bd_intf_pins gtwiz_versal/INTF0_TX3_GT_IP_Interface]
  connect_bd_intf_net -intf_net intf_net_hdmi_gt_controller_status_sb_tx [get_bd_intf_pins hdmi_gt_controller/status_sb_tx] [get_bd_intf_pins vid_phy_status_sb_tx]

  # Create port connections
  connect_bd_net -net net_bdry_in_drpclk  [get_bd_pins drpclk] \
  [get_bd_pins hdmi_gt_controller/apb_clk] \
  [get_bd_pins gtwiz_versal/gtwiz_freerun_clk]
  connect_bd_net -net net_bdry_in_dru_ref_clk_in  [get_bd_pins dru_ref_clk_in] \
  [get_bd_pins gtwiz_versal/QUAD0_GTREFCLK1]
  connect_bd_net -net net_bdry_in_dru_ref_clk_odiv2_in  [get_bd_pins dru_ref_clk_odiv2_in] \
  [get_bd_pins hdmi_gt_controller/gt_refclk2_odiv2]
  connect_bd_net -net net_bdry_in_tx_ref_clk_in  [get_bd_pins tx_ref_clk_in] \
  [get_bd_pins gtwiz_versal/QUAD0_GTREFCLK0]
  connect_bd_net -net net_bdry_in_tx_ref_clk_odiv2_in  [get_bd_pins tx_ref_clk_odiv2_in] \
  [get_bd_pins hdmi_gt_controller/gt_refclk1_odiv2]
  connect_bd_net -net net_bdry_in_tx_refclk_rdy  [get_bd_pins tx_refclk_rdy] \
  [get_bd_pins hdmi_gt_controller/tx_refclk_rdy]
  connect_bd_net -net net_bdry_in_vid_phy_axi4lite_aclk  [get_bd_pins vid_phy_axi4lite_aclk] \
  [get_bd_pins hdmi_gt_controller/axi4lite_aclk]
  connect_bd_net -net net_bdry_in_vid_phy_axi4lite_aresetn  [get_bd_pins vid_phy_axi4lite_aresetn] \
  [get_bd_pins hdmi_gt_controller/axi4lite_aresetn]
  connect_bd_net -net net_bdry_in_vid_phy_sb_aclk  [get_bd_pins vid_phy_sb_aclk] \
  [get_bd_pins hdmi_gt_controller/sb_aclk]
  connect_bd_net -net net_bdry_in_vid_phy_sb_aresetn  [get_bd_pins vid_phy_sb_aresetn] \
  [get_bd_pins hdmi_gt_controller/sb_aresetn]
  connect_bd_net -net net_bdry_in_vid_phy_tx_axi4s_aresetn  [get_bd_pins vid_phy_tx_axi4s_aresetn] \
  [get_bd_pins hdmi_gt_controller/tx_axi4s_aresetn]
  connect_bd_net -net net_bufg_gt_tx_usrclk  [get_bd_pins bufg_gt_tx/usrclk] \
  [get_bd_pins txoutclk] \
  [get_bd_pins gtwiz_versal/QUAD0_TX0_usrclk] \
  [get_bd_pins gtwiz_versal/QUAD0_TX1_usrclk] \
  [get_bd_pins gtwiz_versal/QUAD0_TX2_usrclk] \
  [get_bd_pins gtwiz_versal/QUAD0_TX3_usrclk] \
  [get_bd_pins hdmi_gt_controller/tx_axi4s_aclk] \
  [get_bd_pins hdmi_gt_controller/gt_txusrclk]
  connect_bd_net -net net_gtwiz_versal_INTF0_rst_tx_done_out  [get_bd_pins gtwiz_versal/INTF0_rst_tx_done_out] \
  [get_bd_pins hdmi_gt_controller/tx_full_rst_done]
  connect_bd_net -net net_gtwiz_versal_QUAD0_TX0_outclk  [get_bd_pins gtwiz_versal/QUAD0_TX0_outclk] \
  [get_bd_pins bufg_gt_tx/outclk]
  connect_bd_net -net net_gtwiz_versal_QUAD0_ch0_iloresetdone  [get_bd_pins gtwiz_versal/QUAD0_ch0_iloresetdone] \
  [get_bd_pins hdmi_gt_controller/gt_ch0_ilo_resetdone]
  connect_bd_net -net net_gtwiz_versal_QUAD0_ch1_iloresetdone  [get_bd_pins gtwiz_versal/QUAD0_ch1_iloresetdone] \
  [get_bd_pins hdmi_gt_controller/gt_ch1_ilo_resetdone]
  connect_bd_net -net net_gtwiz_versal_QUAD0_ch2_iloresetdone  [get_bd_pins gtwiz_versal/QUAD0_ch2_iloresetdone] \
  [get_bd_pins hdmi_gt_controller/gt_ch2_ilo_resetdone]
  connect_bd_net -net net_gtwiz_versal_QUAD0_ch3_iloresetdone  [get_bd_pins gtwiz_versal/QUAD0_ch3_iloresetdone] \
  [get_bd_pins hdmi_gt_controller/gt_ch3_ilo_resetdone]
  connect_bd_net -net net_gtwiz_versal_QUAD0_hsclk0_lcplllock  [get_bd_pins gtwiz_versal/QUAD0_hsclk0_lcplllock] \
  [get_bd_pins hdmi_gt_controller/gt_lcpll0_lock]
  connect_bd_net -net net_gtwiz_versal_QUAD0_hsclk1_lcplllock  [get_bd_pins gtwiz_versal/QUAD0_hsclk1_lcplllock] \
  [get_bd_pins hdmi_gt_controller/gt_lcpll1_lock]
  connect_bd_net -net net_gtwiz_versal_gtpowergood  [get_bd_pins gtwiz_versal/gtpowergood] \
  [get_bd_pins ilcp/In0]
  connect_bd_net -net net_hdmi_gt_controller_gt_lcpll0_reset  [get_bd_pins hdmi_gt_controller/gt_lcpll0_reset] \
  [get_bd_pins gtwiz_versal/QUAD0_hsclk0_lcpllreset]
  connect_bd_net -net net_hdmi_gt_controller_gt_lcpll1_reset  [get_bd_pins hdmi_gt_controller/gt_lcpll1_reset] \
  [get_bd_pins gtwiz_versal/QUAD0_hsclk1_lcpllreset]
  connect_bd_net -net net_hdmi_gt_controller_irq  [get_bd_pins hdmi_gt_controller/irq] \
  [get_bd_pins irq]
  connect_bd_net -net net_hdmi_gt_controller_reset_tx_datapath  [get_bd_pins hdmi_gt_controller/reset_tx_datapath] \
  [get_bd_pins gtwiz_versal/INTF0_rst_tx_datapath_in]
  connect_bd_net -net net_hdmi_gt_controller_reset_tx_pll_and_datapath  [get_bd_pins hdmi_gt_controller/reset_tx_pll_and_datapath] \
  [get_bd_pins gtwiz_versal/INTF0_rst_tx_pll_and_datapath_in]
  connect_bd_net -net net_hdmi_gt_controller_tx_full_rst  [get_bd_pins hdmi_gt_controller/tx_full_rst] \
  [get_bd_pins gtwiz_versal/INTF0_rst_all_in]
  connect_bd_net -net net_hdmi_gt_controller_tx_tmds_clk  [get_bd_pins hdmi_gt_controller/tx_tmds_clk] \
  [get_bd_pins tx_tmds_clk]
  connect_bd_net -net net_hdmi_gt_controller_tx_video_clk  [get_bd_pins hdmi_gt_controller/tx_video_clk] \
  [get_bd_pins tx_video_clk]
  connect_bd_net -net net_ilcp_dout  [get_bd_pins ilcp/dout] \
  [get_bd_pins urlp/Op1]
  connect_bd_net -net net_urlp_Res  [get_bd_pins urlp/Res] \
  [get_bd_pins hdmi_gt_controller/gtpowergood]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: gt_refclk_buf_ss_1
proc create_hier_cell_gt_refclk_buf_ss_1 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_gt_refclk_buf_ss_1() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 IBUFDSGT_IN


  # Create pins
  create_bd_pin -dir O -from 0 -to 0 IBUFDSGT_OUT
  create_bd_pin -dir O -from 0 -to 0 IBUFDSGT_ODIV2_OUT

  # Create instance: bufg_gt, and set properties
  set bufg_gt [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf bufg_gt ]
  set_property CONFIG.C_BUF_TYPE {BUFG_GT} $bufg_gt


  # Create instance: ibufdsgte, and set properties
  set ibufdsgte [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf ibufdsgte ]
  set_property CONFIG.C_BUF_TYPE {IBUFDSGTE} $ibufdsgte


  # Create instance: vcc_const, and set properties
  set vcc_const [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant vcc_const ]
  set_property CONFIG.CONST_VAL {1} $vcc_const


  # Create interface connections
  connect_bd_intf_net -intf_net intf_net_bdry_in_IBUFDSGT_IN [get_bd_intf_pins IBUFDSGT_IN] [get_bd_intf_pins ibufdsgte/CLK_IN_D]

  # Create port connections
  connect_bd_net -net net_bufg_gt_BUFG_GT_O  [get_bd_pins bufg_gt/BUFG_GT_O] \
  [get_bd_pins IBUFDSGT_ODIV2_OUT]
  connect_bd_net -net net_ibufdsgte_IBUF_DS_ODIV2  [get_bd_pins ibufdsgte/IBUF_DS_ODIV2] \
  [get_bd_pins bufg_gt/BUFG_GT_I]
  connect_bd_net -net net_ibufdsgte_IBUF_OUT  [get_bd_pins ibufdsgte/IBUF_OUT] \
  [get_bd_pins IBUFDSGT_OUT]
  connect_bd_net -net net_vcc_const_dout  [get_bd_pins vcc_const/dout] \
  [get_bd_pins bufg_gt/BUFG_GT_CE]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: gt_refclk_buf_ss_0
proc create_hier_cell_gt_refclk_buf_ss_0 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_gt_refclk_buf_ss_0() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 IBUFDSGT_IN


  # Create pins
  create_bd_pin -dir O -from 0 -to 0 IBUFDSGT_OUT
  create_bd_pin -dir O -from 0 -to 0 IBUFDSGT_ODIV2_OUT

  # Create instance: bufg_gt, and set properties
  set bufg_gt [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf bufg_gt ]
  set_property CONFIG.C_BUF_TYPE {BUFG_GT} $bufg_gt


  # Create instance: ibufdsgte, and set properties
  set ibufdsgte [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf ibufdsgte ]
  set_property CONFIG.C_BUF_TYPE {IBUFDSGTE} $ibufdsgte


  # Create instance: vcc_const, and set properties
  set vcc_const [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant vcc_const ]
  set_property CONFIG.CONST_VAL {1} $vcc_const


  # Create interface connections
  connect_bd_intf_net -intf_net intf_net_bdry_in_IBUFDSGT_IN [get_bd_intf_pins IBUFDSGT_IN] [get_bd_intf_pins ibufdsgte/CLK_IN_D]

  # Create port connections
  connect_bd_net -net net_bufg_gt_BUFG_GT_O  [get_bd_pins bufg_gt/BUFG_GT_O] \
  [get_bd_pins IBUFDSGT_ODIV2_OUT]
  connect_bd_net -net net_ibufdsgte_IBUF_DS_ODIV2  [get_bd_pins ibufdsgte/IBUF_DS_ODIV2] \
  [get_bd_pins bufg_gt/BUFG_GT_I]
  connect_bd_net -net net_ibufdsgte_IBUF_OUT  [get_bd_pins ibufdsgte/IBUF_OUT] \
  [get_bd_pins IBUFDSGT_OUT]
  connect_bd_net -net net_vcc_const_dout  [get_bd_pins vcc_const/dout] \
  [get_bd_pins bufg_gt/BUFG_GT_CE]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: hdmi_ss
proc create_hier_cell_hdmi_ss { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_hdmi_ss() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_CPU_IN

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 VIDEO_IN

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_IIC

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 GT_DRU_FRL_CLK_IN

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 TX_REFCLK_P_IN_V

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 GT_Serial

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 vid_phy_axi4lite

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_VFMC

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_TIMER

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 TX_DDC_OUT

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 HDMI_CTRL


  # Create pins
  create_bd_pin -dir I -type clk vid_phy_sb_aclk
  create_bd_pin -dir I -type rst vid_phy_sb_aresetn
  create_bd_pin -dir I TX_HPD_IN
  create_bd_pin -dir O -type intr hdmi_tx_irq
  create_bd_pin -dir O LED0
  create_bd_pin -dir I -type clk s_axis_video_aclk
  create_bd_pin -dir I -type rst s_axis_video_aresetn
  create_bd_pin -dir I IDT8T49N241_LOL_IN
  create_bd_pin -dir O vphy_irq
  create_bd_pin -dir O -from 0 -to 0 TX_TI_ENABLE
  create_bd_pin -dir O -from 0 -to 0 RX_TI_ENABLE
  create_bd_pin -dir O -type intr timer_irq
  create_bd_pin -dir O -type intr iic_irq

  # Create instance: v_hdmi_txss1, and set properties
  set v_hdmi_txss1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_hdmi_txss1 v_hdmi_txss1 ]
  set_property -dict [list \
    CONFIG.C_ADDR_WIDTH {10} \
    CONFIG.C_ADD_CORE_DBG {0} \
    CONFIG.C_ADD_MARK_DBG {false} \
    CONFIG.C_DYNAMIC_HDR {0} \
    CONFIG.C_EXDES_RX_PLL_SELECTION {8} \
    CONFIG.C_EXDES_TX_PLL_SELECTION {7} \
    CONFIG.C_HPD_INVERT {true} \
    CONFIG.C_HYSTERESIS_LEVEL {511} \
    CONFIG.C_INCLUDE_HDCP {false} \
    CONFIG.C_INCLUDE_HDCP_1_4 {false} \
    CONFIG.C_INCLUDE_HDCP_2_2 {false} \
    CONFIG.C_INPUT_PIXELS_PER_CLOCK {4} \
    CONFIG.C_MAX_BITS_PER_COMPONENT {10} \
    CONFIG.C_VALIDATION_ENABLE {false} \
    CONFIG.C_VIDEO_MASK_ENABLE {1} \
    CONFIG.C_VID_INTERFACE {0} \
    CONFIG.C_VRR_SUPPORT {1} \
  ] $v_hdmi_txss1


  # Create instance: ilconstant_0, and set properties
  set ilconstant_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant ilconstant_0 ]
  set_property CONFIG.CONST_VAL {0} $ilconstant_0


  # Create instance: vcc_const, and set properties
  set vcc_const [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant vcc_const ]
  set_property CONFIG.CONST_VAL {1} $vcc_const


  # Create instance: axi_iic_hdmi, and set properties
  set axi_iic_hdmi [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic axi_iic_hdmi ]
  set_property CONFIG.TEN_BIT_ADR {7_bit} $axi_iic_hdmi


  # Create instance: gt_refclk_buf_ss_0
  create_hier_cell_gt_refclk_buf_ss_0 $hier_obj gt_refclk_buf_ss_0

  # Create instance: gt_refclk_buf_ss_1
  create_hier_cell_gt_refclk_buf_ss_1 $hier_obj gt_refclk_buf_ss_1

  # Create instance: hdmiphy_ss_0
  create_hier_cell_hdmiphy_ss_0 $hier_obj hdmiphy_ss_0

  # Create instance: vfmc_ctlr_ss_0
  create_hier_cell_vfmc_ctlr_ss_0 $hier_obj vfmc_ctlr_ss_0

  # Create instance: axi_timer_hdmi, and set properties
  set axi_timer_hdmi [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer axi_timer_hdmi ]
  set_property CONFIG.COUNT_WIDTH {32} $axi_timer_hdmi


  # Create instance: clkx5_wiz_hdmi, and set properties
  set clkx5_wiz_hdmi [ create_bd_cell -type ip -vlnv xilinx.com:ip:clkx5_wiz clkx5_wiz_hdmi ]
  set_property -dict [list \
    CONFIG.CLKOUT_DRIVES {BUFG,BUFG,BUFG,BUFG,BUFG,BUFG,BUFG} \
    CONFIG.CLKOUT_DYN_PS {None,None,None,None,None,None,None} \
    CONFIG.CLKOUT_GROUPING {Auto,Auto,Auto,Auto,Auto,Auto,Auto} \
    CONFIG.CLKOUT_MATCHED_ROUTING {false,false,false,false,false,false,false} \
    CONFIG.CLKOUT_PORT {clk_out1,clk_out2,clk_out3,clk_out4,clk_out5,clk_out6,clk_out7} \
    CONFIG.CLKOUT_REQUESTED_DUTY_CYCLE {50.000,50.000,50.000,50.000,50.000,50.000,50.000} \
    CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {450,100.000,100.000,100.000,100.000,100.000,100.000} \
    CONFIG.CLKOUT_REQUESTED_PHASE {0.000,0.000,0.000,0.000,0.000,0.000,0.000} \
    CONFIG.CLKOUT_USED {true,false,false,false,false,false,false} \
    CONFIG.PRIM_SOURCE {No_buffer} \
    CONFIG.RESET_TYPE {ACTIVE_LOW} \
    CONFIG.USE_RESET {true} \
  ] $clkx5_wiz_hdmi


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins v_hdmi_txss1/DDC_OUT] [get_bd_intf_pins TX_DDC_OUT]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins axi_iic_hdmi/IIC] [get_bd_intf_pins HDMI_CTRL]
  connect_bd_intf_net -intf_net S_AXI_1 [get_bd_intf_pins S_AXI_TIMER] [get_bd_intf_pins axi_timer_hdmi/S_AXI]
  connect_bd_intf_net -intf_net cips_ss_0_M07_AXI1 [get_bd_intf_pins S_AXI_IIC] [get_bd_intf_pins axi_iic_hdmi/S_AXI]
  connect_bd_intf_net -intf_net intf_net_bdry_in_GT_DRU_FRL_CLK_IN [get_bd_intf_pins GT_DRU_FRL_CLK_IN] [get_bd_intf_pins gt_refclk_buf_ss_0/IBUFDSGT_IN]
  connect_bd_intf_net -intf_net intf_net_bdry_in_TX_REFCLK_P_IN_V [get_bd_intf_pins TX_REFCLK_P_IN_V] [get_bd_intf_pins gt_refclk_buf_ss_1/IBUFDSGT_IN]
  connect_bd_intf_net -intf_net intf_net_cips_ss_0_M00_AXI [get_bd_intf_pins vid_phy_axi4lite] [get_bd_intf_pins hdmiphy_ss_0/vid_phy_axi4lite]
  connect_bd_intf_net -intf_net intf_net_cips_ss_0_M02_AXI [get_bd_intf_pins S_AXI_CPU_IN] [get_bd_intf_pins v_hdmi_txss1/S_AXI_CPU_IN]
  connect_bd_intf_net -intf_net intf_net_cips_ss_0_M08_AXI [get_bd_intf_pins S_AXI_VFMC] [get_bd_intf_pins vfmc_ctlr_ss_0/S_AXI]
  connect_bd_intf_net -intf_net intf_net_hdmiphy_ss_0_phy_data [get_bd_intf_pins GT_Serial] [get_bd_intf_pins hdmiphy_ss_0/phy_data]
  connect_bd_intf_net -intf_net intf_net_hdmiphy_ss_0_vid_phy_status_sb_tx [get_bd_intf_pins hdmiphy_ss_0/vid_phy_status_sb_tx] [get_bd_intf_pins v_hdmi_txss1/SB_STATUS_IN]
  connect_bd_intf_net -intf_net intf_net_v_hdmi_txss1_LINK_DATA0_OUT [get_bd_intf_pins v_hdmi_txss1/LINK_DATA0_OUT] [get_bd_intf_pins hdmiphy_ss_0/vid_phy_tx_axi4s_ch0]
  connect_bd_intf_net -intf_net intf_net_v_hdmi_txss1_LINK_DATA1_OUT [get_bd_intf_pins v_hdmi_txss1/LINK_DATA1_OUT] [get_bd_intf_pins hdmiphy_ss_0/vid_phy_tx_axi4s_ch1]
  connect_bd_intf_net -intf_net intf_net_v_hdmi_txss1_LINK_DATA2_OUT [get_bd_intf_pins v_hdmi_txss1/LINK_DATA2_OUT] [get_bd_intf_pins hdmiphy_ss_0/vid_phy_tx_axi4s_ch2]
  connect_bd_intf_net -intf_net intf_net_v_hdmi_txss1_LINK_DATA3_OUT [get_bd_intf_pins v_hdmi_txss1/LINK_DATA3_OUT] [get_bd_intf_pins hdmiphy_ss_0/vid_phy_tx_axi4s_ch3]
  connect_bd_intf_net -intf_net vmix_ss_m_axis_video [get_bd_intf_pins VIDEO_IN] [get_bd_intf_pins v_hdmi_txss1/VIDEO_IN]

  # Create port connections
  connect_bd_net -net axi_iic_hdmi_iic2intc_irpt  [get_bd_pins axi_iic_hdmi/iic2intc_irpt] \
  [get_bd_pins iic_irq]
  connect_bd_net -net axi_timer_hdmi_interrupt  [get_bd_pins axi_timer_hdmi/interrupt] \
  [get_bd_pins timer_irq]
  connect_bd_net -net clkx5_wiz_hdmi_clk_out1  [get_bd_pins clkx5_wiz_hdmi/clk_out1] \
  [get_bd_pins v_hdmi_txss1/frl_clk]
  connect_bd_net -net ilconstant_0_dout  [get_bd_pins ilconstant_0/dout] \
  [get_bd_pins v_hdmi_txss1/s_axis_audio_aclk] \
  [get_bd_pins v_hdmi_txss1/fid]
  connect_bd_net -net net_bdry_in_IDT8T49N241_LOL_IN  [get_bd_pins IDT8T49N241_LOL_IN] \
  [get_bd_pins hdmiphy_ss_0/tx_refclk_rdy]
  connect_bd_net -net net_bdry_in_TX_HPD_IN  [get_bd_pins TX_HPD_IN] \
  [get_bd_pins v_hdmi_txss1/hpd]
  connect_bd_net -net net_cips_ss_0_clk_out2  [get_bd_pins s_axis_video_aclk] \
  [get_bd_pins v_hdmi_txss1/s_axis_video_aclk]
  connect_bd_net -net net_cips_ss_0_dcm_locked  [get_bd_pins s_axis_video_aresetn] \
  [get_bd_pins v_hdmi_txss1/s_axis_video_aresetn]
  connect_bd_net -net net_cips_ss_0_peripheral_aresetn  [get_bd_pins vid_phy_sb_aresetn] \
  [get_bd_pins hdmiphy_ss_0/vid_phy_sb_aresetn] \
  [get_bd_pins hdmiphy_ss_0/vid_phy_axi4lite_aresetn] \
  [get_bd_pins vfmc_ctlr_ss_0/s_axi_aresetn] \
  [get_bd_pins axi_iic_hdmi/s_axi_aresetn] \
  [get_bd_pins axi_timer_hdmi/s_axi_aresetn] \
  [get_bd_pins clkx5_wiz_hdmi/resetn] \
  [get_bd_pins v_hdmi_txss1/s_axi_cpu_aresetn]
  connect_bd_net -net net_cips_ss_0_s_axi_aclk  [get_bd_pins vid_phy_sb_aclk] \
  [get_bd_pins hdmiphy_ss_0/vid_phy_sb_aclk] \
  [get_bd_pins hdmiphy_ss_0/vid_phy_axi4lite_aclk] \
  [get_bd_pins vfmc_ctlr_ss_0/s_axi_aclk] \
  [get_bd_pins hdmiphy_ss_0/drpclk] \
  [get_bd_pins axi_iic_hdmi/s_axi_aclk] \
  [get_bd_pins axi_timer_hdmi/s_axi_aclk] \
  [get_bd_pins clkx5_wiz_hdmi/clk_in1] \
  [get_bd_pins v_hdmi_txss1/s_axi_cpu_aclk]
  connect_bd_net -net net_gt_refclk_buf_ss_0_IBUFDSGT_ODIV2_OUT  [get_bd_pins gt_refclk_buf_ss_0/IBUFDSGT_ODIV2_OUT] \
  [get_bd_pins hdmiphy_ss_0/dru_ref_clk_odiv2_in]
  connect_bd_net -net net_gt_refclk_buf_ss_0_IBUFDSGT_OUT  [get_bd_pins gt_refclk_buf_ss_0/IBUFDSGT_OUT] \
  [get_bd_pins hdmiphy_ss_0/dru_ref_clk_in]
  connect_bd_net -net net_gt_refclk_buf_ss_1_IBUFDSGT_ODIV2_OUT  [get_bd_pins gt_refclk_buf_ss_1/IBUFDSGT_ODIV2_OUT] \
  [get_bd_pins hdmiphy_ss_0/tx_ref_clk_odiv2_in]
  connect_bd_net -net net_gt_refclk_buf_ss_1_IBUFDSGT_OUT  [get_bd_pins gt_refclk_buf_ss_1/IBUFDSGT_OUT] \
  [get_bd_pins hdmiphy_ss_0/tx_ref_clk_in]
  connect_bd_net -net net_hdmiphy_ss_0_irq  [get_bd_pins hdmiphy_ss_0/irq] \
  [get_bd_pins vphy_irq]
  connect_bd_net -net net_hdmiphy_ss_0_tx_video_clk  [get_bd_pins hdmiphy_ss_0/tx_video_clk] \
  [get_bd_pins v_hdmi_txss1/video_clk]
  connect_bd_net -net net_hdmiphy_ss_0_txoutclk  [get_bd_pins hdmiphy_ss_0/txoutclk] \
  [get_bd_pins v_hdmi_txss1/link_clk]
  connect_bd_net -net net_v_hdmi_txss1_irq  [get_bd_pins v_hdmi_txss1/irq] \
  [get_bd_pins hdmi_tx_irq]
  connect_bd_net -net net_v_hdmi_txss1_locked  [get_bd_pins v_hdmi_txss1/locked] \
  [get_bd_pins LED0]
  connect_bd_net -net net_vcc_const_dout  [get_bd_pins vcc_const/dout] \
  [get_bd_pins hdmiphy_ss_0/vid_phy_tx_axi4s_aresetn] \
  [get_bd_pins v_hdmi_txss1/video_cke_in]
  connect_bd_net -net net_vfmc_ctlr_ss_0_VFMC_RX_ONSEMI_ENABLE  [get_bd_pins vfmc_ctlr_ss_0/VFMC_RX_ONSEMI_ENABLE] \
  [get_bd_pins TX_TI_ENABLE] \
  [get_bd_pins RX_TI_ENABLE]

  # Perform GUI Layout
  regenerate_bd_layout -hierarchy [get_bd_cells /hdmi_tx_ss_hier/hdmi_ss] -layout_string {
   "ActiveEmotionalView":"Default View",
   "Default View_ScaleFactor":"0.551343",
   "Default View_TopLeft":"-755,-7",
   "ExpandedHierarchyInLayout":"",
   "guistr":"# # String gsaved with Nlview 7.8.0 2024-04-26 e1825d835c VDI=44 GEI=38 GUI=JA:21.0 TLS
#  -string -flagsOSRD
preplace port S_AXI_CPU_IN -pg 1 -lvl 0 -x 0 -y 780 -defaultsOSRD
preplace port VIDEO_IN -pg 1 -lvl 0 -x 0 -y 840 -defaultsOSRD
preplace port S_AXI_IIC -pg 1 -lvl 0 -x 0 -y 670 -defaultsOSRD
preplace port GT_DRU_FRL_CLK_IN -pg 1 -lvl 0 -x 0 -y 570 -defaultsOSRD
preplace port TX_REFCLK_P_IN_V -pg 1 -lvl 0 -x 0 -y 160 -defaultsOSRD
preplace port GT_Serial -pg 1 -lvl 4 -x 1110 -y 380 -defaultsOSRD
preplace port vid_phy_axi4lite -pg 1 -lvl 0 -x 0 -y 360 -defaultsOSRD
preplace port S_AXI_VFMC -pg 1 -lvl 0 -x 0 -y 90 -defaultsOSRD
preplace port S_AXI_TIMER -pg 1 -lvl 0 -x 0 -y 710 -defaultsOSRD
preplace port TX_DDC_OUT -pg 1 -lvl 4 -x 1110 -y 980 -defaultsOSRD
preplace port HDMI_CTRL -pg 1 -lvl 4 -x 1110 -y 670 -defaultsOSRD
preplace port port-id_vid_phy_sb_aclk -pg 1 -lvl 0 -x 0 -y 880 -defaultsOSRD
preplace port port-id_vid_phy_sb_aresetn -pg 1 -lvl 0 -x 0 -y 860 -defaultsOSRD
preplace port port-id_TX_HPD_IN -pg 1 -lvl 0 -x 0 -y 1100 -defaultsOSRD
preplace port port-id_hdmi_tx_irq -pg 1 -lvl 4 -x 1110 -y 1000 -defaultsOSRD
preplace port port-id_LED0 -pg 1 -lvl 4 -x 1110 -y 1020 -defaultsOSRD
preplace port port-id_s_axis_video_aclk -pg 1 -lvl 0 -x 0 -y 1220 -defaultsOSRD
preplace port port-id_s_axis_video_aresetn -pg 1 -lvl 0 -x 0 -y 1240 -defaultsOSRD
preplace port port-id_IDT8T49N241_LOL_IN -pg 1 -lvl 0 -x 0 -y 420 -defaultsOSRD
preplace port port-id_vphy_irq -pg 1 -lvl 4 -x 1110 -y 480 -defaultsOSRD
preplace port port-id_timer_irq -pg 1 -lvl 4 -x 1110 -y 890 -defaultsOSRD
preplace port port-id_iic_irq -pg 1 -lvl 4 -x 1110 -y 690 -defaultsOSRD
preplace portBus TX_TI_ENABLE -pg 1 -lvl 4 -x 1110 -y 170 -defaultsOSRD
preplace portBus RX_TI_ENABLE -pg 1 -lvl 4 -x 1110 -y 150 -defaultsOSRD
preplace inst v_hdmi_txss1 -pg 1 -lvl 2 -x 450 -y 960 -defaultsOSRD
preplace inst ilconstant_0 -pg 1 -lvl 1 -x 130 -y 1040 -defaultsOSRD
preplace inst vcc_const -pg 1 -lvl 1 -x 130 -y 1160 -defaultsOSRD
preplace inst axi_iic_hdmi -pg 1 -lvl 3 -x 890 -y 690 -defaultsOSRD
preplace inst gt_refclk_buf_ss_0 -pg 1 -lvl 2 -x 450 -y 570 -defaultsOSRD
preplace inst gt_refclk_buf_ss_1 -pg 1 -lvl 2 -x 450 -y 160 -defaultsOSRD
preplace inst hdmiphy_ss_0 -pg 1 -lvl 3 -x 890 -y 430 -defaultsOSRD
preplace inst vfmc_ctlr_ss_0 -pg 1 -lvl 3 -x 890 -y 110 -defaultsOSRD
preplace inst axi_timer_hdmi -pg 1 -lvl 3 -x 890 -y 860 -defaultsOSRD
preplace inst clkx5_wiz_hdmi -pg 1 -lvl 1 -x 130 -y 930 -defaultsOSRD
preplace netloc axi_iic_hdmi_iic2intc_irpt 1 3 1 NJ 690
preplace netloc axi_timer_hdmi_interrupt 1 3 1 NJ 890
preplace netloc clkx5_wiz_hdmi_clk_out1 1 1 1 260 930n
preplace netloc ilconstant_0_dout 1 1 1 230 920n
preplace netloc net_bdry_in_IDT8T49N241_LOL_IN 1 0 3 NJ 420 NJ 420 NJ
preplace netloc net_bdry_in_TX_HPD_IN 1 0 2 NJ 1100 240J
preplace netloc net_cips_ss_0_clk_out2 1 0 2 NJ 1220 260J
preplace netloc net_cips_ss_0_dcm_locked 1 0 2 NJ 1240 270J
preplace netloc net_cips_ss_0_peripheral_aresetn 1 0 3 20 850 270 630 670
preplace netloc net_cips_ss_0_s_axi_aclk 1 0 3 30 860 260 640 660
preplace netloc net_gt_refclk_buf_ss_0_IBUFDSGT_ODIV2_OUT 1 2 1 N 580
preplace netloc net_gt_refclk_buf_ss_0_IBUFDSGT_OUT 1 2 1 N 560
preplace netloc net_gt_refclk_buf_ss_1_IBUFDSGT_ODIV2_OUT 1 2 1 650 170n
preplace netloc net_gt_refclk_buf_ss_1_IBUFDSGT_OUT 1 2 1 690 150n
preplace netloc net_hdmiphy_ss_0_irq 1 3 1 NJ 480
preplace netloc net_hdmiphy_ss_0_tx_video_clk 1 1 3 290 1200 NJ 1200 1090
preplace netloc net_hdmiphy_ss_0_txoutclk 1 1 3 280 720 610J 970 1080
preplace netloc net_v_hdmi_txss1_irq 1 2 2 NJ 1000 NJ
preplace netloc net_v_hdmi_txss1_locked 1 2 2 NJ 1020 NJ
preplace netloc net_vcc_const_dout 1 1 2 250 650 650J
preplace netloc net_vfmc_ctlr_ss_0_VFMC_RX_ONSEMI_ENABLE 1 3 1 1090 150n
preplace netloc Conn1 1 2 2 NJ 980 NJ
preplace netloc Conn2 1 3 1 NJ 670
preplace netloc S_AXI_1 1 0 3 NJ 710 NJ 710 630J
preplace netloc cips_ss_0_M07_AXI1 1 0 3 NJ 670 NJ 670 NJ
preplace netloc intf_net_bdry_in_GT_DRU_FRL_CLK_IN 1 0 2 NJ 570 NJ
preplace netloc intf_net_bdry_in_TX_REFCLK_P_IN_V 1 0 2 NJ 160 NJ
preplace netloc intf_net_cips_ss_0_M00_AXI 1 0 3 NJ 360 NJ 360 NJ
preplace netloc intf_net_cips_ss_0_M02_AXI 1 0 2 NJ 780 NJ
preplace netloc intf_net_cips_ss_0_M08_AXI 1 0 3 NJ 90 NJ 90 NJ
preplace netloc intf_net_hdmiphy_ss_0_phy_data 1 3 1 NJ 380
preplace netloc intf_net_hdmiphy_ss_0_vid_phy_status_sb_tx 1 1 3 290 220 NJ 220 1090
preplace netloc intf_net_v_hdmi_txss1_LINK_DATA0_OUT 1 2 1 620 280n
preplace netloc intf_net_v_hdmi_txss1_LINK_DATA1_OUT 1 2 1 640 300n
preplace netloc intf_net_v_hdmi_txss1_LINK_DATA2_OUT 1 2 1 680 320n
preplace netloc intf_net_v_hdmi_txss1_LINK_DATA3_OUT 1 2 1 700 340n
preplace netloc vmix_ss_m_axis_video 1 0 2 NJ 840 NJ
levelinfo -pg 1 0 130 450 890 1110
pagesize -pg 1 -db -bbox -sgen -200 0 1290 1260
"
}

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: vmix_ss
proc create_hier_cell_vmix_ss { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_vmix_ss() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axit_ctrl_vmix_gpio

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_ctrl_vmix

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 vmix_M00_INI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 vmix_M01_INI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_vmix_video_out


  # Create pins
  create_bd_pin -dir I -type clk s_axis_video_aclk
  create_bd_pin -dir I -type rst s_axis_video_aresetn
  create_bd_pin -dir O -type intr mixer_irq

  # Create instance: ilconstant_1, and set properties
  set ilconstant_1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant ilconstant_1 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {120} \
  ] $ilconstant_1


  # Create instance: vmix_rst_gpio, and set properties
  set vmix_rst_gpio [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio vmix_rst_gpio ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_DOUT_DEFAULT {0x00000003} \
    CONFIG.C_GPIO_WIDTH {2} \
  ] $vmix_rst_gpio


  # Create instance: v_mix, and set properties
  set v_mix [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_mix v_mix ]
  set_property -dict [list \
    CONFIG.AXIMM_ADDR_WIDTH {64} \
    CONFIG.AXIMM_DATA_WIDTH {256} \
    CONFIG.LAYER1_ALPHA {true} \
    CONFIG.LAYER1_INTF_TYPE {0} \
    CONFIG.LAYER1_VIDEO_FORMAT {20} \
    CONFIG.LAYER2_ALPHA {true} \
    CONFIG.LAYER2_INTF_TYPE {0} \
    CONFIG.LAYER2_VIDEO_FORMAT {20} \
    CONFIG.LAYER3_ALPHA {true} \
    CONFIG.LAYER3_INTF_TYPE {0} \
    CONFIG.LAYER3_VIDEO_FORMAT {20} \
    CONFIG.LAYER4_ALPHA {true} \
    CONFIG.LAYER4_INTF_TYPE {0} \
    CONFIG.LAYER4_VIDEO_FORMAT {20} \
    CONFIG.LAYER5_ALPHA {true} \
    CONFIG.LAYER5_INTF_TYPE {0} \
    CONFIG.LAYER5_VIDEO_FORMAT {24} \
    CONFIG.LAYER6_ALPHA {true} \
    CONFIG.LAYER6_INTF_TYPE {0} \
    CONFIG.LAYER6_VIDEO_FORMAT {20} \
    CONFIG.MAX_DATA_WIDTH {10} \
    CONFIG.NR_LAYERS {6} \
    CONFIG.SAMPLES_PER_CLOCK {4} \
    CONFIG.VIDEO_FORMAT {0} \
  ] $v_mix


  # Create instance: ilslice_vmix_gpio, and set properties
  set ilslice_vmix_gpio [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice ilslice_vmix_gpio ]
  set_property -dict [list \
    CONFIG.DIN_FROM {1} \
    CONFIG.DIN_TO {1} \
    CONFIG.DIN_WIDTH {2} \
  ] $ilslice_vmix_gpio


  # Create instance: axi_noc2_frmbuf, and set properties
  set axi_noc2_frmbuf [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc2 axi_noc2_frmbuf ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {1} \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NMI {2} \
    CONFIG.NUM_SI {5} \
  ] $axi_noc2_frmbuf


  set_property -dict [ list \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.R_TRAFFIC_CLASS {ISOCHRONOUS} \
   CONFIG.CONNECTIONS {M00_INI {read_bw {1100} write_bw {100} }} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins $axi_noc2_frmbuf/S00_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.R_TRAFFIC_CLASS {ISOCHRONOUS} \
   CONFIG.CONNECTIONS {M01_INI {read_bw {1100} write_bw {100} }} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins $axi_noc2_frmbuf/S01_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.R_TRAFFIC_CLASS {ISOCHRONOUS} \
   CONFIG.CONNECTIONS {M00_INI {read_bw {1100} write_bw {100} }} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins $axi_noc2_frmbuf/S02_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.R_TRAFFIC_CLASS {ISOCHRONOUS} \
   CONFIG.CONNECTIONS {M01_INI {read_bw {1100} write_bw {100} }} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins $axi_noc2_frmbuf/S03_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.R_TRAFFIC_CLASS {ISOCHRONOUS} \
   CONFIG.CONNECTIONS {M01_INI {read_bw {1100} write_bw {100} }} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins $axi_noc2_frmbuf/S04_AXI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXI:S01_AXI:S02_AXI:S03_AXI:S04_AXI} \
 ] [get_bd_pins $axi_noc2_frmbuf/aclk0]

  # Create interface connections
  connect_bd_intf_net -intf_net Conn0 [get_bd_intf_pins axi_noc2_frmbuf/M00_INI] [get_bd_intf_pins vmix_M00_INI]
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins axi_noc2_frmbuf/M01_INI] [get_bd_intf_pins vmix_M01_INI]
  connect_bd_intf_net -intf_net s_axi_ctrl_vmix_1 [get_bd_intf_pins s_axi_ctrl_vmix] [get_bd_intf_pins v_mix/s_axi_CTRL]
  connect_bd_intf_net -intf_net s_axit_ctrl_vmix_gpio_1 [get_bd_intf_pins s_axit_ctrl_vmix_gpio] [get_bd_intf_pins vmix_rst_gpio/S_AXI]
  connect_bd_intf_net -intf_net v_mix_m_axi_mm_video1 [get_bd_intf_pins v_mix/m_axi_mm_video1] [get_bd_intf_pins axi_noc2_frmbuf/S00_AXI]
  connect_bd_intf_net -intf_net v_mix_m_axi_mm_video2 [get_bd_intf_pins v_mix/m_axi_mm_video2] [get_bd_intf_pins axi_noc2_frmbuf/S01_AXI]
  connect_bd_intf_net -intf_net v_mix_m_axi_mm_video3 [get_bd_intf_pins v_mix/m_axi_mm_video3] [get_bd_intf_pins axi_noc2_frmbuf/S02_AXI]
  connect_bd_intf_net -intf_net v_mix_m_axi_mm_video4 [get_bd_intf_pins v_mix/m_axi_mm_video4] [get_bd_intf_pins axi_noc2_frmbuf/S03_AXI]
  connect_bd_intf_net -intf_net v_mix_m_axi_mm_video5 [get_bd_intf_pins v_mix/m_axi_mm_video5] [get_bd_intf_pins axi_noc2_frmbuf/S04_AXI]
  connect_bd_intf_net -intf_net v_mix_m_axis_video [get_bd_intf_pins m_axis_vmix_video_out] [get_bd_intf_pins v_mix/m_axis_video]

  # Create port connections
  connect_bd_net -net ilconstant_1_dout  [get_bd_pins ilconstant_1/dout] \
  [get_bd_pins v_mix/s_axis_video_TVALID] \
  [get_bd_pins v_mix/s_axis_video_TDATA]
  connect_bd_net -net ilslice_vmix_gpio_Dout  [get_bd_pins ilslice_vmix_gpio/Dout] \
  [get_bd_pins v_mix/ap_rst_n]
  connect_bd_net -net s_axis_video_aclk_1  [get_bd_pins s_axis_video_aclk] \
  [get_bd_pins axi_noc2_frmbuf/aclk0] \
  [get_bd_pins v_mix/ap_clk] \
  [get_bd_pins vmix_rst_gpio/s_axi_aclk]
  connect_bd_net -net s_axis_video_aresetn_1  [get_bd_pins s_axis_video_aresetn] \
  [get_bd_pins vmix_rst_gpio/s_axi_aresetn]
  connect_bd_net -net v_mix_interrupt  [get_bd_pins v_mix/interrupt] \
  [get_bd_pins mixer_irq]
  connect_bd_net -net vmix_rst_gpio_gpio_io_o  [get_bd_pins vmix_rst_gpio/gpio_io_o] \
  [get_bd_pins ilslice_vmix_gpio/Din]

  # Perform GUI Layout
  regenerate_bd_layout -hierarchy [get_bd_cells /hdmi_tx_ss_hier/vmix_ss] -layout_string {
   "ActiveEmotionalView":"Default View",
   "Default View_ScaleFactor":"0.515134",
   "Default View_TopLeft":"-202,-43",
   "ExpandedHierarchyInLayout":"",
   "guistr":"# # String gsaved with Nlview 7.8.0 2024-04-26 e1825d835c VDI=44 GEI=38 GUI=JA:21.0 TLS
#  -string -flagsOSRD
preplace port s_axit_ctrl_vmix_gpio -pg 1 -lvl 0 -x 0 -y 200 -defaultsOSRD
preplace port s_axi_ctrl_vmix -pg 1 -lvl 0 -x 0 -y 70 -defaultsOSRD
preplace port vmix_M00_INI -pg 1 -lvl 5 -x 1330 -y 100 -defaultsOSRD
preplace port vmix_M01_INI -pg 1 -lvl 5 -x 1330 -y 120 -defaultsOSRD
preplace port m_axis_vmix_video_out -pg 1 -lvl 5 -x 1330 -y 220 -defaultsOSRD
preplace port port-id_s_axis_video_aclk -pg 1 -lvl 0 -x 0 -y 220 -defaultsOSRD
preplace port port-id_s_axis_video_aresetn -pg 1 -lvl 0 -x 0 -y 240 -defaultsOSRD
preplace port port-id_mixer_irq -pg 1 -lvl 5 -x 1330 -y 240 -defaultsOSRD
preplace inst ilconstant_1 -pg 1 -lvl 2 -x 400 -y 130 -defaultsOSRD
preplace inst vmix_rst_gpio -pg 1 -lvl 1 -x 160 -y 220 -defaultsOSRD
preplace inst v_mix -pg 1 -lvl 3 -x 750 -y 120 -defaultsOSRD
preplace inst ilslice_vmix_gpio -pg 1 -lvl 2 -x 400 -y 230 -defaultsOSRD
preplace inst axi_noc2_frmbuf -pg 1 -lvl 4 -x 1160 -y 110 -defaultsOSRD
preplace netloc ilconstant_1_dout 1 2 1 500 110n
preplace netloc ilslice_vmix_gpio_Dout 1 2 1 510J 170n
preplace netloc s_axis_video_aclk_1 1 0 4 20 300 NJ 300 500 240 1000J
preplace netloc s_axis_video_aresetn_1 1 0 1 NJ 240
preplace netloc v_mix_interrupt 1 3 2 1010J 240 NJ
preplace netloc vmix_rst_gpio_gpio_io_o 1 1 1 N 230
preplace netloc Conn0 1 4 1 NJ 100
preplace netloc Conn1 1 4 1 NJ 120
preplace netloc s_axi_ctrl_vmix_1 1 0 3 NJ 70 NJ 70 NJ
preplace netloc s_axit_ctrl_vmix_gpio_1 1 0 1 NJ 200
preplace netloc v_mix_m_axi_mm_video1 1 3 1 N 60
preplace netloc v_mix_m_axi_mm_video2 1 3 1 N 80
preplace netloc v_mix_m_axi_mm_video3 1 3 1 N 100
preplace netloc v_mix_m_axi_mm_video4 1 3 1 N 120
preplace netloc v_mix_m_axis_video 1 3 2 990J 220 NJ
preplace netloc v_mix_m_axi_mm_video5 1 3 1 N 140
levelinfo -pg 1 0 160 400 750 1160 1330
pagesize -pg 1 -db -bbox -sgen -210 0 1550 310
"
}

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: hdmi_tx_ss_hier
proc create_hier_cell_hdmi_tx_ss_hier { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_hdmi_tx_ss_hier() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 vmix_M00_INI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 vmix_M01_INI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 GT_DRU_FRL_CLK_IN

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 TX_REFCLK_P_IN_V

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 GT_Serial

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 TX_DDC_OUT

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 HDMI_CTRL

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI


  # Create pins
  create_bd_pin -dir I -type clk s_axis_video_aclk
  create_bd_pin -dir I -type rst s_axis_video_aresetn
  create_bd_pin -dir O -type intr mixer_irq
  create_bd_pin -dir I -type clk vid_phy_sb_aclk
  create_bd_pin -dir I -type rst vid_phy_sb_aresetn
  create_bd_pin -dir I TX_HPD_IN
  create_bd_pin -dir O -type intr hdmi_tx_irq
  create_bd_pin -dir I IDT8T49N241_LOL_IN
  create_bd_pin -dir O vphy_irq
  create_bd_pin -dir O -from 0 -to 0 TX_TI_ENABLE
  create_bd_pin -dir O -from 0 -to 0 RX_TI_ENABLE
  create_bd_pin -dir O -type intr timer_irq
  create_bd_pin -dir O -type intr iic_irq

  # Create instance: vmix_ss
  create_hier_cell_vmix_ss $hier_obj vmix_ss

  # Create instance: hdmi_ss
  create_hier_cell_hdmi_ss $hier_obj hdmi_ss

  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_0 ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {2} \
    CONFIG.NUM_MI {7} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_0


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins smartconnect_0/S00_AXI] [get_bd_intf_pins S00_AXI]
  connect_bd_intf_net -intf_net hdmi_ss_DDC_OUT_0 [get_bd_intf_pins TX_DDC_OUT] [get_bd_intf_pins hdmi_ss/TX_DDC_OUT]
  connect_bd_intf_net -intf_net hdmi_ss_IIC_0 [get_bd_intf_pins HDMI_CTRL] [get_bd_intf_pins hdmi_ss/HDMI_CTRL]
  connect_bd_intf_net -intf_net intf_net_bdry_in_GT_DRU_FRL_CLK_IN [get_bd_intf_pins GT_DRU_FRL_CLK_IN] [get_bd_intf_pins hdmi_ss/GT_DRU_FRL_CLK_IN]
  connect_bd_intf_net -intf_net intf_net_bdry_in_TX_REFCLK_P_IN_V [get_bd_intf_pins TX_REFCLK_P_IN_V] [get_bd_intf_pins hdmi_ss/TX_REFCLK_P_IN_V]
  connect_bd_intf_net -intf_net intf_net_hdmiphy_ss_0_phy_data [get_bd_intf_pins GT_Serial] [get_bd_intf_pins hdmi_ss/GT_Serial]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins hdmi_ss/S_AXI_CPU_IN]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins smartconnect_0/M01_AXI] [get_bd_intf_pins hdmi_ss/S_AXI_IIC]
  connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins smartconnect_0/M02_AXI] [get_bd_intf_pins hdmi_ss/vid_phy_axi4lite]
  connect_bd_intf_net -intf_net smartconnect_0_M03_AXI [get_bd_intf_pins smartconnect_0/M03_AXI] [get_bd_intf_pins hdmi_ss/S_AXI_VFMC]
  connect_bd_intf_net -intf_net smartconnect_0_M04_AXI [get_bd_intf_pins smartconnect_0/M04_AXI] [get_bd_intf_pins hdmi_ss/S_AXI_TIMER]
  connect_bd_intf_net -intf_net smartconnect_0_M05_AXI [get_bd_intf_pins smartconnect_0/M05_AXI] [get_bd_intf_pins vmix_ss/s_axit_ctrl_vmix_gpio]
  connect_bd_intf_net -intf_net smartconnect_0_M06_AXI [get_bd_intf_pins smartconnect_0/M06_AXI] [get_bd_intf_pins vmix_ss/s_axi_ctrl_vmix]
  connect_bd_intf_net -intf_net vmix_frmbuf_rd_ss_m_axis_vmix_video_out [get_bd_intf_pins vmix_ss/m_axis_vmix_video_out] [get_bd_intf_pins hdmi_ss/VIDEO_IN]
  connect_bd_intf_net -intf_net vmix_ss_vmix_M00_INI [get_bd_intf_pins vmix_M00_INI] [get_bd_intf_pins vmix_ss/vmix_M00_INI]
  connect_bd_intf_net -intf_net vmix_ss_vmix_M01_INI [get_bd_intf_pins vmix_M01_INI] [get_bd_intf_pins vmix_ss/vmix_M01_INI]

  # Create port connections
  connect_bd_net -net hdmi_ss_RX_TI_ENABLE  [get_bd_pins hdmi_ss/RX_TI_ENABLE] \
  [get_bd_pins RX_TI_ENABLE]
  connect_bd_net -net hdmi_ss_hdmi_tx_irq  [get_bd_pins hdmi_ss/hdmi_tx_irq] \
  [get_bd_pins hdmi_tx_irq]
  connect_bd_net -net hdmi_ss_iic_irq  [get_bd_pins hdmi_ss/iic_irq] \
  [get_bd_pins iic_irq]
  connect_bd_net -net hdmi_ss_timer_irq  [get_bd_pins hdmi_ss/timer_irq] \
  [get_bd_pins timer_irq]
  connect_bd_net -net hdmi_ss_vphy_irq  [get_bd_pins hdmi_ss/vphy_irq] \
  [get_bd_pins vphy_irq]
  connect_bd_net -net net_bdry_in_IDT8T49N241_LOL_IN  [get_bd_pins IDT8T49N241_LOL_IN] \
  [get_bd_pins hdmi_ss/IDT8T49N241_LOL_IN]
  connect_bd_net -net net_bdry_in_TX_HPD_IN  [get_bd_pins TX_HPD_IN] \
  [get_bd_pins hdmi_ss/TX_HPD_IN]
  connect_bd_net -net net_vfmc_ctlr_ss_0_VFMC_RX_ONSEMI_ENABLE  [get_bd_pins hdmi_ss/TX_TI_ENABLE] \
  [get_bd_pins TX_TI_ENABLE]
  connect_bd_net -net proc_sys_reset_300_peripheral_aresetn  [get_bd_pins s_axis_video_aresetn] \
  [get_bd_pins hdmi_ss/s_axis_video_aresetn] \
  [get_bd_pins vmix_ss/s_axis_video_aresetn]
  connect_bd_net -net ps_wizard_0_pl1_ref_clk  [get_bd_pins vid_phy_sb_aclk] \
  [get_bd_pins hdmi_ss/vid_phy_sb_aclk] \
  [get_bd_pins smartconnect_0/aclk]
  connect_bd_net -net ps_wizard_0_pl3_ref_clk  [get_bd_pins s_axis_video_aclk] \
  [get_bd_pins hdmi_ss/s_axis_video_aclk] \
  [get_bd_pins vmix_ss/s_axis_video_aclk] \
  [get_bd_pins smartconnect_0/aclk1]
  connect_bd_net -net s_axi_aresetn  [get_bd_pins vid_phy_sb_aresetn] \
  [get_bd_pins hdmi_ss/vid_phy_sb_aresetn] \
  [get_bd_pins smartconnect_0/aresetn]
  connect_bd_net -net vmix_frmbuf_rd_ss_mixer_irq  [get_bd_pins vmix_ss/mixer_irq] \
  [get_bd_pins mixer_irq]

  # Perform GUI Layout
  regenerate_bd_layout -hierarchy [get_bd_cells /hdmi_tx_ss_hier] -layout_string {
   "ActiveEmotionalView":"Default View",
   "Default View_ScaleFactor":"0.461883",
   "Default View_TopLeft":"-385,2",
   "ExpandedHierarchyInLayout":"",
   "guistr":"# # String gsaved with Nlview 7.8.0 2024-04-26 e1825d835c VDI=44 GEI=38 GUI=JA:21.0 TLS
#  -string -flagsOSRD
preplace port vmix_M00_INI -pg 1 -lvl 4 -x 1200 -y 50 -defaultsOSRD
preplace port vmix_M01_INI -pg 1 -lvl 4 -x 1200 -y 70 -defaultsOSRD
preplace port GT_DRU_FRL_CLK_IN -pg 1 -lvl 0 -x 0 -y 20 -defaultsOSRD
preplace port TX_REFCLK_P_IN_V -pg 1 -lvl 0 -x 0 -y 290 -defaultsOSRD
preplace port GT_Serial -pg 1 -lvl 4 -x 1200 -y 180 -defaultsOSRD
preplace port TX_DDC_OUT -pg 1 -lvl 4 -x 1200 -y 200 -defaultsOSRD
preplace port HDMI_CTRL -pg 1 -lvl 4 -x 1200 -y 220 -defaultsOSRD
preplace port S00_AXI -pg 1 -lvl 0 -x 0 -y 110 -defaultsOSRD
preplace port port-id_s_axis_video_aclk -pg 1 -lvl 0 -x 0 -y 150 -defaultsOSRD
preplace port port-id_s_axis_video_aresetn -pg 1 -lvl 0 -x 0 -y 270 -defaultsOSRD
preplace port port-id_mixer_irq -pg 1 -lvl 4 -x 1200 -y 90 -defaultsOSRD
preplace port port-id_vid_phy_sb_aclk -pg 1 -lvl 0 -x 0 -y 130 -defaultsOSRD
preplace port port-id_vid_phy_sb_aresetn -pg 1 -lvl 0 -x 0 -y 170 -defaultsOSRD
preplace port port-id_TX_HPD_IN -pg 1 -lvl 0 -x 0 -y 340 -defaultsOSRD
preplace port port-id_hdmi_tx_irq -pg 1 -lvl 4 -x 1200 -y 240 -defaultsOSRD
preplace port port-id_IDT8T49N241_LOL_IN -pg 1 -lvl 0 -x 0 -y 400 -defaultsOSRD
preplace port port-id_vphy_irq -pg 1 -lvl 4 -x 1200 -y 280 -defaultsOSRD
preplace port port-id_timer_irq -pg 1 -lvl 4 -x 1200 -y 340 -defaultsOSRD
preplace port port-id_iic_irq -pg 1 -lvl 4 -x 1200 -y 360 -defaultsOSRD
preplace portBus TX_TI_ENABLE -pg 1 -lvl 4 -x 1200 -y 300 -defaultsOSRD
preplace portBus RX_TI_ENABLE -pg 1 -lvl 4 -x 1200 -y 320 -defaultsOSRD
preplace inst vmix_ss -pg 1 -lvl 2 -x 540 -y 210 -defaultsOSRD
preplace inst hdmi_ss -pg 1 -lvl 3 -x 1000 -y 270 -defaultsOSRD
preplace inst smartconnect_0 -pg 1 -lvl 1 -x 180 -y 140 -defaultsOSRD
preplace netloc hdmi_ss_RX_TI_ENABLE 1 3 1 NJ 320
preplace netloc hdmi_ss_hdmi_tx_irq 1 3 1 NJ 240
preplace netloc hdmi_ss_iic_irq 1 3 1 NJ 360
preplace netloc hdmi_ss_timer_irq 1 3 1 NJ 340
preplace netloc hdmi_ss_vphy_irq 1 3 1 NJ 280
preplace netloc net_bdry_in_IDT8T49N241_LOL_IN 1 0 3 NJ 400 NJ 400 NJ
preplace netloc net_bdry_in_TX_HPD_IN 1 0 3 NJ 340 NJ 340 NJ
preplace netloc net_vfmc_ctlr_ss_0_VFMC_RX_ONSEMI_ENABLE 1 3 1 NJ 300
preplace netloc proc_sys_reset_300_peripheral_aresetn 1 0 3 NJ 270 340 380 NJ
preplace netloc ps_wizard_0_pl1_ref_clk 1 0 3 40 310 NJ 310 820J
preplace netloc ps_wizard_0_pl3_ref_clk 1 0 3 30 260 330 360 NJ
preplace netloc s_axi_aresetn 1 0 3 20 320 NJ 320 NJ
preplace netloc vmix_frmbuf_rd_ss_mixer_irq 1 2 2 770J 80 1180J
preplace netloc Conn1 1 0 1 NJ 110
preplace netloc hdmi_ss_DDC_OUT_0 1 3 1 NJ 200
preplace netloc hdmi_ss_IIC_0 1 3 1 NJ 220
preplace netloc intf_net_bdry_in_GT_DRU_FRL_CLK_IN 1 0 3 NJ 20 NJ 20 810J
preplace netloc intf_net_bdry_in_TX_REFCLK_P_IN_V 1 0 3 NJ 290 NJ 290 800J
preplace netloc intf_net_hdmiphy_ss_0_phy_data 1 3 1 NJ 180
preplace netloc smartconnect_0_M00_AXI 1 1 2 320 90 820J
preplace netloc smartconnect_0_M01_AXI 1 1 2 N 100 800J
preplace netloc smartconnect_0_M02_AXI 1 1 2 320 110 780J
preplace netloc smartconnect_0_M03_AXI 1 1 2 340 120 750J
preplace netloc smartconnect_0_M04_AXI 1 1 2 320 300 810J
preplace netloc smartconnect_0_M05_AXI 1 1 1 N 180
preplace netloc smartconnect_0_M06_AXI 1 1 1 N 200
preplace netloc vmix_frmbuf_rd_ss_m_axis_vmix_video_out 1 2 1 790 160n
preplace netloc vmix_ss_vmix_M00_INI 1 2 2 740J 50 NJ
preplace netloc vmix_ss_vmix_M01_INI 1 2 2 760J 70 NJ
levelinfo -pg 1 0 180 540 1000 1200
pagesize -pg 1 -db -bbox -sgen -210 0 1390 450
"
}

  # Restore current instance
  current_bd_instance $oldCurInst
}


proc available_tcl_procs { } {
   puts "##################################################################"
   puts "# Available Tcl procedures to recreate hierarchical blocks:"
   puts "#"
   puts "#    create_hier_cell_hdmi_tx_ss_hier parentCell nameHier"
   puts "#    create_hier_cell_vmix_ss parentCell nameHier"
   puts "#    create_hier_cell_hdmi_ss parentCell nameHier"
   puts "#    create_hier_cell_gt_refclk_buf_ss_0 parentCell nameHier"
   puts "#    create_hier_cell_gt_refclk_buf_ss_1 parentCell nameHier"
   puts "#    create_hier_cell_hdmiphy_ss_0 parentCell nameHier"
   puts "#    create_hier_cell_vfmc_ctlr_ss_0 parentCell nameHier"
   puts "#"
   puts "##################################################################"
}

available_tcl_procs

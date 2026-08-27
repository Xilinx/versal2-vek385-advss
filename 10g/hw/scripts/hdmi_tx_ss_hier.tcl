# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------


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
set scripts_vivado_version 2026.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   common::send_gid_msg -ssname BD::TCL -id 2040 -severity "CRITICAL WARNING" "This script was generated using Vivado <$scripts_vivado_version> but is now being run in <$current_vivado_version> of Vivado."
}

################################################################
# CHECK IPs
################################################################
set bCheckIPsPassed 1
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\
xilinx.com:inline_hdl:ilconstant:*\

xilinx.com:inline_hdl:ilslice:*\

xilinx.com:inline_hdl:ilvector_logic:*\

xilinx.com:ip:axi_gpio:*\

xilinx.com:ip:axi_iic:*\

xilinx.com:ip:axi_noc2:*\

xilinx.com:ip:axi_timer:*\

xilinx.com:ip:axis_register_slice:*\

xilinx.com:ip:clkx5_wiz:*\

xilinx.com:ip:proc_sys_reset:*\

xilinx.com:ip:smartconnect:*\

xilinx.com:ip:v_hdmi_txss1:*\

xilinx.com:ip:v_mix:*\

xilinx.com:ip:video_cke_sync:*\

xilinx.com:inline_hdl:ilconcat:*\

xilinx.com:inline_hdl:ilreduced_logic:*\

xilinx.com:ip:bufg_gt:*\

xilinx.com:ip:gtwiz_versal:*\

xilinx.com:ip:hdmi_gt_controller:*\

xilinx.com:ip:util_ds_buf:*\

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

# Hierarchical cell: hdmiphy_ss_0
proc create_hier_cell_hdmiphy_ss_0 { parentCell nameHier } {
  variable script_folder
  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_hdmiphy_ss_0() - Empty argument(s)!"}
     return
  }
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }
  set oldCurInst [current_bd_instance .]
  current_bd_instance $parentObj
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 phy_data
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 vid_phy_rx_axi4s_ch0
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 vid_phy_rx_axi4s_ch1
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 vid_phy_rx_axi4s_ch2
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 vid_phy_tx_axi4s_ch0
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 vid_phy_tx_axi4s_ch1
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 vid_phy_tx_axi4s_ch2
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 vid_phy_tx_axi4s_ch3
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 vid_phy_rx_axi4s_ch3
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 vid_phy_axi4lite
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 vid_phy_status_sb_rx
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 vid_phy_status_sb_tx
  create_bd_pin -dir I -type clk tx_ref_clk_in
  create_bd_pin -dir I -type clk tx_ref_clk_odiv2_in
  create_bd_pin -dir I -type clk rx_ref_clk_in
  create_bd_pin -dir I -type clk rx_ref_clk_odiv2_in
  create_bd_pin -dir I tx_refclk_rdy
  create_bd_pin -dir I -type clk vid_phy_axi4lite_aclk
  create_bd_pin -dir I -type rst vid_phy_axi4lite_aresetn
  create_bd_pin -dir I -type clk drpclk
  create_bd_pin -dir I -type clk vid_phy_sb_aclk
  create_bd_pin -dir I -type rst vid_phy_sb_aresetn
  create_bd_pin -dir I -type rst vid_phy_rx_axi4s_aresetn
  create_bd_pin -dir I -type rst vid_phy_tx_axi4s_aresetn
  create_bd_pin -dir O -type clk tx_tmds_clk
  create_bd_pin -dir O -type clk tx_video_clk
  create_bd_pin -dir O -type clk rx_tmds_clk
  create_bd_pin -dir O -type clk rx_tmds_clk_p
  create_bd_pin -dir O -type clk rx_tmds_clk_n
  create_bd_pin -dir O -type clk rx_video_clk
  create_bd_pin -dir O -type gt_usrclk txoutclk
  create_bd_pin -dir O -type gt_usrclk rxoutclk
  create_bd_pin -dir O irq
  create_bd_pin -dir I -type clk dru_ref_clk_in
  create_bd_pin -dir I -type clk dru_ref_clk_odiv2_in
  create_bd_cell -type ip -vlnv xilinx.com:ip:hdmi_gt_controller hdmi_gt_controller
  set_property -dict [list \
    CONFIG.C_NEW_WIZ {1} \
    CONFIG.C_NIDRU {true} \
    CONFIG.C_NIDRU_REFCLK_SEL {5} \
    CONFIG.C_RX_FRL_REFCLK_SEL {5} \
    CONFIG.C_RX_PLL_SELECTION {8} \
    CONFIG.C_RX_REFCLK_SEL {0} \
    CONFIG.C_Rx_Protocol {HDMI 2.1} \
    CONFIG.C_TX_FRL_REFCLK_SEL {5} \
    CONFIG.C_TX_PLL_SELECTION {7} \
    CONFIG.C_TX_REFCLK_SEL {1} \
    CONFIG.C_Tx_Protocol {HDMI 2.1} \
    CONFIG.C_Txrefclk_Rdy_Invert {true} \
    CONFIG.Rx_GT_Line_Rate {12.0} \
    CONFIG.Rx_GT_Ref_Clock_Freq {400} \
    CONFIG.Rx_Max_GT_Line_Rate {12.0} \
    CONFIG.Tx_GT_Line_Rate {12.0} \
    CONFIG.Tx_GT_Ref_Clock_Freq {400} \
    CONFIG.Tx_Max_GT_Line_Rate {12.0} \
    CONFIG.check_refclk_selection {0} \
  ] [get_bd_cells hdmi_gt_controller]
  create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilreduced_logic urlp
  set_property -dict [list \
    CONFIG.C_SIZE {1} \
  ] [get_bd_cells urlp]
  create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat xlcp
  set_property -dict [list \
    CONFIG.NUM_PORTS {1} \
  ] [get_bd_cells xlcp]
  create_bd_cell -type ip -vlnv xilinx.com:ip:bufg_gt bufg_gt_rx
  set_property -dict [list \
    CONFIG.FREQ_HZ {297000000.0} \
  ] [get_bd_cells bufg_gt_rx]
  create_bd_cell -type ip -vlnv xilinx.com:ip:bufg_gt bufg_gt_tx
  set_property -dict [list \
    CONFIG.FREQ_HZ {297000000.0} \
  ] [get_bd_cells bufg_gt_tx]
  create_bd_cell -type ip -vlnv xilinx.com:ip:gtwiz_versal gtwiz_versal
  set_property -dict [list \
    CONFIG.INTF0_GT_DIRECTION {SIMPLEX_TX} \
    CONFIG.INTF0_GT_SETTINGS(GT_DIRECTION) {SIMPLEX_TX} \
    CONFIG.INTF0_GT_SETTINGS(GT_TYPE) {GTYP} \
    CONFIG.INTF0_GT_SETTINGS(LR0_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_TX TX_PLL_TYPE LCPLL TX_DATA_ENCODING RAW TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE TXPROGDIVCLK TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE\
LCPLL TX_LANE_DESKEW_HDMI_ENABLE true TX_REFCLK_SOURCE R5 TX_USER_DATA_WIDTH 20 TX_INT_DATA_WIDTH 20 TX_LINE_RATE 2.5 TX_REFCLK_FREQUENCY 400.00} \
    CONFIG.INTF0_GT_SETTINGS(LR1_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_TX TX_PLL_TYPE LCPLL TX_DATA_ENCODING RAW TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE TXPROGDIVCLK TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE\
LCPLL TX_LANE_DESKEW_HDMI_ENABLE true TX_REFCLK_SOURCE R1 TX_USER_DATA_WIDTH 40 TX_INT_DATA_WIDTH 40 TX_LINE_RATE 1.625 TX_REFCLK_FREQUENCY 162.5} \
    CONFIG.INTF0_GT_SETTINGS(LR2_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_TX TX_PLL_TYPE LCPLL TX_DATA_ENCODING RAW TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE TXPROGDIVCLK TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE\
LCPLL TX_LANE_DESKEW_HDMI_ENABLE true TX_REFCLK_SOURCE R1 TX_USER_DATA_WIDTH 40 TX_INT_DATA_WIDTH 40 TX_LINE_RATE 2.485 TX_REFCLK_FREQUENCY 248.5} \
    CONFIG.INTF0_GT_SETTINGS(LR3_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_TX TX_PLL_TYPE LCPLL TX_DATA_ENCODING RAW TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE TXPROGDIVCLK TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE\
LCPLL TX_LANE_DESKEW_HDMI_ENABLE true TX_REFCLK_SOURCE R1 TX_USER_DATA_WIDTH 40 TX_INT_DATA_WIDTH 40 TX_LINE_RATE 3.700 TX_REFCLK_FREQUENCY 92.5} \
    CONFIG.INTF0_GT_SETTINGS(LR4_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_TX TX_PLL_TYPE LCPLL TX_DATA_ENCODING RAW TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE TXPROGDIVCLK TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE\
LCPLL TX_LANE_DESKEW_HDMI_ENABLE true TX_REFCLK_SOURCE R1 TX_USER_DATA_WIDTH 40 TX_INT_DATA_WIDTH 40 TX_LINE_RATE 5.94 TX_REFCLK_FREQUENCY 148.5} \
    CONFIG.INTF0_GT_SETTINGS(LR5_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_TX TX_PLL_TYPE LCPLL TX_DATA_ENCODING RAW TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE TXPROGDIVCLK TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE\
LCPLL TX_LANE_DESKEW_HDMI_ENABLE true TX_REFCLK_SOURCE R5 TX_USER_DATA_WIDTH 40 TX_INT_DATA_WIDTH 40 TX_LINE_RATE 3.0 TX_REFCLK_FREQUENCY 400.0} \
    CONFIG.INTF0_GT_SETTINGS(LR6_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_TX TX_PLL_TYPE LCPLL TX_DATA_ENCODING RAW TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE TXPROGDIVCLK TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE\
LCPLL TX_LANE_DESKEW_HDMI_ENABLE true TX_REFCLK_SOURCE R5 TX_USER_DATA_WIDTH 40 TX_INT_DATA_WIDTH 40 TX_LINE_RATE 6.0 TX_REFCLK_FREQUENCY 400.0} \
    CONFIG.INTF0_GT_SETTINGS(LR7_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_TX TX_PLL_TYPE LCPLL TX_DATA_ENCODING RAW TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE TXPROGDIVCLK TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE\
LCPLL TX_LANE_DESKEW_HDMI_ENABLE true TX_REFCLK_SOURCE R5 TX_USER_DATA_WIDTH 40 TX_INT_DATA_WIDTH 40 TX_LINE_RATE 8.0 TX_REFCLK_FREQUENCY 400.0} \
    CONFIG.INTF0_GT_SETTINGS(LR8_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_TX TX_PLL_TYPE LCPLL TX_DATA_ENCODING RAW TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE TXPROGDIVCLK TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE\
LCPLL TX_LANE_DESKEW_HDMI_ENABLE true TX_REFCLK_SOURCE R5 TX_USER_DATA_WIDTH 40 TX_INT_DATA_WIDTH 40 TX_LINE_RATE 10.0 TX_REFCLK_FREQUENCY 400.0} \
    CONFIG.INTF0_GT_SETTINGS(LR9_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_TX TX_PLL_TYPE LCPLL TX_DATA_ENCODING RAW TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE TXPROGDIVCLK TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE\
LCPLL TX_LANE_DESKEW_HDMI_ENABLE true TX_REFCLK_SOURCE R5 TX_USER_DATA_WIDTH 40 TX_INT_DATA_WIDTH 40 TX_LINE_RATE 12.0 TX_REFCLK_FREQUENCY 400.0} \
    CONFIG.INTF0_PARENTID {edf_base_hdmi_gt_controller_0} \
    CONFIG.INTF1_GT_DIRECTION {SIMPLEX_RX} \
    CONFIG.INTF1_GT_SETTINGS(GT_DIRECTION) {SIMPLEX_RX} \
    CONFIG.INTF1_GT_SETTINGS(GT_TYPE) {GTYP} \
    CONFIG.INTF1_GT_SETTINGS(LR0_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_RX RX_PLL_TYPE RPLL RX_DATA_DECODING RAW RX_BUFFER_MODE 1 RX_REFCLK_SOURCE R5 RX_USER_DATA_WIDTH 20 RX_INT_DATA_WIDTH 20 RX_LINE_RATE\
2.5 RX_REFCLK_FREQUENCY 400.00 RX_EQ_MODE LPM} \
    CONFIG.INTF1_GT_SETTINGS(LR1_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_RX RX_PLL_TYPE RPLL RX_DATA_DECODING RAW RX_BUFFER_MODE 1 RX_REFCLK_SOURCE R0 RX_USER_DATA_WIDTH 40 RX_INT_DATA_WIDTH 40 RX_LINE_RATE\
1.625 RX_REFCLK_FREQUENCY 162.5 RX_EQ_MODE LPM} \
    CONFIG.INTF1_GT_SETTINGS(LR2_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_RX RX_PLL_TYPE RPLL RX_DATA_DECODING RAW RX_BUFFER_MODE 1 RX_REFCLK_SOURCE R0 RX_USER_DATA_WIDTH 40 RX_INT_DATA_WIDTH 40 RX_LINE_RATE\
2.485 RX_REFCLK_FREQUENCY 248.5 RX_EQ_MODE LPM} \
    CONFIG.INTF1_GT_SETTINGS(LR3_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_RX RX_PLL_TYPE RPLL RX_DATA_DECODING RAW RX_BUFFER_MODE 1 RX_REFCLK_SOURCE R0 RX_USER_DATA_WIDTH 40 RX_INT_DATA_WIDTH 40 RX_LINE_RATE\
3.700 RX_REFCLK_FREQUENCY 92.5 RX_EQ_MODE LPM} \
    CONFIG.INTF1_GT_SETTINGS(LR4_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_RX RX_PLL_TYPE RPLL RX_DATA_DECODING RAW RX_BUFFER_MODE 1 RX_REFCLK_SOURCE R0 RX_USER_DATA_WIDTH 40 RX_INT_DATA_WIDTH 40 RX_LINE_RATE\
5.94 RX_REFCLK_FREQUENCY 148.5 RX_EQ_MODE LPM} \
    CONFIG.INTF1_GT_SETTINGS(LR5_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_RX RX_PLL_TYPE RPLL RX_DATA_DECODING RAW RX_BUFFER_MODE 1 RX_REFCLK_SOURCE R5 RX_USER_DATA_WIDTH 40 RX_INT_DATA_WIDTH 40 RX_LINE_RATE\
3.0 RX_REFCLK_FREQUENCY 400.0 RX_EQ_MODE LPM} \
    CONFIG.INTF1_GT_SETTINGS(LR6_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_RX RX_PLL_TYPE RPLL RX_DATA_DECODING RAW RX_BUFFER_MODE 1 RX_REFCLK_SOURCE R5 RX_USER_DATA_WIDTH 40 RX_INT_DATA_WIDTH 40 RX_LINE_RATE\
6.0 RX_REFCLK_FREQUENCY 400.0 RX_EQ_MODE LPM} \
    CONFIG.INTF1_GT_SETTINGS(LR7_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_RX RX_PLL_TYPE RPLL RX_DATA_DECODING RAW RX_BUFFER_MODE 1 RX_REFCLK_SOURCE R5 RX_USER_DATA_WIDTH 40 RX_INT_DATA_WIDTH 40 RX_LINE_RATE\
8.0 RX_REFCLK_FREQUENCY 400.0 RX_EQ_MODE LPM} \
    CONFIG.INTF1_GT_SETTINGS(LR8_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_RX RX_PLL_TYPE RPLL RX_DATA_DECODING RAW RX_BUFFER_MODE 1 RX_REFCLK_SOURCE R5 RX_USER_DATA_WIDTH 40 RX_INT_DATA_WIDTH 40 RX_LINE_RATE\
10.0 RX_REFCLK_FREQUENCY 400.0 RX_EQ_MODE LPM} \
    CONFIG.INTF1_GT_SETTINGS(LR9_SETTINGS) {PRESET None GT_DIRECTION SIMPLEX_RX RX_PLL_TYPE RPLL RX_DATA_DECODING RAW RX_BUFFER_MODE 1 RX_REFCLK_SOURCE R5 RX_USER_DATA_WIDTH 40 RX_INT_DATA_WIDTH 40 RX_LINE_RATE\
12.0 RX_REFCLK_FREQUENCY 400.0 RX_EQ_MODE DFE} \
    CONFIG.INTF1_NO_OF_LANES {4} \
    CONFIG.INTF1_PARENTID {edf_base_hdmi_gt_controller_0} \
    CONFIG.INTF_PARENT_PIN_LIST {QUAD0_TX0 /hdmi_tx_ss_hier/hdmiphy_ss_0/hdmi_gt_controller/gt_tx0 QUAD0_TX1 /hdmi_tx_ss_hier/hdmiphy_ss_0/hdmi_gt_controller/gt_tx1 QUAD0_TX2 /hdmi_tx_ss_hier/hdmiphy_ss_0/hdmi_gt_controller/gt_tx2\
QUAD0_TX3 /hdmi_tx_ss_hier/hdmiphy_ss_0/hdmi_gt_controller/gt_tx3 QUAD0_RX0 /hdmi_tx_ss_hier/hdmiphy_ss_0/hdmi_gt_controller/gt_rx0 QUAD0_RX1 /hdmi_tx_ss_hier/hdmiphy_ss_0/hdmi_gt_controller/gt_rx1 QUAD0_RX2\
/hdmi_tx_ss_hier/hdmiphy_ss_0/hdmi_gt_controller/gt_rx2 QUAD0_RX3 /hdmi_tx_ss_hier/hdmiphy_ss_0/hdmi_gt_controller/gt_rx3} \
    CONFIG.NO_OF_INTERFACE {2} \
    CONFIG.QUAD0_CH0_DEBUG_EN {true} \
    CONFIG.QUAD0_CH0_ILORESETDONE_EN {true} \
    CONFIG.QUAD0_CH0_PHYREADY_EN {true} \
    CONFIG.QUAD0_CH1_DEBUG_EN {true} \
    CONFIG.QUAD0_CH1_ILORESETDONE_EN {true} \
    CONFIG.QUAD0_CH1_PHYREADY_EN {true} \
    CONFIG.QUAD0_CH2_DEBUG_EN {true} \
    CONFIG.QUAD0_CH2_ILORESETDONE_EN {true} \
    CONFIG.QUAD0_CH2_PHYREADY_EN {true} \
    CONFIG.QUAD0_CH3_DEBUG_EN {true} \
    CONFIG.QUAD0_CH3_ILORESETDONE_EN {true} \
    CONFIG.QUAD0_CH3_PHYREADY_EN {true} \
    CONFIG.QUAD0_GT_DEBUG_EN {true} \
    CONFIG.QUAD0_HSCLK0_LCPLLRESET_EN {true} \
    CONFIG.QUAD0_HSCLK0_LCPLL_LOCK_EN {true} \
    CONFIG.QUAD0_HSCLK0_RPLLRESET_EN {true} \
    CONFIG.QUAD0_HSCLK0_RPLL_LOCK_EN {true} \
    CONFIG.QUAD0_HSCLK1_LCPLLRESET_EN {true} \
    CONFIG.QUAD0_HSCLK1_LCPLL_LOCK_EN {true} \
    CONFIG.QUAD0_HSCLK1_RPLLRESET_EN {true} \
    CONFIG.QUAD0_HSCLK1_RPLL_LOCK_EN {true} \
    CONFIG.QUAD0_NO_PROT {2} \
    CONFIG.QUAD0_PROT0_TX1_EN {true} \
    CONFIG.QUAD0_PROT0_TX2_EN {true} \
    CONFIG.QUAD0_PROT0_TX3_EN {true} \
    CONFIG.QUAD0_PROT1 {INTF1} \
    CONFIG.QUAD0_PROT1_LANES {4} \
    CONFIG.QUAD0_PROT1_RX0_EN {true} \
    CONFIG.QUAD0_PROT1_RX1_EN {true} \
    CONFIG.QUAD0_PROT1_RX2_EN {true} \
    CONFIG.QUAD0_PROT1_RX3_EN {true} \
    CONFIG.QUAD0_PROT1_RXMSTCLK {RX0} \
    CONFIG.QUAD0_REFCLK_STRING {HSCLK0_LCPLLGTREFCLK1 refclk_PROT0_R1_multiple_ext_freq HSCLK0_LCPLLSOUTHREFCLK1 refclk_PROT0_R5_400_MHz_unique1 HSCLK0_RPLLGTREFCLK0 refclk_PROT1_R0_multiple_ext_freq HSCLK0_RPLLSOUTHREFCLK1\
refclk_PROT1_R5_400_MHz_unique1 HSCLK1_LCPLLGTREFCLK1 refclk_PROT0_R1_multiple_ext_freq HSCLK1_LCPLLSOUTHREFCLK1 refclk_PROT0_R5_400_MHz_unique1 HSCLK1_RPLLGTREFCLK0 refclk_PROT1_R0_multiple_ext_freq HSCLK1_RPLLSOUTHREFCLK1\
refclk_PROT1_R5_400_MHz_unique1} \
    CONFIG.QUAD0_USAGE {TX_QUAD_CH {TXQuad_0_/edf_base_gtwiz_versal_0/edf_base_gtwiz_versal_0_gt_quad_base_0 {/edf_base_gtwiz_versal_0/edf_base_gtwiz_versal_0_gt_quad_base_0 edf_base_hdmi_gt_controller_0.IP_CH0,edf_base_hdmi_gt_controller_0.IP_CH1,edf_base_hdmi_gt_controller_0.IP_CH2,edf_base_hdmi_gt_controller_0.IP_CH3\
MSTRCLK 1,0,0,0 IS_CURRENT_QUAD 1}} RX_QUAD_CH {RXQuad_0_/edf_base_gtwiz_versal_0/edf_base_gtwiz_versal_0_gt_quad_base_0 {/edf_base_gtwiz_versal_0/edf_base_gtwiz_versal_0_gt_quad_base_0 edf_base_hdmi_gt_controller_0.IP_CH0,edf_base_hdmi_gt_controller_0.IP_CH1,edf_base_hdmi_gt_controller_0.IP_CH2,edf_base_hdmi_gt_controller_0.IP_CH3\
MSTRCLK 1,0,0,0 IS_CURRENT_QUAD 1}}} \
    CONFIG.INTF0_GT_SETTINGS.VALUE_MODE {auto} \
    CONFIG.INTF0_PARENTID.VALUE_MODE {auto} \
    CONFIG.INTF1_GT_SETTINGS.VALUE_MODE {auto} \
    CONFIG.INTF1_PARENTID.VALUE_MODE {auto} \
    CONFIG.INTF_PARENT_PIN_LIST.VALUE_MODE {auto} \
    CONFIG.QUAD0_USAGE.VALUE_MODE {auto} \
  ] [get_bd_cells gtwiz_versal]
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
  connect_bd_intf_net -intf_net intf_net_hdmi_gt_controller_gt_rx0 [get_bd_intf_pins hdmi_gt_controller/gt_rx0] [get_bd_intf_pins gtwiz_versal/INTF1_RX0_GT_IP_Interface]
  connect_bd_intf_net -intf_net intf_net_hdmi_gt_controller_gt_rx1 [get_bd_intf_pins hdmi_gt_controller/gt_rx1] [get_bd_intf_pins gtwiz_versal/INTF1_RX1_GT_IP_Interface]
  connect_bd_intf_net -intf_net intf_net_hdmi_gt_controller_gt_rx2 [get_bd_intf_pins hdmi_gt_controller/gt_rx2] [get_bd_intf_pins gtwiz_versal/INTF1_RX2_GT_IP_Interface]
  connect_bd_intf_net -intf_net intf_net_hdmi_gt_controller_gt_rx3 [get_bd_intf_pins hdmi_gt_controller/gt_rx3] [get_bd_intf_pins gtwiz_versal/INTF1_RX3_GT_IP_Interface]
  connect_bd_intf_net -intf_net intf_net_hdmi_gt_controller_gt_tx0 [get_bd_intf_pins hdmi_gt_controller/gt_tx0] [get_bd_intf_pins gtwiz_versal/INTF0_TX0_GT_IP_Interface]
  connect_bd_intf_net -intf_net intf_net_hdmi_gt_controller_gt_tx1 [get_bd_intf_pins hdmi_gt_controller/gt_tx1] [get_bd_intf_pins gtwiz_versal/INTF0_TX1_GT_IP_Interface]
  connect_bd_intf_net -intf_net intf_net_hdmi_gt_controller_gt_tx2 [get_bd_intf_pins hdmi_gt_controller/gt_tx2] [get_bd_intf_pins gtwiz_versal/INTF0_TX2_GT_IP_Interface]
  connect_bd_intf_net -intf_net intf_net_hdmi_gt_controller_gt_tx3 [get_bd_intf_pins hdmi_gt_controller/gt_tx3] [get_bd_intf_pins gtwiz_versal/INTF0_TX3_GT_IP_Interface]
  connect_bd_intf_net -intf_net intf_net_hdmi_gt_controller_rx_axi4s_ch0 [get_bd_intf_pins hdmi_gt_controller/rx_axi4s_ch0] [get_bd_intf_pins vid_phy_rx_axi4s_ch0]
  connect_bd_intf_net -intf_net intf_net_hdmi_gt_controller_rx_axi4s_ch1 [get_bd_intf_pins hdmi_gt_controller/rx_axi4s_ch1] [get_bd_intf_pins vid_phy_rx_axi4s_ch1]
  connect_bd_intf_net -intf_net intf_net_hdmi_gt_controller_rx_axi4s_ch2 [get_bd_intf_pins hdmi_gt_controller/rx_axi4s_ch2] [get_bd_intf_pins vid_phy_rx_axi4s_ch2]
  connect_bd_intf_net -intf_net intf_net_hdmi_gt_controller_rx_axi4s_ch3 [get_bd_intf_pins hdmi_gt_controller/rx_axi4s_ch3] [get_bd_intf_pins vid_phy_rx_axi4s_ch3]
  connect_bd_intf_net -intf_net intf_net_hdmi_gt_controller_status_sb_rx [get_bd_intf_pins hdmi_gt_controller/status_sb_rx] [get_bd_intf_pins vid_phy_status_sb_rx]
  connect_bd_intf_net -intf_net intf_net_hdmi_gt_controller_status_sb_tx [get_bd_intf_pins hdmi_gt_controller/status_sb_tx] [get_bd_intf_pins vid_phy_status_sb_tx]
  connect_bd_net -net net_bdry_in_drpclk [get_bd_pins drpclk] [get_bd_pins hdmi_gt_controller/apb_clk] [get_bd_pins gtwiz_versal/gtwiz_freerun_clk]
  connect_bd_net -net net_bdry_in_dru_ref_clk_in [get_bd_pins dru_ref_clk_in] [get_bd_pins gtwiz_versal/QUAD0_GTREFCLK1] [get_bd_pins gtwiz_versal/QUAD0_GTREFCLK3]
  connect_bd_net -net net_bdry_in_dru_ref_clk_odiv2_in [get_bd_pins dru_ref_clk_odiv2_in] [get_bd_pins hdmi_gt_controller/gt_refclk5_odiv2]
  connect_bd_net -net net_bdry_in_rx_ref_clk_in [get_bd_pins rx_ref_clk_in] [get_bd_pins gtwiz_versal/QUAD0_GTREFCLK2]
  connect_bd_net -net net_bdry_in_rx_ref_clk_odiv2_in [get_bd_pins rx_ref_clk_odiv2_in] [get_bd_pins hdmi_gt_controller/gt_refclk0_odiv2]
  connect_bd_net -net net_bdry_in_tx_ref_clk_in [get_bd_pins tx_ref_clk_in] [get_bd_pins gtwiz_versal/QUAD0_GTREFCLK0]
  connect_bd_net -net net_bdry_in_tx_ref_clk_odiv2_in [get_bd_pins tx_ref_clk_odiv2_in] [get_bd_pins hdmi_gt_controller/gt_refclk1_odiv2]
  connect_bd_net -net net_bdry_in_tx_refclk_rdy [get_bd_pins tx_refclk_rdy] [get_bd_pins hdmi_gt_controller/tx_refclk_rdy]
  connect_bd_net -net net_bdry_in_vid_phy_axi4lite_aclk [get_bd_pins vid_phy_axi4lite_aclk] [get_bd_pins hdmi_gt_controller/axi4lite_aclk]
  connect_bd_net -net net_bdry_in_vid_phy_axi4lite_aresetn [get_bd_pins vid_phy_axi4lite_aresetn] [get_bd_pins hdmi_gt_controller/axi4lite_aresetn]
  connect_bd_net -net net_bdry_in_vid_phy_rx_axi4s_aresetn [get_bd_pins vid_phy_rx_axi4s_aresetn] [get_bd_pins hdmi_gt_controller/rx_axi4s_aresetn]
  connect_bd_net -net net_bdry_in_vid_phy_sb_aclk [get_bd_pins vid_phy_sb_aclk] [get_bd_pins hdmi_gt_controller/sb_aclk]
  connect_bd_net -net net_bdry_in_vid_phy_sb_aresetn [get_bd_pins vid_phy_sb_aresetn] [get_bd_pins hdmi_gt_controller/sb_aresetn]
  connect_bd_net -net net_bdry_in_vid_phy_tx_axi4s_aresetn [get_bd_pins vid_phy_tx_axi4s_aresetn] [get_bd_pins hdmi_gt_controller/tx_axi4s_aresetn]
  connect_bd_net -net net_bufg_gt_rx_usrclk [get_bd_pins bufg_gt_rx/usrclk] [get_bd_pins rxoutclk] [get_bd_pins hdmi_gt_controller/gt_rxusrclk] [get_bd_pins hdmi_gt_controller/rx_axi4s_aclk] [get_bd_pins gtwiz_versal/QUAD0_RX0_usrclk] [get_bd_pins gtwiz_versal/QUAD0_RX1_usrclk] [get_bd_pins gtwiz_versal/QUAD0_RX2_usrclk] [get_bd_pins gtwiz_versal/QUAD0_RX3_usrclk]
  connect_bd_net -net net_bufg_gt_tx_usrclk [get_bd_pins bufg_gt_tx/usrclk] [get_bd_pins txoutclk] [get_bd_pins hdmi_gt_controller/gt_txusrclk] [get_bd_pins hdmi_gt_controller/tx_axi4s_aclk] [get_bd_pins gtwiz_versal/QUAD0_TX0_usrclk] [get_bd_pins gtwiz_versal/QUAD0_TX1_usrclk] [get_bd_pins gtwiz_versal/QUAD0_TX2_usrclk] [get_bd_pins gtwiz_versal/QUAD0_TX3_usrclk]
  connect_bd_net -net net_gtwiz_versal_INTF0_rst_tx_done_out [get_bd_pins gtwiz_versal/INTF0_rst_tx_done_out] [get_bd_pins hdmi_gt_controller/tx_full_rst_done]
  connect_bd_net -net net_gtwiz_versal_INTF1_rst_rx_done_out [get_bd_pins gtwiz_versal/INTF1_rst_rx_done_out] [get_bd_pins hdmi_gt_controller/rx_full_rst_done]
  connect_bd_net -net net_gtwiz_versal_QUAD0_RX0_outclk [get_bd_pins gtwiz_versal/QUAD0_RX0_outclk] [get_bd_pins bufg_gt_rx/outclk]
  connect_bd_net -net net_gtwiz_versal_QUAD0_TX0_outclk [get_bd_pins gtwiz_versal/QUAD0_TX0_outclk] [get_bd_pins bufg_gt_tx/outclk]
  connect_bd_net -net net_gtwiz_versal_QUAD0_ch0_iloresetdone [get_bd_pins gtwiz_versal/QUAD0_ch0_iloresetdone] [get_bd_pins hdmi_gt_controller/gt_ch0_ilo_resetdone]
  connect_bd_net -net net_gtwiz_versal_QUAD0_ch1_iloresetdone [get_bd_pins gtwiz_versal/QUAD0_ch1_iloresetdone] [get_bd_pins hdmi_gt_controller/gt_ch1_ilo_resetdone]
  connect_bd_net -net net_gtwiz_versal_QUAD0_ch2_iloresetdone [get_bd_pins gtwiz_versal/QUAD0_ch2_iloresetdone] [get_bd_pins hdmi_gt_controller/gt_ch2_ilo_resetdone]
  connect_bd_net -net net_gtwiz_versal_QUAD0_ch3_iloresetdone [get_bd_pins gtwiz_versal/QUAD0_ch3_iloresetdone] [get_bd_pins hdmi_gt_controller/gt_ch3_ilo_resetdone]
  connect_bd_net -net net_gtwiz_versal_QUAD0_hsclk0_lcplllock [get_bd_pins gtwiz_versal/QUAD0_hsclk0_lcplllock] [get_bd_pins hdmi_gt_controller/gt_lcpll0_lock]
  connect_bd_net -net net_gtwiz_versal_QUAD0_hsclk0_rplllock [get_bd_pins gtwiz_versal/QUAD0_hsclk0_rplllock] [get_bd_pins hdmi_gt_controller/gt_rpll0_lock]
  connect_bd_net -net net_gtwiz_versal_QUAD0_hsclk1_lcplllock [get_bd_pins gtwiz_versal/QUAD0_hsclk1_lcplllock] [get_bd_pins hdmi_gt_controller/gt_lcpll1_lock]
  connect_bd_net -net net_gtwiz_versal_QUAD0_hsclk1_rplllock [get_bd_pins gtwiz_versal/QUAD0_hsclk1_rplllock] [get_bd_pins hdmi_gt_controller/gt_rpll1_lock]
  connect_bd_net -net net_gtwiz_versal_gtpowergood [get_bd_pins gtwiz_versal/gtpowergood] [get_bd_pins xlcp/In0]
  connect_bd_net -net net_hdmi_gt_controller_gt_lcpll0_reset [get_bd_pins hdmi_gt_controller/gt_lcpll0_reset] [get_bd_pins gtwiz_versal/QUAD0_hsclk0_lcpllreset]
  connect_bd_net -net net_hdmi_gt_controller_gt_lcpll1_reset [get_bd_pins hdmi_gt_controller/gt_lcpll1_reset] [get_bd_pins gtwiz_versal/QUAD0_hsclk1_lcpllreset]
  connect_bd_net -net net_hdmi_gt_controller_gt_rpll0_reset [get_bd_pins hdmi_gt_controller/gt_rpll0_reset] [get_bd_pins gtwiz_versal/QUAD0_hsclk0_rpllreset]
  connect_bd_net -net net_hdmi_gt_controller_gt_rpll1_reset [get_bd_pins hdmi_gt_controller/gt_rpll1_reset] [get_bd_pins gtwiz_versal/QUAD0_hsclk1_rpllreset]
  connect_bd_net -net net_hdmi_gt_controller_irq [get_bd_pins hdmi_gt_controller/irq] [get_bd_pins irq]
  connect_bd_net -net net_hdmi_gt_controller_reset_rx_datapath [get_bd_pins hdmi_gt_controller/reset_rx_datapath] [get_bd_pins gtwiz_versal/INTF1_rst_rx_datapath_in]
  connect_bd_net -net net_hdmi_gt_controller_reset_rx_pll_and_datapath [get_bd_pins hdmi_gt_controller/reset_rx_pll_and_datapath] [get_bd_pins gtwiz_versal/INTF1_rst_rx_pll_and_datapath_in]
  connect_bd_net -net net_hdmi_gt_controller_reset_tx_datapath [get_bd_pins hdmi_gt_controller/reset_tx_datapath] [get_bd_pins gtwiz_versal/INTF0_rst_tx_datapath_in]
  connect_bd_net -net net_hdmi_gt_controller_reset_tx_pll_and_datapath [get_bd_pins hdmi_gt_controller/reset_tx_pll_and_datapath] [get_bd_pins gtwiz_versal/INTF0_rst_tx_pll_and_datapath_in]
  connect_bd_net -net net_hdmi_gt_controller_rx_full_rst [get_bd_pins hdmi_gt_controller/rx_full_rst] [get_bd_pins gtwiz_versal/INTF1_rst_all_in]
  connect_bd_net -net net_hdmi_gt_controller_rx_tmds_clk [get_bd_pins hdmi_gt_controller/rx_tmds_clk] [get_bd_pins rx_tmds_clk]
  connect_bd_net -net net_hdmi_gt_controller_rx_tmds_clk_n [get_bd_pins hdmi_gt_controller/rx_tmds_clk_n] [get_bd_pins rx_tmds_clk_n]
  connect_bd_net -net net_hdmi_gt_controller_rx_tmds_clk_p [get_bd_pins hdmi_gt_controller/rx_tmds_clk_p] [get_bd_pins rx_tmds_clk_p]
  connect_bd_net -net net_hdmi_gt_controller_rx_video_clk [get_bd_pins hdmi_gt_controller/rx_video_clk] [get_bd_pins rx_video_clk]
  connect_bd_net -net net_hdmi_gt_controller_tx_full_rst [get_bd_pins hdmi_gt_controller/tx_full_rst] [get_bd_pins gtwiz_versal/INTF0_rst_all_in]
  connect_bd_net -net net_hdmi_gt_controller_tx_tmds_clk [get_bd_pins hdmi_gt_controller/tx_tmds_clk] [get_bd_pins tx_tmds_clk]
  connect_bd_net -net net_hdmi_gt_controller_tx_video_clk [get_bd_pins hdmi_gt_controller/tx_video_clk] [get_bd_pins tx_video_clk]
  connect_bd_net -net net_urlp_Res [get_bd_pins urlp/Res] [get_bd_pins hdmi_gt_controller/gtpowergood]
  connect_bd_net -net net_xlcp_dout [get_bd_pins xlcp/dout] [get_bd_pins urlp/Op1]

  current_bd_instance $oldCurInst
}

# Hierarchical cell: gt_refclk_buf_ss_0
proc create_hier_cell_gt_refclk_buf_ss_0 { parentCell nameHier } {
  variable script_folder
  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_gt_refclk_buf_ss_0() - Empty argument(s)!"}
     return
  }
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }
  set oldCurInst [current_bd_instance .]
  current_bd_instance $parentObj
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 IBUFDSGT_IN
  create_bd_pin -dir O -from 0 -to 0 IBUFDSGT_OUT
  create_bd_pin -dir O -from 0 -to 0 IBUFDSGT_ODIV2_OUT
  create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf bufg_gt
  set_property -dict [list \
    CONFIG.C_BUF_TYPE {BUFG_GT} \
  ] [get_bd_cells bufg_gt]
  create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf ibufdsgte
  set_property -dict [list \
    CONFIG.C_BUF_TYPE {IBUFDSGTE} \
  ] [get_bd_cells ibufdsgte]
  create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant vcc_const
  set_property -dict [list \
    CONFIG.CONST_VAL {1} \
  ] [get_bd_cells vcc_const]
  connect_bd_intf_net -intf_net intf_net_bdry_in_IBUFDSGT_IN [get_bd_intf_pins IBUFDSGT_IN] [get_bd_intf_pins ibufdsgte/CLK_IN_D]
  connect_bd_net -net net_bufg_gt_BUFG_GT_O [get_bd_pins bufg_gt/BUFG_GT_O] [get_bd_pins IBUFDSGT_ODIV2_OUT]
  connect_bd_net -net net_ibufdsgte_IBUF_DS_ODIV2 [get_bd_pins ibufdsgte/IBUF_DS_ODIV2] [get_bd_pins bufg_gt/BUFG_GT_I]
  connect_bd_net -net net_ibufdsgte_IBUF_OUT [get_bd_pins ibufdsgte/IBUF_OUT] [get_bd_pins IBUFDSGT_OUT]
  connect_bd_net -net net_vcc_const_dout [get_bd_pins vcc_const/dout] [get_bd_pins bufg_gt/BUFG_GT_CE]

  current_bd_instance $oldCurInst
}

# Hierarchical cell: gt_refclk_buf_ss_1
proc create_hier_cell_gt_refclk_buf_ss_1 { parentCell nameHier } {
  variable script_folder
  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_gt_refclk_buf_ss_1() - Empty argument(s)!"}
     return
  }
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }
  set oldCurInst [current_bd_instance .]
  current_bd_instance $parentObj
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 IBUFDSGT_IN
  create_bd_pin -dir O -from 0 -to 0 IBUFDSGT_OUT
  create_bd_pin -dir O -from 0 -to 0 IBUFDSGT_ODIV2_OUT
  create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf bufg_gt
  set_property -dict [list \
    CONFIG.C_BUF_TYPE {BUFG_GT} \
  ] [get_bd_cells bufg_gt]
  create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf ibufdsgte
  set_property -dict [list \
    CONFIG.C_BUF_TYPE {IBUFDSGTE} \
  ] [get_bd_cells ibufdsgte]
  create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant vcc_const
  set_property -dict [list \
    CONFIG.CONST_VAL {1} \
  ] [get_bd_cells vcc_const]
  connect_bd_intf_net -intf_net intf_net_bdry_in_IBUFDSGT_IN [get_bd_intf_pins IBUFDSGT_IN] [get_bd_intf_pins ibufdsgte/CLK_IN_D]
  connect_bd_net -net net_bufg_gt_BUFG_GT_O [get_bd_pins bufg_gt/BUFG_GT_O] [get_bd_pins IBUFDSGT_ODIV2_OUT]
  connect_bd_net -net net_ibufdsgte_IBUF_DS_ODIV2 [get_bd_pins ibufdsgte/IBUF_DS_ODIV2] [get_bd_pins bufg_gt/BUFG_GT_I]
  connect_bd_net -net net_ibufdsgte_IBUF_OUT [get_bd_pins ibufdsgte/IBUF_OUT] [get_bd_pins IBUFDSGT_OUT]
  connect_bd_net -net net_vcc_const_dout [get_bd_pins vcc_const/dout] [get_bd_pins bufg_gt/BUFG_GT_CE]

  current_bd_instance $oldCurInst
}

# Hierarchical cell: gt_refclk_buf_ss_2
proc create_hier_cell_gt_refclk_buf_ss_2 { parentCell nameHier } {
  variable script_folder
  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_gt_refclk_buf_ss_2() - Empty argument(s)!"}
     return
  }
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }
  set oldCurInst [current_bd_instance .]
  current_bd_instance $parentObj
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 IBUFDSGT_IN
  create_bd_pin -dir O -from 0 -to 0 IBUFDSGT_OUT
  create_bd_pin -dir O -from 0 -to 0 IBUFDSGT_ODIV2_OUT
  create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf bufg_gt
  set_property -dict [list \
    CONFIG.C_BUF_TYPE {BUFG_GT} \
  ] [get_bd_cells bufg_gt]
  create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf ibufdsgte
  set_property -dict [list \
    CONFIG.C_BUF_TYPE {IBUFDSGTE} \
  ] [get_bd_cells ibufdsgte]
  create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant vcc_const
  set_property -dict [list \
    CONFIG.CONST_VAL {1} \
  ] [get_bd_cells vcc_const]
  connect_bd_intf_net -intf_net intf_net_bdry_in_IBUFDSGT_IN [get_bd_intf_pins IBUFDSGT_IN] [get_bd_intf_pins ibufdsgte/CLK_IN_D]
  connect_bd_net -net net_bufg_gt_BUFG_GT_O [get_bd_pins bufg_gt/BUFG_GT_O] [get_bd_pins IBUFDSGT_ODIV2_OUT]
  connect_bd_net -net net_ibufdsgte_IBUF_DS_ODIV2 [get_bd_pins ibufdsgte/IBUF_DS_ODIV2] [get_bd_pins bufg_gt/BUFG_GT_I]
  connect_bd_net -net net_ibufdsgte_IBUF_OUT [get_bd_pins ibufdsgte/IBUF_OUT] [get_bd_pins IBUFDSGT_OUT]
  connect_bd_net -net net_vcc_const_dout [get_bd_pins vcc_const/dout] [get_bd_pins bufg_gt/BUFG_GT_CE]

  current_bd_instance $oldCurInst
}

# Hierarchical cell: vfmc_ctlr_ss_0
proc create_hier_cell_vfmc_ctlr_ss_0 { parentCell nameHier } {
  variable script_folder
  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_vfmc_ctlr_ss_0() - Empty argument(s)!"}
     return
  }
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }
  set oldCurInst [current_bd_instance .]
  current_bd_instance $parentObj
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI
  create_bd_pin -dir O -from 0 -to 0 VFMC_TX_CH4_FRLSELn
  create_bd_pin -dir O -from 0 -to 0 VFMC_TX_LED0
  create_bd_pin -dir O -from 0 -to 0 VFMC_TX_LED1
  create_bd_pin -dir O -from 0 -to 0 VFMC_RX_CH4_FRLSELn
  create_bd_pin -dir O -from 0 -to 0 VFMC_RX_LED0
  create_bd_pin -dir O -from 0 -to 0 VFMC_RX_LED1
  create_bd_pin -dir O -from 0 -to 0 VFMC_RX_ONSEMI_ENABLE
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn
  create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio vfmc_gpio
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_GPIO_WIDTH {32} \
  ] [get_bd_cells vfmc_gpio]
  create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice vfmc_slice_bit0
  set_property -dict [list \
    CONFIG.DIN_FROM {0} \
    CONFIG.DIN_TO {0} \
    CONFIG.DIN_WIDTH {32} \
    CONFIG.DOUT_WIDTH {1} \
  ] [get_bd_cells vfmc_slice_bit0]
  create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice vfmc_slice_bit1
  set_property -dict [list \
    CONFIG.DIN_FROM {1} \
    CONFIG.DIN_TO {1} \
    CONFIG.DIN_WIDTH {32} \
    CONFIG.DOUT_WIDTH {1} \
  ] [get_bd_cells vfmc_slice_bit1]
  create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice vfmc_slice_bit2
  set_property -dict [list \
    CONFIG.DIN_FROM {2} \
    CONFIG.DIN_TO {2} \
    CONFIG.DIN_WIDTH {32} \
    CONFIG.DOUT_WIDTH {1} \
  ] [get_bd_cells vfmc_slice_bit2]
  create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice vfmc_slice_bit16
  set_property -dict [list \
    CONFIG.DIN_FROM {16} \
    CONFIG.DIN_TO {16} \
    CONFIG.DIN_WIDTH {32} \
    CONFIG.DOUT_WIDTH {1} \
  ] [get_bd_cells vfmc_slice_bit16]
  create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice vfmc_slice_bit17
  set_property -dict [list \
    CONFIG.DIN_FROM {17} \
    CONFIG.DIN_TO {17} \
    CONFIG.DIN_WIDTH {32} \
    CONFIG.DOUT_WIDTH {1} \
  ] [get_bd_cells vfmc_slice_bit17]
  create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice vfmc_slice_bit18
  set_property -dict [list \
    CONFIG.DIN_FROM {18} \
    CONFIG.DIN_TO {18} \
    CONFIG.DIN_WIDTH {32} \
    CONFIG.DOUT_WIDTH {1} \
  ] [get_bd_cells vfmc_slice_bit18]
  create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice vfmc_slice_bit19
  set_property -dict [list \
    CONFIG.DIN_FROM {19} \
    CONFIG.DIN_TO {19} \
    CONFIG.DIN_WIDTH {32} \
    CONFIG.DOUT_WIDTH {1} \
  ] [get_bd_cells vfmc_slice_bit19]
  connect_bd_intf_net -intf_net intf_net_bdry_in_S_AXI [get_bd_intf_pins S_AXI] [get_bd_intf_pins vfmc_gpio/S_AXI]
  connect_bd_net -net net_bdry_in_s_axi_aclk [get_bd_pins s_axi_aclk] [get_bd_pins vfmc_gpio/s_axi_aclk]
  connect_bd_net -net net_bdry_in_s_axi_aresetn [get_bd_pins s_axi_aresetn] [get_bd_pins vfmc_gpio/s_axi_aresetn]
  connect_bd_net -net net_vfmc_gpio_gpio_io_o [get_bd_pins vfmc_gpio/gpio_io_o] [get_bd_pins vfmc_slice_bit0/Din] [get_bd_pins vfmc_slice_bit1/Din] [get_bd_pins vfmc_slice_bit2/Din] [get_bd_pins vfmc_slice_bit16/Din] [get_bd_pins vfmc_slice_bit17/Din] [get_bd_pins vfmc_slice_bit18/Din] [get_bd_pins vfmc_slice_bit19/Din]
  connect_bd_net -net net_vfmc_slice_bit0_Dout [get_bd_pins vfmc_slice_bit0/Dout] [get_bd_pins VFMC_TX_LED0]
  connect_bd_net -net net_vfmc_slice_bit16_Dout [get_bd_pins vfmc_slice_bit16/Dout] [get_bd_pins VFMC_RX_LED0]
  connect_bd_net -net net_vfmc_slice_bit17_Dout [get_bd_pins vfmc_slice_bit17/Dout] [get_bd_pins VFMC_RX_LED1]
  connect_bd_net -net net_vfmc_slice_bit18_Dout [get_bd_pins vfmc_slice_bit18/Dout] [get_bd_pins VFMC_RX_CH4_FRLSELn]
  connect_bd_net -net net_vfmc_slice_bit19_Dout [get_bd_pins vfmc_slice_bit19/Dout] [get_bd_pins VFMC_RX_ONSEMI_ENABLE]
  connect_bd_net -net net_vfmc_slice_bit1_Dout [get_bd_pins vfmc_slice_bit1/Dout] [get_bd_pins VFMC_TX_LED1]
  connect_bd_net -net net_vfmc_slice_bit2_Dout [get_bd_pins vfmc_slice_bit2/Dout] [get_bd_pins VFMC_TX_CH4_FRLSELn]

  current_bd_instance $oldCurInst
}

# Hierarchical cell: hdmi_tx_ss_hier
proc create_hier_cell_hdmi_tx_ss_hier { parentCell nameHier } {
  variable script_folder
  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_hdmi_tx_ss_hier() - Empty argument(s)!"}
     return
  }
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }
  set oldCurInst [current_bd_instance .]
  current_bd_instance $parentObj
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 TX_DDC_OUT
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 HDMI_CTRL
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 GT_Serial
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 GT_DRU_FRL_CLK_IN
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 TX_REFCLK_P_IN_V
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 HDMI_RX_CLK_P_IN_V
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M00_INI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M01_INI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M02_INI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M03_INI
  create_bd_pin -dir I TX_HPD_IN
  create_bd_pin -dir O LED0
  create_bd_pin -dir I IDT8T49N241_LOL_IN
  create_bd_pin -dir O -type clk RX_REFCLK_P_OUT
  create_bd_pin -dir O -type clk RX_REFCLK_N_OUT
  create_bd_pin -dir O -from 0 -to 0 TX_TI_ENABLE
  create_bd_pin -dir O -type intr Timer_interrupt
  create_bd_pin -dir I -type clk clk_in1
  create_bd_pin -dir I -from 0 -to 0 Op1
  create_bd_pin -dir O -type intr hdmi_txss_irq
  create_bd_pin -dir O hdmi_gt_irq
  create_bd_pin -dir O -type intr iic2intc_irpt
  create_bd_pin -dir O -type intr Mixer_irq
  create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset rst_processor_1_300M
  set_property -dict [list \
    CONFIG.C_NUM_INTERCONNECT_ARESETN {1} \
  ] [get_bd_cells rst_processor_1_300M]
  create_bd_cell -type ip -vlnv xilinx.com:ip:axis_register_slice tx_video_axis_reg_slice
  create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice ilslice_5
  set_property -dict [list \
    CONFIG.DIN_TO {5} \
    CONFIG.DIN_WIDTH {8} \
  ] [get_bd_cells ilslice_5]
  create_bd_cell -type ip -vlnv xilinx.com:ip:v_hdmi_txss1 v_hdmi_txss1
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
    CONFIG.C_INPUT_PIXELS_PER_CLOCK {8} \
    CONFIG.C_MAX_BITS_PER_COMPONENT {8} \
    CONFIG.C_VALIDATION_ENABLE {false} \
    CONFIG.C_VID_INTERFACE {0} \
    CONFIG.C_VRR_SUPPORT {1} \
  ] [get_bd_cells v_hdmi_txss1]
  create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant ilconstant_1
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {192} \
  ] [get_bd_cells ilconstant_1]
  create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset rst_processor_1_100M
  set_property -dict [list \
    CONFIG.C_NUM_INTERCONNECT_ARESETN {1} \
  ] [get_bd_cells rst_processor_1_100M]
  create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant vcc_const
  set_property -dict [list \
    CONFIG.CONST_VAL {1} \
  ] [get_bd_cells vcc_const]
  create_bd_cell -type ip -vlnv xilinx.com:ip:clkx5_wiz clkx_wiz_0
  set_property -dict [list \
    CONFIG.CLKOUT_DRIVES {BUFG,BUFG,BUFG,BUFG,BUFG,BUFG,BUFG} \
    CONFIG.CLKOUT_DYN_PS {None,None,None,None,None,None,None} \
    CONFIG.CLKOUT_GROUPING {Auto,Auto,Auto,Auto,Auto,Auto,Auto} \
    CONFIG.CLKOUT_MATCHED_ROUTING {false,false,false,false,false,false,false} \
    CONFIG.CLKOUT_PORT {clk_out1,clk_out2,clk_out3,clk_out4,clk_out5,clk_out6,clk_out7} \
    CONFIG.CLKOUT_REQUESTED_DUTY_CYCLE {50.000,50.000,50.000,50.000,50.000,50.000,50.000} \
    CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {450,300,100.000,100.000,100.000,100.000,100.000} \
    CONFIG.CLKOUT_REQUESTED_PHASE {0.000,0.000,0.000,0.000,0.000,0.000,0.000} \
    CONFIG.CLKOUT_USED {true,true,false,false,false,false,false} \
    CONFIG.PRIM_SOURCE {No_buffer} \
    CONFIG.USE_LOCKED {true} \
    CONFIG.USE_RESET {true} \
  ] [get_bd_cells clkx_wiz_0]
  create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc2 axi_noc2_0
  set_property -dict [list \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NMI {4} \
    CONFIG.NUM_SI {8} \
  ] [get_bd_cells axi_noc2_0]
  set_property -dict [list \
    CONFIG.DATA_WIDTH {512} \
    CONFIG.CONNECTIONS {M00_INI {read_bw {1075} write_bw {0} }} \
    CONFIG.DEST_IDS {} \
    CONFIG.NOC_PARAMS {} \
    CONFIG.CATEGORY {pl} \
  ] [get_bd_intf_pins axi_noc2_0/S00_AXI]
  set_property -dict [list \
    CONFIG.DATA_WIDTH {512} \
    CONFIG.CONNECTIONS {M01_INI {read_bw {1075} write_bw {0} }} \
    CONFIG.DEST_IDS {} \
    CONFIG.NOC_PARAMS {} \
    CONFIG.CATEGORY {pl} \
  ] [get_bd_intf_pins axi_noc2_0/S01_AXI]
  set_property -dict [list \
    CONFIG.DATA_WIDTH {512} \
    CONFIG.CONNECTIONS {M02_INI {read_bw {1075} write_bw {0} }} \
    CONFIG.DEST_IDS {} \
    CONFIG.NOC_PARAMS {} \
    CONFIG.CATEGORY {pl} \
  ] [get_bd_intf_pins axi_noc2_0/S02_AXI]
  set_property -dict [list \
    CONFIG.DATA_WIDTH {512} \
    CONFIG.CONNECTIONS {M03_INI {read_bw {1075} write_bw {0} }} \
    CONFIG.DEST_IDS {} \
    CONFIG.NOC_PARAMS {} \
    CONFIG.CATEGORY {pl} \
  ] [get_bd_intf_pins axi_noc2_0/S03_AXI]
  set_property -dict [list \
    CONFIG.DATA_WIDTH {512} \
    CONFIG.CONNECTIONS {M00_INI {read_bw {1075} write_bw {0} }} \
    CONFIG.DEST_IDS {} \
    CONFIG.NOC_PARAMS {} \
    CONFIG.CATEGORY {pl} \
  ] [get_bd_intf_pins axi_noc2_0/S04_AXI]
  set_property -dict [list \
    CONFIG.DATA_WIDTH {512} \
    CONFIG.CONNECTIONS {M01_INI {read_bw {1075} write_bw {0} }} \
    CONFIG.DEST_IDS {} \
    CONFIG.NOC_PARAMS {} \
    CONFIG.CATEGORY {pl} \
  ] [get_bd_intf_pins axi_noc2_0/S05_AXI]
  set_property -dict [list \
    CONFIG.DATA_WIDTH {512} \
    CONFIG.CONNECTIONS {M02_INI {read_bw {1075} write_bw {0} }} \
    CONFIG.DEST_IDS {} \
    CONFIG.NOC_PARAMS {} \
    CONFIG.CATEGORY {pl} \
  ] [get_bd_intf_pins axi_noc2_0/S06_AXI]
  set_property -dict [list \
    CONFIG.DATA_WIDTH {512} \
    CONFIG.CONNECTIONS {M03_INI {read_bw {1075} write_bw {0} }} \
    CONFIG.DEST_IDS {} \
    CONFIG.NOC_PARAMS {} \
    CONFIG.CATEGORY {pl} \
  ] [get_bd_intf_pins axi_noc2_0/S07_AXI]
  set_property -dict [list \
    CONFIG.ASSOCIATED_BUSIF {S00_AXI:S01_AXI:S02_AXI:S03_AXI:S04_AXI:S05_AXI:S06_AXI:S07_AXI} \
  ] [get_bd_pins axi_noc2_0/aclk0]
  create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilvector_logic util_vector_logic_0
  set_property -dict [list \
    CONFIG.C_OPERATION {not} \
    CONFIG.C_SIZE {1} \
  ] [get_bd_cells util_vector_logic_0]
  create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio axi_gpio
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_DOUT_DEFAULT {0x000000FF} \
    CONFIG.C_GPIO_WIDTH {8} \
  ] [get_bd_cells axi_gpio]
  create_bd_cell -type ip -vlnv xilinx.com:ip:video_cke_sync v_fifo_dc
  create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect axi_smartconnect_0
  set_property -dict [list \
    CONFIG.ADVANCED_PROPERTIES {__experimental_features__ {legacy_low_area_mode 1}} \
    CONFIG.NUM_CLKS {2} \
    CONFIG.NUM_MI {7} \
    CONFIG.NUM_SI {1} \
  ] [get_bd_cells axi_smartconnect_0]
  create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic axi_iic_0
  set_property -dict [list \
    CONFIG.TEN_BIT_ADR {7_bit} \
  ] [get_bd_cells axi_iic_0]
  create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer axi_timer_0
  set_property -dict [list \
    CONFIG.COUNT_WIDTH {32} \
  ] [get_bd_cells axi_timer_0]
  create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant ilconstant_0
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
  ] [get_bd_cells ilconstant_0]
  create_bd_cell -type ip -vlnv xilinx.com:ip:v_mix v_mix_1
  set_property -dict [list \
    CONFIG.AXIMM_ADDR_WIDTH {64} \
    CONFIG.IS_TILE_FORMAT {0} \
    CONFIG.LAYER10_VIDEO_FORMAT {19} \
    CONFIG.LAYER11_VIDEO_FORMAT {19} \
    CONFIG.LAYER12_VIDEO_FORMAT {19} \
    CONFIG.LAYER1_VIDEO_FORMAT {18} \
    CONFIG.LAYER2_VIDEO_FORMAT {18} \
    CONFIG.LAYER3_VIDEO_FORMAT {18} \
    CONFIG.LAYER4_VIDEO_FORMAT {18} \
    CONFIG.LAYER5_VIDEO_FORMAT {19} \
    CONFIG.LAYER6_VIDEO_FORMAT {19} \
    CONFIG.LAYER7_VIDEO_FORMAT {19} \
    CONFIG.LAYER8_VIDEO_FORMAT {19} \
    CONFIG.LAYER9_VIDEO_FORMAT {19} \
    CONFIG.MAX_DATA_WIDTH {8} \
    CONFIG.NR_LAYERS {9} \
    CONFIG.SAMPLES_PER_CLOCK {8} \
  ] [get_bd_cells v_mix_1]
  create_hier_cell_hdmiphy_ss_0 $hier_obj hdmiphy_ss_0
  create_hier_cell_gt_refclk_buf_ss_0 $hier_obj gt_refclk_buf_ss_0
  create_hier_cell_gt_refclk_buf_ss_1 $hier_obj gt_refclk_buf_ss_1
  create_hier_cell_gt_refclk_buf_ss_2 $hier_obj gt_refclk_buf_ss_2
  create_hier_cell_vfmc_ctlr_ss_0 $hier_obj vfmc_ctlr_ss_0
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins axi_smartconnect_0/S00_AXI] [get_bd_intf_pins S00_AXI]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins axi_noc2_0/M00_INI] [get_bd_intf_pins M00_INI]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins axi_noc2_0/M01_INI] [get_bd_intf_pins M01_INI]
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins axi_noc2_0/M02_INI] [get_bd_intf_pins M02_INI]
  connect_bd_intf_net -intf_net axi_noc2_0_M03_INI [get_bd_intf_pins M03_INI] [get_bd_intf_pins axi_noc2_0/M03_INI]
  connect_bd_intf_net -intf_net axi_smartconnect_0_M01_AXI [get_bd_intf_pins axi_smartconnect_0/M01_AXI] [get_bd_intf_pins vfmc_ctlr_ss_0/S_AXI]
  connect_bd_intf_net -intf_net axi_smartconnect_0_M03_AXI [get_bd_intf_pins axi_smartconnect_0/M03_AXI] [get_bd_intf_pins axi_iic_0/S_AXI]
  connect_bd_intf_net -intf_net axi_smartconnect_0_M04_AXI [get_bd_intf_pins axi_smartconnect_0/M04_AXI] [get_bd_intf_pins v_mix_1/s_axi_CTRL]
  connect_bd_intf_net -intf_net axi_smartconnect_0_M05_AXI [get_bd_intf_pins axi_smartconnect_0/M05_AXI] [get_bd_intf_pins axi_gpio/S_AXI]
  connect_bd_intf_net -intf_net axi_smartconnect_0_M06_AXI [get_bd_intf_pins axi_smartconnect_0/M06_AXI] [get_bd_intf_pins axi_timer_0/S_AXI]
  connect_bd_intf_net -intf_net intf_net_bdry_in_GT_DRU_FRL_CLK_IN [get_bd_intf_pins GT_DRU_FRL_CLK_IN] [get_bd_intf_pins gt_refclk_buf_ss_0/IBUFDSGT_IN]
  connect_bd_intf_net -intf_net intf_net_bdry_in_HDMI_RX_CLK_P_IN_V [get_bd_intf_pins HDMI_RX_CLK_P_IN_V] [get_bd_intf_pins gt_refclk_buf_ss_2/IBUFDSGT_IN]
  connect_bd_intf_net -intf_net intf_net_bdry_in_TX_REFCLK_P_IN_V [get_bd_intf_pins TX_REFCLK_P_IN_V] [get_bd_intf_pins gt_refclk_buf_ss_1/IBUFDSGT_IN]
  connect_bd_intf_net -intf_net intf_net_cips_ss_0_IIC [get_bd_intf_pins HDMI_CTRL] [get_bd_intf_pins axi_iic_0/IIC]
  connect_bd_intf_net -intf_net intf_net_cips_ss_0_M00_AXI [get_bd_intf_pins axi_smartconnect_0/M00_AXI] [get_bd_intf_pins hdmiphy_ss_0/vid_phy_axi4lite]
  connect_bd_intf_net -intf_net intf_net_cips_ss_0_M02_AXI [get_bd_intf_pins axi_smartconnect_0/M02_AXI] [get_bd_intf_pins v_hdmi_txss1/S_AXI_CPU_IN]
  connect_bd_intf_net -intf_net intf_net_hdmiphy_ss_0_phy_data [get_bd_intf_pins GT_Serial] [get_bd_intf_pins hdmiphy_ss_0/phy_data]
  connect_bd_intf_net -intf_net intf_net_hdmiphy_ss_0_vid_phy_status_sb_tx [get_bd_intf_pins hdmiphy_ss_0/vid_phy_status_sb_tx] [get_bd_intf_pins v_hdmi_txss1/SB_STATUS_IN]
  connect_bd_intf_net -intf_net intf_net_tx_video_axis_reg_slice_M_AXIS [get_bd_intf_pins tx_video_axis_reg_slice/M_AXIS] [get_bd_intf_pins v_hdmi_txss1/VIDEO_IN]
  connect_bd_intf_net -intf_net intf_net_v_hdmi_txss1_DDC_OUT [get_bd_intf_pins TX_DDC_OUT] [get_bd_intf_pins v_hdmi_txss1/DDC_OUT]
  connect_bd_intf_net -intf_net intf_net_v_hdmi_txss1_LINK_DATA0_OUT [get_bd_intf_pins v_hdmi_txss1/LINK_DATA0_OUT] [get_bd_intf_pins hdmiphy_ss_0/vid_phy_tx_axi4s_ch0]
  connect_bd_intf_net -intf_net intf_net_v_hdmi_txss1_LINK_DATA1_OUT [get_bd_intf_pins v_hdmi_txss1/LINK_DATA1_OUT] [get_bd_intf_pins hdmiphy_ss_0/vid_phy_tx_axi4s_ch1]
  connect_bd_intf_net -intf_net intf_net_v_hdmi_txss1_LINK_DATA2_OUT [get_bd_intf_pins v_hdmi_txss1/LINK_DATA2_OUT] [get_bd_intf_pins hdmiphy_ss_0/vid_phy_tx_axi4s_ch2]
  connect_bd_intf_net -intf_net intf_net_v_hdmi_txss1_LINK_DATA3_OUT [get_bd_intf_pins v_hdmi_txss1/LINK_DATA3_OUT] [get_bd_intf_pins hdmiphy_ss_0/vid_phy_tx_axi4s_ch3]
  connect_bd_intf_net -intf_net v_mix_1_m_axi_mm_video1 [get_bd_intf_pins v_mix_1/m_axi_mm_video1] [get_bd_intf_pins axi_noc2_0/S00_AXI]
  connect_bd_intf_net -intf_net v_mix_1_m_axi_mm_video2 [get_bd_intf_pins v_mix_1/m_axi_mm_video2] [get_bd_intf_pins axi_noc2_0/S01_AXI]
  connect_bd_intf_net -intf_net v_mix_1_m_axi_mm_video3 [get_bd_intf_pins v_mix_1/m_axi_mm_video3] [get_bd_intf_pins axi_noc2_0/S02_AXI]
  connect_bd_intf_net -intf_net v_mix_1_m_axi_mm_video4 [get_bd_intf_pins v_mix_1/m_axi_mm_video4] [get_bd_intf_pins axi_noc2_0/S03_AXI]
  connect_bd_intf_net -intf_net v_mix_1_m_axi_mm_video5 [get_bd_intf_pins v_mix_1/m_axi_mm_video5] [get_bd_intf_pins axi_noc2_0/S04_AXI]
  connect_bd_intf_net -intf_net v_mix_1_m_axi_mm_video6 [get_bd_intf_pins v_mix_1/m_axi_mm_video6] [get_bd_intf_pins axi_noc2_0/S05_AXI]
  connect_bd_intf_net -intf_net v_mix_1_m_axi_mm_video7 [get_bd_intf_pins v_mix_1/m_axi_mm_video7] [get_bd_intf_pins axi_noc2_0/S06_AXI]
  connect_bd_intf_net -intf_net v_mix_1_m_axi_mm_video8 [get_bd_intf_pins v_mix_1/m_axi_mm_video8] [get_bd_intf_pins axi_noc2_0/S07_AXI]
  connect_bd_intf_net -intf_net v_mix_1_m_axis_video [get_bd_intf_pins tx_video_axis_reg_slice/S_AXIS] [get_bd_intf_pins v_mix_1/m_axis_video]
  connect_bd_net -net Net [get_bd_pins Op1] [get_bd_pins rst_processor_1_100M/ext_reset_in] [get_bd_pins util_vector_logic_0/Op1] [get_bd_pins rst_processor_1_100M/aux_reset_in] [get_bd_pins rst_processor_1_100M/dcm_locked]
  connect_bd_net -net axi_gpio_gpio_io_o [get_bd_pins axi_gpio/gpio_io_o] [get_bd_pins ilslice_5/Din]
  connect_bd_net -net axi_iic_0_iic2intc_irpt [get_bd_pins axi_iic_0/iic2intc_irpt] [get_bd_pins iic2intc_irpt]
  connect_bd_net -net axi_timer_0_interrupt [get_bd_pins axi_timer_0/interrupt] [get_bd_pins Timer_interrupt]
  connect_bd_net -net hdmiphy_ss_0_irq [get_bd_pins hdmiphy_ss_0/irq] [get_bd_pins hdmi_gt_irq]
  connect_bd_net -net ilconstant_0_dout [get_bd_pins ilconstant_0/dout] [get_bd_pins v_hdmi_txss1/s_axis_audio_aclk] [get_bd_pins v_hdmi_txss1/fid]
  connect_bd_net -net ilconstant_1_dout [get_bd_pins ilconstant_1/dout] [get_bd_pins v_mix_1/s_axis_video_TVALID] [get_bd_pins v_mix_1/s_axis_video_TDATA]
  connect_bd_net -net ilslice_5_Dout [get_bd_pins ilslice_5/Dout] [get_bd_pins v_mix_1/ap_rst_n]
  connect_bd_net -net net_bdry_in_IDT8T49N241_LOL_IN [get_bd_pins IDT8T49N241_LOL_IN] [get_bd_pins hdmiphy_ss_0/tx_refclk_rdy]
  connect_bd_net -net net_bdry_in_TX_HPD_IN [get_bd_pins TX_HPD_IN] [get_bd_pins v_hdmi_txss1/hpd]
  connect_bd_net -net net_cips_ss_0_clk_out2 [get_bd_pins clkx_wiz_0/clk_out2] [get_bd_pins tx_video_axis_reg_slice/aclk] [get_bd_pins v_fifo_dc/rstn_clk] [get_bd_pins rst_processor_1_300M/slowest_sync_clk] [get_bd_pins axi_gpio/s_axi_aclk] [get_bd_pins axi_noc2_0/aclk0] [get_bd_pins axi_smartconnect_0/aclk1] [get_bd_pins v_hdmi_txss1/s_axis_video_aclk] [get_bd_pins v_mix_1/ap_clk]
  connect_bd_net -net net_cips_ss_0_dcm_locked [get_bd_pins rst_processor_1_300M/peripheral_aresetn] [get_bd_pins tx_video_axis_reg_slice/aresetn] [get_bd_pins v_fifo_dc/rstn] [get_bd_pins axi_gpio/s_axi_aresetn] [get_bd_pins v_hdmi_txss1/s_axis_video_aresetn]
  connect_bd_net -net net_cips_ss_0_frl_clk [get_bd_pins clkx_wiz_0/clk_out1] [get_bd_pins v_hdmi_txss1/frl_clk]
  connect_bd_net -net net_cips_ss_0_peripheral_aresetn [get_bd_pins rst_processor_1_100M/peripheral_aresetn] [get_bd_pins hdmiphy_ss_0/vid_phy_sb_aresetn] [get_bd_pins hdmiphy_ss_0/vid_phy_axi4lite_aresetn] [get_bd_pins vfmc_ctlr_ss_0/s_axi_aresetn] [get_bd_pins axi_iic_0/s_axi_aresetn] [get_bd_pins axi_timer_0/s_axi_aresetn] [get_bd_pins v_hdmi_txss1/s_axi_cpu_aresetn]
  connect_bd_net -net net_clkx_wiz_0_locked [get_bd_pins clkx_wiz_0/locked] [get_bd_pins rst_processor_1_300M/aux_reset_in] [get_bd_pins rst_processor_1_300M/dcm_locked] [get_bd_pins rst_processor_1_300M/ext_reset_in]
  connect_bd_net -net net_gt_refclk_buf_ss_0_IBUFDSGT_ODIV2_OUT [get_bd_pins gt_refclk_buf_ss_0/IBUFDSGT_ODIV2_OUT] [get_bd_pins hdmiphy_ss_0/dru_ref_clk_odiv2_in]
  connect_bd_net -net net_gt_refclk_buf_ss_0_IBUFDSGT_OUT [get_bd_pins gt_refclk_buf_ss_0/IBUFDSGT_OUT] [get_bd_pins hdmiphy_ss_0/dru_ref_clk_in]
  connect_bd_net -net net_gt_refclk_buf_ss_1_IBUFDSGT_ODIV2_OUT [get_bd_pins gt_refclk_buf_ss_1/IBUFDSGT_ODIV2_OUT] [get_bd_pins hdmiphy_ss_0/tx_ref_clk_odiv2_in]
  connect_bd_net -net net_gt_refclk_buf_ss_1_IBUFDSGT_OUT [get_bd_pins gt_refclk_buf_ss_1/IBUFDSGT_OUT] [get_bd_pins hdmiphy_ss_0/tx_ref_clk_in]
  connect_bd_net -net net_gt_refclk_buf_ss_2_IBUFDSGT_ODIV2_OUT [get_bd_pins gt_refclk_buf_ss_2/IBUFDSGT_ODIV2_OUT] [get_bd_pins hdmiphy_ss_0/rx_ref_clk_odiv2_in]
  connect_bd_net -net net_gt_refclk_buf_ss_2_IBUFDSGT_OUT [get_bd_pins gt_refclk_buf_ss_2/IBUFDSGT_OUT] [get_bd_pins hdmiphy_ss_0/rx_ref_clk_in]
  connect_bd_net -net net_hdmiphy_ss_0_rx_tmds_clk_n [get_bd_pins hdmiphy_ss_0/rx_tmds_clk_n] [get_bd_pins RX_REFCLK_N_OUT]
  connect_bd_net -net net_hdmiphy_ss_0_rx_tmds_clk_p [get_bd_pins hdmiphy_ss_0/rx_tmds_clk_p] [get_bd_pins RX_REFCLK_P_OUT]
  connect_bd_net -net net_hdmiphy_ss_0_rx_video_clk [get_bd_pins hdmiphy_ss_0/rx_video_clk] [get_bd_pins v_fifo_dc/a_clk]
  connect_bd_net -net net_hdmiphy_ss_0_tx_video_clk [get_bd_pins hdmiphy_ss_0/tx_video_clk] [get_bd_pins v_fifo_dc/b_clk] [get_bd_pins v_hdmi_txss1/video_clk]
  connect_bd_net -net net_hdmiphy_ss_0_txoutclk [get_bd_pins hdmiphy_ss_0/txoutclk] [get_bd_pins v_hdmi_txss1/link_clk]
  connect_bd_net -net net_rst_processor_1_100M_interconnect_aresetn [get_bd_pins rst_processor_1_100M/interconnect_aresetn] [get_bd_pins axi_smartconnect_0/aresetn]
  connect_bd_net -net net_util_vector_logic_0_Res [get_bd_pins util_vector_logic_0/Res] [get_bd_pins clkx_wiz_0/reset]
  connect_bd_net -net net_v_fifo_dc_b_de_out [get_bd_pins v_fifo_dc/b_de_out] [get_bd_pins v_hdmi_txss1/video_cke_in]
  connect_bd_net -net net_v_hdmi_txss1_locked [get_bd_pins v_hdmi_txss1/locked] [get_bd_pins LED0]
  connect_bd_net -net net_vcc_const_dout [get_bd_pins vcc_const/dout] [get_bd_pins hdmiphy_ss_0/vid_phy_tx_axi4s_aresetn] [get_bd_pins hdmiphy_ss_0/vid_phy_rx_axi4s_aresetn] [get_bd_pins v_fifo_dc/a_dat_in] [get_bd_pins v_fifo_dc/b_rd_in]
  connect_bd_net -net net_vfmc_ctlr_ss_0_VFMC_RX_ONSEMI_ENABLE [get_bd_pins vfmc_ctlr_ss_0/VFMC_RX_ONSEMI_ENABLE] [get_bd_pins TX_TI_ENABLE]
  connect_bd_net -net ps_wizard_0_pl0_ref_clk [get_bd_pins clk_in1] [get_bd_pins hdmiphy_ss_0/vid_phy_sb_aclk] [get_bd_pins hdmiphy_ss_0/vid_phy_axi4lite_aclk] [get_bd_pins vfmc_ctlr_ss_0/s_axi_aclk] [get_bd_pins hdmiphy_ss_0/drpclk] [get_bd_pins rst_processor_1_100M/slowest_sync_clk] [get_bd_pins axi_iic_0/s_axi_aclk] [get_bd_pins axi_smartconnect_0/aclk] [get_bd_pins axi_timer_0/s_axi_aclk] [get_bd_pins clkx_wiz_0/clk_in1] [get_bd_pins v_hdmi_txss1/s_axi_cpu_aclk]
  connect_bd_net -net v_hdmi_txss1_irq [get_bd_pins v_hdmi_txss1/irq] [get_bd_pins hdmi_txss_irq]
  connect_bd_net -net v_mix_1_interrupt [get_bd_pins v_mix_1/interrupt] [get_bd_pins Mixer_irq]

  current_bd_instance $oldCurInst

}

proc available_tcl_procs { } {
   puts "##################################################################"
   puts "# Available Tcl procedures to recreate hierarchical blocks:"
   puts "#"
   puts "#    create_hier_cell_hdmi_tx_ss_hier parentCell nameHier"
   puts "#    create_hier_cell_hdmiphy_ss_0 parentCell nameHier"
   puts "#    create_hier_cell_gt_refclk_buf_ss_0 parentCell nameHier"
   puts "#    create_hier_cell_gt_refclk_buf_ss_1 parentCell nameHier"
   puts "#    create_hier_cell_gt_refclk_buf_ss_2 parentCell nameHier"
   puts "#    create_hier_cell_vfmc_ctlr_ss_0 parentCell nameHier"
   puts "#"
   puts "##################################################################"
}

available_tcl_procs

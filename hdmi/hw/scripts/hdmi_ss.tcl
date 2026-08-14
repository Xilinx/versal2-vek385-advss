# Copyright (C) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

################################################################################
# hdmi_ss hierarchy - pin-out description
#
# The 'hdmi_ss' hierarchy (created by create_hier_cell_hdmi_ss) is a complete,
# self-contained HDMI 2.1 capture/playback datapath. The pipeline is shown below:
#
#     HDMI Rx  ->  Frame Buffer Wr  ->  DDR  ->  Frame Buffer Rd  ->  HDMI Tx
#                  (v_frmbuf_wr)                 (v_frmbuf_rd)
#
# Internally it instantiates the HDMI RX SS, HDMI TX SS, HDMI GT Controller (PHY),
# Audio SS (ACR + pattern gen), Video Processor SS (scaler), Frame Buffer Wr/Rd,
# clock-domain crossing FIFOs, AXI IIC, two AXI Timers, reset GPIO, and AXI
# SmartConnect for all AXI4-Lite control. To use it standalone you only have to
# drive the clocks/resets, hook the frame-buffer AXI-MM masters to a memory
# controller (DDR via NoC), route the GT/board I/O to top-level ports/constraints,
# and connect S00_AXI to a CPU/AXI master plus the interrupt outputs to your
# interrupt controller.
#
# ------------------------------------------------------------------------------
# INTERFACE PINS
# ------------------------------------------------------------------------------
#   S00_AXI                       [S, AXI4-Lite] Control bus for ALL internal IPs
#                                                (RX/TX SS, GT Controller, frame
#                                                buffers, VPSS, audio, IIC, timers,
#                                                reset GPIO). Connect to CPU.
#   M00_INI, M01_INI, M02_INI,    [M, INI-MM   ] NoC master ports to DDR (frame
#   M03_INI                                      buffer write/read). Connect to
#                                                NoC_C0_C1 or NoC_C2_C3.
#   RX_DDC_OUT                    [M, IIC      ] HDMI RX DDC/EDID I2C to RX connector.
#   TX_DDC_OUT                    [M, IIC      ] HDMI TX DDC I2C to TX connector.
#   IIC_HDMI_CTRL                 [M, IIC      ] Board control I2C (clock gen/retimers).
#   GT_DRU_FRL_CLK_IN             [S, diff clk ] DRU reference clock (differential) for
#                                                HDMI GT Controller FRL mode.
#
# ------------------------------------------------------------------------------
# CLOCKS / RESETS (all active-low resets)
# ------------------------------------------------------------------------------
#   s_axi_cpu_aclk                [I clk] AXI4-Lite control clock (drives S00_AXI + IPs).
#   s_axi_cpu_aresetn             [I rst] AXI4-Lite control reset.
#   s_axis_video_aclk             [I clk] Video/AXIS datapath clock (300 MHz for 4K60).
#   s_axis_video_aresetn          [I rst] Video/AXIS datapath reset.
#   frl_clk                       [I clk] FRL (Fixed Rate Link) clock (450 MHz for HDMI 2.1).
#
# ------------------------------------------------------------------------------
# GT / TRANSCEIVER + BOARD I/O (route to top-level ports / constraints)
# ------------------------------------------------------------------------------
#   HDMI_RX_CLK_P_IN / _N_IN      [I]      RX GT reference clock (differential).
#   TX_REFCLK_P_IN   / _N_IN      [I]      TX GT reference clock (differential).
#   RX_REFCLK_P_OUT  / _N_OUT     [O clk]  Recovered RX ref clock out (to clock gen).
#   HDMI_TX_DAT_N_OUT/ _P_OUT     [O 3:0]  TX GT serial data (4 FRL/TMDS lanes).
#   HDMI_RX_DAT_N_IN / _P_IN      [I 2:0]  RX GT serial data (3 TMDS lanes, RX only).
#
# ------------------------------------------------------------------------------
# HOT-PLUG / CABLE-DETECT / ENABLE SIDEBAND
# ------------------------------------------------------------------------------
#   RX_DET_N_n                    [I]      RX cable detect (active low) from connector.
#   RX_HPD_OUT                    [O 0:0]  RX Hot-Plug-Detect asserted to the HDMI source.
#   TX_HPD_IN                     [I]      TX Hot-Plug-Detect from the HDMI sink.
#   RX_TI_ENABLE                  [O 0:0]  RX path enable (retimer / ONSEMI enable).
#   TX_TI_ENABLE                  [O 0:0]  TX path enable (retimer / ONSEMI enable).
#   IDT8T49N241_LOL_IN            [I]      Board clock-generator Loss-Of-Lock status in.
#   LED0                          [O]      HDMI TX 'locked' status indicator.
#
# ------------------------------------------------------------------------------
# INTERRUPTS (connect to your interrupt controller)
# ------------------------------------------------------------------------------
#   irq_rx                        [O intr] HDMI RX subsystem.
#   irq_tx                        [O intr] HDMI TX subsystem.
#   irq_vphy                      [O intr] HDMI GT Controller (Video PHY).
#   fb_wr_irq                     [O]      Frame Buffer Write done/error.
#   fb_rd_irq                     [O]      Frame Buffer Read done/error.
#   irq_iic_ctrl                  [O intr] AXI IIC controller.
#   irq_timer0                    [O]      AXI Timer 0.
#   irq_timer1                    [O intr] AXI Timer 1.
################################################################################

################################################################
# This is a generated script based on design: edf_base
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
set scripts_vivado_version 2026.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   common::send_gid_msg -ssname BD::TCL -id 2040 -severity "CRITICAL WARNING" "This script was generated using Vivado <$scripts_vivado_version> without IP versions in the create_bd_cell commands, but is now being run in <$current_vivado_version> of Vivado. There may have been changes to the IP between Vivado <$scripts_vivado_version> and <$current_vivado_version>, which could impact the functionality and configuration of the design."

}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source edf_base_script.tcl

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:video_cke_sync:*\
xilinx.com:ip:axi_iic:*\
xilinx.com:ip:axi_timer:*\
xilinx.com:ip:smartconnect:*\
xilinx.com:inline_hdl:ilconstant:*\
xilinx.com:ip:axi_noc2:*\
xilinx.com:ip:axi_gpio:*\
xilinx.com:inline_hdl:ilslice:*\
xilinx.com:ip:v_frmbuf_rd:*\
xilinx.com:ip:util_ds_buf:*\
xilinx.com:ip:v_frmbuf_wr:*\
xilinx.com:ip:v_proc_ss:*\
xilinx.com:ip:v_hdmi_rxss1:*\
xilinx.com:ip:axis_register_slice:*\
xilinx.com:ip:xlconstant:*\
xilinx.com:ip:v_hdmi_txss1:*\
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


# Hierarchical cell: hdmiphy_ss
proc create_hier_cell_hdmiphy_ss { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_hdmiphy_ss() - Empty argument(s)!"}
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


  # Create pins
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

  # Create instance: hdmi_gt_controller, and set properties
  set hdmi_gt_controller [ create_bd_cell -type ip -vlnv xilinx.com:ip:hdmi_gt_controller hdmi_gt_controller ]
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
    CONFIG.Rx_Max_GT_Line_Rate {12.0} \
    CONFIG.Tx_GT_Line_Rate {12.0} \
    CONFIG.Tx_Max_GT_Line_Rate {12.0} \
    CONFIG.check_refclk_selection {0} \
  ] $hdmi_gt_controller


  # Create instance: urlp, and set properties
  set urlp [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilreduced_logic urlp ]
  set_property CONFIG.C_SIZE {1} $urlp


  # Create instance: xlcp, and set properties
  set xlcp [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat xlcp ]
  set_property CONFIG.NUM_PORTS {1} $xlcp


  # Create instance: bufg_gt_rx, and set properties
  set bufg_gt_rx [ create_bd_cell -type ip -vlnv xilinx.com:ip:bufg_gt bufg_gt_rx ]
  set_property CONFIG.FREQ_HZ {297000000.0} $bufg_gt_rx


  # Create instance: bufg_gt_tx, and set properties
  set bufg_gt_tx [ create_bd_cell -type ip -vlnv xilinx.com:ip:bufg_gt bufg_gt_tx ]
  set_property CONFIG.FREQ_HZ {297000000.0} $bufg_gt_tx


  # Create instance: gtwiz_versal, and set properties
  set gtwiz_versal [ create_bd_cell -type ip -vlnv xilinx.com:ip:gtwiz_versal gtwiz_versal ]
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
    CONFIG.INTF_PARENT_PIN_LIST {QUAD0_TX0 /hdmi_ss/hdmiphy_ss/hdmi_gt_controller/gt_tx0 QUAD0_TX1 /hdmi_ss/hdmiphy_ss/hdmi_gt_controller/gt_tx1 QUAD0_TX2 /hdmi_ss/hdmiphy_ss/hdmi_gt_controller/gt_tx2\
QUAD0_TX3 /hdmi_ss/hdmiphy_ss/hdmi_gt_controller/gt_tx3 QUAD0_RX0 /hdmi_ss/hdmiphy_ss/hdmi_gt_controller/gt_rx0 QUAD0_RX1 /hdmi_ss/hdmiphy_ss/hdmi_gt_controller/gt_rx1 QUAD0_RX2 /hdmi_ss/hdmiphy_ss/hdmi_gt_controller/gt_rx2\
QUAD0_RX3 /hdmi_ss/hdmiphy_ss/hdmi_gt_controller/gt_rx3} \
    CONFIG.NO_OF_INTERFACE {2} \
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
    CONFIG.QUAD0_NO_PROT {2} \
    CONFIG.QUAD0_PROT0_TX1_EN {true} \
    CONFIG.QUAD0_PROT0_TX2_EN {true} \
    CONFIG.QUAD0_PROT0_TX3_EN {true} \
    CONFIG.QUAD0_PROT1_LANES {4} \
    CONFIG.QUAD0_PROT1_RX0_EN {true} \
    CONFIG.QUAD0_PROT1_RX1_EN {true} \
    CONFIG.QUAD0_PROT1_RX2_EN {true} \
    CONFIG.QUAD0_PROT1_RX3_EN {true} \
    CONFIG.QUAD0_PROT1_RXMSTCLK {RX0} \
    CONFIG.QUAD0_REFCLK_STRING {HSCLK0_LCPLLGTREFCLK1 refclk_PROT0_R1_multiple_ext_freq HSCLK0_LCPLLSOUTHREFCLK1 refclk_PROT0_R5_400_MHz_unique1 HSCLK0_RPLLGTREFCLK0 refclk_PROT1_R0_multiple_ext_freq HSCLK0_RPLLSOUTHREFCLK1\
refclk_PROT1_R5_400_MHz_unique1 HSCLK1_LCPLLGTREFCLK1 refclk_PROT0_R1_multiple_ext_freq HSCLK1_LCPLLSOUTHREFCLK1 refclk_PROT0_R5_400_MHz_unique1 HSCLK1_RPLLGTREFCLK0 refclk_PROT1_R0_multiple_ext_freq HSCLK1_RPLLSOUTHREFCLK1\
refclk_PROT1_R5_400_MHz_unique1} \
  ] $gtwiz_versal

  set_property -dict [list \
    CONFIG.INTF0_GT_SETTINGS.VALUE_MODE {auto} \
    CONFIG.INTF0_PARENTID.VALUE_MODE {auto} \
    CONFIG.INTF1_GT_SETTINGS.VALUE_MODE {auto} \
    CONFIG.INTF1_PARENTID.VALUE_MODE {auto} \
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

  # Create port connections
  connect_bd_net -net net_bdry_in_drpclk  [get_bd_pins drpclk] \
  [get_bd_pins hdmi_gt_controller/apb_clk] \
  [get_bd_pins gtwiz_versal/gtwiz_freerun_clk]
  connect_bd_net -net net_bdry_in_dru_ref_clk_in  [get_bd_pins dru_ref_clk_in] \
  [get_bd_pins gtwiz_versal/QUAD0_GTREFCLK1] \
  [get_bd_pins gtwiz_versal/QUAD0_GTREFCLK3]
  connect_bd_net -net net_bdry_in_dru_ref_clk_odiv2_in  [get_bd_pins dru_ref_clk_odiv2_in] \
  [get_bd_pins hdmi_gt_controller/gt_refclk5_odiv2]
  connect_bd_net -net net_bdry_in_rx_ref_clk_in  [get_bd_pins rx_ref_clk_in] \
  [get_bd_pins gtwiz_versal/QUAD0_GTREFCLK2]
  connect_bd_net -net net_bdry_in_rx_ref_clk_odiv2_in  [get_bd_pins rx_ref_clk_odiv2_in] \
  [get_bd_pins hdmi_gt_controller/gt_refclk0_odiv2]
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
  connect_bd_net -net net_bdry_in_vid_phy_rx_axi4s_aresetn  [get_bd_pins vid_phy_rx_axi4s_aresetn] \
  [get_bd_pins hdmi_gt_controller/rx_axi4s_aresetn]
  connect_bd_net -net net_bdry_in_vid_phy_sb_aclk  [get_bd_pins vid_phy_sb_aclk] \
  [get_bd_pins hdmi_gt_controller/sb_aclk]
  connect_bd_net -net net_bdry_in_vid_phy_sb_aresetn  [get_bd_pins vid_phy_sb_aresetn] \
  [get_bd_pins hdmi_gt_controller/sb_aresetn]
  connect_bd_net -net net_bdry_in_vid_phy_tx_axi4s_aresetn  [get_bd_pins vid_phy_tx_axi4s_aresetn] \
  [get_bd_pins hdmi_gt_controller/tx_axi4s_aresetn]
  connect_bd_net -net net_bufg_gt_rx_usrclk  [get_bd_pins bufg_gt_rx/usrclk] \
  [get_bd_pins rxoutclk] \
  [get_bd_pins gtwiz_versal/QUAD0_RX0_usrclk] \
  [get_bd_pins gtwiz_versal/QUAD0_RX1_usrclk] \
  [get_bd_pins gtwiz_versal/QUAD0_RX2_usrclk] \
  [get_bd_pins gtwiz_versal/QUAD0_RX3_usrclk] \
  [get_bd_pins hdmi_gt_controller/rx_axi4s_aclk] \
  [get_bd_pins hdmi_gt_controller/gt_rxusrclk]
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
  connect_bd_net -net net_gtwiz_versal_INTF1_rst_rx_done_out  [get_bd_pins gtwiz_versal/INTF1_rst_rx_done_out] \
  [get_bd_pins hdmi_gt_controller/rx_full_rst_done]
  connect_bd_net -net net_gtwiz_versal_QUAD0_RX0_outclk  [get_bd_pins gtwiz_versal/QUAD0_RX0_outclk] \
  [get_bd_pins bufg_gt_rx/outclk]
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
  connect_bd_net -net net_gtwiz_versal_QUAD0_hsclk0_rplllock  [get_bd_pins gtwiz_versal/QUAD0_hsclk0_rplllock] \
  [get_bd_pins hdmi_gt_controller/gt_rpll0_lock]
  connect_bd_net -net net_gtwiz_versal_QUAD0_hsclk1_lcplllock  [get_bd_pins gtwiz_versal/QUAD0_hsclk1_lcplllock] \
  [get_bd_pins hdmi_gt_controller/gt_lcpll1_lock]
  connect_bd_net -net net_gtwiz_versal_QUAD0_hsclk1_rplllock  [get_bd_pins gtwiz_versal/QUAD0_hsclk1_rplllock] \
  [get_bd_pins hdmi_gt_controller/gt_rpll1_lock]
  connect_bd_net -net net_gtwiz_versal_gtpowergood  [get_bd_pins gtwiz_versal/gtpowergood] \
  [get_bd_pins xlcp/In0]
  connect_bd_net -net net_hdmi_gt_controller_gt_lcpll0_reset  [get_bd_pins hdmi_gt_controller/gt_lcpll0_reset] \
  [get_bd_pins gtwiz_versal/QUAD0_hsclk0_lcpllreset]
  connect_bd_net -net net_hdmi_gt_controller_gt_lcpll1_reset  [get_bd_pins hdmi_gt_controller/gt_lcpll1_reset] \
  [get_bd_pins gtwiz_versal/QUAD0_hsclk1_lcpllreset]
  connect_bd_net -net net_hdmi_gt_controller_gt_rpll0_reset  [get_bd_pins hdmi_gt_controller/gt_rpll0_reset] \
  [get_bd_pins gtwiz_versal/QUAD0_hsclk0_rpllreset]
  connect_bd_net -net net_hdmi_gt_controller_gt_rpll1_reset  [get_bd_pins hdmi_gt_controller/gt_rpll1_reset] \
  [get_bd_pins gtwiz_versal/QUAD0_hsclk1_rpllreset]
  connect_bd_net -net net_hdmi_gt_controller_irq  [get_bd_pins hdmi_gt_controller/irq] \
  [get_bd_pins irq]
  connect_bd_net -net net_hdmi_gt_controller_reset_rx_datapath  [get_bd_pins hdmi_gt_controller/reset_rx_datapath] \
  [get_bd_pins gtwiz_versal/INTF1_rst_rx_datapath_in]
  connect_bd_net -net net_hdmi_gt_controller_reset_rx_pll_and_datapath  [get_bd_pins hdmi_gt_controller/reset_rx_pll_and_datapath] \
  [get_bd_pins gtwiz_versal/INTF1_rst_rx_pll_and_datapath_in]
  connect_bd_net -net net_hdmi_gt_controller_reset_tx_datapath  [get_bd_pins hdmi_gt_controller/reset_tx_datapath] \
  [get_bd_pins gtwiz_versal/INTF0_rst_tx_datapath_in]
  connect_bd_net -net net_hdmi_gt_controller_reset_tx_pll_and_datapath  [get_bd_pins hdmi_gt_controller/reset_tx_pll_and_datapath] \
  [get_bd_pins gtwiz_versal/INTF0_rst_tx_pll_and_datapath_in]
  connect_bd_net -net net_hdmi_gt_controller_rx_full_rst  [get_bd_pins hdmi_gt_controller/rx_full_rst] \
  [get_bd_pins gtwiz_versal/INTF1_rst_all_in]
  connect_bd_net -net net_hdmi_gt_controller_rx_tmds_clk  [get_bd_pins hdmi_gt_controller/rx_tmds_clk] \
  [get_bd_pins rx_tmds_clk]
  connect_bd_net -net net_hdmi_gt_controller_rx_tmds_clk_n  [get_bd_pins hdmi_gt_controller/rx_tmds_clk_n] \
  [get_bd_pins rx_tmds_clk_n]
  connect_bd_net -net net_hdmi_gt_controller_rx_tmds_clk_p  [get_bd_pins hdmi_gt_controller/rx_tmds_clk_p] \
  [get_bd_pins rx_tmds_clk_p]
  connect_bd_net -net net_hdmi_gt_controller_rx_video_clk  [get_bd_pins hdmi_gt_controller/rx_video_clk] \
  [get_bd_pins rx_video_clk]
  connect_bd_net -net net_hdmi_gt_controller_tx_full_rst  [get_bd_pins hdmi_gt_controller/tx_full_rst] \
  [get_bd_pins gtwiz_versal/INTF0_rst_all_in]
  connect_bd_net -net net_hdmi_gt_controller_tx_tmds_clk  [get_bd_pins hdmi_gt_controller/tx_tmds_clk] \
  [get_bd_pins tx_tmds_clk]
  connect_bd_net -net net_hdmi_gt_controller_tx_video_clk  [get_bd_pins hdmi_gt_controller/tx_video_clk] \
  [get_bd_pins tx_video_clk]
  connect_bd_net -net net_urlp_Res  [get_bd_pins urlp/Res] \
  [get_bd_pins hdmi_gt_controller/gtpowergood]
  connect_bd_net -net net_xlcp_dout  [get_bd_pins xlcp/dout] \
  [get_bd_pins urlp/Op1]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: hdmi_tx_ss
proc create_hier_cell_hdmi_tx_ss { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_hdmi_tx_ss() - Empty argument(s)!"}
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

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 AUDIO_IN

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 SB_STATUS_IN

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 LINK_DATA0_OUT

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 LINK_DATA1_OUT

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 LINK_DATA2_OUT

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 LINK_DATA3_OUT

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 DDC_OUT

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS


  # Create pins
  create_bd_pin -dir I -type clk s_axi_cpu_aclk
  create_bd_pin -dir I -type rst s_axi_cpu_aresetn
  create_bd_pin -dir I -type gt_usrclk link_clk
  create_bd_pin -dir I -type clk video_clk
  create_bd_pin -dir I -from 19 -to 0 acr_cts
  create_bd_pin -dir I -from 19 -to 0 acr_n
  create_bd_pin -dir I acr_valid
  create_bd_pin -dir I TX_HPD_IN
  create_bd_pin -dir O -type intr irq_tx
  create_bd_pin -dir I -type clk frl_clk
  create_bd_pin -dir O LED0
  create_bd_pin -dir I video_cke_in
  create_bd_pin -dir I -type clk s_axis_video_aclk
  create_bd_pin -dir I -type rst s_axis_video_aresetn

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
    CONFIG.C_MAX_BITS_PER_COMPONENT {12} \
    CONFIG.C_VALIDATION_ENABLE {false} \
    CONFIG.C_VID_INTERFACE {0} \
    CONFIG.C_VRR_SUPPORT {1} \
  ] $v_hdmi_txss1


  # Create instance: tx_video_axis_reg_slice, and set properties
  set tx_video_axis_reg_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_register_slice tx_video_axis_reg_slice ]

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant xlconstant_0 ]
  set_property CONFIG.CONST_VAL {0} $xlconstant_0


  # Create interface connections
  connect_bd_intf_net -intf_net audio_ss_0_axis_audio_out [get_bd_intf_pins AUDIO_IN] [get_bd_intf_pins v_hdmi_txss1/AUDIO_IN]
  connect_bd_intf_net -intf_net hdmiphy_ss_0_vid_phy_status_sb_tx [get_bd_intf_pins SB_STATUS_IN] [get_bd_intf_pins v_hdmi_txss1/SB_STATUS_IN]
  connect_bd_intf_net -intf_net ps_ss_AXI_CPU_IN_HDMI_TX [get_bd_intf_pins S_AXI_CPU_IN] [get_bd_intf_pins v_hdmi_txss1/S_AXI_CPU_IN]
  connect_bd_intf_net -intf_net tx_video_axis_reg_slice_M_AXIS [get_bd_intf_pins v_hdmi_txss1/VIDEO_IN] [get_bd_intf_pins tx_video_axis_reg_slice/M_AXIS]
  connect_bd_intf_net -intf_net v_hdmi_txss1_DDC_OUT [get_bd_intf_pins DDC_OUT] [get_bd_intf_pins v_hdmi_txss1/DDC_OUT]
  connect_bd_intf_net -intf_net v_hdmi_txss1_LINK_DATA0_OUT [get_bd_intf_pins LINK_DATA0_OUT] [get_bd_intf_pins v_hdmi_txss1/LINK_DATA0_OUT]
  connect_bd_intf_net -intf_net v_hdmi_txss1_LINK_DATA1_OUT [get_bd_intf_pins LINK_DATA1_OUT] [get_bd_intf_pins v_hdmi_txss1/LINK_DATA1_OUT]
  connect_bd_intf_net -intf_net v_hdmi_txss1_LINK_DATA2_OUT [get_bd_intf_pins LINK_DATA2_OUT] [get_bd_intf_pins v_hdmi_txss1/LINK_DATA2_OUT]
  connect_bd_intf_net -intf_net v_hdmi_txss1_LINK_DATA3_OUT [get_bd_intf_pins LINK_DATA3_OUT] [get_bd_intf_pins v_hdmi_txss1/LINK_DATA3_OUT]
  connect_bd_intf_net -intf_net vmixer_m_axis_vmix_video_out [get_bd_intf_pins S_AXIS] [get_bd_intf_pins tx_video_axis_reg_slice/S_AXIS]

  # Create port connections
  connect_bd_net -net TX_HPD_IN_1  [get_bd_pins TX_HPD_IN] \
  [get_bd_pins v_hdmi_txss1/hpd]
  connect_bd_net -net audio_ss_0_aud_acr_cts_out  [get_bd_pins acr_cts] \
  [get_bd_pins v_hdmi_txss1/acr_cts]
  connect_bd_net -net audio_ss_0_aud_acr_n_out  [get_bd_pins acr_n] \
  [get_bd_pins v_hdmi_txss1/acr_n]
  connect_bd_net -net audio_ss_0_aud_acr_valid_out  [get_bd_pins acr_valid] \
  [get_bd_pins v_hdmi_txss1/acr_valid]
  connect_bd_net -net hdmiphy_ss_0_tx_video_clk  [get_bd_pins video_clk] \
  [get_bd_pins v_hdmi_txss1/video_clk]
  connect_bd_net -net ps_ss_clk150_aresetn  [get_bd_pins s_axi_cpu_aresetn] \
  [get_bd_pins v_hdmi_txss1/s_axi_cpu_aresetn]
  connect_bd_net -net ps_ss_clk300_aresetn  [get_bd_pins s_axis_video_aresetn] \
  [get_bd_pins tx_video_axis_reg_slice/aresetn] \
  [get_bd_pins v_hdmi_txss1/s_axis_video_aresetn]
  connect_bd_net -net ps_ss_clkx5_450  [get_bd_pins frl_clk] \
  [get_bd_pins v_hdmi_txss1/frl_clk]
  connect_bd_net -net ps_ss_pl_clk_150  [get_bd_pins s_axi_cpu_aclk] \
  [get_bd_pins v_hdmi_txss1/s_axi_cpu_aclk]
  connect_bd_net -net ps_ss_pl_clk_300  [get_bd_pins s_axis_video_aclk] \
  [get_bd_pins tx_video_axis_reg_slice/aclk] \
  [get_bd_pins v_hdmi_txss1/s_axis_video_aclk]
  connect_bd_net -net tx_link_clk_1  [get_bd_pins link_clk] \
  [get_bd_pins v_hdmi_txss1/link_clk]
  connect_bd_net -net v_fifo_dc_b_de_out  [get_bd_pins video_cke_in] \
  [get_bd_pins v_hdmi_txss1/video_cke_in]
  connect_bd_net -net v_hdmi_txss1_irq  [get_bd_pins v_hdmi_txss1/irq] \
  [get_bd_pins irq_tx]
  connect_bd_net -net v_hdmi_txss1_locked  [get_bd_pins v_hdmi_txss1/locked] \
  [get_bd_pins LED0]
  connect_bd_net -net xlconstant_0_dout  [get_bd_pins xlconstant_0/dout] \
  [get_bd_pins v_hdmi_txss1/s_axis_audio_aclk]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: hdmi_rx_ss
proc create_hier_cell_hdmi_rx_ss { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_hdmi_rx_ss() - Empty argument(s)!"}
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

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 AUDIO_OUT

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 SB_STATUS_IN

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 LINK_DATA0_IN

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 LINK_DATA1_IN

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 LINK_DATA2_IN

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 LINK_DATA3_IN

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 DDC_OUT

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS


  # Create pins
  create_bd_pin -dir I -type clk s_axi_cpu_aclk
  create_bd_pin -dir I -type rst s_axi_cpu_aresetn
  create_bd_pin -dir I RX_DET_N_n
  create_bd_pin -dir I -type gt_usrclk link_clk
  create_bd_pin -dir O -from 19 -to 0 acr_cts
  create_bd_pin -dir O -from 19 -to 0 acr_n
  create_bd_pin -dir O acr_valid
  create_bd_pin -dir O -from 0 -to 0 RX_HPD_OUT
  create_bd_pin -dir O -type intr irq_rx
  create_bd_pin -dir I -type clk video_clk
  create_bd_pin -dir I -type clk frl_clk
  create_bd_pin -dir O video_cke_out
  create_bd_pin -dir I -type rst s_axis_video_aresetn
  create_bd_pin -dir I -type clk s_axis_video_aclk

  # Create instance: v_hdmi_rxss1, and set properties
  set v_hdmi_rxss1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_hdmi_rxss1 v_hdmi_rxss1 ]
  set_property -dict [list \
    CONFIG.C_ADDR_WIDTH {10} \
    CONFIG.C_ADD_CORE_DBG {0} \
    CONFIG.C_ADD_MARK_DBG {false} \
    CONFIG.C_CD_INVERT {true} \
    CONFIG.C_DYNAMIC_HDR {0} \
    CONFIG.C_EDID_RAM_SIZE {256} \
    CONFIG.C_EXDES_RX_PLL_SELECTION {8} \
    CONFIG.C_EXDES_TX_PLL_SELECTION {7} \
    CONFIG.C_FRL_SM_VCKE {1} \
    CONFIG.C_HDMI_VERSION {4} \
    CONFIG.C_HPD_INVERT {true} \
    CONFIG.C_INCLUDE_HDCP {false} \
    CONFIG.C_INCLUDE_HDCP_1_4 {false} \
    CONFIG.C_INCLUDE_HDCP_2_2 {false} \
    CONFIG.C_INPUT_PIXELS_PER_CLOCK {4} \
    CONFIG.C_MAX_BITS_PER_COMPONENT {12} \
    CONFIG.C_VALIDATION_ENABLE {false} \
    CONFIG.C_VID_INTERFACE {0} \
    CONFIG.C_VRR_SUPPORT {1} \
  ] $v_hdmi_rxss1


  # Create instance: rx_video_axis_reg_slice, and set properties
  set rx_video_axis_reg_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_register_slice rx_video_axis_reg_slice ]

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant xlconstant_0 ]
  set_property CONFIG.CONST_VAL {0} $xlconstant_0


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins rx_video_axis_reg_slice/M_AXIS] [get_bd_intf_pins M_AXIS]
  connect_bd_intf_net -intf_net hdmiphy_ss_0_vid_phy_rx_axi4s_ch0 [get_bd_intf_pins LINK_DATA0_IN] [get_bd_intf_pins v_hdmi_rxss1/LINK_DATA0_IN]
  connect_bd_intf_net -intf_net hdmiphy_ss_0_vid_phy_rx_axi4s_ch1 [get_bd_intf_pins LINK_DATA1_IN] [get_bd_intf_pins v_hdmi_rxss1/LINK_DATA1_IN]
  connect_bd_intf_net -intf_net hdmiphy_ss_0_vid_phy_rx_axi4s_ch2 [get_bd_intf_pins LINK_DATA2_IN] [get_bd_intf_pins v_hdmi_rxss1/LINK_DATA2_IN]
  connect_bd_intf_net -intf_net hdmiphy_ss_0_vid_phy_rx_axi4s_ch3 [get_bd_intf_pins LINK_DATA3_IN] [get_bd_intf_pins v_hdmi_rxss1/LINK_DATA3_IN]
  connect_bd_intf_net -intf_net hdmiphy_ss_0_vid_phy_status_sb_rx [get_bd_intf_pins SB_STATUS_IN] [get_bd_intf_pins v_hdmi_rxss1/SB_STATUS_IN]
  connect_bd_intf_net -intf_net ps_ss_AXI_CPU_IN_HDMI_RX [get_bd_intf_pins S_AXI_CPU_IN] [get_bd_intf_pins v_hdmi_rxss1/S_AXI_CPU_IN]
  connect_bd_intf_net -intf_net v_hdmi_rxss1_AUDIO_OUT [get_bd_intf_pins AUDIO_OUT] [get_bd_intf_pins v_hdmi_rxss1/AUDIO_OUT]
  connect_bd_intf_net -intf_net v_hdmi_rxss1_DDC_OUT [get_bd_intf_pins DDC_OUT] [get_bd_intf_pins v_hdmi_rxss1/DDC_OUT]
  connect_bd_intf_net -intf_net v_hdmi_rxss1_VIDEO_OUT [get_bd_intf_pins v_hdmi_rxss1/VIDEO_OUT] [get_bd_intf_pins rx_video_axis_reg_slice/S_AXIS]

  # Create port connections
  connect_bd_net -net RX_DET_N_IN_1  [get_bd_pins RX_DET_N_n] \
  [get_bd_pins v_hdmi_rxss1/cable_detect]
  connect_bd_net -net hdmi_ss_rxoutclk  [get_bd_pins link_clk] \
  [get_bd_pins v_hdmi_rxss1/link_clk]
  connect_bd_net -net hdmiphy_ss_0_rx_video_clk  [get_bd_pins video_clk] \
  [get_bd_pins v_hdmi_rxss1/video_clk]
  connect_bd_net -net ps_ss_clk150_aresetn  [get_bd_pins s_axi_cpu_aresetn] \
  [get_bd_pins v_hdmi_rxss1/s_axi_cpu_aresetn]
  connect_bd_net -net ps_ss_clk300_aresetn  [get_bd_pins s_axis_video_aresetn] \
  [get_bd_pins v_hdmi_rxss1/s_axis_video_aresetn] \
  [get_bd_pins rx_video_axis_reg_slice/aresetn]
  connect_bd_net -net ps_ss_clkx5_450  [get_bd_pins frl_clk] \
  [get_bd_pins v_hdmi_rxss1/frl_clk]
  connect_bd_net -net ps_ss_pl_clk_150  [get_bd_pins s_axi_cpu_aclk] \
  [get_bd_pins v_hdmi_rxss1/s_axi_cpu_aclk]
  connect_bd_net -net ps_ss_pl_clk_300  [get_bd_pins s_axis_video_aclk] \
  [get_bd_pins v_hdmi_rxss1/s_axis_video_aclk] \
  [get_bd_pins rx_video_axis_reg_slice/aclk]
  connect_bd_net -net v_hdmi_rxss1_acr_cts  [get_bd_pins v_hdmi_rxss1/acr_cts] \
  [get_bd_pins acr_cts]
  connect_bd_net -net v_hdmi_rxss1_acr_n  [get_bd_pins v_hdmi_rxss1/acr_n] \
  [get_bd_pins acr_n]
  connect_bd_net -net v_hdmi_rxss1_acr_valid  [get_bd_pins v_hdmi_rxss1/acr_valid] \
  [get_bd_pins acr_valid]
  connect_bd_net -net v_hdmi_rxss1_hpd  [get_bd_pins v_hdmi_rxss1/hpd] \
  [get_bd_pins RX_HPD_OUT]
  connect_bd_net -net v_hdmi_rxss1_irq  [get_bd_pins v_hdmi_rxss1/irq] \
  [get_bd_pins irq_rx]
  connect_bd_net -net v_hdmi_rxss1_video_cke_out  [get_bd_pins v_hdmi_rxss1/video_cke_out] \
  [get_bd_pins video_cke_out]
  connect_bd_net -net xlconstant_0_dout  [get_bd_pins xlconstant_0/dout] \
  [get_bd_pins v_hdmi_rxss1/s_axis_audio_aclk]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: vfmc_ctlr_ss
proc create_hier_cell_vfmc_ctlr_ss { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_vfmc_ctlr_ss() - Empty argument(s)!"}
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

# Hierarchical cell: frmbuf_ss_wr
proc create_hier_cell_frmbuf_ss_wr { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_frmbuf_ss_wr() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_video

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_CTRL

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_mm_video


  # Create pins
  create_bd_pin -dir O -type intr irq_frmbuf_wr
  create_bd_pin -dir I -type clk s_axis_video_aclk
  create_bd_pin -dir I -type rst s_axis_video_aresetn

  # Create instance: frmbuf_rst_gpio, and set properties
  set frmbuf_rst_gpio [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio frmbuf_rst_gpio ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_DOUT_DEFAULT {0x00000000} \
    CONFIG.C_GPIO_WIDTH {2} \
  ] $frmbuf_rst_gpio


  # Create instance: smartconnect, and set properties
  set smartconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect ]
  set_property -dict [list \
    CONFIG.NUM_MI {3} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect


  # Create instance: v_frmbuf_wr, and set properties
  set v_frmbuf_wr [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_frmbuf_wr v_frmbuf_wr ]
  set_property -dict [list \
    CONFIG.AXIMM_ADDR_WIDTH {64} \
    CONFIG.HAS_Y10 {1} \
    CONFIG.HAS_Y12 {1} \
    CONFIG.HAS_Y8 {1} \
    CONFIG.HAS_Y_UV10 {1} \
    CONFIG.HAS_Y_UV10_420 {1} \
    CONFIG.HAS_Y_UV12 {1} \
    CONFIG.HAS_Y_UV12_420 {1} \
    CONFIG.HAS_Y_UV8 {1} \
    CONFIG.HAS_Y_UV8_420 {1} \
    CONFIG.HAS_Y_U_V10 {1} \
    CONFIG.HAS_Y_U_V12 {1} \
    CONFIG.HAS_Y_U_V8 {1} \
    CONFIG.IS_TILE_FORMAT {1} \
    CONFIG.MAX_COLS {8192} \
    CONFIG.MAX_DATA_WIDTH {12} \
    CONFIG.MAX_ROWS {4320} \
    CONFIG.SAMPLES_PER_CLOCK {4} \
  ] $v_frmbuf_wr


  # Create instance: v_proc_ss_0, and set properties
  set v_proc_ss_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_proc_ss v_proc_ss_0 ]
  set_property -dict [list \
    CONFIG.C_ENABLE_CSC {true} \
    CONFIG.C_MAX_COLS {8192} \
    CONFIG.C_MAX_DATA_WIDTH {12} \
    CONFIG.C_MAX_ROWS {4320} \
    CONFIG.C_SAMPLES_PER_CLK {4} \
    CONFIG.C_TOPOLOGY {0} \
  ] $v_proc_ss_0


  # Create instance: xlslice_0, and set properties
  set xlslice_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice xlslice_0 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {0} \
    CONFIG.DIN_TO {0} \
    CONFIG.DIN_WIDTH {2} \
  ] $xlslice_0


  # Create instance: xlslice_1, and set properties
  set xlslice_1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice xlslice_1 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {1} \
    CONFIG.DIN_TO {1} \
    CONFIG.DIN_WIDTH {2} \
  ] $xlslice_1


  # Create interface connections
  connect_bd_intf_net -intf_net s_axi_CTRL_1 [get_bd_intf_pins s_axi_CTRL] [get_bd_intf_pins smartconnect/S00_AXI]
  connect_bd_intf_net -intf_net s_axis_video_1 [get_bd_intf_pins s_axis_video] [get_bd_intf_pins v_proc_ss_0/s_axis]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect/M00_AXI] [get_bd_intf_pins v_proc_ss_0/s_axi_ctrl]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins smartconnect/M01_AXI] [get_bd_intf_pins v_frmbuf_wr/s_axi_CTRL]
  connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins smartconnect/M02_AXI] [get_bd_intf_pins frmbuf_rst_gpio/S_AXI]
  connect_bd_intf_net -intf_net v_frmbuf_wr_0_m_axi_mm_video [get_bd_intf_pins m_axi_mm_video] [get_bd_intf_pins v_frmbuf_wr/m_axi_mm_video]
  connect_bd_intf_net -intf_net v_proc_ss_0_m_axis [get_bd_intf_pins v_proc_ss_0/m_axis] [get_bd_intf_pins v_frmbuf_wr/s_axis_video]

  # Create port connections
  connect_bd_net -net ap_clk_0_1  [get_bd_pins s_axis_video_aclk] \
  [get_bd_pins frmbuf_rst_gpio/s_axi_aclk] \
  [get_bd_pins smartconnect/aclk] \
  [get_bd_pins v_proc_ss_0/aclk_axis] \
  [get_bd_pins v_proc_ss_0/aclk_ctrl] \
  [get_bd_pins v_frmbuf_wr/ap_clk]
  connect_bd_net -net frmbuf_rst_gpio_gpio_io_o  [get_bd_pins frmbuf_rst_gpio/gpio_io_o] \
  [get_bd_pins xlslice_0/Din] \
  [get_bd_pins xlslice_1/Din]
  connect_bd_net -net s_axi_aresetn_0_1  [get_bd_pins s_axis_video_aresetn] \
  [get_bd_pins frmbuf_rst_gpio/s_axi_aresetn] \
  [get_bd_pins smartconnect/aresetn]
  connect_bd_net -net v_frmbuf_wr_0_int  [get_bd_pins v_frmbuf_wr/interrupt] \
  [get_bd_pins irq_frmbuf_wr]
  connect_bd_net -net xlslice_0_Dout  [get_bd_pins xlslice_0/Dout] \
  [get_bd_pins v_proc_ss_0/aresetn_ctrl]
  connect_bd_net -net xlslice_1_Dout  [get_bd_pins xlslice_1/Dout] \
  [get_bd_pins v_frmbuf_wr/ap_rst_n]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: gt_refclk_buf_ss_2
proc create_hier_cell_gt_refclk_buf_ss_2 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_gt_refclk_buf_ss_2() - Empty argument(s)!"}
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

# Hierarchical cell: frmbuff_ss_rd
proc create_hier_cell_frmbuff_ss_rd { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_frmbuff_ss_rd() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_video_out

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_ctrl_vmix

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_mm_video1


  # Create pins
  create_bd_pin -dir O -type intr fb_rd_irq
  create_bd_pin -dir I -type clk s_axis_video_aclk
  create_bd_pin -dir I -type rst s_axis_video_aresetn

  # Create instance: smartconnect, and set properties
  set smartconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect ]
  set_property -dict [list \
    CONFIG.NUM_MI {2} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect


  # Create instance: fb_rd_rst_gpio, and set properties
  set fb_rd_rst_gpio [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio fb_rd_rst_gpio ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_DOUT_DEFAULT {0x00000003} \
    CONFIG.C_GPIO_WIDTH {2} \
  ] $fb_rd_rst_gpio


  # Create instance: xlslice, and set properties
  set xlslice [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice xlslice ]
  set_property -dict [list \
    CONFIG.DIN_FROM {0} \
    CONFIG.DIN_TO {0} \
    CONFIG.DIN_WIDTH {2} \
  ] $xlslice


  # Create instance: v_frmbuf_rd, and set properties
  set v_frmbuf_rd [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_frmbuf_rd v_frmbuf_rd ]
  set_property -dict [list \
    CONFIG.AXIMM_ADDR_WIDTH {64} \
    CONFIG.HAS_Y10 {1} \
    CONFIG.HAS_Y12 {1} \
    CONFIG.HAS_Y8 {1} \
    CONFIG.HAS_Y_UV10 {1} \
    CONFIG.HAS_Y_UV10_420 {1} \
    CONFIG.HAS_Y_UV12 {1} \
    CONFIG.HAS_Y_UV12_420 {1} \
    CONFIG.HAS_Y_UV8 {1} \
    CONFIG.HAS_Y_UV8_420 {1} \
    CONFIG.HAS_Y_U_V10 {1} \
    CONFIG.HAS_Y_U_V12 {1} \
    CONFIG.HAS_Y_U_V8 {1} \
    CONFIG.IS_TILE_FORMAT {1} \
    CONFIG.MAX_COLS {8192} \
    CONFIG.MAX_DATA_WIDTH {12} \
    CONFIG.MAX_ROWS {4320} \
    CONFIG.SAMPLES_PER_CLOCK {4} \
  ] $v_frmbuf_rd


  # Create interface connections
  connect_bd_intf_net -intf_net s_axi_ctrl_vmix_1 [get_bd_intf_pins s_axi_ctrl_vmix] [get_bd_intf_pins smartconnect/S00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect/M00_AXI] [get_bd_intf_pins v_frmbuf_rd/s_axi_CTRL]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins smartconnect/M01_AXI] [get_bd_intf_pins fb_rd_rst_gpio/S_AXI]
  connect_bd_intf_net -intf_net v_frmbuf_rd_0_m_axi_mm_video [get_bd_intf_pins m_axi_mm_video1] [get_bd_intf_pins v_frmbuf_rd/m_axi_mm_video]
  connect_bd_intf_net -intf_net v_frmbuf_rd_0_m_axis_video [get_bd_intf_pins m_axis_video_out] [get_bd_intf_pins v_frmbuf_rd/m_axis_video]

  # Create port connections
  connect_bd_net -net axi_gpio_gpio_io_o  [get_bd_pins fb_rd_rst_gpio/gpio_io_o] \
  [get_bd_pins xlslice/Din]
  connect_bd_net -net net_cips_ss_0_clk_out2  [get_bd_pins s_axis_video_aclk] \
  [get_bd_pins fb_rd_rst_gpio/s_axi_aclk] \
  [get_bd_pins smartconnect/aclk] \
  [get_bd_pins v_frmbuf_rd/ap_clk]
  connect_bd_net -net net_cips_ss_0_dcm_locked  [get_bd_pins s_axis_video_aresetn] \
  [get_bd_pins fb_rd_rst_gpio/s_axi_aresetn] \
  [get_bd_pins smartconnect/aresetn]
  connect_bd_net -net v_frmbuf_rd_0_interrupt  [get_bd_pins v_frmbuf_rd/interrupt] \
  [get_bd_pins fb_rd_irq]
  connect_bd_net -net xlslice_1_Dout  [get_bd_pins xlslice/Dout] \
  [get_bd_pins v_frmbuf_rd/ap_rst_n]

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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 TX_DDC_OUT

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 RX_DDC_OUT

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 GT_DRU_FRL_CLK_IN

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 TX_REFCLK_P_IN_V

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 HDMI_RX_CLK_P_IN_V

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 GT_Serial

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 HDMI_CTRL

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M00_INI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M01_INI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M02_INI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M03_INI


  # Create pins
  create_bd_pin -dir I -type clk s_axis_video_aclk
  create_bd_pin -dir I -type rst s_axis_video_aresetn
  create_bd_pin -dir I -type clk s_axi_cpu_aclk
  create_bd_pin -dir I -type rst s_axi_cpu_aresetn
  create_bd_pin -dir I TX_HPD_IN
  create_bd_pin -dir O -type intr irq_tx
  create_bd_pin -dir I -type clk frl_clk
  create_bd_pin -dir O LED0
  create_bd_pin -dir I RX_DET_N_n
  create_bd_pin -dir O -from 0 -to 0 RX_HPD_OUT
  create_bd_pin -dir O -type intr irq_rx
  create_bd_pin -dir O -type intr fb_rd_irq
  create_bd_pin -dir O -type intr fb_wr_irq
  create_bd_pin -dir I IDT8T49N241_LOL_IN
  create_bd_pin -dir O -type clk RX_REFCLK_P_OUT
  create_bd_pin -dir O -type clk RX_REFCLK_N_OUT
  create_bd_pin -dir O irq_vphy
  create_bd_pin -dir O -from 0 -to 0 TX_TI_ENABLE
  create_bd_pin -dir O -type intr irq_iic_ctrl
  create_bd_pin -dir O -type intr irq_timer0
  create_bd_pin -dir O -type intr irq_timer1

  # Create instance: v_fifo_dc, and set properties
  set v_fifo_dc [ create_bd_cell -type ip -vlnv xilinx.com:ip:video_cke_sync v_fifo_dc ]

  # Create instance: axi_iic_0, and set properties
  set axi_iic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic axi_iic_0 ]
  set_property CONFIG.IIC_FREQ_KHZ {100} $axi_iic_0


  # Create instance: axi_timer_1, and set properties
  set axi_timer_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer axi_timer_1 ]

  # Create instance: axi_timer_0, and set properties
  set axi_timer_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer axi_timer_0 ]

  # Create instance: smartconnect, and set properties
  set smartconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {2} \
    CONFIG.NUM_MI {9} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect


  # Create instance: vcc_const, and set properties
  set vcc_const [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant vcc_const ]
  set_property CONFIG.CONST_VAL {1} $vcc_const


  # Create instance: axi_noc2, and set properties
  set axi_noc2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc2 axi_noc2 ]
  set_property -dict [list \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NMI {4} \
    CONFIG.NUM_SI {2} \
    CONFIG.SI_SIDEBAND_PINS {0} \
  ] $axi_noc2


  set_property -dict [ list \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.CONNECTIONS {M02_INI {read_bw {500} write_bw {500} } M00_INI {read_bw {500} write_bw {500} }} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
 ] [get_bd_intf_pins $axi_noc2/S00_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.CONNECTIONS {M01_INI {read_bw {500} write_bw {500} } M03_INI {read_bw {500} write_bw {500} }} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
 ] [get_bd_intf_pins $axi_noc2/S01_AXI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXI:S01_AXI} \
 ] [get_bd_pins $axi_noc2/aclk0]

  # Create instance: frmbuff_ss_rd
  create_hier_cell_frmbuff_ss_rd $hier_obj frmbuff_ss_rd

  # Create instance: gt_refclk_buf_ss_0
  create_hier_cell_gt_refclk_buf_ss_0 $hier_obj gt_refclk_buf_ss_0

  # Create instance: gt_refclk_buf_ss_1
  create_hier_cell_gt_refclk_buf_ss_1 $hier_obj gt_refclk_buf_ss_1

  # Create instance: gt_refclk_buf_ss_2
  create_hier_cell_gt_refclk_buf_ss_2 $hier_obj gt_refclk_buf_ss_2

  # Create instance: frmbuf_ss_wr
  create_hier_cell_frmbuf_ss_wr $hier_obj frmbuf_ss_wr

  # Create instance: vfmc_ctlr_ss
  create_hier_cell_vfmc_ctlr_ss $hier_obj vfmc_ctlr_ss

  # Create instance: hdmi_rx_ss
  create_hier_cell_hdmi_rx_ss $hier_obj hdmi_rx_ss

  # Create instance: hdmi_tx_ss
  create_hier_cell_hdmi_tx_ss $hier_obj hdmi_tx_ss

  # Create instance: hdmiphy_ss
  create_hier_cell_hdmiphy_ss $hier_obj hdmiphy_ss

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins axi_iic_0/IIC] [get_bd_intf_pins HDMI_CTRL]
  connect_bd_intf_net -intf_net GT_DRU_FRL_CLK_IN_1 [get_bd_intf_pins GT_DRU_FRL_CLK_IN] [get_bd_intf_pins gt_refclk_buf_ss_0/IBUFDSGT_IN]
  connect_bd_intf_net -intf_net HDMI_RX_CLK_P_IN_V_1 [get_bd_intf_pins HDMI_RX_CLK_P_IN_V] [get_bd_intf_pins gt_refclk_buf_ss_2/IBUFDSGT_IN]
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins S00_AXI] [get_bd_intf_pins smartconnect/S00_AXI]
  connect_bd_intf_net -intf_net SB_STATUS_IN_1 [get_bd_intf_pins hdmi_tx_ss/SB_STATUS_IN] [get_bd_intf_pins hdmiphy_ss/vid_phy_status_sb_tx]
  connect_bd_intf_net -intf_net S_AXI_1 [get_bd_intf_pins vfmc_ctlr_ss/S_AXI] [get_bd_intf_pins smartconnect/M06_AXI]
  connect_bd_intf_net -intf_net TX_REFCLK_P_IN_V_1 [get_bd_intf_pins TX_REFCLK_P_IN_V] [get_bd_intf_pins gt_refclk_buf_ss_1/IBUFDSGT_IN]
  connect_bd_intf_net -intf_net axi_noc2_M00_INI [get_bd_intf_pins M00_INI] [get_bd_intf_pins axi_noc2/M00_INI]
  connect_bd_intf_net -intf_net axi_noc2_M01_INI [get_bd_intf_pins M01_INI] [get_bd_intf_pins axi_noc2/M01_INI]
  connect_bd_intf_net -intf_net axi_noc2_M02_INI [get_bd_intf_pins M02_INI] [get_bd_intf_pins axi_noc2/M02_INI]
  connect_bd_intf_net -intf_net axi_noc2_M03_INI [get_bd_intf_pins M03_INI] [get_bd_intf_pins axi_noc2/M03_INI]
  connect_bd_intf_net -intf_net frmbuf_ss_wr_m_axi_mm_video [get_bd_intf_pins frmbuf_ss_wr/m_axi_mm_video] [get_bd_intf_pins axi_noc2/S00_AXI]
  connect_bd_intf_net -intf_net frmbuff_ss_rd_m_axi_mm_video1 [get_bd_intf_pins frmbuff_ss_rd/m_axi_mm_video1] [get_bd_intf_pins axi_noc2/S01_AXI]
  connect_bd_intf_net -intf_net hdmi_tx_ss_LINK_DATA0_OUT [get_bd_intf_pins hdmi_tx_ss/LINK_DATA0_OUT] [get_bd_intf_pins hdmiphy_ss/vid_phy_tx_axi4s_ch0]
  connect_bd_intf_net -intf_net hdmi_tx_ss_LINK_DATA1_OUT [get_bd_intf_pins hdmi_tx_ss/LINK_DATA1_OUT] [get_bd_intf_pins hdmiphy_ss/vid_phy_tx_axi4s_ch1]
  connect_bd_intf_net -intf_net hdmi_tx_ss_LINK_DATA2_OUT [get_bd_intf_pins hdmi_tx_ss/LINK_DATA2_OUT] [get_bd_intf_pins hdmiphy_ss/vid_phy_tx_axi4s_ch2]
  connect_bd_intf_net -intf_net hdmi_tx_ss_LINK_DATA3_OUT [get_bd_intf_pins hdmi_tx_ss/LINK_DATA3_OUT] [get_bd_intf_pins hdmiphy_ss/vid_phy_tx_axi4s_ch3]
  connect_bd_intf_net -intf_net hdmiphy_ss_1_phy_data [get_bd_intf_pins GT_Serial] [get_bd_intf_pins hdmiphy_ss/phy_data]
  connect_bd_intf_net -intf_net hdmiphy_ss_1_vid_phy_rx_axi4s_ch0 [get_bd_intf_pins hdmiphy_ss/vid_phy_rx_axi4s_ch0] [get_bd_intf_pins hdmi_rx_ss/LINK_DATA0_IN]
  connect_bd_intf_net -intf_net hdmiphy_ss_1_vid_phy_rx_axi4s_ch1 [get_bd_intf_pins hdmiphy_ss/vid_phy_rx_axi4s_ch1] [get_bd_intf_pins hdmi_rx_ss/LINK_DATA1_IN]
  connect_bd_intf_net -intf_net hdmiphy_ss_1_vid_phy_rx_axi4s_ch2 [get_bd_intf_pins hdmiphy_ss/vid_phy_rx_axi4s_ch2] [get_bd_intf_pins hdmi_rx_ss/LINK_DATA2_IN]
  connect_bd_intf_net -intf_net hdmiphy_ss_1_vid_phy_rx_axi4s_ch3 [get_bd_intf_pins hdmiphy_ss/vid_phy_rx_axi4s_ch3] [get_bd_intf_pins hdmi_rx_ss/LINK_DATA3_IN]
  connect_bd_intf_net -intf_net hdmiphy_ss_1_vid_phy_status_sb_rx [get_bd_intf_pins hdmiphy_ss/vid_phy_status_sb_rx] [get_bd_intf_pins hdmi_rx_ss/SB_STATUS_IN]
  connect_bd_intf_net -intf_net s_axis_video_1 [get_bd_intf_pins frmbuf_ss_wr/s_axis_video] [get_bd_intf_pins hdmi_rx_ss/M_AXIS]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect/M00_AXI] [get_bd_intf_pins hdmiphy_ss/vid_phy_axi4lite]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins smartconnect/M01_AXI] [get_bd_intf_pins hdmi_rx_ss/S_AXI_CPU_IN]
  connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins smartconnect/M02_AXI] [get_bd_intf_pins hdmi_tx_ss/S_AXI_CPU_IN]
  connect_bd_intf_net -intf_net smartconnect_0_M03_AXI [get_bd_intf_pins axi_iic_0/S_AXI] [get_bd_intf_pins smartconnect/M03_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M04_AXI [get_bd_intf_pins axi_timer_0/S_AXI] [get_bd_intf_pins smartconnect/M04_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M05_AXI [get_bd_intf_pins axi_timer_1/S_AXI] [get_bd_intf_pins smartconnect/M05_AXI]
  connect_bd_intf_net -intf_net smartconnect_M07_AXI [get_bd_intf_pins smartconnect/M07_AXI] [get_bd_intf_pins frmbuf_ss_wr/s_axi_CTRL]
  connect_bd_intf_net -intf_net smartconnect_M08_AXI [get_bd_intf_pins smartconnect/M08_AXI] [get_bd_intf_pins frmbuff_ss_rd/s_axi_ctrl_vmix]
  connect_bd_intf_net -intf_net v_hdmi_rxss1_DDC_OUT [get_bd_intf_pins RX_DDC_OUT] [get_bd_intf_pins hdmi_rx_ss/DDC_OUT]
  connect_bd_intf_net -intf_net v_hdmi_txss1_DDC_OUT [get_bd_intf_pins TX_DDC_OUT] [get_bd_intf_pins hdmi_tx_ss/DDC_OUT]
  connect_bd_intf_net -intf_net vmixer_m_axis_vmix_video_out [get_bd_intf_pins frmbuff_ss_rd/m_axis_video_out] [get_bd_intf_pins hdmi_tx_ss/S_AXIS]

  # Create port connections
  connect_bd_net -net IDT8T49N241_LOL_IN_1  [get_bd_pins IDT8T49N241_LOL_IN] \
  [get_bd_pins hdmiphy_ss/tx_refclk_rdy]
  connect_bd_net -net RX_DET_N_IN_1  [get_bd_pins RX_DET_N_n] \
  [get_bd_pins hdmi_rx_ss/RX_DET_N_n]
  connect_bd_net -net TX_HPD_IN_1  [get_bd_pins TX_HPD_IN] \
  [get_bd_pins hdmi_tx_ss/TX_HPD_IN]
  connect_bd_net -net axi_iic_0_iic2intc_irpt  [get_bd_pins axi_iic_0/iic2intc_irpt] \
  [get_bd_pins irq_iic_ctrl]
  connect_bd_net -net axi_timer_0_interrupt  [get_bd_pins axi_timer_0/interrupt] \
  [get_bd_pins irq_timer0]
  connect_bd_net -net axi_timer_1_interrupt  [get_bd_pins axi_timer_1/interrupt] \
  [get_bd_pins irq_timer1]
  connect_bd_net -net gt_refclk_buf_ss_0_IBUFDSGT_ODIV2_OUT  [get_bd_pins gt_refclk_buf_ss_0/IBUFDSGT_ODIV2_OUT] \
  [get_bd_pins hdmiphy_ss/dru_ref_clk_odiv2_in]
  connect_bd_net -net gt_refclk_buf_ss_0_IBUFDSGT_OUT  [get_bd_pins gt_refclk_buf_ss_0/IBUFDSGT_OUT] \
  [get_bd_pins hdmiphy_ss/dru_ref_clk_in]
  connect_bd_net -net hdmi_ss_rxoutclk  [get_bd_pins hdmiphy_ss/rxoutclk] \
  [get_bd_pins hdmi_rx_ss/link_clk]
  connect_bd_net -net hdmiphy_ss_0_rx_video_clk  [get_bd_pins hdmiphy_ss/rx_video_clk] \
  [get_bd_pins v_fifo_dc/a_clk] \
  [get_bd_pins hdmi_rx_ss/video_clk]
  connect_bd_net -net hdmiphy_ss_0_tx_video_clk  [get_bd_pins hdmiphy_ss/tx_video_clk] \
  [get_bd_pins v_fifo_dc/b_clk] \
  [get_bd_pins hdmi_tx_ss/video_clk]
  connect_bd_net -net hdmiphy_ss_1_irq  [get_bd_pins hdmiphy_ss/irq] \
  [get_bd_pins irq_vphy]
  connect_bd_net -net hdmiphy_ss_1_rx_tmds_clk_n  [get_bd_pins hdmiphy_ss/rx_tmds_clk_n] \
  [get_bd_pins RX_REFCLK_N_OUT]
  connect_bd_net -net hdmiphy_ss_1_rx_tmds_clk_p  [get_bd_pins hdmiphy_ss/rx_tmds_clk_p] \
  [get_bd_pins RX_REFCLK_P_OUT]
  connect_bd_net -net pl_lpd_irq6_1  [get_bd_pins frmbuf_ss_wr/irq_frmbuf_wr] \
  [get_bd_pins fb_wr_irq]
  connect_bd_net -net ps_ss_clk150_aresetn  [get_bd_pins s_axi_cpu_aresetn] \
  [get_bd_pins vfmc_ctlr_ss/s_axi_aresetn] \
  [get_bd_pins axi_timer_0/s_axi_aresetn] \
  [get_bd_pins axi_timer_1/s_axi_aresetn] \
  [get_bd_pins axi_iic_0/s_axi_aresetn] \
  [get_bd_pins hdmi_rx_ss/s_axi_cpu_aresetn] \
  [get_bd_pins hdmi_tx_ss/s_axi_cpu_aresetn] \
  [get_bd_pins smartconnect/aresetn] \
  [get_bd_pins hdmiphy_ss/vid_phy_axi4lite_aresetn] \
  [get_bd_pins hdmiphy_ss/vid_phy_sb_aresetn]
  connect_bd_net -net ps_ss_clk300_aresetn  [get_bd_pins s_axis_video_aresetn] \
  [get_bd_pins frmbuf_ss_wr/s_axis_video_aresetn] \
  [get_bd_pins frmbuff_ss_rd/s_axis_video_aresetn] \
  [get_bd_pins v_fifo_dc/rstn] \
  [get_bd_pins hdmi_rx_ss/s_axis_video_aresetn] \
  [get_bd_pins hdmi_tx_ss/s_axis_video_aresetn]
  connect_bd_net -net ps_ss_clkx5_450  [get_bd_pins frl_clk] \
  [get_bd_pins hdmi_rx_ss/frl_clk] \
  [get_bd_pins hdmi_tx_ss/frl_clk]
  connect_bd_net -net ps_ss_pl_clk_150  [get_bd_pins s_axi_cpu_aclk] \
  [get_bd_pins vfmc_ctlr_ss/s_axi_aclk] \
  [get_bd_pins axi_timer_0/s_axi_aclk] \
  [get_bd_pins axi_timer_1/s_axi_aclk] \
  [get_bd_pins axi_iic_0/s_axi_aclk] \
  [get_bd_pins hdmi_rx_ss/s_axi_cpu_aclk] \
  [get_bd_pins hdmi_tx_ss/s_axi_cpu_aclk] \
  [get_bd_pins smartconnect/aclk] \
  [get_bd_pins hdmiphy_ss/vid_phy_axi4lite_aclk] \
  [get_bd_pins hdmiphy_ss/drpclk] \
  [get_bd_pins hdmiphy_ss/vid_phy_sb_aclk]
  connect_bd_net -net ps_ss_pl_clk_300  [get_bd_pins s_axis_video_aclk] \
  [get_bd_pins frmbuf_ss_wr/s_axis_video_aclk] \
  [get_bd_pins frmbuff_ss_rd/s_axis_video_aclk] \
  [get_bd_pins v_fifo_dc/rstn_clk] \
  [get_bd_pins hdmi_rx_ss/s_axis_video_aclk] \
  [get_bd_pins hdmi_tx_ss/s_axis_video_aclk] \
  [get_bd_pins smartconnect/aclk1] \
  [get_bd_pins axi_noc2/aclk0]
  connect_bd_net -net rx_ref_clk_in_1  [get_bd_pins gt_refclk_buf_ss_2/IBUFDSGT_OUT] \
  [get_bd_pins hdmiphy_ss/rx_ref_clk_in]
  connect_bd_net -net rx_ref_clk_odiv2_in_1  [get_bd_pins gt_refclk_buf_ss_2/IBUFDSGT_ODIV2_OUT] \
  [get_bd_pins hdmiphy_ss/rx_ref_clk_odiv2_in]
  connect_bd_net -net tx_link_clk_1  [get_bd_pins hdmiphy_ss/txoutclk] \
  [get_bd_pins hdmi_tx_ss/link_clk]
  connect_bd_net -net tx_ref_clk_in_1  [get_bd_pins gt_refclk_buf_ss_1/IBUFDSGT_OUT] \
  [get_bd_pins hdmiphy_ss/tx_ref_clk_in]
  connect_bd_net -net tx_ref_clk_odiv2_in_1  [get_bd_pins gt_refclk_buf_ss_1/IBUFDSGT_ODIV2_OUT] \
  [get_bd_pins hdmiphy_ss/tx_ref_clk_odiv2_in]
  connect_bd_net -net v_fifo_dc_b_de_out  [get_bd_pins v_fifo_dc/b_de_out] \
  [get_bd_pins hdmi_tx_ss/video_cke_in]
  connect_bd_net -net v_hdmi_rxss1_hpd  [get_bd_pins hdmi_rx_ss/RX_HPD_OUT] \
  [get_bd_pins RX_HPD_OUT]
  connect_bd_net -net v_hdmi_rxss1_irq  [get_bd_pins hdmi_rx_ss/irq_rx] \
  [get_bd_pins irq_rx]
  connect_bd_net -net v_hdmi_rxss1_video_cke_out  [get_bd_pins hdmi_rx_ss/video_cke_out] \
  [get_bd_pins v_fifo_dc/a_wr_in]
  connect_bd_net -net v_hdmi_txss1_irq  [get_bd_pins hdmi_tx_ss/irq_tx] \
  [get_bd_pins irq_tx]
  connect_bd_net -net v_hdmi_txss1_locked  [get_bd_pins hdmi_tx_ss/LED0] \
  [get_bd_pins LED0]
  connect_bd_net -net vfmc_ctlr_ss_0_VFMC_RX_ONSEMI_ENABLE  [get_bd_pins vfmc_ctlr_ss/VFMC_RX_ONSEMI_ENABLE] \
  [get_bd_pins TX_TI_ENABLE]
  connect_bd_net -net vid_phy_tx_axi4s_aresetn_1  [get_bd_pins vcc_const/dout] \
  [get_bd_pins v_fifo_dc/b_rd_in] \
  [get_bd_pins v_fifo_dc/a_dat_in] \
  [get_bd_pins hdmiphy_ss/vid_phy_rx_axi4s_aresetn] \
  [get_bd_pins hdmiphy_ss/vid_phy_tx_axi4s_aresetn]
  connect_bd_net -net vmixer_mixer_irq  [get_bd_pins frmbuff_ss_rd/fb_rd_irq] \
  [get_bd_pins fb_rd_irq]

  # Restore current instance
  current_bd_instance $oldCurInst
}


proc available_tcl_procs { } {
   puts "##################################################################"
   puts "# Available Tcl procedures to recreate hierarchical blocks:"
   puts "#"
   puts "#    create_hier_cell_hdmi_ss parentCell nameHier"
   puts "#    create_hier_cell_frmbuff_ss_rd parentCell nameHier"
   puts "#    create_hier_cell_gt_refclk_buf_ss_0 parentCell nameHier"
   puts "#    create_hier_cell_gt_refclk_buf_ss_1 parentCell nameHier"
   puts "#    create_hier_cell_gt_refclk_buf_ss_2 parentCell nameHier"
   puts "#    create_hier_cell_frmbuf_ss_wr parentCell nameHier"
   puts "#    create_hier_cell_vfmc_ctlr_ss parentCell nameHier"
   puts "#    create_hier_cell_hdmi_rx_ss parentCell nameHier"
   puts "#    create_hier_cell_hdmi_tx_ss parentCell nameHier"
   puts "#    create_hier_cell_hdmiphy_ss parentCell nameHier"
   puts "#"
   puts "##################################################################"
}

available_tcl_procs

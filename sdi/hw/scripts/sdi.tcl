# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------

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
xilinx.com:ip:bufg_gt:*\
xilinx.com:ip:v_vid_gt_bridge:*\
xilinx.com:ip:util_ds_buf:*\
xilinx.com:ip:gtwiz_versal:*\
xilinx.com:ip:axi_noc2:*\
xilinx.com:inline_hdl:ilconstant:*\
xilinx.com:ip:axi_intc:*\
xilinx.com:inline_hdl:ilconcat:*\
xilinx.com:ip:v_uhdsdi_audio:*\
xilinx.com:ip:v_smpte_uhdsdi_tx_ss:*\
xilinx.com:inline_hdl:ilslice:*\
xilinx.com:ip:v_frmbuf_rd:*\
xilinx.com:ip:axi_gpio:*\
xilinx.com:ip:axi_iic:*\
xilinx.com:ip:axi_quad_spi:*\
xilinx.com:ip:proc_sys_reset:*\
xilinx.com:ip:util_vector_logic:*\
xilinx.com:ip:xpm_cdc_gen:*\
xilinx.com:ip:smartconnect:*\
xilinx.com:ip:clkx5_wiz:*\
xilinx.com:ip:v_smpte_uhdsdi_rx_ss:*\
xilinx.com:ip:v_frmbuf_wr:*\
xilinx.com:ip:axis_data_fifo:*\
xilinx.com:ip:v_proc_ss:*\
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


# Hierarchical cell: RX_Heir
proc create_hier_cell_RX_Heir { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_RX_Heir() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_CTRL

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_CTRL1

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_RX

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_CTRL_SB_RX

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_STS_SB_RX

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_mm_video

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_CTRL3

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_ctrl2


  # Create pins
  create_bd_pin -dir O -type intr interrupt
  create_bd_pin -dir I -type rst s_axi_arstn
  create_bd_pin -dir O -type intr sdi_rx_irq
  create_bd_pin -dir I -type rst sdi_rx_rst
  create_bd_pin -dir I -type rst video_out_arstn
  create_bd_pin -dir I -type clk video_out_clk
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type clk sdi_rx_clk
  create_bd_pin -dir O -type intr interrupt1
  create_bd_pin -dir I -from 3 -to 0 Din
  create_bd_pin -dir O fid

  # Create instance: v_uhdsdi_audio_Extract, and set properties
  set v_uhdsdi_audio_Extract [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_uhdsdi_audio v_uhdsdi_audio_Extract ]
  set_property -dict [list \
    CONFIG.C_AUDIO_FUNCTION {Extract} \
    CONFIG.C_MAX_AUDIO_CHANNELS {32} \
  ] $v_uhdsdi_audio_Extract


  # Create instance: v_smpte_uhdsdi_rx_ss_0, and set properties
  set v_smpte_uhdsdi_rx_ss_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_smpte_uhdsdi_rx_ss v_smpte_uhdsdi_rx_ss_0 ]
  set_property -dict [list \
    CONFIG.C_BPP {12} \
    CONFIG.C_DYNAMIC_BPP_CHANGE {true} \
    CONFIG.C_INCLUDE_ADV_FEATURES {true} \
  ] $v_smpte_uhdsdi_rx_ss_0


  # Create instance: v_frmbuf_wr_0, and set properties
  set v_frmbuf_wr_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_frmbuf_wr v_frmbuf_wr_0 ]
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
    CONFIG.MAX_DATA_WIDTH {12} \
  ] $v_frmbuf_wr_0


  # Create instance: ilslice_0, and set properties
  set ilslice_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice ilslice_0 ]
  set_property CONFIG.DIN_WIDTH {4} $ilslice_0


  # Create instance: axis_data_fifo_0, and set properties
  set axis_data_fifo_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo axis_data_fifo_0 ]

  # Create instance: v_proc_ss_0, and set properties
  set v_proc_ss_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_proc_ss v_proc_ss_0 ]
  set_property -dict [list \
    CONFIG.C_ENABLE_CSC {true} \
    CONFIG.C_MAX_DATA_WIDTH {12} \
    CONFIG.C_TOPOLOGY {0} \
  ] $v_proc_ss_0


  # Create instance: ilslice_2, and set properties
  set ilslice_2 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice ilslice_2 ]
set_property -dict [list \
    CONFIG.DIN_FROM {2} \
    CONFIG.DIN_TO {2} \
    CONFIG.DIN_WIDTH {4} \
  ] $ilslice_2

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins v_smpte_uhdsdi_rx_ss_0/S_AXIS_RX] [get_bd_intf_pins S_AXIS_RX]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins v_smpte_uhdsdi_rx_ss_0/M_AXIS_CTRL_SB_RX] [get_bd_intf_pins M_AXIS_CTRL_SB_RX]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins v_smpte_uhdsdi_rx_ss_0/S_AXIS_STS_SB_RX] [get_bd_intf_pins S_AXIS_STS_SB_RX]
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins v_frmbuf_wr_0/m_axi_mm_video] [get_bd_intf_pins m_axi_mm_video]
  connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins v_frmbuf_wr_0/s_axi_CTRL] [get_bd_intf_pins s_axi_CTRL3]
  connect_bd_intf_net -intf_net Conn6 [get_bd_intf_pins axis_data_fifo_0/M_AXIS] [get_bd_intf_pins M_AXIS]
  connect_bd_intf_net -intf_net S_AXI_CTRL1_1 [get_bd_intf_pins S_AXI_CTRL1] [get_bd_intf_pins v_smpte_uhdsdi_rx_ss_0/S_AXI_CTRL]
  connect_bd_intf_net -intf_net s_axi_ctrl2_1 [get_bd_intf_pins s_axi_ctrl2] [get_bd_intf_pins v_proc_ss_0/s_axi_ctrl]
  connect_bd_intf_net -intf_net smartconnect_1_M09_AXI [get_bd_intf_pins S_AXI_CTRL] [get_bd_intf_pins v_uhdsdi_audio_Extract/S_AXI_CTRL]
  connect_bd_intf_net -intf_net v_proc_ss_0_m_axis [get_bd_intf_pins v_proc_ss_0/m_axis] [get_bd_intf_pins v_frmbuf_wr_0/s_axis_video]
  connect_bd_intf_net -intf_net v_smpte_uhdsdi_rx_ss_0_SDI_RX_ANC_DS_OUT [get_bd_intf_pins v_smpte_uhdsdi_rx_ss_0/SDI_RX_ANC_DS_OUT] [get_bd_intf_pins v_uhdsdi_audio_Extract/SDI_EXTRACT_ANC_DS_IN]
  connect_bd_intf_net -intf_net v_smpte_uhdsdi_rx_ss_0_VIDEO_OUT [get_bd_intf_pins v_smpte_uhdsdi_rx_ss_0/VIDEO_OUT] [get_bd_intf_pins v_proc_ss_0/s_axis]
  connect_bd_intf_net -intf_net v_uhdsdi_audio_Extract_M_AXIS_DATA [get_bd_intf_pins v_uhdsdi_audio_Extract/M_AXIS_DATA] [get_bd_intf_pins axis_data_fifo_0/S_AXIS]

  # Create port connections
  connect_bd_net -net Din_1  [get_bd_pins Din] \
  [get_bd_pins ilslice_0/Din] \
  [get_bd_pins ilslice_2/Din]
  connect_bd_net -net axi_gpio_2_gpio_io_o  [get_bd_pins sdi_rx_rst] \
  [get_bd_pins v_uhdsdi_audio_Extract/sdi_extract_reset] \
  [get_bd_pins v_smpte_uhdsdi_rx_ss_0/sdi_rx_rst]
  connect_bd_net -net clk_wizard_0_clk_out2  [get_bd_pins video_out_clk] \
  [get_bd_pins v_uhdsdi_audio_Extract/m_axis_clk] \
  [get_bd_pins v_smpte_uhdsdi_rx_ss_0/video_out_clk] \
  [get_bd_pins v_frmbuf_wr_0/ap_clk] \
  [get_bd_pins axis_data_fifo_0/s_axis_aclk] \
  [get_bd_pins v_proc_ss_0/aclk_axis]
  connect_bd_net -net ilslice_0_Dout  [get_bd_pins ilslice_0/Dout] \
  [get_bd_pins v_frmbuf_wr_0/ap_rst_n]
  connect_bd_net -net ilslice_2_Dout  [get_bd_pins ilslice_2/Dout] \
  [get_bd_pins v_proc_ss_0/aresetn_ctrl]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn  [get_bd_pins s_axi_arstn] \
  [get_bd_pins v_uhdsdi_audio_Extract/s_axi_aresetn] \
  [get_bd_pins v_smpte_uhdsdi_rx_ss_0/s_axi_arstn]
  connect_bd_net -net proc_sys_reset_1_peripheral_aresetn  [get_bd_pins video_out_arstn] \
  [get_bd_pins v_uhdsdi_audio_Extract/m_axis_resetn] \
  [get_bd_pins v_smpte_uhdsdi_rx_ss_0/video_out_arstn] \
  [get_bd_pins axis_data_fifo_0/s_axis_aresetn]
  connect_bd_net -net s_axi_aclk_1  [get_bd_pins s_axi_aclk] \
  [get_bd_pins v_smpte_uhdsdi_rx_ss_0/s_axi_aclk] \
  [get_bd_pins v_uhdsdi_audio_Extract/s_axi_aclk] \
  [get_bd_pins v_proc_ss_0/aclk_ctrl]
  connect_bd_net -net sdi_rx_clk_1  [get_bd_pins sdi_rx_clk] \
  [get_bd_pins v_smpte_uhdsdi_rx_ss_0/sdi_rx_clk] \
  [get_bd_pins v_uhdsdi_audio_Extract/sdi_extract_clk]
  connect_bd_net -net v_frmbuf_wr_0_interrupt  [get_bd_pins v_frmbuf_wr_0/interrupt] \
  [get_bd_pins interrupt1]
  connect_bd_net -net v_smpte_uhdsdi_rx_ss_0_fid  [get_bd_pins v_smpte_uhdsdi_rx_ss_0/fid] \
  [get_bd_pins fid]
  connect_bd_net -net v_smpte_uhdsdi_rx_ss_0_sdi_rx_anc_ctrl_out  [get_bd_pins v_smpte_uhdsdi_rx_ss_0/sdi_rx_anc_ctrl_out] \
  [get_bd_pins v_uhdsdi_audio_Extract/sdi_extract_anc_ctrl_in]
  connect_bd_net -net v_smpte_uhdsdi_rx_ss_0_sdi_rx_irq  [get_bd_pins v_smpte_uhdsdi_rx_ss_0/sdi_rx_irq] \
  [get_bd_pins sdi_rx_irq]
  connect_bd_net -net v_uhdsdi_audio_0_interrupt  [get_bd_pins v_uhdsdi_audio_Extract/interrupt] \
  [get_bd_pins interrupt]

  # Perform GUI Layout
  regenerate_bd_layout -hierarchy [get_bd_cells /sdi/RX_Heir] -layout_string {
   "ActiveEmotionalView":"Default View",
   "Default View_ScaleFactor":"0.959866",
   "Default View_TopLeft":"-391,3",
   "ExpandedHierarchyInLayout":"",
   "guistr":"# # String gsaved with Nlview 7.8.0 2024-04-26 e1825d835c VDI=44 GEI=38 GUI=JA:24.0 TLS
#  -string -flagsOSRD
preplace port S_AXI_CTRL -pg 1 -lvl 0 -x 0 -y 440 -defaultsOSRD
preplace port S_AXI_CTRL1 -pg 1 -lvl 0 -x 0 -y 720 -defaultsOSRD
preplace port S_AXIS_RX -pg 1 -lvl 0 -x 0 -y 660 -defaultsOSRD
preplace port M_AXIS_CTRL_SB_RX -pg 1 -lvl 4 -x 1110 -y 690 -defaultsOSRD
preplace port S_AXIS_STS_SB_RX -pg 1 -lvl 0 -x 0 -y 690 -defaultsOSRD
preplace port m_axi_mm_video -pg 1 -lvl 4 -x 1110 -y 140 -defaultsOSRD
preplace port s_axi_CTRL3 -pg 1 -lvl 0 -x 0 -y 120 -defaultsOSRD
preplace port M_AXIS -pg 1 -lvl 4 -x 1110 -y 300 -defaultsOSRD
preplace port port-id_interrupt -pg 1 -lvl 4 -x 1110 -y 510 -defaultsOSRD
preplace port port-id_s_axi_arstn -pg 1 -lvl 0 -x 0 -y 500 -defaultsOSRD
preplace port port-id_sdi_rx_irq -pg 1 -lvl 4 -x 1110 -y 790 -defaultsOSRD
preplace port port-id_sdi_rx_rst -pg 1 -lvl 0 -x 0 -y 560 -defaultsOSRD
preplace port port-id_video_out_arstn -pg 1 -lvl 0 -x 0 -y 600 -defaultsOSRD
preplace port port-id_video_out_clk -pg 1 -lvl 0 -x 0 -y 250 -defaultsOSRD
preplace port port-id_s_axi_aclk -pg 1 -lvl 0 -x 0 -y 470 -defaultsOSRD
preplace port port-id_sdi_rx_clk -pg 1 -lvl 0 -x 0 -y 530 -defaultsOSRD
preplace port port-id_interrupt1 -pg 1 -lvl 4 -x 1110 -y 170 -defaultsOSRD
preplace port port-id_fid -pg 1 -lvl 4 -x 1110 -y 760 -defaultsOSRD
preplace portBus Din -pg 1 -lvl 0 -x 0 -y 60 -defaultsOSRD
preplace inst v_uhdsdi_audio_Extract -pg 1 -lvl 2 -x 480 -y 520 -defaultsOSRD
preplace inst v_smpte_uhdsdi_rx_ss_0 -pg 1 -lvl 3 -x 890 -y 750 -defaultsOSRD
preplace inst v_frmbuf_wr_0 -pg 1 -lvl 3 -x 890 -y 150 -defaultsOSRD
preplace inst ilslice_0 -pg 1 -lvl 2 -x 480 -y 60 -defaultsOSRD
preplace inst axis_data_fifo_0 -pg 1 -lvl 3 -x 890 -y 300 -defaultsOSRD
preplace inst v_proc_ss_0 -pg 1 -lvl 2 -x 480 -y 270 -defaultsOSRD
preplace inst ilslice_2 -pg 1 -lvl 1 -x 120 -y 310 -defaultsOSRD
preplace netloc Din_1 1 0 2 20 60 NJ
preplace netloc axi_gpio_2_gpio_io_o 1 0 3 NJ 560 270 750 NJ
preplace netloc clk_wizard_0_clk_out2 1 0 3 NJ 250 250 370 690
preplace netloc ilslice_0_Dout 1 2 1 680J 60n
preplace netloc proc_sys_reset_0_peripheral_aresetn 1 0 3 NJ 500 220 830 NJ
preplace netloc proc_sys_reset_1_peripheral_aresetn 1 0 3 NJ 600 250 660 700
preplace netloc s_axi_aclk_1 1 0 3 NJ 470 240 810 NJ
preplace netloc sdi_rx_clk_1 1 0 3 NJ 530 260 730 NJ
preplace netloc v_frmbuf_wr_0_interrupt 1 3 1 1080J 160n
preplace netloc v_smpte_uhdsdi_rx_ss_0_fid 1 3 1 1090J 760n
preplace netloc v_smpte_uhdsdi_rx_ss_0_sdi_rx_anc_ctrl_out 1 1 3 280 900 NJ 900 1070
preplace netloc v_smpte_uhdsdi_rx_ss_0_sdi_rx_irq 1 3 1 NJ 790
preplace netloc v_uhdsdi_audio_0_interrupt 1 2 2 NJ 510 NJ
preplace netloc ilslice_2_Dout 1 1 1 NJ 310
preplace netloc Conn1 1 0 3 NJ 660 230J 670 NJ
preplace netloc Conn2 1 3 1 NJ 690
preplace netloc Conn3 1 0 3 NJ 690 NJ 690 NJ
preplace netloc Conn4 1 3 1 NJ 140
preplace netloc Conn5 1 0 3 NJ 120 NJ 120 NJ
preplace netloc Conn6 1 3 1 NJ 300
preplace netloc S_AXI_CTRL1_1 1 0 3 NJ 720 NJ 720 710J
preplace netloc smartconnect_1_M09_AXI 1 0 2 NJ 440 NJ
preplace netloc v_smpte_uhdsdi_rx_ss_0_SDI_RX_ANC_DS_OUT 1 1 3 290 890 NJ 890 1080
preplace netloc v_uhdsdi_audio_Extract_M_AXIS_DATA 1 2 1 670 280n
preplace netloc v_proc_ss_0_m_axis 1 2 1 670 140n
preplace netloc v_smpte_uhdsdi_rx_ss_0_VIDEO_OUT 1 1 3 290 380 NJ 380 1080
levelinfo -pg 1 0 120 480 890 1110
pagesize -pg 1 -db -bbox -sgen -170 0 1300 910
"
}

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: peripheral_hier
proc create_hier_cell_peripheral_hier { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_peripheral_hier() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 fzetton_fmc_gpio

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 fzetton_fmc_iic

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:spi_rtl:1.0 fzetton_fmc_spi

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M00_AXI_0

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M01_AXI_0

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M09_AXI_0

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M10_AXI_0

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M03_AXI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M08_AXI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M12_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M13_AXI


  # Create pins
  create_bd_pin -dir O -from 0 -to 0 Res
  create_bd_pin -dir O -from 0 -to 0 gpio_io_o
  create_bd_pin -dir O -from 7 -to 0 gpio_io_o1
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_aresetn
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_aresetn1
  create_bd_pin -dir I -type rst reset
  create_bd_pin -dir O -type clk clk_out2
  create_bd_pin -dir O -type clk clk_freerun1
  create_bd_pin -dir I -type clk clk_in1
  create_bd_pin -dir O -type intr iic2intc_irpt
  create_bd_pin -dir O -type intr ip2intc_irpt
  create_bd_pin -dir O -from 3 -to 0 gpio_io_o2

  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio axi_gpio_0 ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_GPIO_WIDTH {8} \
  ] $axi_gpio_0


  # Create instance: axi_gpio_2, and set properties
  set axi_gpio_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio axi_gpio_2 ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_GPIO_WIDTH {1} \
  ] $axi_gpio_2


  # Create instance: axi_gpio_3, and set properties
  set axi_gpio_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio axi_gpio_3 ]
  set_property CONFIG.C_ALL_OUTPUTS {1} $axi_gpio_3


  # Create instance: axi_iic_0, and set properties
  set axi_iic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic axi_iic_0 ]

  # Create instance: axi_quad_spi_0, and set properties
  set axi_quad_spi_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_quad_spi axi_quad_spi_0 ]
  set_property -dict [list \
    CONFIG.C_FIFO_DEPTH {16} \
    CONFIG.C_NUM_SS_BITS {3} \
    CONFIG.C_NUM_TRANSFER_BITS {16} \
    CONFIG.FIFO_INCLUDED {1} \
  ] $axi_quad_spi_0


  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_0 ]

  # Create instance: proc_sys_reset_1, and set properties
  set proc_sys_reset_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_1 ]

  # Create instance: util_vector_logic_4, and set properties
  set util_vector_logic_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic util_vector_logic_4 ]
  set_property -dict [list \
    CONFIG.C_OPERATION {not} \
    CONFIG.C_SIZE {1} \
  ] $util_vector_logic_4


  # Create instance: xpm_cdc_gen_0, and set properties
  set xpm_cdc_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xpm_cdc_gen xpm_cdc_gen_0 ]
  set_property CONFIG.WIDTH {1} $xpm_cdc_gen_0


  # Create instance: axi_smartconnect_0, and set properties
  set axi_smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect axi_smartconnect_0 ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {3} \
    CONFIG.NUM_MI {14} \
    CONFIG.NUM_SI {1} \
  ] $axi_smartconnect_0


  # Create instance: clkx5_wiz_0, and set properties
  set clkx5_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clkx5_wiz clkx5_wiz_0 ]
  set_property -dict [list \
    CONFIG.CLKOUT_DRIVES {BUFG,BUFG,BUFG,BUFG,BUFG,BUFG,BUFG} \
    CONFIG.CLKOUT_DYN_PS {None,None,None,None,None,None,None} \
    CONFIG.CLKOUT_GROUPING {Auto,Auto,Auto,Auto,Auto,Auto,Auto} \
    CONFIG.CLKOUT_MATCHED_ROUTING {false,false,false,false,false,false,false} \
    CONFIG.CLKOUT_PORT {clk_out1,clk_out2,clk_out3,clk_out4,clk_out5,clk_out6,clk_out7} \
    CONFIG.CLKOUT_REQUESTED_DUTY_CYCLE {50.000,50.000,50.000,50.000,50.000,50.000,50.000} \
    CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {149.000,370,18.500,100.000,100.000,100.000,100.000} \
    CONFIG.CLKOUT_REQUESTED_PHASE {0.000,0.000,0.000,0.000,0.000,0.000,0.000} \
    CONFIG.CLKOUT_USED {true,true,false,false,false,false,false} \
  ] $clkx5_wiz_0


  # Create instance: axi_gpio_slice, and set properties
  set axi_gpio_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio axi_gpio_slice ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_DOUT_DEFAULT {0x0000000F} \
    CONFIG.C_GPIO_WIDTH {4} \
  ] $axi_gpio_slice


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins fzetton_fmc_iic] [get_bd_intf_pins axi_iic_0/IIC]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins fzetton_fmc_gpio] [get_bd_intf_pins axi_gpio_3/GPIO]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins fzetton_fmc_spi] [get_bd_intf_pins axi_quad_spi_0/SPI_0]
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins axi_smartconnect_0/S00_AXI] [get_bd_intf_pins S00_AXI]
  connect_bd_intf_net -intf_net Conn6 [get_bd_intf_pins axi_smartconnect_0/M00_AXI] [get_bd_intf_pins M00_AXI_0]
  connect_bd_intf_net -intf_net Conn7 [get_bd_intf_pins axi_smartconnect_0/M01_AXI] [get_bd_intf_pins M01_AXI_0]
  connect_bd_intf_net -intf_net Conn8 [get_bd_intf_pins axi_smartconnect_0/M03_AXI] [get_bd_intf_pins M03_AXI]
  connect_bd_intf_net -intf_net Conn9 [get_bd_intf_pins axi_smartconnect_0/M08_AXI] [get_bd_intf_pins M08_AXI]
  connect_bd_intf_net -intf_net Conn15 [get_bd_intf_pins axi_smartconnect_0/M09_AXI] [get_bd_intf_pins M09_AXI_0]
  connect_bd_intf_net -intf_net Conn16 [get_bd_intf_pins axi_smartconnect_0/M10_AXI] [get_bd_intf_pins M10_AXI_0]
  connect_bd_intf_net -intf_net Conn17 [get_bd_intf_pins axi_smartconnect_0/M12_AXI] [get_bd_intf_pins M12_AXI]
  connect_bd_intf_net -intf_net axi_smartconnect_0_M02_AXI [get_bd_intf_pins axi_smartconnect_0/M02_AXI] [get_bd_intf_pins axi_gpio_0/S_AXI]
  connect_bd_intf_net -intf_net axi_smartconnect_0_M04_AXI [get_bd_intf_pins axi_smartconnect_0/M04_AXI] [get_bd_intf_pins axi_gpio_2/S_AXI]
  connect_bd_intf_net -intf_net axi_smartconnect_0_M05_AXI [get_bd_intf_pins axi_smartconnect_0/M05_AXI] [get_bd_intf_pins axi_quad_spi_0/AXI_LITE]
  connect_bd_intf_net -intf_net axi_smartconnect_0_M06_AXI [get_bd_intf_pins axi_smartconnect_0/M06_AXI] [get_bd_intf_pins axi_iic_0/S_AXI]
  connect_bd_intf_net -intf_net axi_smartconnect_0_M07_AXI [get_bd_intf_pins axi_smartconnect_0/M07_AXI] [get_bd_intf_pins axi_gpio_3/S_AXI]
  connect_bd_intf_net -intf_net axi_smartconnect_0_M11_AXI [get_bd_intf_pins axi_smartconnect_0/M11_AXI] [get_bd_intf_pins axi_gpio_slice/S_AXI]
  connect_bd_intf_net -intf_net axi_smartconnect_0_M13_AXI [get_bd_intf_pins M13_AXI] [get_bd_intf_pins axi_smartconnect_0/M13_AXI]

  # Create port connections
  connect_bd_net -net axi_gpio_0_gpio_io_o  [get_bd_pins axi_gpio_0/gpio_io_o] \
  [get_bd_pins gpio_io_o1]
  connect_bd_net -net axi_gpio_2_gpio_io_o  [get_bd_pins axi_gpio_2/gpio_io_o] \
  [get_bd_pins gpio_io_o] \
  [get_bd_pins util_vector_logic_4/Op1]
  connect_bd_net -net axi_gpio_slice_gpio_io_o  [get_bd_pins axi_gpio_slice/gpio_io_o] \
  [get_bd_pins gpio_io_o2]
  connect_bd_net -net axi_iic_0_iic2intc_irpt  [get_bd_pins axi_iic_0/iic2intc_irpt] \
  [get_bd_pins iic2intc_irpt]
  connect_bd_net -net axi_quad_spi_0_ip2intc_irpt  [get_bd_pins axi_quad_spi_0/ip2intc_irpt] \
  [get_bd_pins ip2intc_irpt]
  connect_bd_net -net clk_in1_1  [get_bd_pins clk_in1] \
  [get_bd_pins clkx5_wiz_0/clk_in1] \
  [get_bd_pins axi_smartconnect_0/aclk2]
  connect_bd_net -net clkx5_wiz_1_clk_out1  [get_bd_pins clkx5_wiz_0/clk_out1] \
  [get_bd_pins axi_gpio_0/s_axi_aclk] \
  [get_bd_pins axi_gpio_2/s_axi_aclk] \
  [get_bd_pins axi_gpio_3/s_axi_aclk] \
  [get_bd_pins axi_iic_0/s_axi_aclk] \
  [get_bd_pins axi_quad_spi_0/ext_spi_clk] \
  [get_bd_pins axi_quad_spi_0/s_axi_aclk] \
  [get_bd_pins xpm_cdc_gen_0/src_clk] \
  [get_bd_pins axi_smartconnect_0/aclk] \
  [get_bd_pins proc_sys_reset_0/slowest_sync_clk] \
  [get_bd_pins clk_freerun1]
  connect_bd_net -net clkx5_wiz_1_clk_out2  [get_bd_pins clkx5_wiz_0/clk_out2] \
  [get_bd_pins xpm_cdc_gen_0/dest_clk] \
  [get_bd_pins proc_sys_reset_1/slowest_sync_clk] \
  [get_bd_pins clk_out2] \
  [get_bd_pins axi_smartconnect_0/aclk1] \
  [get_bd_pins axi_gpio_slice/s_axi_aclk]
  connect_bd_net -net ext_reset_in_0_1  [get_bd_pins reset] \
  [get_bd_pins proc_sys_reset_0/ext_reset_in] \
  [get_bd_pins proc_sys_reset_1/ext_reset_in]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn  [get_bd_pins proc_sys_reset_0/peripheral_aresetn] \
  [get_bd_pins peripheral_aresetn] \
  [get_bd_pins axi_gpio_0/s_axi_aresetn] \
  [get_bd_pins axi_gpio_2/s_axi_aresetn] \
  [get_bd_pins axi_gpio_3/s_axi_aresetn] \
  [get_bd_pins axi_iic_0/s_axi_aresetn] \
  [get_bd_pins axi_quad_spi_0/s_axi_aresetn] \
  [get_bd_pins axi_smartconnect_0/aresetn]
  connect_bd_net -net proc_sys_reset_1_peripheral_aresetn  [get_bd_pins proc_sys_reset_1/peripheral_aresetn] \
  [get_bd_pins peripheral_aresetn1] \
  [get_bd_pins axi_gpio_slice/s_axi_aresetn]
  connect_bd_net -net util_vector_logic_4_Res  [get_bd_pins util_vector_logic_4/Res] \
  [get_bd_pins xpm_cdc_gen_0/src_in]
  connect_bd_net -net xpm_cdc_gen_0_dest_out  [get_bd_pins xpm_cdc_gen_0/dest_out] \
  [get_bd_pins Res]

  # Perform GUI Layout
  regenerate_bd_layout -hierarchy [get_bd_cells /sdi/peripheral_hier] -layout_string {
   "ActiveEmotionalView":"Default View",
   "Default View_ScaleFactor":"0.653759",
   "Default View_TopLeft":"-1245,2",
   "ExpandedHierarchyInLayout":"",
   "guistr":"# # String gsaved with Nlview 7.8.0 2024-04-26 e1825d835c VDI=44 GEI=38 GUI=JA:24.0 TLS
#  -string -flagsOSRD
preplace port fzetton_fmc_gpio -pg 1 -lvl 3 -x 790 -y 450 -defaultsOSRD
preplace port fzetton_fmc_iic -pg 1 -lvl 3 -x 790 -y 570 -defaultsOSRD
preplace port fzetton_fmc_spi -pg 1 -lvl 3 -x 790 -y 910 -defaultsOSRD
preplace port M00_AXI_0 -pg 1 -lvl 3 -x 790 -y 20 -defaultsOSRD
preplace port M01_AXI_0 -pg 1 -lvl 3 -x 790 -y 190 -defaultsOSRD
preplace port M09_AXI_0 -pg 1 -lvl 3 -x 790 -y 330 -defaultsOSRD
preplace port M10_AXI_0 -pg 1 -lvl 3 -x 790 -y 350 -defaultsOSRD
preplace port M03_AXI -pg 1 -lvl 3 -x 790 -y 210 -defaultsOSRD
preplace port M08_AXI -pg 1 -lvl 3 -x 790 -y 310 -defaultsOSRD
preplace port M12_AXI -pg 1 -lvl 3 -x 790 -y 370 -defaultsOSRD
preplace port S00_AXI -pg 1 -lvl 0 -x 0 -y 230 -defaultsOSRD
preplace port port-id_reset -pg 1 -lvl 0 -x 0 -y 540 -defaultsOSRD
preplace port port-id_clk_out2 -pg 1 -lvl 3 -x 790 -y 670 -defaultsOSRD
preplace port port-id_clk_freerun1 -pg 1 -lvl 3 -x 790 -y 170 -defaultsOSRD
preplace port port-id_clk_in1 -pg 1 -lvl 0 -x 0 -y 560 -defaultsOSRD
preplace port port-id_iic2intc_irpt -pg 1 -lvl 3 -x 790 -y 590 -defaultsOSRD
preplace port port-id_ip2intc_irpt -pg 1 -lvl 3 -x 790 -y 930 -defaultsOSRD
preplace portBus Res -pg 1 -lvl 3 -x 790 -y 1240 -defaultsOSRD
preplace portBus gpio_io_o -pg 1 -lvl 3 -x 790 -y 1080 -defaultsOSRD
preplace portBus gpio_io_o1 -pg 1 -lvl 3 -x 790 -y 110 -defaultsOSRD
preplace portBus peripheral_aresetn -pg 1 -lvl 3 -x 790 -y 1150 -defaultsOSRD
preplace portBus peripheral_aresetn1 -pg 1 -lvl 3 -x 790 -y 830 -defaultsOSRD
preplace portBus gpio_io_o2 -pg 1 -lvl 3 -x 790 -y 760 -defaultsOSRD
preplace inst axi_gpio_0 -pg 1 -lvl 2 -x 630 -y 100 -defaultsOSRD
preplace inst axi_gpio_2 -pg 1 -lvl 2 -x 630 -y 1070 -defaultsOSRD
preplace inst axi_gpio_3 -pg 1 -lvl 2 -x 630 -y 450 -defaultsOSRD
preplace inst axi_iic_0 -pg 1 -lvl 2 -x 630 -y 590 -defaultsOSRD
preplace inst axi_quad_spi_0 -pg 1 -lvl 2 -x 630 -y 920 -defaultsOSRD
preplace inst proc_sys_reset_0 -pg 1 -lvl 1 -x 230 -y 560 -defaultsOSRD
preplace inst proc_sys_reset_1 -pg 1 -lvl 1 -x 230 -y 760 -defaultsOSRD
preplace inst util_vector_logic_4 -pg 1 -lvl 1 -x 230 -y 1260 -defaultsOSRD
preplace inst xpm_cdc_gen_0 -pg 1 -lvl 2 -x 630 -y 1240 -defaultsOSRD
preplace inst axi_smartconnect_0 -pg 1 -lvl 1 -x 230 -y 270 -defaultsOSRD
preplace inst clkx5_wiz_0 -pg 1 -lvl 1 -x 230 -y 910 -defaultsOSRD
preplace inst axi_gpio_slice -pg 1 -lvl 2 -x 630 -y 750 -defaultsOSRD
preplace netloc axi_gpio_0_gpio_io_o 1 2 1 NJ 110
preplace netloc axi_gpio_2_gpio_io_o 1 0 3 60 1160 NJ 1160 770
preplace netloc axi_gpio_slice_gpio_io_o 1 2 1 NJ 760
preplace netloc axi_iic_0_iic2intc_irpt 1 2 1 NJ 590
preplace netloc axi_quad_spi_0_ip2intc_irpt 1 2 1 NJ 930
preplace netloc clk_in1_1 1 0 1 30 310n
preplace netloc clkx5_wiz_1_clk_out1 1 0 3 50 450 460 180 770J
preplace netloc clkx5_wiz_1_clk_out2 1 0 3 40 660 400 670 NJ
preplace netloc ext_reset_in_0_1 1 0 1 20 540n
preplace netloc proc_sys_reset_0_peripheral_aresetn 1 0 3 60 460 480 1150 NJ
preplace netloc proc_sys_reset_1_peripheral_aresetn 1 1 2 490 830 NJ
preplace netloc util_vector_logic_4_Res 1 1 1 NJ 1260
preplace netloc xpm_cdc_gen_0_dest_out 1 2 1 NJ 1240
preplace netloc Conn1 1 2 1 NJ 570
preplace netloc Conn2 1 2 1 NJ 450
preplace netloc Conn3 1 2 1 NJ 910
preplace netloc Conn4 1 0 1 NJ 230
preplace netloc Conn6 1 1 2 410J 20 NJ
preplace netloc Conn7 1 1 2 490J 190 NJ
preplace netloc Conn8 1 1 2 NJ 210 NJ
preplace netloc Conn9 1 1 2 NJ 310 NJ
preplace netloc Conn15 1 1 2 NJ 330 NJ
preplace netloc Conn16 1 1 2 NJ 350 NJ
preplace netloc Conn17 1 1 2 470J 370 NJ
preplace netloc axi_smartconnect_0_M02_AXI 1 1 1 420 80n
preplace netloc axi_smartconnect_0_M04_AXI 1 1 1 430 230n
preplace netloc axi_smartconnect_0_M05_AXI 1 1 1 420 250n
preplace netloc axi_smartconnect_0_M06_AXI 1 1 1 450 270n
preplace netloc axi_smartconnect_0_M07_AXI 1 1 1 440 290n
preplace netloc axi_smartconnect_0_M11_AXI 1 1 1 410 370n
levelinfo -pg 1 0 230 630 790
pagesize -pg 1 -db -bbox -sgen -100 0 1020 1310
"
}

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: Tx_Heir
proc create_hier_cell_Tx_Heir { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_Tx_Heir() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_DATA

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_CTRL

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_CTRL1

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_TX

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_CTRL_SB_TX

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_STS_SB_TX

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_mm_video1

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_CTRL2


  # Create pins
  create_bd_pin -dir O -type intr interrupt
  create_bd_pin -dir I -type rst s_axi_arstn
  create_bd_pin -dir O -type intr sdi_tx_irq
  create_bd_pin -dir I -type rst sdi_tx_rst
  create_bd_pin -dir I -type rst video_in_arstn
  create_bd_pin -dir I -type clk video_in_clk
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type clk sdi_tx_clk
  create_bd_pin -dir O -type intr interrupt1
  create_bd_pin -dir I -from 3 -to 0 Din
  create_bd_pin -dir I fid

  # Create instance: v_uhdsdi_audio_Embed, and set properties
  set v_uhdsdi_audio_Embed [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_uhdsdi_audio v_uhdsdi_audio_Embed ]
  set_property -dict [list \
    CONFIG.C_AUDIO_FUNCTION {Embed} \
    CONFIG.C_MAX_AUDIO_CHANNELS {32} \
  ] $v_uhdsdi_audio_Embed


  # Create instance: v_smpte_uhdsdi_tx_ss_0, and set properties
  set v_smpte_uhdsdi_tx_ss_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_smpte_uhdsdi_tx_ss v_smpte_uhdsdi_tx_ss_0 ]
  set_property -dict [list \
    CONFIG.C_BPP {12} \
    CONFIG.C_DYNAMIC_BPP_CHANGE {true} \
    CONFIG.C_INCLUDE_ADV_FEATURES {true} \
  ] $v_smpte_uhdsdi_tx_ss_0


  # Create instance: ilslice_1, and set properties
  set ilslice_1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice ilslice_1 ]
  set_property -dict [list \
    CONFIG.DIN_TO {1} \
    CONFIG.DIN_WIDTH {4} \
  ] $ilslice_1


  # Create instance: v_frmbuf_rd_0, and set properties
  set v_frmbuf_rd_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_frmbuf_rd v_frmbuf_rd_0 ]
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
    CONFIG.MAX_DATA_WIDTH {12} \
  ] $v_frmbuf_rd_0


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins v_smpte_uhdsdi_tx_ss_0/M_AXIS_TX] [get_bd_intf_pins M_AXIS_TX]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins v_smpte_uhdsdi_tx_ss_0/M_AXIS_CTRL_SB_TX] [get_bd_intf_pins M_AXIS_CTRL_SB_TX]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins v_smpte_uhdsdi_tx_ss_0/S_AXIS_STS_SB_TX] [get_bd_intf_pins S_AXIS_STS_SB_TX]
  connect_bd_intf_net -intf_net S_AXI_CTRL1_1 [get_bd_intf_pins S_AXI_CTRL1] [get_bd_intf_pins v_smpte_uhdsdi_tx_ss_0/S_AXI_CTRL]
  connect_bd_intf_net -intf_net axis_data_fifo_1_M_AXIS [get_bd_intf_pins S_AXIS_DATA] [get_bd_intf_pins v_uhdsdi_audio_Embed/S_AXIS_DATA]
  connect_bd_intf_net -intf_net s_axi_CTRL2_1 [get_bd_intf_pins s_axi_CTRL2] [get_bd_intf_pins v_frmbuf_rd_0/s_axi_CTRL]
  connect_bd_intf_net -intf_net smartconnect_1_M10_AXI [get_bd_intf_pins S_AXI_CTRL] [get_bd_intf_pins v_uhdsdi_audio_Embed/S_AXI_CTRL]
  connect_bd_intf_net -intf_net v_frmbuf_rd_0_m_axi_mm_video [get_bd_intf_pins m_axi_mm_video1] [get_bd_intf_pins v_frmbuf_rd_0/m_axi_mm_video]
  connect_bd_intf_net -intf_net v_frmbuf_rd_0_m_axis_video [get_bd_intf_pins v_smpte_uhdsdi_tx_ss_0/VIDEO_IN] [get_bd_intf_pins v_frmbuf_rd_0/m_axis_video]
  connect_bd_intf_net -intf_net v_smpte_uhdsdi_tx_ss_0_SDI_TX_ANC_DS_OUT [get_bd_intf_pins v_smpte_uhdsdi_tx_ss_0/SDI_TX_ANC_DS_OUT] [get_bd_intf_pins v_uhdsdi_audio_Embed/SDI_EMBED_ANC_DS_IN]
  connect_bd_intf_net -intf_net v_uhdsdi_audio_Embed_SDI_EMBED_ANC_DS_OUT [get_bd_intf_pins v_uhdsdi_audio_Embed/SDI_EMBED_ANC_DS_OUT] [get_bd_intf_pins v_smpte_uhdsdi_tx_ss_0/SDI_TX_ANC_DS_IN]

  # Create port connections
  connect_bd_net -net Din_1  [get_bd_pins Din] \
  [get_bd_pins ilslice_1/Din]
  connect_bd_net -net axi_gpio_2_gpio_io_o  [get_bd_pins sdi_tx_rst] \
  [get_bd_pins v_uhdsdi_audio_Embed/sdi_embed_reset] \
  [get_bd_pins v_smpte_uhdsdi_tx_ss_0/sdi_tx_rst]
  connect_bd_net -net clk_wizard_0_clk_out2  [get_bd_pins video_in_clk] \
  [get_bd_pins v_uhdsdi_audio_Embed/s_axis_clk] \
  [get_bd_pins v_smpte_uhdsdi_tx_ss_0/video_in_clk] \
  [get_bd_pins v_frmbuf_rd_0/ap_clk]
  connect_bd_net -net fid_1  [get_bd_pins fid] \
  [get_bd_pins v_smpte_uhdsdi_tx_ss_0/fid]
  connect_bd_net -net ilslice_1_Dout  [get_bd_pins ilslice_1/Dout] \
  [get_bd_pins v_frmbuf_rd_0/ap_rst_n]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn  [get_bd_pins s_axi_arstn] \
  [get_bd_pins v_uhdsdi_audio_Embed/s_axi_aresetn] \
  [get_bd_pins v_smpte_uhdsdi_tx_ss_0/s_axi_arstn]
  connect_bd_net -net proc_sys_reset_1_peripheral_aresetn  [get_bd_pins video_in_arstn] \
  [get_bd_pins v_uhdsdi_audio_Embed/s_axis_resetn] \
  [get_bd_pins v_smpte_uhdsdi_tx_ss_0/video_in_arstn]
  connect_bd_net -net s_axi_aclk_1  [get_bd_pins s_axi_aclk] \
  [get_bd_pins v_smpte_uhdsdi_tx_ss_0/s_axi_aclk] \
  [get_bd_pins v_uhdsdi_audio_Embed/s_axi_aclk]
  connect_bd_net -net sdi_tx_clk_1  [get_bd_pins sdi_tx_clk] \
  [get_bd_pins v_smpte_uhdsdi_tx_ss_0/sdi_tx_clk] \
  [get_bd_pins v_uhdsdi_audio_Embed/sdi_embed_clk]
  connect_bd_net -net v_frmbuf_rd_0_interrupt  [get_bd_pins v_frmbuf_rd_0/interrupt] \
  [get_bd_pins interrupt1]
  connect_bd_net -net v_smpte_uhdsdi_tx_ss_0_sdi_tx_anc_ctrl_out  [get_bd_pins v_smpte_uhdsdi_tx_ss_0/sdi_tx_anc_ctrl_out] \
  [get_bd_pins v_uhdsdi_audio_Embed/sdi_embed_anc_ctrl_in]
  connect_bd_net -net v_smpte_uhdsdi_tx_ss_0_sdi_tx_irq  [get_bd_pins v_smpte_uhdsdi_tx_ss_0/sdi_tx_irq] \
  [get_bd_pins sdi_tx_irq]
  connect_bd_net -net v_uhdsdi_audio_1_interrupt  [get_bd_pins v_uhdsdi_audio_Embed/interrupt] \
  [get_bd_pins interrupt]

  # Perform GUI Layout
  regenerate_bd_layout -hierarchy [get_bd_cells /sdi/Tx_Heir] -layout_string {
   "ActiveEmotionalView":"Default View",
   "Default View_ScaleFactor":"1.0",
   "Default View_TopLeft":"-328,-127",
   "ExpandedHierarchyInLayout":"",
   "guistr":"# # String gsaved with Nlview 7.8.0 2024-04-26 e1825d835c VDI=44 GEI=38 GUI=JA:24.0 TLS
#  -string -flagsOSRD
preplace port S_AXIS_DATA -pg 1 -lvl 0 -x 0 -y 330 -defaultsOSRD
preplace port S_AXI_CTRL -pg 1 -lvl 0 -x 0 -y 300 -defaultsOSRD
preplace port S_AXI_CTRL1 -pg 1 -lvl 0 -x 0 -y 50 -defaultsOSRD
preplace port M_AXIS_TX -pg 1 -lvl 4 -x 1160 -y 190 -defaultsOSRD
preplace port M_AXIS_CTRL_SB_TX -pg 1 -lvl 4 -x 1160 -y 220 -defaultsOSRD
preplace port S_AXIS_STS_SB_TX -pg 1 -lvl 0 -x 0 -y 20 -defaultsOSRD
preplace port m_axi_mm_video1 -pg 1 -lvl 4 -x 1160 -y 70 -defaultsOSRD
preplace port s_axi_CTRL2 -pg 1 -lvl 0 -x 0 -y 120 -defaultsOSRD
preplace port port-id_interrupt -pg 1 -lvl 4 -x 1160 -y 410 -defaultsOSRD
preplace port port-id_s_axi_arstn -pg 1 -lvl 0 -x 0 -y 390 -defaultsOSRD
preplace port port-id_sdi_tx_irq -pg 1 -lvl 4 -x 1160 -y 280 -defaultsOSRD
preplace port port-id_sdi_tx_rst -pg 1 -lvl 0 -x 0 -y 480 -defaultsOSRD
preplace port port-id_video_in_arstn -pg 1 -lvl 0 -x 0 -y 420 -defaultsOSRD
preplace port port-id_video_in_clk -pg 1 -lvl 0 -x 0 -y 150 -defaultsOSRD
preplace port port-id_s_axi_aclk -pg 1 -lvl 0 -x 0 -y 360 -defaultsOSRD
preplace port port-id_sdi_tx_clk -pg 1 -lvl 0 -x 0 -y 450 -defaultsOSRD
preplace port port-id_interrupt1 -pg 1 -lvl 4 -x 1160 -y 100 -defaultsOSRD
preplace port port-id_fid -pg 1 -lvl 0 -x 0 -y 80 -defaultsOSRD
preplace portBus Din -pg 1 -lvl 0 -x 0 -y 210 -defaultsOSRD
preplace inst v_uhdsdi_audio_Embed -pg 1 -lvl 2 -x 490 -y 400 -defaultsOSRD
preplace inst v_smpte_uhdsdi_tx_ss_0 -pg 1 -lvl 3 -x 950 -y 250 -defaultsOSRD
preplace inst ilslice_1 -pg 1 -lvl 1 -x 120 -y 210 -defaultsOSRD
preplace inst v_frmbuf_rd_0 -pg 1 -lvl 2 -x 490 -y 140 -defaultsOSRD
preplace netloc Din_1 1 0 1 NJ 210
preplace netloc axi_gpio_2_gpio_io_o 1 0 3 NJ 480 280 560 740J
preplace netloc clk_wizard_0_clk_out2 1 0 3 NJ 150 260 550 750J
preplace netloc fid_1 1 0 3 NJ 80 250J 60 730J
preplace netloc ilslice_1_Dout 1 1 1 230J 160n
preplace netloc proc_sys_reset_0_peripheral_aresetn 1 0 3 NJ 390 270 250 690J
preplace netloc proc_sys_reset_1_peripheral_aresetn 1 0 3 NJ 420 230 570 760J
preplace netloc s_axi_aclk_1 1 0 3 NJ 360 280 240 700J
preplace netloc sdi_tx_clk_1 1 0 3 NJ 450 240 230 NJ
preplace netloc v_frmbuf_rd_0_interrupt 1 2 2 700J 80 1140J
preplace netloc v_smpte_uhdsdi_tx_ss_0_sdi_tx_anc_ctrl_out 1 1 3 290 580 NJ 580 1130
preplace netloc v_smpte_uhdsdi_tx_ss_0_sdi_tx_irq 1 3 1 NJ 280
preplace netloc v_uhdsdi_audio_1_interrupt 1 2 2 690J 410 NJ
preplace netloc Conn1 1 3 1 1140J 190n
preplace netloc Conn2 1 3 1 NJ 220
preplace netloc Conn3 1 0 3 NJ 20 NJ 20 760J
preplace netloc S_AXI_CTRL1_1 1 0 3 NJ 50 NJ 50 750J
preplace netloc axis_data_fifo_1_M_AXIS 1 0 2 NJ 330 NJ
preplace netloc s_axi_CTRL2_1 1 0 2 NJ 120 NJ
preplace netloc smartconnect_1_M10_AXI 1 0 2 NJ 300 250J
preplace netloc v_frmbuf_rd_0_m_axi_mm_video 1 2 2 690J 70 NJ
preplace netloc v_frmbuf_rd_0_m_axis_video 1 2 1 740 140n
preplace netloc v_smpte_uhdsdi_tx_ss_0_SDI_TX_ANC_DS_OUT 1 1 3 290 220 710J 90 1130
preplace netloc v_uhdsdi_audio_Embed_SDI_EMBED_ANC_DS_OUT 1 2 1 720 210n
levelinfo -pg 1 0 120 490 950 1160
pagesize -pg 1 -db -bbox -sgen -170 0 1350 590
"
}

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: sdi
proc create_hier_cell_sdi { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_sdi() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 gt_refclk

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 GT_Serial_0

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M00_INI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M01_INI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 gt_refclk2

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 fzetton_fmc_gpio

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 fzetton_fmc_iic

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:spi_rtl:1.0 fzetton_fmc_spi

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI


  # Create pins
  create_bd_pin -dir O -type clk clk_rxusrclk
  create_bd_pin -dir I -from 31 -to 0 QUAD0_gpi_0
  create_bd_pin -dir O -from 31 -to 0 QUAD0_gpo_0
  create_bd_pin -dir O -type gt_usrclk clk_txusrclk
  create_bd_pin -dir I -type rst reset
  create_bd_pin -dir I -type clk clk_in1
  create_bd_pin -dir O -type intr irq

  # Create instance: bufg_gt, and set properties
  set bufg_gt [ create_bd_cell -type ip -vlnv xilinx.com:ip:bufg_gt bufg_gt ]

  # Create instance: v_vid_gt_bridge_rx, and set properties
  set v_vid_gt_bridge_rx [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_vid_gt_bridge v_vid_gt_bridge_rx ]
  set_property -dict [list \
    CONFIG.C_GT_DIRECTION {SIMPLEX_RX} \
    CONFIG.GT_TYPE {GTYP} \
    CONFIG.c_protocol {1} \
  ] $v_vid_gt_bridge_rx


  # Create instance: util_ds_buf_1, and set properties
  set util_ds_buf_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf util_ds_buf_1 ]
  set_property CONFIG.C_BUF_TYPE {IBUFDSGTE} $util_ds_buf_1


  # Create instance: gtwiz_versal_0, and set properties
  set gtwiz_versal_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:gtwiz_versal gtwiz_versal_0 ]
  set_property -dict [list \
    CONFIG.INTF0_GT_DIRECTION {SIMPLEX_TX} \
    CONFIG.INTF0_GT_SETTINGS(GT_DIRECTION) {SIMPLEX_TX} \
    CONFIG.INTF0_GT_SETTINGS(GT_TYPE) {GTYP} \
    CONFIG.INTF0_GT_SETTINGS(LR0_SETTINGS) {TX_LINE_RATE 11.88 TX_PLL_TYPE RPLL TX_REFCLK_FREQUENCY 148.5 TX_DATA_ENCODING RAW TX_USER_DATA_WIDTH 40 TX_INT_DATA_WIDTH 40 TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE\
TXOUTCLKPMA TX_REFCLK_SOURCE R0 TX_PIPM_ENABLE false} \
    CONFIG.INTF0_GT_SETTINGS(LR1_SETTINGS) {TX_LINE_RATE 11.868 TX_PLL_TYPE RPLL TX_REFCLK_FREQUENCY 148.35 TX_DATA_ENCODING RAW TX_USER_DATA_WIDTH 40 TX_INT_DATA_WIDTH 40 TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE\
TXOUTCLKPMA TX_REFCLK_SOURCE R1 TX_PIPM_ENABLE false} \
    CONFIG.INTF0_GT_SETTINGS(LR2_SETTINGS) {TX_LINE_RATE 5.94 TX_PLL_TYPE RPLL TX_REFCLK_FREQUENCY 148.5 TX_DATA_ENCODING RAW TX_USER_DATA_WIDTH 40 TX_INT_DATA_WIDTH 40 TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE\
TXOUTCLKPMA TX_REFCLK_SOURCE R0 TX_PIPM_ENABLE false} \
    CONFIG.INTF0_GT_SETTINGS(LR3_SETTINGS) {TX_LINE_RATE 5.934 TX_PLL_TYPE RPLL TX_REFCLK_FREQUENCY 148.35 TX_DATA_ENCODING RAW TX_USER_DATA_WIDTH 40 TX_INT_DATA_WIDTH 40 TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE\
TXOUTCLKPMA TX_REFCLK_SOURCE R1 TX_PIPM_ENABLE false} \
    CONFIG.INTF0_GT_SETTINGS(LR4_SETTINGS) {TX_LINE_RATE 2.97 TX_PLL_TYPE RPLL TX_REFCLK_FREQUENCY 148.5 TX_DATA_ENCODING RAW TX_USER_DATA_WIDTH 20 TX_INT_DATA_WIDTH 20 TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE\
TXOUTCLKPMA TX_REFCLK_SOURCE R0 TX_PIPM_ENABLE false} \
    CONFIG.INTF0_GT_SETTINGS(LR5_SETTINGS) {TX_LINE_RATE 2.967 TX_PLL_TYPE RPLL TX_REFCLK_FREQUENCY 148.35 TX_DATA_ENCODING RAW TX_USER_DATA_WIDTH 20 TX_INT_DATA_WIDTH 20 TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE\
TXOUTCLKPMA TX_REFCLK_SOURCE R1 TX_PIPM_ENABLE false} \
    CONFIG.INTF0_GT_SETTINGS(LR6_SETTINGS) {TX_LINE_RATE 1.485 TX_PLL_TYPE RPLL TX_REFCLK_FREQUENCY 148.5 TX_DATA_ENCODING RAW TX_USER_DATA_WIDTH 20 TX_INT_DATA_WIDTH 20 TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE\
TXOUTCLKPMA TX_REFCLK_SOURCE R0 TX_PIPM_ENABLE false} \
    CONFIG.INTF0_GT_SETTINGS(LR7_SETTINGS) {TX_LINE_RATE 1.4835 TX_PLL_TYPE RPLL TX_REFCLK_FREQUENCY 148.35 TX_DATA_ENCODING RAW TX_USER_DATA_WIDTH 20 TX_INT_DATA_WIDTH 20 TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE\
TXOUTCLKPMA TX_REFCLK_SOURCE R1 TX_PIPM_ENABLE false} \
    CONFIG.INTF0_GT_SETTINGS(LR8_SETTINGS) {TX_LINE_RATE 2.97 TX_PLL_TYPE RPLL TX_REFCLK_FREQUENCY 148.5 TX_DATA_ENCODING RAW TX_USER_DATA_WIDTH 20 TX_INT_DATA_WIDTH 20 TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE\
TXOUTCLKPMA TX_REFCLK_SOURCE R0 TX_PIPM_ENABLE false} \
    CONFIG.INTF0_GT_SETTINGS(LR9_SETTINGS) {TX_LINE_RATE 2.967 TX_PLL_TYPE RPLL TX_REFCLK_FREQUENCY 148.35 TX_DATA_ENCODING RAW TX_USER_DATA_WIDTH 20 TX_INT_DATA_WIDTH 20 TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE\
TXOUTCLKPMA TX_REFCLK_SOURCE R1 TX_PIPM_ENABLE false} \
    CONFIG.INTF0_NO_OF_LANES {1} \
    CONFIG.INTF0_PARENTID {edf_base_v_vid_gt_bridge_tx_0} \
    CONFIG.INTF1_GT_DIRECTION {SIMPLEX_RX} \
    CONFIG.INTF1_GT_SETTINGS(GT_DIRECTION) {SIMPLEX_RX} \
    CONFIG.INTF1_GT_SETTINGS(GT_TYPE) {GTYP} \
    CONFIG.INTF1_GT_SETTINGS(LR0_SETTINGS) {RX_LINE_RATE 11.88 RX_PLL_TYPE LCPLL RX_REFCLK_FREQUENCY 148.5 RX_DATA_DECODING RAW RX_USER_DATA_WIDTH 40 RX_INT_DATA_WIDTH 40 RX_BUFFER_MODE 1 RX_OUTCLK_SOURCE\
RXOUTCLKPMA RX_PPM_OFFSET 1200 INS_LOSS_NYQ 20 RX_REFCLK_SOURCE R0 RX_TERMINATION_PROG_VALUE 800} \
    CONFIG.INTF1_GT_SETTINGS(LR1_SETTINGS) {RX_LINE_RATE 11.868 RX_PLL_TYPE LCPLL RX_REFCLK_FREQUENCY 148.35 RX_DATA_DECODING RAW RX_USER_DATA_WIDTH 40 RX_INT_DATA_WIDTH 40 RX_BUFFER_MODE 1 RX_OUTCLK_SOURCE\
RXOUTCLKPMA RX_PPM_OFFSET 1200 INS_LOSS_NYQ 20 RX_REFCLK_SOURCE R1 RX_TERMINATION_PROG_VALUE 800} \
    CONFIG.INTF1_GT_SETTINGS(LR2_SETTINGS) {RX_LINE_RATE 5.94 RX_PLL_TYPE LCPLL RX_REFCLK_FREQUENCY 148.5 RX_DATA_DECODING RAW RX_USER_DATA_WIDTH 40 RX_INT_DATA_WIDTH 40 RX_BUFFER_MODE 1 RX_OUTCLK_SOURCE\
RXOUTCLKPMA RX_PPM_OFFSET 1200 INS_LOSS_NYQ 20 RX_REFCLK_SOURCE R0 RX_TERMINATION_PROG_VALUE 800} \
    CONFIG.INTF1_GT_SETTINGS(LR3_SETTINGS) {RX_LINE_RATE 5.934 RX_PLL_TYPE LCPLL RX_REFCLK_FREQUENCY 148.35 RX_DATA_DECODING RAW RX_USER_DATA_WIDTH 40 RX_INT_DATA_WIDTH 40 RX_BUFFER_MODE 1 RX_OUTCLK_SOURCE\
RXOUTCLKPMA RX_PPM_OFFSET 1200 INS_LOSS_NYQ 20 RX_REFCLK_SOURCE R1 RX_TERMINATION_PROG_VALUE 800} \
    CONFIG.INTF1_GT_SETTINGS(LR4_SETTINGS) {RX_LINE_RATE 2.97 RX_PLL_TYPE LCPLL RX_REFCLK_FREQUENCY 148.5 RX_DATA_DECODING RAW RX_USER_DATA_WIDTH 20 RX_INT_DATA_WIDTH 20 RX_BUFFER_MODE 1 RX_OUTCLK_SOURCE\
RXOUTCLKPMA RX_PPM_OFFSET 1200 INS_LOSS_NYQ 20 RX_REFCLK_SOURCE R0 RX_TERMINATION_PROG_VALUE 800} \
    CONFIG.INTF1_GT_SETTINGS(LR5_SETTINGS) {RX_LINE_RATE 2.967 RX_PLL_TYPE LCPLL RX_REFCLK_FREQUENCY 148.35 RX_DATA_DECODING RAW RX_USER_DATA_WIDTH 20 RX_INT_DATA_WIDTH 20 RX_BUFFER_MODE 1 RX_OUTCLK_SOURCE\
RXOUTCLKPMA RX_PPM_OFFSET 1200 INS_LOSS_NYQ 20 RX_REFCLK_SOURCE R1 RX_TERMINATION_PROG_VALUE 800} \
    CONFIG.INTF1_GT_SETTINGS(LR6_SETTINGS) {RX_LINE_RATE 1.485 RX_PLL_TYPE LCPLL RX_REFCLK_FREQUENCY 148.5 RX_DATA_DECODING RAW RX_USER_DATA_WIDTH 20 RX_INT_DATA_WIDTH 20 RX_BUFFER_MODE 1 RX_OUTCLK_SOURCE\
RXOUTCLKPMA RX_PPM_OFFSET 1200 INS_LOSS_NYQ 20 RX_REFCLK_SOURCE R0 RX_TERMINATION_PROG_VALUE 800} \
    CONFIG.INTF1_GT_SETTINGS(LR7_SETTINGS) {RX_LINE_RATE 1.4835 RX_PLL_TYPE LCPLL RX_REFCLK_FREQUENCY 148.35 RX_DATA_DECODING RAW RX_USER_DATA_WIDTH 20 RX_INT_DATA_WIDTH 20 RX_BUFFER_MODE 1 RX_OUTCLK_SOURCE\
RXOUTCLKPMA RX_PPM_OFFSET 1200 INS_LOSS_NYQ 20 RX_REFCLK_SOURCE R1 RX_TERMINATION_PROG_VALUE 800} \
    CONFIG.INTF1_GT_SETTINGS(LR8_SETTINGS) {RX_LINE_RATE 2.97 RX_PLL_TYPE LCPLL RX_REFCLK_FREQUENCY 148.5 RX_DATA_DECODING RAW RX_USER_DATA_WIDTH 20 RX_INT_DATA_WIDTH 20 RX_BUFFER_MODE 1 RX_OUTCLK_SOURCE\
RXOUTCLKPMA RX_PPM_OFFSET 1200 INS_LOSS_NYQ 20 RX_REFCLK_SOURCE R0 RX_TERMINATION_PROG_VALUE 800} \
    CONFIG.INTF1_GT_SETTINGS(LR9_SETTINGS) {RX_LINE_RATE 2.967 RX_PLL_TYPE LCPLL RX_REFCLK_FREQUENCY 148.35 RX_DATA_DECODING RAW RX_USER_DATA_WIDTH 20 RX_INT_DATA_WIDTH 20 RX_BUFFER_MODE 1 RX_OUTCLK_SOURCE\
RXOUTCLKPMA RX_PPM_OFFSET 1200 INS_LOSS_NYQ 20 RX_REFCLK_SOURCE R1 RX_TERMINATION_PROG_VALUE 800} \
    CONFIG.INTF1_PARENTID {edf_base_v_vid_gt_bridge_rx_0} \
    CONFIG.INTF_PARENT_PIN_LIST {QUAD0_TX0 /sdi/v_vid_gt_bridge_tx/GT_TX0 QUAD0_RX0 /sdi/v_vid_gt_bridge_rx/GT_RX0} \
    CONFIG.IS_PL_GTS_AVAILABLE {true} \
    CONFIG.NO_OF_INTERFACE {2} \
    CONFIG.QUAD0_NO_PROT {2} \
    CONFIG.QUAD0_PROT0_LANES {1} \
    CONFIG.QUAD0_PROT0_TX0_EN {true} \
    CONFIG.QUAD0_PROT0_TX1_EN {false} \
    CONFIG.QUAD0_PROT0_TX2_EN {false} \
    CONFIG.QUAD0_PROT0_TX3_EN {false} \
    CONFIG.QUAD0_PROT0_TXMSTCLK {TX0} \
    CONFIG.QUAD0_PROT1_RX0_EN {true} \
    CONFIG.QUAD0_PROT1_RXMSTCLK {RX0} \
    CONFIG.QUAD0_REFCLK_STRING {HSCLK0_LCPLLGTREFCLK0 refclk_PROT1_R0_148.5_MHz_unique1 HSCLK0_LCPLLGTREFCLK1 refclk_PROT1_R1_148.35_MHz_unique1 HSCLK0_RPLLGTREFCLK0 refclk_PROT0_R0_148.5_MHz_unique1 HSCLK0_RPLLGTREFCLK1\
refclk_PROT0_R1_148.35_MHz_unique1} \
    CONFIG.QUAD0_USAGE {TX_QUAD_CH {TXQuad_0_/edf_base_gtwiz_versal_0_0/edf_base_gtwiz_versal_0_0_gt_quad_base_0 {/edf_base_gtwiz_versal_0_0/edf_base_gtwiz_versal_0_0_gt_quad_base_0 edf_base_v_vid_gt_bridge_tx_0.IP_CH0,undef,undef,undef\
MSTRCLK 1,0,0,0 IS_CURRENT_QUAD 1}} RX_QUAD_CH {RXQuad_0_/edf_base_gtwiz_versal_0_0/edf_base_gtwiz_versal_0_0_gt_quad_base_0 {/edf_base_gtwiz_versal_0_0/edf_base_gtwiz_versal_0_0_gt_quad_base_0 edf_base_v_vid_gt_bridge_rx_0.IP_CH0,undef,undef,undef\
MSTRCLK 1,0,0,0 IS_CURRENT_QUAD 1}}} \
  ] $gtwiz_versal_0

  set_property -dict [list \
    CONFIG.INTF0_GT_SETTINGS.VALUE_MODE {auto} \
    CONFIG.INTF0_PARENTID.VALUE_MODE {auto} \
    CONFIG.INTF1_GT_SETTINGS.VALUE_MODE {auto} \
    CONFIG.INTF1_PARENTID.VALUE_MODE {auto} \
    CONFIG.INTF_PARENT_PIN_LIST.VALUE_MODE {auto} \
    CONFIG.QUAD0_USAGE.VALUE_MODE {auto} \
  ] $gtwiz_versal_0


  # Create instance: bufg_gt_1, and set properties
  set bufg_gt_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:bufg_gt bufg_gt_1 ]

  # Create instance: axi_noc2_0, and set properties
  set axi_noc2_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc2 axi_noc2_0 ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {1} \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NMI {2} \
    CONFIG.NUM_SI {2} \
  ] $axi_noc2_0


  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS {M01_INI {read_bw {500} write_bw {500} } M00_INI {read_bw {500} write_bw {500} }} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins $axi_noc2_0/S00_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS {M01_INI {read_bw {500} write_bw {500} } M00_INI {read_bw {500} write_bw {500} }} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins $axi_noc2_0/S01_AXI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXI:S01_AXI} \
 ] [get_bd_pins $axi_noc2_0/aclk0]

  # Create instance: v_vid_gt_bridge_tx, and set properties
  set v_vid_gt_bridge_tx [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_vid_gt_bridge v_vid_gt_bridge_tx ]
  set_property -dict [list \
    CONFIG.C_GT_DIRECTION {SIMPLEX_TX} \
    CONFIG.c_protocol {1} \
  ] $v_vid_gt_bridge_tx


  # Create instance: util_ds_buf, and set properties
  set util_ds_buf [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf util_ds_buf ]
  set_property CONFIG.C_BUF_TYPE {IBUFDSGTE} $util_ds_buf


  # Create instance: ilconstant_1, and set properties
  set ilconstant_1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant ilconstant_1 ]
  set_property CONFIG.CONST_VAL {0} $ilconstant_1


  # Create instance: Tx_Heir
  create_hier_cell_Tx_Heir $hier_obj Tx_Heir

  # Create instance: peripheral_hier
  create_hier_cell_peripheral_hier $hier_obj peripheral_hier

  # Create instance: RX_Heir
  create_hier_cell_RX_Heir $hier_obj RX_Heir

  # Create instance: axi_intc_0, and set properties
  set axi_intc_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc axi_intc_0 ]
  set_property CONFIG.C_IRQ_CONNECTION {1} $axi_intc_0


  # Create instance: ilconcat_0, and set properties
  set ilconcat_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat ilconcat_0 ]
  set_property CONFIG.NUM_PORTS {8} $ilconcat_0


  # Create interface connections
  connect_bd_intf_net -intf_net Processor_Heir_M00_AXI_0 [get_bd_intf_pins peripheral_hier/M00_AXI_0] [get_bd_intf_pins RX_Heir/S_AXI_CTRL1]
  connect_bd_intf_net -intf_net Processor_Heir_M01_AXI_0 [get_bd_intf_pins peripheral_hier/M01_AXI_0] [get_bd_intf_pins Tx_Heir/S_AXI_CTRL]
  connect_bd_intf_net -intf_net Processor_Heir_M03_AXI [get_bd_intf_pins peripheral_hier/M03_AXI] [get_bd_intf_pins RX_Heir/s_axi_CTRL3]
  connect_bd_intf_net -intf_net Processor_Heir_M08_AXI [get_bd_intf_pins peripheral_hier/M08_AXI] [get_bd_intf_pins Tx_Heir/s_axi_CTRL2]
  connect_bd_intf_net -intf_net Processor_Heir_M09_AXI_0 [get_bd_intf_pins peripheral_hier/M09_AXI_0] [get_bd_intf_pins RX_Heir/S_AXI_CTRL]
  connect_bd_intf_net -intf_net Processor_Heir_M10_AXI_0 [get_bd_intf_pins peripheral_hier/M10_AXI_0] [get_bd_intf_pins Tx_Heir/S_AXI_CTRL1]
  connect_bd_intf_net -intf_net Processor_Heir_fzetton_fmc_gpio [get_bd_intf_pins fzetton_fmc_gpio] [get_bd_intf_pins peripheral_hier/fzetton_fmc_gpio]
  connect_bd_intf_net -intf_net Processor_Heir_fzetton_fmc_iic [get_bd_intf_pins fzetton_fmc_iic] [get_bd_intf_pins peripheral_hier/fzetton_fmc_iic]
  connect_bd_intf_net -intf_net Processor_Heir_fzetton_fmc_spi [get_bd_intf_pins fzetton_fmc_spi] [get_bd_intf_pins peripheral_hier/fzetton_fmc_spi]
  connect_bd_intf_net -intf_net RX_Heir_M_AXIS_CTRL_SB_RX [get_bd_intf_pins RX_Heir/M_AXIS_CTRL_SB_RX] [get_bd_intf_pins v_vid_gt_bridge_rx/SDI_RX_PHY_SB_CTRL]
  connect_bd_intf_net -intf_net RX_Heir_m_axi_mm_video [get_bd_intf_pins axi_noc2_0/S00_AXI] [get_bd_intf_pins RX_Heir/m_axi_mm_video]
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins S00_AXI] [get_bd_intf_pins peripheral_hier/S00_AXI]
  connect_bd_intf_net -intf_net S_AXIS_DATA_1 [get_bd_intf_pins Tx_Heir/S_AXIS_DATA] [get_bd_intf_pins RX_Heir/M_AXIS]
  connect_bd_intf_net -intf_net S_AXIS_RX_1 [get_bd_intf_pins RX_Heir/S_AXIS_RX] [get_bd_intf_pins v_vid_gt_bridge_rx/SDI_RX_AXI4S_CH0]
  connect_bd_intf_net -intf_net S_AXIS_STS_SB_RX_1 [get_bd_intf_pins RX_Heir/S_AXIS_STS_SB_RX] [get_bd_intf_pins v_vid_gt_bridge_rx/SDI_RX_PHY_SB_STS]
  connect_bd_intf_net -intf_net Tx_Heir_M_AXIS_CTRL_SB_TX [get_bd_intf_pins Tx_Heir/M_AXIS_CTRL_SB_TX] [get_bd_intf_pins v_vid_gt_bridge_tx/SDI_TX_PHY_SB_CTRL]
  connect_bd_intf_net -intf_net Tx_Heir_M_AXIS_TX [get_bd_intf_pins Tx_Heir/M_AXIS_TX] [get_bd_intf_pins v_vid_gt_bridge_tx/SDI_TX_AXI4S_CH0]
  connect_bd_intf_net -intf_net Tx_Heir_m_axi_mm_video1 [get_bd_intf_pins axi_noc2_0/S01_AXI] [get_bd_intf_pins Tx_Heir/m_axi_mm_video1]
  connect_bd_intf_net -intf_net axi_noc2_0_M00_INI [get_bd_intf_pins M00_INI] [get_bd_intf_pins axi_noc2_0/M00_INI]
  connect_bd_intf_net -intf_net axi_noc2_0_M01_INI [get_bd_intf_pins M01_INI] [get_bd_intf_pins axi_noc2_0/M01_INI]
  connect_bd_intf_net -intf_net gt_refclk2_1 [get_bd_intf_pins gt_refclk2] [get_bd_intf_pins util_ds_buf/CLK_IN_D]
  connect_bd_intf_net -intf_net gt_refclk_1 [get_bd_intf_pins gt_refclk] [get_bd_intf_pins util_ds_buf_1/CLK_IN_D]
  connect_bd_intf_net -intf_net gtwiz_versal_0_Quad0_GT_Serial [get_bd_intf_pins GT_Serial_0] [get_bd_intf_pins gtwiz_versal_0/Quad0_GT_Serial]
  connect_bd_intf_net -intf_net peripheral_hier_M12_AXI [get_bd_intf_pins axi_intc_0/s_axi] [get_bd_intf_pins peripheral_hier/M12_AXI]
  connect_bd_intf_net -intf_net peripheral_hier_M13_AXI [get_bd_intf_pins peripheral_hier/M13_AXI] [get_bd_intf_pins RX_Heir/s_axi_ctrl2]
  connect_bd_intf_net -intf_net v_vid_gt_bridge_rx_GT_RX0 [get_bd_intf_pins v_vid_gt_bridge_rx/GT_RX0] [get_bd_intf_pins gtwiz_versal_0/INTF1_RX0_GT_IP_Interface]
  connect_bd_intf_net -intf_net v_vid_gt_bridge_tx_GT_TX0 [get_bd_intf_pins v_vid_gt_bridge_tx/GT_TX0] [get_bd_intf_pins gtwiz_versal_0/INTF0_TX0_GT_IP_Interface]
  connect_bd_intf_net -intf_net v_vid_gt_bridge_tx_SDI_TX_PHY_SB_STS [get_bd_intf_pins v_vid_gt_bridge_tx/SDI_TX_PHY_SB_STS] [get_bd_intf_pins Tx_Heir/S_AXIS_STS_SB_TX]

  # Create port connections
  connect_bd_net -net Processor_Heir_gpio_io_o1  [get_bd_pins peripheral_hier/gpio_io_o1] \
  [get_bd_pins v_vid_gt_bridge_tx/sdi_gt_ctrl] \
  [get_bd_pins v_vid_gt_bridge_rx/sdi_gt_ctrl]
  connect_bd_net -net QUAD0_gpi_0_1  [get_bd_pins QUAD0_gpi_0] \
  [get_bd_pins gtwiz_versal_0/QUAD0_gpi]
  connect_bd_net -net RX_Heir_interrupt  [get_bd_pins RX_Heir/interrupt] \
  [get_bd_pins ilconcat_0/In0]
  connect_bd_net -net RX_Heir_interrupt1  [get_bd_pins RX_Heir/interrupt1] \
  [get_bd_pins ilconcat_0/In2]
  connect_bd_net -net RX_Heir_sdi_rx_irq  [get_bd_pins RX_Heir/sdi_rx_irq] \
  [get_bd_pins ilconcat_0/In1]
  connect_bd_net -net Tx_Heir_interrupt  [get_bd_pins Tx_Heir/interrupt] \
  [get_bd_pins ilconcat_0/In3]
  connect_bd_net -net Tx_Heir_interrupt1  [get_bd_pins Tx_Heir/interrupt1] \
  [get_bd_pins ilconcat_0/In5]
  connect_bd_net -net Tx_Heir_sdi_tx_irq  [get_bd_pins Tx_Heir/sdi_tx_irq] \
  [get_bd_pins ilconcat_0/In4]
  connect_bd_net -net axi_intc_0_irq  [get_bd_pins axi_intc_0/irq] \
  [get_bd_pins irq]
  connect_bd_net -net bufg_gt_1_usrclk  [get_bd_pins bufg_gt_1/usrclk] \
  [get_bd_pins clk_txusrclk] \
  [get_bd_pins Tx_Heir/sdi_tx_clk] \
  [get_bd_pins v_vid_gt_bridge_tx/gt_txusrclk] \
  [get_bd_pins gtwiz_versal_0/QUAD0_TX0_usrclk]
  connect_bd_net -net bufg_gt_usrclk  [get_bd_pins bufg_gt/usrclk] \
  [get_bd_pins clk_rxusrclk] \
  [get_bd_pins RX_Heir/sdi_rx_clk] \
  [get_bd_pins gtwiz_versal_0/QUAD0_RX0_usrclk] \
  [get_bd_pins v_vid_gt_bridge_rx/gt_rxusrclk]
  connect_bd_net -net clk_freerun  [get_bd_pins peripheral_hier/clk_freerun1] \
  [get_bd_pins Tx_Heir/s_axi_aclk] \
  [get_bd_pins RX_Heir/s_axi_aclk] \
  [get_bd_pins v_vid_gt_bridge_rx/clk_100mhz] \
  [get_bd_pins gtwiz_versal_0/gtwiz_freerun_clk] \
  [get_bd_pins v_vid_gt_bridge_tx/gt_ctrl_aclk] \
  [get_bd_pins v_vid_gt_bridge_tx/clk_100mhz] \
  [get_bd_pins v_vid_gt_bridge_rx/gt_ctrl_aclk] \
  [get_bd_pins axi_intc_0/s_axi_aclk]
  connect_bd_net -net clk_wizard_0_clk_out2  [get_bd_pins peripheral_hier/clk_out2] \
  [get_bd_pins RX_Heir/video_out_clk] \
  [get_bd_pins Tx_Heir/video_in_clk] \
  [get_bd_pins axi_noc2_0/aclk0]
  connect_bd_net -net fid_1  [get_bd_pins RX_Heir/fid] \
  [get_bd_pins Tx_Heir/fid]
  connect_bd_net -net gtwiz_versal_0_INTF0_TX_clrb_leaf_out  [get_bd_pins gtwiz_versal_0/INTF0_TX_clrb_leaf_out] \
  [get_bd_pins v_vid_gt_bridge_tx/tx_full_rst_done]
  connect_bd_net -net gtwiz_versal_0_INTF0_rst_tx_done_out  [get_bd_pins gtwiz_versal_0/INTF0_rst_tx_done_out] \
  [get_bd_pins v_vid_gt_bridge_rx/rx_full_rst_done]
  connect_bd_net -net gtwiz_versal_0_QUAD0_RX0_outclk  [get_bd_pins gtwiz_versal_0/QUAD0_RX0_outclk] \
  [get_bd_pins bufg_gt/outclk]
  connect_bd_net -net gtwiz_versal_0_QUAD0_TX0_outclk  [get_bd_pins gtwiz_versal_0/QUAD0_TX0_outclk] \
  [get_bd_pins bufg_gt_1/outclk]
  connect_bd_net -net gtwiz_versal_0_QUAD0_gpo  [get_bd_pins gtwiz_versal_0/QUAD0_gpo] \
  [get_bd_pins QUAD0_gpo_0]
  connect_bd_net -net gtwiz_versal_0_gtpowergood  [get_bd_pins gtwiz_versal_0/gtpowergood] \
  [get_bd_pins v_vid_gt_bridge_rx/gt_powergood] \
  [get_bd_pins v_vid_gt_bridge_tx/gt_powergood]
  connect_bd_net -net ilconcat_0_dout  [get_bd_pins ilconcat_0/dout] \
  [get_bd_pins axi_intc_0/intr]
  connect_bd_net -net peripheral_hier_gpio_io_o2  [get_bd_pins peripheral_hier/gpio_io_o2] \
  [get_bd_pins Tx_Heir/Din] \
  [get_bd_pins RX_Heir/Din]
  connect_bd_net -net peripheral_hier_iic2intc_irpt  [get_bd_pins peripheral_hier/iic2intc_irpt] \
  [get_bd_pins ilconcat_0/In6]
  connect_bd_net -net peripheral_hier_ip2intc_irpt  [get_bd_pins peripheral_hier/ip2intc_irpt] \
  [get_bd_pins ilconcat_0/In7]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn  [get_bd_pins peripheral_hier/peripheral_aresetn] \
  [get_bd_pins RX_Heir/s_axi_arstn] \
  [get_bd_pins Tx_Heir/s_axi_arstn] \
  [get_bd_pins v_vid_gt_bridge_tx/gt_ctrl_aresetn] \
  [get_bd_pins v_vid_gt_bridge_rx/gt_ctrl_aresetn] \
  [get_bd_pins axi_intc_0/s_axi_aresetn]
  connect_bd_net -net proc_sys_reset_1_peripheral_aresetn  [get_bd_pins peripheral_hier/peripheral_aresetn1] \
  [get_bd_pins RX_Heir/video_out_arstn] \
  [get_bd_pins Tx_Heir/video_in_arstn]
  connect_bd_net -net ps_wizard_0_pl0_ref_clk  [get_bd_pins clk_in1] \
  [get_bd_pins peripheral_hier/clk_in1]
  connect_bd_net -net reset_1  [get_bd_pins reset] \
  [get_bd_pins peripheral_hier/reset]
  connect_bd_net -net util_ds_buf_1_IBUF_OUT  [get_bd_pins util_ds_buf_1/IBUF_OUT] \
  [get_bd_pins gtwiz_versal_0/QUAD0_GTREFCLK1] \
  [get_bd_pins gtwiz_versal_0/QUAD0_GTREFCLK3]
  connect_bd_net -net util_ds_buf_IBUF_OUT  [get_bd_pins util_ds_buf/IBUF_OUT] \
  [get_bd_pins gtwiz_versal_0/QUAD0_GTREFCLK2] \
  [get_bd_pins gtwiz_versal_0/QUAD0_GTREFCLK0]
  connect_bd_net -net v_vid_gt_bridge_rx_reset_rx_datapath  [get_bd_pins v_vid_gt_bridge_rx/reset_rx_datapath] \
  [get_bd_pins gtwiz_versal_0/INTF1_rst_rx_datapath_in]
  connect_bd_net -net v_vid_gt_bridge_rx_reset_rx_pll_and_datapath  [get_bd_pins v_vid_gt_bridge_rx/reset_rx_pll_and_datapath] \
  [get_bd_pins gtwiz_versal_0/INTF1_rst_rx_pll_and_datapath_in]
  connect_bd_net -net v_vid_gt_bridge_rx_rx_full_rst  [get_bd_pins v_vid_gt_bridge_rx/rx_full_rst] \
  [get_bd_pins gtwiz_versal_0/INTF1_rst_all_in]
  connect_bd_net -net v_vid_gt_bridge_tx_reset_tx_datapath  [get_bd_pins v_vid_gt_bridge_tx/reset_tx_datapath] \
  [get_bd_pins gtwiz_versal_0/INTF0_rst_tx_datapath_in]
  connect_bd_net -net v_vid_gt_bridge_tx_reset_tx_pll_and_datapath  [get_bd_pins v_vid_gt_bridge_tx/reset_tx_pll_and_datapath] \
  [get_bd_pins gtwiz_versal_0/INTF0_rst_tx_pll_and_datapath_in]
  connect_bd_net -net v_vid_gt_bridge_tx_tx_full_rst  [get_bd_pins v_vid_gt_bridge_tx/tx_full_rst] \
  [get_bd_pins gtwiz_versal_0/INTF0_rst_all_in]
  connect_bd_net -net xlconstant_2_dout  [get_bd_pins ilconstant_1/dout] \
  [get_bd_pins RX_Heir/sdi_rx_rst] \
  [get_bd_pins Tx_Heir/sdi_tx_rst]

  # Perform GUI Layout
  regenerate_bd_layout -hierarchy [get_bd_cells /sdi] -layout_string {
   "ActiveEmotionalView":"Default View",
   "Default View_ScaleFactor":"2.95756",
   "Default View_TopLeft":"-151,349",
   "ExpandedHierarchyInLayout":"",
   "guistr":"# # String gsaved with Nlview 7.8.0 2024-04-26 e1825d835c VDI=44 GEI=38 GUI=JA:24.0 TLS
#  -string -flagsOSRD
preplace port gt_refclk -pg 1 -lvl 0 -x 0 -y 1700 -defaultsOSRD
preplace port GT_Serial_0 -pg 1 -lvl 6 -x 2520 -y 1020 -defaultsOSRD
preplace port M00_INI -pg 1 -lvl 6 -x 2520 -y 170 -defaultsOSRD
preplace port M01_INI -pg 1 -lvl 6 -x 2520 -y 200 -defaultsOSRD
preplace port gt_refclk2 -pg 1 -lvl 0 -x 0 -y 1160 -defaultsOSRD
preplace port fzetton_fmc_gpio -pg 1 -lvl 6 -x 2520 -y 380 -defaultsOSRD
preplace port fzetton_fmc_iic -pg 1 -lvl 6 -x 2520 -y 540 -defaultsOSRD
preplace port fzetton_fmc_spi -pg 1 -lvl 6 -x 2520 -y 570 -defaultsOSRD
preplace port S00_AXI -pg 1 -lvl 0 -x 0 -y 440 -defaultsOSRD
preplace port port-id_clk_rxusrclk -pg 1 -lvl 6 -x 2520 -y 1860 -defaultsOSRD
preplace port port-id_clk_txusrclk -pg 1 -lvl 6 -x 2520 -y 1830 -defaultsOSRD
preplace port port-id_reset -pg 1 -lvl 0 -x 0 -y 470 -defaultsOSRD
preplace port port-id_clk_in1 -pg 1 -lvl 0 -x 0 -y 500 -defaultsOSRD
preplace port port-id_irq -pg 1 -lvl 6 -x 2520 -y 470 -defaultsOSRD
preplace portBus QUAD0_gpi_0 -pg 1 -lvl 0 -x 0 -y 1130 -defaultsOSRD
preplace portBus QUAD0_gpo_0 -pg 1 -lvl 6 -x 2520 -y 860 -defaultsOSRD
preplace inst bufg_gt -pg 1 -lvl 4 -x 1740 -y 1550 -defaultsOSRD
preplace inst v_vid_gt_bridge_rx -pg 1 -lvl 1 -x 250 -y 970 -defaultsOSRD
preplace inst util_ds_buf_1 -pg 1 -lvl 4 -x 1740 -y 1710 -defaultsOSRD
preplace inst gtwiz_versal_0 -pg 1 -lvl 5 -x 2250 -y 1110 -defaultsOSRD
preplace inst bufg_gt_1 -pg 1 -lvl 4 -x 1740 -y 1330 -defaultsOSRD
preplace inst axi_noc2_0 -pg 1 -lvl 5 -x 2250 -y 180 -defaultsOSRD
preplace inst v_vid_gt_bridge_tx -pg 1 -lvl 4 -x 1740 -y 760 -defaultsOSRD
preplace inst util_ds_buf -pg 1 -lvl 4 -x 1740 -y 1170 -defaultsOSRD
preplace inst ilconstant_1 -pg 1 -lvl 1 -x 250 -y 740 -defaultsOSRD
preplace inst Tx_Heir -pg 1 -lvl 3 -x 1290 -y 190 -defaultsOSRD
preplace inst Picxo_Heir -pg 1 -lvl 4 -x 1740 -y 1040 -defaultsOSRD
preplace inst peripheral_hier -pg 1 -lvl 1 -x 250 -y 460 -defaultsOSRD
preplace inst RX_Heir -pg 1 -lvl 2 -x 830 -y 280 -defaultsOSRD
preplace inst axi_intc_0 -pg 1 -lvl 5 -x 2250 -y 470 -defaultsOSRD
preplace inst ilconcat_0 -pg 1 -lvl 4 -x 1740 -y 350 -defaultsOSRD
preplace netloc Picxo_Heir_ACC_DATA 1 4 1 2010 1020n
preplace netloc Picxo_Heir_dout 1 4 1 2000 1000n
preplace netloc Processor_Heir_gpio_io_o 1 1 3 530J 500 NJ 500 1480
preplace netloc Processor_Heir_gpio_io_o1 1 0 4 50 830 440 510 NJ 510 1470
preplace netloc QUAD0_gpi_0_1 1 0 5 20J 1140 660J 1130 NJ 1130 1520J 940 NJ
preplace netloc RX_Heir_interrupt 1 2 2 1040J 360 1460
preplace netloc RX_Heir_interrupt1 1 2 2 1010J 380 1500
preplace netloc RX_Heir_sdi_rx_irq 1 2 2 1020J 370 1490
preplace netloc Tx_Heir_interrupt 1 3 1 1550 200n
preplace netloc Tx_Heir_interrupt1 1 3 1 1510 240n
preplace netloc Tx_Heir_sdi_tx_irq 1 3 1 1470 220n
preplace netloc axi_intc_0_irq 1 5 1 NJ 470
preplace netloc bufg_gt_1_usrclk 1 2 4 1120 610 1460 950 1930 1830 NJ
preplace netloc bufg_gt_usrclk 1 0 6 30 1130 650 1140 NJ 1140 1530 1440 2010 1860 NJ
preplace netloc clk_freerun 1 0 5 20 800 620 530 1100 590 1490 590 2020
preplace netloc clk_wizard_0_clk_out2 1 1 4 480 470 1080 390 1480J 220 2020J
preplace netloc fid_1 1 2 1 1070 310n
preplace netloc gtwiz_versal_0_INTF0_TX_clrb_leaf_out 1 3 3 1550 610 NJ 610 2500
preplace netloc gtwiz_versal_0_INTF0_rst_tx_done_out 1 0 6 40 1120 NJ 1120 NJ 1120 1510J 930 1970J 850 2480
preplace netloc gtwiz_versal_0_QUAD0_RX0_outclk 1 3 3 1550 1810 NJ 1810 2470
preplace netloc gtwiz_versal_0_QUAD0_TX0_outclk 1 3 3 1540 1820 NJ 1820 2490
preplace netloc gtwiz_versal_0_QUAD0_gpo 1 4 2 2030 860 NJ
preplace netloc gtwiz_versal_0_gtpowergood 1 0 6 60 1110 NJ 1110 NJ 1110 1500 910 1950J 840 2490
preplace netloc ilconcat_0_dout 1 4 1 1990 350n
preplace netloc peripheral_hier_gpio_io_o2 1 1 2 630 450 1090J
preplace netloc peripheral_hier_iic2intc_irpt 1 1 3 610J 540 NJ 540 1490
preplace netloc peripheral_hier_ip2intc_irpt 1 1 3 640J 550 NJ 550 1500
preplace netloc proc_sys_reset_0_peripheral_aresetn 1 0 5 40 820 600 520 1060 600 1540 600 1970
preplace netloc proc_sys_reset_1_peripheral_aresetn 1 1 2 520 440 1030J
preplace netloc ps_wizard_0_pl0_ref_clk 1 0 1 20J 480n
preplace netloc reset_1 1 0 1 20J 460n
preplace netloc util_ds_buf_1_IBUF_OUT 1 4 1 1960 1200n
preplace netloc util_ds_buf_IBUF_OUT 1 4 1 1950 1080n
preplace netloc v_vid_gt_bridge_rx_reset_rx_datapath 1 1 4 440 1800 NJ 1800 NJ 1800 2030J
preplace netloc v_vid_gt_bridge_rx_reset_rx_pll_and_datapath 1 1 4 520 1790 NJ 1790 NJ 1790 2020J
preplace netloc v_vid_gt_bridge_rx_rx_full_rst 1 1 4 630 1780 NJ 1780 NJ 1780 1990J
preplace netloc v_vid_gt_bridge_tx_reset_tx_datapath 1 4 1 1940 820n
preplace netloc v_vid_gt_bridge_tx_reset_tx_pll_and_datapath 1 4 1 1960 800n
preplace netloc v_vid_gt_bridge_tx_tx_full_rst 1 4 1 1990 740n
preplace netloc xlconstant_2_dout 1 1 2 560 460 1050J
preplace netloc Processor_Heir_M00_AXI_0 1 1 1 460 190n
preplace netloc Processor_Heir_M01_AXI_0 1 1 2 440 90 NJ
preplace netloc Processor_Heir_M03_AXI 1 1 1 510 250n
preplace netloc Processor_Heir_M08_AXI 1 1 2 490 110 1030J
preplace netloc Processor_Heir_M09_AXI_0 1 1 1 470 170n
preplace netloc Processor_Heir_M10_AXI_0 1 1 2 450 100 1110J
preplace netloc Processor_Heir_fzetton_fmc_gpio 1 1 5 590J 480 NJ 480 NJ 480 1940J 380 NJ
preplace netloc Processor_Heir_fzetton_fmc_iic 1 1 5 550J 560 NJ 560 NJ 560 NJ 560 2500J
preplace netloc Processor_Heir_fzetton_fmc_spi 1 1 5 500J 570 NJ 570 NJ 570 NJ 570 NJ
preplace netloc RX_Heir_M_AXIS_CTRL_SB_RX 1 0 3 30 810 NJ 810 1000
preplace netloc RX_Heir_m_axi_mm_video 1 2 3 1010J 10 NJ 10 2020
preplace netloc S00_AXI_1 1 0 1 NJ 440
preplace netloc S_AXIS_DATA_1 1 2 1 1020 70n
preplace netloc S_AXIS_RX_1 1 1 1 570 210n
preplace netloc S_AXIS_STS_SB_RX_1 1 1 1 580 230n
preplace netloc Tx_Heir_M_AXIS_CTRL_SB_TX 1 3 1 1520 160n
preplace netloc Tx_Heir_M_AXIS_TX 1 3 1 1530 140n
preplace netloc Tx_Heir_m_axi_mm_video1 1 3 2 NJ 180 N
preplace netloc axi_noc2_0_M00_INI 1 5 1 NJ 170
preplace netloc axi_noc2_0_M01_INI 1 5 1 2500J 190n
preplace netloc gt_refclk2_1 1 0 4 NJ 1160 NJ 1160 NJ 1160 NJ
preplace netloc gt_refclk_1 1 0 4 NJ 1700 NJ 1700 NJ 1700 NJ
preplace netloc gtwiz_versal_0_Quad0_GT_Serial 1 5 1 NJ 1020
preplace netloc peripheral_hier_M12_AXI 1 1 4 540J 490 NJ 490 NJ 490 1960
preplace netloc v_vid_gt_bridge_rx_GT_RX0 1 1 4 NJ 920 NJ 920 NJ 920 1980
preplace netloc v_vid_gt_bridge_tx_GT_TX0 1 4 1 2010 720n
preplace netloc v_vid_gt_bridge_tx_SDI_TX_PHY_SB_STS 1 2 3 1110 580 NJ 580 1940
levelinfo -pg 1 0 250 830 1290 1740 2250 2520
pagesize -pg 1 -db -bbox -sgen -180 0 2710 1880
"
}

  # Restore current instance
  current_bd_instance $oldCurInst
}


proc available_tcl_procs { } {
   puts "##################################################################"
   puts "# Available Tcl procedures to recreate hierarchical blocks:"
   puts "#"
   puts "#    create_hier_cell_sdi parentCell nameHier"
   puts "#    create_hier_cell_Tx_Heir parentCell nameHier"
   puts "#    create_hier_cell_peripheral_hier parentCell nameHier"
   puts "#    create_hier_cell_RX_Heir parentCell nameHier"
   puts "#"
   puts "##################################################################"
}

available_tcl_procs

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
xilinx.com:ip:mipi_csi2_rx_subsystem:*\
xilinx.com:ip:axis_broadcaster:*\
xilinx.com:ip:visp_ss:*\
xilinx.com:ip:axi_noc2:*\
xilinx.com:ip:smartconnect:*\
xilinx.com:inline_hdl:ilvector_logic:*\
xilinx.com:inline_hdl:ilconcat:*\
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


# Hierarchical cell: mipi_rx_ss_hier
proc create_hier_cell_mipi_rx_ss_hier { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_mipi_rx_ss_hier() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:mipi_phy_rtl:1.0 MIPI2

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:mipi_phy_rtl:1.0 MIPI6

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_LITE

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 S00_INI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M00_INI


  # Create pins
  create_bd_pin -dir I -type clk tile0_ref_dpll_clk
  create_bd_pin -dir I -type rst s_axi_lite_rstn
  create_bd_pin -dir I -type clk dphy_clk_200M
  create_bd_pin -dir O -type intr tile0_isp0_fusa_irq
  create_bd_pin -dir O -type intr tile0_isp0_isp_irq
  create_bd_pin -dir O -type intr tile0_isp_isr_irq
  create_bd_pin -dir O -type intr tile0_isp_xmpu_interrupt
  create_bd_pin -dir O -type intr csirxss_csi_irq
  create_bd_pin -dir O -type intr csirxss_csi_irq1

  # Create instance: mipi_csi2_rx_subsyst_0, and set properties
  set mipi_csi2_rx_subsyst_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mipi_csi2_rx_subsystem mipi_csi2_rx_subsyst_0 ]
  set_property -dict [list \
    CONFIG.CMN_NUM_LANES {4} \
    CONFIG.CMN_NUM_PIXELS {4} \
    CONFIG.CMN_PXL_FORMAT {RAW12} \
    CONFIG.CMN_VC {All} \
    CONFIG.CSI_BUF_DEPTH {4096} \
    CONFIG.C_CSI_EN_ACTIVELANES {true} \
    CONFIG.C_CSI_FILTER_USERDATATYPE {true} \
    CONFIG.C_DPHY_LANES {4} \
    CONFIG.C_SPRT_ISP_BRIDGE {true} \
    CONFIG.DPY_EN_REG_IF {true} \
    CONFIG.DPY_LINE_RATE {1500} \
    CONFIG.SupportLevel {1} \
  ] $mipi_csi2_rx_subsyst_0


  # Create instance: axis_broadcaster_0, and set properties
  set axis_broadcaster_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_broadcaster axis_broadcaster_0 ]
  set_property -dict [list \
    CONFIG.HAS_TKEEP {1} \
    CONFIG.HAS_TLAST {1} \
    CONFIG.HAS_TREADY {1} \
    CONFIG.HAS_TSTRB {0} \
    CONFIG.M_TDATA_NUM_BYTES {6} \
    CONFIG.M_TUSER_WIDTH {112} \
    CONFIG.S_TDATA_NUM_BYTES {6} \
    CONFIG.S_TUSER_WIDTH {112} \
    CONFIG.TDEST_WIDTH {11} \
    CONFIG.TID_WIDTH {0} \
  ] $axis_broadcaster_0

  set_property -dict [list \
    CONFIG.HAS_TKEEP.VALUE_MODE {auto} \
    CONFIG.HAS_TLAST.VALUE_MODE {auto} \
    CONFIG.HAS_TREADY.VALUE_MODE {auto} \
    CONFIG.HAS_TSTRB.VALUE_MODE {auto} \
    CONFIG.M_TDATA_NUM_BYTES.VALUE_MODE {auto} \
    CONFIG.M_TUSER_WIDTH.VALUE_MODE {auto} \
    CONFIG.S_TDATA_NUM_BYTES.VALUE_MODE {auto} \
    CONFIG.S_TUSER_WIDTH.VALUE_MODE {auto} \
    CONFIG.TDEST_WIDTH.VALUE_MODE {auto} \
    CONFIG.TID_WIDTH.VALUE_MODE {auto} \
  ] $axis_broadcaster_0


  # Create instance: axis_broadcaster_1, and set properties
  set axis_broadcaster_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_broadcaster axis_broadcaster_1 ]
  set_property -dict [list \
    CONFIG.HAS_TKEEP {1} \
    CONFIG.HAS_TLAST {1} \
    CONFIG.HAS_TREADY {1} \
    CONFIG.HAS_TSTRB {0} \
    CONFIG.M_TDATA_NUM_BYTES {6} \
    CONFIG.M_TUSER_WIDTH {112} \
    CONFIG.S_TDATA_NUM_BYTES {6} \
    CONFIG.S_TUSER_WIDTH {112} \
    CONFIG.TDEST_WIDTH {11} \
    CONFIG.TID_WIDTH {0} \
  ] $axis_broadcaster_1

  set_property -dict [list \
    CONFIG.HAS_TKEEP.VALUE_MODE {auto} \
    CONFIG.HAS_TLAST.VALUE_MODE {auto} \
    CONFIG.HAS_TREADY.VALUE_MODE {auto} \
    CONFIG.HAS_TSTRB.VALUE_MODE {auto} \
    CONFIG.M_TDATA_NUM_BYTES.VALUE_MODE {auto} \
    CONFIG.M_TUSER_WIDTH.VALUE_MODE {auto} \
    CONFIG.S_TDATA_NUM_BYTES.VALUE_MODE {auto} \
    CONFIG.S_TUSER_WIDTH.VALUE_MODE {auto} \
    CONFIG.TDEST_WIDTH.VALUE_MODE {auto} \
    CONFIG.TID_WIDTH.VALUE_MODE {auto} \
  ] $axis_broadcaster_1


  # Create instance: mipi_csi2_rx_subsyst_1, and set properties
  set mipi_csi2_rx_subsyst_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mipi_csi2_rx_subsystem mipi_csi2_rx_subsyst_1 ]
  set_property -dict [list \
    CONFIG.CMN_NUM_LANES {4} \
    CONFIG.CMN_NUM_PIXELS {4} \
    CONFIG.CMN_PXL_FORMAT {RAW12} \
    CONFIG.CMN_VC {All} \
    CONFIG.CSI_BUF_DEPTH {4096} \
    CONFIG.C_CSI_EN_ACTIVELANES {true} \
    CONFIG.C_CSI_FILTER_USERDATATYPE {true} \
    CONFIG.C_DPHY_LANES {4} \
    CONFIG.C_SPRT_ISP_BRIDGE {true} \
    CONFIG.DPY_EN_REG_IF {true} \
    CONFIG.DPY_LINE_RATE {1500} \
    CONFIG.SupportLevel {1} \
  ] $mipi_csi2_rx_subsyst_1


  # Create instance: visp_ss_0, and set properties
  set visp_ss_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:visp_ss visp_ss_0 ]
  set_property -dict [list \
    CONFIG.C_LLPATH0_TILE {3} \
    CONFIG.C_LLPATH1_TILE {3} \
    CONFIG.C_TILE0_CONFIG {1} \
    CONFIG.C_TILE0_ISP0_CORE_CLK {600.1} \
    CONFIG.C_TILE0_ISP0_ENABLE_MP {false} \
    CONFIG.C_TILE0_ISP0_ENABLE_SP {true} \
    CONFIG.C_TILE0_ISP0_GPIO_PS_CHECK {true} \
    CONFIG.C_TILE0_ISP0_GPIO_SELECT {0} \
    CONFIG.C_TILE0_ISP0_IBA0_DATA_FORMAT {12} \
    CONFIG.C_TILE0_ISP0_IBA0_FPS {60} \
    CONFIG.C_TILE0_ISP0_IBA0_PPC {4} \
    CONFIG.C_TILE0_ISP0_IBA0_RES_HOR {1920} \
    CONFIG.C_TILE0_ISP0_IBA0_RES_VER {1080} \
    CONFIG.C_TILE0_ISP0_IBA0_VCID {0} \
    CONFIG.C_TILE0_ISP0_IBA1_DATA_FORMAT {12} \
    CONFIG.C_TILE0_ISP0_IBA1_FPS {60} \
    CONFIG.C_TILE0_ISP0_IBA1_RES_HOR {1920} \
    CONFIG.C_TILE0_ISP0_IBA1_RES_VER {1080} \
    CONFIG.C_TILE0_ISP0_IBA2_DATA_FORMAT {12} \
    CONFIG.C_TILE0_ISP0_IBA2_FPS {60} \
    CONFIG.C_TILE0_ISP0_IBA2_RES_HOR {1920} \
    CONFIG.C_TILE0_ISP0_IBA2_RES_VER {1080} \
    CONFIG.C_TILE0_ISP0_IBA2_VCID {0} \
    CONFIG.C_TILE0_ISP0_IBA3_DATA_FORMAT {12} \
    CONFIG.C_TILE0_ISP0_IBA3_FPS {60} \
    CONFIG.C_TILE0_ISP0_IBA3_RES_HOR {1920} \
    CONFIG.C_TILE0_ISP0_IBA3_RES_VER {1080} \
    CONFIG.C_TILE0_ISP0_IBA3_VCID {1} \
    CONFIG.C_TILE0_ISP0_IIC_PS_CHECK {true} \
    CONFIG.C_TILE0_ISP0_IIC_SELECT {0} \
    CONFIG.C_TILE0_ISP0_IO_TYPE {2} \
    CONFIG.C_TILE0_ISP0_LIVE_INPUTS {4} \
    CONFIG.C_TILE0_ISP0_OBA0_MP_BPP {10} \
    CONFIG.C_TILE0_ISP0_OBA0_MP_RGB888 {true} \
    CONFIG.C_TILE0_ISP0_OBA0_MP_Y {true} \
    CONFIG.C_TILE0_ISP0_OBA0_MP_YUV420 {false} \
    CONFIG.C_TILE0_ISP0_OBA0_MP_YUV422 {true} \
    CONFIG.C_TILE0_ISP0_OBA0_PPC {4} \
    CONFIG.C_TILE0_ISP0_RPU {6} \
    CONFIG.C_TILE0_ISP1_CORE_CLK {597.20} \
    CONFIG.C_TILE0_ISP1_ENABLE_MP {false} \
    CONFIG.C_TILE0_ISP1_ENABLE_SP {true} \
    CONFIG.C_TILE0_ISP1_IBA4_RES_HOR {3840} \
    CONFIG.C_TILE0_ISP1_IBA4_RES_VER {2160} \
    CONFIG.C_TILE0_ISP1_IBA4_VCID {0} \
    CONFIG.C_TILE0_ISP1_IO_TYPE {0} \
    CONFIG.C_TILE0_ISP1_OBA1_MP_BPP {10} \
    CONFIG.C_TILE0_ISP1_OBA1_MP_RGB888 {true} \
    CONFIG.C_TILE0_ISP1_OBA1_MP_Y {true} \
    CONFIG.C_TILE0_ISP1_OBA1_MP_YUV420 {false} \
    CONFIG.C_TILE0_ISP1_OBA1_MP_YUV422 {true} \
    CONFIG.C_TILE0_ISP1_OBA1_PPC {4} \
    CONFIG.C_TILE0_ISP1_RPU {6} \
    CONFIG.C_TILE1_CONFIG {1} \
    CONFIG.C_TILE1_ENABLE {false} \
    CONFIG.C_TILE1_ISP0_CORE_CLK {600.00} \
    CONFIG.C_TILE1_ISP0_IO_TYPE {0} \
    CONFIG.C_TILE1_ISP0_RPU {7} \
    CONFIG.C_TILE1_ISP1_CORE_CLK {600.00} \
    CONFIG.C_TILE1_ISP1_IBA4_VCID {0} \
    CONFIG.C_TILE1_ISP1_IO_TYPE {0} \
    CONFIG.C_TILE1_ISP1_RPU {7} \
    CONFIG.C_TILE2_CONFIG {0} \
    CONFIG.C_TILE2_ENABLE {false} \
    CONFIG.C_TILE2_ISP0_IO_TYPE {0} \
    CONFIG.C_TILE2_ISP0_RPU {8} \
    CONFIG.C_TILE2_ISP1_IO_TYPE {0} \
    CONFIG.C_TILE2_ISP1_RPU {8} \
  ] $visp_ss_0


  set_property -dict [ list \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.PROTOCOL {AXI4LITE} \
   CONFIG.ADDR_WIDTH {12} \
 ] [get_bd_intf_pins $visp_ss_0/S_AXI_LITE]

  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {64} \
   CONFIG.CATEGORY {noc} \
   CONFIG.MY_CATEGORY {isp} \
   CONFIG.PHYSICAL_CHANNEL {ISP_TO_NOC_NMU} \
   CONFIG.TILE_INDEX {0} \
   CONFIG.INDEX {0} \
 ] [get_bd_intf_pins $visp_ss_0/TILE0_ISP0_NMU]

  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.CATEGORY {noc} \
   CONFIG.MY_CATEGORY {isp} \
   CONFIG.PHYSICAL_CHANNEL {NOC_NSU_TO_ISP} \
   CONFIG.TILE_INDEX {0} \
   CONFIG.INDEX {0} \
 ] [get_bd_intf_pins $visp_ss_0/TILE0_ISP_NSU]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S_AXI_LITE} \
   CONFIG.ASSOCIATED_RESET {s_axi_lite_rstn} \
 ] [get_bd_pins $visp_ss_0/s_axi_lite_aclk]

  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] [get_bd_pins $visp_ss_0/s_axi_lite_rstn]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {TILE0_ISP0_NMU} \
 ] [get_bd_pins $visp_ss_0/tile0_nmu0_axi_clk]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {TILE0_ISP_NSU} \
 ] [get_bd_pins $visp_ss_0/tile0_nsu_axi_clk]

  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] [get_bd_pins $visp_ss_0/tile0_pl_isp_rstn]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {TILE0_ISP_MIPI_VIDIN0} \
 ] [get_bd_pins $visp_ss_0/tile0_pl_isp_vidin0_clk]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {TILE0_ISP_MIPI_VIDIN1} \
 ] [get_bd_pins $visp_ss_0/tile0_pl_isp_vidin1_clk]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {TILE0_ISP_MIPI_VIDIN2} \
 ] [get_bd_pins $visp_ss_0/tile0_pl_isp_vidin2_clk]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {TILE0_ISP_MIPI_VIDIN3} \
 ] [get_bd_pins $visp_ss_0/tile0_pl_isp_vidin3_clk]

  # Create instance: axi_noc2_visp_ss, and set properties
  set axi_noc2_visp_ss [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc2 axi_noc2_visp_ss ]
  set_property -dict [list \
    CONFIG.MI_SIDEBAND_PINS {} \
    CONFIG.NUM_CLKS {2} \
    CONFIG.NUM_MI {1} \
    CONFIG.NUM_NMI {1} \
    CONFIG.NUM_NSI {1} \
    CONFIG.NUM_SI {1} \
    CONFIG.SI_SIDEBAND_PINS {} \
  ] $axi_noc2_visp_ss


  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.PHYSICAL_LOC {NOC2_NSU128_X14Y2} \
   CONFIG.CATEGORY {isp} \
 ] [get_bd_intf_pins $axi_noc2_visp_ss/M00_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.R_TRAFFIC_CLASS {ISOCHRONOUS} \
   CONFIG.W_TRAFFIC_CLASS {ISOCHRONOUS} \
   CONFIG.CONNECTIONS {M00_INI {read_bw {1100} write_bw {2200} initial_boot {true} }} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {isp} \
 ] [get_bd_intf_pins $axi_noc2_visp_ss/S00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true} }} \
 ] [get_bd_intf_pins $axi_noc2_visp_ss/S00_INI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXI} \
 ] [get_bd_pins $axi_noc2_visp_ss/aclk0]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI} \
 ] [get_bd_pins $axi_noc2_visp_ss/aclk1]

  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_0 ]
  set_property -dict [list \
    CONFIG.NUM_MI {3} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_0


  # Create instance: ilvector_logic_2, and set properties
  set ilvector_logic_2 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilvector_logic ilvector_logic_2 ]
  set_property -dict [list \
    CONFIG.C_OPERATION {or} \
    CONFIG.C_SIZE {1} \
  ] $ilvector_logic_2


  # Create instance: ilconcat_1, and set properties
  set ilconcat_1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat ilconcat_1 ]

  # Create instance: ilconcat_2, and set properties
  set ilconcat_2 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat ilconcat_2 ]

  # Create instance: ilvector_logic_4, and set properties
  set ilvector_logic_4 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilvector_logic ilvector_logic_4 ]
  set_property -dict [list \
    CONFIG.C_OPERATION {or} \
    CONFIG.C_SIZE {1} \
  ] $ilvector_logic_4


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins axi_noc2_visp_ss/M00_INI] [get_bd_intf_pins M00_INI]
  connect_bd_intf_net -intf_net MIPI2_1 [get_bd_intf_pins MIPI2] [get_bd_intf_pins mipi_csi2_rx_subsyst_0/mipi_phy_if]
  connect_bd_intf_net -intf_net MIPI6_1 [get_bd_intf_pins MIPI6] [get_bd_intf_pins mipi_csi2_rx_subsyst_1/mipi_phy_if]
  connect_bd_intf_net -intf_net Master_NoC_M12_INI [get_bd_intf_pins S00_INI] [get_bd_intf_pins axi_noc2_visp_ss/S00_INI]
  connect_bd_intf_net -intf_net S_AXI_LITE_1 [get_bd_intf_pins S_AXI_LITE] [get_bd_intf_pins smartconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net axis_broadcaster_0_M00_AXIS [get_bd_intf_pins axis_broadcaster_0/M00_AXIS] [get_bd_intf_pins visp_ss_0/TILE0_ISP_MIPI_VIDIN0]
  connect_bd_intf_net -intf_net axis_broadcaster_0_M01_AXIS [get_bd_intf_pins axis_broadcaster_0/M01_AXIS] [get_bd_intf_pins visp_ss_0/TILE0_ISP_MIPI_VIDIN1]
  connect_bd_intf_net -intf_net axis_broadcaster_1_M00_AXIS [get_bd_intf_pins axis_broadcaster_1/M00_AXIS] [get_bd_intf_pins visp_ss_0/TILE0_ISP_MIPI_VIDIN2]
  connect_bd_intf_net -intf_net axis_broadcaster_1_M01_AXIS [get_bd_intf_pins axis_broadcaster_1/M01_AXIS] [get_bd_intf_pins visp_ss_0/TILE0_ISP_MIPI_VIDIN3]
  connect_bd_intf_net -intf_net mipi_csi2_rx_subsyst_0_video_out [get_bd_intf_pins mipi_csi2_rx_subsyst_0/video_out] [get_bd_intf_pins axis_broadcaster_0/S_AXIS]
  connect_bd_intf_net -intf_net mipi_csi2_rx_subsyst_1_video_out [get_bd_intf_pins axis_broadcaster_1/S_AXIS] [get_bd_intf_pins mipi_csi2_rx_subsyst_1/video_out]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins mipi_csi2_rx_subsyst_0/csirxss_s_axi]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins smartconnect_0/M01_AXI] [get_bd_intf_pins mipi_csi2_rx_subsyst_1/csirxss_s_axi]
  connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins smartconnect_0/M02_AXI] [get_bd_intf_pins visp_ss_0/S_AXI_LITE]
  connect_bd_intf_net -intf_net visp_ss_0_TILE0_ISP0_NMU [get_bd_intf_pins visp_ss_0/TILE0_ISP0_NMU] [get_bd_intf_pins axi_noc2_visp_ss/S00_AXI]
  connect_bd_intf_net -intf_net visp_ss_0_TILE0_ISP_NSU [get_bd_intf_pins visp_ss_0/TILE0_ISP_NSU] [get_bd_intf_pins axi_noc2_visp_ss/M00_AXI]

  # Create port connections
  connect_bd_net -net Net  [get_bd_pins visp_ss_0/TILE0_ISP_MIPI_VIDIN1_tready] \
  [get_bd_pins ilvector_logic_2/Op2]
  connect_bd_net -net clkx5_wiz_0_dphy_clk_200M  [get_bd_pins dphy_clk_200M] \
  [get_bd_pins mipi_csi2_rx_subsyst_1/dphy_clk_200M] \
  [get_bd_pins mipi_csi2_rx_subsyst_0/dphy_clk_200M]
  connect_bd_net -net ilconcat_1_dout  [get_bd_pins ilconcat_1/dout] \
  [get_bd_pins axis_broadcaster_0/m_axis_tready]
  connect_bd_net -net ilconcat_2_dout  [get_bd_pins ilconcat_2/dout] \
  [get_bd_pins axis_broadcaster_1/m_axis_tready]
  connect_bd_net -net ilvector_logic_2_Res  [get_bd_pins ilvector_logic_2/Res] \
  [get_bd_pins ilconcat_1/In0] \
  [get_bd_pins ilconcat_1/In1]
  connect_bd_net -net ilvector_logic_2_Res1  [get_bd_pins ilvector_logic_4/Res] \
  [get_bd_pins ilconcat_2/In0] \
  [get_bd_pins ilconcat_2/In1]
  connect_bd_net -net mipi_csi2_rx_subsyst_0_csirxss_csi_irq  [get_bd_pins mipi_csi2_rx_subsyst_0/csirxss_csi_irq] \
  [get_bd_pins csirxss_csi_irq]
  connect_bd_net -net mipi_csi2_rx_subsyst_0_header_data  [get_bd_pins mipi_csi2_rx_subsyst_0/header_data] \
  [get_bd_pins visp_ss_0/tile0_isp_mipi_vidin0_header_data] \
  [get_bd_pins visp_ss_0/tile0_isp_mipi_vidin1_header_data]
  connect_bd_net -net mipi_csi2_rx_subsyst_0_header_valid  [get_bd_pins mipi_csi2_rx_subsyst_0/header_valid] \
  [get_bd_pins visp_ss_0/tile0_isp_mipi_vidin0_header_valid] \
  [get_bd_pins visp_ss_0/tile0_isp_mipi_vidin1_header_valid]
  connect_bd_net -net mipi_csi2_rx_subsyst_1_csirxss_csi_irq  [get_bd_pins mipi_csi2_rx_subsyst_1/csirxss_csi_irq] \
  [get_bd_pins csirxss_csi_irq1]
  connect_bd_net -net mipi_csi2_rx_subsyst_1_header_data  [get_bd_pins mipi_csi2_rx_subsyst_1/header_data] \
  [get_bd_pins visp_ss_0/tile0_isp_mipi_vidin3_header_data] \
  [get_bd_pins visp_ss_0/tile0_isp_mipi_vidin2_header_data]
  connect_bd_net -net mipi_csi2_rx_subsyst_1_header_valid  [get_bd_pins mipi_csi2_rx_subsyst_1/header_valid] \
  [get_bd_pins visp_ss_0/tile0_isp_mipi_vidin3_header_valid] \
  [get_bd_pins visp_ss_0/tile0_isp_mipi_vidin2_header_valid]
  connect_bd_net -net ps_wizard_0_pl1_ref_clk  [get_bd_pins tile0_ref_dpll_clk] \
  [get_bd_pins visp_ss_0/tile0_ref_dpll_clk] \
  [get_bd_pins visp_ss_0/s_axi_lite_aclk] \
  [get_bd_pins visp_ss_0/tile0_pl_isp_vidin0_clk] \
  [get_bd_pins axis_broadcaster_0/aclk] \
  [get_bd_pins axis_broadcaster_1/aclk] \
  [get_bd_pins mipi_csi2_rx_subsyst_0/video_aclk] \
  [get_bd_pins mipi_csi2_rx_subsyst_1/lite_aclk] \
  [get_bd_pins mipi_csi2_rx_subsyst_1/video_aclk] \
  [get_bd_pins mipi_csi2_rx_subsyst_0/lite_aclk] \
  [get_bd_pins smartconnect_0/aclk] \
  [get_bd_pins visp_ss_0/tile0_pl_isp_vidin1_clk] \
  [get_bd_pins visp_ss_0/tile0_pl_isp_vidin2_clk] \
  [get_bd_pins visp_ss_0/tile0_pl_isp_vidin3_clk]
  connect_bd_net -net s_axi_aresetn  [get_bd_pins s_axi_lite_rstn] \
  [get_bd_pins visp_ss_0/s_axi_lite_rstn] \
  [get_bd_pins visp_ss_0/tile0_pl_isp_rstn] \
  [get_bd_pins axis_broadcaster_0/aresetn] \
  [get_bd_pins axis_broadcaster_1/aresetn] \
  [get_bd_pins mipi_csi2_rx_subsyst_0/video_aresetn] \
  [get_bd_pins mipi_csi2_rx_subsyst_1/lite_aresetn] \
  [get_bd_pins mipi_csi2_rx_subsyst_1/video_aresetn] \
  [get_bd_pins mipi_csi2_rx_subsyst_0/lite_aresetn] \
  [get_bd_pins smartconnect_0/aresetn]
  connect_bd_net -net visp_ss_0_TILE0_ISP_MIPI_VIDIN0_tready  [get_bd_pins visp_ss_0/TILE0_ISP_MIPI_VIDIN0_tready] \
  [get_bd_pins ilvector_logic_2/Op1]
  connect_bd_net -net visp_ss_0_TILE0_ISP_MIPI_VIDIN2_tready  [get_bd_pins visp_ss_0/TILE0_ISP_MIPI_VIDIN2_tready] \
  [get_bd_pins ilvector_logic_4/Op1]
  connect_bd_net -net visp_ss_0_TILE0_ISP_MIPI_VIDIN3_tready  [get_bd_pins visp_ss_0/TILE0_ISP_MIPI_VIDIN3_tready] \
  [get_bd_pins ilvector_logic_4/Op2]
  connect_bd_net -net visp_ss_0_tile0_isp0_fusa_irq  [get_bd_pins visp_ss_0/tile0_isp0_fusa_irq] \
  [get_bd_pins tile0_isp0_fusa_irq]
  connect_bd_net -net visp_ss_0_tile0_isp0_isp_irq  [get_bd_pins visp_ss_0/tile0_isp0_isp_irq] \
  [get_bd_pins tile0_isp0_isp_irq]
  connect_bd_net -net visp_ss_0_tile0_isp_isr_irq  [get_bd_pins visp_ss_0/tile0_isp_isr_irq] \
  [get_bd_pins tile0_isp_isr_irq]
  connect_bd_net -net visp_ss_0_tile0_isp_xmpu_interrupt  [get_bd_pins visp_ss_0/tile0_isp_xmpu_interrupt] \
  [get_bd_pins tile0_isp_xmpu_interrupt]
  connect_bd_net -net visp_ss_0_tile0_nmu0_axi_clk  [get_bd_pins visp_ss_0/tile0_nmu0_axi_clk] \
  [get_bd_pins axi_noc2_visp_ss/aclk0]
  connect_bd_net -net visp_ss_0_tile0_nsu_axi_clk  [get_bd_pins visp_ss_0/tile0_nsu_axi_clk] \
  [get_bd_pins axi_noc2_visp_ss/aclk1]

  # Perform GUI Layout
  regenerate_bd_layout -hierarchy [get_bd_cells /mipi_rx_ss_hier] -layout_string {
   "ActiveEmotionalView":"Default View",
   "Default View_ScaleFactor":"3.35735",
   "Default View_TopLeft":"1768,46",
   "ExpandedHierarchyInLayout":"",
   "guistr":"# # String gsaved with Nlview 7.8.0 2024-04-26 e1825d835c VDI=44 GEI=38 GUI=JA:21.0 TLS
#  -string -flagsOSRD
preplace port MIPI2 -pg 1 -lvl 0 -x 0 -y 290 -defaultsOSRD
preplace port MIPI6 -pg 1 -lvl 0 -x 0 -y 630 -defaultsOSRD
preplace port S_AXI_LITE -pg 1 -lvl 0 -x 0 -y 350 -defaultsOSRD
preplace port S00_INI -pg 1 -lvl 0 -x 0 -y 110 -defaultsOSRD
preplace port M00_INI -pg 1 -lvl 6 -x 2160 -y 130 -defaultsOSRD
preplace port port-id_tile0_ref_dpll_clk -pg 1 -lvl 0 -x 0 -y 370 -defaultsOSRD
preplace port port-id_s_axi_lite_rstn -pg 1 -lvl 0 -x 0 -y 390 -defaultsOSRD
preplace port port-id_dphy_clk_200M -pg 1 -lvl 0 -x 0 -y 660 -defaultsOSRD
preplace port port-id_tile0_isp0_fusa_irq -pg 1 -lvl 6 -x 2160 -y 420 -defaultsOSRD
preplace port port-id_tile0_isp0_isp_irq -pg 1 -lvl 6 -x 2160 -y 440 -defaultsOSRD
preplace port port-id_tile0_isp_isr_irq -pg 1 -lvl 6 -x 2160 -y 460 -defaultsOSRD
preplace port port-id_tile0_isp_xmpu_interrupt -pg 1 -lvl 6 -x 2160 -y 480 -defaultsOSRD
preplace port port-id_csirxss_csi_irq -pg 1 -lvl 6 -x 2160 -y 740 -defaultsOSRD
preplace port port-id_csirxss_csi_irq1 -pg 1 -lvl 6 -x 2160 -y 890 -defaultsOSRD
preplace inst mipi_csi2_rx_subsyst_0 -pg 1 -lvl 2 -x 520 -y 350 -defaultsOSRD
preplace inst axis_broadcaster_0 -pg 1 -lvl 3 -x 910 -y 260 -defaultsOSRD
preplace inst axis_broadcaster_1 -pg 1 -lvl 3 -x 910 -y 440 -defaultsOSRD
preplace inst mipi_csi2_rx_subsyst_1 -pg 1 -lvl 2 -x 520 -y 690 -defaultsOSRD
preplace inst visp_ss_0 -pg 1 -lvl 4 -x 1490 -y 420 -defaultsOSRD
preplace inst axi_noc2_visp_ss -pg 1 -lvl 5 -x 1950 -y 120 -defaultsOSRD
preplace inst smartconnect_0 -pg 1 -lvl 1 -x 170 -y 370 -defaultsOSRD
preplace inst ilvector_logic_2 -pg 1 -lvl 4 -x 1490 -y 810 -defaultsOSRD
preplace inst ilconcat_1 -pg 1 -lvl 5 -x 1950 -y 810 -defaultsOSRD
preplace inst ilconcat_2 -pg 1 -lvl 5 -x 1950 -y 960 -defaultsOSRD
preplace inst ilvector_logic_4 -pg 1 -lvl 4 -x 1490 -y 960 -defaultsOSRD
preplace netloc clkx5_wiz_0_dphy_clk_200M 1 0 2 NJ 660 360
preplace netloc ilconcat_1_dout 1 3 3 1100J 90 1740J 230 2110
preplace netloc ilconcat_2_dout 1 3 3 1120J 100 1770J 240 2120
preplace netloc ilvector_logic_2_Res 1 4 1 1740 800n
preplace netloc ilvector_logic_2_Res1 1 4 1 1790 950n
preplace netloc mipi_csi2_rx_subsyst_0_csirxss_csi_irq 1 2 4 680J 80 NJ 80 1780J 250 2140J
preplace netloc mipi_csi2_rx_subsyst_0_header_data 1 2 2 680J 350 1170
preplace netloc mipi_csi2_rx_subsyst_0_header_valid 1 2 2 690J 360 1140
preplace netloc mipi_csi2_rx_subsyst_1_csirxss_csi_irq 1 2 4 NJ 620 1100J 730 NJ 730 2130J
preplace netloc ps_wizard_0_pl1_ref_clk 1 0 4 30 280 330 160 700 340 1150
preplace netloc s_axi_aresetn 1 0 4 30 450 350 180 710 180 1190
preplace netloc visp_ss_0_TILE0_ISP_MIPI_VIDIN0_tready 1 3 1 1240 210n
preplace netloc visp_ss_0_tile0_isp0_fusa_irq 1 4 2 NJ 420 NJ
preplace netloc visp_ss_0_tile0_isp0_isp_irq 1 4 2 NJ 440 NJ
preplace netloc visp_ss_0_tile0_isp_isr_irq 1 4 2 NJ 460 NJ
preplace netloc visp_ss_0_tile0_isp_xmpu_interrupt 1 4 2 NJ 480 NJ
preplace netloc visp_ss_0_tile0_nmu0_axi_clk 1 4 1 1760 130n
preplace netloc visp_ss_0_tile0_nsu_axi_clk 1 4 1 1790 150n
preplace netloc Net 1 3 1 1200 250n
preplace netloc visp_ss_0_TILE0_ISP_MIPI_VIDIN2_tready 1 3 1 1210 290n
preplace netloc visp_ss_0_TILE0_ISP_MIPI_VIDIN3_tready 1 3 1 1220 330n
preplace netloc mipi_csi2_rx_subsyst_1_header_valid 1 2 2 NJ 800 1190
preplace netloc mipi_csi2_rx_subsyst_1_header_data 1 2 2 NJ 780 1170
preplace netloc MIPI2_1 1 0 2 NJ 290 NJ
preplace netloc MIPI6_1 1 0 2 NJ 630 NJ
preplace netloc Master_NoC_M12_INI 1 0 5 NJ 110 NJ 110 NJ 110 NJ 110 NJ
preplace netloc S_AXI_LITE_1 1 0 1 NJ 350
preplace netloc axis_broadcaster_0_M00_AXIS 1 3 1 1110 190n
preplace netloc mipi_csi2_rx_subsyst_0_video_out 1 2 1 N 240
preplace netloc mipi_csi2_rx_subsyst_1_video_out 1 2 1 720 420n
preplace netloc smartconnect_0_M00_AXI 1 1 1 340 310n
preplace netloc smartconnect_0_M01_AXI 1 1 1 340 370n
preplace netloc smartconnect_0_M02_AXI 1 1 3 310 170 NJ 170 NJ
preplace netloc visp_ss_0_TILE0_ISP0_NMU 1 4 1 1750 90n
preplace netloc visp_ss_0_TILE0_ISP_NSU 1 3 3 1230 10 NJ 10 2110
preplace netloc axis_broadcaster_0_M01_AXIS 1 3 1 1140 230n
preplace netloc axis_broadcaster_1_M00_AXIS 1 3 1 1160 270n
preplace netloc axis_broadcaster_1_M01_AXIS 1 3 1 1180 310n
preplace netloc Conn1 1 5 1 N 130
levelinfo -pg 1 0 170 520 910 1490 1950 2160
pagesize -pg 1 -db -bbox -sgen -170 0 2390 1030
"
}

  # Restore current instance
  current_bd_instance $oldCurInst
}


proc available_tcl_procs { } {
   puts "##################################################################"
   puts "# Available Tcl procedures to recreate hierarchical blocks:"
   puts "#"
   puts "#    create_hier_cell_mipi_rx_ss_hier parentCell nameHier"
   puts "#"
   puts "##################################################################"
}

available_tcl_procs

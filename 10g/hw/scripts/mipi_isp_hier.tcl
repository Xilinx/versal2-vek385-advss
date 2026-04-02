
################################################################
# This is a generated script based on design: mipi_isp
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
# source mipi_isp_script.tcl

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:mipi_csi2_rx_subsystem:*\
xilinx.com:ip:smartconnect:*\
xilinx.com:ip:axi_intc:*\
xilinx.com:ip:proc_sys_reset:*\
xilinx.com:ip:axi_noc2:*\
xilinx.com:ip:visp_ss:*\
xilinx.com:ip:axis_broadcaster:*\
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


# Hierarchical cell: mipi_isp
proc create_hier_cell_mipi_isp { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_mipi_isp() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M00_INI_isp

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:mipi_phy_rtl:1.0 mipi_phy_if_0

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:mipi_phy_rtl:1.0 mipi_phy_if_1

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 TILE0_ISP_NSU

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 TILE1_ISP_NSU


  # Create pins
  create_bd_pin -dir I -type clk aclk_150
  create_bd_pin -dir I -type clk dphy_clk_200M
  create_bd_pin -dir O irq_mipi
  create_bd_pin -dir I -type rst ext_reset_in_0
  create_bd_pin -dir O -type intr tile0_isp0_fusa_irq_0
  create_bd_pin -dir O -type intr tile0_isp0_isp_irq_0
  create_bd_pin -dir O -type intr tile0_isp_isr_irq_0
  create_bd_pin -dir O -type intr tile0_isp_xmpu_interrupt_0
  create_bd_pin -dir I -type clk ref_dpll
  create_bd_pin -dir O -type intr tile1_isp0_fusa_irq_0
  create_bd_pin -dir O -type intr tile1_isp0_isp_irq_0
  create_bd_pin -dir O -type intr tile1_isp_isr_irq_0
  create_bd_pin -dir O -type intr tile1_isp_xmpu_interrupt_0
  create_bd_pin -dir O -type intr tile0_isp1_fusa_irq_0
  create_bd_pin -dir O -type intr tile0_isp1_isp_irq_0
  create_bd_pin -dir O -type intr tile1_isp1_fusa_irq_0
  create_bd_pin -dir O -type intr tile1_isp1_isp_irq_0

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


  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_0 ]
  set_property -dict [list \
    CONFIG.ADVANCED_PROPERTIES {__experimental_features__ {legacy_low_area_mode 1}} \
    CONFIG.NUM_MI {4} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_0


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


  # Create instance: axi_intc_0, and set properties
  set axi_intc_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc axi_intc_0 ]

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_0 ]

  # Create instance: axi_noc2_0, and set properties
  set axi_noc2_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc2 axi_noc2_0 ]
  set_property -dict [list \
    CONFIG.MI_SIDEBAND_PINS {} \
    CONFIG.NUM_CLKS {6} \
    CONFIG.NUM_MI {2} \
    CONFIG.NUM_NMI {1} \
    CONFIG.NUM_NSI {2} \
    CONFIG.NUM_SI {4} \
    CONFIG.SI_SIDEBAND_PINS {} \
  ] $axi_noc2_0


  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CATEGORY {isp} \
 ] [get_bd_intf_pins $axi_noc2_0/M00_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CATEGORY {isp} \
 ] [get_bd_intf_pins $axi_noc2_0/M01_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.W_TRAFFIC_CLASS {ISOCHRONOUS} \
   CONFIG.CONNECTIONS {M00_INI {read_bw {500} write_bw {2000} initial_boot {true}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {isp} \
 ] [get_bd_intf_pins $axi_noc2_0/S00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}} \
 ] [get_bd_intf_pins $axi_noc2_0/S00_INI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.W_TRAFFIC_CLASS {ISOCHRONOUS} \
   CONFIG.CONNECTIONS {M00_INI {read_bw {500} write_bw {2000} initial_boot {true}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {isp} \
 ] [get_bd_intf_pins $axi_noc2_0/S01_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M01_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}} \
 ] [get_bd_intf_pins $axi_noc2_0/S01_INI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.W_TRAFFIC_CLASS {ISOCHRONOUS} \
   CONFIG.CONNECTIONS {M00_INI {read_bw {500} write_bw {2000} initial_boot {true}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {isp} \
 ] [get_bd_intf_pins $axi_noc2_0/S02_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.W_TRAFFIC_CLASS {ISOCHRONOUS} \
   CONFIG.CONNECTIONS {M00_INI {read_bw {500} write_bw {2000} initial_boot {true}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {isp} \
 ] [get_bd_intf_pins $axi_noc2_0/S03_AXI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXI} \
 ] [get_bd_pins $axi_noc2_0/aclk0]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S01_AXI} \
 ] [get_bd_pins $axi_noc2_0/aclk1]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S02_AXI} \
 ] [get_bd_pins $axi_noc2_0/aclk2]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S03_AXI} \
 ] [get_bd_pins $axi_noc2_0/aclk3]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI} \
 ] [get_bd_pins $axi_noc2_0/aclk4]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M01_AXI} \
 ] [get_bd_pins $axi_noc2_0/aclk5]

  # Create instance: visp_ss_0, and set properties
  set visp_ss_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:visp_ss visp_ss_0 ]
  set_property -dict [list \
    CONFIG.C_TILE0_COMMON_IBA3_DATA_FORMAT {12} \
    CONFIG.C_TILE0_COMMON_IBA3_FPS {15} \
    CONFIG.C_TILE0_COMMON_IBA3_VCID {3} \
    CONFIG.C_TILE0_DPLL_CLKFBOUT_FRACT {1} \
    CONFIG.C_TILE0_DPLL_CLKFBOUT_MULT {54} \
    CONFIG.C_TILE0_DPLL_DIVCLK_DIVIDE {2} \
    CONFIG.C_TILE0_ISP0_BASIC_DATA_FORMAT {12} \
    CONFIG.C_TILE0_ISP0_CORE_CLK {600.1} \
    CONFIG.C_TILE0_ISP0_ENABLE_MP {false} \
    CONFIG.C_TILE0_ISP0_GPIO_PL_WIDTH {1} \
    CONFIG.C_TILE0_ISP0_GPIO_PS_CHECK {true} \
    CONFIG.C_TILE0_ISP0_GPIO_SELECT {0} \
    CONFIG.C_TILE0_ISP0_IBA0_DATA_FORMAT {12} \
    CONFIG.C_TILE0_ISP0_IBA0_FPS {30} \
    CONFIG.C_TILE0_ISP0_IIC_PS_CHECK {true} \
    CONFIG.C_TILE0_ISP0_IIC_SELECT {0} \
    CONFIG.C_TILE0_ISP0_IO_TYPE {2} \
    CONFIG.C_TILE0_ISP0_LIVE_INPUTS {1} \
    CONFIG.C_TILE0_ISP0_NETFPS {30} \
    CONFIG.C_TILE0_ISP1_BASIC_DATA_FORMAT {12} \
    CONFIG.C_TILE0_ISP1_CORE_CLK {600.1} \
    CONFIG.C_TILE0_ISP1_ENABLE_MP {false} \
    CONFIG.C_TILE0_ISP1_GPIO_PS_CHECK {true} \
    CONFIG.C_TILE0_ISP1_GPIO_SELECT {0} \
    CONFIG.C_TILE0_ISP1_IBA4_DATA_FORMAT {12} \
    CONFIG.C_TILE0_ISP1_IBA4_FPS {30} \
    CONFIG.C_TILE0_ISP1_IBA4_VCID {1} \
    CONFIG.C_TILE0_ISP1_IIC_PS_CHECK {true} \
    CONFIG.C_TILE0_ISP1_IIC_SELECT {0} \
    CONFIG.C_TILE0_ISP1_IO_TYPE {2} \
    CONFIG.C_TILE0_ISP1_NETFPS {30} \
    CONFIG.C_TILE0_VIDIN0_TDATA_WIDTH {48} \
    CONFIG.C_TILE0_VIDIN3_TDATA_WIDTH {48} \
    CONFIG.C_TILE0_VIDIN4_TDATA_WIDTH {48} \
    CONFIG.C_TILE1_COMMON_IBA3_FPS {15} \
    CONFIG.C_TILE1_COMMON_IBA3_VCID {3} \
    CONFIG.C_TILE1_DPLL_CLKFBOUT_FRACT {1} \
    CONFIG.C_TILE1_DPLL_CLKFBOUT_MULT {54} \
    CONFIG.C_TILE1_DPLL_CLKOUT2_DIVIDE {6} \
    CONFIG.C_TILE1_DPLL_CLKOUT3_DIVIDE {6} \
    CONFIG.C_TILE1_DPLL_DIVCLK_DIVIDE {2} \
    CONFIG.C_TILE1_ENABLE {true} \
    CONFIG.C_TILE1_ISP0_BASIC_DATA_FORMAT {12} \
    CONFIG.C_TILE1_ISP0_CORE_CLK {600.1} \
    CONFIG.C_TILE1_ISP0_GPIO_PL_WIDTH {1} \
    CONFIG.C_TILE1_ISP0_GPIO_PS_CHECK {true} \
    CONFIG.C_TILE1_ISP0_GPIO_SELECT {0} \
    CONFIG.C_TILE1_ISP0_IBA0_DATA_FORMAT {12} \
    CONFIG.C_TILE1_ISP0_IBA0_FPS {30} \
    CONFIG.C_TILE1_ISP0_IIC_PS_CHECK {true} \
    CONFIG.C_TILE1_ISP0_IIC_SELECT {0} \
    CONFIG.C_TILE1_ISP0_IO_TYPE {2} \
    CONFIG.C_TILE1_ISP0_LIVE_INPUTS {1} \
    CONFIG.C_TILE1_ISP0_NETFPS {30} \
    CONFIG.C_TILE1_ISP1_BASIC_DATA_FORMAT {12} \
    CONFIG.C_TILE1_ISP1_CORE_CLK {600.1} \
    CONFIG.C_TILE1_ISP1_GPIO_PS_CHECK {true} \
    CONFIG.C_TILE1_ISP1_GPIO_SELECT {0} \
    CONFIG.C_TILE1_ISP1_IBA4_DATA_FORMAT {12} \
    CONFIG.C_TILE1_ISP1_IBA4_FPS {30} \
    CONFIG.C_TILE1_ISP1_IBA4_VCID {1} \
    CONFIG.C_TILE1_ISP1_IIC_PS_CHECK {true} \
    CONFIG.C_TILE1_ISP1_IIC_SELECT {0} \
    CONFIG.C_TILE1_ISP1_IO_TYPE {2} \
    CONFIG.C_TILE1_ISP1_LIVE_INPUTS {1} \
    CONFIG.C_TILE1_ISP1_NETFPS {30} \
    CONFIG.C_TILE1_VIDIN0_TDATA_WIDTH {48} \
    CONFIG.C_TILE1_VIDIN3_TDATA_WIDTH {48} \
    CONFIG.C_TILE1_VIDIN4_TDATA_WIDTH {48} \
  ] $visp_ss_0


  set_property -dict [ list \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.PROTOCOL {AXI4LITE} \
   CONFIG.ADDR_WIDTH {12} \
 ] [get_bd_intf_pins $visp_ss_0/S_AXI_LITE]

  set_property -dict [ list \
   CONFIG.CATEGORY {noc} \
   CONFIG.MY_CATEGORY {isp} \
   CONFIG.PHYSICAL_CHANNEL {ISP_TO_NOC_NMU} \
   CONFIG.TILE_INDEX {0} \
   CONFIG.INDEX {0} \
 ] [get_bd_intf_pins $visp_ss_0/TILE0_ISP0_NMU]

  set_property -dict [ list \
   CONFIG.CATEGORY {noc} \
   CONFIG.MY_CATEGORY {isp} \
   CONFIG.PHYSICAL_CHANNEL {ISP_TO_NOC_NMU} \
   CONFIG.TILE_INDEX {0} \
   CONFIG.INDEX {1} \
 ] [get_bd_intf_pins $visp_ss_0/TILE0_ISP1_NMU]

  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.CATEGORY {noc} \
   CONFIG.MY_CATEGORY {isp} \
   CONFIG.PHYSICAL_CHANNEL {NOC_NSU_TO_ISP} \
   CONFIG.TILE_INDEX {0} \
   CONFIG.INDEX {0} \
 ] [get_bd_intf_pins $visp_ss_0/TILE0_ISP_NSU]

  set_property -dict [ list \
   CONFIG.CATEGORY {noc} \
   CONFIG.MY_CATEGORY {isp} \
   CONFIG.PHYSICAL_CHANNEL {ISP_TO_NOC_NMU} \
   CONFIG.TILE_INDEX {1} \
   CONFIG.INDEX {0} \
 ] [get_bd_intf_pins $visp_ss_0/TILE1_ISP0_NMU]

  set_property -dict [ list \
   CONFIG.CATEGORY {noc} \
   CONFIG.MY_CATEGORY {isp} \
   CONFIG.PHYSICAL_CHANNEL {ISP_TO_NOC_NMU} \
   CONFIG.TILE_INDEX {1} \
   CONFIG.INDEX {1} \
 ] [get_bd_intf_pins $visp_ss_0/TILE1_ISP1_NMU]

  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.CATEGORY {noc} \
   CONFIG.MY_CATEGORY {isp} \
   CONFIG.PHYSICAL_CHANNEL {NOC_NSU_TO_ISP} \
   CONFIG.TILE_INDEX {1} \
   CONFIG.INDEX {0} \
 ] [get_bd_intf_pins $visp_ss_0/TILE1_ISP_NSU]

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
   CONFIG.ASSOCIATED_BUSIF {TILE0_ISP1_NMU} \
 ] [get_bd_pins $visp_ss_0/tile0_nmu1_axi_clk]

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
   CONFIG.ASSOCIATED_BUSIF {TILE0_ISP_MIPI_VIDIN4} \
 ] [get_bd_pins $visp_ss_0/tile0_pl_isp_vidin4_clk]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {TILE1_ISP0_NMU} \
 ] [get_bd_pins $visp_ss_0/tile1_nmu0_axi_clk]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {TILE1_ISP1_NMU} \
 ] [get_bd_pins $visp_ss_0/tile1_nmu1_axi_clk]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {TILE1_ISP_NSU} \
 ] [get_bd_pins $visp_ss_0/tile1_nsu_axi_clk]

  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] [get_bd_pins $visp_ss_0/tile1_pl_isp_rstn]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {TILE1_ISP_MIPI_VIDIN0} \
 ] [get_bd_pins $visp_ss_0/tile1_pl_isp_vidin0_clk]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {TILE1_ISP_MIPI_VIDIN4} \
 ] [get_bd_pins $visp_ss_0/tile1_pl_isp_vidin4_clk]

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
    CONFIG.TID_WIDTH.VALUE_MODE {auto} \
  ] $axis_broadcaster_1


  # Create instance: ilvector_logic_0, and set properties
  set ilvector_logic_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilvector_logic ilvector_logic_0 ]
  set_property -dict [list \
    CONFIG.C_OPERATION {or} \
    CONFIG.C_SIZE {1} \
  ] $ilvector_logic_0


  # Create instance: ilvector_logic_1, and set properties
  set ilvector_logic_1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilvector_logic ilvector_logic_1 ]
  set_property -dict [list \
    CONFIG.C_OPERATION {or} \
    CONFIG.C_SIZE {1} \
  ] $ilvector_logic_1


  # Create instance: ilconcat_0, and set properties
  set ilconcat_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat ilconcat_0 ]

  # Create instance: ilconcat_1, and set properties
  set ilconcat_1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat ilconcat_1 ]

  # Create instance: ilconcat_2, and set properties
  set ilconcat_2 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat ilconcat_2 ]

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins smartconnect_0/S00_AXI] [get_bd_intf_pins S00_AXI]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins mipi_csi2_rx_subsyst_0/mipi_phy_if] [get_bd_intf_pins mipi_phy_if_0]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins mipi_csi2_rx_subsyst_1/mipi_phy_if] [get_bd_intf_pins mipi_phy_if_1]
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins axi_noc2_0/S00_INI] [get_bd_intf_pins TILE0_ISP_NSU]
  connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins axi_noc2_0/S01_INI] [get_bd_intf_pins TILE1_ISP_NSU]
  connect_bd_intf_net -intf_net axi_noc2_0_M00_AXI [get_bd_intf_pins axi_noc2_0/M00_AXI] [get_bd_intf_pins visp_ss_0/TILE0_ISP_NSU]
  connect_bd_intf_net -intf_net axi_noc2_0_M00_INI [get_bd_intf_pins M00_INI_isp] [get_bd_intf_pins axi_noc2_0/M00_INI]
  connect_bd_intf_net -intf_net axi_noc2_0_M01_AXI [get_bd_intf_pins axi_noc2_0/M01_AXI] [get_bd_intf_pins visp_ss_0/TILE1_ISP_NSU]
  connect_bd_intf_net -intf_net axis_broadcaster_0_M00_AXIS [get_bd_intf_pins visp_ss_0/TILE0_ISP_MIPI_VIDIN0] [get_bd_intf_pins axis_broadcaster_0/M00_AXIS]
  connect_bd_intf_net -intf_net axis_broadcaster_0_M01_AXIS [get_bd_intf_pins visp_ss_0/TILE0_ISP_MIPI_VIDIN4] [get_bd_intf_pins axis_broadcaster_0/M01_AXIS]
  connect_bd_intf_net -intf_net axis_broadcaster_1_M00_AXIS [get_bd_intf_pins visp_ss_0/TILE1_ISP_MIPI_VIDIN0] [get_bd_intf_pins axis_broadcaster_1/M00_AXIS]
  connect_bd_intf_net -intf_net axis_broadcaster_1_M01_AXIS [get_bd_intf_pins visp_ss_0/TILE1_ISP_MIPI_VIDIN4] [get_bd_intf_pins axis_broadcaster_1/M01_AXIS]
  connect_bd_intf_net -intf_net mipi_csi2_rx_subsyst_0_video_out [get_bd_intf_pins axis_broadcaster_0/S_AXIS] [get_bd_intf_pins mipi_csi2_rx_subsyst_0/video_out]
  connect_bd_intf_net -intf_net mipi_csi2_rx_subsyst_1_video_out [get_bd_intf_pins axis_broadcaster_1/S_AXIS] [get_bd_intf_pins mipi_csi2_rx_subsyst_1/video_out]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins mipi_csi2_rx_subsyst_0/csirxss_s_axi]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins smartconnect_0/M01_AXI] [get_bd_intf_pins mipi_csi2_rx_subsyst_1/csirxss_s_axi]
  connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins smartconnect_0/M02_AXI] [get_bd_intf_pins visp_ss_0/S_AXI_LITE]
  connect_bd_intf_net -intf_net smartconnect_0_M03_AXI [get_bd_intf_pins smartconnect_0/M03_AXI] [get_bd_intf_pins axi_intc_0/s_axi]
  connect_bd_intf_net -intf_net visp_ss_0_TILE0_ISP0_NMU [get_bd_intf_pins visp_ss_0/TILE0_ISP0_NMU] [get_bd_intf_pins axi_noc2_0/S00_AXI]
  connect_bd_intf_net -intf_net visp_ss_0_TILE0_ISP1_NMU [get_bd_intf_pins visp_ss_0/TILE0_ISP1_NMU] [get_bd_intf_pins axi_noc2_0/S01_AXI]
  connect_bd_intf_net -intf_net visp_ss_0_TILE1_ISP0_NMU [get_bd_intf_pins visp_ss_0/TILE1_ISP0_NMU] [get_bd_intf_pins axi_noc2_0/S02_AXI]
  connect_bd_intf_net -intf_net visp_ss_0_TILE1_ISP1_NMU [get_bd_intf_pins visp_ss_0/TILE1_ISP1_NMU] [get_bd_intf_pins axi_noc2_0/S03_AXI]

  # Create port connections
  connect_bd_net -net axi_intc_0_irq  [get_bd_pins axi_intc_0/irq] \
  [get_bd_pins irq_mipi]
  connect_bd_net -net dphy_clk_200M_0_1  [get_bd_pins dphy_clk_200M] \
  [get_bd_pins mipi_csi2_rx_subsyst_0/dphy_clk_200M] \
  [get_bd_pins mipi_csi2_rx_subsyst_1/dphy_clk_200M]
  connect_bd_net -net ext_reset_in_0_1  [get_bd_pins ext_reset_in_0] \
  [get_bd_pins proc_sys_reset_0/ext_reset_in]
  connect_bd_net -net ilconcat_0_dout  [get_bd_pins ilconcat_0/dout] \
  [get_bd_pins axi_intc_0/intr]
  connect_bd_net -net ilconcat_1_dout  [get_bd_pins ilconcat_1/dout] \
  [get_bd_pins axis_broadcaster_0/m_axis_tready]
  connect_bd_net -net ilconcat_2_dout  [get_bd_pins ilconcat_2/dout] \
  [get_bd_pins axis_broadcaster_1/m_axis_tready]
  connect_bd_net -net ilvector_logic_0_Res  [get_bd_pins ilvector_logic_0/Res] \
  [get_bd_pins ilconcat_1/In0] \
  [get_bd_pins ilconcat_1/In1]
  connect_bd_net -net ilvector_logic_1_Res  [get_bd_pins ilvector_logic_1/Res] \
  [get_bd_pins ilconcat_2/In0] \
  [get_bd_pins ilconcat_2/In1]
  connect_bd_net -net lite_aclk_0_1  [get_bd_pins aclk_150] \
  [get_bd_pins proc_sys_reset_0/slowest_sync_clk] \
  [get_bd_pins axi_intc_0/s_axi_aclk] \
  [get_bd_pins axis_broadcaster_0/aclk] \
  [get_bd_pins axis_broadcaster_1/aclk] \
  [get_bd_pins mipi_csi2_rx_subsyst_0/lite_aclk] \
  [get_bd_pins mipi_csi2_rx_subsyst_0/video_aclk] \
  [get_bd_pins mipi_csi2_rx_subsyst_1/lite_aclk] \
  [get_bd_pins mipi_csi2_rx_subsyst_1/video_aclk] \
  [get_bd_pins smartconnect_0/aclk] \
  [get_bd_pins visp_ss_0/s_axi_lite_aclk] \
  [get_bd_pins visp_ss_0/tile0_pl_isp_vidin0_clk] \
  [get_bd_pins visp_ss_0/tile0_pl_isp_vidin4_clk] \
  [get_bd_pins visp_ss_0/tile1_pl_isp_vidin0_clk] \
  [get_bd_pins visp_ss_0/tile1_pl_isp_vidin4_clk]
  connect_bd_net -net mipi_csi2_rx_subsyst_0_csirxss_csi_irq  [get_bd_pins mipi_csi2_rx_subsyst_0/csirxss_csi_irq] \
  [get_bd_pins ilconcat_0/In0]
  connect_bd_net -net mipi_csi2_rx_subsyst_0_header_data  [get_bd_pins mipi_csi2_rx_subsyst_0/header_data] \
  [get_bd_pins visp_ss_0/tile0_isp_mipi_vidin0_header_data] \
  [get_bd_pins visp_ss_0/tile0_isp_mipi_vidin4_header_data]
  connect_bd_net -net mipi_csi2_rx_subsyst_0_header_valid  [get_bd_pins mipi_csi2_rx_subsyst_0/header_valid] \
  [get_bd_pins visp_ss_0/tile0_isp_mipi_vidin0_header_valid] \
  [get_bd_pins visp_ss_0/tile0_isp_mipi_vidin4_header_valid]
  connect_bd_net -net mipi_csi2_rx_subsyst_1_csirxss_csi_irq  [get_bd_pins mipi_csi2_rx_subsyst_1/csirxss_csi_irq] \
  [get_bd_pins ilconcat_0/In1]
  connect_bd_net -net mipi_csi2_rx_subsyst_1_header_data  [get_bd_pins mipi_csi2_rx_subsyst_1/header_data] \
  [get_bd_pins visp_ss_0/tile1_isp_mipi_vidin0_header_data] \
  [get_bd_pins visp_ss_0/tile1_isp_mipi_vidin4_header_data]
  connect_bd_net -net mipi_csi2_rx_subsyst_1_header_valid  [get_bd_pins mipi_csi2_rx_subsyst_1/header_valid] \
  [get_bd_pins visp_ss_0/tile1_isp_mipi_vidin0_header_valid] \
  [get_bd_pins visp_ss_0/tile1_isp_mipi_vidin4_header_valid]
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn  [get_bd_pins proc_sys_reset_0/interconnect_aresetn] \
  [get_bd_pins smartconnect_0/aresetn]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn  [get_bd_pins proc_sys_reset_0/peripheral_aresetn] \
  [get_bd_pins axi_intc_0/s_axi_aresetn] \
  [get_bd_pins axis_broadcaster_0/aresetn] \
  [get_bd_pins axis_broadcaster_1/aresetn] \
  [get_bd_pins mipi_csi2_rx_subsyst_0/lite_aresetn] \
  [get_bd_pins mipi_csi2_rx_subsyst_0/video_aresetn] \
  [get_bd_pins mipi_csi2_rx_subsyst_1/lite_aresetn] \
  [get_bd_pins mipi_csi2_rx_subsyst_1/video_aresetn] \
  [get_bd_pins visp_ss_0/s_axi_lite_rstn] \
  [get_bd_pins visp_ss_0/tile0_pl_isp_rstn] \
  [get_bd_pins visp_ss_0/tile1_pl_isp_rstn]
  connect_bd_net -net tile0_ref_dpll_clk_0_1  [get_bd_pins ref_dpll] \
  [get_bd_pins visp_ss_0/tile0_ref_dpll_clk] \
  [get_bd_pins visp_ss_0/tile1_ref_dpll_clk]
  connect_bd_net -net visp_ss_0_TILE0_ISP_MIPI_VIDIN0_tready  [get_bd_pins visp_ss_0/TILE0_ISP_MIPI_VIDIN0_tready] \
  [get_bd_pins ilvector_logic_0/Op1]
  connect_bd_net -net visp_ss_0_TILE0_ISP_MIPI_VIDIN4_tready  [get_bd_pins visp_ss_0/TILE0_ISP_MIPI_VIDIN4_tready] \
  [get_bd_pins ilvector_logic_0/Op2]
  connect_bd_net -net visp_ss_0_TILE1_ISP_MIPI_VIDIN0_tready  [get_bd_pins visp_ss_0/TILE1_ISP_MIPI_VIDIN0_tready] \
  [get_bd_pins ilvector_logic_1/Op1]
  connect_bd_net -net visp_ss_0_TILE1_ISP_MIPI_VIDIN4_tready  [get_bd_pins visp_ss_0/TILE1_ISP_MIPI_VIDIN4_tready] \
  [get_bd_pins ilvector_logic_1/Op2]
  connect_bd_net -net visp_ss_0_tile0_isp0_fusa_irq  [get_bd_pins visp_ss_0/tile0_isp0_fusa_irq] \
  [get_bd_pins tile0_isp0_fusa_irq_0]
  connect_bd_net -net visp_ss_0_tile0_isp0_isp_irq  [get_bd_pins visp_ss_0/tile0_isp0_isp_irq] \
  [get_bd_pins tile0_isp0_isp_irq_0]
  connect_bd_net -net visp_ss_0_tile0_isp1_fusa_irq  [get_bd_pins visp_ss_0/tile0_isp1_fusa_irq] \
  [get_bd_pins tile0_isp1_fusa_irq_0]
  connect_bd_net -net visp_ss_0_tile0_isp1_isp_irq  [get_bd_pins visp_ss_0/tile0_isp1_isp_irq] \
  [get_bd_pins tile0_isp1_isp_irq_0]
  connect_bd_net -net visp_ss_0_tile0_isp_isr_irq  [get_bd_pins visp_ss_0/tile0_isp_isr_irq] \
  [get_bd_pins tile0_isp_isr_irq_0]
  connect_bd_net -net visp_ss_0_tile0_isp_xmpu_interrupt  [get_bd_pins visp_ss_0/tile0_isp_xmpu_interrupt] \
  [get_bd_pins tile0_isp_xmpu_interrupt_0]
  connect_bd_net -net visp_ss_0_tile0_nmu0_axi_clk  [get_bd_pins visp_ss_0/tile0_nmu0_axi_clk] \
  [get_bd_pins axi_noc2_0/aclk0]
  connect_bd_net -net visp_ss_0_tile0_nmu1_axi_clk  [get_bd_pins visp_ss_0/tile0_nmu1_axi_clk] \
  [get_bd_pins axi_noc2_0/aclk1]
  connect_bd_net -net visp_ss_0_tile0_nsu_axi_clk  [get_bd_pins visp_ss_0/tile0_nsu_axi_clk] \
  [get_bd_pins axi_noc2_0/aclk4]
  connect_bd_net -net visp_ss_0_tile1_isp0_fusa_irq  [get_bd_pins visp_ss_0/tile1_isp0_fusa_irq] \
  [get_bd_pins tile1_isp0_fusa_irq_0]
  connect_bd_net -net visp_ss_0_tile1_isp0_isp_irq  [get_bd_pins visp_ss_0/tile1_isp0_isp_irq] \
  [get_bd_pins tile1_isp0_isp_irq_0]
  connect_bd_net -net visp_ss_0_tile1_isp1_fusa_irq  [get_bd_pins visp_ss_0/tile1_isp1_fusa_irq] \
  [get_bd_pins tile1_isp1_fusa_irq_0]
  connect_bd_net -net visp_ss_0_tile1_isp1_isp_irq  [get_bd_pins visp_ss_0/tile1_isp1_isp_irq] \
  [get_bd_pins tile1_isp1_isp_irq_0]
  connect_bd_net -net visp_ss_0_tile1_isp_isr_irq  [get_bd_pins visp_ss_0/tile1_isp_isr_irq] \
  [get_bd_pins tile1_isp_isr_irq_0]
  connect_bd_net -net visp_ss_0_tile1_isp_xmpu_interrupt  [get_bd_pins visp_ss_0/tile1_isp_xmpu_interrupt] \
  [get_bd_pins tile1_isp_xmpu_interrupt_0]
  connect_bd_net -net visp_ss_0_tile1_nmu0_axi_clk  [get_bd_pins visp_ss_0/tile1_nmu0_axi_clk] \
  [get_bd_pins axi_noc2_0/aclk2]
  connect_bd_net -net visp_ss_0_tile1_nmu1_axi_clk  [get_bd_pins visp_ss_0/tile1_nmu1_axi_clk] \
  [get_bd_pins axi_noc2_0/aclk3]
  connect_bd_net -net visp_ss_0_tile1_nsu_axi_clk  [get_bd_pins visp_ss_0/tile1_nsu_axi_clk] \
  [get_bd_pins axi_noc2_0/aclk5]

  # Perform GUI Layout
  regenerate_bd_layout -hierarchy [get_bd_cells /mipi_isp] -layout_string {
   "ActiveEmotionalView":"Default View",
   "Default View_ScaleFactor":"0.220859",
   "Default View_TopLeft":"-679,-9",
   "ExpandedHierarchyInLayout":"",
   "guistr":"# # String gsaved with Nlview 7.8.0 2024-04-26 e1825d835c VDI=44 GEI=38 GUI=JA:21.0 TLS
#  -string -flagsOSRD
preplace port M00_INI_isp -pg 1 -lvl 7 -x 2480 -y 200 -defaultsOSRD
preplace port S00_AXI -pg 1 -lvl 0 -x 0 -y 610 -defaultsOSRD
preplace port mipi_phy_if_0 -pg 1 -lvl 0 -x 0 -y 270 -defaultsOSRD
preplace port mipi_phy_if_1 -pg 1 -lvl 0 -x 0 -y 630 -defaultsOSRD
preplace port TILE0_ISP_NSU -pg 1 -lvl 0 -x 0 -y 140 -defaultsOSRD
preplace port TILE1_ISP_NSU -pg 1 -lvl 0 -x 0 -y 160 -defaultsOSRD
preplace port port-id_aclk_150 -pg 1 -lvl 0 -x 0 -y 690 -defaultsOSRD
preplace port port-id_dphy_clk_200M -pg 1 -lvl 0 -x 0 -y 350 -defaultsOSRD
preplace port port-id_irq_mipi -pg 1 -lvl 7 -x 2480 -y 1200 -defaultsOSRD
preplace port port-id_ext_reset_in_0 -pg 1 -lvl 0 -x 0 -y 710 -defaultsOSRD
preplace port port-id_tile0_isp0_fusa_irq_0 -pg 1 -lvl 7 -x 2480 -y 520 -defaultsOSRD
preplace port port-id_tile0_isp0_isp_irq_0 -pg 1 -lvl 7 -x 2480 -y 540 -defaultsOSRD
preplace port port-id_tile0_isp_isr_irq_0 -pg 1 -lvl 7 -x 2480 -y 600 -defaultsOSRD
preplace port port-id_tile0_isp_xmpu_interrupt_0 -pg 1 -lvl 7 -x 2480 -y 620 -defaultsOSRD
preplace port port-id_ref_dpll -pg 1 -lvl 0 -x 0 -y 860 -defaultsOSRD
preplace port port-id_tile1_isp0_fusa_irq_0 -pg 1 -lvl 7 -x 2480 -y 640 -defaultsOSRD
preplace port port-id_tile1_isp0_isp_irq_0 -pg 1 -lvl 7 -x 2480 -y 660 -defaultsOSRD
preplace port port-id_tile1_isp_isr_irq_0 -pg 1 -lvl 7 -x 2480 -y 720 -defaultsOSRD
preplace port port-id_tile1_isp_xmpu_interrupt_0 -pg 1 -lvl 7 -x 2480 -y 740 -defaultsOSRD
preplace port port-id_tile0_isp1_fusa_irq_0 -pg 1 -lvl 7 -x 2480 -y 560 -defaultsOSRD
preplace port port-id_tile0_isp1_isp_irq_0 -pg 1 -lvl 7 -x 2480 -y 580 -defaultsOSRD
preplace port port-id_tile1_isp1_fusa_irq_0 -pg 1 -lvl 7 -x 2480 -y 680 -defaultsOSRD
preplace port port-id_tile1_isp1_isp_irq_0 -pg 1 -lvl 7 -x 2480 -y 700 -defaultsOSRD
preplace inst mipi_csi2_rx_subsyst_0 -pg 1 -lvl 3 -x 850 -y 330 -defaultsOSRD
preplace inst smartconnect_0 -pg 1 -lvl 2 -x 510 -y 720 -defaultsOSRD
preplace inst mipi_csi2_rx_subsyst_1 -pg 1 -lvl 3 -x 850 -y 690 -defaultsOSRD
preplace inst axi_intc_0 -pg 1 -lvl 6 -x 2310 -y 1190 -defaultsOSRD
preplace inst proc_sys_reset_0 -pg 1 -lvl 1 -x 190 -y 730 -defaultsOSRD
preplace inst axi_noc2_0 -pg 1 -lvl 6 -x 2310 -y 180 -defaultsOSRD
preplace inst visp_ss_0 -pg 1 -lvl 5 -x 1800 -y 530 -defaultsOSRD
preplace inst axis_broadcaster_0 -pg 1 -lvl 4 -x 1260 -y 70 -defaultsOSRD
preplace inst axis_broadcaster_1 -pg 1 -lvl 4 -x 1260 -y 390 -defaultsOSRD
preplace inst ilvector_logic_0 -pg 1 -lvl 5 -x 1800 -y 950 -defaultsOSRD
preplace inst ilvector_logic_1 -pg 1 -lvl 5 -x 1800 -y 1090 -defaultsOSRD
preplace inst ilconcat_0 -pg 1 -lvl 5 -x 1800 -y 1230 -defaultsOSRD
preplace inst ilconcat_1 -pg 1 -lvl 6 -x 2310 -y 910 -defaultsOSRD
preplace inst ilconcat_2 -pg 1 -lvl 6 -x 2310 -y 1050 -defaultsOSRD
preplace netloc axi_intc_0_irq 1 6 1 NJ 1200
preplace netloc dphy_clk_200M_0_1 1 0 3 NJ 350 NJ 350 680
preplace netloc ext_reset_in_0_1 1 0 1 NJ 710
preplace netloc ilconcat_0_dout 1 5 1 2040 1220n
preplace netloc ilconcat_1_dout 1 4 3 1470J 190 2090J 360 2460
preplace netloc ilconcat_2_dout 1 4 3 1450J 1020 2160J 980 2460
preplace netloc ilvector_logic_0_Res 1 5 1 2160 900n
preplace netloc ilvector_logic_1_Res 1 5 1 2160 1040n
preplace netloc lite_aclk_0_1 1 0 6 20 830 370 810 660 510 1020 470 1510 870 2090J
preplace netloc mipi_csi2_rx_subsyst_0_csirxss_csi_irq 1 3 2 1040 1220 NJ
preplace netloc mipi_csi2_rx_subsyst_0_header_data 1 3 2 1060 500 1470
preplace netloc mipi_csi2_rx_subsyst_0_header_valid 1 3 2 1030 510 1460
preplace netloc mipi_csi2_rx_subsyst_1_csirxss_csi_irq 1 3 2 NJ 720 1440
preplace netloc mipi_csi2_rx_subsyst_1_header_data 1 3 2 NJ 780 1460
preplace netloc mipi_csi2_rx_subsyst_1_header_valid 1 3 2 NJ 800 1500
preplace netloc proc_sys_reset_0_interconnect_aresetn 1 1 1 380 740n
preplace netloc proc_sys_reset_0_peripheral_aresetn 1 1 5 360 820 690 520 1070 490 1480 880 2040J
preplace netloc tile0_ref_dpll_clk_0_1 1 0 5 NJ 860 NJ 860 NJ 860 NJ 860 1490
preplace netloc visp_ss_0_TILE0_ISP_MIPI_VIDIN0_tready 1 4 1 1560 290n
preplace netloc visp_ss_0_TILE0_ISP_MIPI_VIDIN4_tready 1 4 1 1530 330n
preplace netloc visp_ss_0_TILE1_ISP_MIPI_VIDIN0_tready 1 4 1 1540 390n
preplace netloc visp_ss_0_TILE1_ISP_MIPI_VIDIN4_tready 1 4 1 1520 430n
preplace netloc visp_ss_0_tile0_isp0_fusa_irq 1 5 2 NJ 520 NJ
preplace netloc visp_ss_0_tile0_isp0_isp_irq 1 5 2 NJ 540 NJ
preplace netloc visp_ss_0_tile0_isp1_fusa_irq 1 5 2 NJ 560 NJ
preplace netloc visp_ss_0_tile0_isp1_isp_irq 1 5 2 NJ 580 NJ
preplace netloc visp_ss_0_tile0_isp_isr_irq 1 5 2 NJ 600 NJ
preplace netloc visp_ss_0_tile0_isp_xmpu_interrupt 1 5 2 NJ 620 NJ
preplace netloc visp_ss_0_tile0_nmu0_axi_clk 1 5 1 2100 190n
preplace netloc visp_ss_0_tile0_nmu1_axi_clk 1 5 1 2110 210n
preplace netloc visp_ss_0_tile0_nsu_axi_clk 1 5 1 2140 270n
preplace netloc visp_ss_0_tile1_isp0_fusa_irq 1 5 2 NJ 640 NJ
preplace netloc visp_ss_0_tile1_isp0_isp_irq 1 5 2 NJ 660 NJ
preplace netloc visp_ss_0_tile1_isp1_fusa_irq 1 5 2 NJ 680 NJ
preplace netloc visp_ss_0_tile1_isp1_isp_irq 1 5 2 NJ 700 NJ
preplace netloc visp_ss_0_tile1_isp_isr_irq 1 5 2 NJ 720 NJ
preplace netloc visp_ss_0_tile1_isp_xmpu_interrupt 1 5 2 NJ 740 NJ
preplace netloc visp_ss_0_tile1_nmu0_axi_clk 1 5 1 2120 230n
preplace netloc visp_ss_0_tile1_nmu1_axi_clk 1 5 1 2150 250n
preplace netloc visp_ss_0_tile1_nsu_axi_clk 1 5 1 2160 290n
preplace netloc Conn1 1 0 2 NJ 610 380J
preplace netloc Conn2 1 0 3 NJ 270 NJ 270 NJ
preplace netloc Conn3 1 0 3 NJ 630 NJ 630 NJ
preplace netloc Conn4 1 0 6 NJ 140 NJ 140 NJ 140 1080J 150 NJ 150 NJ
preplace netloc Conn5 1 0 6 NJ 160 NJ 160 NJ 160 NJ 160 NJ 160 2130J
preplace netloc axi_noc2_0_M00_AXI 1 4 3 1510 170 2040J 10 2460
preplace netloc axi_noc2_0_M00_INI 1 6 1 NJ 200
preplace netloc axi_noc2_0_M01_AXI 1 4 3 1550 180 2130J 350 2460
preplace netloc axis_broadcaster_0_M00_AXIS 1 4 1 1480 50n
preplace netloc axis_broadcaster_0_M01_AXIS 1 4 1 1460 90n
preplace netloc axis_broadcaster_1_M00_AXIS 1 4 1 N 370
preplace netloc axis_broadcaster_1_M01_AXIS 1 4 1 N 410
preplace netloc mipi_csi2_rx_subsyst_0_video_out 1 3 1 1010 50n
preplace netloc mipi_csi2_rx_subsyst_1_video_out 1 3 1 1080 370n
preplace netloc smartconnect_0_M00_AXI 1 2 1 640 290n
preplace netloc smartconnect_0_M01_AXI 1 2 1 670 650n
preplace netloc smartconnect_0_M02_AXI 1 2 3 650 500 1050J 310 1450J
preplace netloc smartconnect_0_M03_AXI 1 2 4 640 1160 NJ 1160 NJ 1160 NJ
preplace netloc visp_ss_0_TILE0_ISP0_NMU 1 5 1 2050 70n
preplace netloc visp_ss_0_TILE0_ISP1_NMU 1 5 1 2060 90n
preplace netloc visp_ss_0_TILE1_ISP0_NMU 1 5 1 2070 110n
preplace netloc visp_ss_0_TILE1_ISP1_NMU 1 5 1 2080 130n
levelinfo -pg 1 0 190 510 850 1260 1800 2310 2480
pagesize -pg 1 -db -bbox -sgen -150 0 2720 1290
"
}

  # Restore current instance
  current_bd_instance $oldCurInst
}


proc available_tcl_procs { } {
   puts "##################################################################"
   puts "# Available Tcl procedures to recreate hierarchical blocks:"
   puts "#"
   puts "#    create_hier_cell_mipi_isp parentCell nameHier"
   puts "#"
   puts "##################################################################"
}

available_tcl_procs

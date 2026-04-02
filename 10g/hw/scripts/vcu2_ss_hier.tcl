
################################################################
# This is a generated script based on design: vcu2_ss
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
# source vcu2_ss_script.tcl

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:vcu2:*\
xilinx.com:ip:axi_gpio:*\
xilinx.com:ip:axi_noc2:*\
xilinx.com:ip:proc_sys_reset:*\
xilinx.com:inline_hdl:ilslice:*\
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


# Hierarchical cell: vcu2_ss
proc create_hier_cell_vcu2_ss { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_vcu2_ss() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_vcu

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_gpio

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M00_INI_vcu

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 vcu_nsu


  # Create pins
  create_bd_pin -dir O -type intr c0_vcu2_irq_error
  create_bd_pin -dir O -type intr c0_vcu2_dec_pintreq
  create_bd_pin -dir O -type intr c0_vcu2_enc_pintreq
  create_bd_pin -dir I -type clk dpll_ref_clk
  create_bd_pin -dir I -type clk aclk_150
  create_bd_pin -dir I -type rst ext_reset_in_2

  # Create instance: vcu2_0, and set properties
  set vcu2_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:vcu2 vcu2_0 ]
  set_property -dict [list \
    CONFIG.C0_DEC_COLOR_DEPTH {1} \
    CONFIG.C0_DEC_COLOR_FORMAT {2} \
    CONFIG.C0_ENC_COLOR_DEPTH {1} \
    CONFIG.C0_ENC_COLOR_FORMAT {2} \
    CONFIG.C0_ENC_FRAME_SIZE {4} \
    CONFIG.C0_ENC_MCU_AND_CORE_CLK {952} \
    CONFIG.C0_ENC_SOURCE_FORMAT {0} \
    CONFIG.C_TARGET_BOARD {1} \
  ] $vcu2_0


  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio axi_gpio_0 ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_DOUT_DEFAULT {0x0000000F} \
    CONFIG.C_GPIO_WIDTH {4} \
  ] $axi_gpio_0


  # Create instance: axi_noc2_0, and set properties
  set axi_noc2_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc2 axi_noc2_0 ]
  set_property -dict [list \
    CONFIG.MI_SIDEBAND_PINS {} \
    CONFIG.NUM_CLKS {5} \
    CONFIG.NUM_MI {1} \
    CONFIG.NUM_NMI {1} \
    CONFIG.NUM_NSI {1} \
    CONFIG.NUM_SI {4} \
    CONFIG.SI_SIDEBAND_PINS {} \
  ] $axi_noc2_0


  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CATEGORY {vcu} \
 ] [get_bd_intf_pins $axi_noc2_0/M00_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.R_TRAFFIC_CLASS {ISOCHRONOUS} \
   CONFIG.W_TRAFFIC_CLASS {ISOCHRONOUS} \
   CONFIG.CONNECTIONS {M00_INI {read_bw {2000} write_bw {800} initial_boot {true} }} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {vcu} \
 ] [get_bd_intf_pins $axi_noc2_0/S00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {1000} write_bw {1000} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}} \
 ] [get_bd_intf_pins $axi_noc2_0/S00_INI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.R_TRAFFIC_CLASS {ISOCHRONOUS} \
   CONFIG.W_TRAFFIC_CLASS {ISOCHRONOUS} \
   CONFIG.CONNECTIONS {M00_INI {read_bw {2000} write_bw {800} initial_boot {true} }} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {vcu} \
 ] [get_bd_intf_pins $axi_noc2_0/S01_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.R_TRAFFIC_CLASS {ISOCHRONOUS} \
   CONFIG.W_TRAFFIC_CLASS {ISOCHRONOUS} \
   CONFIG.CONNECTIONS {M00_INI {read_bw {800} write_bw {1000} initial_boot {true} }} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {vcu} \
 ] [get_bd_intf_pins $axi_noc2_0/S02_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.R_TRAFFIC_CLASS {ISOCHRONOUS} \
   CONFIG.W_TRAFFIC_CLASS {ISOCHRONOUS} \
   CONFIG.CONNECTIONS {M00_INI {read_bw {800} write_bw {1000} initial_boot {true} }} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {vcu} \
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

  # Create instance: proc_sys_reset_2, and set properties
  set proc_sys_reset_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_2 ]

  # Create instance: ilslice_0, and set properties
  set ilslice_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice ilslice_0 ]
  set_property CONFIG.DIN_WIDTH {4} $ilslice_0


  # Create instance: ilslice_1, and set properties
  set ilslice_1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice ilslice_1 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {1} \
    CONFIG.DIN_TO {1} \
    CONFIG.DIN_WIDTH {4} \
  ] $ilslice_1


  # Create instance: ilslice_2, and set properties
  set ilslice_2 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice ilslice_2 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {2} \
    CONFIG.DIN_TO {2} \
    CONFIG.DIN_WIDTH {4} \
  ] $ilslice_2


  # Create instance: ilslice_3, and set properties
  set ilslice_3 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice ilslice_3 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {3} \
    CONFIG.DIN_TO {3} \
    CONFIG.DIN_WIDTH {4} \
  ] $ilslice_3


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins axi_noc2_0/S00_INI] [get_bd_intf_pins vcu_nsu]
  connect_bd_intf_net -intf_net S_AXI_0_1 [get_bd_intf_pins S_AXI_gpio] [get_bd_intf_pins axi_gpio_0/S_AXI]
  connect_bd_intf_net -intf_net S_AXI_LITE_0_1 [get_bd_intf_pins S_AXI_vcu] [get_bd_intf_pins vcu2_0/S_AXI_LITE]
  connect_bd_intf_net -intf_net axi_noc2_0_M00_AXI [get_bd_intf_pins axi_noc2_0/M00_AXI] [get_bd_intf_pins vcu2_0/C0_S_AXI_NOC]
  connect_bd_intf_net -intf_net axi_noc2_0_M00_INI [get_bd_intf_pins M00_INI_vcu] [get_bd_intf_pins axi_noc2_0/M00_INI]
  connect_bd_intf_net -intf_net vcu2_0_C0_DEC_MCU_M_AXI [get_bd_intf_pins vcu2_0/C0_DEC_MCU_M_AXI_NOC] [get_bd_intf_pins axi_noc2_0/S03_AXI]
  connect_bd_intf_net -intf_net vcu2_0_C0_DEC_M_AXI [get_bd_intf_pins vcu2_0/C0_DEC_M_AXI_NOC] [get_bd_intf_pins axi_noc2_0/S02_AXI]
  connect_bd_intf_net -intf_net vcu2_0_C0_ENC_MCU_M_AXI [get_bd_intf_pins vcu2_0/C0_ENC_MCU_M_AXI_NOC] [get_bd_intf_pins axi_noc2_0/S01_AXI]
  connect_bd_intf_net -intf_net vcu2_0_C0_ENC_M_AXI [get_bd_intf_pins vcu2_0/C0_ENC_M_AXI_NOC] [get_bd_intf_pins axi_noc2_0/S00_AXI]

  # Create port connections
  connect_bd_net -net axi_gpio_0_gpio_io_o  [get_bd_pins axi_gpio_0/gpio_io_o] \
  [get_bd_pins ilslice_0/Din] \
  [get_bd_pins ilslice_3/Din] \
  [get_bd_pins ilslice_1/Din] \
  [get_bd_pins ilslice_2/Din]
  connect_bd_net -net dpll_ref_clk_0_1  [get_bd_pins dpll_ref_clk] \
  [get_bd_pins vcu2_0/dpll_ref_clk]
  connect_bd_net -net ext_reset_in_0_1  [get_bd_pins ext_reset_in_2] \
  [get_bd_pins proc_sys_reset_2/ext_reset_in]
  connect_bd_net -net ilslice_0_Dout  [get_bd_pins ilslice_0/Dout] \
  [get_bd_pins vcu2_0/c0_pl_enc_rst_n]
  connect_bd_net -net ilslice_1_Dout  [get_bd_pins ilslice_1/Dout] \
  [get_bd_pins vcu2_0/c0_pl_dec_rst_n]
  connect_bd_net -net ilslice_2_Dout  [get_bd_pins ilslice_2/Dout] \
  [get_bd_pins vcu2_0/c0_raw_rst_n]
  connect_bd_net -net ilslice_3_Dout  [get_bd_pins ilslice_3/Dout] \
  [get_bd_pins vcu2_0/c0_dpll_rst_n]
  connect_bd_net -net proc_sys_reset_2_peripheral_aresetn  [get_bd_pins proc_sys_reset_2/peripheral_aresetn] \
  [get_bd_pins axi_gpio_0/s_axi_aresetn] \
  [get_bd_pins vcu2_0/s_axi_lite_rst_n]
  connect_bd_net -net s_axi_lite_aclk_0_1  [get_bd_pins aclk_150] \
  [get_bd_pins axi_gpio_0/s_axi_aclk] \
  [get_bd_pins proc_sys_reset_2/slowest_sync_clk] \
  [get_bd_pins vcu2_0/s_axi_lite_clk]
  connect_bd_net -net vcu2_0_c0_vcu2_dec_clk0  [get_bd_pins vcu2_0/c0_dec_m_axi_noc_clk] \
  [get_bd_pins axi_noc2_0/aclk2]
  connect_bd_net -net vcu2_0_c0_vcu2_dec_clk_mcu  [get_bd_pins vcu2_0/c0_dec_mcu_m_axi_noc_clk] \
  [get_bd_pins axi_noc2_0/aclk3]
  connect_bd_net -net vcu2_0_c0_vcu2_dec_pintreq  [get_bd_pins vcu2_0/c0_irq_dec_pintreq] \
  [get_bd_pins c0_vcu2_dec_pintreq]
  connect_bd_net -net vcu2_0_c0_vcu2_enc_clk0  [get_bd_pins vcu2_0/c0_enc_m_axi_noc_clk] \
  [get_bd_pins axi_noc2_0/aclk0]
  connect_bd_net -net vcu2_0_c0_vcu2_enc_clk_mcu  [get_bd_pins vcu2_0/c0_enc_mcu_m_axi_noc_clk] \
  [get_bd_pins axi_noc2_0/aclk1]
  connect_bd_net -net vcu2_0_c0_vcu2_enc_pintreq  [get_bd_pins vcu2_0/c0_irq_enc_pintreq] \
  [get_bd_pins c0_vcu2_enc_pintreq]
  connect_bd_net -net vcu2_0_c0_vcu2_irq_error  [get_bd_pins vcu2_0/c0_irq_error] \
  [get_bd_pins c0_vcu2_irq_error]
  connect_bd_net -net vcu2_0_c0_vcu2_nsu_s_axi_clk  [get_bd_pins vcu2_0/c0_s_axi_noc_clk] \
  [get_bd_pins axi_noc2_0/aclk4]

  # Perform GUI Layout
  regenerate_bd_layout -hierarchy [get_bd_cells /vcu2_ss] -layout_string {
   "ExpandedHierarchyInLayout":"",
   "guistr":"# # String gsaved with Nlview 7.8.0 2024-04-26 e1825d835c VDI=44 GEI=38 GUI=JA:21.0 TLS
#  -string -flagsOSRD
preplace inst vcu2_ss -pg 1 -lvl 1 -x 150 -y 100 -defaultsOSRD
levelinfo -pg 1 0 150 300
pagesize -pg 1 -db -bbox -sgen 0 0 300 200
"
}

  # Restore current instance
  current_bd_instance $oldCurInst
}


proc available_tcl_procs { } {
   puts "##################################################################"
   puts "# Available Tcl procedures to recreate hierarchical blocks:"
   puts "#"
   puts "#    create_hier_cell_vcu2_ss parentCell nameHier"
   puts "#"
   puts "##################################################################"
}

available_tcl_procs

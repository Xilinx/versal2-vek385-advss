# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------
################################################################
# This is a generated script based on design: versal_comn_platform
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
# source versal_comn_platform_script.tcl

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axi_gpio:*\
xilinx.com:ip:vcu2:*\
xilinx.com:inline_hdl:ilslice:*\
xilinx.com:ip:axi_noc2:*\
xilinx.com:ip:smartconnect:*\
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 S00_INI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M00_INI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M01_INI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M02_INI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M03_INI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI


  # Create pins
  create_bd_pin -dir I -type clk s_axi_lite_clk
  create_bd_pin -dir I -type rst s_axi_lite_rst_n
  create_bd_pin -dir O -type intr c0_irq_error
  create_bd_pin -dir O -type intr c0_irq_dec_pintreq
  create_bd_pin -dir O -type intr c0_irq_enc_pintreq
  create_bd_pin -dir I -type clk dpll_ref_clk

  # Create instance: vcu_gpio_reset, and set properties
  set vcu_gpio_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio vcu_gpio_reset ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_DOUT_DEFAULT {0x0000000F} \
    CONFIG.C_GPIO_WIDTH {4} \
  ] $vcu_gpio_reset


  # Create instance: vcu2_0, and set properties
  set vcu2_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:vcu2 vcu2_0 ]
  set_property CONFIG.C0_ENC_SOURCE_FORMAT {1} $vcu2_0


  # Create instance: ilslice_vcu_dec_rst_n, and set properties
  set ilslice_vcu_dec_rst_n [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice ilslice_vcu_dec_rst_n ]
  set_property -dict [list \
    CONFIG.DIN_FROM {1} \
    CONFIG.DIN_TO {1} \
    CONFIG.DIN_WIDTH {4} \
  ] $ilslice_vcu_dec_rst_n


  # Create instance: axi_noc_vcu2, and set properties
  set axi_noc_vcu2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc2 axi_noc_vcu2 ]
  set_property -dict [list \
    CONFIG.MI_SIDEBAND_PINS {} \
    CONFIG.NUM_CLKS {5} \
    CONFIG.NUM_NMI {4} \
    CONFIG.NUM_NSI {1} \
    CONFIG.NUM_SI {4} \
    CONFIG.SI_SIDEBAND_PINS {} \
  ] $axi_noc_vcu2


  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CATEGORY {vcu} \
 ] [get_bd_intf_pins $axi_noc_vcu2/M00_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS {M00_INI {read_bw {500} write_bw {500} initial_boot {false}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {vcu} \
 ] [get_bd_intf_pins $axi_noc_vcu2/S00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false}}} \
 ] [get_bd_intf_pins $axi_noc_vcu2/S00_INI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS {M01_INI {read_bw {500} write_bw {500} initial_boot {false}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {vcu} \
 ] [get_bd_intf_pins $axi_noc_vcu2/S01_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS {M02_INI {read_bw {500} write_bw {500} initial_boot {false}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {vcu} \
 ] [get_bd_intf_pins $axi_noc_vcu2/S02_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS {M03_INI {read_bw {500} write_bw {500} initial_boot {false}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {vcu} \
 ] [get_bd_intf_pins $axi_noc_vcu2/S03_AXI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXI} \
 ] [get_bd_pins $axi_noc_vcu2/aclk0]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S01_AXI} \
 ] [get_bd_pins $axi_noc_vcu2/aclk1]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S02_AXI} \
 ] [get_bd_pins $axi_noc_vcu2/aclk2]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S03_AXI} \
 ] [get_bd_pins $axi_noc_vcu2/aclk3]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI} \
 ] [get_bd_pins $axi_noc_vcu2/aclk4]

  # Create instance: ilslice_vcu_dpll_rst_n, and set properties
  set ilslice_vcu_dpll_rst_n [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice ilslice_vcu_dpll_rst_n ]
  set_property -dict [list \
    CONFIG.DIN_FROM {3} \
    CONFIG.DIN_TO {3} \
    CONFIG.DIN_WIDTH {4} \
  ] $ilslice_vcu_dpll_rst_n


  # Create instance: ilslice_vcu_enc_rst_n, and set properties
  set ilslice_vcu_enc_rst_n [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice ilslice_vcu_enc_rst_n ]
  set_property CONFIG.DIN_WIDTH {4} $ilslice_vcu_enc_rst_n


  # Create instance: ilslice_vcu_raw_rst_n, and set properties
  set ilslice_vcu_raw_rst_n [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice ilslice_vcu_raw_rst_n ]
  set_property -dict [list \
    CONFIG.DIN_FROM {2} \
    CONFIG.DIN_TO {2} \
    CONFIG.DIN_WIDTH {4} \
  ] $ilslice_vcu_raw_rst_n


  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_0 ]
  set_property -dict [list \
    CONFIG.NUM_MI {2} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_0


  # Create interface connections
  connect_bd_intf_net -intf_net Master_NoC_M08_INI [get_bd_intf_pins S00_INI] [get_bd_intf_pins axi_noc_vcu2/S00_INI]
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins S00_AXI] [get_bd_intf_pins smartconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net axi_noc2_0_M00_AXI [get_bd_intf_pins vcu2_0/C0_S_AXI_NOC] [get_bd_intf_pins axi_noc_vcu2/M00_AXI]
  connect_bd_intf_net -intf_net axi_noc_vcu2_M00_INI [get_bd_intf_pins M00_INI] [get_bd_intf_pins axi_noc_vcu2/M00_INI]
  connect_bd_intf_net -intf_net axi_noc_vcu2_M01_INI [get_bd_intf_pins M01_INI] [get_bd_intf_pins axi_noc_vcu2/M01_INI]
  connect_bd_intf_net -intf_net axi_noc_vcu2_M02_INI [get_bd_intf_pins M02_INI] [get_bd_intf_pins axi_noc_vcu2/M02_INI]
  connect_bd_intf_net -intf_net axi_noc_vcu2_M03_INI [get_bd_intf_pins M03_INI] [get_bd_intf_pins axi_noc_vcu2/M03_INI]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins vcu2_0/S_AXI_LITE] [get_bd_intf_pins smartconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins smartconnect_0/M01_AXI] [get_bd_intf_pins vcu_gpio_reset/S_AXI]
  connect_bd_intf_net -intf_net vcu2_0_C0_DEC_MCU_M_AXI [get_bd_intf_pins axi_noc_vcu2/S03_AXI] [get_bd_intf_pins vcu2_0/C0_DEC_MCU_M_AXI_NOC]
  connect_bd_intf_net -intf_net vcu2_0_C0_DEC_M_AXI [get_bd_intf_pins axi_noc_vcu2/S02_AXI] [get_bd_intf_pins vcu2_0/C0_DEC_M_AXI_NOC]
  connect_bd_intf_net -intf_net vcu2_0_C0_ENC_MCU_M_AXI [get_bd_intf_pins axi_noc_vcu2/S01_AXI] [get_bd_intf_pins vcu2_0/C0_ENC_MCU_M_AXI_NOC]
  connect_bd_intf_net -intf_net vcu2_0_C0_ENC_M_AXI [get_bd_intf_pins axi_noc_vcu2/S00_AXI] [get_bd_intf_pins vcu2_0/C0_ENC_M_AXI_NOC]

  # Create port connections
  connect_bd_net -net clkx5_wiz_0_clk_out1  [get_bd_pins s_axi_lite_clk] \
  [get_bd_pins vcu2_0/s_axi_lite_clk] \
  [get_bd_pins vcu_gpio_reset/s_axi_aclk] \
  [get_bd_pins smartconnect_0/aclk]
  connect_bd_net -net clkx5_wiz_0_clk_out2  [get_bd_pins dpll_ref_clk] \
  [get_bd_pins vcu2_0/dpll_ref_clk]
  connect_bd_net -net ilslice_0_Dout  [get_bd_pins ilslice_vcu_enc_rst_n/Dout] \
  [get_bd_pins vcu2_0/c0_pl_enc_rst_n]
  connect_bd_net -net ilslice_1_Dout  [get_bd_pins ilslice_vcu_dec_rst_n/Dout] \
  [get_bd_pins vcu2_0/c0_pl_dec_rst_n]
  connect_bd_net -net ilslice_2_Dout  [get_bd_pins ilslice_vcu_raw_rst_n/Dout] \
  [get_bd_pins vcu2_0/c0_raw_rst_n]
  connect_bd_net -net ilslice_3_Dout  [get_bd_pins ilslice_vcu_dpll_rst_n/Dout] \
  [get_bd_pins vcu2_0/c0_dpll_rst_n]
  connect_bd_net -net rst_ps_wizard_0_99M_peripheral_aresetn  [get_bd_pins s_axi_lite_rst_n] \
  [get_bd_pins vcu2_0/s_axi_lite_rst_n] \
  [get_bd_pins vcu_gpio_reset/s_axi_aresetn] \
  [get_bd_pins smartconnect_0/aresetn]
  connect_bd_net -net vcu2_0_c0_vcu2_dec_clk0  [get_bd_pins vcu2_0/c0_dec_m_axi_noc_clk] \
  [get_bd_pins axi_noc_vcu2/aclk2]
  connect_bd_net -net vcu2_0_c0_vcu2_dec_clk_mcu  [get_bd_pins vcu2_0/c0_dec_mcu_m_axi_noc_clk] \
  [get_bd_pins axi_noc_vcu2/aclk3]
  connect_bd_net -net vcu2_0_c0_vcu2_dec_pintreq  [get_bd_pins vcu2_0/c0_irq_dec_pintreq] \
  [get_bd_pins c0_irq_dec_pintreq]
  connect_bd_net -net vcu2_0_c0_vcu2_enc_clk0  [get_bd_pins vcu2_0/c0_enc_m_axi_noc_clk] \
  [get_bd_pins axi_noc_vcu2/aclk0]
  connect_bd_net -net vcu2_0_c0_vcu2_enc_clk_mcu  [get_bd_pins vcu2_0/c0_enc_mcu_m_axi_noc_clk] \
  [get_bd_pins axi_noc_vcu2/aclk1]
  connect_bd_net -net vcu2_0_c0_vcu2_enc_pintreq  [get_bd_pins vcu2_0/c0_irq_enc_pintreq] \
  [get_bd_pins c0_irq_enc_pintreq]
  connect_bd_net -net vcu2_0_c0_vcu2_irq_error  [get_bd_pins vcu2_0/c0_irq_error] \
  [get_bd_pins c0_irq_error]
  connect_bd_net -net vcu2_0_c0_vcu2_nsu_s_axi_clk  [get_bd_pins vcu2_0/c0_s_axi_noc_clk] \
  [get_bd_pins axi_noc_vcu2/aclk4]
  connect_bd_net -net vcu_gpio_reset_gpio_io_o  [get_bd_pins vcu_gpio_reset/gpio_io_o] \
  [get_bd_pins ilslice_vcu_enc_rst_n/Din] \
  [get_bd_pins ilslice_vcu_dec_rst_n/Din] \
  [get_bd_pins ilslice_vcu_raw_rst_n/Din] \
  [get_bd_pins ilslice_vcu_dpll_rst_n/Din]

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

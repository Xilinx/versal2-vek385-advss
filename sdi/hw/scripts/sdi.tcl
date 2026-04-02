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
xilinx.com:ip:axi_noc2:*\
xilinx.com:ip:smartconnect:*\
xilinx.com:ip:axi_intc:*\
xilinx.com:inline_hdl:ilconcat:*\
xilinx.com:ip:axi_gpio:*\
xilinx.com:ip:axi_iic:*\
xilinx.com:ip:proc_sys_reset:*\
xilinx.com:ip:util_vector_logic:*\
xilinx.com:ip:xpm_cdc_gen:*\
xilinx.com:ip:clkx5_wiz:*\
xilinx.com:ip:axi_quad_spi:*\
xilinx.com:ip:xlconstant:*\
xilinx.com:ip:v_uhdsdi_audio:*\
xilinx.com:ip:v_smpte_uhdsdi_rx_ss:*\
xilinx.com:ip:v_frmbuf_wr:*\
xilinx.com:inline_hdl:ilslice:*\
xilinx.com:ip:axis_data_fifo:*\
xilinx.com:ip:axis_subset_converter:*\
xilinx.com:ip:v_proc_ss:*\
xilinx.com:ip:v_smpte_uhdsdi_tx_ss:*\
xilinx.com:ip:v_mix:*\
xilinx.com:ip:bufg_gt:*\
xilinx.com:ip:v_vid_gt_bridge:*\
xilinx.com:ip:util_ds_buf:*\
xilinx.com:ip:gtwiz_versal:*\
xilinx.com:ip:axis_ila:*\
xilinx.com:ip:axis_vio:*\
xilinx.com:ip:picxo_fracxo:*\
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


# Hierarchical cell: hier_constant
proc create_hier_cell_hier_constant { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_hier_constant() - Empty argument(s)!"}
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

  # Create pins
  create_bd_pin -dir O -from 0 -to 0 dout
  create_bd_pin -dir O -from 21 -to 0 dout1

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant xlconstant_0 ]
  set_property CONFIG.CONST_VAL {0} $xlconstant_0


  # Create instance: xlconstant_3, and set properties
  set xlconstant_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant xlconstant_3 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {22} \
  ] $xlconstant_3


  # Create port connections
  connect_bd_net -net xlconstant_0_dout  [get_bd_pins xlconstant_0/dout] \
  [get_bd_pins dout]
  connect_bd_net -net xlconstant_3_dout  [get_bd_pins xlconstant_3/dout] \
  [get_bd_pins dout1]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: Picxo_Heir
proc create_hier_cell_Picxo_Heir { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_Picxo_Heir() - Empty argument(s)!"}
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

  # Create pins
  create_bd_pin -dir O -from 4 -to 0 ACC_DATA
  create_bd_pin -dir I -type rst RESET_I
  create_bd_pin -dir I -type clk TXOUTCLK_I_0
  create_bd_pin -dir I -type clk clk_freerun
  create_bd_pin -dir O -from 0 -to 0 dout
  create_bd_pin -dir I -type clk rx_lnk_clk

  # Create instance: axis_ila_0, and set properties
  set axis_ila_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_ila axis_ila_0 ]
  set_property -dict [list \
    CONFIG.ALL_PROBE_SAME_MU_CNT {2} \
    CONFIG.C_EN_AXIS_IF {0} \
    CONFIG.C_INPUT_PIPE_STAGES {2} \
    CONFIG.C_MON_TYPE {Net_Probes} \
    CONFIG.C_NUM_OF_PROBES {10} \
    CONFIG.C_PROBE0_MU_CNT {2} \
    CONFIG.C_PROBE0_WIDTH {21} \
    CONFIG.C_PROBE10_MU_CNT {2} \
    CONFIG.C_PROBE10_WIDTH {5} \
    CONFIG.C_PROBE1_MU_CNT {2} \
    CONFIG.C_PROBE1_WIDTH {22} \
    CONFIG.C_PROBE2_MU_CNT {2} \
    CONFIG.C_PROBE2_WIDTH {1} \
    CONFIG.C_PROBE3_MU_CNT {2} \
    CONFIG.C_PROBE4_MU_CNT {2} \
    CONFIG.C_PROBE5_MU_CNT {2} \
    CONFIG.C_PROBE6_MU_CNT {2} \
    CONFIG.C_PROBE7_MU_CNT {2} \
    CONFIG.C_PROBE8_MU_CNT {2} \
    CONFIG.C_PROBE9_MU_CNT {2} \
    CONFIG.C_PROBE9_WIDTH {5} \
  ] $axis_ila_0


  # Create instance: axis_vio_1, and set properties
  set axis_vio_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_vio axis_vio_1 ]
  set_property -dict [list \
    CONFIG.C_NUM_PROBE_IN {0} \
    CONFIG.C_NUM_PROBE_OUT {6} \
    CONFIG.C_PROBE_OUT0_INIT_VAL {0x08} \
    CONFIG.C_PROBE_OUT0_WIDTH {5} \
    CONFIG.C_PROBE_OUT12_WIDTH {1} \
    CONFIG.C_PROBE_OUT13_WIDTH {1} \
    CONFIG.C_PROBE_OUT14_WIDTH {1} \
    CONFIG.C_PROBE_OUT1_INIT_VAL {0x10} \
    CONFIG.C_PROBE_OUT1_WIDTH {5} \
    CONFIG.C_PROBE_OUT2_INIT_VAL {0x0200} \
    CONFIG.C_PROBE_OUT2_WIDTH {16} \
    CONFIG.C_PROBE_OUT3_INIT_VAL {0x0200} \
    CONFIG.C_PROBE_OUT3_WIDTH {16} \
    CONFIG.C_PROBE_OUT4_INIT_VAL {0x7} \
    CONFIG.C_PROBE_OUT4_WIDTH {4} \
    CONFIG.C_PROBE_OUT5_INIT_VAL {0x0003FF} \
    CONFIG.C_PROBE_OUT5_WIDTH {24} \
    CONFIG.C_PROBE_OUT6_WIDTH {1} \
  ] $axis_vio_1


  # Create instance: hier_constant
  create_hier_cell_hier_constant $hier_obj hier_constant

  # Create instance: picxo_fracxo_0, and set properties
  set picxo_fracxo_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:picxo_fracxo picxo_fracxo_0 ]
  set_property -dict [list \
    CONFIG.GT_TYPE {GTY} \
    CONFIG.HOLD {false} \
    CONFIG.PRESCALER {false} \
  ] $picxo_fracxo_0


  # Create instance: xlconstant_1, and set properties
  set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant xlconstant_1 ]

  # Create instance: xpm_cdc_gen_0, and set properties
  set xpm_cdc_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xpm_cdc_gen xpm_cdc_gen_0 ]
  set_property CONFIG.WIDTH {1} $xpm_cdc_gen_0


  # Create instance: xpm_cdc_gen_1, and set properties
  set xpm_cdc_gen_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xpm_cdc_gen xpm_cdc_gen_1 ]
  set_property CONFIG.WIDTH {21} $xpm_cdc_gen_1


  # Create instance: xpm_cdc_gen_2, and set properties
  set xpm_cdc_gen_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xpm_cdc_gen xpm_cdc_gen_2 ]
  set_property CONFIG.WIDTH {22} $xpm_cdc_gen_2


  # Create instance: xpm_cdc_gen_3, and set properties
  set xpm_cdc_gen_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xpm_cdc_gen xpm_cdc_gen_3 ]
  set_property CONFIG.WIDTH {1} $xpm_cdc_gen_3


  # Create instance: xpm_cdc_gen_4, and set properties
  set xpm_cdc_gen_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xpm_cdc_gen xpm_cdc_gen_4 ]
  set_property CONFIG.WIDTH {1} $xpm_cdc_gen_4


  # Create instance: xpm_cdc_gen_5, and set properties
  set xpm_cdc_gen_5 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xpm_cdc_gen xpm_cdc_gen_5 ]
  set_property CONFIG.WIDTH {1} $xpm_cdc_gen_5


  # Create instance: xpm_cdc_gen_6, and set properties
  set xpm_cdc_gen_6 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xpm_cdc_gen xpm_cdc_gen_6 ]
  set_property CONFIG.WIDTH {1} $xpm_cdc_gen_6


  # Create instance: xpm_cdc_gen_7, and set properties
  set xpm_cdc_gen_7 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xpm_cdc_gen xpm_cdc_gen_7 ]
  set_property CONFIG.WIDTH {1} $xpm_cdc_gen_7


  # Create instance: xpm_cdc_gen_8, and set properties
  set xpm_cdc_gen_8 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xpm_cdc_gen xpm_cdc_gen_8 ]
  set_property CONFIG.WIDTH {1} $xpm_cdc_gen_8


  # Create instance: xpm_cdc_gen_9, and set properties
  set xpm_cdc_gen_9 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xpm_cdc_gen xpm_cdc_gen_9 ]
  set_property CONFIG.WIDTH {1} $xpm_cdc_gen_9


  # Create instance: xpm_cdc_gen_10, and set properties
  set xpm_cdc_gen_10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xpm_cdc_gen xpm_cdc_gen_10 ]
  set_property CONFIG.WIDTH {5} $xpm_cdc_gen_10


  # Create instance: xpm_cdc_gen_12, and set properties
  set xpm_cdc_gen_12 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xpm_cdc_gen xpm_cdc_gen_12 ]
  set_property CONFIG.WIDTH {16} $xpm_cdc_gen_12


  # Create instance: xpm_cdc_gen_14, and set properties
  set xpm_cdc_gen_14 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xpm_cdc_gen xpm_cdc_gen_14 ]
  set_property CONFIG.WIDTH {24} $xpm_cdc_gen_14


  # Create instance: xpm_cdc_gen_15, and set properties
  set xpm_cdc_gen_15 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xpm_cdc_gen xpm_cdc_gen_15 ]
  set_property CONFIG.WIDTH {5} $xpm_cdc_gen_15


  # Create instance: xpm_cdc_gen_16, and set properties
  set xpm_cdc_gen_16 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xpm_cdc_gen xpm_cdc_gen_16 ]
  set_property CONFIG.WIDTH {5} $xpm_cdc_gen_16


  # Create instance: xpm_cdc_gen_18, and set properties
  set xpm_cdc_gen_18 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xpm_cdc_gen xpm_cdc_gen_18 ]
  set_property CONFIG.WIDTH {4} $xpm_cdc_gen_18


  # Create instance: xpm_cdc_gen_19, and set properties
  set xpm_cdc_gen_19 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xpm_cdc_gen xpm_cdc_gen_19 ]
  set_property CONFIG.WIDTH {16} $xpm_cdc_gen_19


  # Create port connections
  connect_bd_net -net RESET_I_1  [get_bd_pins RESET_I] \
  [get_bd_pins xpm_cdc_gen_0/src_in]
  connect_bd_net -net TXOUTCLK_I_0_1  [get_bd_pins TXOUTCLK_I_0] \
  [get_bd_pins xpm_cdc_gen_0/dest_clk] \
  [get_bd_pins xpm_cdc_gen_10/src_clk] \
  [get_bd_pins xpm_cdc_gen_14/dest_clk] \
  [get_bd_pins xpm_cdc_gen_15/dest_clk] \
  [get_bd_pins xpm_cdc_gen_16/dest_clk] \
  [get_bd_pins xpm_cdc_gen_18/dest_clk] \
  [get_bd_pins xpm_cdc_gen_19/dest_clk] \
  [get_bd_pins xpm_cdc_gen_1/src_clk] \
  [get_bd_pins xpm_cdc_gen_2/src_clk] \
  [get_bd_pins xpm_cdc_gen_3/src_clk] \
  [get_bd_pins xpm_cdc_gen_4/src_clk] \
  [get_bd_pins xpm_cdc_gen_5/src_clk] \
  [get_bd_pins xpm_cdc_gen_6/src_clk] \
  [get_bd_pins xpm_cdc_gen_7/src_clk] \
  [get_bd_pins xpm_cdc_gen_8/src_clk] \
  [get_bd_pins xpm_cdc_gen_9/src_clk] \
  [get_bd_pins picxo_fracxo_0/TXOUTCLK_I]
  connect_bd_net -net axis_vio_1_probe_out0  [get_bd_pins axis_vio_1/probe_out0] \
  [get_bd_pins xpm_cdc_gen_15/src_in]
  connect_bd_net -net axis_vio_1_probe_out1  [get_bd_pins axis_vio_1/probe_out1] \
  [get_bd_pins xpm_cdc_gen_16/src_in]
  connect_bd_net -net axis_vio_1_probe_out2  [get_bd_pins axis_vio_1/probe_out2] \
  [get_bd_pins xpm_cdc_gen_12/src_in]
  connect_bd_net -net axis_vio_1_probe_out3  [get_bd_pins axis_vio_1/probe_out3] \
  [get_bd_pins xpm_cdc_gen_19/src_in]
  connect_bd_net -net axis_vio_1_probe_out4  [get_bd_pins axis_vio_1/probe_out4] \
  [get_bd_pins xpm_cdc_gen_18/src_in]
  connect_bd_net -net axis_vio_1_probe_out5  [get_bd_pins axis_vio_1/probe_out5] \
  [get_bd_pins xpm_cdc_gen_14/src_in]
  connect_bd_net -net clk_freerun  [get_bd_pins clk_freerun] \
  [get_bd_pins xpm_cdc_gen_0/src_clk] \
  [get_bd_pins xpm_cdc_gen_10/dest_clk] \
  [get_bd_pins xpm_cdc_gen_12/src_clk] \
  [get_bd_pins xpm_cdc_gen_14/src_clk] \
  [get_bd_pins xpm_cdc_gen_15/src_clk] \
  [get_bd_pins xpm_cdc_gen_16/src_clk] \
  [get_bd_pins xpm_cdc_gen_18/src_clk] \
  [get_bd_pins xpm_cdc_gen_19/src_clk] \
  [get_bd_pins xpm_cdc_gen_1/dest_clk] \
  [get_bd_pins xpm_cdc_gen_2/dest_clk] \
  [get_bd_pins xpm_cdc_gen_3/dest_clk] \
  [get_bd_pins xpm_cdc_gen_4/dest_clk] \
  [get_bd_pins xpm_cdc_gen_5/dest_clk] \
  [get_bd_pins xpm_cdc_gen_6/dest_clk] \
  [get_bd_pins xpm_cdc_gen_7/dest_clk] \
  [get_bd_pins xpm_cdc_gen_8/dest_clk] \
  [get_bd_pins xpm_cdc_gen_9/dest_clk] \
  [get_bd_pins axis_ila_0/clk] \
  [get_bd_pins axis_vio_1/clk]
  connect_bd_net -net picxo_fracxo_0_ACC_DATA  [get_bd_pins picxo_fracxo_0/ACC_DATA] \
  [get_bd_pins ACC_DATA] \
  [get_bd_pins xpm_cdc_gen_10/src_in]
  connect_bd_net -net picxo_fracxo_0_CE_DSP_O  [get_bd_pins picxo_fracxo_0/CE_DSP_O] \
  [get_bd_pins xpm_cdc_gen_5/src_in]
  connect_bd_net -net picxo_fracxo_0_CE_PI2_O  [get_bd_pins picxo_fracxo_0/CE_PI2_O] \
  [get_bd_pins xpm_cdc_gen_4/src_in]
  connect_bd_net -net picxo_fracxo_0_CE_PI_O  [get_bd_pins picxo_fracxo_0/CE_PI_O] \
  [get_bd_pins xpm_cdc_gen_3/src_in]
  connect_bd_net -net picxo_fracxo_0_ERROR_O  [get_bd_pins picxo_fracxo_0/ERROR_O] \
  [get_bd_pins xpm_cdc_gen_1/src_in]
  connect_bd_net -net picxo_fracxo_0_OVF_AB  [get_bd_pins picxo_fracxo_0/OVF_AB] \
  [get_bd_pins xpm_cdc_gen_7/src_in]
  connect_bd_net -net picxo_fracxo_0_OVF_INT  [get_bd_pins picxo_fracxo_0/OVF_INT] \
  [get_bd_pins xpm_cdc_gen_9/src_in]
  connect_bd_net -net picxo_fracxo_0_OVF_PD  [get_bd_pins picxo_fracxo_0/OVF_PD] \
  [get_bd_pins xpm_cdc_gen_6/src_in]
  connect_bd_net -net picxo_fracxo_0_OVF_VOLT  [get_bd_pins picxo_fracxo_0/OVF_VOLT] \
  [get_bd_pins xpm_cdc_gen_8/src_in]
  connect_bd_net -net picxo_fracxo_0_VOLT_O  [get_bd_pins picxo_fracxo_0/VOLT_O] \
  [get_bd_pins xpm_cdc_gen_2/src_in]
  connect_bd_net -net rx_lnk_clk_1  [get_bd_pins rx_lnk_clk] \
  [get_bd_pins xpm_cdc_gen_12/dest_clk] \
  [get_bd_pins picxo_fracxo_0/REF_CLK_I]
  connect_bd_net -net xlconstant_0_dout  [get_bd_pins hier_constant/dout] \
  [get_bd_pins picxo_fracxo_0/OFFSET_EN] \
  [get_bd_pins picxo_fracxo_0/DON_I]
  connect_bd_net -net xlconstant_1_dout  [get_bd_pins xlconstant_1/dout] \
  [get_bd_pins dout]
  connect_bd_net -net xlconstant_3_dout  [get_bd_pins hier_constant/dout1] \
  [get_bd_pins picxo_fracxo_0/OFFSET_PPM]
  connect_bd_net -net xpm_cdc_gen_0_dest_out  [get_bd_pins xpm_cdc_gen_0/dest_out] \
  [get_bd_pins picxo_fracxo_0/RESET_I]
  connect_bd_net -net xpm_cdc_gen_10_dest_out  [get_bd_pins xpm_cdc_gen_10/dest_out] \
  [get_bd_pins axis_ila_0/probe9]
  connect_bd_net -net xpm_cdc_gen_12_dest_out  [get_bd_pins xpm_cdc_gen_12/dest_out] \
  [get_bd_pins picxo_fracxo_0/R]
  connect_bd_net -net xpm_cdc_gen_14_dest_out  [get_bd_pins xpm_cdc_gen_14/dest_out] \
  [get_bd_pins picxo_fracxo_0/CE_DSP_RATE]
  connect_bd_net -net xpm_cdc_gen_15_dest_out  [get_bd_pins xpm_cdc_gen_15/dest_out] \
  [get_bd_pins picxo_fracxo_0/G1]
  connect_bd_net -net xpm_cdc_gen_16_dest_out  [get_bd_pins xpm_cdc_gen_16/dest_out] \
  [get_bd_pins picxo_fracxo_0/G2]
  connect_bd_net -net xpm_cdc_gen_18_dest_out  [get_bd_pins xpm_cdc_gen_18/dest_out] \
  [get_bd_pins picxo_fracxo_0/ACC_STEP]
  connect_bd_net -net xpm_cdc_gen_19_dest_out  [get_bd_pins xpm_cdc_gen_19/dest_out] \
  [get_bd_pins picxo_fracxo_0/V]
  connect_bd_net -net xpm_cdc_gen_1_dest_out  [get_bd_pins xpm_cdc_gen_1/dest_out] \
  [get_bd_pins axis_ila_0/probe0]
  connect_bd_net -net xpm_cdc_gen_2_dest_out  [get_bd_pins xpm_cdc_gen_2/dest_out] \
  [get_bd_pins axis_ila_0/probe1]
  connect_bd_net -net xpm_cdc_gen_3_dest_out  [get_bd_pins xpm_cdc_gen_3/dest_out] \
  [get_bd_pins axis_ila_0/probe2]
  connect_bd_net -net xpm_cdc_gen_4_dest_out  [get_bd_pins xpm_cdc_gen_4/dest_out] \
  [get_bd_pins axis_ila_0/probe3]
  connect_bd_net -net xpm_cdc_gen_5_dest_out  [get_bd_pins xpm_cdc_gen_5/dest_out] \
  [get_bd_pins axis_ila_0/probe4]
  connect_bd_net -net xpm_cdc_gen_6_dest_out  [get_bd_pins xpm_cdc_gen_6/dest_out] \
  [get_bd_pins axis_ila_0/probe5]
  connect_bd_net -net xpm_cdc_gen_7_dest_out  [get_bd_pins xpm_cdc_gen_7/dest_out] \
  [get_bd_pins axis_ila_0/probe6]
  connect_bd_net -net xpm_cdc_gen_8_dest_out  [get_bd_pins xpm_cdc_gen_8/dest_out] \
  [get_bd_pins axis_ila_0/probe7]
  connect_bd_net -net xpm_cdc_gen_9_dest_out  [get_bd_pins xpm_cdc_gen_9/dest_out] \
  [get_bd_pins axis_ila_0/probe8]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: gt_hier
proc create_hier_cell_gt_hier { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_gt_hier() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 SDI_TX_PHY_SB_CTRL

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 SDI_TX_PHY_SB_STS

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 SDI_TX_AXI4S_CH0

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 SDI_RX_PHY_SB_STS

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 SDI_RX_PHY_SB_CTRL

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 SDI_RX_AXI4S_CH0

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 gt_refclk

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 gt_refclk2

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 GT_Serial_0


  # Create pins
  create_bd_pin -dir O -type clk clk_rxusrclk
  create_bd_pin -dir I -type clk clk_freerun
  create_bd_pin -dir I -type rst gt_ctrl_aresetn
  create_bd_pin -dir I -from 7 -to 0 sdi_gt_ctrl
  create_bd_pin -dir O -type gt_usrclk clk_txusrclk
  create_bd_pin -dir I -from 31 -to 0 QUAD0_gpi_0
  create_bd_pin -dir O -from 31 -to 0 QUAD0_gpo_0
  create_bd_pin -dir I -type rst RESET_I

  # Create instance: bufg_gt, and set properties
  set bufg_gt [ create_bd_cell -type ip -vlnv xilinx.com:ip:bufg_gt bufg_gt ]

  # Create instance: v_vid_gt_bridge_0, and set properties
  set v_vid_gt_bridge_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_vid_gt_bridge v_vid_gt_bridge_0 ]
  set_property -dict [list \
    CONFIG.GT_TYPE {GTYP} \
    CONFIG.c_picxo {1} \
    CONFIG.c_protocol {1} \
  ] $v_vid_gt_bridge_0


  # Create instance: util_ds_buf_1, and set properties
  set util_ds_buf_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf util_ds_buf_1 ]
  set_property CONFIG.C_BUF_TYPE {IBUFDSGTE} $util_ds_buf_1


  # Create instance: bufg_gt_1, and set properties
  set bufg_gt_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:bufg_gt bufg_gt_1 ]

  # Create instance: util_ds_buf, and set properties
  set util_ds_buf [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf util_ds_buf ]
  set_property CONFIG.C_BUF_TYPE {IBUFDSGTE} $util_ds_buf


  # Create instance: gtwiz_versal_0, and set properties
  set gtwiz_versal_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:gtwiz_versal gtwiz_versal_0 ]
  set_property -dict [list \
    CONFIG.INTF0_GT_SETTINGS(GT_DIRECTION) {DUPLEX} \
    CONFIG.INTF0_GT_SETTINGS(GT_TYPE) {GTYP} \
    CONFIG.INTF0_GT_SETTINGS(LR0_SETTINGS) {TX_LINE_RATE 11.88 TX_PLL_TYPE LCPLL TX_REFCLK_FREQUENCY 148.5 TX_DATA_ENCODING RAW TX_USER_DATA_WIDTH 40 TX_INT_DATA_WIDTH 40 TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE\
TXOUTCLKPMA TX_REFCLK_SOURCE R0 TX_PIPM_ENABLE true RX_LINE_RATE 11.88 RX_PLL_TYPE LCPLL RX_REFCLK_FREQUENCY 148.5 RX_DATA_DECODING RAW RX_USER_DATA_WIDTH 40 RX_INT_DATA_WIDTH 40 RX_BUFFER_MODE 1 RX_OUTCLK_SOURCE\
RXOUTCLKPMA RX_PPM_OFFSET 1200 INS_LOSS_NYQ 20 RX_REFCLK_SOURCE R0 RX_TERMINATION_PROG_VALUE 800} \
    CONFIG.INTF0_GT_SETTINGS(LR1_SETTINGS) {TX_LINE_RATE 11.868 TX_PLL_TYPE LCPLL TX_REFCLK_FREQUENCY 148.35 TX_DATA_ENCODING RAW TX_USER_DATA_WIDTH 40 TX_INT_DATA_WIDTH 40 TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE\
TXOUTCLKPMA TX_REFCLK_SOURCE R1 TX_PIPM_ENABLE true RX_LINE_RATE 11.868 RX_PLL_TYPE LCPLL RX_REFCLK_FREQUENCY 148.35 RX_DATA_DECODING RAW RX_USER_DATA_WIDTH 40 RX_INT_DATA_WIDTH 40 RX_BUFFER_MODE 1 RX_OUTCLK_SOURCE\
RXOUTCLKPMA RX_PPM_OFFSET 1200 INS_LOSS_NYQ 20 RX_REFCLK_SOURCE R1 RX_TERMINATION_PROG_VALUE 800} \
    CONFIG.INTF0_GT_SETTINGS(LR2_SETTINGS) {TX_LINE_RATE 5.94 TX_PLL_TYPE LCPLL TX_REFCLK_FREQUENCY 148.5 TX_DATA_ENCODING RAW TX_USER_DATA_WIDTH 40 TX_INT_DATA_WIDTH 40 TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE\
TXOUTCLKPMA TX_REFCLK_SOURCE R0 TX_PIPM_ENABLE true RX_LINE_RATE 5.94 RX_PLL_TYPE LCPLL RX_REFCLK_FREQUENCY 148.5 RX_DATA_DECODING RAW RX_USER_DATA_WIDTH 40 RX_INT_DATA_WIDTH 40 RX_BUFFER_MODE 1 RX_OUTCLK_SOURCE\
RXOUTCLKPMA RX_PPM_OFFSET 1200 INS_LOSS_NYQ 20 RX_REFCLK_SOURCE R0 RX_TERMINATION_PROG_VALUE 800} \
    CONFIG.INTF0_GT_SETTINGS(LR3_SETTINGS) {TX_LINE_RATE 5.934 TX_PLL_TYPE LCPLL TX_REFCLK_FREQUENCY 148.35 TX_DATA_ENCODING RAW TX_USER_DATA_WIDTH 40 TX_INT_DATA_WIDTH 40 TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE\
TXOUTCLKPMA TX_REFCLK_SOURCE R1 TX_PIPM_ENABLE true RX_LINE_RATE 5.934 RX_PLL_TYPE LCPLL RX_REFCLK_FREQUENCY 148.35 RX_DATA_DECODING RAW RX_USER_DATA_WIDTH 40 RX_INT_DATA_WIDTH 40 RX_BUFFER_MODE 1 RX_OUTCLK_SOURCE\
RXOUTCLKPMA RX_PPM_OFFSET 1200 INS_LOSS_NYQ 20 RX_REFCLK_SOURCE R1 RX_TERMINATION_PROG_VALUE 800} \
    CONFIG.INTF0_GT_SETTINGS(LR4_SETTINGS) {TX_LINE_RATE 2.97 TX_PLL_TYPE LCPLL TX_REFCLK_FREQUENCY 148.5 TX_DATA_ENCODING RAW TX_USER_DATA_WIDTH 20 TX_INT_DATA_WIDTH 20 TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE\
TXOUTCLKPMA TX_REFCLK_SOURCE R0 TX_PIPM_ENABLE true RX_LINE_RATE 2.97 RX_PLL_TYPE LCPLL RX_REFCLK_FREQUENCY 148.5 RX_DATA_DECODING RAW RX_USER_DATA_WIDTH 20 RX_INT_DATA_WIDTH 20 RX_BUFFER_MODE 1 RX_OUTCLK_SOURCE\
RXOUTCLKPMA RX_PPM_OFFSET 1200 INS_LOSS_NYQ 20 RX_REFCLK_SOURCE R0 RX_TERMINATION_PROG_VALUE 800} \
    CONFIG.INTF0_GT_SETTINGS(LR5_SETTINGS) {TX_LINE_RATE 2.967 TX_PLL_TYPE LCPLL TX_REFCLK_FREQUENCY 148.35 TX_DATA_ENCODING RAW TX_USER_DATA_WIDTH 20 TX_INT_DATA_WIDTH 20 TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE\
TXOUTCLKPMA TX_REFCLK_SOURCE R1 TX_PIPM_ENABLE true RX_LINE_RATE 2.967 RX_PLL_TYPE LCPLL RX_REFCLK_FREQUENCY 148.35 RX_DATA_DECODING RAW RX_USER_DATA_WIDTH 20 RX_INT_DATA_WIDTH 20 RX_BUFFER_MODE 1 RX_OUTCLK_SOURCE\
RXOUTCLKPMA RX_PPM_OFFSET 1200 INS_LOSS_NYQ 20 RX_REFCLK_SOURCE R1 RX_TERMINATION_PROG_VALUE 800} \
    CONFIG.INTF0_GT_SETTINGS(LR6_SETTINGS) {TX_LINE_RATE 1.485 TX_PLL_TYPE LCPLL TX_REFCLK_FREQUENCY 148.5 TX_DATA_ENCODING RAW TX_USER_DATA_WIDTH 20 TX_INT_DATA_WIDTH 20 TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE\
TXOUTCLKPMA TX_REFCLK_SOURCE R0 TX_PIPM_ENABLE true RX_LINE_RATE 1.485 RX_PLL_TYPE LCPLL RX_REFCLK_FREQUENCY 148.5 RX_DATA_DECODING RAW RX_USER_DATA_WIDTH 20 RX_INT_DATA_WIDTH 20 RX_BUFFER_MODE 1 RX_OUTCLK_SOURCE\
RXOUTCLKPMA RX_PPM_OFFSET 1200 INS_LOSS_NYQ 20 RX_REFCLK_SOURCE R0 RX_TERMINATION_PROG_VALUE 800} \
    CONFIG.INTF0_GT_SETTINGS(LR7_SETTINGS) {TX_LINE_RATE 1.4835 TX_PLL_TYPE LCPLL TX_REFCLK_FREQUENCY 148.35 TX_DATA_ENCODING RAW TX_USER_DATA_WIDTH 20 TX_INT_DATA_WIDTH 20 TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE\
TXOUTCLKPMA TX_REFCLK_SOURCE R1 TX_PIPM_ENABLE true RX_LINE_RATE 1.4835 RX_PLL_TYPE LCPLL RX_REFCLK_FREQUENCY 148.35 RX_DATA_DECODING RAW RX_USER_DATA_WIDTH 20 RX_INT_DATA_WIDTH 20 RX_BUFFER_MODE 1 RX_OUTCLK_SOURCE\
RXOUTCLKPMA RX_PPM_OFFSET 1200 INS_LOSS_NYQ 20 RX_REFCLK_SOURCE R1 RX_TERMINATION_PROG_VALUE 800} \
    CONFIG.INTF0_GT_SETTINGS(LR8_SETTINGS) {TX_LINE_RATE 2.97 TX_PLL_TYPE LCPLL TX_REFCLK_FREQUENCY 148.5 TX_DATA_ENCODING RAW TX_USER_DATA_WIDTH 20 TX_INT_DATA_WIDTH 20 TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE\
TXOUTCLKPMA TX_REFCLK_SOURCE R0 TX_PIPM_ENABLE true RX_LINE_RATE 2.97 RX_PLL_TYPE LCPLL RX_REFCLK_FREQUENCY 148.5 RX_DATA_DECODING RAW RX_USER_DATA_WIDTH 20 RX_INT_DATA_WIDTH 20 RX_BUFFER_MODE 1 RX_OUTCLK_SOURCE\
RXOUTCLKPMA RX_PPM_OFFSET 1200 INS_LOSS_NYQ 20 RX_REFCLK_SOURCE R0 RX_TERMINATION_PROG_VALUE 800} \
    CONFIG.INTF0_GT_SETTINGS(LR9_SETTINGS) {TX_LINE_RATE 2.967 TX_PLL_TYPE LCPLL TX_REFCLK_FREQUENCY 148.35 TX_DATA_ENCODING RAW TX_USER_DATA_WIDTH 20 TX_INT_DATA_WIDTH 20 TX_BUFFER_MODE 1 TX_OUTCLK_SOURCE\
TXOUTCLKPMA TX_REFCLK_SOURCE R1 TX_PIPM_ENABLE true RX_LINE_RATE 2.967 RX_PLL_TYPE LCPLL RX_REFCLK_FREQUENCY 148.35 RX_DATA_DECODING RAW RX_USER_DATA_WIDTH 20 RX_INT_DATA_WIDTH 20 RX_BUFFER_MODE 1 RX_OUTCLK_SOURCE\
RXOUTCLKPMA RX_PPM_OFFSET 1200 INS_LOSS_NYQ 20 RX_REFCLK_SOURCE R1 RX_TERMINATION_PROG_VALUE 800} \
    CONFIG.INTF0_NO_OF_LANES {1} \
    CONFIG.INTF0_PARENTID {versal_gen2_platform_v_vid_gt_bridge_0_0} \
    CONFIG.INTF_PARENT_PIN_LIST {QUAD0_RX0 /sdi/peripheral_gt_heir/gt_hier/v_vid_gt_bridge_0/GT_RX0 QUAD0_TX0 /sdi/peripheral_gt_heir/gt_hier/v_vid_gt_bridge_0/GT_TX0} \
    CONFIG.IS_PL_GTS_AVAILABLE {true} \
    CONFIG.QUAD0_OUTCLK_VALUES {CH0_TXOUTCLK 297.000003 CH0_RXOUTCLK 297.000003 CH1_TXOUTCLK 322.266 CH1_RXOUTCLK 322.266 CH2_TXOUTCLK 322.266 CH2_RXOUTCLK 322.266 CH3_TXOUTCLK 322.266 CH3_RXOUTCLK 322.266}\
\
    CONFIG.QUAD0_PROT0_LANES {1} \
    CONFIG.QUAD0_PROT0_RX1_EN {false} \
    CONFIG.QUAD0_PROT0_RX2_EN {false} \
    CONFIG.QUAD0_PROT0_RX3_EN {false} \
    CONFIG.QUAD0_PROT0_TX1_EN {false} \
    CONFIG.QUAD0_PROT0_TX2_EN {false} \
    CONFIG.QUAD0_PROT0_TX3_EN {false} \
    CONFIG.QUAD0_REFCLK_STRING {HSCLK0_LCPLLGTREFCLK0 refclk_PROT0_R0_148.5_MHz_unique1 HSCLK0_LCPLLGTREFCLK1 refclk_PROT0_R1_148.35_MHz_unique1} \
    CONFIG.QUAD0_USAGE {TX_QUAD_CH {TXQuad_0_/versal_gen2_platform_gtwiz_versal_0_0/versal_gen2_platform_gtwiz_versal_0_0_gt_quad_base_0 {/versal_gen2_platform_gtwiz_versal_0_0/versal_gen2_platform_gtwiz_versal_0_0_gt_quad_base_0\
versal_gen2_platform_v_vid_gt_bridge_0_0.IP_CH0,undef,undef,undef MSTRCLK 1,0,0,0 IS_CURRENT_QUAD 1}} RX_QUAD_CH {RXQuad_0_/versal_gen2_platform_gtwiz_versal_0_0/versal_gen2_platform_gtwiz_versal_0_0_gt_quad_base_0\
{/versal_gen2_platform_gtwiz_versal_0_0/versal_gen2_platform_gtwiz_versal_0_0_gt_quad_base_0 versal_gen2_platform_v_vid_gt_bridge_0_0.IP_CH0,undef,undef,undef MSTRCLK 1,0,0,0 IS_CURRENT_QUAD 1}}} \
  ] $gtwiz_versal_0

  set_property -dict [list \
    CONFIG.INTF0_GT_SETTINGS.VALUE_MODE {auto} \
    CONFIG.INTF0_PARENTID.VALUE_MODE {auto} \
    CONFIG.INTF_PARENT_PIN_LIST.VALUE_MODE {auto} \
    CONFIG.QUAD0_USAGE.VALUE_MODE {auto} \
  ] $gtwiz_versal_0


  # Create instance: Picxo_Heir
  create_hier_cell_Picxo_Heir $hier_obj Picxo_Heir

  # Create interface connections
  connect_bd_intf_net -intf_net RX_Heir_M_AXIS_CTRL_SB_RX [get_bd_intf_pins SDI_RX_PHY_SB_CTRL] [get_bd_intf_pins v_vid_gt_bridge_0/SDI_RX_PHY_SB_CTRL]
  connect_bd_intf_net -intf_net S_AXIS_RX_1 [get_bd_intf_pins SDI_RX_AXI4S_CH0] [get_bd_intf_pins v_vid_gt_bridge_0/SDI_RX_AXI4S_CH0]
  connect_bd_intf_net -intf_net S_AXIS_STS_SB_RX_1 [get_bd_intf_pins SDI_RX_PHY_SB_STS] [get_bd_intf_pins v_vid_gt_bridge_0/SDI_RX_PHY_SB_STS]
  connect_bd_intf_net -intf_net Tx_Heir_M_AXIS_CTRL_SB_TX [get_bd_intf_pins SDI_TX_PHY_SB_CTRL] [get_bd_intf_pins v_vid_gt_bridge_0/SDI_TX_PHY_SB_CTRL]
  connect_bd_intf_net -intf_net Tx_Heir_M_AXIS_TX [get_bd_intf_pins SDI_TX_AXI4S_CH0] [get_bd_intf_pins v_vid_gt_bridge_0/SDI_TX_AXI4S_CH0]
  connect_bd_intf_net -intf_net gtwiz_versal_0_Quad0_GT_Serial [get_bd_intf_pins GT_Serial_0] [get_bd_intf_pins gtwiz_versal_0/Quad0_GT_Serial]
  connect_bd_intf_net -intf_net v_vid_gt_bridge_0_GT_RX0 [get_bd_intf_pins v_vid_gt_bridge_0/GT_RX0] [get_bd_intf_pins gtwiz_versal_0/INTF0_RX0_GT_IP_Interface]
  connect_bd_intf_net -intf_net v_vid_gt_bridge_0_GT_TX0 [get_bd_intf_pins v_vid_gt_bridge_0/GT_TX0] [get_bd_intf_pins gtwiz_versal_0/INTF0_TX0_GT_IP_Interface]
  connect_bd_intf_net -intf_net v_vid_gt_bridge_0_SDI_TX_PHY_SB_STS [get_bd_intf_pins SDI_TX_PHY_SB_STS] [get_bd_intf_pins v_vid_gt_bridge_0/SDI_TX_PHY_SB_STS]
  connect_bd_intf_net -intf_net v_vid_gt_bridge_0_diff_gt_ref_clock_1 [get_bd_intf_pins gt_refclk2] [get_bd_intf_pins util_ds_buf/CLK_IN_D]
  connect_bd_intf_net -intf_net v_vid_gt_bridge_0_diff_gt_ref_clock_1_1 [get_bd_intf_pins gt_refclk] [get_bd_intf_pins util_ds_buf_1/CLK_IN_D]

  # Create port connections
  connect_bd_net -net Picxo_Heir_ACC_DATA  [get_bd_pins Picxo_Heir/ACC_DATA] \
  [get_bd_pins gtwiz_versal_0/INTF0_TX0_ch_txpippmstepsize]
  connect_bd_net -net Picxo_Heir_dout  [get_bd_pins Picxo_Heir/dout] \
  [get_bd_pins gtwiz_versal_0/INTF0_TX0_ch_txpippmen]
  connect_bd_net -net Processor_Heir_gpio_io_o1  [get_bd_pins sdi_gt_ctrl] \
  [get_bd_pins v_vid_gt_bridge_0/sdi_gt_ctrl]
  connect_bd_net -net QUAD0_gpi_0_1  [get_bd_pins QUAD0_gpi_0] \
  [get_bd_pins gtwiz_versal_0/QUAD0_gpi]
  connect_bd_net -net axi_gpio_2_gpio_io_o  [get_bd_pins RESET_I] \
  [get_bd_pins Picxo_Heir/RESET_I]
  connect_bd_net -net bufg_gt_1_usrclk  [get_bd_pins bufg_gt_1/usrclk] \
  [get_bd_pins clk_txusrclk] \
  [get_bd_pins Picxo_Heir/TXOUTCLK_I_0] \
  [get_bd_pins gtwiz_versal_0/QUAD0_TX0_usrclk] \
  [get_bd_pins v_vid_gt_bridge_0/gt_txusrclk]
  connect_bd_net -net bufg_gt_usrclk  [get_bd_pins bufg_gt/usrclk] \
  [get_bd_pins clk_rxusrclk] \
  [get_bd_pins Picxo_Heir/rx_lnk_clk] \
  [get_bd_pins gtwiz_versal_0/QUAD0_RX0_usrclk] \
  [get_bd_pins v_vid_gt_bridge_0/gt_rxusrclk]
  connect_bd_net -net clk_freerun  [get_bd_pins clk_freerun] \
  [get_bd_pins Picxo_Heir/clk_freerun] \
  [get_bd_pins gtwiz_versal_0/gtwiz_freerun_clk] \
  [get_bd_pins v_vid_gt_bridge_0/clk_100mhz] \
  [get_bd_pins v_vid_gt_bridge_0/gt_ctrl_aclk]
  connect_bd_net -net gtwiz_versal_0_INTF0_rst_rx_done_out  [get_bd_pins gtwiz_versal_0/INTF0_rst_rx_done_out] \
  [get_bd_pins v_vid_gt_bridge_0/rx_full_rst_done]
  connect_bd_net -net gtwiz_versal_0_INTF0_rst_tx_done_out  [get_bd_pins gtwiz_versal_0/INTF0_rst_tx_done_out] \
  [get_bd_pins v_vid_gt_bridge_0/tx_full_rst_done]
  connect_bd_net -net gtwiz_versal_0_QUAD0_RX0_outclk  [get_bd_pins gtwiz_versal_0/QUAD0_RX0_outclk] \
  [get_bd_pins bufg_gt/outclk]
  connect_bd_net -net gtwiz_versal_0_QUAD0_TX0_outclk  [get_bd_pins gtwiz_versal_0/QUAD0_TX0_outclk] \
  [get_bd_pins bufg_gt_1/outclk]
  connect_bd_net -net gtwiz_versal_0_QUAD0_gpo  [get_bd_pins gtwiz_versal_0/QUAD0_gpo] \
  [get_bd_pins QUAD0_gpo_0]
  connect_bd_net -net gtwiz_versal_0_gtpowergood  [get_bd_pins gtwiz_versal_0/gtpowergood] \
  [get_bd_pins v_vid_gt_bridge_0/gt_powergood]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn  [get_bd_pins gt_ctrl_aresetn] \
  [get_bd_pins v_vid_gt_bridge_0/gt_ctrl_aresetn]
  connect_bd_net -net util_ds_buf_1_IBUF_OUT  [get_bd_pins util_ds_buf_1/IBUF_OUT] \
  [get_bd_pins gtwiz_versal_0/QUAD0_GTREFCLK1]
  connect_bd_net -net util_ds_buf_IBUF_OUT  [get_bd_pins util_ds_buf/IBUF_OUT] \
  [get_bd_pins gtwiz_versal_0/QUAD0_GTREFCLK0]
  connect_bd_net -net v_vid_gt_bridge_0_full_rst  [get_bd_pins v_vid_gt_bridge_0/full_rst] \
  [get_bd_pins gtwiz_versal_0/INTF0_rst_all_in]
  connect_bd_net -net v_vid_gt_bridge_0_reset_rx_datapath  [get_bd_pins v_vid_gt_bridge_0/reset_rx_datapath] \
  [get_bd_pins gtwiz_versal_0/INTF0_rst_rx_datapath_in]
  connect_bd_net -net v_vid_gt_bridge_0_reset_rx_pll_and_datapath  [get_bd_pins v_vid_gt_bridge_0/reset_rx_pll_and_datapath] \
  [get_bd_pins gtwiz_versal_0/INTF0_rst_rx_pll_and_datapath_in]
  connect_bd_net -net v_vid_gt_bridge_0_reset_tx_datapath  [get_bd_pins v_vid_gt_bridge_0/reset_tx_datapath] \
  [get_bd_pins gtwiz_versal_0/INTF0_rst_tx_datapath_in]
  connect_bd_net -net v_vid_gt_bridge_0_reset_tx_pll_and_datapath  [get_bd_pins v_vid_gt_bridge_0/reset_tx_pll_and_datapath] \
  [get_bd_pins gtwiz_versal_0/INTF0_rst_tx_pll_and_datapath_in]

  # Perform GUI Layout
  regenerate_bd_layout -hierarchy [get_bd_cells /sdi/peripheral_gt_heir/gt_hier] -layout_string {
   "ActiveEmotionalView":"Default View",
   "Default View_ScaleFactor":"0.406593",
   "Default View_TopLeft":"-1395,-7",
   "ExpandedHierarchyInLayout":"",
   "guistr":"# # String gsaved with Nlview 7.8.0 2024-04-26 e1825d835c VDI=44 GEI=38 GUI=JA:21.0 TLS
#  -string -flagsOSRD
preplace port SDI_TX_PHY_SB_CTRL -pg 1 -lvl 0 -x 0 -y 50 -defaultsOSRD
preplace port SDI_TX_PHY_SB_STS -pg 1 -lvl 3 -x 1110 -y 60 -defaultsOSRD
preplace port SDI_TX_AXI4S_CH0 -pg 1 -lvl 0 -x 0 -y 70 -defaultsOSRD
preplace port SDI_RX_PHY_SB_STS -pg 1 -lvl 3 -x 1110 -y 100 -defaultsOSRD
preplace port SDI_RX_PHY_SB_CTRL -pg 1 -lvl 0 -x 0 -y 90 -defaultsOSRD
preplace port SDI_RX_AXI4S_CH0 -pg 1 -lvl 3 -x 1110 -y 140 -defaultsOSRD
preplace port gt_refclk -pg 1 -lvl 0 -x 0 -y 630 -defaultsOSRD
preplace port gt_refclk2 -pg 1 -lvl 0 -x 0 -y 750 -defaultsOSRD
preplace port GT_Serial_0 -pg 1 -lvl 3 -x 1110 -y 320 -defaultsOSRD
preplace port port-id_clk_rxusrclk -pg 1 -lvl 3 -x 1110 -y 650 -defaultsOSRD
preplace port port-id_clk_freerun -pg 1 -lvl 0 -x 0 -y 500 -defaultsOSRD
preplace port port-id_gt_ctrl_aresetn -pg 1 -lvl 0 -x 0 -y 130 -defaultsOSRD
preplace port port-id_clk_txusrclk -pg 1 -lvl 3 -x 1110 -y 630 -defaultsOSRD
preplace port port-id_RESET_I -pg 1 -lvl 0 -x 0 -y 480 -defaultsOSRD
preplace portBus sdi_gt_ctrl -pg 1 -lvl 0 -x 0 -y 150 -defaultsOSRD
preplace portBus QUAD0_gpi_0 -pg 1 -lvl 0 -x 0 -y 380 -defaultsOSRD
preplace portBus QUAD0_gpo_0 -pg 1 -lvl 3 -x 1110 -y 180 -defaultsOSRD
preplace inst bufg_gt -pg 1 -lvl 1 -x 270 -y 960 -defaultsOSRD
preplace inst v_vid_gt_bridge_0 -pg 1 -lvl 1 -x 270 -y 180 -defaultsOSRD
preplace inst util_ds_buf_1 -pg 1 -lvl 1 -x 270 -y 640 -defaultsOSRD
preplace inst bufg_gt_1 -pg 1 -lvl 1 -x 270 -y 1160 -defaultsOSRD
preplace inst util_ds_buf -pg 1 -lvl 1 -x 270 -y 760 -defaultsOSRD
preplace inst gtwiz_versal_0 -pg 1 -lvl 2 -x 830 -y 410 -defaultsOSRD
preplace inst Picxo_Heir -pg 1 -lvl 1 -x 270 -y 510 -defaultsOSRD
preplace netloc Picxo_Heir_ACC_DATA 1 1 1 520 350n
preplace netloc Picxo_Heir_dout 1 1 1 510 330n
preplace netloc Processor_Heir_gpio_io_o1 1 0 1 NJ 150
preplace netloc QUAD0_gpi_0_1 1 0 2 NJ 380 470J
preplace netloc axi_gpio_2_gpio_io_o 1 0 1 NJ 480
preplace netloc bufg_gt_1_usrclk 1 0 3 50 840 600 630 NJ
preplace netloc bufg_gt_usrclk 1 0 3 70 400 470 650 NJ
preplace netloc clk_freerun 1 0 2 20 390 NJ
preplace netloc gtwiz_versal_0_INTF0_rst_rx_done_out 1 0 3 30 420 460J 670 1060
preplace netloc gtwiz_versal_0_INTF0_rst_tx_done_out 1 0 3 60 410 480J 660 1070
preplace netloc gtwiz_versal_0_QUAD0_RX0_outclk 1 0 3 80 830 NJ 830 1080
preplace netloc gtwiz_versal_0_QUAD0_TX0_outclk 1 0 3 40 850 NJ 850 1090
preplace netloc gtwiz_versal_0_QUAD0_gpo 1 1 2 600 180 NJ
preplace netloc gtwiz_versal_0_gtpowergood 1 0 3 80 370 460J 190 1060
preplace netloc proc_sys_reset_0_peripheral_aresetn 1 0 1 NJ 130
preplace netloc util_ds_buf_1_IBUF_OUT 1 1 1 560J 430n
preplace netloc util_ds_buf_IBUF_OUT 1 1 1 550J 410n
preplace netloc v_vid_gt_bridge_0_full_rst 1 1 1 570 180n
preplace netloc v_vid_gt_bridge_0_reset_rx_datapath 1 1 1 490 260n
preplace netloc v_vid_gt_bridge_0_reset_rx_pll_and_datapath 1 1 1 500 240n
preplace netloc v_vid_gt_bridge_0_reset_tx_datapath 1 1 1 530 220n
preplace netloc v_vid_gt_bridge_0_reset_tx_pll_and_datapath 1 1 1 540 200n
preplace netloc RX_Heir_M_AXIS_CTRL_SB_RX 1 0 1 NJ 90
preplace netloc S_AXIS_RX_1 1 1 2 NJ 140 NJ
preplace netloc S_AXIS_STS_SB_RX_1 1 1 2 NJ 100 NJ
preplace netloc Tx_Heir_M_AXIS_CTRL_SB_TX 1 0 1 NJ 50
preplace netloc Tx_Heir_M_AXIS_TX 1 0 1 NJ 70
preplace netloc gtwiz_versal_0_Quad0_GT_Serial 1 2 1 NJ 320
preplace netloc v_vid_gt_bridge_0_GT_RX0 1 1 1 580 120n
preplace netloc v_vid_gt_bridge_0_GT_TX0 1 1 1 590 80n
preplace netloc v_vid_gt_bridge_0_SDI_TX_PHY_SB_STS 1 1 2 NJ 60 NJ
preplace netloc v_vid_gt_bridge_0_diff_gt_ref_clock_1 1 0 1 NJ 750
preplace netloc v_vid_gt_bridge_0_diff_gt_ref_clock_1_1 1 0 1 NJ 630
levelinfo -pg 1 0 270 830 1110
pagesize -pg 1 -db -bbox -sgen -180 0 1290 1260
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

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_TX

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_CTRL_SB_TX

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_STS_SB_TX

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_mm_video1

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_mm_video2

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI


  # Create pins
  create_bd_pin -dir I -type clk clk_freerun
  create_bd_pin -dir I fid
  create_bd_pin -dir O -type intr interrupt
  create_bd_pin -dir I -type rst s_axi_arstn
  create_bd_pin -dir O -type intr sdi_tx_irq
  create_bd_pin -dir I -type rst sdi_tx_rst
  create_bd_pin -dir I -type clk tx_lnk_clk
  create_bd_pin -dir I -type rst video_in_arstn
  create_bd_pin -dir I -type clk video_in_clk
  create_bd_pin -dir I -type rst s_axi_arstn1
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type clk sdi_tx_clk
  create_bd_pin -dir O -type intr interrupt1
  create_bd_pin -dir I -from 7 -to 0 Din
  create_bd_pin -dir I -type clk aclk2

  # Create instance: v_uhdsdi_audio_Embed, and set properties
  set v_uhdsdi_audio_Embed [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_uhdsdi_audio v_uhdsdi_audio_Embed ]
  set_property -dict [list \
    CONFIG.C_AUDIO_FUNCTION {Embed} \
    CONFIG.C_MAX_AUDIO_CHANNELS {32} \
  ] $v_uhdsdi_audio_Embed


  # Create instance: v_smpte_uhdsdi_tx_ss_0, and set properties
  set v_smpte_uhdsdi_tx_ss_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_smpte_uhdsdi_tx_ss v_smpte_uhdsdi_tx_ss_0 ]
  set_property CONFIG.C_INCLUDE_ADV_FEATURES {true} $v_smpte_uhdsdi_tx_ss_0


  # Create instance: v_mix_0, and set properties
  set v_mix_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_mix v_mix_0 ]
  set_property -dict [list \
    CONFIG.AXIMM_ADDR_WIDTH {64} \
    CONFIG.LAYER1_ALPHA {true} \
    CONFIG.LAYER1_VIDEO_FORMAT {18} \
    CONFIG.LAYER2_ALPHA {true} \
    CONFIG.LAYER2_VIDEO_FORMAT {19} \
    CONFIG.LAYER3_ALPHA {true} \
    CONFIG.LAYER3_VIDEO_FORMAT {11} \
    CONFIG.LAYER4_VIDEO_FORMAT {14} \
    CONFIG.MAX_DATA_WIDTH {10} \
    CONFIG.NR_LAYERS {3} \
    CONFIG.SAMPLES_PER_CLOCK {2} \
    CONFIG.VIDEO_FORMAT {2} \
  ] $v_mix_0


  # Create instance: ilslice_0, and set properties
  set ilslice_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice ilslice_0 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {1} \
    CONFIG.DIN_TO {1} \
    CONFIG.DIN_WIDTH {8} \
  ] $ilslice_0


  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant xlconstant_0 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {64} \
  ] $xlconstant_0


  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_0 ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {3} \
    CONFIG.NUM_MI {3} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_0


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins v_smpte_uhdsdi_tx_ss_0/M_AXIS_TX] [get_bd_intf_pins M_AXIS_TX]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins v_smpte_uhdsdi_tx_ss_0/M_AXIS_CTRL_SB_TX] [get_bd_intf_pins M_AXIS_CTRL_SB_TX]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins v_smpte_uhdsdi_tx_ss_0/S_AXIS_STS_SB_TX] [get_bd_intf_pins S_AXIS_STS_SB_TX]
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins v_mix_0/m_axi_mm_video1] [get_bd_intf_pins m_axi_mm_video1]
  connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins v_mix_0/m_axi_mm_video2] [get_bd_intf_pins m_axi_mm_video2]
  connect_bd_intf_net -intf_net Conn6 [get_bd_intf_pins smartconnect_0/S00_AXI] [get_bd_intf_pins S00_AXI]
  connect_bd_intf_net -intf_net axis_data_fifo_1_M_AXIS [get_bd_intf_pins S_AXIS_DATA] [get_bd_intf_pins v_uhdsdi_audio_Embed/S_AXIS_DATA]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins v_uhdsdi_audio_Embed/S_AXI_CTRL]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins smartconnect_0/M01_AXI] [get_bd_intf_pins v_smpte_uhdsdi_tx_ss_0/S_AXI_CTRL]
  connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins smartconnect_0/M02_AXI] [get_bd_intf_pins v_mix_0/s_axi_CTRL]
  connect_bd_intf_net -intf_net v_mix_0_m_axis_video [get_bd_intf_pins v_mix_0/m_axis_video] [get_bd_intf_pins v_smpte_uhdsdi_tx_ss_0/VIDEO_IN]
  connect_bd_intf_net -intf_net v_smpte_uhdsdi_tx_ss_0_SDI_TX_ANC_DS_OUT [get_bd_intf_pins v_smpte_uhdsdi_tx_ss_0/SDI_TX_ANC_DS_OUT] [get_bd_intf_pins v_uhdsdi_audio_Embed/SDI_EMBED_ANC_DS_IN]
  connect_bd_intf_net -intf_net v_uhdsdi_audio_Embed_SDI_EMBED_ANC_DS_OUT [get_bd_intf_pins v_uhdsdi_audio_Embed/SDI_EMBED_ANC_DS_OUT] [get_bd_intf_pins v_smpte_uhdsdi_tx_ss_0/SDI_TX_ANC_DS_IN]

  # Create port connections
  connect_bd_net -net Din_1  [get_bd_pins Din] \
  [get_bd_pins ilslice_0/Din]
  connect_bd_net -net aclk2_1  [get_bd_pins aclk2] \
  [get_bd_pins smartconnect_0/aclk2]
  connect_bd_net -net axi_gpio_2_gpio_io_o  [get_bd_pins sdi_tx_rst] \
  [get_bd_pins v_uhdsdi_audio_Embed/sdi_embed_reset] \
  [get_bd_pins v_smpte_uhdsdi_tx_ss_0/sdi_tx_rst]
  connect_bd_net -net clk_freerun  [get_bd_pins clk_freerun] \
  [get_bd_pins v_uhdsdi_audio_Embed/s_axi_aclk] \
  [get_bd_pins smartconnect_0/aclk]
  connect_bd_net -net clk_wizard_0_clk_out2  [get_bd_pins video_in_clk] \
  [get_bd_pins v_uhdsdi_audio_Embed/s_axis_clk] \
  [get_bd_pins v_smpte_uhdsdi_tx_ss_0/video_in_clk] \
  [get_bd_pins v_mix_0/ap_clk] \
  [get_bd_pins smartconnect_0/aclk1]
  connect_bd_net -net fid_1  [get_bd_pins fid] \
  [get_bd_pins v_smpte_uhdsdi_tx_ss_0/fid]
  connect_bd_net -net ilslice_0_Dout  [get_bd_pins ilslice_0/Dout] \
  [get_bd_pins v_mix_0/ap_rst_n]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn  [get_bd_pins s_axi_arstn] \
  [get_bd_pins v_uhdsdi_audio_Embed/s_axi_aresetn] \
  [get_bd_pins smartconnect_0/aresetn]
  connect_bd_net -net proc_sys_reset_1_peripheral_aresetn  [get_bd_pins video_in_arstn] \
  [get_bd_pins v_uhdsdi_audio_Embed/s_axis_resetn] \
  [get_bd_pins v_smpte_uhdsdi_tx_ss_0/video_in_arstn]
  connect_bd_net -net s_axi_aclk_1  [get_bd_pins s_axi_aclk] \
  [get_bd_pins v_smpte_uhdsdi_tx_ss_0/s_axi_aclk]
  connect_bd_net -net s_axi_arstn1_1  [get_bd_pins s_axi_arstn1] \
  [get_bd_pins v_smpte_uhdsdi_tx_ss_0/s_axi_arstn]
  connect_bd_net -net sdi_tx_clk_1  [get_bd_pins sdi_tx_clk] \
  [get_bd_pins v_smpte_uhdsdi_tx_ss_0/sdi_tx_clk]
  connect_bd_net -net tx_lnk_clk_1  [get_bd_pins tx_lnk_clk] \
  [get_bd_pins v_uhdsdi_audio_Embed/sdi_embed_clk]
  connect_bd_net -net v_mix_0_interrupt  [get_bd_pins v_mix_0/interrupt] \
  [get_bd_pins interrupt1]
  connect_bd_net -net v_smpte_uhdsdi_tx_ss_0_sdi_tx_anc_ctrl_out  [get_bd_pins v_smpte_uhdsdi_tx_ss_0/sdi_tx_anc_ctrl_out] \
  [get_bd_pins v_uhdsdi_audio_Embed/sdi_embed_anc_ctrl_in]
  connect_bd_net -net v_smpte_uhdsdi_tx_ss_0_sdi_tx_irq  [get_bd_pins v_smpte_uhdsdi_tx_ss_0/sdi_tx_irq] \
  [get_bd_pins sdi_tx_irq]
  connect_bd_net -net v_uhdsdi_audio_1_interrupt  [get_bd_pins v_uhdsdi_audio_Embed/interrupt] \
  [get_bd_pins interrupt]
  connect_bd_net -net xlconstant_0_dout  [get_bd_pins xlconstant_0/dout] \
  [get_bd_pins v_mix_0/s_axis_video_TDATA] \
  [get_bd_pins v_mix_0/s_axis_video_TVALID]

  # Perform GUI Layout
  regenerate_bd_layout -hierarchy [get_bd_cells /sdi/Tx_Heir] -layout_string {
   "ActiveEmotionalView":"Default View",
   "Default View_ScaleFactor":"0.634027",
   "Default View_TopLeft":"-580,3",
   "ExpandedHierarchyInLayout":"",
   "guistr":"# # String gsaved with Nlview 7.8.0 2024-04-26 e1825d835c VDI=44 GEI=38 GUI=JA:21.0 TLS
#  -string -flagsOSRD
preplace port S_AXIS_DATA -pg 1 -lvl 0 -x 0 -y 490 -defaultsOSRD
preplace port M_AXIS_TX -pg 1 -lvl 4 -x 1340 -y 530 -defaultsOSRD
preplace port M_AXIS_CTRL_SB_TX -pg 1 -lvl 4 -x 1340 -y 550 -defaultsOSRD
preplace port S_AXIS_STS_SB_TX -pg 1 -lvl 0 -x 0 -y 410 -defaultsOSRD
preplace port m_axi_mm_video1 -pg 1 -lvl 4 -x 1340 -y 160 -defaultsOSRD
preplace port m_axi_mm_video2 -pg 1 -lvl 4 -x 1340 -y 180 -defaultsOSRD
preplace port S00_AXI -pg 1 -lvl 0 -x 0 -y 260 -defaultsOSRD
preplace port port-id_clk_freerun -pg 1 -lvl 0 -x 0 -y 280 -defaultsOSRD
preplace port port-id_fid -pg 1 -lvl 0 -x 0 -y 760 -defaultsOSRD
preplace port port-id_interrupt -pg 1 -lvl 4 -x 1340 -y 410 -defaultsOSRD
preplace port port-id_s_axi_arstn -pg 1 -lvl 0 -x 0 -y 340 -defaultsOSRD
preplace port port-id_sdi_tx_irq -pg 1 -lvl 4 -x 1340 -y 610 -defaultsOSRD
preplace port port-id_sdi_tx_rst -pg 1 -lvl 0 -x 0 -y 630 -defaultsOSRD
preplace port port-id_tx_lnk_clk -pg 1 -lvl 0 -x 0 -y 610 -defaultsOSRD
preplace port port-id_video_in_arstn -pg 1 -lvl 0 -x 0 -y 590 -defaultsOSRD
preplace port port-id_video_in_clk -pg 1 -lvl 0 -x 0 -y 300 -defaultsOSRD
preplace port port-id_s_axi_arstn1 -pg 1 -lvl 0 -x 0 -y 800 -defaultsOSRD
preplace port port-id_s_axi_aclk -pg 1 -lvl 0 -x 0 -y 780 -defaultsOSRD
preplace port port-id_sdi_tx_clk -pg 1 -lvl 0 -x 0 -y 720 -defaultsOSRD
preplace port port-id_interrupt1 -pg 1 -lvl 4 -x 1340 -y 220 -defaultsOSRD
preplace port port-id_aclk2 -pg 1 -lvl 0 -x 0 -y 320 -defaultsOSRD
preplace portBus Din -pg 1 -lvl 0 -x 0 -y 160 -defaultsOSRD
preplace inst v_uhdsdi_audio_Embed -pg 1 -lvl 2 -x 610 -y 560 -defaultsOSRD
preplace inst v_smpte_uhdsdi_tx_ss_0 -pg 1 -lvl 3 -x 1130 -y 580 -defaultsOSRD
preplace inst v_mix_0 -pg 1 -lvl 2 -x 610 -y 190 -defaultsOSRD
preplace inst ilslice_0 -pg 1 -lvl 1 -x 180 -y 160 -defaultsOSRD
preplace inst xlconstant_0 -pg 1 -lvl 1 -x 180 -y 60 -defaultsOSRD
preplace inst smartconnect_0 -pg 1 -lvl 1 -x 180 -y 300 -defaultsOSRD
preplace netloc Din_1 1 0 1 NJ 160
preplace netloc aclk2_1 1 0 1 NJ 320
preplace netloc axi_gpio_2_gpio_io_o 1 0 3 NJ 630 340 730 890J
preplace netloc clk_freerun 1 0 2 40 530 NJ
preplace netloc clk_wizard_0_clk_out2 1 0 3 30 400 350 740 900J
preplace netloc fid_1 1 0 3 NJ 760 NJ 760 920J
preplace netloc ilslice_0_Dout 1 1 1 340J 160n
preplace netloc proc_sys_reset_0_peripheral_aresetn 1 0 2 20 550 NJ
preplace netloc proc_sys_reset_1_peripheral_aresetn 1 0 3 NJ 590 320 750 910J
preplace netloc s_axi_aclk_1 1 0 3 NJ 780 NJ 780 930J
preplace netloc s_axi_arstn1_1 1 0 3 NJ 800 NJ 800 940J
preplace netloc sdi_tx_clk_1 1 0 3 NJ 720 NJ 720 880J
preplace netloc tx_lnk_clk_1 1 0 2 NJ 610 NJ
preplace netloc v_mix_0_interrupt 1 2 2 NJ 220 NJ
preplace netloc v_smpte_uhdsdi_tx_ss_0_sdi_tx_anc_ctrl_out 1 1 3 360 810 NJ 810 1320
preplace netloc v_smpte_uhdsdi_tx_ss_0_sdi_tx_irq 1 3 1 NJ 610
preplace netloc v_uhdsdi_audio_1_interrupt 1 2 2 860J 410 NJ
preplace netloc xlconstant_0_dout 1 1 1 350 60n
preplace netloc Conn1 1 3 1 NJ 530
preplace netloc Conn2 1 3 1 NJ 550
preplace netloc Conn3 1 0 3 NJ 410 NJ 410 850J
preplace netloc Conn4 1 2 2 NJ 160 NJ
preplace netloc Conn5 1 2 2 NJ 180 NJ
preplace netloc Conn6 1 0 1 NJ 260
preplace netloc axis_data_fifo_1_M_AXIS 1 0 2 NJ 490 NJ
preplace netloc smartconnect_0_M00_AXI 1 1 1 320 280n
preplace netloc smartconnect_0_M01_AXI 1 1 2 NJ 300 880
preplace netloc smartconnect_0_M02_AXI 1 1 1 330 140n
preplace netloc v_mix_0_m_axis_video 1 2 1 940 200n
preplace netloc v_smpte_uhdsdi_tx_ss_0_SDI_TX_ANC_DS_OUT 1 1 3 370 710 870J 420 1320
preplace netloc v_uhdsdi_audio_Embed_SDI_EMBED_ANC_DS_OUT 1 2 1 N 540
levelinfo -pg 1 0 180 610 1130 1340
pagesize -pg 1 -db -bbox -sgen -190 0 1540 820
"
}

  # Restore current instance
  current_bd_instance $oldCurInst
}

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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_RX

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_CTRL_SB_RX

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_STS_SB_RX

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_mm_video

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS


  # Create pins
  create_bd_pin -dir I -type clk clk_freerun
  create_bd_pin -dir O fid
  create_bd_pin -dir O -type intr interrupt
  create_bd_pin -dir I -type clk rx_lnk_clk
  create_bd_pin -dir I -type rst s_axi_arstn
  create_bd_pin -dir O -type intr sdi_rx_irq
  create_bd_pin -dir I -type rst sdi_rx_rst
  create_bd_pin -dir I -type rst video_out_arstn
  create_bd_pin -dir I -type clk video_out_clk
  create_bd_pin -dir I -type rst s_axi_arstn1
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type clk sdi_rx_clk
  create_bd_pin -dir I -from 7 -to 0 Din
  create_bd_pin -dir O -type intr interrupt1
  create_bd_pin -dir I -type clk aclk2
  create_bd_pin -dir I -type rst s_axis_aresetn

  # Create instance: v_uhdsdi_audio_Extract, and set properties
  set v_uhdsdi_audio_Extract [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_uhdsdi_audio v_uhdsdi_audio_Extract ]
  set_property -dict [list \
    CONFIG.C_AUDIO_FUNCTION {Extract} \
    CONFIG.C_MAX_AUDIO_CHANNELS {32} \
  ] $v_uhdsdi_audio_Extract


  # Create instance: v_smpte_uhdsdi_rx_ss_0, and set properties
  set v_smpte_uhdsdi_rx_ss_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_smpte_uhdsdi_rx_ss v_smpte_uhdsdi_rx_ss_0 ]
  set_property CONFIG.C_INCLUDE_ADV_FEATURES {true} $v_smpte_uhdsdi_rx_ss_0


  # Create instance: v_frmbuf_wr_0, and set properties
  set v_frmbuf_wr_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_frmbuf_wr v_frmbuf_wr_0 ]
  set_property -dict [list \
    CONFIG.AXIMM_ADDR_WIDTH {64} \
    CONFIG.HAS_BGR8 {1} \
    CONFIG.HAS_BGRX8 {1} \
    CONFIG.HAS_RGBX8 {1} \
    CONFIG.HAS_UYVY8 {1} \
    CONFIG.HAS_Y8 {1} \
    CONFIG.HAS_YUV8 {1} \
    CONFIG.HAS_YUVX8 {1} \
    CONFIG.HAS_YUYV8 {1} \
    CONFIG.HAS_Y_UV8 {1} \
    CONFIG.HAS_Y_UV8_420 {1} \
    CONFIG.HAS_Y_U_V8 {1} \
    CONFIG.HAS_Y_U_V8_420 {1} \
    CONFIG.MAX_DATA_WIDTH {8} \
  ] $v_frmbuf_wr_0


  # Create instance: ilslice_0, and set properties
  set ilslice_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice ilslice_0 ]
  set_property CONFIG.DIN_WIDTH {8} $ilslice_0


  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_0 ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {3} \
    CONFIG.NUM_MI {4} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_0


  # Create instance: axis_data_fifo_Audio, and set properties
  set axis_data_fifo_Audio [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo axis_data_fifo_Audio ]

  # Create instance: axis_subset_converter_0, and set properties
  set axis_subset_converter_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_subset_converter axis_subset_converter_0 ]
  set_property -dict [list \
    CONFIG.M_HAS_TKEEP {1} \
    CONFIG.M_HAS_TLAST {1} \
    CONFIG.M_HAS_TREADY {1} \
    CONFIG.M_HAS_TSTRB {1} \
    CONFIG.M_TDATA_NUM_BYTES {6} \
    CONFIG.M_TDEST_WIDTH {1} \
    CONFIG.M_TID_WIDTH {1} \
    CONFIG.M_TUSER_WIDTH {1} \
    CONFIG.S_HAS_TKEEP {1} \
    CONFIG.S_HAS_TLAST {1} \
    CONFIG.S_HAS_TREADY {1} \
    CONFIG.S_HAS_TSTRB {1} \
    CONFIG.S_TDATA_NUM_BYTES {8} \
    CONFIG.S_TDEST_WIDTH {1} \
    CONFIG.S_TID_WIDTH {1} \
    CONFIG.S_TUSER_WIDTH {1} \
    CONFIG.TDATA_REMAP {tdata[59:52],tdata[49:42],tdata[39:32],tdata[29:22],tdata[19:12],tdata[9:2]} \
  ] $axis_subset_converter_0

  set_property -dict [list \
    CONFIG.M_HAS_TREADY.VALUE_MODE {auto} \
    CONFIG.S_HAS_TREADY.VALUE_MODE {auto} \
  ] $axis_subset_converter_0


  # Create instance: v_proc_ss_0, and set properties
  set v_proc_ss_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_proc_ss v_proc_ss_0 ]
  set_property -dict [list \
    CONFIG.C_ENABLE_CSC {true} \
    CONFIG.C_MAX_DATA_WIDTH {8} \
    CONFIG.C_TOPOLOGY {0} \
  ] $v_proc_ss_0


  # Create instance: ilslice_3, and set properties
  set ilslice_3 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice ilslice_3 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {3} \
    CONFIG.DIN_TO {3} \
    CONFIG.DIN_WIDTH {8} \
  ] $ilslice_3


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins v_smpte_uhdsdi_rx_ss_0/S_AXIS_RX] [get_bd_intf_pins S_AXIS_RX]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins v_smpte_uhdsdi_rx_ss_0/M_AXIS_CTRL_SB_RX] [get_bd_intf_pins M_AXIS_CTRL_SB_RX]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins v_smpte_uhdsdi_rx_ss_0/S_AXIS_STS_SB_RX] [get_bd_intf_pins S_AXIS_STS_SB_RX]
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins v_frmbuf_wr_0/m_axi_mm_video] [get_bd_intf_pins m_axi_mm_video]
  connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins smartconnect_0/S00_AXI] [get_bd_intf_pins S00_AXI]
  connect_bd_intf_net -intf_net Conn6 [get_bd_intf_pins axis_data_fifo_Audio/M_AXIS] [get_bd_intf_pins M_AXIS]
  connect_bd_intf_net -intf_net axis_subset_converter_0_M_AXIS [get_bd_intf_pins axis_subset_converter_0/M_AXIS] [get_bd_intf_pins v_proc_ss_0/s_axis]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins v_smpte_uhdsdi_rx_ss_0/S_AXI_CTRL]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins smartconnect_0/M01_AXI] [get_bd_intf_pins v_frmbuf_wr_0/s_axi_CTRL]
  connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins smartconnect_0/M02_AXI] [get_bd_intf_pins v_uhdsdi_audio_Extract/S_AXI_CTRL]
  connect_bd_intf_net -intf_net smartconnect_0_M03_AXI [get_bd_intf_pins v_proc_ss_0/s_axi_ctrl] [get_bd_intf_pins smartconnect_0/M03_AXI]
  connect_bd_intf_net -intf_net v_proc_ss_0_m_axis [get_bd_intf_pins v_proc_ss_0/m_axis] [get_bd_intf_pins v_frmbuf_wr_0/s_axis_video]
  connect_bd_intf_net -intf_net v_smpte_uhdsdi_rx_ss_0_SDI_RX_ANC_DS_OUT [get_bd_intf_pins v_smpte_uhdsdi_rx_ss_0/SDI_RX_ANC_DS_OUT] [get_bd_intf_pins v_uhdsdi_audio_Extract/SDI_EXTRACT_ANC_DS_IN]
  connect_bd_intf_net -intf_net v_smpte_uhdsdi_rx_ss_0_VIDEO_OUT [get_bd_intf_pins v_smpte_uhdsdi_rx_ss_0/VIDEO_OUT] [get_bd_intf_pins axis_subset_converter_0/S_AXIS]
  connect_bd_intf_net -intf_net v_uhdsdi_audio_Extract_M_AXIS_DATA [get_bd_intf_pins v_uhdsdi_audio_Extract/M_AXIS_DATA] [get_bd_intf_pins axis_data_fifo_Audio/S_AXIS]

  # Create port connections
  connect_bd_net -net Din_1  [get_bd_pins Din] \
  [get_bd_pins ilslice_0/Din] \
  [get_bd_pins ilslice_3/Din]
  connect_bd_net -net aclk2_1  [get_bd_pins aclk2] \
  [get_bd_pins smartconnect_0/aclk2]
  connect_bd_net -net axi_gpio_2_gpio_io_o  [get_bd_pins sdi_rx_rst] \
  [get_bd_pins v_uhdsdi_audio_Extract/sdi_extract_reset] \
  [get_bd_pins v_smpte_uhdsdi_rx_ss_0/sdi_rx_rst]
  connect_bd_net -net clk_freerun  [get_bd_pins clk_freerun] \
  [get_bd_pins v_uhdsdi_audio_Extract/s_axi_aclk] \
  [get_bd_pins smartconnect_0/aclk]
  connect_bd_net -net clk_wizard_0_clk_out2  [get_bd_pins video_out_clk] \
  [get_bd_pins v_uhdsdi_audio_Extract/m_axis_clk] \
  [get_bd_pins v_smpte_uhdsdi_rx_ss_0/video_out_clk] \
  [get_bd_pins v_frmbuf_wr_0/ap_clk] \
  [get_bd_pins smartconnect_0/aclk1] \
  [get_bd_pins axis_data_fifo_Audio/s_axis_aclk] \
  [get_bd_pins v_proc_ss_0/aclk_axis] \
  [get_bd_pins axis_subset_converter_0/aclk] \
  [get_bd_pins v_proc_ss_0/aclk_ctrl]
  connect_bd_net -net ilslice_0_Dout  [get_bd_pins ilslice_0/Dout] \
  [get_bd_pins v_frmbuf_wr_0/ap_rst_n]
  connect_bd_net -net ilslice_3_Dout  [get_bd_pins ilslice_3/Dout] \
  [get_bd_pins v_proc_ss_0/aresetn_ctrl]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn  [get_bd_pins s_axi_arstn] \
  [get_bd_pins v_uhdsdi_audio_Extract/s_axi_aresetn] \
  [get_bd_pins smartconnect_0/aresetn]
  connect_bd_net -net proc_sys_reset_1_peripheral_aresetn  [get_bd_pins video_out_arstn] \
  [get_bd_pins v_uhdsdi_audio_Extract/m_axis_resetn] \
  [get_bd_pins v_smpte_uhdsdi_rx_ss_0/video_out_arstn] \
  [get_bd_pins axis_subset_converter_0/aresetn]
  connect_bd_net -net rx_lnk_clk_1  [get_bd_pins rx_lnk_clk] \
  [get_bd_pins v_uhdsdi_audio_Extract/sdi_extract_clk]
  connect_bd_net -net s_axi_aclk_1  [get_bd_pins s_axi_aclk] \
  [get_bd_pins v_smpte_uhdsdi_rx_ss_0/s_axi_aclk]
  connect_bd_net -net s_axi_arstn1_1  [get_bd_pins s_axi_arstn1] \
  [get_bd_pins v_smpte_uhdsdi_rx_ss_0/s_axi_arstn]
  connect_bd_net -net s_axis_aresetn_1  [get_bd_pins s_axis_aresetn] \
  [get_bd_pins axis_data_fifo_Audio/s_axis_aresetn]
  connect_bd_net -net sdi_rx_clk_1  [get_bd_pins sdi_rx_clk] \
  [get_bd_pins v_smpte_uhdsdi_rx_ss_0/sdi_rx_clk]
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
   "Default View_ScaleFactor":"1.0",
   "Default View_TopLeft":"-238,-151",
   "ExpandedHierarchyInLayout":"",
   "guistr":"# # String gsaved with Nlview 7.8.0 2024-04-26 e1825d835c VDI=44 GEI=38 GUI=JA:21.0 TLS
#  -string -flagsOSRD
preplace port S_AXIS_RX -pg 1 -lvl 0 -x 0 -y 290 -defaultsOSRD
preplace port M_AXIS_CTRL_SB_RX -pg 1 -lvl 4 -x 1280 -y 650 -defaultsOSRD
preplace port S_AXIS_STS_SB_RX -pg 1 -lvl 0 -x 0 -y 310 -defaultsOSRD
preplace port m_axi_mm_video -pg 1 -lvl 4 -x 1280 -y 70 -defaultsOSRD
preplace port S00_AXI -pg 1 -lvl 0 -x 0 -y 370 -defaultsOSRD
preplace port M_AXIS -pg 1 -lvl 4 -x 1280 -y 490 -defaultsOSRD
preplace port port-id_clk_freerun -pg 1 -lvl 0 -x 0 -y 390 -defaultsOSRD
preplace port port-id_fid -pg 1 -lvl 4 -x 1280 -y 730 -defaultsOSRD
preplace port port-id_interrupt -pg 1 -lvl 4 -x 1280 -y 410 -defaultsOSRD
preplace port port-id_rx_lnk_clk -pg 1 -lvl 0 -x 0 -y 520 -defaultsOSRD
preplace port port-id_s_axi_arstn -pg 1 -lvl 0 -x 0 -y 450 -defaultsOSRD
preplace port port-id_sdi_rx_irq -pg 1 -lvl 4 -x 1280 -y 750 -defaultsOSRD
preplace port port-id_sdi_rx_rst -pg 1 -lvl 0 -x 0 -y 720 -defaultsOSRD
preplace port port-id_video_out_arstn -pg 1 -lvl 0 -x 0 -y 570 -defaultsOSRD
preplace port port-id_video_out_clk -pg 1 -lvl 0 -x 0 -y 410 -defaultsOSRD
preplace port port-id_s_axi_arstn1 -pg 1 -lvl 0 -x 0 -y 790 -defaultsOSRD
preplace port port-id_s_axi_aclk -pg 1 -lvl 0 -x 0 -y 770 -defaultsOSRD
preplace port port-id_sdi_rx_clk -pg 1 -lvl 0 -x 0 -y 740 -defaultsOSRD
preplace port port-id_interrupt1 -pg 1 -lvl 4 -x 1280 -y 90 -defaultsOSRD
preplace port port-id_aclk2 -pg 1 -lvl 0 -x 0 -y 430 -defaultsOSRD
preplace port port-id_s_axis_aresetn -pg 1 -lvl 0 -x 0 -y 550 -defaultsOSRD
preplace portBus Din -pg 1 -lvl 0 -x 0 -y 110 -defaultsOSRD
preplace inst v_uhdsdi_audio_Extract -pg 1 -lvl 2 -x 640 -y 500 -defaultsOSRD
preplace inst v_smpte_uhdsdi_rx_ss_0 -pg 1 -lvl 3 -x 1070 -y 710 -defaultsOSRD
preplace inst v_frmbuf_wr_0 -pg 1 -lvl 3 -x 1070 -y 80 -defaultsOSRD
preplace inst ilslice_0 -pg 1 -lvl 2 -x 640 -y 110 -defaultsOSRD
preplace inst smartconnect_0 -pg 1 -lvl 1 -x 200 -y 410 -defaultsOSRD
preplace inst axis_data_fifo_Audio -pg 1 -lvl 3 -x 1070 -y 490 -defaultsOSRD
preplace inst axis_subset_converter_0 -pg 1 -lvl 1 -x 200 -y 630 -defaultsOSRD
preplace inst v_proc_ss_0 -pg 1 -lvl 2 -x 640 -y 250 -defaultsOSRD
preplace inst ilslice_3 -pg 1 -lvl 1 -x 200 -y 220 -defaultsOSRD
preplace netloc Din_1 1 0 2 30 110 NJ
preplace netloc aclk2_1 1 0 1 NJ 430
preplace netloc axi_gpio_2_gpio_io_o 1 0 3 NJ 720 420 710 NJ
preplace netloc clk_freerun 1 0 2 30 280 400
preplace netloc clk_wizard_0_clk_out2 1 0 3 30 530 430 640 880
preplace netloc ilslice_0_Dout 1 2 1 NJ 110
preplace netloc ilslice_3_Dout 1 1 1 420J 220n
preplace netloc proc_sys_reset_0_peripheral_aresetn 1 0 2 20 510 400J
preplace netloc proc_sys_reset_1_peripheral_aresetn 1 0 3 40 540 350 750 NJ
preplace netloc rx_lnk_clk_1 1 0 2 NJ 520 410J
preplace netloc s_axi_aclk_1 1 0 3 NJ 770 NJ 770 NJ
preplace netloc s_axi_arstn1_1 1 0 3 NJ 790 NJ 790 NJ
preplace netloc s_axis_aresetn_1 1 0 3 NJ 550 360J 650 850J
preplace netloc sdi_rx_clk_1 1 0 3 NJ 740 430J 690 NJ
preplace netloc v_frmbuf_wr_0_interrupt 1 3 1 NJ 90
preplace netloc v_smpte_uhdsdi_rx_ss_0_fid 1 3 1 NJ 730
preplace netloc v_smpte_uhdsdi_rx_ss_0_sdi_rx_anc_ctrl_out 1 1 3 400 860 NJ 860 1250
preplace netloc v_smpte_uhdsdi_rx_ss_0_sdi_rx_irq 1 3 1 NJ 750
preplace netloc v_uhdsdi_audio_0_interrupt 1 2 2 840J 410 NJ
preplace netloc Conn1 1 0 3 NJ 290 410J 350 870J
preplace netloc Conn2 1 3 1 NJ 650
preplace netloc Conn3 1 0 3 NJ 310 390J 360 860J
preplace netloc Conn4 1 3 1 NJ 70
preplace netloc Conn5 1 0 1 NJ 370
preplace netloc Conn6 1 3 1 NJ 490
preplace netloc axis_subset_converter_0_M_AXIS 1 1 1 380 230n
preplace netloc smartconnect_0_M00_AXI 1 1 2 370 670 NJ
preplace netloc smartconnect_0_M01_AXI 1 1 2 350 50 NJ
preplace netloc smartconnect_0_M02_AXI 1 1 1 N 420
preplace netloc smartconnect_0_M03_AXI 1 1 1 360 210n
preplace netloc v_proc_ss_0_m_axis 1 2 1 840 70n
preplace netloc v_smpte_uhdsdi_rx_ss_0_SDI_RX_ANC_DS_OUT 1 1 3 440 850 NJ 850 1260
preplace netloc v_smpte_uhdsdi_rx_ss_0_VIDEO_OUT 1 0 4 50 710 360J 660 890J 570 1250
preplace netloc v_uhdsdi_audio_Extract_M_AXIS_DATA 1 2 1 N 470
levelinfo -pg 1 0 200 640 1070 1280
pagesize -pg 1 -db -bbox -sgen -170 0 1460 870
"
}

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: peripheral_gt_heir
proc create_hier_cell_peripheral_gt_heir { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_peripheral_gt_heir() - Empty argument(s)!"}
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

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 gt_refclk

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 gt_refclk2

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 GT_Serial_0

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 SDI_RX_AXI4S_CH0

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 SDI_RX_PHY_SB_CTRL

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 SDI_RX_PHY_SB_STS

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 SDI_TX_AXI4S_CH0

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 SDI_TX_PHY_SB_CTRL

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 SDI_TX_PHY_SB_STS


  # Create pins
  create_bd_pin -dir I -from 0 -to 0 Op2
  create_bd_pin -dir O -from 0 -to 0 Res
  create_bd_pin -dir O -type clk clk_out2
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_aresetn
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_aresetn1
  create_bd_pin -dir I -type rst reset
  create_bd_pin -dir O -type clk clk_freerun
  create_bd_pin -dir I -type clk clk_in1
  create_bd_pin -dir O -from 7 -to 0 gpio_io_o2
  create_bd_pin -dir O -from 0 -to 0 dout
  create_bd_pin -dir I -from 31 -to 0 QUAD0_gpi_0
  create_bd_pin -dir O -type gt_usrclk clk_txusrclk
  create_bd_pin -dir O -type clk clk_rxusrclk
  create_bd_pin -dir O -from 31 -to 0 QUAD0_gpo_0

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


  # Create instance: clkx5_wiz_0, and set properties
  set clkx5_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clkx5_wiz clkx5_wiz_0 ]
  set_property -dict [list \
    CONFIG.CLKOUT_DRIVES {BUFG,BUFG,BUFG,BUFG,BUFG,BUFG,BUFG} \
    CONFIG.CLKOUT_DYN_PS {None,None,None,None,None,None,None} \
    CONFIG.CLKOUT_GROUPING {Auto,Auto,Auto,Auto,Auto,Auto,Auto} \
    CONFIG.CLKOUT_MATCHED_ROUTING {false,false,false,false,false,false,false} \
    CONFIG.CLKOUT_PORT {clk_out1,clk_out2,clk_out3,clk_out4,clk_out5,clk_out6,clk_out7} \
    CONFIG.CLKOUT_REQUESTED_DUTY_CYCLE {50.000,50.000,50.000,50.000,50.000,50.000,50.000} \
    CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {100,300.000,100.000,100.000,100.000,100.000,100.000} \
    CONFIG.CLKOUT_REQUESTED_PHASE {0.000,0.000,0.000,0.000,0.000,0.000,0.000} \
    CONFIG.CLKOUT_USED {true,true,false,false,false,false,false} \
  ] $clkx5_wiz_0


  # Create instance: axi_smartconnect_0, and set properties
  set axi_smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect axi_smartconnect_0 ]
  set_property -dict [list \
    CONFIG.ADVANCED_PROPERTIES {__experimental_features__ {legacy_low_area_mode 1}} \
    CONFIG.NUM_CLKS {3} \
    CONFIG.NUM_MI {6} \
    CONFIG.NUM_SI {1} \
  ] $axi_smartconnect_0


  # Create instance: axi_quad_spi_0, and set properties
  set axi_quad_spi_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_quad_spi axi_quad_spi_0 ]
  set_property -dict [list \
    CONFIG.C_NUM_SS_BITS {3} \
    CONFIG.C_NUM_TRANSFER_BITS {16} \
  ] $axi_quad_spi_0


  # Create instance: axi_gpio_1, and set properties
  set axi_gpio_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio axi_gpio_1 ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_GPIO_WIDTH {8} \
  ] $axi_gpio_1


  # Create instance: xlconstant_2, and set properties
  set xlconstant_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant xlconstant_2 ]
  set_property CONFIG.CONST_VAL {0} $xlconstant_2


  # Create instance: gt_hier
  create_hier_cell_gt_hier $hier_obj gt_hier

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins fzetton_fmc_iic] [get_bd_intf_pins axi_iic_0/IIC]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins fzetton_fmc_gpio] [get_bd_intf_pins axi_gpio_3/GPIO]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins axi_smartconnect_0/S00_AXI] [get_bd_intf_pins S00_AXI]
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins gt_hier/gt_refclk] [get_bd_intf_pins gt_refclk]
  connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins gt_hier/gt_refclk2] [get_bd_intf_pins gt_refclk2]
  connect_bd_intf_net -intf_net Conn6 [get_bd_intf_pins gt_hier/GT_Serial_0] [get_bd_intf_pins GT_Serial_0]
  connect_bd_intf_net -intf_net Conn7 [get_bd_intf_pins gt_hier/SDI_RX_AXI4S_CH0] [get_bd_intf_pins SDI_RX_AXI4S_CH0]
  connect_bd_intf_net -intf_net Conn8 [get_bd_intf_pins gt_hier/SDI_RX_PHY_SB_CTRL] [get_bd_intf_pins SDI_RX_PHY_SB_CTRL]
  connect_bd_intf_net -intf_net Conn9 [get_bd_intf_pins gt_hier/SDI_RX_PHY_SB_STS] [get_bd_intf_pins SDI_RX_PHY_SB_STS]
  connect_bd_intf_net -intf_net Conn10 [get_bd_intf_pins gt_hier/SDI_TX_AXI4S_CH0] [get_bd_intf_pins SDI_TX_AXI4S_CH0]
  connect_bd_intf_net -intf_net Conn11 [get_bd_intf_pins gt_hier/SDI_TX_PHY_SB_CTRL] [get_bd_intf_pins SDI_TX_PHY_SB_CTRL]
  connect_bd_intf_net -intf_net Conn12 [get_bd_intf_pins gt_hier/SDI_TX_PHY_SB_STS] [get_bd_intf_pins SDI_TX_PHY_SB_STS]
  connect_bd_intf_net -intf_net Conn19 [get_bd_intf_pins axi_quad_spi_0/SPI_0] [get_bd_intf_pins fzetton_fmc_spi]
  connect_bd_intf_net -intf_net axi_smartconnect_0_M00_AXI [get_bd_intf_pins axi_smartconnect_0/M00_AXI] [get_bd_intf_pins axi_gpio_3/S_AXI]
  connect_bd_intf_net -intf_net axi_smartconnect_0_M01_AXI [get_bd_intf_pins axi_smartconnect_0/M01_AXI] [get_bd_intf_pins axi_iic_0/S_AXI]
  connect_bd_intf_net -intf_net axi_smartconnect_0_M02_AXI [get_bd_intf_pins axi_smartconnect_0/M02_AXI] [get_bd_intf_pins axi_gpio_0/S_AXI]
  connect_bd_intf_net -intf_net axi_smartconnect_0_M03_AXI [get_bd_intf_pins axi_quad_spi_0/AXI_LITE] [get_bd_intf_pins axi_smartconnect_0/M03_AXI]
  connect_bd_intf_net -intf_net axi_smartconnect_0_M04_AXI [get_bd_intf_pins axi_smartconnect_0/M04_AXI] [get_bd_intf_pins axi_gpio_2/S_AXI]
  connect_bd_intf_net -intf_net axi_smartconnect_0_M05_AXI [get_bd_intf_pins axi_smartconnect_0/M05_AXI] [get_bd_intf_pins axi_gpio_1/S_AXI]

  # Create port connections
  connect_bd_net -net Op2_1  [get_bd_pins Op2] \
  [get_bd_pins proc_sys_reset_1/aux_reset_in] \
  [get_bd_pins proc_sys_reset_0/aux_reset_in]
  connect_bd_net -net QUAD0_gpi_0_1  [get_bd_pins QUAD0_gpi_0] \
  [get_bd_pins gt_hier/QUAD0_gpi_0]
  connect_bd_net -net axi_gpio_0_gpio_io_o  [get_bd_pins axi_gpio_0/gpio_io_o] \
  [get_bd_pins gt_hier/sdi_gt_ctrl]
  connect_bd_net -net axi_gpio_1_gpio_io_o  [get_bd_pins axi_gpio_1/gpio_io_o] \
  [get_bd_pins gpio_io_o2]
  connect_bd_net -net axi_gpio_2_gpio_io_o  [get_bd_pins axi_gpio_2/gpio_io_o] \
  [get_bd_pins util_vector_logic_4/Op1] \
  [get_bd_pins gt_hier/RESET_I]
  connect_bd_net -net clkx5_wiz_0_clk_out1  [get_bd_pins clkx5_wiz_0/clk_out1] \
  [get_bd_pins axi_iic_0/s_axi_aclk] \
  [get_bd_pins axi_gpio_0/s_axi_aclk] \
  [get_bd_pins axi_gpio_3/s_axi_aclk] \
  [get_bd_pins axi_gpio_2/s_axi_aclk] \
  [get_bd_pins xpm_cdc_gen_0/src_clk] \
  [get_bd_pins clk_freerun] \
  [get_bd_pins proc_sys_reset_0/slowest_sync_clk] \
  [get_bd_pins axi_quad_spi_0/ext_spi_clk] \
  [get_bd_pins axi_quad_spi_0/s_axi_aclk] \
  [get_bd_pins axi_smartconnect_0/aclk] \
  [get_bd_pins axi_gpio_1/s_axi_aclk] \
  [get_bd_pins gt_hier/clk_freerun]
  connect_bd_net -net clkx5_wiz_1_clk_out2  [get_bd_pins clkx5_wiz_0/clk_out2] \
  [get_bd_pins clk_out2] \
  [get_bd_pins xpm_cdc_gen_0/dest_clk] \
  [get_bd_pins proc_sys_reset_1/slowest_sync_clk] \
  [get_bd_pins axi_smartconnect_0/aclk2]
  connect_bd_net -net ext_reset_in_0_1  [get_bd_pins reset] \
  [get_bd_pins proc_sys_reset_0/ext_reset_in] \
  [get_bd_pins proc_sys_reset_1/ext_reset_in]
  connect_bd_net -net gt_hier_QUAD0_gpo_0  [get_bd_pins gt_hier/QUAD0_gpo_0] \
  [get_bd_pins QUAD0_gpo_0]
  connect_bd_net -net gt_hier_clk_rxusrclk  [get_bd_pins gt_hier/clk_rxusrclk] \
  [get_bd_pins clk_rxusrclk]
  connect_bd_net -net gt_hier_clk_txusrclk  [get_bd_pins gt_hier/clk_txusrclk] \
  [get_bd_pins clk_txusrclk]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn  [get_bd_pins proc_sys_reset_0/peripheral_aresetn] \
  [get_bd_pins peripheral_aresetn] \
  [get_bd_pins axi_gpio_0/s_axi_aresetn] \
  [get_bd_pins axi_gpio_2/s_axi_aresetn] \
  [get_bd_pins axi_gpio_3/s_axi_aresetn] \
  [get_bd_pins axi_iic_0/s_axi_aresetn] \
  [get_bd_pins axi_quad_spi_0/s_axi_aresetn] \
  [get_bd_pins axi_smartconnect_0/aresetn] \
  [get_bd_pins axi_gpio_1/s_axi_aresetn] \
  [get_bd_pins gt_hier/gt_ctrl_aresetn]
  connect_bd_net -net proc_sys_reset_1_peripheral_aresetn  [get_bd_pins proc_sys_reset_1/peripheral_aresetn] \
  [get_bd_pins peripheral_aresetn1]
  connect_bd_net -net ps_wizard_0_pl0_ref_clk  [get_bd_pins clk_in1] \
  [get_bd_pins axi_smartconnect_0/aclk1] \
  [get_bd_pins clkx5_wiz_0/clk_in1]
  connect_bd_net -net util_vector_logic_4_Res  [get_bd_pins util_vector_logic_4/Res] \
  [get_bd_pins xpm_cdc_gen_0/src_in]
  connect_bd_net -net xlconstant_2_dout  [get_bd_pins xlconstant_2/dout] \
  [get_bd_pins dout]
  connect_bd_net -net xpm_cdc_gen_0_dest_out  [get_bd_pins xpm_cdc_gen_0/dest_out] \
  [get_bd_pins Res]

  # Perform GUI Layout
  regenerate_bd_layout -hierarchy [get_bd_cells /sdi/peripheral_gt_heir] -layout_string {
   "ActiveEmotionalView":"Default View",
   "Default View_ScaleFactor":"0.507346",
   "Default View_TopLeft":"-1072,4",
   "ExpandedHierarchyInLayout":"",
   "guistr":"# # String gsaved with Nlview 7.8.0 2024-04-26 e1825d835c VDI=44 GEI=38 GUI=JA:21.0 TLS
#  -string -flagsOSRD
preplace port fzetton_fmc_gpio -pg 1 -lvl 3 -x 870 -y 510 -defaultsOSRD
preplace port fzetton_fmc_iic -pg 1 -lvl 3 -x 870 -y 790 -defaultsOSRD
preplace port fzetton_fmc_spi -pg 1 -lvl 3 -x 870 -y 950 -defaultsOSRD
preplace port S00_AXI -pg 1 -lvl 0 -x 0 -y 780 -defaultsOSRD
preplace port gt_refclk -pg 1 -lvl 0 -x 0 -y 120 -defaultsOSRD
preplace port gt_refclk2 -pg 1 -lvl 0 -x 0 -y 140 -defaultsOSRD
preplace port GT_Serial_0 -pg 1 -lvl 3 -x 870 -y 150 -defaultsOSRD
preplace port SDI_RX_AXI4S_CH0 -pg 1 -lvl 3 -x 870 -y 130 -defaultsOSRD
preplace port SDI_RX_PHY_SB_CTRL -pg 1 -lvl 0 -x 0 -y 100 -defaultsOSRD
preplace port SDI_RX_PHY_SB_STS -pg 1 -lvl 3 -x 870 -y 110 -defaultsOSRD
preplace port SDI_TX_AXI4S_CH0 -pg 1 -lvl 0 -x 0 -y 80 -defaultsOSRD
preplace port SDI_TX_PHY_SB_CTRL -pg 1 -lvl 0 -x 0 -y 60 -defaultsOSRD
preplace port SDI_TX_PHY_SB_STS -pg 1 -lvl 3 -x 870 -y 90 -defaultsOSRD
preplace port port-id_clk_out2 -pg 1 -lvl 3 -x 870 -y 1370 -defaultsOSRD
preplace port port-id_reset -pg 1 -lvl 0 -x 0 -y 1430 -defaultsOSRD
preplace port port-id_clk_freerun -pg 1 -lvl 3 -x 870 -y 1050 -defaultsOSRD
preplace port port-id_clk_in1 -pg 1 -lvl 0 -x 0 -y 820 -defaultsOSRD
preplace port port-id_clk_txusrclk -pg 1 -lvl 3 -x 870 -y 190 -defaultsOSRD
preplace port port-id_clk_rxusrclk -pg 1 -lvl 3 -x 870 -y 170 -defaultsOSRD
preplace portBus Op2 -pg 1 -lvl 0 -x 0 -y 1450 -defaultsOSRD
preplace portBus Res -pg 1 -lvl 3 -x 870 -y 1290 -defaultsOSRD
preplace portBus peripheral_aresetn -pg 1 -lvl 3 -x 870 -y 1210 -defaultsOSRD
preplace portBus peripheral_aresetn1 -pg 1 -lvl 3 -x 870 -y 1610 -defaultsOSRD
preplace portBus gpio_io_o2 -pg 1 -lvl 3 -x 870 -y 1140 -defaultsOSRD
preplace portBus dout -pg 1 -lvl 3 -x 870 -y 1710 -defaultsOSRD
preplace portBus QUAD0_gpi_0 -pg 1 -lvl 0 -x 0 -y 220 -defaultsOSRD
preplace portBus QUAD0_gpo_0 -pg 1 -lvl 3 -x 870 -y 210 -defaultsOSRD
preplace inst axi_gpio_0 -pg 1 -lvl 2 -x 660 -y 370 -defaultsOSRD
preplace inst axi_gpio_2 -pg 1 -lvl 2 -x 660 -y 650 -defaultsOSRD
preplace inst axi_gpio_3 -pg 1 -lvl 2 -x 660 -y 510 -defaultsOSRD
preplace inst axi_iic_0 -pg 1 -lvl 2 -x 660 -y 810 -defaultsOSRD
preplace inst proc_sys_reset_0 -pg 1 -lvl 1 -x 230 -y 1450 -defaultsOSRD
preplace inst proc_sys_reset_1 -pg 1 -lvl 2 -x 660 -y 1570 -defaultsOSRD
preplace inst util_vector_logic_4 -pg 1 -lvl 1 -x 230 -y 1310 -defaultsOSRD
preplace inst xpm_cdc_gen_0 -pg 1 -lvl 2 -x 660 -y 1290 -defaultsOSRD
preplace inst clkx5_wiz_0 -pg 1 -lvl 1 -x 230 -y 1000 -defaultsOSRD
preplace inst axi_smartconnect_0 -pg 1 -lvl 1 -x 230 -y 820 -defaultsOSRD
preplace inst axi_quad_spi_0 -pg 1 -lvl 2 -x 660 -y 960 -defaultsOSRD
preplace inst axi_gpio_1 -pg 1 -lvl 2 -x 660 -y 1130 -defaultsOSRD
preplace inst xlconstant_2 -pg 1 -lvl 2 -x 660 -y 1710 -defaultsOSRD
preplace inst gt_hier -pg 1 -lvl 2 -x 660 -y 150 -defaultsOSRD
preplace netloc Op2_1 1 0 2 20 1570 NJ
preplace netloc QUAD0_gpi_0_1 1 0 2 NJ 220 NJ
preplace netloc axi_gpio_0_gpio_io_o 1 1 2 470 290 850
preplace netloc axi_gpio_1_gpio_io_o 1 2 1 NJ 1140
preplace netloc axi_gpio_2_gpio_io_o 1 0 3 50 1070 460 730 850
preplace netloc clkx5_wiz_0_clk_out1 1 0 3 30 1080 420 1050 NJ
preplace netloc clkx5_wiz_1_clk_out2 1 0 3 40 930 410 1370 NJ
preplace netloc ext_reset_in_0_1 1 0 2 40 1550 NJ
preplace netloc gt_hier_QUAD0_gpo_0 1 2 1 NJ 210
preplace netloc gt_hier_clk_rxusrclk 1 2 1 NJ 170
preplace netloc gt_hier_clk_txusrclk 1 2 1 NJ 190
preplace netloc proc_sys_reset_0_peripheral_aresetn 1 0 3 50 710 450 1210 NJ
preplace netloc proc_sys_reset_1_peripheral_aresetn 1 2 1 NJ 1610
preplace netloc ps_wizard_0_pl0_ref_clk 1 0 1 20 820n
preplace netloc util_vector_logic_4_Res 1 1 1 NJ 1310
preplace netloc xlconstant_2_dout 1 2 1 NJ 1710
preplace netloc xpm_cdc_gen_0_dest_out 1 2 1 NJ 1290
preplace netloc Conn1 1 2 1 NJ 790
preplace netloc Conn2 1 2 1 NJ 510
preplace netloc Conn3 1 0 1 NJ 780
preplace netloc Conn4 1 0 2 NJ 120 NJ
preplace netloc Conn5 1 0 2 NJ 140 NJ
preplace netloc Conn6 1 2 1 NJ 150
preplace netloc Conn7 1 2 1 NJ 130
preplace netloc Conn8 1 0 2 NJ 100 NJ
preplace netloc Conn9 1 2 1 NJ 110
preplace netloc Conn10 1 0 2 NJ 80 NJ
preplace netloc Conn11 1 0 2 NJ 60 NJ
preplace netloc Conn12 1 2 1 NJ 90
preplace netloc Conn19 1 2 1 NJ 950
preplace netloc axi_smartconnect_0_M00_AXI 1 1 1 440 490n
preplace netloc axi_smartconnect_0_M01_AXI 1 1 1 N 790
preplace netloc axi_smartconnect_0_M02_AXI 1 1 1 410 350n
preplace netloc axi_smartconnect_0_M03_AXI 1 1 1 440 830n
preplace netloc axi_smartconnect_0_M04_AXI 1 1 1 470 630n
preplace netloc axi_smartconnect_0_M05_AXI 1 1 1 430 870n
levelinfo -pg 1 0 230 660 870
pagesize -pg 1 -db -bbox -sgen -210 0 1100 1770
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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 fzetton_fmc_gpio

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 fzetton_fmc_iic

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:spi_rtl:1.0 fzetton_fmc_spi

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 gt_refclk

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 gt_refclk2

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 GT_Serial_0

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M00_INI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M01_INI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI


  # Create pins
  create_bd_pin -dir I -type clk aclk2
  create_bd_pin -dir I -from 31 -to 0 QUAD0_gpi_0
  create_bd_pin -dir O -type clk clk_txusrclk
  create_bd_pin -dir O -type clk clk_rxusrclk
  create_bd_pin -dir O -from 31 -to 0 QUAD0_gpo_0
  create_bd_pin -dir I -type rst reset
  create_bd_pin -dir O irq

  # Create instance: peripheral_gt_heir
  create_hier_cell_peripheral_gt_heir $hier_obj peripheral_gt_heir

  # Create instance: RX_Heir
  create_hier_cell_RX_Heir $hier_obj RX_Heir

  # Create instance: Tx_Heir
  create_hier_cell_Tx_Heir $hier_obj Tx_Heir

  # Create instance: axi_noc2_0, and set properties
  set axi_noc2_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc2 axi_noc2_0 ]
  set_property -dict [list \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NMI {2} \
    CONFIG.NUM_SI {3} \
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
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS {M01_INI {read_bw {500} write_bw {500} } M00_INI {read_bw {500} write_bw {500} }} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins $axi_noc2_0/S02_AXI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXI:S01_AXI:S02_AXI} \
 ] [get_bd_pins $axi_noc2_0/aclk0]

  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_0 ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {3} \
    CONFIG.NUM_MI {4} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_0


  # Create instance: axi_intc_0, and set properties
  set axi_intc_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc axi_intc_0 ]
  set_property CONFIG.C_IRQ_CONNECTION {1} $axi_intc_0


  # Create instance: irq_concat, and set properties
  set irq_concat [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat irq_concat ]
  set_property CONFIG.NUM_PORTS {6} $irq_concat


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins axi_noc2_0/M00_INI] [get_bd_intf_pins M00_INI]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins axi_noc2_0/M01_INI] [get_bd_intf_pins M01_INI]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins smartconnect_0/S00_AXI] [get_bd_intf_pins S00_AXI]
  connect_bd_intf_net -intf_net Processor_Heir_GT_Serial_0 [get_bd_intf_pins GT_Serial_0] [get_bd_intf_pins peripheral_gt_heir/GT_Serial_0]
  connect_bd_intf_net -intf_net Processor_Heir_SPI_0_0 [get_bd_intf_pins fzetton_fmc_spi] [get_bd_intf_pins peripheral_gt_heir/fzetton_fmc_spi]
  connect_bd_intf_net -intf_net Processor_Heir_fzetton_fmc_gpio [get_bd_intf_pins fzetton_fmc_gpio] [get_bd_intf_pins peripheral_gt_heir/fzetton_fmc_gpio]
  connect_bd_intf_net -intf_net Processor_Heir_fzetton_fmc_iic [get_bd_intf_pins fzetton_fmc_iic] [get_bd_intf_pins peripheral_gt_heir/fzetton_fmc_iic]
  connect_bd_intf_net -intf_net RX_Heir_M_AXIS_CTRL_SB_RX [get_bd_intf_pins RX_Heir/M_AXIS_CTRL_SB_RX] [get_bd_intf_pins peripheral_gt_heir/SDI_RX_PHY_SB_CTRL]
  connect_bd_intf_net -intf_net RX_Heir_m_axi_mm_video [get_bd_intf_pins RX_Heir/m_axi_mm_video] [get_bd_intf_pins axi_noc2_0/S00_AXI]
  connect_bd_intf_net -intf_net S_AXIS_DATA_1 [get_bd_intf_pins Tx_Heir/S_AXIS_DATA] [get_bd_intf_pins RX_Heir/M_AXIS]
  connect_bd_intf_net -intf_net S_AXIS_RX_1 [get_bd_intf_pins RX_Heir/S_AXIS_RX] [get_bd_intf_pins peripheral_gt_heir/SDI_RX_AXI4S_CH0]
  connect_bd_intf_net -intf_net S_AXIS_STS_SB_RX_1 [get_bd_intf_pins RX_Heir/S_AXIS_STS_SB_RX] [get_bd_intf_pins peripheral_gt_heir/SDI_RX_PHY_SB_STS]
  connect_bd_intf_net -intf_net S_AXIS_STS_SB_TX_1 [get_bd_intf_pins Tx_Heir/S_AXIS_STS_SB_TX] [get_bd_intf_pins peripheral_gt_heir/SDI_TX_PHY_SB_STS]
  connect_bd_intf_net -intf_net Tx_Heir_M_AXIS_CTRL_SB_TX [get_bd_intf_pins Tx_Heir/M_AXIS_CTRL_SB_TX] [get_bd_intf_pins peripheral_gt_heir/SDI_TX_PHY_SB_CTRL]
  connect_bd_intf_net -intf_net Tx_Heir_M_AXIS_TX [get_bd_intf_pins Tx_Heir/M_AXIS_TX] [get_bd_intf_pins peripheral_gt_heir/SDI_TX_AXI4S_CH0]
  connect_bd_intf_net -intf_net Tx_Heir_m_axi_mm_video1 [get_bd_intf_pins Tx_Heir/m_axi_mm_video1] [get_bd_intf_pins axi_noc2_0/S01_AXI]
  connect_bd_intf_net -intf_net Tx_Heir_m_axi_mm_video2 [get_bd_intf_pins Tx_Heir/m_axi_mm_video2] [get_bd_intf_pins axi_noc2_0/S02_AXI]
  connect_bd_intf_net -intf_net gt_refclk2_1 [get_bd_intf_pins gt_refclk2] [get_bd_intf_pins peripheral_gt_heir/gt_refclk2]
  connect_bd_intf_net -intf_net gt_refclk_1 [get_bd_intf_pins gt_refclk] [get_bd_intf_pins peripheral_gt_heir/gt_refclk]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins RX_Heir/S00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins smartconnect_0/M01_AXI] [get_bd_intf_pins peripheral_gt_heir/S00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins smartconnect_0/M02_AXI] [get_bd_intf_pins Tx_Heir/S00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M03_AXI [get_bd_intf_pins smartconnect_0/M03_AXI] [get_bd_intf_pins axi_intc_0/s_axi]

  # Create port connections
  connect_bd_net -net Processor_Heir_QUAD0_gpo_0  [get_bd_pins peripheral_gt_heir/QUAD0_gpo_0] \
  [get_bd_pins QUAD0_gpo_0]
  connect_bd_net -net Processor_Heir_Res  [get_bd_pins peripheral_gt_heir/Res] \
  [get_bd_pins RX_Heir/s_axis_aresetn]
  connect_bd_net -net Processor_Heir_gpio_io_o2  [get_bd_pins peripheral_gt_heir/gpio_io_o2] \
  [get_bd_pins RX_Heir/Din] \
  [get_bd_pins Tx_Heir/Din]
  connect_bd_net -net QUAD0_gpi_0_1  [get_bd_pins QUAD0_gpi_0] \
  [get_bd_pins peripheral_gt_heir/QUAD0_gpi_0]
  connect_bd_net -net RX_Heir_interrupt  [get_bd_pins RX_Heir/interrupt] \
  [get_bd_pins irq_concat/In0]
  connect_bd_net -net RX_Heir_interrupt1  [get_bd_pins RX_Heir/interrupt1] \
  [get_bd_pins irq_concat/In2]
  connect_bd_net -net RX_Heir_sdi_rx_irq  [get_bd_pins RX_Heir/sdi_rx_irq] \
  [get_bd_pins irq_concat/In1]
  connect_bd_net -net Tx_Heir_interrupt  [get_bd_pins Tx_Heir/interrupt] \
  [get_bd_pins irq_concat/In3]
  connect_bd_net -net Tx_Heir_interrupt1  [get_bd_pins Tx_Heir/interrupt1] \
  [get_bd_pins irq_concat/In5]
  connect_bd_net -net Tx_Heir_sdi_tx_irq  [get_bd_pins Tx_Heir/sdi_tx_irq] \
  [get_bd_pins irq_concat/In4]
  connect_bd_net -net axi_intc_0_irq  [get_bd_pins axi_intc_0/irq] \
  [get_bd_pins irq]
  connect_bd_net -net bufg_gt_1_usrclk  [get_bd_pins peripheral_gt_heir/clk_txusrclk] \
  [get_bd_pins clk_txusrclk] \
  [get_bd_pins Tx_Heir/sdi_tx_clk] \
  [get_bd_pins Tx_Heir/tx_lnk_clk]
  connect_bd_net -net bufg_gt_usrclk  [get_bd_pins peripheral_gt_heir/clk_rxusrclk] \
  [get_bd_pins clk_rxusrclk] \
  [get_bd_pins RX_Heir/sdi_rx_clk] \
  [get_bd_pins RX_Heir/rx_lnk_clk]
  connect_bd_net -net clk_freerun  [get_bd_pins peripheral_gt_heir/clk_freerun] \
  [get_bd_pins RX_Heir/clk_freerun] \
  [get_bd_pins Tx_Heir/clk_freerun] \
  [get_bd_pins Tx_Heir/s_axi_aclk] \
  [get_bd_pins RX_Heir/s_axi_aclk] \
  [get_bd_pins smartconnect_0/aclk] \
  [get_bd_pins axi_intc_0/s_axi_aclk]
  connect_bd_net -net clk_wizard_0_clk_out1  [get_bd_pins aclk2] \
  [get_bd_pins Tx_Heir/aclk2] \
  [get_bd_pins RX_Heir/aclk2] \
  [get_bd_pins peripheral_gt_heir/clk_in1] \
  [get_bd_pins smartconnect_0/aclk2]
  connect_bd_net -net clk_wizard_0_clk_out2  [get_bd_pins peripheral_gt_heir/clk_out2] \
  [get_bd_pins RX_Heir/video_out_clk] \
  [get_bd_pins Tx_Heir/video_in_clk] \
  [get_bd_pins axi_noc2_0/aclk0] \
  [get_bd_pins smartconnect_0/aclk1]
  connect_bd_net -net ilconcat_0_dout  [get_bd_pins irq_concat/dout] \
  [get_bd_pins axi_intc_0/intr]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn  [get_bd_pins peripheral_gt_heir/peripheral_aresetn] \
  [get_bd_pins RX_Heir/s_axi_arstn] \
  [get_bd_pins Tx_Heir/s_axi_arstn] \
  [get_bd_pins Tx_Heir/s_axi_arstn1] \
  [get_bd_pins RX_Heir/s_axi_arstn1] \
  [get_bd_pins smartconnect_0/aresetn] \
  [get_bd_pins axi_intc_0/s_axi_aresetn]
  connect_bd_net -net proc_sys_reset_1_peripheral_aresetn  [get_bd_pins peripheral_gt_heir/peripheral_aresetn1] \
  [get_bd_pins RX_Heir/video_out_arstn] \
  [get_bd_pins Tx_Heir/video_in_arstn]
  connect_bd_net -net reset_1  [get_bd_pins reset] \
  [get_bd_pins peripheral_gt_heir/reset]
  connect_bd_net -net v_smpte_uhdsdi_rx_ss_0_fid  [get_bd_pins RX_Heir/fid] \
  [get_bd_pins Tx_Heir/fid]
  connect_bd_net -net xlconstant_2_dout  [get_bd_pins peripheral_gt_heir/dout] \
  [get_bd_pins RX_Heir/sdi_rx_rst] \
  [get_bd_pins Tx_Heir/sdi_tx_rst]

  # Perform GUI Layout
  regenerate_bd_layout -hierarchy [get_bd_cells /sdi] -layout_string {
   "ActiveEmotionalView":"Default View",
   "Default View_ScaleFactor":"0.459627",
   "Default View_TopLeft":"-761,2",
   "ExpandedHierarchyInLayout":"",
   "guistr":"# # String gsaved with Nlview 7.8.0 2024-04-26 e1825d835c VDI=44 GEI=38 GUI=JA:21.0 TLS
#  -string -flagsOSRD
preplace port fzetton_fmc_gpio -pg 1 -lvl 5 -x 1940 -y 650 -defaultsOSRD
preplace port fzetton_fmc_iic -pg 1 -lvl 5 -x 1940 -y 670 -defaultsOSRD
preplace port fzetton_fmc_spi -pg 1 -lvl 5 -x 1940 -y 690 -defaultsOSRD
preplace port gt_refclk -pg 1 -lvl 0 -x 0 -y 740 -defaultsOSRD
preplace port gt_refclk2 -pg 1 -lvl 0 -x 0 -y 760 -defaultsOSRD
preplace port GT_Serial_0 -pg 1 -lvl 5 -x 1940 -y 710 -defaultsOSRD
preplace port M00_INI -pg 1 -lvl 5 -x 1940 -y 470 -defaultsOSRD
preplace port M01_INI -pg 1 -lvl 5 -x 1940 -y 490 -defaultsOSRD
preplace port S00_AXI -pg 1 -lvl 0 -x 0 -y 150 -defaultsOSRD
preplace port port-id_aclk2 -pg 1 -lvl 0 -x 0 -y 210 -defaultsOSRD
preplace port port-id_clk_txusrclk -pg 1 -lvl 5 -x 1940 -y 930 -defaultsOSRD
preplace port port-id_clk_rxusrclk -pg 1 -lvl 5 -x 1940 -y 950 -defaultsOSRD
preplace port port-id_reset -pg 1 -lvl 0 -x 0 -y 860 -defaultsOSRD
preplace port port-id_irq -pg 1 -lvl 5 -x 1940 -y 90 -defaultsOSRD
preplace portBus QUAD0_gpi_0 -pg 1 -lvl 0 -x 0 -y 900 -defaultsOSRD
preplace portBus QUAD0_gpo_0 -pg 1 -lvl 5 -x 1940 -y 970 -defaultsOSRD
preplace inst peripheral_gt_heir -pg 1 -lvl 4 -x 1620 -y 810 -defaultsOSRD
preplace inst RX_Heir -pg 1 -lvl 2 -x 640 -y 260 -defaultsOSRD
preplace inst Tx_Heir -pg 1 -lvl 3 -x 1140 -y 520 -defaultsOSRD
preplace inst axi_noc2_0 -pg 1 -lvl 4 -x 1620 -y 480 -defaultsOSRD
preplace inst smartconnect_0 -pg 1 -lvl 1 -x 190 -y 190 -defaultsOSRD
preplace inst axi_intc_0 -pg 1 -lvl 4 -x 1620 -y 90 -defaultsOSRD
preplace inst irq_concat -pg 1 -lvl 3 -x 1140 -y 180 -defaultsOSRD
preplace netloc Processor_Heir_QUAD0_gpo_0 1 4 1 NJ 970
preplace netloc Processor_Heir_Res 1 1 4 420 1030 NJ 1030 NJ 1030 1840
preplace netloc Processor_Heir_gpio_io_o2 1 1 4 430 510 830 1090 NJ 1090 1850
preplace netloc QUAD0_gpi_0_1 1 0 4 NJ 900 NJ 900 NJ 900 NJ
preplace netloc RX_Heir_interrupt 1 2 1 850 130n
preplace netloc RX_Heir_interrupt1 1 2 1 870 170n
preplace netloc RX_Heir_sdi_rx_irq 1 2 1 860 150n
preplace netloc Tx_Heir_interrupt 1 2 2 960 290 1320
preplace netloc Tx_Heir_interrupt1 1 2 2 940 310 1340
preplace netloc Tx_Heir_sdi_tx_irq 1 2 2 950 300 1330
preplace netloc axi_intc_0_irq 1 4 1 NJ 90
preplace netloc bufg_gt_1_usrclk 1 2 3 930 1110 NJ 1110 1920
preplace netloc bufg_gt_usrclk 1 1 4 400 1120 NJ 1120 NJ 1120 1910
preplace netloc clk_freerun 1 0 5 50 290 380 460 890 710 1360 1080 1860
preplace netloc clk_wizard_0_clk_out1 1 0 4 20 310 330 520 850 880 NJ
preplace netloc clk_wizard_0_clk_out2 1 0 5 40 300 350 500 840 720 1410 1020 1820
preplace netloc ilconcat_0_dout 1 3 1 1320 120n
preplace netloc proc_sys_reset_0_peripheral_aresetn 1 0 5 30 320 370 470 950 320 1400 590 1830
preplace netloc proc_sys_reset_1_peripheral_aresetn 1 1 4 440 490 870 1070 NJ 1070 1870
preplace netloc reset_1 1 0 4 NJ 860 NJ 860 NJ 860 NJ
preplace netloc v_smpte_uhdsdi_rx_ss_0_fid 1 2 1 910 260n
preplace netloc xlconstant_2_dout 1 1 4 450 480 860 1100 NJ 1100 1830
preplace netloc Conn1 1 4 1 NJ 470
preplace netloc Conn2 1 4 1 NJ 490
preplace netloc Conn3 1 0 1 NJ 150
preplace netloc Processor_Heir_GT_Serial_0 1 4 1 NJ 710
preplace netloc Processor_Heir_SPI_0_0 1 4 1 NJ 690
preplace netloc Processor_Heir_fzetton_fmc_gpio 1 4 1 NJ 650
preplace netloc Processor_Heir_fzetton_fmc_iic 1 4 1 NJ 670
preplace netloc RX_Heir_M_AXIS_CTRL_SB_RX 1 2 2 880 780 NJ
preplace netloc RX_Heir_m_axi_mm_video 1 2 2 830J 70 1380
preplace netloc S_AXIS_DATA_1 1 2 1 920 240n
preplace netloc S_AXIS_RX_1 1 1 4 410 1040 NJ 1040 NJ 1040 1900
preplace netloc S_AXIS_STS_SB_RX_1 1 1 4 390 1050 NJ 1050 NJ 1050 1890
preplace netloc S_AXIS_STS_SB_TX_1 1 2 3 960 1060 NJ 1060 1880
preplace netloc Tx_Heir_M_AXIS_CTRL_SB_TX 1 3 1 1350 480n
preplace netloc Tx_Heir_M_AXIS_TX 1 3 1 1380 460n
preplace netloc Tx_Heir_m_axi_mm_video1 1 3 1 1370 470n
preplace netloc Tx_Heir_m_axi_mm_video2 1 3 1 1390 490n
preplace netloc gt_refclk2_1 1 0 4 NJ 760 NJ 760 NJ 760 NJ
preplace netloc gt_refclk_1 1 0 4 NJ 740 NJ 740 NJ 740 NJ
preplace netloc smartconnect_0_M00_AXI 1 1 1 N 160
preplace netloc smartconnect_0_M01_AXI 1 1 3 340 730 NJ 730 1420J
preplace netloc smartconnect_0_M02_AXI 1 1 2 360 450 900J
preplace netloc smartconnect_0_M03_AXI 1 1 3 350J 60 NJ 60 N
levelinfo -pg 1 0 190 640 1140 1620 1940
pagesize -pg 1 -db -bbox -sgen -190 0 2140 1130
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
   puts "#    create_hier_cell_peripheral_gt_heir parentCell nameHier"
   puts "#    create_hier_cell_RX_Heir parentCell nameHier"
   puts "#    create_hier_cell_Tx_Heir parentCell nameHier"
   puts "#    create_hier_cell_gt_hier parentCell nameHier"
   puts "#    create_hier_cell_Picxo_Heir parentCell nameHier"
   puts "#    create_hier_cell_hier_constant parentCell nameHier"
   puts "#"
   puts "##################################################################"
}

available_tcl_procs

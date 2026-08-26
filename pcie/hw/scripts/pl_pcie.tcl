# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
###############################################################

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
user.org:user:pcie_reg_space:*\

xilinx.com:inline_hdl:ilconcat:*\

xilinx.com:inline_hdl:ilconstant:*\

xilinx.com:ip:axi_intc:*\

xilinx.com:ip:axi_noc2:*\

xilinx.com:ip:qdma:*\

xilinx.com:ip:smartconnect:*\

xilinx.com:ip:gtwiz_versal:*\

xilinx.com:ip:pcie_phy_versal:*\

xilinx.com:ip:pcie_versal:*\

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

# Hierarchical cell: qdma_0_support
proc create_hier_cell_qdma_0_support { parentCell nameHier } {
  variable script_folder
  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_qdma_0_support() - Empty argument(s)!"}
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

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 pcie_mgt
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_refclk
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_cq
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_rc
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie_cfg_fc_rtl:1.1 pcie_cfg_fc
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:pcie3_cfg_interrupt_rtl:1.0 pcie_cfg_interrupt
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie3_cfg_msg_received_rtl:1.0 pcie_cfg_mesg_rcvd
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie3_cfg_mesg_tx_rtl:1.0 pcie_cfg_mesg_tx
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_cc
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_rq
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:pcie5_cfg_control_rtl:1.0 pcie_cfg_control
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:pcie4_cfg_msix_rtl:1.0 pcie_cfg_external_msix_without_msi
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:pcie4_cfg_mgmt_rtl:1.0 pcie_cfg_mgmt
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie5_cfg_status_rtl:1.0 pcie_cfg_status
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie3_transmit_fc_rtl:1.0 pcie_transmit_fc
  create_bd_pin -dir I -type rst sys_reset
  create_bd_pin -dir I -type clk gtwiz_freerun_clk
  create_bd_pin -dir I -from 0 -to 0 BUFG_GT_CE
  create_bd_pin -dir O phy_rdy_out
  create_bd_pin -dir O -type clk user_clk
  create_bd_pin -dir O user_lnk_up
  create_bd_pin -dir O -type rst user_reset
  create_bd_cell -type ip -vlnv xilinx.com:ip:pcie_versal pcie
  set_property -dict [list \
    CONFIG.AXISTEN_IF_CQ_ALIGNMENT_MODE {Address_Aligned} \
    CONFIG.AXISTEN_IF_RQ_ALIGNMENT_MODE {DWORD_Aligned} \
    CONFIG.MSI_X_OPTIONS {MSI-X_External} \
    CONFIG.PF0_AER_CAP_ECRC_GEN_AND_CHECK_CAPABLE {false} \
    CONFIG.PF0_DEVICE_ID {B048} \
    CONFIG.PF0_INTERRUPT_PIN {INTA} \
    CONFIG.PF0_LINK_STATUS_SLOT_CLOCK_CONFIG {true} \
    CONFIG.PF0_MSIX_CAP_PBA_BIR {BAR_1:0} \
    CONFIG.PF0_MSIX_CAP_PBA_OFFSET {34000} \
    CONFIG.PF0_MSIX_CAP_TABLE_BIR {BAR_1:0} \
    CONFIG.PF0_MSIX_CAP_TABLE_OFFSET {30000} \
    CONFIG.PF0_MSIX_CAP_TABLE_SIZE {007} \
    CONFIG.PF0_REVISION_ID {00} \
    CONFIG.PF0_SRIOV_VF_DEVICE_ID {C048} \
    CONFIG.PF0_SUBSYSTEM_ID {0007} \
    CONFIG.PF0_SUBSYSTEM_VENDOR_ID {10EE} \
    CONFIG.PF0_Use_Class_Code_Lookup_Assistant {false} \
    CONFIG.PF1_DEVICE_ID {913F} \
    CONFIG.PF1_MSIX_CAP_PBA_BIR {BAR_1:0} \
    CONFIG.PF1_MSIX_CAP_TABLE_BIR {BAR_1:0} \
    CONFIG.PF1_MSI_CAP_MULTIMSGCAP {1_vector} \
    CONFIG.PF1_REVISION_ID {00} \
    CONFIG.PF1_SUBSYSTEM_ID {0007} \
    CONFIG.PF1_SUBSYSTEM_VENDOR_ID {10EE} \
    CONFIG.PF1_Use_Class_Code_Lookup_Assistant {false} \
    CONFIG.PF2_DEVICE_ID {B248} \
    CONFIG.PF2_MSIX_CAP_PBA_BIR {BAR_1:0} \
    CONFIG.PF2_MSIX_CAP_TABLE_BIR {BAR_1:0} \
    CONFIG.PF2_MSI_CAP_MULTIMSGCAP {1_vector} \
    CONFIG.PF2_REVISION_ID {00} \
    CONFIG.PF2_SUBSYSTEM_ID {0007} \
    CONFIG.PF2_SUBSYSTEM_VENDOR_ID {10EE} \
    CONFIG.PF2_Use_Class_Code_Lookup_Assistant {false} \
    CONFIG.PF3_DEVICE_ID {B348} \
    CONFIG.PF3_MSIX_CAP_PBA_BIR {BAR_1:0} \
    CONFIG.PF3_MSIX_CAP_TABLE_BIR {BAR_1:0} \
    CONFIG.PF3_MSI_CAP_MULTIMSGCAP {1_vector} \
    CONFIG.PF3_REVISION_ID {00} \
    CONFIG.PF3_SUBSYSTEM_ID {0007} \
    CONFIG.PF3_SUBSYSTEM_VENDOR_ID {10EE} \
    CONFIG.PF3_Use_Class_Code_Lookup_Assistant {false} \
    CONFIG.PL_DISABLE_LANE_REVERSAL {TRUE} \
    CONFIG.PL_LINK_CAP_MAX_LINK_SPEED {16.0_GT/s} \
    CONFIG.PL_LINK_CAP_MAX_LINK_WIDTH {X8} \
    CONFIG.REF_CLK_FREQ {100_MHz} \
    CONFIG.SRIOV_CAP_ENABLE {false} \
    CONFIG.TL_PF_ENABLE_REG {1} \
    CONFIG.VFG0_MSIX_CAP_PBA_BIR {BAR_1:0} \
    CONFIG.VFG0_MSIX_CAP_PBA_OFFSET {4800} \
    CONFIG.VFG0_MSIX_CAP_TABLE_BIR {BAR_1:0} \
    CONFIG.VFG0_MSIX_CAP_TABLE_OFFSET {4000} \
    CONFIG.VFG0_MSIX_CAP_TABLE_SIZE {007} \
    CONFIG.VFG1_MSIX_CAP_TABLE_OFFSET {4000} \
    CONFIG.VFG2_MSIX_CAP_TABLE_OFFSET {4000} \
    CONFIG.VFG3_MSIX_CAP_TABLE_OFFSET {4000} \
    CONFIG.acs_ext_cap_enable {false} \
    CONFIG.all_speeds_all_sides {NO} \
    CONFIG.axisten_freq {250} \
    CONFIG.axisten_if_enable_client_tag {true} \
    CONFIG.axisten_if_enable_msg_route {1EFFF} \
    CONFIG.axisten_if_enable_msg_route_override {true} \
    CONFIG.axisten_if_width {512_bit} \
    CONFIG.cfg_ext_if {false} \
    CONFIG.cfg_mgmt_if {true} \
    CONFIG.copy_pf0 {true} \
    CONFIG.dedicate_perst {false} \
    CONFIG.device_port_type {PCI_Express_Endpoint_device} \
    CONFIG.en_dbg_descramble {false} \
    CONFIG.en_ext_clk {FALSE} \
    CONFIG.en_l23_entry {false} \
    CONFIG.en_parity {false} \
    CONFIG.en_transceiver_status_ports {false} \
    CONFIG.enable_auto_rxeq {False} \
    CONFIG.enable_ccix {FALSE} \
    CONFIG.enable_code {0000} \
    CONFIG.enable_dvsec {FALSE} \
    CONFIG.enable_gen4 {true} \
    CONFIG.enable_gtwizard {true} \
    CONFIG.enable_ibert {false} \
    CONFIG.enable_jtag_dbg {false} \
    CONFIG.enable_more_clk {false} \
    CONFIG.ext_pcie_cfg_space_enabled {false} \
    CONFIG.extended_tag_field {true} \
    CONFIG.insert_cips {false} \
    CONFIG.lane_order {Bottom} \
    CONFIG.legacy_ext_pcie_cfg_space_enabled {false} \
    CONFIG.mode_selection {Advanced} \
    CONFIG.pcie_blk_locn {X0Y2} \
    CONFIG.pcie_link_debug {false} \
    CONFIG.pcie_link_debug_axi4_st {false} \
    CONFIG.pf0_ari_enabled {false} \
    CONFIG.pf0_bar0_64bit {true} \
    CONFIG.pf0_bar0_enabled {true} \
    CONFIG.pf0_bar0_prefetchable {false} \
    CONFIG.pf0_bar0_scale {Kilobytes} \
    CONFIG.pf0_bar0_size {256} \
    CONFIG.pf0_bar2_64bit {true} \
    CONFIG.pf0_bar2_enabled {true} \
    CONFIG.pf0_bar2_prefetchable {false} \
    CONFIG.pf0_bar2_scale {Kilobytes} \
    CONFIG.pf0_bar2_size {128} \
    CONFIG.pf0_bar4_enabled {false} \
    CONFIG.pf0_bar5_enabled {false} \
    CONFIG.pf0_base_class_menu {Memory_controller} \
    CONFIG.pf0_class_code_base {05} \
    CONFIG.pf0_class_code_interface {00} \
    CONFIG.pf0_class_code_sub {80} \
    CONFIG.pf0_expansion_rom_enabled {false} \
    CONFIG.pf0_msi_enabled {false} \
    CONFIG.pf0_msix_enabled {true} \
    CONFIG.pf0_sriov_bar0_64bit {true} \
    CONFIG.pf0_sriov_bar0_enabled {true} \
    CONFIG.pf0_sriov_bar0_prefetchable {true} \
    CONFIG.pf0_sriov_bar0_scale {Kilobytes} \
    CONFIG.pf0_sriov_bar0_size {32} \
    CONFIG.pf0_sriov_bar2_64bit {true} \
    CONFIG.pf0_sriov_bar2_enabled {true} \
    CONFIG.pf0_sriov_bar2_prefetchable {true} \
    CONFIG.pf0_sriov_bar2_scale {Kilobytes} \
    CONFIG.pf0_sriov_bar2_size {4} \
    CONFIG.pf0_sriov_bar4_enabled {false} \
    CONFIG.pf0_sriov_bar5_enabled {false} \
    CONFIG.pf0_sriov_bar5_prefetchable {false} \
    CONFIG.pf0_sub_class_interface_menu {Other_memory_controller} \
    CONFIG.pf1_base_class_menu {Memory_controller} \
    CONFIG.pf1_class_code_base {05} \
    CONFIG.pf1_class_code_interface {00} \
    CONFIG.pf1_class_code_sub {80} \
    CONFIG.pf1_msix_enabled {true} \
    CONFIG.pf1_sriov_bar5_prefetchable {false} \
    CONFIG.pf1_sub_class_interface_menu {Other_memory_controller} \
    CONFIG.pf1_vendor_id {10EE} \
    CONFIG.pf2_base_class_menu {Memory_controller} \
    CONFIG.pf2_class_code_base {05} \
    CONFIG.pf2_class_code_interface {00} \
    CONFIG.pf2_class_code_sub {80} \
    CONFIG.pf2_msix_enabled {true} \
    CONFIG.pf2_sriov_bar5_prefetchable {false} \
    CONFIG.pf2_sub_class_interface_menu {Other_memory_controller} \
    CONFIG.pf2_vendor_id {10EE} \
    CONFIG.pf3_base_class_menu {Memory_controller} \
    CONFIG.pf3_class_code_base {05} \
    CONFIG.pf3_class_code_interface {00} \
    CONFIG.pf3_class_code_sub {80} \
    CONFIG.pf3_msix_enabled {true} \
    CONFIG.pf3_sriov_bar5_prefetchable {false} \
    CONFIG.pf3_sub_class_interface_menu {Other_memory_controller} \
    CONFIG.pf3_vendor_id {10EE} \
    CONFIG.pipe_line_stage {2} \
    CONFIG.pipe_sim {false} \
    CONFIG.replace_uram_with_bram {false} \
    CONFIG.sys_reset_polarity {ACTIVE_LOW} \
    CONFIG.vendor_id {10EE} \
    CONFIG.warm_reboot_sbr_fix {false} \
    CONFIG.xlnx_ref_board {VEK385_1} \
  ] [get_bd_cells pcie]
  create_bd_cell -type ip -vlnv xilinx.com:ip:pcie_phy_versal pcie_phy
  set_property -dict [list \
    CONFIG.PL_LINK_CAP_MAX_LINK_SPEED {16.0_GT/s} \
    CONFIG.PL_LINK_CAP_MAX_LINK_WIDTH {X8} \
    CONFIG.aspm {No_ASPM} \
    CONFIG.async_mode {SRNS} \
    CONFIG.datapath_reorder {false} \
    CONFIG.disable_double_pipe {YES} \
    CONFIG.en_gt_pclk {false} \
    CONFIG.enable_gtwizard {true} \
    CONFIG.ins_loss_profile {Add-in_Card} \
    CONFIG.lane_order {Bottom} \
    CONFIG.lane_reversal {false} \
    CONFIG.phy_async_en {true} \
    CONFIG.phy_coreclk_freq {500_MHz} \
    CONFIG.phy_refclk_freq {100_MHz} \
    CONFIG.phy_userclk_freq {250_MHz} \
    CONFIG.pipeline_stages {2} \
    CONFIG.sim_model {NO} \
    CONFIG.tx_preset {4} \
  ] [get_bd_cells pcie_phy]
  create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf bufg_gt_sysclk
  set_property -dict [list \
    CONFIG.C_BUFG_GT_SYNC {true} \
    CONFIG.C_BUF_TYPE {BUFG_GT} \
  ] [get_bd_cells bufg_gt_sysclk]
  create_bd_cell -type ip -vlnv xilinx.com:ip:gtwiz_versal gtwiz_versal_0
  set_property -dict [list \
    CONFIG.GT_TYPE {GTYP} \
    CONFIG.INTF0_GT_SETTINGS(GT_DIRECTION) {DUPLEX} \
    CONFIG.INTF0_GT_SETTINGS(GT_TYPE) {GTYP} \
    CONFIG.INTF0_GT_SETTINGS(LR0_SETTINGS) {TX_BUFFER_MODE 0 PCIE_ENABLE true TX_PLL_TYPE LCPLL TX_REFCLK_SOURCE R0 TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE RPLL TX_OUTCLK_SOURCE TXPROGDIVCLK TX_DIFF_SWING_EMPH_MODE\
CUSTOM TX_BUFFER_BYPASS_MODE Fast_Sync TX_DATA_ENCODING 8B10B TX_LINE_RATE 2.5 TX_USER_DATA_WIDTH 16 TX_INT_DATA_WIDTH 20 TX_REFCLK_FREQUENCY 100 PCIE_USERCLK_FREQ 250 TXPROGDIV_FREQ_VAL 500.000 PCIE_USERCLK2_FREQ\
250 OOB_ENABLE true RX_BUFFER_MODE 1 RXPROGDIV_FREQ_ENABLE false RX_CC_LEN_SEQ 1 RX_CC_NUM_SEQ 1 RX_CC_K_0_0 true RX_CC_MASK_0_0 false RX_CC_VAL_0_0 00011100 RX_CC_KEEP_IDLE ENABLE RX_COMMA_ALIGN_WORD\
1 RX_COMMA_PRESET K28.5 RX_COMMA_M_ENABLE true RX_COMMA_P_ENABLE true RX_COMMA_MASK 1111111111 RX_COMMA_M_VAL 0101111100 RX_COMMA_P_VAL 1010000011 RX_COMMA_DOUBLE_ENABLE false RX_JTOL_FC 1 RX_PLL_TYPE\
LCPLL RX_SLIDE_MODE OFF RX_REFCLK_SOURCE R0 RX_OUTCLK_SOURCE RXOUTCLKPMA RX_EQ_MODE LPM RX_SSC_PPM 0 INS_LOSS_NYQ 20 RX_DATA_DECODING 8B10B RX_LINE_RATE 2.5 RX_PPM_OFFSET 0 RX_USER_DATA_WIDTH 16 RX_INT_DATA_WIDTH\
20 RX_REFCLK_FREQUENCY 100} \
    CONFIG.INTF0_GT_SETTINGS(LR1_SETTINGS) {TX_BUFFER_MODE 0 PCIE_ENABLE true TX_PLL_TYPE LCPLL TX_REFCLK_SOURCE R0 TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE RPLL TX_OUTCLK_SOURCE TXPROGDIVCLK TX_DIFF_SWING_EMPH_MODE\
CUSTOM TX_BUFFER_BYPASS_MODE Fast_Sync TX_DATA_ENCODING 8B10B TX_LINE_RATE 5.0 TX_USER_DATA_WIDTH 16 TX_INT_DATA_WIDTH 20 TX_REFCLK_FREQUENCY 100 PCIE_USERCLK_FREQ 250 TXPROGDIV_FREQ_VAL 500.000 PCIE_USERCLK2_FREQ\
250 OOB_ENABLE true RX_BUFFER_MODE 1 RXPROGDIV_FREQ_ENABLE false RX_CC_LEN_SEQ 1 RX_CC_NUM_SEQ 1 RX_CC_K_0_0 true RX_CC_MASK_0_0 false RX_CC_VAL_0_0 00011100 RX_CC_KEEP_IDLE ENABLE RX_COMMA_ALIGN_WORD\
1 RX_COMMA_PRESET K28.5 RX_COMMA_M_ENABLE true RX_COMMA_P_ENABLE true RX_COMMA_MASK 1111111111 RX_COMMA_M_VAL 0101111100 RX_COMMA_P_VAL 1010000011 RX_COMMA_DOUBLE_ENABLE false RX_JTOL_FC 1 RX_PLL_TYPE\
LCPLL RX_SLIDE_MODE OFF RX_REFCLK_SOURCE R0 RX_OUTCLK_SOURCE RXOUTCLKPMA RX_EQ_MODE LPM RX_SSC_PPM 0 INS_LOSS_NYQ 20 RX_DATA_DECODING 8B10B RX_LINE_RATE 5.0 RX_PPM_OFFSET 0 RX_USER_DATA_WIDTH 16 RX_INT_DATA_WIDTH\
20 RX_REFCLK_FREQUENCY 100} \
    CONFIG.INTF0_GT_SETTINGS(LR2_SETTINGS) {TX_BUFFER_MODE 0 PCIE_ENABLE true TX_PLL_TYPE LCPLL TX_REFCLK_SOURCE R0 TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE RPLL TX_OUTCLK_SOURCE TXPROGDIVCLK TX_DIFF_SWING_EMPH_MODE\
CUSTOM TX_BUFFER_BYPASS_MODE Fast_Sync TX_DATA_ENCODING 128B130B TX_LINE_RATE 8.0 TX_USER_DATA_WIDTH 32 TX_INT_DATA_WIDTH 32 TX_REFCLK_FREQUENCY 100 PCIE_USERCLK_FREQ 250 TXPROGDIV_FREQ_VAL 500.000 PCIE_USERCLK2_FREQ\
500 OOB_ENABLE true RX_BUFFER_MODE 1 RXPROGDIV_FREQ_ENABLE false RX_CC_LEN_SEQ 1 RX_CC_NUM_SEQ 1 RX_CC_K_0_0 true RX_CC_MASK_0_0 false RX_CC_VAL_0_0 00011100 RX_CC_KEEP_IDLE ENABLE RX_COMMA_ALIGN_WORD\
1 RX_COMMA_PRESET K28.5 RX_COMMA_M_ENABLE true RX_COMMA_P_ENABLE true RX_COMMA_MASK 1111111111 RX_COMMA_M_VAL 0101111100 RX_COMMA_P_VAL 1010000011 RX_COMMA_DOUBLE_ENABLE false RX_JTOL_FC 1 RX_PLL_TYPE\
LCPLL RX_SLIDE_MODE OFF RX_REFCLK_SOURCE R0 RX_OUTCLK_SOURCE RXOUTCLKPMA RX_EQ_MODE DFE RX_SSC_PPM 0 INS_LOSS_NYQ 20 RX_DATA_DECODING 128B130B RX_LINE_RATE 8.0 RX_PPM_OFFSET 0 RX_USER_DATA_WIDTH 32 RX_INT_DATA_WIDTH\
32 RX_REFCLK_FREQUENCY 100} \
    CONFIG.INTF0_GT_SETTINGS(LR3_SETTINGS) {TX_BUFFER_MODE 0 PCIE_ENABLE true TX_PLL_TYPE LCPLL TX_REFCLK_SOURCE R0 TXPROGDIV_FREQ_ENABLE true TXPROGDIV_FREQ_SOURCE RPLL TX_OUTCLK_SOURCE TXPROGDIVCLK TX_DIFF_SWING_EMPH_MODE\
CUSTOM TX_BUFFER_BYPASS_MODE Fast_Sync TX_DATA_ENCODING 128B130B TX_LINE_RATE 16.0 TX_USER_DATA_WIDTH 32 TX_INT_DATA_WIDTH 32 TX_REFCLK_FREQUENCY 100 PCIE_USERCLK_FREQ 250 TXPROGDIV_FREQ_VAL 500.000 PCIE_USERCLK2_FREQ\
500 OOB_ENABLE true RX_BUFFER_MODE 1 RXPROGDIV_FREQ_ENABLE false RX_CC_LEN_SEQ 1 RX_CC_NUM_SEQ 1 RX_CC_K_0_0 true RX_CC_MASK_0_0 false RX_CC_VAL_0_0 00011100 RX_CC_KEEP_IDLE ENABLE RX_COMMA_ALIGN_WORD\
1 RX_COMMA_PRESET K28.5 RX_COMMA_M_ENABLE true RX_COMMA_P_ENABLE true RX_COMMA_MASK 1111111111 RX_COMMA_M_VAL 0101111100 RX_COMMA_P_VAL 1010000011 RX_COMMA_DOUBLE_ENABLE false RX_JTOL_FC 1 RX_PLL_TYPE\
LCPLL RX_SLIDE_MODE OFF RX_REFCLK_SOURCE R0 RX_OUTCLK_SOURCE RXOUTCLKPMA RX_EQ_MODE DFE RX_SSC_PPM 0 INS_LOSS_NYQ 20 RX_DATA_DECODING 128B130B RX_LINE_RATE 16.0 RX_PPM_OFFSET 0 RX_USER_DATA_WIDTH 32 RX_INT_DATA_WIDTH\
32 RX_REFCLK_FREQUENCY 100} \
    CONFIG.INTF0_NO_OF_LANES {8} \
    CONFIG.INTF0_PARENTID {edf_base_pcie_phy_1} \
    CONFIG.INTF0_PCIE_ENABLE {true} \
    CONFIG.INTF_PARENT_PIN_LIST {QUAD0_RX0 /pl_pcie/qdma_0_support/pcie_phy/GT_RX0 QUAD0_RX1 /pl_pcie/qdma_0_support/pcie_phy/GT_RX1 QUAD0_RX2 /pl_pcie/qdma_0_support/pcie_phy/GT_RX2 QUAD0_RX3 /pl_pcie/qdma_0_support/pcie_phy/GT_RX3\
QUAD1_RX0 /pl_pcie/qdma_0_support/pcie_phy/GT_RX4 QUAD1_RX1 /pl_pcie/qdma_0_support/pcie_phy/GT_RX5 QUAD1_RX2 /pl_pcie/qdma_0_support/pcie_phy/GT_RX6 QUAD1_RX3 /pl_pcie/qdma_0_support/pcie_phy/GT_RX7 QUAD0_TX0\
/pl_pcie/qdma_0_support/pcie_phy/GT_TX0 QUAD0_TX1 /pl_pcie/qdma_0_support/pcie_phy/GT_TX1 QUAD0_TX2 /pl_pcie/qdma_0_support/pcie_phy/GT_TX2 QUAD0_TX3 /pl_pcie/qdma_0_support/pcie_phy/GT_TX3 QUAD1_TX0 /pl_pcie/qdma_0_support/pcie_phy/GT_TX4\
QUAD1_TX1 /pl_pcie/qdma_0_support/pcie_phy/GT_TX5 QUAD1_TX2 /pl_pcie/qdma_0_support/pcie_phy/GT_TX6 QUAD1_TX3 /pl_pcie/qdma_0_support/pcie_phy/GT_TX7} \
    CONFIG.NO_OF_QUADS {2} \
    CONFIG.QUAD0_PROT0_LANES {4} \
    CONFIG.QUAD0_REFCLK_STRING {HSCLK0_LCPLLGTREFCLK0 refclk_PROT0_R0_100_MHz_unique1 HSCLK0_RPLLGTREFCLK0 refclk_PROT0_R0_100_MHz_unique1 HSCLK1_LCPLLGTREFCLK0 refclk_PROT0_R0_100_MHz_unique1 HSCLK1_RPLLGTREFCLK0\
refclk_PROT0_R0_100_MHz_unique1} \
    CONFIG.QUAD1_PROT0_LANES {4} \
    CONFIG.QUAD1_REFCLK_STRING {HSCLK0_LCPLLGTREFCLK0 refclk_PROT0_R0_100_MHz_unique1 HSCLK0_RPLLGTREFCLK0 refclk_PROT0_R0_100_MHz_unique1 HSCLK1_LCPLLGTREFCLK0 refclk_PROT0_R0_100_MHz_unique1 HSCLK1_RPLLGTREFCLK0\
refclk_PROT0_R0_100_MHz_unique1} \
    CONFIG.INTF0_GT_SETTINGS.VALUE_MODE {auto} \
    CONFIG.INTF0_PARENTID.VALUE_MODE {auto} \
    CONFIG.INTF_PARENT_PIN_LIST.VALUE_MODE {auto} \
  ] [get_bd_cells gtwiz_versal_0]
  create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf refclk_ibuf
  set_property -dict [list \
    CONFIG.C_BUF_TYPE {IBUFDSGTE} \
  ] [get_bd_cells refclk_ibuf]
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins pcie_phy/pcie_mgt] [get_bd_intf_pins pcie_mgt]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins refclk_ibuf/CLK_IN_D] [get_bd_intf_pins pcie_refclk]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins pcie/m_axis_cq] [get_bd_intf_pins m_axis_cq]
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins pcie/m_axis_rc] [get_bd_intf_pins m_axis_rc]
  connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins pcie/pcie_cfg_fc] [get_bd_intf_pins pcie_cfg_fc]
  connect_bd_intf_net -intf_net Conn6 [get_bd_intf_pins pcie/pcie_cfg_interrupt] [get_bd_intf_pins pcie_cfg_interrupt]
  connect_bd_intf_net -intf_net Conn7 [get_bd_intf_pins pcie/pcie_cfg_mesg_rcvd] [get_bd_intf_pins pcie_cfg_mesg_rcvd]
  connect_bd_intf_net -intf_net Conn8 [get_bd_intf_pins pcie/pcie_cfg_mesg_tx] [get_bd_intf_pins pcie_cfg_mesg_tx]
  connect_bd_intf_net -intf_net Conn9 [get_bd_intf_pins pcie/s_axis_cc] [get_bd_intf_pins s_axis_cc]
  connect_bd_intf_net -intf_net Conn10 [get_bd_intf_pins pcie/s_axis_rq] [get_bd_intf_pins s_axis_rq]
  connect_bd_intf_net -intf_net Conn11 [get_bd_intf_pins pcie/pcie_cfg_control] [get_bd_intf_pins pcie_cfg_control]
  connect_bd_intf_net -intf_net Conn12 [get_bd_intf_pins pcie/pcie_cfg_external_msix_without_msi] [get_bd_intf_pins pcie_cfg_external_msix_without_msi]
  connect_bd_intf_net -intf_net Conn13 [get_bd_intf_pins pcie/pcie_cfg_mgmt] [get_bd_intf_pins pcie_cfg_mgmt]
  connect_bd_intf_net -intf_net Conn14 [get_bd_intf_pins pcie/pcie_cfg_status] [get_bd_intf_pins pcie_cfg_status]
  connect_bd_intf_net -intf_net Conn15 [get_bd_intf_pins pcie/pcie_transmit_fc] [get_bd_intf_pins pcie_transmit_fc]
  connect_bd_intf_net -intf_net gtwiz_versal_0_Quad0_GT0_BUFGT [get_bd_intf_pins pcie_phy/GT_BUFGT] [get_bd_intf_pins gtwiz_versal_0/Quad0_GT0_BUFGT]
  connect_bd_intf_net -intf_net gtwiz_versal_0_Quad0_GT_Serial [get_bd_intf_pins pcie_phy/GT0_Serial] [get_bd_intf_pins gtwiz_versal_0/Quad0_GT_Serial]
  connect_bd_intf_net -intf_net gtwiz_versal_0_Quad1_GT_Serial [get_bd_intf_pins pcie_phy/GT1_Serial] [get_bd_intf_pins gtwiz_versal_0/Quad1_GT_Serial]
  connect_bd_intf_net -intf_net pcie_phy_GT_RX0 [get_bd_intf_pins pcie_phy/GT_RX0] [get_bd_intf_pins gtwiz_versal_0/INTF0_RX0_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_RX1 [get_bd_intf_pins pcie_phy/GT_RX1] [get_bd_intf_pins gtwiz_versal_0/INTF0_RX1_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_RX2 [get_bd_intf_pins pcie_phy/GT_RX2] [get_bd_intf_pins gtwiz_versal_0/INTF0_RX2_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_RX3 [get_bd_intf_pins pcie_phy/GT_RX3] [get_bd_intf_pins gtwiz_versal_0/INTF0_RX3_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_RX4 [get_bd_intf_pins pcie_phy/GT_RX4] [get_bd_intf_pins gtwiz_versal_0/INTF0_RX4_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_RX5 [get_bd_intf_pins pcie_phy/GT_RX5] [get_bd_intf_pins gtwiz_versal_0/INTF0_RX5_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_RX6 [get_bd_intf_pins pcie_phy/GT_RX6] [get_bd_intf_pins gtwiz_versal_0/INTF0_RX6_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_RX7 [get_bd_intf_pins pcie_phy/GT_RX7] [get_bd_intf_pins gtwiz_versal_0/INTF0_RX7_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_TX0 [get_bd_intf_pins pcie_phy/GT_TX0] [get_bd_intf_pins gtwiz_versal_0/INTF0_TX0_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_TX1 [get_bd_intf_pins pcie_phy/GT_TX1] [get_bd_intf_pins gtwiz_versal_0/INTF0_TX1_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_TX2 [get_bd_intf_pins pcie_phy/GT_TX2] [get_bd_intf_pins gtwiz_versal_0/INTF0_TX2_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_TX3 [get_bd_intf_pins pcie_phy/GT_TX3] [get_bd_intf_pins gtwiz_versal_0/INTF0_TX3_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_TX4 [get_bd_intf_pins pcie_phy/GT_TX4] [get_bd_intf_pins gtwiz_versal_0/INTF0_TX4_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_TX5 [get_bd_intf_pins pcie_phy/GT_TX5] [get_bd_intf_pins gtwiz_versal_0/INTF0_TX5_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_TX6 [get_bd_intf_pins pcie_phy/GT_TX6] [get_bd_intf_pins gtwiz_versal_0/INTF0_TX6_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_GT_TX7 [get_bd_intf_pins pcie_phy/GT_TX7] [get_bd_intf_pins gtwiz_versal_0/INTF0_TX7_GT_IP_Interface]
  connect_bd_intf_net -intf_net pcie_phy_gt_rxmargin_q0 [get_bd_intf_pins pcie_phy/gt_rxmargin_q0] [get_bd_intf_pins gtwiz_versal_0/QUAD0_GT_RXMARGIN_INTF]
  connect_bd_intf_net -intf_net pcie_phy_gt_rxmargin_q1 [get_bd_intf_pins pcie_phy/gt_rxmargin_q1] [get_bd_intf_pins gtwiz_versal_0/QUAD1_GT_RXMARGIN_INTF]
  connect_bd_intf_net -intf_net pcie_phy_mac_rx [get_bd_intf_pins pcie_phy/phy_mac_rx] [get_bd_intf_pins pcie/phy_mac_rx]
  connect_bd_intf_net -intf_net pcie_phy_mac_tx [get_bd_intf_pins pcie_phy/phy_mac_tx] [get_bd_intf_pins pcie/phy_mac_tx]
  connect_bd_intf_net -intf_net pcie_phy_phy_mac_command [get_bd_intf_pins pcie_phy/phy_mac_command] [get_bd_intf_pins pcie/phy_mac_command]
  connect_bd_intf_net -intf_net pcie_phy_phy_mac_rx_margining [get_bd_intf_pins pcie_phy/phy_mac_rx_margining] [get_bd_intf_pins pcie/phy_mac_rx_margining]
  connect_bd_intf_net -intf_net pcie_phy_phy_mac_status [get_bd_intf_pins pcie_phy/phy_mac_status] [get_bd_intf_pins pcie/phy_mac_status]
  connect_bd_intf_net -intf_net pcie_phy_phy_mac_tx_drive [get_bd_intf_pins pcie_phy/phy_mac_tx_drive] [get_bd_intf_pins pcie/phy_mac_tx_drive]
  connect_bd_intf_net -intf_net pcie_phy_phy_mac_tx_eq [get_bd_intf_pins pcie_phy/phy_mac_tx_eq] [get_bd_intf_pins pcie/phy_mac_tx_eq]
  connect_bd_net -net BUFG_GT_CE_1 [get_bd_pins BUFG_GT_CE] [get_bd_pins bufg_gt_sysclk/BUFG_GT_CE]
  connect_bd_net -net bufg_gt_sysclk_BUFG_GT_O [get_bd_pins bufg_gt_sysclk/BUFG_GT_O] [get_bd_pins pcie_phy/phy_refclk] [get_bd_pins pcie/sys_clk]
  connect_bd_net -net gtwiz_freerun_clk_1 [get_bd_pins gtwiz_freerun_clk] [get_bd_pins gtwiz_versal_0/gtwiz_freerun_clk]
  connect_bd_net -net gtwiz_versal_0_QUAD0_RX0_outclk [get_bd_pins gtwiz_versal_0/QUAD0_RX0_outclk] [get_bd_pins pcie_phy/gt_rxoutclk]
  connect_bd_net -net gtwiz_versal_0_QUAD0_TX0_outclk [get_bd_pins gtwiz_versal_0/QUAD0_TX0_outclk] [get_bd_pins pcie_phy/gt_txoutclk]
  connect_bd_net -net gtwiz_versal_0_QUAD0_ch0_phyready [get_bd_pins gtwiz_versal_0/QUAD0_ch0_phyready] [get_bd_pins pcie_phy/ch0_phyready]
  connect_bd_net -net gtwiz_versal_0_QUAD0_ch0_phystatus [get_bd_pins gtwiz_versal_0/QUAD0_ch0_phystatus] [get_bd_pins pcie_phy/ch0_phystatus]
  connect_bd_net -net gtwiz_versal_0_QUAD0_ch1_phyready [get_bd_pins gtwiz_versal_0/QUAD0_ch1_phyready] [get_bd_pins pcie_phy/ch1_phyready]
  connect_bd_net -net gtwiz_versal_0_QUAD0_ch1_phystatus [get_bd_pins gtwiz_versal_0/QUAD0_ch1_phystatus] [get_bd_pins pcie_phy/ch1_phystatus]
  connect_bd_net -net gtwiz_versal_0_QUAD0_ch2_phyready [get_bd_pins gtwiz_versal_0/QUAD0_ch2_phyready] [get_bd_pins pcie_phy/ch2_phyready]
  connect_bd_net -net gtwiz_versal_0_QUAD0_ch2_phystatus [get_bd_pins gtwiz_versal_0/QUAD0_ch2_phystatus] [get_bd_pins pcie_phy/ch2_phystatus]
  connect_bd_net -net gtwiz_versal_0_QUAD0_ch3_phyready [get_bd_pins gtwiz_versal_0/QUAD0_ch3_phyready] [get_bd_pins pcie_phy/ch3_phyready]
  connect_bd_net -net gtwiz_versal_0_QUAD0_ch3_phystatus [get_bd_pins gtwiz_versal_0/QUAD0_ch3_phystatus] [get_bd_pins pcie_phy/ch3_phystatus]
  connect_bd_net -net gtwiz_versal_0_QUAD1_ch0_phyready [get_bd_pins gtwiz_versal_0/QUAD1_ch0_phyready] [get_bd_pins pcie_phy/ch4_phyready]
  connect_bd_net -net gtwiz_versal_0_QUAD1_ch0_phystatus [get_bd_pins gtwiz_versal_0/QUAD1_ch0_phystatus] [get_bd_pins pcie_phy/ch4_phystatus]
  connect_bd_net -net gtwiz_versal_0_QUAD1_ch1_phyready [get_bd_pins gtwiz_versal_0/QUAD1_ch1_phyready] [get_bd_pins pcie_phy/ch5_phyready]
  connect_bd_net -net gtwiz_versal_0_QUAD1_ch1_phystatus [get_bd_pins gtwiz_versal_0/QUAD1_ch1_phystatus] [get_bd_pins pcie_phy/ch5_phystatus]
  connect_bd_net -net gtwiz_versal_0_QUAD1_ch2_phyready [get_bd_pins gtwiz_versal_0/QUAD1_ch2_phyready] [get_bd_pins pcie_phy/ch6_phyready]
  connect_bd_net -net gtwiz_versal_0_QUAD1_ch2_phystatus [get_bd_pins gtwiz_versal_0/QUAD1_ch2_phystatus] [get_bd_pins pcie_phy/ch6_phystatus]
  connect_bd_net -net gtwiz_versal_0_QUAD1_ch3_phyready [get_bd_pins gtwiz_versal_0/QUAD1_ch3_phyready] [get_bd_pins pcie_phy/ch7_phyready]
  connect_bd_net -net gtwiz_versal_0_QUAD1_ch3_phystatus [get_bd_pins gtwiz_versal_0/QUAD1_ch3_phystatus] [get_bd_pins pcie_phy/ch7_phystatus]
  connect_bd_net -net pcie_pcie_ltssm_state [get_bd_pins pcie/pcie_ltssm_state] [get_bd_pins pcie_phy/pcie_ltssm_state]
  connect_bd_net -net pcie_phy_gt_pcieltssm [get_bd_pins pcie_phy/gt_pcieltssm] [get_bd_pins gtwiz_versal_0/QUAD0_pcieltssm] [get_bd_pins gtwiz_versal_0/QUAD1_pcieltssm]
  connect_bd_net -net pcie_phy_gtrefclk [get_bd_pins pcie_phy/gtrefclk] [get_bd_pins gtwiz_versal_0/QUAD0_GTREFCLK0] [get_bd_pins gtwiz_versal_0/QUAD1_GTREFCLK0]
  connect_bd_net -net pcie_phy_pcierstb [get_bd_pins pcie_phy/pcierstb] [get_bd_pins gtwiz_versal_0/QUAD0_ch0_pcierstb] [get_bd_pins gtwiz_versal_0/QUAD0_ch1_pcierstb] [get_bd_pins gtwiz_versal_0/QUAD0_ch2_pcierstb] [get_bd_pins gtwiz_versal_0/QUAD0_ch3_pcierstb] [get_bd_pins gtwiz_versal_0/QUAD1_ch0_pcierstb] [get_bd_pins gtwiz_versal_0/QUAD1_ch1_pcierstb] [get_bd_pins gtwiz_versal_0/QUAD1_ch2_pcierstb] [get_bd_pins gtwiz_versal_0/QUAD1_ch3_pcierstb]
  connect_bd_net -net pcie_phy_phy_coreclk [get_bd_pins pcie_phy/phy_coreclk] [get_bd_pins pcie/phy_coreclk]
  connect_bd_net -net pcie_phy_phy_mcapclk [get_bd_pins pcie_phy/phy_mcapclk] [get_bd_pins pcie/phy_mcapclk]
  connect_bd_net -net pcie_phy_phy_pclk [get_bd_pins pcie_phy/phy_pclk] [get_bd_pins pcie/phy_pclk] [get_bd_pins gtwiz_versal_0/QUAD0_TX0_usrclk] [get_bd_pins gtwiz_versal_0/QUAD0_RX0_usrclk] [get_bd_pins gtwiz_versal_0/QUAD0_TX1_usrclk] [get_bd_pins gtwiz_versal_0/QUAD0_RX1_usrclk] [get_bd_pins gtwiz_versal_0/QUAD0_TX2_usrclk] [get_bd_pins gtwiz_versal_0/QUAD0_RX2_usrclk] [get_bd_pins gtwiz_versal_0/QUAD0_TX3_usrclk] [get_bd_pins gtwiz_versal_0/QUAD0_RX3_usrclk] [get_bd_pins gtwiz_versal_0/QUAD1_TX0_usrclk] [get_bd_pins gtwiz_versal_0/QUAD1_RX0_usrclk] [get_bd_pins gtwiz_versal_0/QUAD1_TX1_usrclk] [get_bd_pins gtwiz_versal_0/QUAD1_RX1_usrclk] [get_bd_pins gtwiz_versal_0/QUAD1_TX2_usrclk] [get_bd_pins gtwiz_versal_0/QUAD1_RX2_usrclk] [get_bd_pins gtwiz_versal_0/QUAD1_TX3_usrclk] [get_bd_pins gtwiz_versal_0/QUAD1_RX3_usrclk]
  connect_bd_net -net pcie_phy_phy_userclk [get_bd_pins pcie_phy/phy_userclk] [get_bd_pins pcie/phy_userclk]
  connect_bd_net -net pcie_phy_phy_userclk2 [get_bd_pins pcie_phy/phy_userclk2] [get_bd_pins pcie/phy_userclk2]
  connect_bd_net -net pcie_phy_rdy_out [get_bd_pins pcie/phy_rdy_out] [get_bd_pins phy_rdy_out]
  connect_bd_net -net pcie_user_clk [get_bd_pins pcie/user_clk] [get_bd_pins user_clk]
  connect_bd_net -net pcie_user_lnk_up [get_bd_pins pcie/user_lnk_up] [get_bd_pins user_lnk_up]
  connect_bd_net -net pcie_user_reset [get_bd_pins pcie/user_reset] [get_bd_pins user_reset]
  connect_bd_net -net refclk_ibuf_IBUF_DS_ODIV2 [get_bd_pins refclk_ibuf/IBUF_DS_ODIV2] [get_bd_pins bufg_gt_sysclk/BUFG_GT_I]
  connect_bd_net -net refclk_ibuf_IBUF_OUT [get_bd_pins refclk_ibuf/IBUF_OUT] [get_bd_pins pcie_phy/phy_gtrefclk] [get_bd_pins pcie/sys_clk_gt]
  connect_bd_net -net sys_reset_1 [get_bd_pins sys_reset] [get_bd_pins pcie_phy/phy_rst_n] [get_bd_pins pcie/sys_reset]

  current_bd_instance $oldCurInst
}

# Hierarchical cell: pl_pcie
proc create_hier_cell_pl_pcie { parentCell nameHier } {
  variable script_folder
  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_pl_pcie() - Empty argument(s)!"}
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

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M00_INI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M01_INI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M02_INI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 pcie_mgt
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_refclk
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst sys_reset
  create_bd_pin -dir O -type intr irq
  create_bd_cell -type ip -vlnv xilinx.com:ip:qdma qdma_0
  set_property -dict [list \
    CONFIG.dma_intf_sel_qdma {AXI_MM} \
    CONFIG.en_bridge_slv {false} \
    CONFIG.pcie_blk_locn {X0Y2} \
    CONFIG.pf0_bar2_type_qdma {AXI_Bridge_Master} \
    CONFIG.pf0_pciebar2axibar_2 {0x80250000000} \
    CONFIG.pl_link_cap_max_link_speed {16.0_GT/s} \
  ] [get_bd_cells qdma_0]
  create_bd_cell -type ip -vlnv user.org:user:pcie_reg_space pcie_reg_space_0
  create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc2 axi_noc2_0
  set_property -dict [list \
    CONFIG.MI_NAMES {} \
    CONFIG.MI_SIDEBAND_PINS {} \
    CONFIG.NMI_NAMES {} \
    CONFIG.NUM_MI {1} \
    CONFIG.NUM_NMI {3} \
  ] [get_bd_cells axi_noc2_0]
  set_property -dict [list \
    CONFIG.DATA_WIDTH {32} \
    CONFIG.APERTURES {{0x802_0000_0000 4G}} \
    CONFIG.CATEGORY {pl} \
  ] [get_bd_intf_pins axi_noc2_0/M00_AXI]
  set_property -dict [list \
    CONFIG.DATA_WIDTH {512} \
    CONFIG.CONNECTIONS {M02_INI {read_bw {500} write_bw {500}} M01_INI {read_bw {500} write_bw {500}} M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} M00_INI {read_bw {500} write_bw {500}}} \
    CONFIG.DEST_IDS {M00_AXI:0x0} \
    CONFIG.NOC_PARAMS {} \
    CONFIG.CATEGORY {pl} \
  ] [get_bd_intf_pins axi_noc2_0/S00_AXI]
  set_property -dict [list \
    CONFIG.ASSOCIATED_BUSIF {M00_AXI:S00_AXI} \
  ] [get_bd_pins axi_noc2_0/aclk0]
  create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_1
  set_property -dict [list \
    CONFIG.NUM_SI {2} \
  ] [get_bd_cells smartconnect_1]
  create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant ilconstant_0
  create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant ilconstant_1
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {4} \
  ] [get_bd_cells ilconstant_1]
  create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat ilconcat_0
  create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat ilconcat_1
  set_property -dict [list \
    CONFIG.NUM_PORTS {4} \
  ] [get_bd_cells ilconcat_1]
  create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_2
  set_property -dict [list \
    CONFIG.NUM_MI {2} \
    CONFIG.NUM_SI {1} \
  ] [get_bd_cells smartconnect_2]
  create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc axi_intc_0
  set_property -dict [list \
    CONFIG.C_IRQ_CONNECTION {1} \
  ] [get_bd_cells axi_intc_0]
  create_hier_cell_qdma_0_support $hier_obj qdma_0_support
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins axi_noc2_0/M00_INI] [get_bd_intf_pins M00_INI]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins axi_noc2_0/M01_INI] [get_bd_intf_pins M01_INI]
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins axi_noc2_0/M02_INI] [get_bd_intf_pins M02_INI]
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins S00_AXI] [get_bd_intf_pins smartconnect_2/S00_AXI]
  connect_bd_intf_net -intf_net axi_noc2_0_M00_AXI [get_bd_intf_pins axi_noc2_0/M00_AXI] [get_bd_intf_pins smartconnect_1/S00_AXI]
  connect_bd_intf_net -intf_net pcie_refclk_1 [get_bd_intf_pins pcie_refclk] [get_bd_intf_pins qdma_0_support/pcie_refclk]
  connect_bd_intf_net -intf_net qdma_0_M_AXI [get_bd_intf_pins qdma_0/M_AXI] [get_bd_intf_pins axi_noc2_0/S00_AXI]
  connect_bd_intf_net -intf_net qdma_0_M_AXI_BRIDGE [get_bd_intf_pins qdma_0/M_AXI_BRIDGE] [get_bd_intf_pins smartconnect_1/S01_AXI]
  connect_bd_intf_net -intf_net qdma_0_pcie_cfg_control_if [get_bd_intf_pins qdma_0/pcie_cfg_control_if] [get_bd_intf_pins qdma_0_support/pcie_cfg_control]
  connect_bd_intf_net -intf_net qdma_0_pcie_cfg_external_msix_without_msi_if [get_bd_intf_pins qdma_0/pcie_cfg_external_msix_without_msi_if] [get_bd_intf_pins qdma_0_support/pcie_cfg_external_msix_without_msi]
  connect_bd_intf_net -intf_net qdma_0_pcie_cfg_interrupt [get_bd_intf_pins qdma_0/pcie_cfg_interrupt] [get_bd_intf_pins qdma_0_support/pcie_cfg_interrupt]
  connect_bd_intf_net -intf_net qdma_0_pcie_cfg_mgmt_if [get_bd_intf_pins qdma_0/pcie_cfg_mgmt_if] [get_bd_intf_pins qdma_0_support/pcie_cfg_mgmt]
  connect_bd_intf_net -intf_net qdma_0_s_axis_cc [get_bd_intf_pins qdma_0/s_axis_cc] [get_bd_intf_pins qdma_0_support/s_axis_cc]
  connect_bd_intf_net -intf_net qdma_0_s_axis_rq [get_bd_intf_pins qdma_0/s_axis_rq] [get_bd_intf_pins qdma_0_support/s_axis_rq]
  connect_bd_intf_net -intf_net qdma_0_support_m_axis_cq [get_bd_intf_pins qdma_0/m_axis_cq] [get_bd_intf_pins qdma_0_support/m_axis_cq]
  connect_bd_intf_net -intf_net qdma_0_support_m_axis_rc [get_bd_intf_pins qdma_0/m_axis_rc] [get_bd_intf_pins qdma_0_support/m_axis_rc]
  connect_bd_intf_net -intf_net qdma_0_support_pcie_cfg_fc [get_bd_intf_pins qdma_0/pcie_cfg_fc] [get_bd_intf_pins qdma_0_support/pcie_cfg_fc]
  connect_bd_intf_net -intf_net qdma_0_support_pcie_cfg_mesg_rcvd [get_bd_intf_pins qdma_0/pcie_cfg_mesg_rcvd] [get_bd_intf_pins qdma_0_support/pcie_cfg_mesg_rcvd]
  connect_bd_intf_net -intf_net qdma_0_support_pcie_cfg_mesg_tx [get_bd_intf_pins qdma_0/pcie_cfg_mesg_tx] [get_bd_intf_pins qdma_0_support/pcie_cfg_mesg_tx]
  connect_bd_intf_net -intf_net qdma_0_support_pcie_cfg_status [get_bd_intf_pins qdma_0/pcie_cfg_status_if] [get_bd_intf_pins qdma_0_support/pcie_cfg_status]
  connect_bd_intf_net -intf_net qdma_0_support_pcie_mgt [get_bd_intf_pins pcie_mgt] [get_bd_intf_pins qdma_0_support/pcie_mgt]
  connect_bd_intf_net -intf_net qdma_0_support_pcie_transmit_fc [get_bd_intf_pins qdma_0/pcie_transmit_fc_if] [get_bd_intf_pins qdma_0_support/pcie_transmit_fc]
  connect_bd_intf_net -intf_net smartconnect_1_M00_AXI [get_bd_intf_pins smartconnect_1/M00_AXI] [get_bd_intf_pins pcie_reg_space_0/S00_AXI]
  connect_bd_intf_net -intf_net smartconnect_2_M00_AXI [get_bd_intf_pins smartconnect_2/M00_AXI] [get_bd_intf_pins pcie_reg_space_0/S01_AXI]
  connect_bd_intf_net -intf_net smartconnect_2_M01_AXI [get_bd_intf_pins smartconnect_2/M01_AXI] [get_bd_intf_pins axi_intc_0/s_axi]
  connect_bd_net -net Net [get_bd_pins qdma_0/axi_aresetn] [get_bd_pins pcie_reg_space_0/s00_axi_aresetn] [get_bd_pins smartconnect_1/aresetn]
  connect_bd_net -net Net1 [get_bd_pins aclk] [get_bd_pins pcie_reg_space_0/s01_axi_aclk] [get_bd_pins smartconnect_2/aclk] [get_bd_pins axi_intc_0/s_axi_aclk]
  connect_bd_net -net Net2 [get_bd_pins aresetn] [get_bd_pins pcie_reg_space_0/s01_axi_aresetn] [get_bd_pins smartconnect_2/aresetn] [get_bd_pins axi_intc_0/s_axi_aresetn]
  connect_bd_net -net axi_intc_0_irq [get_bd_pins axi_intc_0/irq] [get_bd_pins irq]
  connect_bd_net -net ilconcat_0_dout [get_bd_pins ilconcat_0/dout] [get_bd_pins qdma_0/usr_irq_in_fnc]
  connect_bd_net -net ilconcat_1_dout [get_bd_pins ilconcat_1/dout] [get_bd_pins axi_intc_0/intr]
  connect_bd_net -net ilconstant_0_dout [get_bd_pins ilconstant_0/dout] [get_bd_pins qdma_0/tm_dsc_sts_rdy] [get_bd_pins qdma_0/qsts_out_rdy] [get_bd_pins qdma_0_support/gtwiz_freerun_clk] [get_bd_pins qdma_0_support/BUFG_GT_CE]
  connect_bd_net -net ilconstant_1_dout [get_bd_pins ilconstant_1/dout] [get_bd_pins ilconcat_0/In1]
  connect_bd_net -net pcie_reg_space_0_IRQ1_to_Host [get_bd_pins pcie_reg_space_0/IRQ1_to_Host] [get_bd_pins ilconcat_0/In0]
  connect_bd_net -net pcie_reg_space_0_IRQ1_to_PS [get_bd_pins pcie_reg_space_0/IRQ1_to_PS] [get_bd_pins ilconcat_1/In0]
  connect_bd_net -net pcie_reg_space_0_IRQ2_to_PS [get_bd_pins pcie_reg_space_0/IRQ2_to_PS] [get_bd_pins ilconcat_1/In1]
  connect_bd_net -net pcie_reg_space_0_IRQ3_to_PS [get_bd_pins pcie_reg_space_0/IRQ3_to_PS] [get_bd_pins ilconcat_1/In2]
  connect_bd_net -net pcie_reg_space_0_IRQ4_to_PS [get_bd_pins pcie_reg_space_0/IRQ4_to_PS] [get_bd_pins ilconcat_1/In3]
  connect_bd_net -net qdma_0_axi_aclk [get_bd_pins qdma_0/axi_aclk] [get_bd_pins axi_noc2_0/aclk0] [get_bd_pins smartconnect_1/aclk] [get_bd_pins pcie_reg_space_0/s00_axi_aclk]
  connect_bd_net -net qdma_0_support_phy_rdy_out [get_bd_pins qdma_0_support/phy_rdy_out] [get_bd_pins qdma_0/phy_rdy_out_sd]
  connect_bd_net -net qdma_0_support_user_clk [get_bd_pins qdma_0_support/user_clk] [get_bd_pins qdma_0/user_clk_sd]
  connect_bd_net -net qdma_0_support_user_lnk_up [get_bd_pins qdma_0_support/user_lnk_up] [get_bd_pins qdma_0/user_lnk_up_sd]
  connect_bd_net -net qdma_0_support_user_reset [get_bd_pins qdma_0_support/user_reset] [get_bd_pins qdma_0/user_reset_sd]
  connect_bd_net -net sys_reset_1 [get_bd_pins sys_reset] [get_bd_pins qdma_0_support/sys_reset]

  current_bd_instance $oldCurInst

  # Hier-internal address assignments (both endpoints under pl_pcie/).

  assign_bd_address -offset 0x080250000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces pl_pcie/qdma_0/M_AXI] [get_bd_addr_segs pl_pcie/pcie_reg_space_0/S00_AXI/S00_AXI_reg] -force
  assign_bd_address -offset 0x080250000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces pl_pcie/qdma_0/M_AXI_BRIDGE] [get_bd_addr_segs pl_pcie/pcie_reg_space_0/S00_AXI/S00_AXI_reg] -force

}

proc available_tcl_procs { } {
   puts "##################################################################"
   puts "# Available Tcl procedures to recreate hierarchical blocks:"
   puts "#"
   puts "#    create_hier_cell_pl_pcie parentCell nameHier"
   puts "#    create_hier_cell_qdma_0_support parentCell nameHier"
   puts "#"
   puts "##################################################################"
}

available_tcl_procs

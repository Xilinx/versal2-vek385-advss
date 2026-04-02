# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------

enable_beta_device xc2ve3858-ssva2112-2MP-e-S
set ::proj_name MMI_10g
set ::bd_name versal_gen2_platform
set proj_dir ./runs/${::proj_name}
set constrs_dir "xdc"
set scripts_dir "./scripts"

# set variable names
set part "xc2ve3858-ssva2112-2MP-e-S"

# set up project
create_project ${::proj_name} "$proj_dir" -part $part -force
set_property board_part xilinx.com:vek385_1:part0:1.0 [current_project]

# set up bd design
create_bd_design ${::bd_name}

# instantiate CED design
instantiate_example_design -template xilinx.com:design:versal_comn_platform:2.0  -design $bd_name -options { Board_selection.VALUE VEK385}

# delete GPIOs
startgroup
delete_bd_objs [get_bd_intf_nets axi_bram_ctrl_0_BRAM_PORTA] [get_bd_intf_nets axi_bram_ctrl_0_BRAM_PORTB] [get_bd_intf_nets axi_gpio_0_GPIO] [get_bd_intf_nets ctrl_smc_M00_AXI] [get_bd_intf_nets axi_gpio_1_GPIO] [get_bd_intf_nets ctrl_smc_M01_AXI] [get_bd_intf_nets ctrl_smc_M02_AXI] [get_bd_intf_nets ctrl_smc_M03_AXI] [get_bd_intf_nets axi_gpio_2_GPIO] [get_bd_cells axi_bram_ctrl_0] [get_bd_cells axi_bram_ctrl_0_bram] [get_bd_cells axi_gpio_0] [get_bd_cells axi_gpio_1] [get_bd_cells axi_gpio_2]
delete_bd_objs [get_bd_intf_ports gpio_dp] [get_bd_intf_ports gpio_led] [get_bd_intf_ports gpio_pb]
delete_bd_objs [get_bd_cells clk_wizard_0]								  
endgroup

# disconnect clock/lock of processor_reset 
disconnect_bd_net /clk_wizard_0_clk_out1 [get_bd_pins rst_clk/slowest_sync_clk]
disconnect_bd_net /clk_wizard_0_locked [get_bd_pins rst_clk/dcm_locked]
															   
							 
		

delete_bd_objs [get_bd_nets axi_gpio_1_ip2intc_irpt]
delete_bd_objs [get_bd_nets axi_gpio_2_ip2intc_irpt]

# ps_wizard interrupts
startgroup
set_property -dict [list \
  CONFIG.PS11_CONFIG(PL_FPD_IRQ_USAGE) {CH0 1 CH1 1 CH2 1 CH3 1 CH4 1 CH5 1 CH6 1 CH7 1} \
  CONFIG.PS11_CONFIG(PL_LPD_IRQ_USAGE) {CH0 1 CH1 1 CH2 1 CH3 1 CH4 1 CH5 1 CH6 1 CH7 1 CH8 1 CH9 1 CH10 1 CH11 1 CH12 0 CH13 0 CH14 0 CH15 0 CH16 0 CH17 0 CH18 0 CH19 0 CH20 1 CH21 0 CH22 1 CH23 1} \
  CONFIG.PS11_CONFIG(PS_USE_PMCPL_CLK0) {1} \
  CONFIG.PS11_CONFIG(PS_USE_PMCPL_CLK1) {1} \
  CONFIG.PS11_CONFIG(PS_USE_PMCPL_CLK2) {1} \
  CONFIG.PS11_CONFIG(PS_USE_PMCPL_CLK3) {1} \
  CONFIG.PS11_CONFIG(PMC_CRP_PL0_REF_CTRL_FREQMHZ) {300} \
  CONFIG.PS11_CONFIG(PMC_CRP_PL1_REF_CTRL_FREQMHZ) {150} \
  CONFIG.PS11_CONFIG(PMC_CRP_PL2_REF_CTRL_FREQMHZ) {200} \
  CONFIG.PS11_CONFIG(PMC_CRP_PL3_REF_CTRL_FREQMHZ) {134} \
] [get_bd_cells ps_wizard_0]
endgroup

# configure smart connect
startgroup
set_property CONFIG.NUM_CLKS {2} [get_bd_cells ctrl_smc]
endgroup

# configure Master NoC
startgroup
set_property CONFIG.NUM_NMI {10} [get_bd_cells Master_NoC]
set_property -dict [list CONFIG.CATEGORY {ps_cci} CONFIG.CONNECTIONS {M07_INI {read_bw {500} write_bw {500} initial_boot {true}} M08_INI {read_bw {500} write_bw {500} initial_boot {true}} M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}} M00_INI {read_bw {500} write_bw {500} initial_boot {true}} M09_INI {read_bw {500} write_bw {500} initial_boot {true}}}] [get_bd_intf_pins /Master_NoC/S00_AXI]
set_property -dict [list CONFIG.CATEGORY {ps_cci} CONFIG.CONNECTIONS {M07_INI {read_bw {500} write_bw {500} initial_boot {true}} M08_INI {read_bw {500} write_bw {500} initial_boot {true}} M01_INI {read_bw {500} write_bw {500} initial_boot {true}} M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}}}] [get_bd_intf_pins /Master_NoC/S01_AXI]
set_property -dict [list CONFIG.CATEGORY {ps_cci}] [get_bd_intf_pins /Master_NoC/S02_AXI]
set_property -dict [list CONFIG.CATEGORY {ps_cci}] [get_bd_intf_pins /Master_NoC/S03_AXI]
set_property -dict [list CONFIG.CATEGORY {ps_cci}] [get_bd_intf_pins /Master_NoC/S04_AXI]
set_property -dict [list CONFIG.CATEGORY {ps_cci}] [get_bd_intf_pins /Master_NoC/S05_AXI]
set_property -dict [list CONFIG.CATEGORY {ps_cci}] [get_bd_intf_pins /Master_NoC/S06_AXI]
set_property -dict [list CONFIG.CATEGORY {ps_cci}] [get_bd_intf_pins /Master_NoC/S07_AXI]
set_property -dict [list CONFIG.CATEGORY {ps_rpu} CONFIG.CONNECTIONS {M07_INI {read_bw {500} write_bw {500} initial_boot {true}} M08_INI {read_bw {500} write_bw {500} initial_boot {true}} M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}} M00_INI {read_bw {500} write_bw {500} initial_boot {true}} M09_INI {read_bw {500} write_bw {500} initial_boot {true}}}] [get_bd_intf_pins /Master_NoC/S08_AXI]
set_property -dict [list CONFIG.CONNECTIONS {M07_INI {read_bw {500} write_bw {500} initial_boot {true}} M08_INI {read_bw {500} write_bw {500} initial_boot {true}} M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}} M00_INI {read_bw {500} write_bw {500} initial_boot {true}} M09_INI {read_bw {500} write_bw {500} initial_boot {true}}}] [get_bd_intf_pins /Master_NoC/S09_AXI]
set_property -dict [list CONFIG.CATEGORY {ps_mmi}] [get_bd_intf_pins /Master_NoC/S10_AXI]
endgroup

# Adding MIPI_ISP_VCU_HDMI
source $scripts_dir/mipi_isp_hier.tcl
create_hier_cell_mipi_isp / mipi_isp

source $scripts_dir/vcu2_ss_hier.tcl
create_hier_cell_vcu2_ss / vcu2_ss

source $scripts_dir/display_hier.tcl
create_hier_cell_display / display

# Configure NoC_c0_c1
startgroup
set_property CONFIG.NUM_NSI {11} [get_bd_cells NoC_C0_C1]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}}] [get_bd_intf_pins /NoC_C0_C1/S05_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}}] [get_bd_intf_pins /NoC_C0_C1/S06_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}}] [get_bd_intf_pins /NoC_C0_C1/S07_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}}] [get_bd_intf_pins /NoC_C0_C1/S08_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}}] [get_bd_intf_pins /NoC_C0_C1/S09_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true}}}] [get_bd_intf_pins /NoC_C0_C1/S10_INI]
endgroup

#connect_bd_net [get_bd_pins ps_wizard_0/pl1_ref_clk] [get_bd_pins ps_wizard_0/fpd_axi_pl_aclk]

# clock and reset 
connect_bd_net [get_bd_pins mipi_isp/aclk_150] [get_bd_pins ps_wizard_0/pl1_ref_clk]
connect_bd_net [get_bd_pins mipi_isp/dphy_clk_200M] [get_bd_pins ps_wizard_0/pl2_ref_clk]
connect_bd_net [get_bd_pins mipi_isp/ref_dpll] [get_bd_pins ps_wizard_0/pl3_ref_clk]
connect_bd_net [get_bd_pins vcu2_ss/dpll_ref_clk] [get_bd_pins ps_wizard_0/pl3_ref_clk]
connect_bd_net [get_bd_pins vcu2_ss/aclk_150] [get_bd_pins ps_wizard_0/pl1_ref_clk]
connect_bd_net [get_bd_pins display/aclk_300] [get_bd_pins ps_wizard_0/pl0_ref_clk]
connect_bd_net [get_bd_pins display/aclk1_150] [get_bd_pins ps_wizard_0/pl1_ref_clk]
connect_bd_net [get_bd_pins rst_clk/slowest_sync_clk] [get_bd_pins ps_wizard_0/pl1_ref_clk]

connect_bd_net [get_bd_pins ctrl_smc/aclk1] [get_bd_pins ps_wizard_0/pl0_ref_clk]
connect_bd_net [get_bd_pins ps_wizard_0/pl1_ref_clk] [get_bd_pins ps_wizard_0/fpd_axi_pl_aclk]

connect_bd_net [get_bd_pins mipi_isp/ext_reset_in_0] [get_bd_pins ps_wizard_0/pl0_resetn]
connect_bd_net [get_bd_pins vcu2_ss/ext_reset_in_2] [get_bd_pins ps_wizard_0/pl0_resetn]
connect_bd_net [get_bd_pins display/ext_reset_in_1] [get_bd_pins ps_wizard_0/pl0_resetn]



# smart connect connection
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins mipi_isp/S00_AXI] [get_bd_intf_pins ctrl_smc/M00_AXI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins vcu2_ss/S_AXI_vcu] [get_bd_intf_pins ctrl_smc/M01_AXI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins vcu2_ss/S_AXI_gpio] [get_bd_intf_pins ctrl_smc/M02_AXI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins display/S00_AXI_hdmi] [get_bd_intf_pins ctrl_smc/M03_AXI]

# NoC_c0_c1 connections
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins mipi_isp/M00_INI_isp] [get_bd_intf_pins NoC_C0_C1/S05_INI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins vcu2_ss/M00_INI_vcu] [get_bd_intf_pins NoC_C0_C1/S06_INI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins display/M00_INI_0] [get_bd_intf_pins NoC_C0_C1/S07_INI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins display/M01_INI_0] [get_bd_intf_pins NoC_C0_C1/S08_INI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins display/M02_INI_0] [get_bd_intf_pins NoC_C0_C1/S09_INI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins display/M03_INI_0] [get_bd_intf_pins NoC_C0_C1/S10_INI]

# ISP_VCU NSU
connect_bd_intf_net [get_bd_intf_pins Master_NoC/M07_INI] -boundary_type upper [get_bd_intf_pins mipi_isp/TILE0_ISP_NSU]
connect_bd_intf_net [get_bd_intf_pins Master_NoC/M08_INI] -boundary_type upper [get_bd_intf_pins mipi_isp/TILE1_ISP_NSU]
connect_bd_intf_net [get_bd_intf_pins Master_NoC/M09_INI] -boundary_type upper [get_bd_intf_pins vcu2_ss/vcu_nsu]

# Interrupts connection 
#ISP
connect_bd_net [get_bd_pins mipi_isp/tile0_isp_isr_irq_0] [get_bd_pins ps_wizard_0/pl_lpd_irq0]
connect_bd_net [get_bd_pins mipi_isp/tile0_isp_xmpu_interrupt_0] [get_bd_pins ps_wizard_0/pl_lpd_irq1]
connect_bd_net [get_bd_pins mipi_isp/tile0_isp0_fusa_irq_0] [get_bd_pins ps_wizard_0/pl_lpd_irq2]
connect_bd_net [get_bd_pins mipi_isp/tile0_isp0_isp_irq_0] [get_bd_pins ps_wizard_0/pl_lpd_irq3]
connect_bd_net [get_bd_pins mipi_isp/tile0_isp1_fusa_irq_0] [get_bd_pins ps_wizard_0/pl_lpd_irq4]
connect_bd_net [get_bd_pins mipi_isp/tile0_isp1_isp_irq_0] [get_bd_pins ps_wizard_0/pl_lpd_irq5]
connect_bd_net [get_bd_pins mipi_isp/tile1_isp_isr_irq_0] [get_bd_pins ps_wizard_0/pl_lpd_irq6]
connect_bd_net [get_bd_pins mipi_isp/tile1_isp_xmpu_interrupt_0] [get_bd_pins ps_wizard_0/pl_lpd_irq7]
connect_bd_net [get_bd_pins mipi_isp/tile1_isp0_fusa_irq_0] [get_bd_pins ps_wizard_0/pl_lpd_irq8]
connect_bd_net [get_bd_pins mipi_isp/tile1_isp0_isp_irq_0] [get_bd_pins ps_wizard_0/pl_lpd_irq9]
connect_bd_net [get_bd_pins mipi_isp/tile1_isp1_fusa_irq_0] [get_bd_pins ps_wizard_0/pl_lpd_irq10]
connect_bd_net [get_bd_pins mipi_isp/tile1_isp1_isp_irq_0] [get_bd_pins ps_wizard_0/pl_lpd_irq11]

#MIPI
connect_bd_net [get_bd_pins mipi_isp/irq_mipi] [get_bd_pins ps_wizard_0/pl_fpd_irq0]

#VCU2
connect_bd_net [get_bd_pins vcu2_ss/c0_vcu2_irq_error] [get_bd_pins ps_wizard_0/pl_fpd_irq1]
connect_bd_net [get_bd_pins vcu2_ss/c0_vcu2_dec_pintreq] [get_bd_pins ps_wizard_0/pl_fpd_irq2]
connect_bd_net [get_bd_pins vcu2_ss/c0_vcu2_enc_pintreq] [get_bd_pins ps_wizard_0/pl_fpd_irq3]

#HDMI/MIXER
connect_bd_net [get_bd_pins display/iic2intc_irpt_0_0] [get_bd_pins ps_wizard_0/pl_fpd_irq6]
connect_bd_net [get_bd_pins display/mixer_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq20]
connect_bd_net [get_bd_pins display/vphy_irq_0] [get_bd_pins ps_wizard_0/pl_lpd_irq23]
connect_bd_net [get_bd_pins display/timer_irq_0] [get_bd_pins ps_wizard_0/pl_fpd_irq7]
connect_bd_net [get_bd_pins display/hdmi_tx_irq_0] [get_bd_pins ps_wizard_0/pl_lpd_irq22]

# External ports
startgroup
make_bd_intf_pins_external  [get_bd_intf_pins display/GT_DRU_FRL_CLK_IN_0]
set_property CONFIG.FREQ_HZ 400000000 [get_bd_intf_ports /GT_DRU_FRL_CLK_IN_0_0]
endgroup
startgroup
make_bd_intf_pins_external  [get_bd_intf_pins display/TX_REFCLK_P_IN_V_0]
endgroup
startgroup
make_bd_pins_external  [get_bd_pins display/TX_HPD_IN_0]
endgroup
startgroup
make_bd_pins_external  [get_bd_pins display/IDT8T49N241_LOL_IN_0]
endgroup
startgroup
make_bd_intf_pins_external  [get_bd_intf_pins display/TX_DDC_OUT_0]
endgroup
startgroup
make_bd_intf_pins_external  [get_bd_intf_pins display/HDMI_CTRL_0]
endgroup
startgroup
make_bd_intf_pins_external  [get_bd_intf_pins display/GT_Serial_0]
endgroup
startgroup
make_bd_pins_external  [get_bd_pins display/LED0_0]
endgroup
startgroup
make_bd_pins_external  [get_bd_pins display/RX_TI_ENABLE_0]
endgroup
startgroup
make_bd_intf_pins_external  [get_bd_intf_pins mipi_isp/mipi_phy_if_0]
set_property name mipi_phy_if_0 [get_bd_intf_ports mipi_phy_if_0_0]
endgroup
startgroup
make_bd_intf_pins_external  [get_bd_intf_pins mipi_isp/mipi_phy_if_1]
set_property name mipi_phy_if_1 [get_bd_intf_ports mipi_phy_if_1_0]
endgroup

assign_bd_address
regenerate_bd_layout
validate_bd_design
save_bd_design

# Constraints
remove_files  -fileset constrs_1 $proj_dir/${::proj_name}.srcs/constrs_1/imports/vek385_constrs/vek385_base.xdc
add_files -fileset constrs_1 -norecurse $constrs_dir/
import_files -fileset constrs_1 $constrs_dir/

remove_files  $proj_dir/${::proj_name}.srcs/sources_1/imports/hdl/${::bd_name}_wrapper.v
file delete -force $proj_dir/${::proj_name}.srcs/sources_1/imports/hdl/${::bd_name}_wrapper.v
make_wrapper -files [get_files $proj_dir/${::proj_name}.srcs/sources_1/bd/${::bd_name}/${::bd_name}.bd] -top
add_files -norecurse $proj_dir/${::proj_name}.srcs/sources_1/bd/${::bd_name}/hdl/${::bd_name}_wrapper.v
update_compile_order -fileset sources_1

set fd [open ./README.hw w]
set columns {%40s%30s%15s%50s}
puts $fd [string repeat - 150]
puts $fd [format $columns "MODULE INSTANCE NAME" "IP TYPE" "IP VERSION" "IP"]
puts $fd [string repeat - 150]

foreach ip [get_ips] {
	set catlg_ip [get_ipdefs -all [get_property IPDEF $ip]]
	puts $fd [format $columns [get_property NAME $ip] [get_property NAME $catlg_ip] [get_property VERSION $catlg_ip] [get_property VLNV $catlg_ip]]
}

close $fd

# Generate all output products
set_property NOC_SOLUTION_FILE {} [get_runs impl_1]
launch_runs impl_1 -to_step write_device_image -jobs 32
wait_on_run impl_1

puts "INFO: Design Timing WNS:[get_property STATS.WNS [current_run]]; TNS:[get_property STATS.TNS [current_run]]; WHS:[get_property STATS.WHS [current_run]]; THS:[get_property STATS.THS [current_run]]; TPWS:[get_property STATS.TPWS [current_run]]"
write_hw_platform -fixed -force -include_bit -file $proj_dir/${::proj_name}.xsa

close_project
exit
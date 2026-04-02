# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------

set design_nm "pcie"
set project_dir "runs/${design_nm}"
set ip_dir "ip"
set constrs_dir "xdc"
set scripts_dir "./"
set bd_name "versal_gen2_platform"
# set variable names
set part xc2ve3858-ssva2112-2MP-e-S

# set up project
create_project $design_nm $project_dir -part  $part -force 
set_property board_part xilinx.com:vek385_1:part0:1.0 [current_project]

create_bd_design $bd_name
instantiate_example_design -template xilinx.com:design:versal_comn_platform:2.0  -design $bd_name -options { Board_selection.VALUE VEK385}

set_property  ip_repo_paths  $ip_dir [current_project]
update_ip_catalog

update_compile_order -fileset sources_1
regenerate_bd_layout

# Remove GPIOs
delete_bd_objs [get_bd_intf_nets axi_uart16550_0_UART] [get_bd_intf_ports pl_uart_bank705]
delete_bd_objs [get_bd_intf_nets ctrl_smc_M00_AXI] [get_bd_intf_nets axi_bram_ctrl_0_BRAM_PORTA] [get_bd_intf_nets axi_bram_ctrl_0_BRAM_PORTB] [get_bd_cells axi_bram_ctrl_0] [get_bd_cells axi_bram_ctrl_0_bram] [get_bd_cells axi_uart16550_0]
delete_bd_objs [get_bd_intf_nets ctrl_smc_M01_AXI] [get_bd_intf_nets ctrl_smc_M02_AXI] [get_bd_intf_nets ctrl_smc_M03_AXI] [get_bd_intf_nets ctrl_smc_M04_AXI] [get_bd_intf_nets ctrl_smc_M05_AXI]
delete_bd_objs [get_bd_cells axi_gpio_0] [get_bd_cells axi_gpio_1] [get_bd_cells axi_gpio_2] 
delete_bd_objs [get_bd_intf_ports gpio_led] [get_bd_intf_ports gpio_pb] [get_bd_intf_ports gpio_dp]

#config cips
set_property -dict [list \
  CONFIG.PS11_CONFIG(PL_FPD_IRQ_USAGE) {CH0 1 CH1 1 CH2 1 CH3 1 CH4 0 CH5 0 CH6 0 CH7 0} \
  CONFIG.PS11_CONFIG(PL_LPD_IRQ_USAGE) {CH0 1 CH1 1 CH2 1 CH3 1 CH4 1 CH5 1 CH6 1 CH7 1 CH8 1 CH9 1 CH10 1 CH11 1 CH12 0 CH13 0 CH14 0 CH15 0 CH16 0 CH17 0 CH18 0 CH19 0 CH20 1 CH21 1 CH22 1 CH23 1} \
  CONFIG.PS11_CONFIG(PS_USE_PMCPL_CLK0) {1} \
  CONFIG.PS11_CONFIG(PS_USE_PMCPL_CLK1) {1} \
  CONFIG.PS11_CONFIG(PS_USE_PMCPL_CLK3) {1} \
  CONFIG.PS11_CONFIG(PMC_CRP_PL0_REF_CTRL_FREQMHZ) {100} \
  CONFIG.PS11_CONFIG(PMC_CRP_PL1_REF_CTRL_FREQMHZ) {150} \
  CONFIG.PS11_CONFIG(PMC_CRP_PL3_REF_CTRL_FREQMHZ) {200} \
] [get_bd_cells ps_wizard_0]

set_property -dict [list \
  CONFIG.NUM_CLKS {2} \
  CONFIG.NUM_MI {3} \
] [get_bd_cells ctrl_smc]


#source mipi-isp_ss
source $scripts_dir/mipi_rx_ss_hier.tcl
create_hier_cell_mipi_rx_ss_hier / mipi_rx_ss_hier

#source pl-pcie 
source $scripts_dir/pl_pcie.tcl
create_hier_cell_pl_pcie / pl_pcie

#Master_noc configs


set_property CONFIG.NUM_NMI {9} [get_bd_cells Master_NoC]
set_property -dict [list CONFIG.CATEGORY {ps_cci} CONFIG.CONNECTIONS {M07_INI {read_bw {500} write_bw {500} initial_boot {true} } M08_INI {read_bw {500} write_bw {500} initial_boot {true} } M06_INI {read_bw {500} write_bw {500} initial_boot {true} } M04_INI {read_bw {500} write_bw {500} initial_boot {true} } M05_INI {read_bw {500} write_bw {500} initial_boot {true} } M00_INI {read_bw {500} write_bw {500} initial_boot {true} }}] [get_bd_intf_pins /Master_NoC/S00_AXI]
set_property -dict [list CONFIG.CATEGORY {ps_cci} CONFIG.CONNECTIONS {M07_INI {read_bw {500} write_bw {500} initial_boot {true} } M08_INI {read_bw {500} write_bw {500} initial_boot {true} } M01_INI {read_bw {500} write_bw {500} initial_boot {true} } M06_INI {read_bw {500} write_bw {500} initial_boot {true} } M04_INI {read_bw {500} write_bw {500} initial_boot {true} } M05_INI {read_bw {500} write_bw {500} initial_boot {true} }}] [get_bd_intf_pins /Master_NoC/S01_AXI]
set_property -dict [list CONFIG.CATEGORY {ps_cci} CONFIG.CONNECTIONS {M02_INI {read_bw {500} write_bw {500} initial_boot {true} } M07_INI {read_bw {500} write_bw {500} initial_boot {true} } M08_INI {read_bw {500} write_bw {500} initial_boot {true} } M06_INI {read_bw {500} write_bw {500} initial_boot {true} } M04_INI {read_bw {500} write_bw {500} initial_boot {true} } M05_INI {read_bw {500} write_bw {500} initial_boot {true} }}] [get_bd_intf_pins /Master_NoC/S02_AXI]
set_property -dict [list CONFIG.CATEGORY {ps_cci} CONFIG.CONNECTIONS {M07_INI {read_bw {500} write_bw {500} initial_boot {true} } M08_INI {read_bw {500} write_bw {500} initial_boot {true} } M06_INI {read_bw {500} write_bw {500} initial_boot {true} } M03_INI {read_bw {500} write_bw {500} initial_boot {true} } M04_INI {read_bw {500} write_bw {500} initial_boot {true} } M05_INI {read_bw {500} write_bw {500} initial_boot {true} }}] [get_bd_intf_pins /Master_NoC/S03_AXI]
set_property -dict [list CONFIG.CATEGORY {ps_cci} CONFIG.CONNECTIONS {M07_INI {read_bw {500} write_bw {500} initial_boot {true} } M08_INI {read_bw {500} write_bw {500} initial_boot {true} } M06_INI {read_bw {500} write_bw {500} initial_boot {true} } M04_INI {read_bw {500} write_bw {500} initial_boot {true} } M05_INI {read_bw {500} write_bw {500} initial_boot {true} } M00_INI {read_bw {500} write_bw {500} initial_boot {true} }}] [get_bd_intf_pins /Master_NoC/S04_AXI]
set_property -dict [list CONFIG.CATEGORY {ps_cci} CONFIG.CONNECTIONS {M07_INI {read_bw {500} write_bw {500} initial_boot {true} } M08_INI {read_bw {500} write_bw {500} initial_boot {true} } M01_INI {read_bw {500} write_bw {500} initial_boot {true} } M06_INI {read_bw {500} write_bw {500} initial_boot {true} } M04_INI {read_bw {500} write_bw {500} initial_boot {true} } M05_INI {read_bw {500} write_bw {500} initial_boot {true} }}] [get_bd_intf_pins /Master_NoC/S05_AXI]
set_property -dict [list CONFIG.CATEGORY {ps_cci} CONFIG.CONNECTIONS {M02_INI {read_bw {500} write_bw {500} initial_boot {true} } M07_INI {read_bw {500} write_bw {500} initial_boot {true} } M08_INI {read_bw {500} write_bw {500} initial_boot {true} } M06_INI {read_bw {500} write_bw {500} initial_boot {true} } M04_INI {read_bw {500} write_bw {500} initial_boot {true} } M05_INI {read_bw {500} write_bw {500} initial_boot {true} }}] [get_bd_intf_pins /Master_NoC/S06_AXI]
set_property -dict [list CONFIG.CATEGORY {ps_cci} CONFIG.CONNECTIONS {M07_INI {read_bw {500} write_bw {500} initial_boot {true} } M08_INI {read_bw {500} write_bw {500} initial_boot {true} } M06_INI {read_bw {500} write_bw {500} initial_boot {true} } M03_INI {read_bw {500} write_bw {500} initial_boot {true} } M04_INI {read_bw {500} write_bw {500} initial_boot {true} } M05_INI {read_bw {500} write_bw {500} initial_boot {true} }}] [get_bd_intf_pins /Master_NoC/S07_AXI]
set_property -dict [list CONFIG.CATEGORY {ps_rpu} CONFIG.CONNECTIONS {M07_INI {read_bw {500} write_bw {500} initial_boot {true} } M08_INI {read_bw {500} write_bw {500} initial_boot {true} } M06_INI {read_bw {500} write_bw {500} initial_boot {true} } M04_INI {read_bw {500} write_bw {500} initial_boot {true} } M05_INI {read_bw {500} write_bw {500} initial_boot {true} } M00_INI {read_bw {500} write_bw {500} initial_boot {true} }}] [get_bd_intf_pins /Master_NoC/S08_AXI]
set_property -dict [list CONFIG.CONNECTIONS {M07_INI {read_bw {500} write_bw {500} initial_boot {true} } M08_INI {read_bw {500} write_bw {500} initial_boot {true} } M06_INI {read_bw {500} write_bw {500} initial_boot {true} } M04_INI {read_bw {500} write_bw {500} initial_boot {true} } M05_INI {read_bw {500} write_bw {500} initial_boot {true} } M00_INI {read_bw {500} write_bw {500} initial_boot {true} }}] [get_bd_intf_pins /Master_NoC/S09_AXI]
set_property -dict [list CONFIG.CATEGORY {ps_mmi}] [get_bd_intf_pins /Master_NoC/S10_AXI]

#C0_C1 config's
set_property CONFIG.NUM_NSI {11} [get_bd_cells NoC_C0_C1]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true} }}] [get_bd_intf_pins /NoC_C0_C1/S05_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true} }}] [get_bd_intf_pins /NoC_C0_C1/S06_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true} }}] [get_bd_intf_pins /NoC_C0_C1/S07_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true} }}] [get_bd_intf_pins /NoC_C0_C1/S08_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true} }}] [get_bd_intf_pins /NoC_C0_C1/S09_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true} }}] [get_bd_intf_pins /NoC_C0_C1/S10_INI]

#C2_C3 config
set_property CONFIG.NUM_NSI {4} [get_bd_cells NoC_C2_C3]
set_property -dict [list CONFIG.CONNECTIONS {MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true} }}] [get_bd_intf_pins /NoC_C2_C3/S03_INI]

#C_C4 config
set_property CONFIG.NUM_NSI {4} [get_bd_cells NoC_C4]
set_property -dict [list CONFIG.CONNECTIONS {MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true} }}] [get_bd_intf_pins /NoC_C4/S03_INI]


#irq-conn 
delete_bd_objs [get_bd_nets axi_gpio_1_ip2intc_irpt] [get_bd_nets axi_gpio_2_ip2intc_irpt]
connect_bd_net [get_bd_pins mipi_rx_ss_hier/tile0_isp0_fusa_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq2]
connect_bd_net [get_bd_pins mipi_rx_ss_hier/tile0_isp0_isp_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq3]
connect_bd_net [get_bd_pins mipi_rx_ss_hier/tile0_isp1_fusa_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq4]
connect_bd_net [get_bd_pins mipi_rx_ss_hier/tile0_isp1_isp_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq5]
connect_bd_net [get_bd_pins mipi_rx_ss_hier/tile0_isp_isr_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq0]
connect_bd_net [get_bd_pins mipi_rx_ss_hier/tile0_isp_xmpu_interrupt] [get_bd_pins ps_wizard_0/pl_lpd_irq1]
connect_bd_net [get_bd_pins mipi_rx_ss_hier/tile1_isp0_fusa_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq8]
connect_bd_net [get_bd_pins mipi_rx_ss_hier/tile1_isp0_isp_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq9]
connect_bd_net [get_bd_pins mipi_rx_ss_hier/tile1_isp1_fusa_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq10]
connect_bd_net [get_bd_pins mipi_rx_ss_hier/tile1_isp1_isp_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq11]
connect_bd_net [get_bd_pins mipi_rx_ss_hier/tile1_isp_isr_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq6]
connect_bd_net [get_bd_pins mipi_rx_ss_hier/tile1_isp_xmpu_interrupt] [get_bd_pins ps_wizard_0/pl_lpd_irq7]
connect_bd_net [get_bd_pins mipi_rx_ss_hier/csirxss_csi_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq20]
connect_bd_net [get_bd_pins mipi_rx_ss_hier/csirxss_csi_irq1] [get_bd_pins ps_wizard_0/pl_lpd_irq21]
connect_bd_net [get_bd_pins pl_pcie/IRQ1_to_PS] [get_bd_pins ps_wizard_0/pl_fpd_irq0]
connect_bd_net [get_bd_pins pl_pcie/IRQ2_to_PS] [get_bd_pins ps_wizard_0/pl_fpd_irq1]
connect_bd_net [get_bd_pins pl_pcie/IRQ3_to_PS] [get_bd_pins ps_wizard_0/pl_fpd_irq2]
connect_bd_net [get_bd_pins pl_pcie/IRQ4_to_PS] [get_bd_pins ps_wizard_0/pl_fpd_irq3]

#connections
connect_bd_net [get_bd_pins ps_wizard_0/pl1_ref_clk] [get_bd_pins mipi_rx_ss_hier/tile0_ref_dpll_clk]
connect_bd_net [get_bd_pins ps_wizard_0/pl3_ref_clk] [get_bd_pins mipi_rx_ss_hier/dphy_clk_200M]

#proc-sys-rst-for-150
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0
set_property name proc_sys_reset_150 [get_bd_cells proc_sys_reset_0]
#dcm-locked-constant
create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ilconstant_dcm
set_property name ilxconstant_dcm_locked [get_bd_cells ilconstant_dcm]

#connection-between-the-ip's-of-ced-ex-design
connect_bd_net [get_bd_pins ps_wizard_0/pl1_ref_clk] [get_bd_pins proc_sys_reset_150/slowest_sync_clk]
connect_bd_net [get_bd_pins ps_wizard_0/pl0_resetn] [get_bd_pins proc_sys_reset_150/ext_reset_in]
connect_bd_net [get_bd_pins ilxconstant_dcm_locked/dout] [get_bd_pins proc_sys_reset_150/dcm_locked]
connect_bd_net [get_bd_pins mipi_rx_ss_hier/s_axi_lite_rstn] [get_bd_pins proc_sys_reset_150/peripheral_aresetn]
make_bd_intf_pins_external  [get_bd_intf_pins mipi_rx_ss_hier/MIPI2] [get_bd_intf_pins mipi_rx_ss_hier/MIPI6]
set_property name MIPI2 [get_bd_intf_ports MIPI2_0]
set_property name MIPI6 [get_bd_intf_ports MIPI6_0]
connect_bd_intf_net [get_bd_intf_pins pl_mmi_clk_wiz/s_axi_lite] [get_bd_intf_pins ctrl_smc/M00_AXI]
connect_bd_intf_net [get_bd_intf_pins ctrl_smc/M01_AXI] -boundary_type upper [get_bd_intf_pins mipi_rx_ss_hier/S_AXI_LITE]
connect_bd_intf_net [get_bd_intf_pins ctrl_smc/M02_AXI] -boundary_type upper [get_bd_intf_pins pl_pcie/S00_AXI]
connect_bd_net [get_bd_pins ctrl_smc/aclk1] [get_bd_pins ps_wizard_0/pl1_ref_clk]
connect_bd_net [get_bd_pins clk_wizard_0/clk_out1] [get_bd_pins pl_pcie/aclk]
connect_bd_net [get_bd_pins rst_clk/peripheral_aresetn] [get_bd_pins pl_pcie/aresetn]
make_bd_pins_external  [get_bd_pins pl_pcie/sys_reset]
make_bd_intf_pins_external  [get_bd_intf_pins pl_pcie/pcie_mgt] [get_bd_intf_pins pl_pcie/pcie_refclk]



#Master_Noc loopback CONNECTIONS
connect_bd_intf_net [get_bd_intf_pins Master_NoC/M07_INI] -boundary_type upper [get_bd_intf_pins mipi_rx_ss_hier/S00_INI]
connect_bd_intf_net [get_bd_intf_pins Master_NoC/M08_INI] -boundary_type upper [get_bd_intf_pins mipi_rx_ss_hier/S01_INI]

#connections to C0_C1 
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins mipi_rx_ss_hier/M00_INI] [get_bd_intf_pins NoC_C0_C1/S05_INI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins mipi_rx_ss_hier/M01_INI] [get_bd_intf_pins NoC_C0_C1/S06_INI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins mipi_rx_ss_hier/M02_INI] [get_bd_intf_pins NoC_C0_C1/S07_INI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins mipi_rx_ss_hier/M03_INI] [get_bd_intf_pins NoC_C0_C1/S08_INI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins pl_pcie/M00_INI] [get_bd_intf_pins NoC_C0_C1/S09_INI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins pl_pcie/M01_INI] [get_bd_intf_pins NoC_C2_C3/S03_INI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins pl_pcie/M02_INI] [get_bd_intf_pins NoC_C4/S03_INI]

save_bd_design

assign_bd_address
regenerate_bd_layout
validate_bd_design
save_bd_design

# Constraints
add_files -fileset constrs_1 -norecurse $constrs_dir/
import_files -fileset constrs_1 $constrs_dir/
set_property used_in_synthesis false [get_files async.xdc]

remove_files  $project_dir/${design_nm}.srcs/sources_1/imports/hdl/${bd_name}_wrapper.v
file delete -force $project_dir/${design_nm}.srcs/sources_1/imports/hdl/${bd_name}_wrapper.v
make_wrapper -files [get_files $project_dir/${design_nm}.srcs/sources_1/bd/${bd_name}/${bd_name}.bd] -top
add_files -norecurse $project_dir/${design_nm}.srcs/sources_1/bd/${bd_name}/hdl/${bd_name}_wrapper.v

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
set_property strategy Performance_Explore [get_runs impl_1]
set_property NOC_SOLUTION_FILE {} [get_runs impl_1]

# Run Implementation
launch_runs impl_1 -to_step write_device_image -jobs 32
wait_on_run impl_1
puts "INFO: Design Timing WNS:[get_property STATS.WNS [current_run]]; TNS:[get_property STATS.TNS [current_run]]; WHS:[get_property STATS.WHS [current_run]]; THS:[get_property STATS.THS [current_run]]; TPWS:[get_property STATS.TPWS [current_run]]"

write_hw_platform -fixed -force -include_bit -file $project_dir/${design_nm}.xsa
close_project
exit

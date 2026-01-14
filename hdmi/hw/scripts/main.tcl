# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------

# local variables
enable_beta_device xc2ve3858-ssva2112-2MP-e-S
set ::proj_name hdmi
set ::bd_name versal_gen2_platform
set proj_dir ./runs/${::proj_name}
set constrs_dir "./xdc"
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
delete_bd_objs [get_bd_intf_nets axi_bram_ctrl_0_BRAM_PORTA] [get_bd_intf_nets axi_bram_ctrl_0_BRAM_PORTB] [get_bd_intf_nets axi_gpio_0_GPIO] [get_bd_intf_nets ctrl_smc_M00_AXI] [get_bd_intf_nets axi_gpio_1_GPIO] [get_bd_intf_nets ctrl_smc_M01_AXI] [get_bd_intf_nets ctrl_smc_M02_AXI] [get_bd_intf_nets ctrl_smc_M03_AXI] [get_bd_intf_nets axi_gpio_2_GPIO] [get_bd_cells axi_bram_ctrl_0] [get_bd_cells axi_bram_ctrl_0_bram] [get_bd_cells axi_gpio_0] [get_bd_cells axi_gpio_1] [get_bd_cells axi_gpio_2] [get_bd_nets axi_gpio_1_ip2intc_irpt] [get_bd_nets axi_gpio_2_ip2intc_irpt] [get_bd_intf_nets axi_uart16550_0_UART] [get_bd_intf_nets ctrl_smc_M01_AXI] [get_bd_cells axi_uart16550_0] [get_bd_intf_ports gpio_dp] [get_bd_intf_ports gpio_led] [get_bd_intf_ports gpio_pb] [get_bd_intf_ports pl_uart_bank705]
endgroup
# configure NoC
startgroup
set_property CONFIG.NUM_NMI {8} [get_bd_cells Master_NoC]
set_property CONFIG.NUM_NSI {11} [get_bd_cells NoC_C0_C1]
set_property CONFIG.NUM_NSI {5} [get_bd_cells NoC_C2_C3]
endgroup
startgroup
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false}}}] [get_bd_intf_pins /NoC_C0_C1/S05_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false}}}] [get_bd_intf_pins /NoC_C0_C1/S06_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false}}}] [get_bd_intf_pins /NoC_C0_C1/S07_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false}}}] [get_bd_intf_pins /NoC_C0_C1/S08_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false}}}] [get_bd_intf_pins /NoC_C0_C1/S09_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false}}}] [get_bd_intf_pins /NoC_C0_C1/S10_INI]
endgroup
startgroup
set_property -dict [list CONFIG.CONNECTIONS {MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C2_C3/S03_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C2_C3/S04_INI]
endgroup
# configure Master NoC 
set Master_NoC_S00_AXI [concat [list M07_INI {read_bw {500} write_bw {500} initial_boot {false}}] [get_property CONFIG.CONNECTIONS [get_bd_intf_pins /Master_NoC/S00_AXI]]]
set Master_NoC_S01_AXI [concat [list M07_INI {read_bw {500} write_bw {500} initial_boot {false}}] [get_property CONFIG.CONNECTIONS [get_bd_intf_pins /Master_NoC/S01_AXI]]]
set Master_NoC_S02_AXI [concat [list M07_INI {read_bw {500} write_bw {500} initial_boot {false}}] [get_property CONFIG.CONNECTIONS [get_bd_intf_pins /Master_NoC/S02_AXI]]]
set Master_NoC_S03_AXI [concat [list M07_INI {read_bw {500} write_bw {500} initial_boot {false}}] [get_property CONFIG.CONNECTIONS [get_bd_intf_pins /Master_NoC/S03_AXI]]]
set Master_NoC_S04_AXI [concat [list M07_INI {read_bw {500} write_bw {500} initial_boot {false}}] [get_property CONFIG.CONNECTIONS [get_bd_intf_pins /Master_NoC/S04_AXI]]]
set Master_NoC_S05_AXI [concat [list M07_INI {read_bw {500} write_bw {500} initial_boot {false}}] [get_property CONFIG.CONNECTIONS [get_bd_intf_pins /Master_NoC/S05_AXI]]]
set Master_NoC_S06_AXI [concat [list M07_INI {read_bw {500} write_bw {500} initial_boot {false}}] [get_property CONFIG.CONNECTIONS [get_bd_intf_pins /Master_NoC/S06_AXI]]]
set Master_NoC_S07_AXI [concat [list M07_INI {read_bw {500} write_bw {500} initial_boot {false}}] [get_property CONFIG.CONNECTIONS [get_bd_intf_pins /Master_NoC/S07_AXI]]]
set Master_NoC_S08_AXI [concat [list M07_INI {read_bw {500} write_bw {500} initial_boot {false}}] [get_property CONFIG.CONNECTIONS [get_bd_intf_pins /Master_NoC/S08_AXI]]]
set Master_NoC_S09_AXI [concat [list M07_INI {read_bw {500} write_bw {500} initial_boot {false}}] [get_property CONFIG.CONNECTIONS [get_bd_intf_pins /Master_NoC/S09_AXI]]]
set Master_NoC_S10_AXI [concat [list M07_INI {read_bw {500} write_bw {500} initial_boot {false}}] [get_property CONFIG.CONNECTIONS [get_bd_intf_pins /Master_NoC/S10_AXI]]]
# Assign NOC2 connectivity
set_property CONFIG.CONNECTIONS $Master_NoC_S00_AXI [get_bd_intf_pins /Master_NoC/S00_AXI]
set_property CONFIG.CONNECTIONS $Master_NoC_S01_AXI [get_bd_intf_pins /Master_NoC/S01_AXI]
set_property CONFIG.CONNECTIONS $Master_NoC_S02_AXI [get_bd_intf_pins /Master_NoC/S02_AXI]
set_property CONFIG.CONNECTIONS $Master_NoC_S03_AXI [get_bd_intf_pins /Master_NoC/S03_AXI]
set_property CONFIG.CONNECTIONS $Master_NoC_S04_AXI [get_bd_intf_pins /Master_NoC/S04_AXI]
set_property CONFIG.CONNECTIONS $Master_NoC_S05_AXI [get_bd_intf_pins /Master_NoC/S05_AXI]
set_property CONFIG.CONNECTIONS $Master_NoC_S06_AXI [get_bd_intf_pins /Master_NoC/S06_AXI]
set_property CONFIG.CONNECTIONS $Master_NoC_S07_AXI [get_bd_intf_pins /Master_NoC/S07_AXI]
set_property CONFIG.CONNECTIONS $Master_NoC_S08_AXI [get_bd_intf_pins /Master_NoC/S08_AXI]
set_property CONFIG.CONNECTIONS $Master_NoC_S09_AXI [get_bd_intf_pins /Master_NoC/S09_AXI]
set_property CONFIG.CONNECTIONS $Master_NoC_S10_AXI [get_bd_intf_pins /Master_NoC/S10_AXI]
# source hdmi_ss
source $scripts_dir/hdmi_ss_hier.tcl
create_hier_cell_hdmi_ss / hdmi_ss
# source vcu2_ss
source $scripts_dir/vcu2_ss_hier.tcl
create_hier_cell_vcu2_ss / vcu2_ss
# NOC connections
# HDMI_ss
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins hdmi_ss/M00_INI] [get_bd_intf_pins NoC_C0_C1/S09_INI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins hdmi_ss/M01_INI] [get_bd_intf_pins NoC_C0_C1/S10_INI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins hdmi_ss/M02_INI] [get_bd_intf_pins NoC_C2_C3/S03_INI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins hdmi_ss/M03_INI] [get_bd_intf_pins NoC_C2_C3/S04_INI]

connect_bd_intf_net -boundary_type upper [get_bd_intf_pins vcu2_ss/S00_INI] [get_bd_intf_pins Master_NoC/M07_INI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins vcu2_ss/M00_INI] [get_bd_intf_pins /NoC_C0_C1/S05_INI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins vcu2_ss/M01_INI] [get_bd_intf_pins /NoC_C0_C1/S06_INI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins vcu2_ss/M02_INI] [get_bd_intf_pins /NoC_C0_C1/S07_INI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins vcu2_ss/M03_INI] [get_bd_intf_pins /NoC_C0_C1/S08_INI]
# clk wizard
startgroup
set_property -dict [list \
  CONFIG.CLKOUT_PORT {clk_150,clk_300,clk_450,clk_out4,clk_out5,clk_out6,clk_out7} \
  CONFIG.CLKOUT_REQUESTED_DUTY_CYCLE {50.000,50.000,50.000,50.000,50.000,50.000,50.000} \
  CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {150,300,450.000,100.000,100.000,100.000,100.000} \
  CONFIG.CLKOUT_USED {true,true,true,false,false,false,false} \
] [get_bd_cells clk_wizard_0]

endgroup
# configure smart connect
startgroup
delete_bd_objs [get_bd_intf_nets ctrl_smc_M04_AXI] [get_bd_intf_nets ctrl_smc_M05_AXI]
set_property -dict [list \
  CONFIG.NUM_CLKS {2} \
  CONFIG.NUM_MI {3} \
] [get_bd_cells ctrl_smc]
endgroup
#smc connection
connect_bd_intf_net [get_bd_intf_pins ctrl_smc/M00_AXI] [get_bd_intf_pins pl_mmi_clk_wiz/s_axi_lite]
connect_bd_intf_net [get_bd_intf_pins ctrl_smc/M01_AXI] -boundary_type upper [get_bd_intf_pins hdmi_ss/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins ctrl_smc/M02_AXI] -boundary_type upper [get_bd_intf_pins vcu2_ss/S00_AXI]

delete_bd_objs [get_bd_nets rst_ps_wizard_0_99M_peripheral_aresetn]
connect_bd_net [get_bd_pins rst_clk/interconnect_aresetn] [get_bd_pins ctrl_smc/aresetn]
connect_bd_net [get_bd_pins clk_wizard_0/clk_300] [get_bd_pins ctrl_smc/aclk1] 
connect_bd_net [get_bd_pins clk_wizard_0/clk_150] [get_bd_pins rst_clk/slowest_sync_clk]
connect_bd_net [get_bd_pins rst_clk/peripheral_aresetn] [get_bd_pins pl_mmi_clk_wiz/s_axi_aresetn]


# proc_rst_300M
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0
endgroup
set_property name proc_sys_reset_300M [get_bd_cells proc_sys_reset_0]
connect_bd_net [get_bd_pins proc_sys_reset_300M/ext_reset_in] [get_bd_pins ps_wizard_0/pl0_resetn]
connect_bd_net [get_bd_pins proc_sys_reset_300M/slowest_sync_clk] [get_bd_pins clk_wizard_0/clk_300]
connect_bd_net [get_bd_pins proc_sys_reset_300M/dcm_locked] [get_bd_pins clk_wizard_0/locked]
# enable interrupt 
set_property -dict [list \
CONFIG.PS11_CONFIG(PL_FPD_IRQ_USAGE) {CH0 1 CH1 1 CH2 1 CH3 1 CH4 0 CH5 0 CH6 1 CH7 1} \
CONFIG.PS11_CONFIG(PL_LPD_IRQ_USAGE) {CH0 1 CH1 0 CH2 0 CH3 0 CH4 0 CH5 0 CH6 0 CH7 0 CH8 0 CH9 0 CH10 0 CH11 0 CH12 0 CH13 0 CH14 0 CH15 0 CH16 0 CH17 0 CH18 1 CH19 1 CH20 1 CH21 1 CH22 1 CH23 1} \
] [get_bd_cells ps_wizard_0]  
# IRQ connections
# HDMI IRQ
connect_bd_net [get_bd_pins hdmi_ss/irq_rx] [get_bd_pins ps_wizard_0/pl_lpd_irq18]
connect_bd_net [get_bd_pins hdmi_ss/fb_wr_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq19]
connect_bd_net [get_bd_pins hdmi_ss/fb_rd_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq20]
connect_bd_net [get_bd_pins hdmi_ss/irq_timer0] [get_bd_pins ps_wizard_0/pl_lpd_irq21]
connect_bd_net [get_bd_pins hdmi_ss/irq_tx] [get_bd_pins ps_wizard_0/pl_lpd_irq22]
connect_bd_net [get_bd_pins hdmi_ss/irq_vphy] [get_bd_pins ps_wizard_0/pl_lpd_irq23]
connect_bd_net [get_bd_pins hdmi_ss/irq_iic_ctrl] [get_bd_pins ps_wizard_0/pl_fpd_irq6]
connect_bd_net [get_bd_pins hdmi_ss/irq_timer1] [get_bd_pins ps_wizard_0/pl_fpd_irq7]
#VCU irq
connect_bd_net [get_bd_pins vcu2_ss/c0_irq_error] [get_bd_pins ps_wizard_0/pl_fpd_irq1]
connect_bd_net [get_bd_pins vcu2_ss/c0_irq_dec_pintreq] [get_bd_pins ps_wizard_0/pl_fpd_irq2]
connect_bd_net [get_bd_pins vcu2_ss/c0_irq_enc_pintreq] [get_bd_pins ps_wizard_0/pl_fpd_irq3]
# hdmi_ss connections
connect_bd_net [get_bd_pins hdmi_ss/s_axis_video_aclk] [get_bd_pins clk_wizard_0/clk_300]
connect_bd_net [get_bd_pins hdmi_ss/s_axis_video_aresetn] [get_bd_pins proc_sys_reset_300M/peripheral_aresetn]
connect_bd_net [get_bd_pins hdmi_ss/s_axi_cpu_aclk] [get_bd_pins clk_wizard_0/clk_150]
connect_bd_net [get_bd_pins hdmi_ss/s_axi_cpu_aresetn] [get_bd_pins rst_clk/peripheral_aresetn]
connect_bd_net [get_bd_pins hdmi_ss/frl_clk] [get_bd_pins clk_wizard_0/clk_450]
# vcu2_ss connection
connect_bd_net [get_bd_pins vcu2_ss/s_axi_lite_clk] [get_bd_pins clk_wizard_0/clk_150]
connect_bd_net [get_bd_pins vcu2_ss/s_axi_lite_rst_n] [get_bd_pins rst_clk/peripheral_aresetn]
connect_bd_net [get_bd_pins ps_wizard_0/pl1_ref_clk] [get_bd_pins vcu2_ss/dpll_ref_clk]

# External interfaces
startgroup
make_bd_pins_external  [get_bd_pins hdmi_ss/RX_DET_N_n] [get_bd_pins hdmi_ss/TX_HPD_IN] [get_bd_pins hdmi_ss/IDT8T49N241_LOL_IN]   [get_bd_pins hdmi_ss/RX_HPD_OUT] [get_bd_pins hdmi_ss/RX_REFCLK_P_OUT] [get_bd_pins hdmi_ss/RX_REFCLK_N_OUT] [get_bd_pins hdmi_ss/TX_TI_ENABLE] [get_bd_pins hdmi_ss/LED0]
endgroup
startgroup
make_bd_intf_pins_external  [get_bd_intf_pins hdmi_ss/GT_DRU_FRL_CLK_IN] [get_bd_intf_pins hdmi_ss/TX_REFCLK_P_IN_V] [get_bd_intf_pins hdmi_ss/HDMI_RX_CLK_P_IN_V] [get_bd_intf_pins hdmi_ss/GT_Serial] [get_bd_intf_pins hdmi_ss/RX_DDC_OUT] [get_bd_intf_pins hdmi_ss/HDMI_CTRL] [get_bd_intf_pins hdmi_ss/TX_DDC_OUT]
endgroup
startgroup
set_property name GT_DRU_FRL_CLK_IN [get_bd_intf_ports GT_DRU_FRL_CLK_IN_0]
set_property CONFIG.FREQ_HZ 400000000 [get_bd_intf_ports /GT_DRU_FRL_CLK_IN] 
set_property name TX_REFCLK_P_IN_V [get_bd_intf_ports TX_REFCLK_P_IN_V_0]
set_property name HDMI_RX_CLK_P_IN_V [get_bd_intf_ports HDMI_RX_CLK_P_IN_V_0]
set_property name GT_Serial [get_bd_intf_ports GT_Serial_0]
set_property name RX_DDC_OUT [get_bd_intf_ports RX_DDC_OUT_0]
set_property name HDMI_CTRL [get_bd_intf_ports HDMI_CTRL_0]
set_property name TX_DDC_OUT [get_bd_intf_ports TX_DDC_OUT_0]
endgroup
startgroup
set_property name RX_DET_N_n [get_bd_ports RX_DET_N_n_0]
set_property name TX_HPD_IN [get_bd_ports TX_HPD_IN_0]
set_property name IDT8T49N241_LOL_IN [get_bd_ports IDT8T49N241_LOL_IN_0]
set_property name RX_HPD_OUT [get_bd_ports RX_HPD_OUT_0]
set_property name RX_REFCLK_P_OUT [get_bd_ports RX_REFCLK_P_OUT_0]
set_property name RX_REFCLK_N_OUT [get_bd_ports RX_REFCLK_N_OUT_0]
set_property name TX_TI_ENABLE [get_bd_ports TX_TI_ENABLE_0]
create_bd_port -dir O RX_TI_ENABLE
connect_bd_net [get_bd_ports RX_TI_ENABLE] [get_bd_pins hdmi_ss/TX_TI_ENABLE]
set_property name LED0 [get_bd_ports LED0_0]
endgroup

assign_bd_address
regenerate_bd_layout
validate_bd_design
save_bd_design

# Constraints
add_files -fileset constrs_1 -norecurse $constrs_dir/
import_files -fileset constrs_1 $constrs_dir/

remove_files  $proj_dir/${::proj_name}.srcs/sources_1/imports/hdl/${::bd_name}_wrapper.v
file delete -force $proj_dir/${::proj_name}.srcs/sources_1/imports/hdl/${::bd_name}_wrapper.v
make_wrapper -files [get_files $proj_dir/${::proj_name}.srcs/sources_1/bd/${::bd_name}/${::bd_name}.bd] -top
add_files -norecurse $proj_dir/${::proj_name}.gen/sources_1/bd/${::bd_name}/hdl/${::bd_name}_wrapper.v
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
set_property strategy {Vivado Advanced Implementation Defaults} [get_runs impl_1]
launch_runs impl_1 -to_step write_device_image -jobs 32
wait_on_run impl_1

puts "INFO: Design Timing WNS:[get_property STATS.WNS [current_run]]; TNS:[get_property STATS.TNS [current_run]]; WHS:[get_property STATS.WHS [current_run]]; THS:[get_property STATS.THS [current_run]]; TPWS:[get_property STATS.TPWS [current_run]]"
write_hw_platform -fixed -force -include_bit -file $proj_dir/${::proj_name}.xsa

close_project
exit

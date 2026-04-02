# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------

# local variablesset 
enable_beta_device xc2ve3858-ssva2112-2MP-e-S
set ::proj_name sdi
set ::bd_name versal_gen2_platform
set proj_dir ./runs/${::proj_name}
set constrs_dir "./xdc"
set scripts_dir "./scripts"
set source_dir "./srcs"


# set variable names
set part "xc2ve3858-ssva2112-2MP-e-S"

# set up project
create_project ${::proj_name} "$proj_dir" -part $part -force
set_property board_part xilinx.com:vek385_1:part0:1.0 [current_project]

# set up bd design
create_bd_design ${::bd_name}

# instantiate CED design
instantiate_example_design -template xilinx.com:design:versal_comn_platform:2.0  -design $bd_name -options { Board_selection.VALUE VEK385}

# clk wizard
set_property -dict [list \
  CONFIG.CLKOUT_PORT {clk_100,clk_out2,clk_out3,clk_out4,clk_out5,clk_out6,clk_out7} \
  CONFIG.CLKOUT_USED {true,false,false,false,false,false,false} \
  CONFIG.OVERRIDE_PRIMITIVE {false} \
] [get_bd_cells clk_wizard_0]

source $scripts_dir/sdi.tcl
create_hier_cell_sdi / sdi

source $scripts_dir/vcu2_ss.tcl
create_hier_cell_vcu2_ss / vcu2_ss

#C0_C1 & C2 Noc config

set_property CONFIG.NUM_NSI {10} [get_bd_cells NoC_C0_C1]
set_property CONFIG.NUM_NSI {4} [get_bd_cells NoC_C2_C3]

set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C0_C1/S05_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C0_C1/S06_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C0_C1/S07_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C0_C1/S08_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C0_C1/S09_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C2_C3/S03_INI]

# configure Master NoC 

set_property CONFIG.NUM_NMI {8} [get_bd_cells Master_NoC]
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

#NOC CONNECTIONS

connect_bd_intf_net -boundary_type upper [get_bd_intf_pins vcu2_ss/S00_INI] [get_bd_intf_pins Master_NoC/M07_INI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins vcu2_ss/M00_INI] [get_bd_intf_pins /NoC_C0_C1/S05_INI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins vcu2_ss/M01_INI] [get_bd_intf_pins /NoC_C0_C1/S06_INI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins vcu2_ss/M02_INI] [get_bd_intf_pins /NoC_C0_C1/S07_INI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins vcu2_ss/M03_INI] [get_bd_intf_pins /NoC_C0_C1/S08_INI]

connect_bd_intf_net -boundary_type upper [get_bd_intf_pins sdi/M00_INI] [get_bd_intf_pins NoC_C0_C1/S09_INI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins sdi/M01_INI] [get_bd_intf_pins NoC_C2_C3/S03_INI]

set_property CONFIG.NUM_MI {8} [get_bd_cells ctrl_smc]
connect_bd_intf_net [get_bd_intf_pins ctrl_smc/M07_AXI] -boundary_type upper [get_bd_intf_pins vcu2_ss/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins sdi/smartconnect_0/S00_AXI] [get_bd_intf_pins ctrl_smc/M06_AXI]


  set gt_refclk2 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 gt_refclk2 ]
  set gt_refclk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 gt_refclk ]
  set GT_Serial_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 GT_Serial_0 ]
  set fzetton_fmc_iic [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 fzetton_fmc_iic ]
  set fzetton_fmc_gpio [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 fzetton_fmc_gpio ]
  set fzetton_fmc_spi [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:spi_rtl:1.0 fzetton_fmc_spi ]
  set QUAD0_gpo_0 [ create_bd_port -dir O -from 31 -to 0 QUAD0_gpo_0 ]
  set QUAD0_gpi_0 [ create_bd_port -dir I -from 31 -to 0 QUAD0_gpi_0 ]
  set clk_txusrclk [ create_bd_port -dir O -type clk clk_txusrclk ]
  set clk_rxusrclk [ create_bd_port -dir O -type clk clk_rxusrclk ]
  
connect_bd_intf_net [get_bd_intf_ports gt_refclk2] [get_bd_intf_pins sdi/gt_refclk2]
connect_bd_intf_net  [get_bd_intf_ports gt_refclk] [get_bd_intf_pins sdi/gt_refclk]
connect_bd_net   [get_bd_ports QUAD0_gpi_0]  [get_bd_pins sdi/QUAD0_gpi_0]
connect_bd_intf_net [get_bd_intf_pins sdi/GT_Serial_0] [get_bd_intf_pins GT_Serial_0]
connect_bd_intf_net  [get_bd_intf_pins fzetton_fmc_spi] [get_bd_intf_pins sdi/fzetton_fmc_spi]
connect_bd_intf_net [get_bd_intf_pins fzetton_fmc_gpio] [get_bd_intf_pins sdi/fzetton_fmc_gpio]
connect_bd_intf_net  [get_bd_intf_pins fzetton_fmc_iic] [get_bd_intf_pins sdi/fzetton_fmc_iic]
connect_bd_net  [get_bd_pins sdi/QUAD0_gpo_0]   [get_bd_pins QUAD0_gpo_0]
connect_bd_net   [get_bd_pins sdi/clk_rxusrclk]  [get_bd_pins clk_rxusrclk]
connect_bd_net [get_bd_pins sdi/clk_txusrclk]  [get_bd_pins clk_txusrclk]

connect_bd_net [get_bd_pins ps_wizard_0/pl0_resetn] [get_bd_pins sdi/reset]
connect_bd_net [get_bd_pins sdi/aclk2] [get_bd_pins clk_wizard_0/clk_100]
connect_bd_net [get_bd_pins clk_wizard_0/clk_100] [get_bd_pins ps_wizard_0/fpd_axi_pl_aclk]
connect_bd_net [get_bd_pins sdi/irq] [get_bd_pins ps_wizard_0/pl_lpd_irq2]

# vcu2_ss connection
connect_bd_net [get_bd_pins vcu2_ss/s_axi_lite_clk] [get_bd_pins clk_wizard_0/clk_100]
connect_bd_net [get_bd_pins vcu2_ss/s_axi_lite_rst_n] [get_bd_pins rst_clk/peripheral_aresetn]
connect_bd_net [get_bd_pins ps_wizard_0/pl1_ref_clk] [get_bd_pins vcu2_ss/dpll_ref_clk]

#VCU irq
connect_bd_net [get_bd_pins vcu2_ss/c0_irq_error] [get_bd_pins ps_wizard_0/pl_fpd_irq1]
connect_bd_net [get_bd_pins vcu2_ss/c0_irq_dec_pintreq] [get_bd_pins ps_wizard_0/pl_fpd_irq2]
connect_bd_net [get_bd_pins vcu2_ss/c0_irq_enc_pintreq] [get_bd_pins ps_wizard_0/pl_fpd_irq3]

assign_bd_address
validate_bd_design
regenerate_bd_layout
save_bd_design

# Constraints
add_files -fileset constrs_1 -norecurse $constrs_dir/
import_files -fileset constrs_1 $constrs_dir/

remove_files  $proj_dir/${::proj_name}.srcs/sources_1/imports/hdl/${::bd_name}_wrapper.v
file delete -force $proj_dir/${::proj_name}.srcs/sources_1/imports/hdl/${::bd_name}_wrapper.v
add_files -norecurse $source_dir/${::bd_name}_wrapper.v

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

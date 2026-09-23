# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------

set ::jobs 8
for {set i 0} {$i < [llength $::argv]} {incr i} {
    set arg [lindex $::argv $i]
    if {$arg == "-jobs"} {
        incr i
        set ::jobs [lindex $::argv $i]
    }
}

set design_nm "sdi"
set project_dir "runs/${design_nm}"
set ip_dir "ip"
set constrs_dir "./xdc"
set scripts_dir "./scripts"
set source_dir "./srcs"
set bd_name "edf_base"
# set variable names
set part xc2ve3858-ssva2112-2MP-e-S

# set up project
create_project $design_nm $project_dir -part  $part -force
set_property board_part xilinx.com:vek385_1:part0:1.0 [current_project]

create_bd_design $bd_name
instantiate_example_design -template xilinx.com:design:edf_base:1.0  -design $bd_name

set_property  ip_repo_paths $ip_dir [current_project]
update_ip_catalog

#config cips
set_property -dict [list \
  CONFIG.PS11_CONFIG(PL_LPD_IRQ_USAGE) {CH0 1 CH1 1 CH2 1 CH3 1 CH4 1 CH5 1 CH6 1 CH7 1 CH8 1 CH9 1 CH10 1 CH11 1 CH12 0 CH13 0 CH14 0 CH15 0 CH16 0 CH17 0 CH18 1 CH19 1 CH20 1 CH21 1 CH22 1 CH23 1}
] [get_bd_cells ps_wizard_0]

# WARNING: [WARNING/ddr] cell=NoC_C0_C1 where=S05_INI/CONFIG.CONNECTIONS/MC_0/initial_boot:1
# WARNING: [WARNING/ddr] cell=NoC_C0_C1 where=S06_INI/CONFIG.CONNECTIONS/MC_0/initial_boot:1
# WARNING: [WARNING/ddr] cell=NoC_C2_C3 where=S03_INI/CONFIG.CONNECTIONS/MC_1/initial_boot:1
# WARNING: [WARNING/ddr] cell=NoC_C4 where=S03_INI/CONFIG.CONNECTIONS/MC_1/initial_boot:1
# WARNING: [WARNING/ps] cell=ps_wizard_0 where=CONFIG.PS11_CONFIG(SMON_MEAS43):1
# WARNING: [WARNING/ps] cell=ps_wizard_0 where=CONFIG.PS11_CONFIG(SMON_MEAS44):1
# WARNING: [WARNING/ps] cell=ps_wizard_0 where=CONFIG.PS11_CONFIG(SMON_MEAS21):1
# WARNING: [WARNING/ps] cell=ps_wizard_0 where=CONFIG.PS11_CONFIG(SMON_MEAS22):1
# WARNING: [WARNING/ps] cell=ps_wizard_0 where=CONFIG.PS11_CONFIG(SMON_MEAS42):1

# source sdi_hier
source $scripts_dir/sdi.tcl
create_hier_cell_sdi / sdi
# source VCU_hier
source $scripts_dir/VCU_hier.tcl

create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0
set_property -dict [list \
  CONFIG.NUM_MI {3} \
  CONFIG.NUM_SI {1} \
] [get_bd_cells smartconnect_0]
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0


#pin-connections
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
  
  
#C0_C1 & C2 Noc config
set_property CONFIG.NUM_NSI {10} [get_bd_cells NoC_C0_C1]
set_property CONFIG.NUM_NSI {4} [get_bd_cells NoC_C2_C3]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C0_C1/S05_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C0_C1/S06_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C0_C1/S07_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C0_C1/S08_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C0_C1/S09_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C2_C3/S03_INI]
#NOC CONNECTIONS
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins sdi/M00_INI] [get_bd_intf_pins NoC_C0_C1/S09_INI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins sdi/M01_INI] [get_bd_intf_pins NoC_C2_C3/S03_INI]

#sdi-hier connections
connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M00_AXI] -boundary_type upper [get_bd_intf_pins sdi/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins ps_wizard_0/FPD_AXI_PL] [get_bd_intf_pins smartconnect_0/S00_AXI]
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
connect_bd_net [get_bd_pins sdi/irq] [get_bd_pins ps_wizard_0/pl_fpd_irq3]
disconnect_bd_net /ilconstant_1_dout [get_bd_pins ps_wizard_0/fpd_axi_pl_aclk]
connect_bd_net [get_bd_pins ps_wizard_0/pl0_ref_clk] [get_bd_pins ps_wizard_0/fpd_axi_pl_aclk]
connect_bd_net [get_bd_pins ps_wizard_0/pl0_ref_clk] [get_bd_pins smartconnect_0/aclk]
connect_bd_net [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins ps_wizard_0/pl0_ref_clk]
connect_bd_net [get_bd_pins sdi/clk_in1] [get_bd_pins ps_wizard_0/pl0_ref_clk]
connect_bd_net [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins smartconnect_0/aresetn]
connect_bd_net [get_bd_pins ps_wizard_0/pl0_resetn] [get_bd_pins proc_sys_reset_0/ext_reset_in]

#vcu_connections
connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M01_AXI] -boundary_type upper [get_bd_intf_pins VCU_hier/S00_AXI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins VCU_hier/M00_INI] [get_bd_intf_pins /NoC_C0_C1/S05_INI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins VCU_hier/M01_INI] [get_bd_intf_pins /NoC_C0_C1/S06_INI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins VCU_hier/M02_INI] [get_bd_intf_pins /NoC_C0_C1/S07_INI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins VCU_hier/M03_INI] [get_bd_intf_pins /NoC_C0_C1/S08_INI]
# vcu2_ss connection
connect_bd_net [get_bd_pins VCU_hier/s_axi_aclk] [get_bd_pins ps_wizard_0/pl0_ref_clk]
connect_bd_net [get_bd_pins VCU_hier/s_axi_aresetn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
connect_bd_net [get_bd_pins VCU_hier/dpll_ref_clk] [get_bd_pins ps_wizard_0/pl1_ref_clk] 
#VCU irq
connect_bd_net [get_bd_pins VCU_hier/c0_irq_error] [get_bd_pins ps_wizard_0/pl_fpd_irq0]
connect_bd_net [get_bd_pins VCU_hier/c0_irq_dec_pintreq] [get_bd_pins ps_wizard_0/pl_fpd_irq1]
connect_bd_net [get_bd_pins VCU_hier/c0_irq_enc_pintreq] [get_bd_pins ps_wizard_0/pl_fpd_irq2]

# Auto-assign addresses for any segment not already mapped by the CED.
assign_bd_address
assign_bd_address -export_to_file ${project_dir}/${design_nm}_address_segments.csv -force
regenerate_bd_layout
validate_bd_design
save_bd_design

# Constraints
add_files -fileset constrs_1 -norecurse $constrs_dir/
import_files -fileset constrs_1 $constrs_dir/


remove_files  $project_dir/${design_nm}.srcs/sources_1/imports/hdl/${bd_name}_wrapper.v
file delete -force $project_dir/${design_nm}.srcs/sources_1/imports/hdl/${bd_name}_wrapper.v
add_files -norecurse $source_dir/${::bd_name}_wrapper.v

# Stop here so the user can inspect / open the project in the GUI.
# Re-run with `edfify_bd --impl ...` (or re-source main.tcl with the
# impl block enabled) to run synthesis + implementation + write .xsa.

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

# Get jobs from argument or calculate from nproc
if {[info exists ::jobs]} {
    set num_jobs $::jobs
} else {
    # Default to nproc - 2, with max of 32
    set nproc [exec nproc]
    set num_jobs [expr {$nproc - 2}]
    if {$num_jobs < 1} {
        set num_jobs 1
    }
}
# Cap at maximum of 32 jobs
if {$num_jobs > 32} {
    set num_jobs 32
}
puts "INFO: Using $num_jobs parallel jobs"

# Run Synthesis
puts "INFO: Starting Synthesis..."
launch_runs synth_1 -jobs $num_jobs
wait_on_run synth_1
puts "INFO: Synthesis completed. Status: [get_property STATUS [get_runs synth_1]]"

# Check synthesis status
if {[get_property STATUS [get_runs synth_1]] != "synth_design Complete!"} {
    puts "ERROR: Synthesis failed!"
    exit 1
}

# Run Implementation
puts "INFO: Starting Implementation..."
set_property strategy Performance_Explore [get_runs impl_1]
launch_runs impl_1 -jobs $num_jobs
wait_on_run impl_1
puts "INFO: Implementation completed. Status: [get_property STATUS [get_runs impl_1]]"

# Generate Device Image (Bitstream)
puts "INFO: Generating Device Image..."
launch_runs impl_1 -to_step write_device_image -jobs $num_jobs
wait_on_run impl_1

puts "INFO: Design Timing WNS:[get_property STATS.WNS [get_runs impl_1]]; TNS:[get_property STATS.TNS [get_runs impl_1]]; WHS:[get_property STATS.WHS [get_runs impl_1]]; THS:[get_property STATS.THS [get_runs impl_1]]; TPWS:[get_property STATS.TPWS [get_runs impl_1]]"
write_hw_platform -fixed -force -include_bit -file $project_dir/${design_nm}.xsa
close_project
exit
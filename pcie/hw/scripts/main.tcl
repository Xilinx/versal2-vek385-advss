# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
###############################################################
# Parse command line arguments
set ::jobs 8
for {set i 0} {$i < [llength $::argv]} {incr i} {
    set arg [lindex $::argv $i]
    if {$arg == "-jobs"} {
        incr i
        set ::jobs [lindex $::argv $i]
    }
}

set design_nm "pcie"
set project_dir "runs/${design_nm}"
set ip_dir "ip"
set constrs_dir "xdc"
set scripts_dir "scripts"
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

#source update for ISP_hier
source $scripts_dir/update_ISP_hier.tcl

#source new hier pl_pcie
source $scripts_dir/pl_pcie.tcl
create_hier_cell_pl_pcie / pl_pcie

create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_0
create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smt_ctrl
set_property -dict [list \
  CONFIG.NUM_MI {1} \
  CONFIG.NUM_SI {1} \
] [get_bd_cells smt_ctrl]
create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_0
set_property -dict [list \
  CONFIG.NUM_MI {1} \
  CONFIG.NUM_SI {1} \
] [get_bd_cells smartconnect_0]

create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:mipi_phy_rtl:1.0 MIPI1
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_refclk_0
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 pcie_mgt_0
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 IIC_0
create_bd_port -dir I -type rst sys_reset_0

set_property -dict [list CONFIG.CONNECTIONS {M07_INI {read_bw {100} write_bw {100} initial_boot {true}} M08_INI {read_bw {100} write_bw {100} initial_boot {true}} M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}} M00_INI {read_bw {500} write_bw {500} initial_boot {true}} M09_INI {read_bw {100} write_bw {100} initial_boot {true}} M10_INI {read_bw {100} write_bw {100} initial_boot {true}}}] [get_bd_intf_pins /Master_NoC/S00_AXI]
set_property -dict [list CONFIG.CONNECTIONS {M07_INI {read_bw {100} write_bw {100} initial_boot {true}} M08_INI {read_bw {100} write_bw {100} initial_boot {true}} M01_INI {read_bw {500} write_bw {500} initial_boot {true}} M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}} M09_INI {read_bw {100} write_bw {100} initial_boot {true}} M10_INI {read_bw {100} write_bw {100} initial_boot {true}}}] [get_bd_intf_pins /Master_NoC/S01_AXI]
set_property -dict [list CONFIG.CONNECTIONS {M02_INI {read_bw {500} write_bw {500} initial_boot {true}} M07_INI {read_bw {100} write_bw {100} initial_boot {true}} M08_INI {read_bw {100} write_bw {100} initial_boot {true}} M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}} M09_INI {read_bw {100} write_bw {100} initial_boot {true}} M10_INI {read_bw {100} write_bw {100} initial_boot {true}}}] [get_bd_intf_pins /Master_NoC/S02_AXI]
set_property -dict [list CONFIG.CONNECTIONS {M07_INI {read_bw {100} write_bw {100} initial_boot {true}} M08_INI {read_bw {100} write_bw {100} initial_boot {true}} M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M03_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}} M09_INI {read_bw {100} write_bw {100} initial_boot {true}} M10_INI {read_bw {100} write_bw {100} initial_boot {true}}}] [get_bd_intf_pins /Master_NoC/S03_AXI]
set_property -dict [list CONFIG.CONNECTIONS {M07_INI {read_bw {100} write_bw {100} initial_boot {true}} M08_INI {read_bw {100} write_bw {100} initial_boot {true}} M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}} M00_INI {read_bw {500} write_bw {500} initial_boot {true}} M09_INI {read_bw {100} write_bw {100} initial_boot {true}} M10_INI {read_bw {100} write_bw {100} initial_boot {true}}}] [get_bd_intf_pins /Master_NoC/S04_AXI]
set_property -dict [list CONFIG.CONNECTIONS {M07_INI {read_bw {100} write_bw {100} initial_boot {true}} M08_INI {read_bw {100} write_bw {100} initial_boot {true}} M01_INI {read_bw {500} write_bw {500} initial_boot {true}} M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}} M09_INI {read_bw {100} write_bw {100} initial_boot {true}} M10_INI {read_bw {100} write_bw {100} initial_boot {true}}}] [get_bd_intf_pins /Master_NoC/S05_AXI]
set_property -dict [list CONFIG.CONNECTIONS {M02_INI {read_bw {500} write_bw {500} initial_boot {true}} M07_INI {read_bw {100} write_bw {100} initial_boot {true}} M08_INI {read_bw {100} write_bw {100} initial_boot {true}} M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}} M09_INI {read_bw {100} write_bw {100} initial_boot {true}} M10_INI {read_bw {100} write_bw {100} initial_boot {true}}}] [get_bd_intf_pins /Master_NoC/S06_AXI]
set_property -dict [list CONFIG.CONNECTIONS {M07_INI {read_bw {100} write_bw {100} initial_boot {true}} M08_INI {read_bw {100} write_bw {100} initial_boot {true}} M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M03_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}} M09_INI {read_bw {100} write_bw {100} initial_boot {true}} M10_INI {read_bw {100} write_bw {100} initial_boot {true}}}] [get_bd_intf_pins /Master_NoC/S07_AXI]
set_property -dict [list CONFIG.CONNECTIONS {M07_INI {read_bw {100} write_bw {100} initial_boot {true}} M08_INI {read_bw {100} write_bw {100} initial_boot {true}} M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}} M00_INI {read_bw {500} write_bw {500} initial_boot {true}} M09_INI {read_bw {100} write_bw {100} initial_boot {true}} M10_INI {read_bw {100} write_bw {100} initial_boot {true}}}] [get_bd_intf_pins /Master_NoC/S08_AXI]
set_property -dict [list CONFIG.CONNECTIONS {M07_INI {read_bw {100} write_bw {100} initial_boot {true}} M08_INI {read_bw {100} write_bw {100} initial_boot {true}} M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}} M00_INI {read_bw {500} write_bw {500} initial_boot {true}} M09_INI {read_bw {100} write_bw {100} initial_boot {true}} M10_INI {read_bw {100} write_bw {100} initial_boot {true}}}] [get_bd_intf_pins /Master_NoC/S09_AXI]
set_property -dict [list CONFIG.CONNECTIONS {M07_INI {read_bw {500} write_bw {500} initial_boot {true}} M08_INI {read_bw {500} write_bw {500} initial_boot {true}} M06_INI {read_bw {500} write_bw {500} initial_boot {true}} M04_INI {read_bw {500} write_bw {500} initial_boot {true}} M05_INI {read_bw {500} write_bw {500} initial_boot {true}} M00_INI {read_bw {500} write_bw {500} initial_boot {true}} M09_INI {read_bw {500} write_bw {500} initial_boot {true}} M10_INI {read_bw {500} write_bw {500} initial_boot {true}}}] [get_bd_intf_pins /Master_NoC/S10_AXI]
set_property -dict [list \
  CONFIG.NUM_NSI {7} \
] [get_bd_cells NoC_C0_C1]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C0_C1/S05_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C0_C1/S06_INI]
set_property -dict [list \
  CONFIG.NUM_NSI {4} \
] [get_bd_cells NoC_C2_C3]
set_property -dict [list CONFIG.CONNECTIONS {MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C2_C3/S03_INI]
set_property -dict [list \
  CONFIG.NUM_NSI {4} \
] [get_bd_cells NoC_C4]
set_property -dict [list CONFIG.CONNECTIONS {MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C4/S03_INI]

connect_bd_intf_net [get_bd_intf_ports IIC_0] [get_bd_intf_pins ISP_hier/IIC_0]
connect_bd_intf_net [get_bd_intf_pins NoC_C0_C1/S05_INI] [get_bd_intf_pins ISP_hier/M00_INI]
connect_bd_intf_net [get_bd_intf_ports MIPI1] [get_bd_intf_pins ISP_hier/MIPI1]
connect_bd_intf_net [get_bd_intf_ports pcie_refclk_0] [get_bd_intf_pins pl_pcie/pcie_refclk]
connect_bd_intf_net [get_bd_intf_pins pl_pcie/M00_INI] [get_bd_intf_pins NoC_C2_C3/S03_INI]
connect_bd_intf_net [get_bd_intf_pins pl_pcie/M01_INI] [get_bd_intf_pins NoC_C4/S03_INI]
connect_bd_intf_net [get_bd_intf_pins pl_pcie/M02_INI] [get_bd_intf_pins NoC_C0_C1/S06_INI]
connect_bd_intf_net [get_bd_intf_ports pcie_mgt_0] [get_bd_intf_pins pl_pcie/pcie_mgt]
connect_bd_intf_net [get_bd_intf_pins smartconnect_0/S00_AXI] [get_bd_intf_pins ps_wizard_0/FPD_AXI_PL]
connect_bd_intf_net [get_bd_intf_pins ps_wizard_0/LPD_AXI_PL] [get_bd_intf_pins smt_ctrl/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins pl_pcie/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins smt_ctrl/M00_AXI] [get_bd_intf_pins ISP_hier/S_AXI_LITE]

disconnect_bd_net /ilconstant_1_dout [get_bd_pins ps_wizard_0/fpd_axi_pl_aclk]
disconnect_bd_net /ilconstant_1_dout [get_bd_pins ps_wizard_0/lpd_axi_pl_aclk]
connect_bd_net -net ISP_hier_csirxss_csi_irq [get_bd_pins ISP_hier/csirxss_csi_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq21]
connect_bd_net -net ISP_hier_iic2intc_irpt [get_bd_pins ISP_hier/iic2intc_irpt] [get_bd_pins ps_wizard_0/pl_lpd_irq20]
connect_bd_net -net ISP_hier_tile0_isp0_fusa_irq [get_bd_pins ISP_hier/tile0_isp0_fusa_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq2]
connect_bd_net -net ISP_hier_tile0_isp0_isp_irq [get_bd_pins ISP_hier/tile0_isp0_isp_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq3]
connect_bd_net -net ISP_hier_tile0_isp_isr_irq [get_bd_pins ISP_hier/tile0_isp_isr_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq0]
connect_bd_net -net ISP_hier_tile0_isp_xmpu_interrupt [get_bd_pins ISP_hier/tile0_isp_xmpu_interrupt] [get_bd_pins ps_wizard_0/pl_lpd_irq1]
connect_bd_net -net pl_pcie_irq [get_bd_pins pl_pcie/irq] [get_bd_pins ps_wizard_0/pl_fpd_irq0]
connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins ISP_hier/lite_aresetn] [get_bd_pins pl_pcie/aresetn] [get_bd_pins smt_ctrl/aresetn] [get_bd_pins smartconnect_0/aresetn]
connect_bd_net -net ps_wizard_0_pl0_ref_clk [get_bd_pins ps_wizard_0/pl0_ref_clk] [get_bd_pins ISP_hier/s_axi_aclk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins ps_wizard_0/fpd_axi_pl_aclk] [get_bd_pins ps_wizard_0/lpd_axi_pl_aclk] [get_bd_pins pl_pcie/aclk] [get_bd_pins smt_ctrl/aclk] [get_bd_pins smartconnect_0/aclk]
connect_bd_net -net ps_wizard_0_pl0_resetn [get_bd_pins ps_wizard_0/pl0_resetn] [get_bd_pins ISP_hier/ext_reset_in] [get_bd_pins proc_sys_reset_0/ext_reset_in]
connect_bd_net -net ps_wizard_0_pl1_ref_clk [get_bd_pins ps_wizard_0/pl1_ref_clk] [get_bd_pins ISP_hier/tile0_pl_isp_vidin0_clk]
connect_bd_net -net sys_reset_0_1 [get_bd_ports sys_reset_0] [get_bd_pins pl_pcie/sys_reset]

# Auto-assign addresses for any segment not already mapped by the CED.
assign_bd_address -target_address_space /ps_wizard_0/ps11_0_cortexr52_0 [get_bd_addr_segs ISP_hier/axi_iic_0/S_AXI/Reg] -force
assign_bd_address -target_address_space /ps_wizard_0/ps11_0_cortexr52_1 [get_bd_addr_segs ISP_hier/axi_iic_0/S_AXI/Reg] -force
assign_bd_address -target_address_space /ps_wizard_0/ps11_0_cortexr52_2 [get_bd_addr_segs ISP_hier/axi_iic_0/S_AXI/Reg] -force
assign_bd_address -target_address_space /ps_wizard_0/ps11_0_cortexr52_3 [get_bd_addr_segs ISP_hier/axi_iic_0/S_AXI/Reg] -force
assign_bd_address -target_address_space /ps_wizard_0/ps11_0_cortexr52_4 [get_bd_addr_segs ISP_hier/axi_iic_0/S_AXI/Reg] -force
assign_bd_address -target_address_space /ps_wizard_0/ps11_0_cortexr52_5 [get_bd_addr_segs ISP_hier/axi_iic_0/S_AXI/Reg] -force
assign_bd_address -target_address_space /ps_wizard_0/ps11_0_cortexr52_6 [get_bd_addr_segs ISP_hier/axi_iic_0/S_AXI/Reg] -force
assign_bd_address -target_address_space /ps_wizard_0/ps11_0_cortexr52_7 [get_bd_addr_segs ISP_hier/axi_iic_0/S_AXI/Reg] -force
assign_bd_address -target_address_space /ps_wizard_0/ps11_0_cortexr52_8 [get_bd_addr_segs ISP_hier/axi_iic_0/S_AXI/Reg] -force
assign_bd_address -target_address_space /ps_wizard_0/ps11_0_cortexr52_9 [get_bd_addr_segs ISP_hier/axi_iic_0/S_AXI/Reg] -force
assign_bd_address -target_address_space /ps_wizard_0/ps11_0_dma_pmc_0 [get_bd_addr_segs ISP_hier/axi_iic_0/S_AXI/Reg] -force
assign_bd_address -target_address_space /ps_wizard_0/ps11_0_dma_pmc_1 [get_bd_addr_segs ISP_hier/axi_iic_0/S_AXI/Reg] -force
assign_bd_address -target_address_space /ps_wizard_0/ps11_0_dpc [get_bd_addr_segs ISP_hier/axi_iic_0/S_AXI/Reg] -force
assign_bd_address -target_address_space /ps_wizard_0/ps11_0_pmc_0 [get_bd_addr_segs ISP_hier/axi_iic_0/S_AXI/Reg] -force
assign_bd_address -target_address_space /ps_wizard_0/ps11_0_lpd_dma_0 [get_bd_addr_segs ISP_hier/axi_iic_0/S_AXI/Reg] -force

assign_bd_address
assign_bd_address -export_to_file $project_dir/addresses.csv

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

set fd [open $project_dir/README.hw w]
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

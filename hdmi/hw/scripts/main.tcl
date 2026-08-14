# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------
# -----------------------------------------------
# ==============================================================================
# FILE:    scripts/main.tcl
# PROJECT: VEK385 HDMI hardware platform
# ROLE:    Vivado batch script — build BD (HDMI subsystem + VCU), run
#          synth/impl/device_image, emit XSA. cwd MUST be hdmi/hw (paths relative).
#
# INVOCATION from Makefile:
#   make xsa [JOBS=<n>]         # runs: vivado -mode batch -source scripts/main.tcl -tclargs -jobs <n>
#   make sdt                    # runs scripts/gen_sdt.tcl on the XSA.
#
# OUTPUTS (under runs/hdmi/):
#   hdmi.xsa, Vivado project tree, sdt_out
#   hdmi_address_segments.csv; hw/README.hw (IP inventory); vivado.log/.jou.
#
# Associated scripts/files (edit for design changes):
#   scripts/hdmi_ss.tcl         - HDMI hierarchical tcl
#   scripts/update_VCU_hier.tcl - VCU hierarchical tcl updates
#   scripts/gen_sdt.tcl         - SDT generation (make sdt)
#   xdc/                        - constraints
#
# BD TOPOLOGY:
#   edf_base (CED) + hdmi_ss + VCU_hier;
#   ctrl_smc -> AXI-Lite control via PS FPD_AXI_PL.
# ==============================================================================

# --- SECTION: CLI arguments (Makefile tclargs) --------------------------------
# Supported: -jobs <int>  — parallel jobs for synth/impl (see num_jobs below).
# Add new flags here and document in the header above.
set ::jobs 8
for {set i 0} {$i < [llength $::argv]} {incr i} {
    set arg [lindex $::argv $i]
    if {$arg == "-jobs"} {
        incr i
        set ::jobs [lindex $::argv $i]
    }
}

# --- SECTION: Project identity and paths --------------------------------------
set design_nm "hdmi"
set project_dir "runs/${design_nm}"
set ip_dir "ip"
set constrs_dir "xdc"
set scripts_dir "./scripts"
set bd_name "edf_base"

# --- SECTION: Device and board (change for different silicon/board) -----------
set part xc2ve3858-ssva2112-2MP-e-S

# --- SECTION: Vivado project creation -----------------------------------------
# Project is recreated with -force; prior runs/hdmi is overwritten.
create_project $design_nm $project_dir -part  $part -force
set_property board_part xilinx.com:vek385_1:part0:1.0 [current_project]

# --- SECTION: Block design shell ----------------------------------------------
create_bd_design $bd_name

# --- SECTION: CED base platform -----------------------------------------------
# Template: Embedded Design Framework (EDF) base preset on VEK385.
instantiate_example_design -template xilinx.com:design:edf_base:1.0  -design $bd_name

# --- SECTION: Custom IP repository --------------------------------------------
set_property  ip_repo_paths $ip_dir [current_project]
update_ip_catalog

# --- SECTION: Hierarchical VCU subsystem --------------------------------------
# Proc update_VCU_hier is defined in update_VCU_hier.tcl.
source $scripts_dir/update_VCU_hier.tcl

# --- SECTION: Hierarchical HDMI subsystem -------------------------------------
# Proc create_hier_cell_hdmi_ss is defined in hdmi_ss.tcl.
source $scripts_dir/hdmi_ss.tcl
create_hier_cell_hdmi_ss / hdmi_ss

# --- SECTION: CIPS (PS) configuration -----------------------------------------
# Extensions over CED base: Enable PL interrupts for HDMI and VCU subsystems
#   - FPD interrupts: 3 channels (VCU encoder/decoder/error)
#   - LPD interrupts: 8 channels (HDMI TX/RX, video framebuffer, IIC, timers)
set_property -dict [list \
  CONFIG.PS11_CONFIG(PL_FPD_IRQ_USAGE) {CH0 1 CH1 1 CH2 1 CH3 0 CH4 0 CH5 0 CH6 0 CH7 0} \
  CONFIG.PS11_CONFIG(PL_LPD_IRQ_USAGE) {CH0 1 CH1 1 CH2 1 CH3 1 CH4 1 CH5 1 CH6 1 CH7 1 CH8 0 CH9 0 CH10 0 CH11 0 CH12 0 CH13 0 CH14 0 CH15 0 CH16 0 CH17 0 CH18 0 CH19 0 CH20 0 CH21 0 CH22 0 CH23 0}
] [get_bd_cells ps_wizard_0]

# --- SECTION: Control SmartConnect — AXI-Lite (from PS to PL IPs) ------------
# Extensions over CED base: Add SmartConnect for PS control path to HDMI/VCU
#   - 1 slave from PS (FPD_AXI_PL), 2 masters to HDMI and VCU hierarchies
create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 ctrl_smc
set_property -dict [list \
  CONFIG.NUM_CLKS {2} \
  CONFIG.NUM_MI {2} \
  CONFIG.NUM_SI {1} \
] [get_bd_cells ctrl_smc]

# --- SECTION: Resets and clock domain hooks -----------------------------------
# rst_clk: 100 MHz AXI-Lite / control domain reset
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_clk

# --- SECTION: Clocking (clk_wizard_0) -----------------------------------------
# clk_100:  AXI-Lite / control domain
# clk_300:  AXI-Stream video domain
# clk_450:  FRL (Fixed Rate Link) clock for HDMI
create_bd_cell -type ip -vlnv xilinx.com:ip:clkx5_wiz:1.0 clk_wizard_0
set_property -dict [list \
  CONFIG.CLKOUT_DRIVES {BUFG,BUFG,BUFG,BUFG,BUFG,BUFG,BUFG} \
  CONFIG.CLKOUT_DYN_PS {None,None,None,None,None,None,None} \
  CONFIG.CLKOUT_GROUPING {Auto,Auto,Auto,Auto,Auto,Auto,Auto} \
  CONFIG.CLKOUT_MATCHED_ROUTING {false,false,false,false,false,false,false} \
  CONFIG.CLKOUT_PORT {clk_100,clk_300,clk_450,clk_out4,clk_out5,clk_out6,clk_out7} \
  CONFIG.CLKOUT_REQUESTED_DUTY_CYCLE {50.000,50.000,50.000,50.000,50.000,50.000,50.000} \
  CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {100,300,450.000,100.000,100.000,100.000,100.000} \
  CONFIG.CLKOUT_REQUESTED_PHASE {0.000,0.000,0.000,0.000,0.000,0.000,0.000} \
  CONFIG.CLKOUT_USED {true,true,true,false,false,false,false} \
  CONFIG.PRIM_SOURCE {No_buffer} \
  CONFIG.RESET_TYPE {ACTIVE_LOW} \
  CONFIG.USE_LOCKED {true} \
  CONFIG.USE_PHASE_ALIGNMENT {true} \
  CONFIG.USE_RESET {true} \
] [get_bd_cells clk_wizard_0]

# proc_sys_reset_300M: 300 MHz video AXIS domain reset
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_300M

# --- SECTION: Top-level board interfaces (VEK385 HDMI pins) ------------------
# Create BD ports for HDMI subsystem external connections.
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 GT_DRU_FRL_CLK_IN
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 TX_REFCLK_P_IN_V
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 HDMI_RX_CLK_P_IN_V
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 GT_Serial
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 RX_DDC_OUT
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 HDMI_CTRL
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 TX_DDC_OUT
create_bd_port -dir I RX_DET_N_n
create_bd_port -dir I TX_HPD_IN
create_bd_port -dir I IDT8T49N241_LOL_IN
create_bd_port -dir O -from 0 -to 0 RX_HPD_OUT
create_bd_port -dir O -type clk RX_REFCLK_P_OUT
create_bd_port -dir O -type clk RX_REFCLK_N_OUT
create_bd_port -dir O -from 0 -to 0 TX_TI_ENABLE
create_bd_port -dir O LED0
create_bd_port -dir O -from 0 -to 0 RX_TI_ENABLE

# --- SECTION: NoC Master_NoC — AXI to INI protocol translation ---------------
# Extensions over CED base: Configure QoS for AXI-to-INI NoC paths
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

# --- SECTION: NoC_C0_C1 — DDR Memory Controller 0 (MC_0) ----------------------
# Extensions over CED base: Add 6 INI slave ports for VCU and HDMI DDR access
#   - VCU: 4 ports (S05-S08) for encoder/decoder memory traffic
#   - HDMI: 2 ports (S09-S10) for framebuffer read/write
set_property -dict [list \
  CONFIG.NUM_NSI {11} \
] [get_bd_cells NoC_C0_C1]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false}}}] [get_bd_intf_pins /NoC_C0_C1/S05_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false}}}] [get_bd_intf_pins /NoC_C0_C1/S06_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false}}}] [get_bd_intf_pins /NoC_C0_C1/S07_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false}}}] [get_bd_intf_pins /NoC_C0_C1/S08_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false}}}] [get_bd_intf_pins /NoC_C0_C1/S09_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false}}}] [get_bd_intf_pins /NoC_C0_C1/S10_INI]

# --- SECTION: NoC_C2_C3 — DDR Memory Controller 1 (MC_1) ----------------------
# Extensions over CED base: Add 2 INI slave ports for HDMI framebuffer access
#   - HDMI: 2 ports (S03-S04) for additional framebuffer bandwidth
set_property -dict [list \
  CONFIG.NUM_NSI {5} \
] [get_bd_cells NoC_C2_C3]
set_property -dict [list CONFIG.CONNECTIONS {MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C2_C3/S03_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_1 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C2_C3/S04_INI]

# --- SECTION: Connectivity — HDMI/VCU subsystems to CED base ----------------
# AXI-Lite control: PS -> ctrl_smc -> {hdmi_ss, VCU_hier}
connect_bd_intf_net [get_bd_intf_pins ps_wizard_0/FPD_AXI_PL] [get_bd_intf_pins ctrl_smc/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins ctrl_smc/M00_AXI] [get_bd_intf_pins hdmi_ss/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins ctrl_smc/M01_AXI] [get_bd_intf_pins VCU_hier/S00_AXI]

# NoC memory: VCU and HDMI framebuffer masters -> DDR controllers
connect_bd_intf_net [get_bd_intf_pins VCU_hier/M00_INI] [get_bd_intf_pins NoC_C0_C1/S05_INI]
connect_bd_intf_net [get_bd_intf_pins VCU_hier/M01_INI] [get_bd_intf_pins NoC_C0_C1/S06_INI]
connect_bd_intf_net [get_bd_intf_pins VCU_hier/M02_INI] [get_bd_intf_pins NoC_C0_C1/S07_INI]
connect_bd_intf_net [get_bd_intf_pins VCU_hier/M03_INI] [get_bd_intf_pins NoC_C0_C1/S08_INI]
connect_bd_intf_net [get_bd_intf_pins hdmi_ss/M00_INI] [get_bd_intf_pins NoC_C0_C1/S09_INI]
connect_bd_intf_net [get_bd_intf_pins hdmi_ss/M01_INI] [get_bd_intf_pins NoC_C0_C1/S10_INI]
connect_bd_intf_net [get_bd_intf_pins hdmi_ss/M02_INI] [get_bd_intf_pins NoC_C2_C3/S03_INI]
connect_bd_intf_net [get_bd_intf_pins hdmi_ss/M03_INI] [get_bd_intf_pins NoC_C2_C3/S04_INI]

# Board interfaces: HDMI external pins
connect_bd_intf_net [get_bd_intf_ports GT_DRU_FRL_CLK_IN] [get_bd_intf_pins hdmi_ss/GT_DRU_FRL_CLK_IN]
connect_bd_intf_net [get_bd_intf_ports HDMI_RX_CLK_P_IN_V] [get_bd_intf_pins hdmi_ss/HDMI_RX_CLK_P_IN_V]
connect_bd_intf_net [get_bd_intf_ports TX_REFCLK_P_IN_V] [get_bd_intf_pins hdmi_ss/TX_REFCLK_P_IN_V]
connect_bd_intf_net [get_bd_intf_ports GT_Serial] [get_bd_intf_pins hdmi_ss/GT_Serial]
connect_bd_intf_net [get_bd_intf_ports HDMI_CTRL] [get_bd_intf_pins hdmi_ss/HDMI_CTRL]
connect_bd_intf_net [get_bd_intf_ports RX_DDC_OUT] [get_bd_intf_pins hdmi_ss/RX_DDC_OUT]
connect_bd_intf_net [get_bd_intf_ports TX_DDC_OUT] [get_bd_intf_pins hdmi_ss/TX_DDC_OUT]

# Interrupts: VCU (FPD) and HDMI (LPD) to PS
disconnect_bd_net /ilconstant_1_dout [get_bd_pins ps_wizard_0/fpd_axi_pl_aclk]
connect_bd_net [get_bd_pins VCU_hier/c0_irq_error] [get_bd_pins ps_wizard_0/pl_fpd_irq0]
connect_bd_net [get_bd_pins VCU_hier/c0_irq_dec_pintreq] [get_bd_pins ps_wizard_0/pl_fpd_irq1]
connect_bd_net [get_bd_pins VCU_hier/c0_irq_enc_pintreq] [get_bd_pins ps_wizard_0/pl_fpd_irq2]
connect_bd_net [get_bd_pins hdmi_ss/irq_iic_ctrl] [get_bd_pins ps_wizard_0/pl_lpd_irq0]
connect_bd_net [get_bd_pins hdmi_ss/irq_vphy] [get_bd_pins ps_wizard_0/pl_lpd_irq1]
connect_bd_net [get_bd_pins hdmi_ss/irq_rx] [get_bd_pins ps_wizard_0/pl_lpd_irq2]
connect_bd_net [get_bd_pins hdmi_ss/fb_wr_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq3]
connect_bd_net [get_bd_pins hdmi_ss/fb_rd_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq4]
connect_bd_net [get_bd_pins hdmi_ss/irq_tx] [get_bd_pins ps_wizard_0/pl_lpd_irq5]
connect_bd_net [get_bd_pins hdmi_ss/irq_timer0] [get_bd_pins ps_wizard_0/pl_lpd_irq6]
connect_bd_net [get_bd_pins hdmi_ss/irq_timer1] [get_bd_pins ps_wizard_0/pl_lpd_irq7]

# Clocks and resets
connect_bd_net [get_bd_pins ps_wizard_0/pl0_ref_clk] [get_bd_pins clk_wizard_0/clk_in1]
connect_bd_net [get_bd_pins clk_wizard_0/clk_100] [get_bd_pins ps_wizard_0/fpd_axi_pl_aclk] [get_bd_pins ctrl_smc/aclk] [get_bd_pins rst_clk/slowest_sync_clk] [get_bd_pins hdmi_ss/s_axi_cpu_aclk] [get_bd_pins VCU_hier/s_axi_aclk]
connect_bd_net [get_bd_pins clk_wizard_0/clk_300] [get_bd_pins ctrl_smc/aclk1] [get_bd_pins proc_sys_reset_300M/slowest_sync_clk] [get_bd_pins hdmi_ss/s_axis_video_aclk]
connect_bd_net [get_bd_pins clk_wizard_0/clk_450] [get_bd_pins hdmi_ss/frl_clk]
connect_bd_net [get_bd_pins ps_wizard_0/pl1_ref_clk] [get_bd_pins VCU_hier/dpll_ref_clk]
connect_bd_net [get_bd_pins clk_wizard_0/locked] [get_bd_pins rst_clk/dcm_locked] [get_bd_pins proc_sys_reset_300M/dcm_locked]
connect_bd_net [get_bd_pins ps_wizard_0/pl0_resetn] [get_bd_pins clk_wizard_0/resetn] [get_bd_pins rst_clk/ext_reset_in] [get_bd_pins proc_sys_reset_300M/ext_reset_in]
connect_bd_net [get_bd_pins rst_clk/interconnect_aresetn] [get_bd_pins ctrl_smc/aresetn]
connect_bd_net [get_bd_pins rst_clk/peripheral_aresetn] [get_bd_pins hdmi_ss/s_axi_cpu_aresetn] [get_bd_pins VCU_hier/s_axi_aresetn]
connect_bd_net [get_bd_pins proc_sys_reset_300M/peripheral_aresetn] [get_bd_pins hdmi_ss/s_axis_video_aresetn]

# HDMI board signals
connect_bd_net [get_bd_ports IDT8T49N241_LOL_IN] [get_bd_pins hdmi_ss/IDT8T49N241_LOL_IN]
connect_bd_net [get_bd_ports RX_DET_N_n] [get_bd_pins hdmi_ss/RX_DET_N_n]
connect_bd_net [get_bd_ports TX_HPD_IN] [get_bd_pins hdmi_ss/TX_HPD_IN]
connect_bd_net [get_bd_pins hdmi_ss/LED0] [get_bd_ports LED0]
connect_bd_net [get_bd_pins hdmi_ss/RX_HPD_OUT] [get_bd_ports RX_HPD_OUT]
connect_bd_net [get_bd_pins hdmi_ss/RX_REFCLK_N_OUT] [get_bd_ports RX_REFCLK_N_OUT]
connect_bd_net [get_bd_pins hdmi_ss/RX_REFCLK_P_OUT] [get_bd_ports RX_REFCLK_P_OUT]
connect_bd_net [get_bd_pins hdmi_ss/TX_TI_ENABLE] [get_bd_ports TX_TI_ENABLE] [get_bd_ports RX_TI_ENABLE]

# --- SECTION: BD finalize (addresses, validate, save) -------------------------
set_property HDL_ATTRIBUTE.DONT_TOUCH {true} [get_bd_intf_nets ps_wizard_0_FPD_AXI_PL]

# Auto-assign addresses.
assign_bd_address
# BD address map for software / integration (tabular CSV next to README.hw).
assign_bd_address -export_to_file ${project_dir}/${design_nm}_address_segments.csv -force

regenerate_bd_layout
validate_bd_design
save_bd_design

# --- SECTION: Constraints -----------------------------------------------------
add_files -fileset constrs_1 -norecurse $constrs_dir/
import_files -fileset constrs_1 $constrs_dir/

# --- SECTION: HDL wrapper (top = ${bd_name}_wrapper) --------------------------
remove_files  $project_dir/${design_nm}.srcs/sources_1/imports/hdl/${bd_name}_wrapper.v
file delete -force $project_dir/${design_nm}.srcs/sources_1/imports/hdl/${bd_name}_wrapper.v
make_wrapper -files [get_files $project_dir/${design_nm}.srcs/sources_1/bd/${bd_name}/${bd_name}.bd] -top
add_files -norecurse $project_dir/${design_nm}.srcs/sources_1/bd/${bd_name}/hdl/${bd_name}_wrapper.v
update_compile_order -fileset sources_1

# --- SECTION: IP inventory (README.hw for software / docs) --------------------
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

# --- SECTION: Implementation and hardware platform export ---------------------
# Versal uses write_device_image instead of write_bitstream.
set_property strategy Performance_Explore [get_runs impl_1]

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

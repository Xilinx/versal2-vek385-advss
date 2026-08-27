# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------



# Parse command line arguments
set ::jobs 8
for {set i 0} {$i < [llength $::argv]} {incr i} {
    set arg [lindex $::argv $i]
    if {$arg == "-jobs"} {
        incr i
        set ::jobs [lindex $::argv $i]
    }
}

set design_nm "MMI_10G"
set project_dir "runs/${design_nm}"
set ip_dir "ip"
set constrs_dir "xdc"
set scripts_dir "./scripts"
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
  CONFIG.PS11_CONFIG(PL_FPD_IRQ_USAGE) {CH0 1 CH1 1 CH2 1 CH3 1 CH4 1 CH5 1 CH6 1 CH7 1} \
  CONFIG.PS11_CONFIG(PL_LPD_IRQ_USAGE) {CH0 1 CH1 1 CH2 1 CH3 1 CH4 1 CH5 1 CH6 1 CH7 1 CH8 1 CH9 1 CH10 1 CH11 1 CH12 0 CH13 0 CH14 0 CH15 0 CH16 0 CH17 0 CH18 1 CH19 0 CH20 1 CH21 1 CH22 1 CH23 1}
] [get_bd_cells ps_wizard_0]



#source update for VCU_hier
source $scripts_dir/update_VCU_hier.tcl

#source update for ISP_hier
source $scripts_dir/update_ISP_hier.tcl

#source new hier hdmi_tx_ss_hier
source $scripts_dir/hdmi_tx_ss_hier.tcl
create_hier_cell_hdmi_tx_ss_hier / hdmi_tx_ss_hier

create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_0
set_property -dict [list \
  CONFIG.NUM_CLKS {2} \
  CONFIG.NUM_MI {3} \
  CONFIG.NUM_SI {1} \
] [get_bd_cells smartconnect_0]
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_0
create_bd_cell -type ip -vlnv xilinx.com:ip:clkx5_wiz clkx5_wiz_0
set_property -dict [list \
  CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {300.000,150.000,200,100.000,100.000,100.000,100.000} \
  CONFIG.CLKOUT_USED {true,true,true,true,false,false,false} \
  CONFIG.RESET_TYPE {ACTIVE_LOW} \
  CONFIG.USE_LOCKED {true} \
  CONFIG.USE_RESET {true} \
] [get_bd_cells clkx5_wiz_0]
create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_2
set_property -dict [list \
  CONFIG.NUM_CLKS {1} \
  CONFIG.NUM_MI {2} \
  CONFIG.NUM_SI {1} \
] [get_bd_cells smartconnect_2]
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic axi_iic_0
set_property -dict [list \
  CONFIG.IIC_FREQ_KHZ {1000} \
] [get_bd_cells axi_iic_0]
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic axi_iic_1
set_property -dict [list \
  CONFIG.IIC_FREQ_KHZ {1000} \
] [get_bd_cells axi_iic_1]

create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:mipi_phy_rtl:1.0 MIPI1
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:mipi_phy_rtl:1.0 MIPI2
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 TX_DDC_OUT
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 HDMI_CTRL
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 GT_DRU_FRL_CLK_IN
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 TX_REFCLK_P_IN_V
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 GT_Serial
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 HDMI_RX_CLK_P_IN_V
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 FMC_IIC_2
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 FMC_IIC_3
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:mipi_phy_rtl:1.0 MIPI3
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:mipi_phy_rtl:1.0 MIPI4
create_bd_port -dir I IDT8T49N241_LOL_IN
create_bd_port -dir O -from 0 -to 0 TX_TI_ENABLE
create_bd_port -dir I TX_HPD_IN
create_bd_port -dir O -type clk RX_REFCLK_P_OUT
create_bd_port -dir O LED0
create_bd_port -dir O -type clk RX_REFCLK_N_OUT
create_bd_port -dir O -from 0 -to 0 RX_TI_ENABLE

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
  CONFIG.NUM_NSI {15} \
] [get_bd_cells NoC_C0_C1]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C0_C1/S05_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C0_C1/S06_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C0_C1/S07_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C0_C1/S08_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C0_C1/S09_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C0_C1/S10_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C0_C1/S11_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C0_C1/S12_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {false} }}] [get_bd_intf_pins /NoC_C0_C1/S13_INI]
set_property -dict [list CONFIG.CONNECTIONS {MC_0 {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4} initial_boot {true} }}] [get_bd_intf_pins /NoC_C0_C1/S14_INI]

connect_bd_intf_net [get_bd_intf_ports GT_DRU_FRL_CLK_IN] [get_bd_intf_pins hdmi_tx_ss_hier/GT_DRU_FRL_CLK_IN]
connect_bd_intf_net [get_bd_intf_ports HDMI_RX_CLK_P_IN_V] [get_bd_intf_pins hdmi_tx_ss_hier/HDMI_RX_CLK_P_IN_V]
connect_bd_intf_net [get_bd_intf_pins NoC_C0_C1/S05_INI] [get_bd_intf_pins ISP_hier/M00_INI]
connect_bd_intf_net [get_bd_intf_pins NoC_C0_C1/S10_INI] [get_bd_intf_pins ISP_hier/M00_INI1]
connect_bd_intf_net [get_bd_intf_ports TX_REFCLK_P_IN_V] [get_bd_intf_pins hdmi_tx_ss_hier/TX_REFCLK_P_IN_V]
connect_bd_intf_net [get_bd_intf_pins NoC_C0_C1/S11_INI] [get_bd_intf_pins VCU_hier/M00_INI]
connect_bd_intf_net [get_bd_intf_pins NoC_C0_C1/S12_INI] [get_bd_intf_pins VCU_hier/M01_INI]
connect_bd_intf_net [get_bd_intf_pins NoC_C0_C1/S13_INI] [get_bd_intf_pins VCU_hier/M02_INI]
connect_bd_intf_net [get_bd_intf_pins NoC_C0_C1/S14_INI] [get_bd_intf_pins VCU_hier/M03_INI]
connect_bd_intf_net [get_bd_intf_ports FMC_IIC_2] [get_bd_intf_pins axi_iic_0/IIC]
connect_bd_intf_net [get_bd_intf_ports FMC_IIC_3] [get_bd_intf_pins axi_iic_1/IIC]
connect_bd_intf_net [get_bd_intf_ports GT_Serial] [get_bd_intf_pins hdmi_tx_ss_hier/GT_Serial]
connect_bd_intf_net [get_bd_intf_ports HDMI_CTRL] [get_bd_intf_pins hdmi_tx_ss_hier/HDMI_CTRL]
connect_bd_intf_net [get_bd_intf_pins hdmi_tx_ss_hier/M00_INI] [get_bd_intf_pins NoC_C0_C1/S06_INI]
connect_bd_intf_net [get_bd_intf_pins hdmi_tx_ss_hier/M01_INI] [get_bd_intf_pins NoC_C0_C1/S07_INI]
connect_bd_intf_net [get_bd_intf_pins hdmi_tx_ss_hier/M02_INI] [get_bd_intf_pins NoC_C0_C1/S08_INI]
connect_bd_intf_net [get_bd_intf_pins hdmi_tx_ss_hier/M03_INI] [get_bd_intf_pins NoC_C0_C1/S09_INI]
connect_bd_intf_net [get_bd_intf_ports TX_DDC_OUT] [get_bd_intf_pins hdmi_tx_ss_hier/TX_DDC_OUT]
connect_bd_intf_net [get_bd_intf_ports MIPI1] [get_bd_intf_pins ISP_hier/mipi_phy_if_0]
connect_bd_intf_net [get_bd_intf_ports MIPI3] [get_bd_intf_pins ISP_hier/mipi_phy_if_2]
connect_bd_intf_net [get_bd_intf_ports MIPI4] [get_bd_intf_pins ISP_hier/mipi_phy_if_3]
connect_bd_intf_net [get_bd_intf_ports MIPI2] [get_bd_intf_pins ISP_hier/mipi_phy_if_1]
connect_bd_intf_net [get_bd_intf_pins smartconnect_0/S00_AXI] [get_bd_intf_pins ps_wizard_0/FPD_AXI_PL]
connect_bd_intf_net [get_bd_intf_pins ps_wizard_0/LPD_AXI_PL] [get_bd_intf_pins smartconnect_2/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins ISP_hier/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M01_AXI] [get_bd_intf_pins hdmi_tx_ss_hier/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M02_AXI] [get_bd_intf_pins VCU_hier/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins smartconnect_2/M00_AXI] [get_bd_intf_pins axi_iic_0/S_AXI]
connect_bd_intf_net [get_bd_intf_pins smartconnect_2/M01_AXI] [get_bd_intf_pins axi_iic_1/S_AXI]

disconnect_bd_net /ilconstant_1_dout [get_bd_pins ps_wizard_0/fpd_axi_pl_aclk]
disconnect_bd_net /ilconstant_1_dout [get_bd_pins ps_wizard_0/lpd_axi_pl_aclk]
connect_bd_net -net IDT8T49N241_LOL_IN_0_1 [get_bd_ports IDT8T49N241_LOL_IN] [get_bd_pins hdmi_tx_ss_hier/IDT8T49N241_LOL_IN]
connect_bd_net -net ISP_hier_irq [get_bd_pins ISP_hier/irq] [get_bd_pins ps_wizard_0/pl_lpd_irq21]
connect_bd_net -net ISP_hier_tile0_isp0_fusa_irq [get_bd_pins ISP_hier/tile0_isp0_fusa_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq2]
connect_bd_net -net ISP_hier_tile0_isp0_isp_irq [get_bd_pins ISP_hier/tile0_isp0_isp_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq3]
connect_bd_net -net ISP_hier_tile0_isp1_fusa_irq [get_bd_pins ISP_hier/tile0_isp1_fusa_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq4]
connect_bd_net -net ISP_hier_tile0_isp1_isp_irq [get_bd_pins ISP_hier/tile0_isp1_isp_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq5]
connect_bd_net -net ISP_hier_tile0_isp_isr_irq [get_bd_pins ISP_hier/tile0_isp_isr_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq0]
connect_bd_net -net ISP_hier_tile0_isp_xmpu_interrupt [get_bd_pins ISP_hier/tile0_isp_xmpu_interrupt] [get_bd_pins ps_wizard_0/pl_lpd_irq1]
connect_bd_net -net ISP_hier_tile1_isp0_fusa_irq [get_bd_pins ISP_hier/tile1_isp0_fusa_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq8]
connect_bd_net -net ISP_hier_tile1_isp0_isp_irq [get_bd_pins ISP_hier/tile1_isp0_isp_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq9]
connect_bd_net -net ISP_hier_tile1_isp1_fusa_irq [get_bd_pins ISP_hier/tile1_isp1_fusa_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq10]
connect_bd_net -net ISP_hier_tile1_isp1_isp_irq [get_bd_pins ISP_hier/tile1_isp1_isp_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq11]
connect_bd_net -net ISP_hier_tile1_isp_isr_irq [get_bd_pins ISP_hier/tile1_isp_isr_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq6]
connect_bd_net -net ISP_hier_tile1_isp_xmpu_interrupt [get_bd_pins ISP_hier/tile1_isp_xmpu_interrupt] [get_bd_pins ps_wizard_0/pl_lpd_irq7]
connect_bd_net -net TX_HPD_IN_0_1 [get_bd_ports TX_HPD_IN] [get_bd_pins hdmi_tx_ss_hier/TX_HPD_IN]
connect_bd_net -net VCU_hier_c0_irq_dec_pintreq [get_bd_pins VCU_hier/c0_irq_dec_pintreq] [get_bd_pins ps_wizard_0/pl_fpd_irq4]
connect_bd_net -net VCU_hier_c0_irq_enc_pintreq [get_bd_pins VCU_hier/c0_irq_enc_pintreq] [get_bd_pins ps_wizard_0/pl_fpd_irq3]
connect_bd_net -net VCU_hier_c0_irq_error [get_bd_pins VCU_hier/c0_irq_error] [get_bd_pins ps_wizard_0/pl_fpd_irq5]
connect_bd_net -net axi_iic_0_iic2intc_irpt [get_bd_pins axi_iic_0/iic2intc_irpt] [get_bd_pins ps_wizard_0/pl_lpd_irq20]
connect_bd_net -net axi_iic_1_iic2intc_irpt [get_bd_pins axi_iic_1/iic2intc_irpt] [get_bd_pins ps_wizard_0/pl_lpd_irq18]
connect_bd_net -net clkx5_wiz_0_clk_out2 [get_bd_pins clkx5_wiz_0/clk_out2] [get_bd_pins ISP_hier/video_aclk] [get_bd_pins smartconnect_0/aclk1]
connect_bd_net -net clkx5_wiz_0_clk_out3 [get_bd_pins clkx5_wiz_0/clk_out3] [get_bd_pins ISP_hier/dphy_clk_200M]
connect_bd_net -net clkx5_wiz_0_locked [get_bd_pins clkx5_wiz_0/locked] [get_bd_pins proc_sys_reset_0/dcm_locked]
connect_bd_net -net hdmi_tx_ss_hier_LED0 [get_bd_pins hdmi_tx_ss_hier/LED0] [get_bd_ports LED0]
connect_bd_net -net hdmi_tx_ss_hier_Mixer_irq [get_bd_pins hdmi_tx_ss_hier/Mixer_irq] [get_bd_pins ps_wizard_0/pl_fpd_irq2]
connect_bd_net -net hdmi_tx_ss_hier_RX_REFCLK_N_OUT [get_bd_pins hdmi_tx_ss_hier/RX_REFCLK_N_OUT] [get_bd_ports RX_REFCLK_N_OUT]
connect_bd_net -net hdmi_tx_ss_hier_RX_REFCLK_P_OUT [get_bd_pins hdmi_tx_ss_hier/RX_REFCLK_P_OUT] [get_bd_ports RX_REFCLK_P_OUT]
connect_bd_net -net hdmi_tx_ss_hier_TX_TI_ENABLE [get_bd_pins hdmi_tx_ss_hier/TX_TI_ENABLE] [get_bd_ports TX_TI_ENABLE] [get_bd_ports RX_TI_ENABLE]
connect_bd_net -net hdmi_tx_ss_hier_Timer_interrupt [get_bd_pins hdmi_tx_ss_hier/Timer_interrupt] [get_bd_pins ps_wizard_0/pl_lpd_irq22]
connect_bd_net -net hdmi_tx_ss_hier_hdmi_gt_irq [get_bd_pins hdmi_tx_ss_hier/hdmi_gt_irq] [get_bd_pins ps_wizard_0/pl_fpd_irq0]
connect_bd_net -net hdmi_tx_ss_hier_hdmi_txss_irq [get_bd_pins hdmi_tx_ss_hier/hdmi_txss_irq] [get_bd_pins ps_wizard_0/pl_lpd_irq23]
connect_bd_net -net hdmi_tx_ss_hier_iic2intc_irpt [get_bd_pins hdmi_tx_ss_hier/iic2intc_irpt] [get_bd_pins ps_wizard_0/pl_fpd_irq1]
connect_bd_net -net proc_sys_reset_0_interconnect_aresetn [get_bd_pins proc_sys_reset_0/interconnect_aresetn] [get_bd_pins smartconnect_2/aresetn] [get_bd_pins smartconnect_0/aresetn]
connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins axi_iic_0/s_axi_aresetn] [get_bd_pins axi_iic_1/s_axi_aresetn] [get_bd_pins VCU_hier/s_axi_lite_rst_n]
connect_bd_net -net ps_wizard_0_pl0_ref_clk [get_bd_pins clkx5_wiz_0/clk_out4] [get_bd_pins smartconnect_0/aclk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins ps_wizard_0/fpd_axi_pl_aclk] [get_bd_pins hdmi_tx_ss_hier/clk_in1] [get_bd_pins ps_wizard_0/lpd_axi_pl_aclk] [get_bd_pins smartconnect_2/aclk] [get_bd_pins axi_iic_0/s_axi_aclk] [get_bd_pins axi_iic_1/s_axi_aclk] [get_bd_pins VCU_hier/s_axi_lite_clk]
connect_bd_net -net ps_wizard_0_pl0_ref_clk1 [get_bd_pins ps_wizard_0/pl0_ref_clk] [get_bd_pins clkx5_wiz_0/clk_in1]
connect_bd_net -net ps_wizard_0_pl0_resetn [get_bd_pins ps_wizard_0/pl0_resetn] [get_bd_pins clkx5_wiz_0/resetn] [get_bd_pins ISP_hier/ext_reset_in] [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins hdmi_tx_ss_hier/Op1]
connect_bd_net -net tile0_ref_dpll_clk_1 [get_bd_pins ps_wizard_0/pl1_ref_clk] [get_bd_pins ISP_hier/tile0_ref_dpll_clk] [get_bd_pins VCU_hier/dpll_ref_clk]

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
set_property strategy {Vivado Advanced Implementation Defaults} [get_runs impl_1]
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
# Stop here so the user can inspect / open the project in the GUI.
# Re-run with `edfify_bd --impl ...` (or re-source main.tcl with the
# impl block enabled) to run synthesis + implementation + write .xsa.

# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------

# Script to configure the VCU hier

set_property -dict [list \
  CONFIG.C_TARGET_BOARD {1} \
  CONFIG.NSU_ONLY {false} \
  CONFIG.C0_ENC_SOURCE_FORMAT {1} \
] [get_bd_cells VCU_hier/vcu2_0]

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:* VCU_hier/vcu_gpio_reset
set_property -dict [list \
  CONFIG.C_ALL_OUTPUTS {1} \
  CONFIG.C_DOUT_DEFAULT {0x0000000F} \
  CONFIG.C_GPIO_WIDTH {4} \
] [get_bd_cells VCU_hier/vcu_gpio_reset]

create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:* VCU_hier/ilslice_vcu_enc_rst_n
create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:* VCU_hier/ilslice_vcu_dec_rst_n
create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:* VCU_hier/ilslice_vcu_raw_rst_n
create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:* VCU_hier/ilslice_vcu_dpll_rst_n

set_property CONFIG.DIN_WIDTH {4} [get_bd_cells VCU_hier/ilslice_vcu_enc_rst_n]
set_property -dict [list \
  CONFIG.DIN_FROM {0} \
  CONFIG.DIN_TO {0} \
  CONFIG.DIN_WIDTH {4} \
] [get_bd_cells VCU_hier/ilslice_vcu_enc_rst_n]
set_property -dict [list \
  CONFIG.DIN_FROM {1} \
  CONFIG.DIN_TO {1} \
  CONFIG.DIN_WIDTH {4} \
] [get_bd_cells VCU_hier/ilslice_vcu_dec_rst_n]
set_property -dict [list \
  CONFIG.DIN_FROM {2} \
  CONFIG.DIN_TO {2} \
  CONFIG.DIN_WIDTH {4} \
] [get_bd_cells VCU_hier/ilslice_vcu_raw_rst_n]
set_property -dict [list \
  CONFIG.DIN_FROM {3} \
  CONFIG.DIN_TO {3} \
  CONFIG.DIN_WIDTH {4} \
] [get_bd_cells VCU_hier/ilslice_vcu_dpll_rst_n]

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc2:* VCU_hier/axi_noc2_vcu
set_property -dict [list \
  CONFIG.NUM_CLKS {4} \
  CONFIG.NUM_MI {0} \
  CONFIG.NUM_NMI {4} \
  CONFIG.NUM_SI {4} \
] [get_bd_cells VCU_hier/axi_noc2_vcu]

set_property -dict [list CONFIG.CONNECTIONS {M00_INI {read_bw {500} write_bw {500} }}] [get_bd_intf_pins /VCU_hier/axi_noc2_vcu/S00_AXI]
set_property -dict [list CONFIG.CONNECTIONS {M01_INI {read_bw {500} write_bw {500} }}] [get_bd_intf_pins /VCU_hier/axi_noc2_vcu/S01_AXI]
set_property -dict [list CONFIG.CONNECTIONS {M02_INI {read_bw {500} write_bw {500} }}] [get_bd_intf_pins /VCU_hier/axi_noc2_vcu/S02_AXI]
set_property -dict [list CONFIG.CONNECTIONS {M03_INI {read_bw {500} write_bw {500} }}] [get_bd_intf_pins /VCU_hier/axi_noc2_vcu/S03_AXI]

create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:* VCU_hier/smartconnect_vcu
set_property -dict [list \
  CONFIG.NUM_MI {2} \
  CONFIG.NUM_SI {1} \
] [get_bd_cells VCU_hier/smartconnect_vcu]

# Connections
connect_bd_intf_net [get_bd_intf_pins VCU_hier/vcu2_0/C0_ENC_M_AXI_NOC] [get_bd_intf_pins VCU_hier/axi_noc2_vcu/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins VCU_hier/vcu2_0/C0_ENC_MCU_M_AXI_NOC] [get_bd_intf_pins VCU_hier/axi_noc2_vcu/S01_AXI]
connect_bd_intf_net [get_bd_intf_pins VCU_hier/vcu2_0/C0_DEC_M_AXI_NOC] [get_bd_intf_pins VCU_hier/axi_noc2_vcu/S02_AXI]
connect_bd_intf_net [get_bd_intf_pins VCU_hier/axi_noc2_vcu/S03_AXI] [get_bd_intf_pins VCU_hier/vcu2_0/C0_DEC_MCU_M_AXI_NOC]
connect_bd_intf_net [get_bd_intf_pins VCU_hier/smartconnect_vcu/M00_AXI] [get_bd_intf_pins VCU_hier/vcu_gpio_reset/S_AXI]
connect_bd_intf_net [get_bd_intf_pins VCU_hier/smartconnect_vcu/M01_AXI] [get_bd_intf_pins VCU_hier/vcu2_0/S_AXI_LITE]
connect_bd_net [get_bd_pins VCU_hier/vcu_gpio_reset/gpio_io_o] [get_bd_pins VCU_hier/ilslice_vcu_enc_rst_n/Din]

connect_bd_net [get_bd_pins VCU_hier/vcu_gpio_reset/gpio_io_o] [get_bd_pins VCU_hier/ilslice_vcu_dec_rst_n/Din]
connect_bd_net [get_bd_pins VCU_hier/vcu_gpio_reset/gpio_io_o] [get_bd_pins VCU_hier/ilslice_vcu_raw_rst_n/Din]
connect_bd_net [get_bd_pins VCU_hier/vcu_gpio_reset/gpio_io_o] [get_bd_pins VCU_hier/ilslice_vcu_dpll_rst_n/Din]
connect_bd_net [get_bd_pins VCU_hier/ilslice_vcu_enc_rst_n/Dout] [get_bd_pins VCU_hier/vcu2_0/c0_pl_enc_rst_n]
connect_bd_net [get_bd_pins VCU_hier/ilslice_vcu_dec_rst_n/Dout] [get_bd_pins VCU_hier/vcu2_0/c0_pl_dec_rst_n]
connect_bd_net [get_bd_pins VCU_hier/ilslice_vcu_raw_rst_n/Dout] [get_bd_pins VCU_hier/vcu2_0/c0_raw_rst_n]
connect_bd_net [get_bd_pins VCU_hier/ilslice_vcu_dpll_rst_n/Dout] [get_bd_pins VCU_hier/vcu2_0/c0_dpll_rst_n]

connect_bd_net [get_bd_pins VCU_hier/vcu2_0/c0_dec_m_axi_noc_clk] [get_bd_pins VCU_hier/axi_noc2_vcu/aclk0]
connect_bd_net [get_bd_pins VCU_hier/vcu2_0/c0_enc_m_axi_noc_clk] [get_bd_pins VCU_hier/axi_noc2_vcu/aclk1]
connect_bd_net [get_bd_pins VCU_hier/vcu2_0/c0_dec_mcu_m_axi_noc_clk] [get_bd_pins VCU_hier/axi_noc2_vcu/aclk2]
connect_bd_net [get_bd_pins VCU_hier/vcu2_0/c0_enc_mcu_m_axi_noc_clk] [get_bd_pins VCU_hier/axi_noc2_vcu/aclk3]

connect_bd_net [get_bd_pins VCU_hier/vcu_gpio_reset/s_axi_aclk] [get_bd_pins VCU_hier/smartconnect_vcu/aclk]
connect_bd_net [get_bd_pins VCU_hier/vcu_gpio_reset/s_axi_aresetn] [get_bd_pins VCU_hier/smartconnect_vcu/aresetn]
connect_bd_net [get_bd_pins VCU_hier/vcu2_0/s_axi_lite_rst_n] [get_bd_pins VCU_hier/smartconnect_vcu/aresetn]
connect_bd_net [get_bd_pins VCU_hier/vcu2_0/s_axi_lite_clk] [get_bd_pins VCU_hier/smartconnect_vcu/aclk]

create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 VCU_hier/S00_AXI
connect_bd_intf_net [get_bd_intf_pins VCU_hier/S00_AXI] [get_bd_intf_pins VCU_hier/smartconnect_vcu/S00_AXI]

create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 VCU_hier/M00_INI
connect_bd_intf_net [get_bd_intf_pins VCU_hier/M00_INI] [get_bd_intf_pins VCU_hier/axi_noc2_vcu/M00_INI]

create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 VCU_hier/M01_INI
connect_bd_intf_net [get_bd_intf_pins VCU_hier/M01_INI] [get_bd_intf_pins VCU_hier/axi_noc2_vcu/M01_INI]

create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 VCU_hier/M02_INI
connect_bd_intf_net [get_bd_intf_pins VCU_hier/M02_INI] [get_bd_intf_pins VCU_hier/axi_noc2_vcu/M02_INI]

create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 VCU_hier/M03_INI
connect_bd_intf_net [get_bd_intf_pins VCU_hier/M03_INI] [get_bd_intf_pins VCU_hier/axi_noc2_vcu/M03_INI]

create_bd_pin -dir I VCU_hier/dpll_ref_clk
connect_bd_net [get_bd_pins VCU_hier/dpll_ref_clk] [get_bd_pins VCU_hier/vcu2_0/dpll_ref_clk]

create_bd_pin -dir I VCU_hier/s_axi_aresetn
connect_bd_net [get_bd_pins VCU_hier/s_axi_aresetn] [get_bd_pins VCU_hier/smartconnect_vcu/aresetn]

create_bd_pin -dir I VCU_hier/s_axi_aclk
connect_bd_net [get_bd_pins VCU_hier/s_axi_aclk] [get_bd_pins VCU_hier/vcu_gpio_reset/s_axi_aclk]

create_bd_pin -dir O VCU_hier/c0_irq_error
connect_bd_net [get_bd_pins VCU_hier/c0_irq_error] [get_bd_pins VCU_hier/vcu2_0/c0_irq_error]

create_bd_pin -dir O VCU_hier/c0_irq_dec_pintreq
connect_bd_net [get_bd_pins VCU_hier/c0_irq_dec_pintreq] [get_bd_pins VCU_hier/vcu2_0/c0_irq_dec_pintreq]


create_bd_pin -dir O VCU_hier/c0_irq_enc_pintreq
connect_bd_net [get_bd_pins VCU_hier/c0_irq_enc_pintreq] [get_bd_pins VCU_hier/vcu2_0/c0_irq_enc_pintreq]
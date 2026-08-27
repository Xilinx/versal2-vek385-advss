# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------

proc update_VCU_hier { parentCell nameHier } {

  set oldCurInst [current_bd_instance .]
  current_bd_instance $parentCell/$nameHier

  # New interface pins
  if { [get_bd_intf_pins -quiet S00_AXI] eq "" } {
    create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI
  }
  if { [get_bd_intf_pins -quiet M00_INI] eq "" } {
    create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M00_INI
  }
  if { [get_bd_intf_pins -quiet M01_INI] eq "" } {
    create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M01_INI
  }
  if { [get_bd_intf_pins -quiet M02_INI] eq "" } {
    create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M02_INI
  }
  if { [get_bd_intf_pins -quiet M03_INI] eq "" } {
    create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M03_INI
  }

  # New pins
  if { [get_bd_pins -quiet dpll_ref_clk] eq "" } {
    create_bd_pin -dir I -type clk dpll_ref_clk
  }
  if { [get_bd_pins -quiet s_axi_lite_clk] eq "" } {
    create_bd_pin -dir I -type clk s_axi_lite_clk
  }
  if { [get_bd_pins -quiet s_axi_lite_rst_n] eq "" } {
    create_bd_pin -dir I -type rst s_axi_lite_rst_n
  }
  if { [get_bd_pins -quiet c0_irq_enc_pintreq] eq "" } {
    create_bd_pin -dir O -type intr c0_irq_enc_pintreq
  }
  if { [get_bd_pins -quiet c0_irq_dec_pintreq] eq "" } {
    create_bd_pin -dir O -type intr c0_irq_dec_pintreq
  }
  if { [get_bd_pins -quiet c0_irq_error] eq "" } {
    create_bd_pin -dir O -type intr c0_irq_error
  }

  # Update: vcu2_0
  set_property -dict [list \
    CONFIG.C0_DEC_COLOR_DEPTH {1} \
    CONFIG.C0_DEC_COLOR_FORMAT {2} \
    CONFIG.C0_DEC_FPS {1} \
    CONFIG.C0_ENC_COLOR_DEPTH {1} \
    CONFIG.C0_ENC_COLOR_FORMAT {2} \
    CONFIG.C0_ENC_FPS {1} \
    CONFIG.C0_ENC_SOURCE_FORMAT {1} \
    CONFIG.C_TARGET_BOARD {1} \
    CONFIG.NSU_ONLY {false} \
  ] [get_bd_cells vcu2_0]

  # New instance: vcu_smartconnect_0
  if { [get_bd_cells -quiet vcu_smartconnect_0] eq "" } {
    create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect vcu_smartconnect_0
    set_property -dict [list \
      CONFIG.NUM_MI {2} \
      CONFIG.NUM_SI {1} \
    ] [get_bd_cells vcu_smartconnect_0]
  }

  # New instance: axi_gpio_0
  if { [get_bd_cells -quiet axi_gpio_0] eq "" } {
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio axi_gpio_0
    set_property -dict [list \
      CONFIG.C_ALL_OUTPUTS {1} \
      CONFIG.C_DOUT_DEFAULT {0x0000000F} \
      CONFIG.C_GPIO_WIDTH {4} \
    ] [get_bd_cells axi_gpio_0]
  }

  # New instance: ilslice_0
  if { [get_bd_cells -quiet ilslice_0] eq "" } {
    create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice ilslice_0
    set_property -dict [list \
      CONFIG.DIN_WIDTH {4} \
    ] [get_bd_cells ilslice_0]
  }

  # New instance: ilslice_1
  if { [get_bd_cells -quiet ilslice_1] eq "" } {
    create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice ilslice_1
    set_property -dict [list \
      CONFIG.DIN_FROM {1} \
      CONFIG.DIN_TO {1} \
      CONFIG.DIN_WIDTH {4} \
    ] [get_bd_cells ilslice_1]
  }

  # New instance: ilslice_2
  if { [get_bd_cells -quiet ilslice_2] eq "" } {
    create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice ilslice_2
    set_property -dict [list \
      CONFIG.DIN_FROM {2} \
      CONFIG.DIN_TO {2} \
      CONFIG.DIN_WIDTH {4} \
    ] [get_bd_cells ilslice_2]
  }

  # New instance: ilslice_3
  if { [get_bd_cells -quiet ilslice_3] eq "" } {
    create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice ilslice_3
    set_property -dict [list \
      CONFIG.DIN_FROM {3} \
      CONFIG.DIN_TO {3} \
      CONFIG.DIN_WIDTH {4} \
    ] [get_bd_cells ilslice_3]
  }

  # New instance: axi_noc2_0
  if { [get_bd_cells -quiet axi_noc2_0] eq "" } {
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc2 axi_noc2_0
    set_property -dict [list \
      CONFIG.NUM_CLKS {4} \
      CONFIG.NUM_MI {0} \
      CONFIG.NUM_NMI {4} \
      CONFIG.NUM_NSI {0} \
      CONFIG.NUM_SI {4} \
    ] [get_bd_cells axi_noc2_0]
    set_property -dict [list \
      CONFIG.DATA_WIDTH {128} \
      CONFIG.CONNECTIONS {M00_INI {read_bw {1100} write_bw {1100} }} \
      CONFIG.DEST_IDS {} \
      CONFIG.NOC_PARAMS {} \
    ] [get_bd_intf_pins axi_noc2_0/S00_AXI]
    set_property -dict [list \
      CONFIG.DATA_WIDTH {128} \
      CONFIG.CONNECTIONS {M01_INI {read_bw {1100} write_bw {1100} }} \
      CONFIG.DEST_IDS {} \
      CONFIG.NOC_PARAMS {} \
    ] [get_bd_intf_pins axi_noc2_0/S01_AXI]
    set_property -dict [list \
      CONFIG.DATA_WIDTH {128} \
      CONFIG.CONNECTIONS {M02_INI {read_bw {1100} write_bw {1100} }} \
      CONFIG.DEST_IDS {} \
      CONFIG.NOC_PARAMS {} \
    ] [get_bd_intf_pins axi_noc2_0/S02_AXI]
    set_property -dict [list \
      CONFIG.DATA_WIDTH {128} \
      CONFIG.CONNECTIONS {M03_INI {read_bw {1100} write_bw {1100} }} \
      CONFIG.DEST_IDS {} \
      CONFIG.NOC_PARAMS {} \
    ] [get_bd_intf_pins axi_noc2_0/S03_AXI]
    set_property -dict [list \
      CONFIG.ASSOCIATED_BUSIF {S02_AXI} \
    ] [get_bd_pins axi_noc2_0/aclk0]
    set_property -dict [list \
      CONFIG.ASSOCIATED_BUSIF {S00_AXI} \
    ] [get_bd_pins axi_noc2_0/aclk1]
    set_property -dict [list \
      CONFIG.ASSOCIATED_BUSIF {S03_AXI} \
    ] [get_bd_pins axi_noc2_0/aclk2]
    set_property -dict [list \
      CONFIG.ASSOCIATED_BUSIF {S01_AXI} \
    ] [get_bd_pins axi_noc2_0/aclk3]
  }

  # New interface connections
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins vcu_smartconnect_0/S00_AXI]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins S00_AXI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins vcu_smartconnect_0/S00_AXI]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins S00_AXI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins vcu_smartconnect_0/S00_AXI] [get_bd_intf_pins S00_AXI] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_0/M00_INI]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins M00_INI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_0/M00_INI]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins M00_INI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins axi_noc2_0/M00_INI] [get_bd_intf_pins M00_INI] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_0/M01_INI]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins M01_INI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_0/M01_INI]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins M01_INI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins axi_noc2_0/M01_INI] [get_bd_intf_pins M01_INI] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_0/M02_INI]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins M02_INI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_0/M02_INI]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins M02_INI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins axi_noc2_0/M02_INI] [get_bd_intf_pins M02_INI] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_0/M03_INI]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins M03_INI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_0/M03_INI]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins M03_INI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins axi_noc2_0/M03_INI] [get_bd_intf_pins M03_INI] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins vcu2_0/C0_DEC_MCU_M_AXI_NOC]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_0/S03_AXI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins vcu2_0/C0_DEC_MCU_M_AXI_NOC]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_0/S03_AXI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins vcu2_0/C0_DEC_MCU_M_AXI_NOC] [get_bd_intf_pins axi_noc2_0/S03_AXI] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins vcu2_0/C0_DEC_M_AXI_NOC]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_0/S02_AXI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins vcu2_0/C0_DEC_M_AXI_NOC]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_0/S02_AXI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins vcu2_0/C0_DEC_M_AXI_NOC] [get_bd_intf_pins axi_noc2_0/S02_AXI] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins vcu2_0/C0_ENC_MCU_M_AXI_NOC]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_0/S01_AXI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins vcu2_0/C0_ENC_MCU_M_AXI_NOC]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_0/S01_AXI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins vcu2_0/C0_ENC_MCU_M_AXI_NOC] [get_bd_intf_pins axi_noc2_0/S01_AXI] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins vcu2_0/C0_ENC_M_AXI_NOC]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_0/S00_AXI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins vcu2_0/C0_ENC_M_AXI_NOC]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_0/S00_AXI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins vcu2_0/C0_ENC_M_AXI_NOC] [get_bd_intf_pins axi_noc2_0/S00_AXI] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins vcu_smartconnect_0/M00_AXI]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_gpio_0/S_AXI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins vcu_smartconnect_0/M00_AXI]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_gpio_0/S_AXI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins vcu_smartconnect_0/M00_AXI] [get_bd_intf_pins axi_gpio_0/S_AXI] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins vcu_smartconnect_0/M01_AXI]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins vcu2_0/S_AXI_LITE]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins vcu_smartconnect_0/M01_AXI]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins vcu2_0/S_AXI_LITE]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins vcu_smartconnect_0/M01_AXI] [get_bd_intf_pins vcu2_0/S_AXI_LITE] }
  }

  # New net connections
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins axi_gpio_0/gpio_io_o]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins ilslice_0/Din]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins ilslice_1/Din]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins ilslice_2/Din]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins ilslice_3/Din]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins axi_gpio_0/gpio_io_o]] eq [get_bd_nets -quiet -of_objects [get_bd_pins ilslice_0/Din]] && [get_bd_nets -quiet -of_objects [get_bd_pins axi_gpio_0/gpio_io_o]] eq [get_bd_nets -quiet -of_objects [get_bd_pins ilslice_1/Din]] && [get_bd_nets -quiet -of_objects [get_bd_pins axi_gpio_0/gpio_io_o]] eq [get_bd_nets -quiet -of_objects [get_bd_pins ilslice_2/Din]] && [get_bd_nets -quiet -of_objects [get_bd_pins axi_gpio_0/gpio_io_o]] eq [get_bd_nets -quiet -of_objects [get_bd_pins ilslice_3/Din]]) } {
    catch { connect_bd_net -net axi_gpio_0_gpio_io_o [get_bd_pins axi_gpio_0/gpio_io_o] [get_bd_pins ilslice_0/Din] [get_bd_pins ilslice_1/Din] [get_bd_pins ilslice_2/Din] [get_bd_pins ilslice_3/Din] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins dpll_ref_clk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/dpll_ref_clk]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins dpll_ref_clk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/dpll_ref_clk]]) } {
    catch { connect_bd_net -net dpll_ref_clk_1 [get_bd_pins dpll_ref_clk] [get_bd_pins vcu2_0/dpll_ref_clk] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins ilslice_0/Dout]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_pl_enc_rst_n]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins ilslice_0/Dout]] eq [get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_pl_enc_rst_n]]) } {
    catch { connect_bd_net -net ilslice_0_Dout [get_bd_pins ilslice_0/Dout] [get_bd_pins vcu2_0/c0_pl_enc_rst_n] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins ilslice_1/Dout]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_pl_dec_rst_n]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins ilslice_1/Dout]] eq [get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_pl_dec_rst_n]]) } {
    catch { connect_bd_net -net ilslice_1_Dout [get_bd_pins ilslice_1/Dout] [get_bd_pins vcu2_0/c0_pl_dec_rst_n] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins ilslice_2/Dout]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_raw_rst_n]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins ilslice_2/Dout]] eq [get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_raw_rst_n]]) } {
    catch { connect_bd_net -net ilslice_2_Dout [get_bd_pins ilslice_2/Dout] [get_bd_pins vcu2_0/c0_raw_rst_n] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins ilslice_3/Dout]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_dpll_rst_n]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins ilslice_3/Dout]] eq [get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_dpll_rst_n]]) } {
    catch { connect_bd_net -net ilslice_3_Dout [get_bd_pins ilslice_3/Dout] [get_bd_pins vcu2_0/c0_dpll_rst_n] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins s_axi_lite_clk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/s_axi_lite_clk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins vcu_smartconnect_0/aclk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins axi_gpio_0/s_axi_aclk]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins s_axi_lite_clk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/s_axi_lite_clk]] && [get_bd_nets -quiet -of_objects [get_bd_pins s_axi_lite_clk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins vcu_smartconnect_0/aclk]] && [get_bd_nets -quiet -of_objects [get_bd_pins s_axi_lite_clk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins axi_gpio_0/s_axi_aclk]]) } {
    catch { connect_bd_net -net s_axi_lite_clk_1 [get_bd_pins s_axi_lite_clk] [get_bd_pins vcu2_0/s_axi_lite_clk] [get_bd_pins vcu_smartconnect_0/aclk] [get_bd_pins axi_gpio_0/s_axi_aclk] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins s_axi_lite_rst_n]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/s_axi_lite_rst_n]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins vcu_smartconnect_0/aresetn]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins axi_gpio_0/s_axi_aresetn]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins s_axi_lite_rst_n]] eq [get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/s_axi_lite_rst_n]] && [get_bd_nets -quiet -of_objects [get_bd_pins s_axi_lite_rst_n]] eq [get_bd_nets -quiet -of_objects [get_bd_pins vcu_smartconnect_0/aresetn]] && [get_bd_nets -quiet -of_objects [get_bd_pins s_axi_lite_rst_n]] eq [get_bd_nets -quiet -of_objects [get_bd_pins axi_gpio_0/s_axi_aresetn]]) } {
    catch { connect_bd_net -net s_axi_lite_rst_n_1 [get_bd_pins s_axi_lite_rst_n] [get_bd_pins vcu2_0/s_axi_lite_rst_n] [get_bd_pins vcu_smartconnect_0/aresetn] [get_bd_pins axi_gpio_0/s_axi_aresetn] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_dec_m_axi_noc_clk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins axi_noc2_0/aclk0]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_dec_m_axi_noc_clk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins axi_noc2_0/aclk0]]) } {
    catch { connect_bd_net -net vcu2_0_c0_dec_m_axi_noc_clk [get_bd_pins vcu2_0/c0_dec_m_axi_noc_clk] [get_bd_pins axi_noc2_0/aclk0] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_dec_mcu_m_axi_noc_clk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins axi_noc2_0/aclk2]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_dec_mcu_m_axi_noc_clk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins axi_noc2_0/aclk2]]) } {
    catch { connect_bd_net -net vcu2_0_c0_dec_mcu_m_axi_noc_clk [get_bd_pins vcu2_0/c0_dec_mcu_m_axi_noc_clk] [get_bd_pins axi_noc2_0/aclk2] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_enc_m_axi_noc_clk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins axi_noc2_0/aclk1]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_enc_m_axi_noc_clk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins axi_noc2_0/aclk1]]) } {
    catch { connect_bd_net -net vcu2_0_c0_enc_m_axi_noc_clk [get_bd_pins vcu2_0/c0_enc_m_axi_noc_clk] [get_bd_pins axi_noc2_0/aclk1] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_enc_mcu_m_axi_noc_clk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins axi_noc2_0/aclk3]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_enc_mcu_m_axi_noc_clk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins axi_noc2_0/aclk3]]) } {
    catch { connect_bd_net -net vcu2_0_c0_enc_mcu_m_axi_noc_clk [get_bd_pins vcu2_0/c0_enc_mcu_m_axi_noc_clk] [get_bd_pins axi_noc2_0/aclk3] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_irq_dec_pintreq]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins c0_irq_dec_pintreq]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_irq_dec_pintreq]] eq [get_bd_nets -quiet -of_objects [get_bd_pins c0_irq_dec_pintreq]]) } {
    catch { connect_bd_net -net vcu2_0_c0_irq_dec_pintreq [get_bd_pins vcu2_0/c0_irq_dec_pintreq] [get_bd_pins c0_irq_dec_pintreq] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_irq_enc_pintreq]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins c0_irq_enc_pintreq]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_irq_enc_pintreq]] eq [get_bd_nets -quiet -of_objects [get_bd_pins c0_irq_enc_pintreq]]) } {
    catch { connect_bd_net -net vcu2_0_c0_irq_enc_pintreq [get_bd_pins vcu2_0/c0_irq_enc_pintreq] [get_bd_pins c0_irq_enc_pintreq] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_irq_error]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins c0_irq_error]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_irq_error]] eq [get_bd_nets -quiet -of_objects [get_bd_pins c0_irq_error]]) } {
    catch { connect_bd_net -net vcu2_0_c0_irq_error [get_bd_pins vcu2_0/c0_irq_error] [get_bd_pins c0_irq_error] }
  }

  current_bd_instance $oldCurInst
}

# Auto-execute: Update VCU_hier when this script is sourced
puts "Updating VCU_hier..."
update_VCU_hier / VCU_hier
puts "VCU_hier updated successfully."

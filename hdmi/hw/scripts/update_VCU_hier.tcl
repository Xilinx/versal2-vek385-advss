# Copyright (C) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT

################################################################################
# VCU_hier hierarchy update procedure
#
# This script updates the 'VCU_hier' (Video Codec Unit) hierarchy by adding
# AXI4-Lite control, AXI NoC interconnect, GPIO-based reset controls, and
# exporting DDR-bound INI (Integrated Network on Chip Interface) ports.
#
# The VCU_hier subsystem handles H.264/H.265 video encode/decode and contains:
#   - vcu2_0: Video Codec Unit IP (encoder + decoder + MCU)
#   - axi_noc2_vcu: AXI NoC for connecting VCU to DDR (4 master INI ports)
#   - vcu_gpio_reset: AXI GPIO for software-controlled reset of VCU subsystems
#   - smartconnect_vcu: AXI SmartConnect for AXI4-Lite control bus routing
#   - ilslice_*: Inline bit-slicing logic to extract individual reset signals
#
# ------------------------------------------------------------------------------
# INTERFACE PINS (exported to parent)
# ------------------------------------------------------------------------------
#   S00_AXI               [S, AXI4-Lite] Control bus for VCU register access
#                                        and GPIO reset control. Connect to CPU.
#   M00_INI..M03_INI      [M, INI-MM   ] NoC master ports to DDR for video
#                                        frame buffers (encoder/decoder data).
#
# ------------------------------------------------------------------------------
# CLOCKS / RESETS
# ------------------------------------------------------------------------------
#   dpll_ref_clk          [I clk] DPLL reference clock for VCU timing.
#   s_axi_aclk            [I clk] AXI4-Lite control clock (drives S00_AXI + IPs).
#   s_axi_aresetn         [I rst] AXI4-Lite control reset (active-low).
#
# ------------------------------------------------------------------------------
# INTERRUPTS (connect to your interrupt controller)
# ------------------------------------------------------------------------------
#   c0_irq_error          [O intr] VCU error interrupt.
#   c0_irq_dec_pintreq    [O intr] VCU decoder interrupt.
#   c0_irq_enc_pintreq    [O intr] VCU encoder interrupt.
#
# ------------------------------------------------------------------------------
# VCU GPIO RESET MAPPING (4-bit gpio_io_o from vcu_gpio_reset)
# ------------------------------------------------------------------------------
#   gpio_io_o[0] -> c0_pl_enc_rst_n   (encoder reset, active-low)
#   gpio_io_o[1] -> c0_pl_dec_rst_n   (decoder reset, active-low)
#   gpio_io_o[2] -> c0_raw_rst_n      (raw video path reset, active-low)
#   gpio_io_o[3] -> c0_dpll_rst_n     (DPLL reset, active-low)
#   Default: 0x0F (all subsystems out of reset).
#
# ------------------------------------------------------------------------------
# AXI NOC2_VCU PORT ALLOCATION (SNN_AXI -> axi_noc2_vcu -> MNN_INI)
# ------------------------------------------------------------------------------
#   S00_AXI = vcu2_0/C0_ENC_M_AXI_NOC     -> M00_INI (encoder data, 500/500 MB/s)
#   S01_AXI = vcu2_0/C0_ENC_MCU_M_AXI_NOC -> M01_INI (encoder MCU, 500/500 MB/s)
#   S02_AXI = vcu2_0/C0_DEC_M_AXI_NOC     -> M02_INI (decoder data, 500/500 MB/s)
#   S03_AXI = vcu2_0/C0_DEC_MCU_M_AXI_NOC -> M03_INI (decoder MCU, 500/500 MB/s)
#   Each port has dedicated clock from VCU (c0_enc_m_axi_noc_clk, etc.).
#
# ------------------------------------------------------------------------------
# SMARTCONNECT_VCU PORT ALLOCATION (S00_AXI -> M0N_AXI)
# ------------------------------------------------------------------------------
#   S00_AXI = parent S00_AXI (from CPU)
#   M00_AXI = vcu_gpio_reset/S_AXI    (GPIO reset control registers)
#   M01_AXI = vcu2_0/S_AXI_LITE       (VCU register access)
#
################################################################################

################################################################
# This is a generated script based on design: versal_gen2_platform
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

proc update_VCU_hier { parentCell nameHier } {

  # --- SECTION: Preserve context and navigate to target hierarchy --------------
  set oldCurInst [current_bd_instance .]
  current_bd_instance $parentCell/$nameHier

  # --- SECTION: Create/verify interface pins (exported to parent) --------------
  # S00_AXI: AXI4-Lite control interface (from CPU to VCU + GPIO reset control)
  # M00_INI..M03_INI: NoC master interfaces to DDR for video frame buffers
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

  # --- SECTION: Create/verify clock/reset/interrupt pins -----------------------
  # dpll_ref_clk: DPLL reference clock input
  # s_axi_aclk/aresetn: AXI4-Lite control clock and reset
  # c0_irq_*: VCU interrupt outputs (error, decoder, encoder)
  if { [get_bd_pins -quiet dpll_ref_clk] eq "" } {
    create_bd_pin -dir I dpll_ref_clk
  }
  if { [get_bd_pins -quiet s_axi_aresetn] eq "" } {
    create_bd_pin -dir I s_axi_aresetn
  }
  if { [get_bd_pins -quiet s_axi_aclk] eq "" } {
    create_bd_pin -dir I s_axi_aclk
  }
  if { [get_bd_pins -quiet c0_irq_error] eq "" } {
    create_bd_pin -dir O c0_irq_error
  }
  if { [get_bd_pins -quiet c0_irq_dec_pintreq] eq "" } {
    create_bd_pin -dir O c0_irq_dec_pintreq
  }
  if { [get_bd_pins -quiet c0_irq_enc_pintreq] eq "" } {
    create_bd_pin -dir O c0_irq_enc_pintreq
  }

  # --- SECTION: Update VCU2 IP configuration ------------------------------------
  # VCU2 (Video Codec Unit Gen 2) configuration:
  #   C_TARGET_BOARD=1: VEK385 board preset
  #   C0_ENC_SOURCE_FORMAT=1: encoder input format (NV12/NV16)
  #   NSU_ONLY=false: full VCU (not NSU-only mode)
  set_property -dict [list \
    CONFIG.C_TARGET_BOARD {1} \
    CONFIG.C0_ENC_SOURCE_FORMAT {1} \
    CONFIG.NSU_ONLY {false} \
  ] [get_bd_cells vcu2_0]

  # --- SECTION: VCU GPIO reset control ------------------------------------------
  # AXI GPIO to provide software-controlled reset for VCU subsystems.
  # 4-bit output: [enc_rst_n, dec_rst_n, raw_rst_n, dpll_rst_n]
  # Default 0x0F keeps all subsystems out of reset.
  if { [get_bd_cells -quiet vcu_gpio_reset] eq "" } {
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 vcu_gpio_reset
    set_property -dict [list \
      CONFIG.C_ALL_OUTPUTS {1} \
      CONFIG.C_DOUT_DEFAULT {0x0000000F} \
      CONFIG.C_GPIO_WIDTH {4} \
    ] [get_bd_cells vcu_gpio_reset]
  }

  # --- SECTION: Bit-slice extractors for individual reset signals --------------
  # Extract individual reset bits from the 4-bit GPIO output:
  #   ilslice_vcu_enc_rst_n:  extracts gpio_io_o[0] -> c0_pl_enc_rst_n
  #   ilslice_vcu_dec_rst_n:  extracts gpio_io_o[1] -> c0_pl_dec_rst_n
  #   ilslice_vcu_raw_rst_n:  extracts gpio_io_o[2] -> c0_raw_rst_n
  #   ilslice_vcu_dpll_rst_n: extracts gpio_io_o[3] -> c0_dpll_rst_n
  if { [get_bd_cells -quiet ilslice_vcu_enc_rst_n] eq "" } {
    create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_vcu_enc_rst_n
    set_property -dict [list \
      CONFIG.DIN_FROM {0} \
      CONFIG.DIN_TO {0} \
      CONFIG.DIN_WIDTH {4} \
    ] [get_bd_cells ilslice_vcu_enc_rst_n]
  }

  # New instance: ilslice_vcu_dec_rst_n
  if { [get_bd_cells -quiet ilslice_vcu_dec_rst_n] eq "" } {
    create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_vcu_dec_rst_n
    set_property -dict [list \
      CONFIG.DIN_FROM {1} \
      CONFIG.DIN_TO {1} \
      CONFIG.DIN_WIDTH {4} \
    ] [get_bd_cells ilslice_vcu_dec_rst_n]
  }

  # New instance: ilslice_vcu_raw_rst_n
  if { [get_bd_cells -quiet ilslice_vcu_raw_rst_n] eq "" } {
    create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_vcu_raw_rst_n
    set_property -dict [list \
      CONFIG.DIN_FROM {2} \
      CONFIG.DIN_TO {2} \
      CONFIG.DIN_WIDTH {4} \
    ] [get_bd_cells ilslice_vcu_raw_rst_n]
  }

  # New instance: ilslice_vcu_dpll_rst_n
  if { [get_bd_cells -quiet ilslice_vcu_dpll_rst_n] eq "" } {
    create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilslice:1.0 ilslice_vcu_dpll_rst_n
    set_property -dict [list \
      CONFIG.DIN_FROM {3} \
      CONFIG.DIN_TO {3} \
      CONFIG.DIN_WIDTH {4} \
    ] [get_bd_cells ilslice_vcu_dpll_rst_n]
  }

  # --- SECTION: AXI NoC for VCU to DDR connectivity -----------------------------
  # axi_noc2_vcu: Routes VCU AXI-MM masters to DDR via NoC INI ports.
  # 4 AXI slaves (from VCU encoder/decoder) -> 4 INI masters (to DDR NoC).
  # Each port: 500 MB/s read/write bandwidth allocation.
  # 4 separate clock domains (aclk0..aclk3) from VCU's internal clocks.
  if { [get_bd_cells -quiet axi_noc2_vcu] eq "" } {
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc2:1.1 axi_noc2_vcu
    set_property -dict [list \
      CONFIG.NUM_CLKS {4} \
      CONFIG.NUM_MI {0} \
      CONFIG.NUM_NMI {4} \
      CONFIG.NUM_SI {4} \
    ] [get_bd_cells axi_noc2_vcu]
    set_property -dict [list \
      CONFIG.DATA_WIDTH {128} \
      CONFIG.CONNECTIONS {M00_INI {read_bw {500} write_bw {500} }} \
      CONFIG.DEST_IDS {} \
      CONFIG.NOC_PARAMS {} \
    ] [get_bd_intf_pins axi_noc2_vcu/S00_AXI]
    set_property -dict [list \
      CONFIG.DATA_WIDTH {128} \
      CONFIG.CONNECTIONS {M01_INI {read_bw {500} write_bw {500} }} \
      CONFIG.DEST_IDS {} \
      CONFIG.NOC_PARAMS {} \
    ] [get_bd_intf_pins axi_noc2_vcu/S01_AXI]
    set_property -dict [list \
      CONFIG.DATA_WIDTH {128} \
      CONFIG.CONNECTIONS {M02_INI {read_bw {500} write_bw {500} }} \
      CONFIG.DEST_IDS {} \
      CONFIG.NOC_PARAMS {} \
    ] [get_bd_intf_pins axi_noc2_vcu/S02_AXI]
    set_property -dict [list \
      CONFIG.DATA_WIDTH {128} \
      CONFIG.CONNECTIONS {M03_INI {read_bw {500} write_bw {500} }} \
      CONFIG.DEST_IDS {} \
      CONFIG.NOC_PARAMS {} \
    ] [get_bd_intf_pins axi_noc2_vcu/S03_AXI]
    set_property -dict [list \
      CONFIG.ASSOCIATED_BUSIF {S02_AXI} \
    ] [get_bd_pins axi_noc2_vcu/aclk0]
    set_property -dict [list \
      CONFIG.ASSOCIATED_BUSIF {S00_AXI} \
    ] [get_bd_pins axi_noc2_vcu/aclk1]
    set_property -dict [list \
      CONFIG.ASSOCIATED_BUSIF {S03_AXI} \
    ] [get_bd_pins axi_noc2_vcu/aclk2]
    set_property -dict [list \
      CONFIG.ASSOCIATED_BUSIF {S01_AXI} \
    ] [get_bd_pins axi_noc2_vcu/aclk3]
  }

  # --- SECTION: AXI SmartConnect for control path routing -----------------------
  # smartconnect_vcu: Routes parent S00_AXI to VCU + GPIO reset.
  # S00_AXI = parent S00_AXI (from CPU)
  # M00_AXI = vcu_gpio_reset/S_AXI
  # M01_AXI = vcu2_0/S_AXI_LITE
  if { [get_bd_cells -quiet smartconnect_vcu] eq "" } {
    create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_vcu
    set_property -dict [list \
      CONFIG.NUM_MI {2} \
      CONFIG.NUM_SI {1} \
    ] [get_bd_cells smartconnect_vcu]
  }

  # --- SECTION: Interface connections (AXI4-Lite, AXI-MM, INI) ------------------
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins S00_AXI]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins smartconnect_vcu/S00_AXI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins S00_AXI]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins smartconnect_vcu/S00_AXI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins S00_AXI] [get_bd_intf_pins smartconnect_vcu/S00_AXI] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins M00_INI]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_vcu/M00_INI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins M00_INI]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_vcu/M00_INI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins M00_INI] [get_bd_intf_pins axi_noc2_vcu/M00_INI] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins M01_INI]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_vcu/M01_INI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins M01_INI]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_vcu/M01_INI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins M01_INI] [get_bd_intf_pins axi_noc2_vcu/M01_INI] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins M02_INI]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_vcu/M02_INI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins M02_INI]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_vcu/M02_INI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins M02_INI] [get_bd_intf_pins axi_noc2_vcu/M02_INI] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins M03_INI]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_vcu/M03_INI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins M03_INI]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_vcu/M03_INI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins M03_INI] [get_bd_intf_pins axi_noc2_vcu/M03_INI] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins smartconnect_vcu/M00_AXI]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins vcu_gpio_reset/S_AXI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins smartconnect_vcu/M00_AXI]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins vcu_gpio_reset/S_AXI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins smartconnect_vcu/M00_AXI] [get_bd_intf_pins vcu_gpio_reset/S_AXI] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins smartconnect_vcu/M01_AXI]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins vcu2_0/S_AXI_LITE]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins smartconnect_vcu/M01_AXI]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins vcu2_0/S_AXI_LITE]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins smartconnect_vcu/M01_AXI] [get_bd_intf_pins vcu2_0/S_AXI_LITE] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_vcu/S03_AXI]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins vcu2_0/C0_DEC_MCU_M_AXI_NOC]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_vcu/S03_AXI]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins vcu2_0/C0_DEC_MCU_M_AXI_NOC]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins axi_noc2_vcu/S03_AXI] [get_bd_intf_pins vcu2_0/C0_DEC_MCU_M_AXI_NOC] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins vcu2_0/C0_DEC_M_AXI_NOC]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_vcu/S02_AXI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins vcu2_0/C0_DEC_M_AXI_NOC]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_vcu/S02_AXI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins vcu2_0/C0_DEC_M_AXI_NOC] [get_bd_intf_pins axi_noc2_vcu/S02_AXI] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins vcu2_0/C0_ENC_MCU_M_AXI_NOC]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_vcu/S01_AXI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins vcu2_0/C0_ENC_MCU_M_AXI_NOC]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_vcu/S01_AXI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins vcu2_0/C0_ENC_MCU_M_AXI_NOC] [get_bd_intf_pins axi_noc2_vcu/S01_AXI] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins vcu2_0/C0_ENC_M_AXI_NOC]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_vcu/S00_AXI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins vcu2_0/C0_ENC_M_AXI_NOC]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_vcu/S00_AXI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins vcu2_0/C0_ENC_M_AXI_NOC] [get_bd_intf_pins axi_noc2_vcu/S00_AXI] }
  }

  # --- SECTION: Net connections (clocks, resets, interrupts, GPIO) -------------
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins s_axi_aclk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins vcu_gpio_reset/s_axi_aclk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins smartconnect_vcu/aclk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/s_axi_lite_clk]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins s_axi_aclk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins vcu_gpio_reset/s_axi_aclk]] && [get_bd_nets -quiet -of_objects [get_bd_pins s_axi_aclk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins smartconnect_vcu/aclk]] && [get_bd_nets -quiet -of_objects [get_bd_pins s_axi_aclk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/s_axi_lite_clk]]) } {
    catch { connect_bd_net -net Net [get_bd_pins s_axi_aclk] [get_bd_pins vcu_gpio_reset/s_axi_aclk] [get_bd_pins smartconnect_vcu/aclk] [get_bd_pins vcu2_0/s_axi_lite_clk] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins s_axi_aresetn]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins vcu_gpio_reset/s_axi_aresetn]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins smartconnect_vcu/aresetn]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/s_axi_lite_rst_n]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins s_axi_aresetn]] eq [get_bd_nets -quiet -of_objects [get_bd_pins vcu_gpio_reset/s_axi_aresetn]] && [get_bd_nets -quiet -of_objects [get_bd_pins s_axi_aresetn]] eq [get_bd_nets -quiet -of_objects [get_bd_pins smartconnect_vcu/aresetn]] && [get_bd_nets -quiet -of_objects [get_bd_pins s_axi_aresetn]] eq [get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/s_axi_lite_rst_n]]) } {
    catch { connect_bd_net -net Net1 [get_bd_pins s_axi_aresetn] [get_bd_pins vcu_gpio_reset/s_axi_aresetn] [get_bd_pins smartconnect_vcu/aresetn] [get_bd_pins vcu2_0/s_axi_lite_rst_n] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins dpll_ref_clk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/dpll_ref_clk]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins dpll_ref_clk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/dpll_ref_clk]]) } {
    catch { connect_bd_net -net dpll_ref_clk_1 [get_bd_pins dpll_ref_clk] [get_bd_pins vcu2_0/dpll_ref_clk] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins ilslice_vcu_dec_rst_n/Dout]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_pl_dec_rst_n]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins ilslice_vcu_dec_rst_n/Dout]] eq [get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_pl_dec_rst_n]]) } {
    catch { connect_bd_net -net ilslice_vcu_dec_rst_n_Dout [get_bd_pins ilslice_vcu_dec_rst_n/Dout] [get_bd_pins vcu2_0/c0_pl_dec_rst_n] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins ilslice_vcu_dpll_rst_n/Dout]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_dpll_rst_n]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins ilslice_vcu_dpll_rst_n/Dout]] eq [get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_dpll_rst_n]]) } {
    catch { connect_bd_net -net ilslice_vcu_dpll_rst_n_Dout [get_bd_pins ilslice_vcu_dpll_rst_n/Dout] [get_bd_pins vcu2_0/c0_dpll_rst_n] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins ilslice_vcu_enc_rst_n/Dout]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_pl_enc_rst_n]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins ilslice_vcu_enc_rst_n/Dout]] eq [get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_pl_enc_rst_n]]) } {
    catch { connect_bd_net -net ilslice_vcu_enc_rst_n_Dout [get_bd_pins ilslice_vcu_enc_rst_n/Dout] [get_bd_pins vcu2_0/c0_pl_enc_rst_n] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins ilslice_vcu_raw_rst_n/Dout]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_raw_rst_n]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins ilslice_vcu_raw_rst_n/Dout]] eq [get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_raw_rst_n]]) } {
    catch { connect_bd_net -net ilslice_vcu_raw_rst_n_Dout [get_bd_pins ilslice_vcu_raw_rst_n/Dout] [get_bd_pins vcu2_0/c0_raw_rst_n] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_dec_m_axi_noc_clk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins axi_noc2_vcu/aclk0]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_dec_m_axi_noc_clk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins axi_noc2_vcu/aclk0]]) } {
    catch { connect_bd_net -net vcu2_0_c0_dec_m_axi_noc_clk [get_bd_pins vcu2_0/c0_dec_m_axi_noc_clk] [get_bd_pins axi_noc2_vcu/aclk0] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_dec_mcu_m_axi_noc_clk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins axi_noc2_vcu/aclk2]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_dec_mcu_m_axi_noc_clk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins axi_noc2_vcu/aclk2]]) } {
    catch { connect_bd_net -net vcu2_0_c0_dec_mcu_m_axi_noc_clk [get_bd_pins vcu2_0/c0_dec_mcu_m_axi_noc_clk] [get_bd_pins axi_noc2_vcu/aclk2] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_enc_m_axi_noc_clk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins axi_noc2_vcu/aclk1]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_enc_m_axi_noc_clk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins axi_noc2_vcu/aclk1]]) } {
    catch { connect_bd_net -net vcu2_0_c0_enc_m_axi_noc_clk [get_bd_pins vcu2_0/c0_enc_m_axi_noc_clk] [get_bd_pins axi_noc2_vcu/aclk1] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_enc_mcu_m_axi_noc_clk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins axi_noc2_vcu/aclk3]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins vcu2_0/c0_enc_mcu_m_axi_noc_clk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins axi_noc2_vcu/aclk3]]) } {
    catch { connect_bd_net -net vcu2_0_c0_enc_mcu_m_axi_noc_clk [get_bd_pins vcu2_0/c0_enc_mcu_m_axi_noc_clk] [get_bd_pins axi_noc2_vcu/aclk3] }
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
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins vcu_gpio_reset/gpio_io_o]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins ilslice_vcu_enc_rst_n/Din]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins ilslice_vcu_dec_rst_n/Din]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins ilslice_vcu_raw_rst_n/Din]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins ilslice_vcu_dpll_rst_n/Din]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins vcu_gpio_reset/gpio_io_o]] eq [get_bd_nets -quiet -of_objects [get_bd_pins ilslice_vcu_enc_rst_n/Din]] && [get_bd_nets -quiet -of_objects [get_bd_pins vcu_gpio_reset/gpio_io_o]] eq [get_bd_nets -quiet -of_objects [get_bd_pins ilslice_vcu_dec_rst_n/Din]] && [get_bd_nets -quiet -of_objects [get_bd_pins vcu_gpio_reset/gpio_io_o]] eq [get_bd_nets -quiet -of_objects [get_bd_pins ilslice_vcu_raw_rst_n/Din]] && [get_bd_nets -quiet -of_objects [get_bd_pins vcu_gpio_reset/gpio_io_o]] eq [get_bd_nets -quiet -of_objects [get_bd_pins ilslice_vcu_dpll_rst_n/Din]]) } {
    catch { connect_bd_net -net vcu_gpio_reset_gpio_io_o [get_bd_pins vcu_gpio_reset/gpio_io_o] [get_bd_pins ilslice_vcu_enc_rst_n/Din] [get_bd_pins ilslice_vcu_dec_rst_n/Din] [get_bd_pins ilslice_vcu_raw_rst_n/Din] [get_bd_pins ilslice_vcu_dpll_rst_n/Din] }
  }

  # --- SECTION: Restore context -------------------------------------------------
  current_bd_instance $oldCurInst
}

# --- SECTION: Auto-execute when script is sourced ----------------------------
# Automatically update VCU_hier when this script is sourced from main.tcl.
puts "Updating VCU_hier..."
update_VCU_hier / VCU_hier
puts "VCU_hier updated successfully."

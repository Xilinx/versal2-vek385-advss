# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
################################################################
# Minimal ISP_hier Update Script

proc update_ISP_hier { parentCell nameHier } {

  set oldCurInst [current_bd_instance .]
  current_bd_instance $parentCell/$nameHier

  # New interface pins
  if { [get_bd_intf_pins -quiet M00_INI] eq "" } {
    create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M00_INI
  }
  if { [get_bd_intf_pins -quiet MIPI1] eq "" } {
    create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:mipi_phy_rtl:1.0 MIPI1
  }
  if { [get_bd_intf_pins -quiet S_AXI_LITE] eq "" } {
    create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_LITE
  }
  if { [get_bd_intf_pins -quiet IIC_0] eq "" } {
    create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 IIC_0
  }

  # New pins
  if { [get_bd_pins -quiet csirxss_csi_irq] eq "" } {
    create_bd_pin -dir O -type intr csirxss_csi_irq
  }
  if { [get_bd_pins -quiet tile0_isp0_fusa_irq] eq "" } {
    create_bd_pin -dir O -type intr tile0_isp0_fusa_irq
  }
  if { [get_bd_pins -quiet tile0_isp0_isp_irq] eq "" } {
    create_bd_pin -dir O -type intr tile0_isp0_isp_irq
  }
  if { [get_bd_pins -quiet tile0_isp_isr_irq] eq "" } {
    create_bd_pin -dir O -type intr tile0_isp_isr_irq
  }
  if { [get_bd_pins -quiet tile0_isp_xmpu_interrupt] eq "" } {
    create_bd_pin -dir O -type intr tile0_isp_xmpu_interrupt
  }
  if { [get_bd_pins -quiet ext_reset_in] eq "" } {
    create_bd_pin -dir I -type rst ext_reset_in
  }
  if { [get_bd_pins -quiet lite_aresetn] eq "" } {
    create_bd_pin -dir I -type rst lite_aresetn
  }
  if { [get_bd_pins -quiet iic2intc_irpt] eq "" } {
    create_bd_pin -dir O -type intr iic2intc_irpt
  }
  if { [get_bd_pins -quiet tile0_pl_isp_vidin0_clk] eq "" } {
    create_bd_pin -dir I -type clk tile0_pl_isp_vidin0_clk
  }
  if { [get_bd_pins -quiet s_axi_aclk] eq "" } {
    create_bd_pin -dir I -type clk s_axi_aclk
  }

  # Update: visp_ss_tile0
  set_property -dict [list \
    CONFIG.C_ENABLE_OVERDRIVE {1} \
    CONFIG.C_LLPATH0_TILE {3} \
    CONFIG.C_LLPATH1_TILE {3} \
    CONFIG.C_TILE0_CONFIG {1} \
    CONFIG.C_TILE0_ISP0_CORE_CLK {600.1} \
    CONFIG.C_TILE0_ISP0_GPIO_PS_CHECK {true} \
    CONFIG.C_TILE0_ISP0_GPIO_SELECT {0} \
    CONFIG.C_TILE0_ISP0_IBA0_DATA_FORMAT {12} \
    CONFIG.C_TILE0_ISP0_IBA0_FPS {30} \
    CONFIG.C_TILE0_ISP0_IIC_PS_CHECK {true} \
    CONFIG.C_TILE0_ISP0_IIC_SELECT {0} \
    CONFIG.C_TILE0_ISP0_IO_TYPE {2} \
    CONFIG.C_TILE0_ISP0_LIVE_INPUTS {1} \
    CONFIG.C_TILE0_ISP1_IO_TYPE {0} \
    CONFIG.C_CONFIG_ONLY {false} \
  ] [get_bd_cells visp_ss_tile0]
  set_property -dict [list \
    CONFIG.DATA_WIDTH {32} \
    CONFIG.PROTOCOL {AXI4LITE} \
    CONFIG.ADDR_WIDTH {12} \
  ] [get_bd_intf_pins visp_ss_tile0/S_AXI_LITE]
  set_property -dict [list \
    CONFIG.CATEGORY {noc} \
    CONFIG.MY_CATEGORY {isp} \
    CONFIG.PHYSICAL_CHANNEL {ISP_TO_NOC_NMU} \
    CONFIG.TILE_INDEX {0} \
    CONFIG.INDEX {0} \
  ] [get_bd_intf_pins visp_ss_tile0/TILE0_ISP0_NMU]
  set_property -dict [list \
    CONFIG.ASSOCIATED_BUSIF {S_AXI_LITE} \
    CONFIG.ASSOCIATED_RESET {s_axi_lite_rstn} \
  ] [get_bd_pins visp_ss_tile0/s_axi_lite_aclk]
  set_property -dict [list \
    CONFIG.POLARITY {ACTIVE_LOW} \
  ] [get_bd_pins visp_ss_tile0/s_axi_lite_rstn]
  set_property -dict [list \
    CONFIG.ASSOCIATED_BUSIF {TILE0_ISP0_NMU} \
  ] [get_bd_pins visp_ss_tile0/tile0_nmu0_axi_clk]
  set_property -dict [list \
    CONFIG.POLARITY {ACTIVE_LOW} \
  ] [get_bd_pins visp_ss_tile0/tile0_pl_isp_rstn]
  set_property -dict [list \
    CONFIG.ASSOCIATED_BUSIF {TILE0_ISP_MIPI_VIDIN0} \
  ] [get_bd_pins visp_ss_tile0/tile0_pl_isp_vidin0_clk]

  # New instance: axi_noc2_visp_ss
  if { [get_bd_cells -quiet axi_noc2_visp_ss] eq "" } {
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc2 axi_noc2_visp_ss
    set_property -dict [list \
      CONFIG.MI_FIREWALL_EN {} \
      CONFIG.MI_NAMES {} \
      CONFIG.MI_SIDEBAND_PINS {} \
      CONFIG.NSI_NAMES {} \
      CONFIG.NUM_CLKS {1} \
      CONFIG.NUM_MI {0} \
      CONFIG.NUM_NMI {1} \
      CONFIG.NUM_NSI {0} \
      CONFIG.NUM_SI {1} \
      CONFIG.SI_SIDEBAND_PINS {} \
    ] [get_bd_cells axi_noc2_visp_ss]
    set_property -dict [list \
      CONFIG.DATA_WIDTH {128} \
      CONFIG.CONNECTIONS {M00_INI {read_bw {1100} write_bw {2200} }} \
      CONFIG.DEST_IDS {} \
      CONFIG.NOC_PARAMS {} \
      CONFIG.CATEGORY {isp} \
    ] [get_bd_intf_pins axi_noc2_visp_ss/S00_AXI]
    set_property -dict [list \
      CONFIG.ASSOCIATED_BUSIF {S00_AXI} \
    ] [get_bd_pins axi_noc2_visp_ss/aclk0]
  }

  # New instance: mipi_csi2_rx_subsyst_0
  if { [get_bd_cells -quiet mipi_csi2_rx_subsyst_0] eq "" } {
    create_bd_cell -type ip -vlnv xilinx.com:ip:mipi_csi2_rx_subsystem mipi_csi2_rx_subsyst_0
    set_property -dict [list \
      CONFIG.CMN_NUM_LANES {4} \
      CONFIG.CMN_NUM_PIXELS {4} \
      CONFIG.CMN_PXL_FORMAT {RAW12} \
      CONFIG.CMN_VC {All} \
      CONFIG.CSI_BUF_DEPTH {4096} \
      CONFIG.C_CSI_EN_ACTIVELANES {true} \
      CONFIG.C_CSI_FILTER_USERDATATYPE {true} \
      CONFIG.C_DPHY_LANES {4} \
      CONFIG.C_SPRT_ISP_BRIDGE {true} \
      CONFIG.DPY_EN_REG_IF {true} \
      CONFIG.DPY_LINE_RATE {1500} \
      CONFIG.SupportLevel {1} \
    ] [get_bd_cells mipi_csi2_rx_subsyst_0]
  }

  # New instance: smartconnect_0
  if { [get_bd_cells -quiet smartconnect_0] eq "" } {
    create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect smartconnect_0
    set_property -dict [list \
      CONFIG.NUM_MI {3} \
      CONFIG.NUM_SI {1} \
    ] [get_bd_cells smartconnect_0]
  }

  # New instance: clkx5_wiz_0
  if { [get_bd_cells -quiet clkx5_wiz_0] eq "" } {
    create_bd_cell -type ip -vlnv xilinx.com:ip:clkx5_wiz clkx5_wiz_0
    set_property -dict [list \
      CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {200.000,150,100.000,100.000,100.000,100.000,100.000} \
      CONFIG.CLKOUT_USED {true,true,false,false,false,false,false} \
      CONFIG.RESET_TYPE {ACTIVE_LOW} \
      CONFIG.USE_LOCKED {true} \
      CONFIG.USE_RESET {true} \
    ] [get_bd_cells clkx5_wiz_0]
  }

  # New instance: proc_sys_reset_1
  if { [get_bd_cells -quiet proc_sys_reset_1] eq "" } {
    create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_1
  }

  # New instance: axi_iic_0
  if { [get_bd_cells -quiet axi_iic_0] eq "" } {
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic axi_iic_0
  }

  # New interface connections
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins MIPI1]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_0/mipi_phy_if]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins MIPI1]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_0/mipi_phy_if]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins MIPI1] [get_bd_intf_pins mipi_csi2_rx_subsyst_0/mipi_phy_if] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins S_AXI_LITE]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins smartconnect_0/S00_AXI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins S_AXI_LITE]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins smartconnect_0/S00_AXI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins S_AXI_LITE] [get_bd_intf_pins smartconnect_0/S00_AXI] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_iic_0/IIC]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins IIC_0]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_iic_0/IIC]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins IIC_0]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins axi_iic_0/IIC] [get_bd_intf_pins IIC_0] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_visp_ss/M00_INI]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins M00_INI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_visp_ss/M00_INI]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins M00_INI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins axi_noc2_visp_ss/M00_INI] [get_bd_intf_pins M00_INI] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins visp_ss_tile0/TILE0_ISP_MIPI_VIDIN0]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_0/video_out]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins visp_ss_tile0/TILE0_ISP_MIPI_VIDIN0]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_0/video_out]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins visp_ss_tile0/TILE0_ISP_MIPI_VIDIN0] [get_bd_intf_pins mipi_csi2_rx_subsyst_0/video_out] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins smartconnect_0/M00_AXI]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_iic_0/S_AXI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins smartconnect_0/M00_AXI]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_iic_0/S_AXI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins axi_iic_0/S_AXI] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins smartconnect_0/M01_AXI]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins visp_ss_tile0/S_AXI_LITE]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins smartconnect_0/M01_AXI]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins visp_ss_tile0/S_AXI_LITE]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M01_AXI] [get_bd_intf_pins visp_ss_tile0/S_AXI_LITE] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins smartconnect_0/M02_AXI]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_0/csirxss_s_axi]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins smartconnect_0/M02_AXI]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_0/csirxss_s_axi]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M02_AXI] [get_bd_intf_pins mipi_csi2_rx_subsyst_0/csirxss_s_axi] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins visp_ss_tile0/TILE0_ISP0_NMU]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_visp_ss/S00_AXI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins visp_ss_tile0/TILE0_ISP0_NMU]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_visp_ss/S00_AXI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins visp_ss_tile0/TILE0_ISP0_NMU] [get_bd_intf_pins axi_noc2_visp_ss/S00_AXI] }
  }

  # New net connections
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins tile0_pl_isp_vidin0_clk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_ref_dpll_clk]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins tile0_pl_isp_vidin0_clk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_ref_dpll_clk]]) } {
    catch { connect_bd_net -net Net1 [get_bd_pins tile0_pl_isp_vidin0_clk] [get_bd_pins visp_ss_tile0/tile0_ref_dpll_clk] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins lite_aresetn]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/s_axi_lite_rstn]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins smartconnect_0/aresetn]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/lite_aresetn]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins axi_iic_0/s_axi_aresetn]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins lite_aresetn]] eq [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/s_axi_lite_rstn]] && [get_bd_nets -quiet -of_objects [get_bd_pins lite_aresetn]] eq [get_bd_nets -quiet -of_objects [get_bd_pins smartconnect_0/aresetn]] && [get_bd_nets -quiet -of_objects [get_bd_pins lite_aresetn]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/lite_aresetn]] && [get_bd_nets -quiet -of_objects [get_bd_pins lite_aresetn]] eq [get_bd_nets -quiet -of_objects [get_bd_pins axi_iic_0/s_axi_aresetn]]) } {
    catch { connect_bd_net -net Net2 [get_bd_pins lite_aresetn] [get_bd_pins visp_ss_tile0/s_axi_lite_rstn] [get_bd_pins smartconnect_0/aresetn] [get_bd_pins mipi_csi2_rx_subsyst_0/lite_aresetn] [get_bd_pins axi_iic_0/s_axi_aresetn] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins ext_reset_in]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_1/ext_reset_in]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins clkx5_wiz_0/resetn]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins ext_reset_in]] eq [get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_1/ext_reset_in]] && [get_bd_nets -quiet -of_objects [get_bd_pins ext_reset_in]] eq [get_bd_nets -quiet -of_objects [get_bd_pins clkx5_wiz_0/resetn]]) } {
    catch { connect_bd_net -net Net3 [get_bd_pins ext_reset_in] [get_bd_pins proc_sys_reset_1/ext_reset_in] [get_bd_pins clkx5_wiz_0/resetn] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins axi_iic_0/iic2intc_irpt]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins iic2intc_irpt]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins axi_iic_0/iic2intc_irpt]] eq [get_bd_nets -quiet -of_objects [get_bd_pins iic2intc_irpt]]) } {
    catch { connect_bd_net -net axi_iic_0_iic2intc_irpt [get_bd_pins axi_iic_0/iic2intc_irpt] [get_bd_pins iic2intc_irpt] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins clkx5_wiz_0/clk_out1]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/dphy_clk_200M]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins clkx5_wiz_0/clk_out1]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/dphy_clk_200M]]) } {
    catch { connect_bd_net -net clkx5_wiz_0_dphy_clk_200M [get_bd_pins clkx5_wiz_0/clk_out1] [get_bd_pins mipi_csi2_rx_subsyst_0/dphy_clk_200M] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins clkx5_wiz_0/locked]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_1/dcm_locked]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins clkx5_wiz_0/locked]] eq [get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_1/dcm_locked]]) } {
    catch { connect_bd_net -net clkx5_wiz_0_locked [get_bd_pins clkx5_wiz_0/locked] [get_bd_pins proc_sys_reset_1/dcm_locked] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/csirxss_csi_irq]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins csirxss_csi_irq]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/csirxss_csi_irq]] eq [get_bd_nets -quiet -of_objects [get_bd_pins csirxss_csi_irq]]) } {
    catch { connect_bd_net -net mipi_csi2_rx_subsyst_0_csirxss_csi_irq [get_bd_pins mipi_csi2_rx_subsyst_0/csirxss_csi_irq] [get_bd_pins csirxss_csi_irq] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/header_data]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp_mipi_vidin0_header_data]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/header_data]] eq [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp_mipi_vidin0_header_data]]) } {
    catch { connect_bd_net -net mipi_csi2_rx_subsyst_0_header_data [get_bd_pins mipi_csi2_rx_subsyst_0/header_data] [get_bd_pins visp_ss_tile0/tile0_isp_mipi_vidin0_header_data] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/header_valid]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp_mipi_vidin0_header_valid]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/header_valid]] eq [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp_mipi_vidin0_header_valid]]) } {
    catch { connect_bd_net -net mipi_csi2_rx_subsyst_0_header_valid [get_bd_pins mipi_csi2_rx_subsyst_0/header_valid] [get_bd_pins visp_ss_tile0/tile0_isp_mipi_vidin0_header_valid] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins clkx5_wiz_0/clk_out2]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_1/slowest_sync_clk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/video_aclk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_pl_isp_vidin0_clk]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins clkx5_wiz_0/clk_out2]] eq [get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_1/slowest_sync_clk]] && [get_bd_nets -quiet -of_objects [get_bd_pins clkx5_wiz_0/clk_out2]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/video_aclk]] && [get_bd_nets -quiet -of_objects [get_bd_pins clkx5_wiz_0/clk_out2]] eq [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_pl_isp_vidin0_clk]]) } {
    catch { connect_bd_net -net ps_wizard_0_pl1_ref_clk [get_bd_pins clkx5_wiz_0/clk_out2] [get_bd_pins proc_sys_reset_1/slowest_sync_clk] [get_bd_pins mipi_csi2_rx_subsyst_0/video_aclk] [get_bd_pins visp_ss_tile0/tile0_pl_isp_vidin0_clk] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins s_axi_aclk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins axi_iic_0/s_axi_aclk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins clkx5_wiz_0/clk_in1]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins smartconnect_0/aclk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/s_axi_lite_aclk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/lite_aclk]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins s_axi_aclk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins axi_iic_0/s_axi_aclk]] && [get_bd_nets -quiet -of_objects [get_bd_pins s_axi_aclk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins clkx5_wiz_0/clk_in1]] && [get_bd_nets -quiet -of_objects [get_bd_pins s_axi_aclk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins smartconnect_0/aclk]] && [get_bd_nets -quiet -of_objects [get_bd_pins s_axi_aclk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/s_axi_lite_aclk]] && [get_bd_nets -quiet -of_objects [get_bd_pins s_axi_aclk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/lite_aclk]]) } {
    catch { connect_bd_net -net s_axi_aclk_1 [get_bd_pins s_axi_aclk] [get_bd_pins axi_iic_0/s_axi_aclk] [get_bd_pins clkx5_wiz_0/clk_in1] [get_bd_pins smartconnect_0/aclk] [get_bd_pins visp_ss_tile0/s_axi_lite_aclk] [get_bd_pins mipi_csi2_rx_subsyst_0/lite_aclk] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_1/peripheral_aresetn]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_pl_isp_rstn]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/video_aresetn]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_1/peripheral_aresetn]] eq [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_pl_isp_rstn]] && [get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_1/peripheral_aresetn]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/video_aresetn]]) } {
    catch { connect_bd_net -net s_axi_aresetn [get_bd_pins proc_sys_reset_1/peripheral_aresetn] [get_bd_pins visp_ss_tile0/tile0_pl_isp_rstn] [get_bd_pins mipi_csi2_rx_subsyst_0/video_aresetn] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp0_fusa_irq]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins tile0_isp0_fusa_irq]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp0_fusa_irq]] eq [get_bd_nets -quiet -of_objects [get_bd_pins tile0_isp0_fusa_irq]]) } {
    catch { connect_bd_net -net visp_ss_tile0_tile0_isp0_fusa_irq [get_bd_pins visp_ss_tile0/tile0_isp0_fusa_irq] [get_bd_pins tile0_isp0_fusa_irq] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp0_isp_irq]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins tile0_isp0_isp_irq]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp0_isp_irq]] eq [get_bd_nets -quiet -of_objects [get_bd_pins tile0_isp0_isp_irq]]) } {
    catch { connect_bd_net -net visp_ss_tile0_tile0_isp0_isp_irq [get_bd_pins visp_ss_tile0/tile0_isp0_isp_irq] [get_bd_pins tile0_isp0_isp_irq] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp_isr_irq]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins tile0_isp_isr_irq]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp_isr_irq]] eq [get_bd_nets -quiet -of_objects [get_bd_pins tile0_isp_isr_irq]]) } {
    catch { connect_bd_net -net visp_ss_tile0_tile0_isp_isr_irq [get_bd_pins visp_ss_tile0/tile0_isp_isr_irq] [get_bd_pins tile0_isp_isr_irq] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp_xmpu_interrupt]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins tile0_isp_xmpu_interrupt]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp_xmpu_interrupt]] eq [get_bd_nets -quiet -of_objects [get_bd_pins tile0_isp_xmpu_interrupt]]) } {
    catch { connect_bd_net -net visp_ss_tile0_tile0_isp_xmpu_interrupt [get_bd_pins visp_ss_tile0/tile0_isp_xmpu_interrupt] [get_bd_pins tile0_isp_xmpu_interrupt] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_nmu0_axi_clk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins axi_noc2_visp_ss/aclk0]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_nmu0_axi_clk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins axi_noc2_visp_ss/aclk0]]) } {
    catch { connect_bd_net -net visp_ss_tile0_tile0_nmu0_axi_clk [get_bd_pins visp_ss_tile0/tile0_nmu0_axi_clk] [get_bd_pins axi_noc2_visp_ss/aclk0] }
  }

  current_bd_instance $oldCurInst
}

# Auto-execute: Update ISP_hier when this script is sourced
puts "Updating ISP_hier..."
update_ISP_hier / ISP_hier
puts "ISP_hier updated successfully."

# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------

proc update_ISP_hier { parentCell nameHier } {

  set oldCurInst [current_bd_instance .]
  current_bd_instance $parentCell/$nameHier

  # New interface pins
  if { [get_bd_intf_pins -quiet S00_AXI] eq "" } {
    create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI
  }
  if { [get_bd_intf_pins -quiet M00_INI] eq "" } {
    create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M00_INI
  }
  if { [get_bd_intf_pins -quiet mipi_phy_if_0] eq "" } {
    create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:mipi_phy_rtl:1.0 mipi_phy_if_0
  }
  if { [get_bd_intf_pins -quiet mipi_phy_if_1] eq "" } {
    create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:mipi_phy_rtl:1.0 mipi_phy_if_1
  }
  if { [get_bd_intf_pins -quiet M00_INI1] eq "" } {
    create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M00_INI1
  }
  if { [get_bd_intf_pins -quiet mipi_phy_if_2] eq "" } {
    create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:mipi_phy_rtl:1.0 mipi_phy_if_2
  }
  if { [get_bd_intf_pins -quiet mipi_phy_if_3] eq "" } {
    create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:mipi_phy_rtl:1.0 mipi_phy_if_3
  }

  # New pins
  if { [get_bd_pins -quiet video_aclk] eq "" } {
    create_bd_pin -dir I -type clk video_aclk
  }
  if { [get_bd_pins -quiet ext_reset_in] eq "" } {
    create_bd_pin -dir I -type rst ext_reset_in
  }
  if { [get_bd_pins -quiet tile0_ref_dpll_clk] eq "" } {
    create_bd_pin -dir I -type clk tile0_ref_dpll_clk
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
  if { [get_bd_pins -quiet irq] eq "" } {
    create_bd_pin -dir O irq
  }
  if { [get_bd_pins -quiet dphy_clk_200M] eq "" } {
    create_bd_pin -dir I -type clk dphy_clk_200M
  }
  if { [get_bd_pins -quiet tile0_isp1_fusa_irq] eq "" } {
    create_bd_pin -dir O -type intr tile0_isp1_fusa_irq
  }
  if { [get_bd_pins -quiet tile0_isp1_isp_irq] eq "" } {
    create_bd_pin -dir O -type intr tile0_isp1_isp_irq
  }
  if { [get_bd_pins -quiet tile1_isp_isr_irq] eq "" } {
    create_bd_pin -dir O -type intr tile1_isp_isr_irq
  }
  if { [get_bd_pins -quiet tile1_isp_xmpu_interrupt] eq "" } {
    create_bd_pin -dir O -type intr tile1_isp_xmpu_interrupt
  }
  if { [get_bd_pins -quiet tile1_isp0_fusa_irq] eq "" } {
    create_bd_pin -dir O -type intr tile1_isp0_fusa_irq
  }
  if { [get_bd_pins -quiet tile1_isp0_isp_irq] eq "" } {
    create_bd_pin -dir O -type intr tile1_isp0_isp_irq
  }
  if { [get_bd_pins -quiet tile1_isp1_fusa_irq] eq "" } {
    create_bd_pin -dir O -type intr tile1_isp1_fusa_irq
  }
  if { [get_bd_pins -quiet tile1_isp1_isp_irq] eq "" } {
    create_bd_pin -dir O -type intr tile1_isp1_isp_irq
  }
  if { [get_bd_pins -quiet peripheral_aresetn] eq "" } {
    create_bd_pin -dir O -type rst -from 0 -to 0 peripheral_aresetn
  }

  # Update: visp_ss_tile0
  set_property -dict [list \
    CONFIG.C_ENABLE_OVERDRIVE {1} \
    CONFIG.C_TILE0_CONFIG {1} \
    CONFIG.C_TILE0_ISP0_CORE_CLK {600.1} \
    CONFIG.C_TILE0_ISP0_GPIO_PS_CHECK {true} \
    CONFIG.C_TILE0_ISP0_GPIO_SELECT {0} \
    CONFIG.C_TILE0_ISP0_IBA0_DATA_FORMAT {12} \
    CONFIG.C_TILE0_ISP0_IBA0_FPS {30} \
    CONFIG.C_TILE0_ISP0_IBA0_RES_HOR {3840} \
    CONFIG.C_TILE0_ISP0_IBA0_RES_VER {2160} \
    CONFIG.C_TILE0_ISP0_IBA0_VCID {0} \
    CONFIG.C_TILE0_ISP0_IBA1_RES_HOR {3840} \
    CONFIG.C_TILE0_ISP0_IBA1_RES_VER {2160} \
    CONFIG.C_TILE0_ISP0_IBA2_RES_HOR {3840} \
    CONFIG.C_TILE0_ISP0_IBA2_RES_VER {2160} \
    CONFIG.C_TILE0_ISP0_IBA2_VCID {0} \
    CONFIG.C_TILE0_ISP0_IBA3_RES_HOR {3840} \
    CONFIG.C_TILE0_ISP0_IBA3_RES_VER {2160} \
    CONFIG.C_TILE0_ISP0_IBA3_VCID {0} \
    CONFIG.C_TILE0_ISP0_IIC_PS_CHECK {true} \
    CONFIG.C_TILE0_ISP0_IIC_SELECT {0} \
    CONFIG.C_TILE0_ISP0_IO_TYPE {2} \
    CONFIG.C_TILE0_ISP0_LIVE_INPUTS {1} \
    CONFIG.C_TILE0_ISP1_CORE_CLK {600.1} \
    CONFIG.C_TILE0_ISP1_GPIO_PS_CHECK {true} \
    CONFIG.C_TILE0_ISP1_GPIO_SELECT {1} \
    CONFIG.C_TILE0_ISP1_IBA4_DATA_FORMAT {12} \
    CONFIG.C_TILE0_ISP1_IBA4_FPS {30} \
    CONFIG.C_TILE0_ISP1_IBA4_VCID {0} \
    CONFIG.C_TILE0_ISP1_IIC_PS_CHECK {true} \
    CONFIG.C_TILE0_ISP1_IIC_SELECT {1} \
    CONFIG.C_TILE0_ISP1_IO_TYPE {2} \
    CONFIG.C_TILE1_CONFIG {1} \
    CONFIG.C_TILE1_ENABLE {true} \
    CONFIG.C_TILE1_ISP0_CORE_CLK {600.1} \
    CONFIG.C_TILE1_ISP0_GPIO_PS_CHECK {true} \
    CONFIG.C_TILE1_ISP0_GPIO_SELECT {0} \
    CONFIG.C_TILE1_ISP0_IBA0_DATA_FORMAT {12} \
    CONFIG.C_TILE1_ISP0_IBA0_FPS {30} \
    CONFIG.C_TILE1_ISP0_IIC_PS_CHECK {true} \
    CONFIG.C_TILE1_ISP0_IIC_SELECT {0} \
    CONFIG.C_TILE1_ISP0_IO_TYPE {2} \
    CONFIG.C_TILE1_ISP0_LIVE_INPUTS {1} \
    CONFIG.C_TILE1_ISP1_CORE_CLK {600.1} \
    CONFIG.C_TILE1_ISP1_GPIO_PS_CHECK {true} \
    CONFIG.C_TILE1_ISP1_GPIO_SELECT {1} \
    CONFIG.C_TILE1_ISP1_IBA4_DATA_FORMAT {12} \
    CONFIG.C_TILE1_ISP1_IBA4_FPS {30} \
    CONFIG.C_TILE1_ISP1_IBA4_VCID {0} \
    CONFIG.C_TILE1_ISP1_IIC_PS_CHECK {true} \
    CONFIG.C_TILE1_ISP1_IIC_SELECT {1} \
    CONFIG.C_TILE1_ISP1_IO_TYPE {2} \
    CONFIG.C_TILE1_ISP1_RPU {7} \
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
    CONFIG.CATEGORY {noc} \
    CONFIG.MY_CATEGORY {isp} \
    CONFIG.PHYSICAL_CHANNEL {ISP_TO_NOC_NMU} \
    CONFIG.TILE_INDEX {0} \
    CONFIG.INDEX {1} \
  ] [get_bd_intf_pins visp_ss_tile0/TILE0_ISP1_NMU]
  set_property -dict [list \
    CONFIG.CATEGORY {noc} \
    CONFIG.MY_CATEGORY {isp} \
    CONFIG.PHYSICAL_CHANNEL {ISP_TO_NOC_NMU} \
    CONFIG.TILE_INDEX {1} \
    CONFIG.INDEX {0} \
  ] [get_bd_intf_pins visp_ss_tile0/TILE1_ISP0_NMU]
  set_property -dict [list \
    CONFIG.CATEGORY {noc} \
    CONFIG.MY_CATEGORY {isp} \
    CONFIG.PHYSICAL_CHANNEL {ISP_TO_NOC_NMU} \
    CONFIG.TILE_INDEX {1} \
    CONFIG.INDEX {1} \
  ] [get_bd_intf_pins visp_ss_tile0/TILE1_ISP1_NMU]
  set_property -dict [list \
    CONFIG.CATEGORY {noc} \
    CONFIG.MY_CATEGORY {isp} \
    CONFIG.PHYSICAL_CHANNEL {NOC_NSU_TO_ISP} \
    CONFIG.TILE_INDEX {1} \
    CONFIG.INDEX {0} \
  ] [get_bd_intf_pins visp_ss_tile0/TILE1_ISP_NSU]
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
    CONFIG.ASSOCIATED_BUSIF {TILE0_ISP1_NMU} \
  ] [get_bd_pins visp_ss_tile0/tile0_nmu1_axi_clk]
  set_property -dict [list \
    CONFIG.POLARITY {ACTIVE_LOW} \
  ] [get_bd_pins visp_ss_tile0/tile0_pl_isp_rstn]
  set_property -dict [list \
    CONFIG.ASSOCIATED_BUSIF {TILE0_ISP_MIPI_VIDIN0} \
  ] [get_bd_pins visp_ss_tile0/tile0_pl_isp_vidin0_clk]
  set_property -dict [list \
    CONFIG.ASSOCIATED_BUSIF {TILE0_ISP_MIPI_VIDIN4} \
  ] [get_bd_pins visp_ss_tile0/tile0_pl_isp_vidin4_clk]
  set_property -dict [list \
    CONFIG.ASSOCIATED_BUSIF {TILE1_ISP0_NMU} \
  ] [get_bd_pins visp_ss_tile0/tile1_nmu0_axi_clk]
  set_property -dict [list \
    CONFIG.ASSOCIATED_BUSIF {TILE1_ISP1_NMU} \
  ] [get_bd_pins visp_ss_tile0/tile1_nmu1_axi_clk]
  set_property -dict [list \
    CONFIG.ASSOCIATED_BUSIF {TILE1_ISP_NSU} \
  ] [get_bd_pins visp_ss_tile0/tile1_nsu_axi_clk]
  set_property -dict [list \
    CONFIG.POLARITY {ACTIVE_LOW} \
  ] [get_bd_pins visp_ss_tile0/tile1_pl_isp_rstn]
  set_property -dict [list \
    CONFIG.ASSOCIATED_BUSIF {TILE1_ISP_MIPI_VIDIN0} \
  ] [get_bd_pins visp_ss_tile0/tile1_pl_isp_vidin0_clk]
  set_property -dict [list \
    CONFIG.ASSOCIATED_BUSIF {TILE1_ISP_MIPI_VIDIN4} \
  ] [get_bd_pins visp_ss_tile0/tile1_pl_isp_vidin4_clk]

  # New instance: axi_noc2_0
  if { [get_bd_cells -quiet axi_noc2_0] eq "" } {
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc2:1.1 axi_noc2_0
    set_property -dict [list \
      CONFIG.MI_SIDEBAND_PINS {} \
      CONFIG.NUM_CLKS {4} \
      CONFIG.NUM_MI {0} \
      CONFIG.NUM_NMI {2} \
      CONFIG.NUM_NSI {0} \
      CONFIG.NUM_SI {4} \
      CONFIG.SI_SIDEBAND_PINS {} \
    ] [get_bd_cells axi_noc2_0]
    set_property -dict [list \
      CONFIG.DATA_WIDTH {128} \
      CONFIG.R_TRAFFIC_CLASS {ISOCHRONOUS} \
      CONFIG.W_TRAFFIC_CLASS {ISOCHRONOUS} \
      CONFIG.CONNECTIONS {M00_INI {read_bw {1075} write_bw {2150} }} \
      CONFIG.DEST_IDS {} \
      CONFIG.NOC_PARAMS {} \
      CONFIG.CATEGORY {isp} \
    ] [get_bd_intf_pins axi_noc2_0/S00_AXI]
    set_property -dict [list \
      CONFIG.DATA_WIDTH {128} \
      CONFIG.R_TRAFFIC_CLASS {ISOCHRONOUS} \
      CONFIG.W_TRAFFIC_CLASS {ISOCHRONOUS} \
      CONFIG.CONNECTIONS {M00_INI {read_bw {1075} write_bw {2150} }} \
      CONFIG.DEST_IDS {} \
      CONFIG.NOC_PARAMS {} \
      CONFIG.CATEGORY {isp} \
    ] [get_bd_intf_pins axi_noc2_0/S01_AXI]
    set_property -dict [list \
      CONFIG.DATA_WIDTH {128} \
      CONFIG.R_TRAFFIC_CLASS {ISOCHRONOUS} \
      CONFIG.W_TRAFFIC_CLASS {ISOCHRONOUS} \
      CONFIG.CONNECTIONS {M01_INI {read_bw {1075} write_bw {2150} }} \
      CONFIG.DEST_IDS {} \
      CONFIG.NOC_PARAMS {} \
      CONFIG.CATEGORY {isp} \
    ] [get_bd_intf_pins axi_noc2_0/S02_AXI]
    set_property -dict [list \
      CONFIG.DATA_WIDTH {128} \
      CONFIG.R_TRAFFIC_CLASS {ISOCHRONOUS} \
      CONFIG.W_TRAFFIC_CLASS {ISOCHRONOUS} \
      CONFIG.CONNECTIONS {M01_INI {read_bw {1075} write_bw {2150} }} \
      CONFIG.DEST_IDS {} \
      CONFIG.NOC_PARAMS {} \
      CONFIG.CATEGORY {isp} \
    ] [get_bd_intf_pins axi_noc2_0/S03_AXI]
    set_property -dict [list \
      CONFIG.ASSOCIATED_BUSIF {S00_AXI} \
    ] [get_bd_pins axi_noc2_0/aclk0]
    set_property -dict [list \
      CONFIG.ASSOCIATED_BUSIF {S01_AXI} \
    ] [get_bd_pins axi_noc2_0/aclk1]
    set_property -dict [list \
      CONFIG.ASSOCIATED_BUSIF {S02_AXI} \
    ] [get_bd_pins axi_noc2_0/aclk2]
    set_property -dict [list \
      CONFIG.ASSOCIATED_BUSIF {S03_AXI} \
    ] [get_bd_pins axi_noc2_0/aclk3]
  }

  # New instance: smartconnect_1
  if { [get_bd_cells -quiet smartconnect_1] eq "" } {
    create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_1
    set_property -dict [list \
      CONFIG.ADVANCED_PROPERTIES {__experimental_features__ {legacy_low_area_mode 1}} \
      CONFIG.NUM_MI {7} \
      CONFIG.NUM_SI {1} \
    ] [get_bd_cells smartconnect_1]
  }

  # New instance: axi_intc_0
  if { [get_bd_cells -quiet axi_intc_0] eq "" } {
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc:4.1 axi_intc_0
  }

  # New instance: ilconcat_0
  if { [get_bd_cells -quiet ilconcat_0] eq "" } {
    create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat:1.0 ilconcat_0
    set_property -dict [list \
      CONFIG.NUM_PORTS {4} \
    ] [get_bd_cells ilconcat_0]
  }

  # New instance: proc_sys_reset_0
  if { [get_bd_cells -quiet proc_sys_reset_0] eq "" } {
    create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0
  }

  # New instance: mipi_csi2_rx_subsyst_0
  if { [get_bd_cells -quiet mipi_csi2_rx_subsyst_0] eq "" } {
    create_bd_cell -type ip -vlnv xilinx.com:ip:mipi_csi2_rx_subsystem:6.0 mipi_csi2_rx_subsyst_0
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

  # New instance: mipi_csi2_rx_subsyst_1
  if { [get_bd_cells -quiet mipi_csi2_rx_subsyst_1] eq "" } {
    create_bd_cell -type ip -vlnv xilinx.com:ip:mipi_csi2_rx_subsystem:6.0 mipi_csi2_rx_subsyst_1
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
    ] [get_bd_cells mipi_csi2_rx_subsyst_1]
  }

  # New instance: mipi_csi2_rx_subsyst_2
  if { [get_bd_cells -quiet mipi_csi2_rx_subsyst_2] eq "" } {
    create_bd_cell -type ip -vlnv xilinx.com:ip:mipi_csi2_rx_subsystem:6.0 mipi_csi2_rx_subsyst_2
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
    ] [get_bd_cells mipi_csi2_rx_subsyst_2]
  }

  # New instance: mipi_csi2_rx_subsyst_3
  if { [get_bd_cells -quiet mipi_csi2_rx_subsyst_3] eq "" } {
    create_bd_cell -type ip -vlnv xilinx.com:ip:mipi_csi2_rx_subsystem:6.0 mipi_csi2_rx_subsyst_3
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
      CONFIG.SupportLevel {0} \
    ] [get_bd_cells mipi_csi2_rx_subsyst_3]
  }

  # New interface connections
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_0/M00_INI]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins M00_INI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_0/M00_INI]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins M00_INI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins axi_noc2_0/M00_INI] [get_bd_intf_pins M00_INI] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_0/mipi_phy_if]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_phy_if_0]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_0/mipi_phy_if]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_phy_if_0]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins mipi_csi2_rx_subsyst_0/mipi_phy_if] [get_bd_intf_pins mipi_phy_if_0] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins smartconnect_1/S00_AXI]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins S00_AXI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins smartconnect_1/S00_AXI]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins S00_AXI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins smartconnect_1/S00_AXI] [get_bd_intf_pins S00_AXI] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_phy_if_1]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_1/mipi_phy_if]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_phy_if_1]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_1/mipi_phy_if]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins mipi_phy_if_1] [get_bd_intf_pins mipi_csi2_rx_subsyst_1/mipi_phy_if] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_2/mipi_phy_if]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_phy_if_2]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_2/mipi_phy_if]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_phy_if_2]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins mipi_csi2_rx_subsyst_2/mipi_phy_if] [get_bd_intf_pins mipi_phy_if_2] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_3/mipi_phy_if]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_phy_if_3]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_3/mipi_phy_if]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_phy_if_3]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins mipi_csi2_rx_subsyst_3/mipi_phy_if] [get_bd_intf_pins mipi_phy_if_3] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_0/M01_INI]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins M00_INI1]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_0/M01_INI]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins M00_INI1]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins axi_noc2_0/M01_INI] [get_bd_intf_pins M00_INI1] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins visp_ss_tile0/TILE0_ISP_MIPI_VIDIN0]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_0/video_out]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins visp_ss_tile0/TILE0_ISP_MIPI_VIDIN0]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_0/video_out]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins visp_ss_tile0/TILE0_ISP_MIPI_VIDIN0] [get_bd_intf_pins mipi_csi2_rx_subsyst_0/video_out] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_1/video_out]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins visp_ss_tile0/TILE0_ISP_MIPI_VIDIN4]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_1/video_out]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins visp_ss_tile0/TILE0_ISP_MIPI_VIDIN4]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins mipi_csi2_rx_subsyst_1/video_out] [get_bd_intf_pins visp_ss_tile0/TILE0_ISP_MIPI_VIDIN4] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins visp_ss_tile0/TILE1_ISP_MIPI_VIDIN0]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_2/video_out]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins visp_ss_tile0/TILE1_ISP_MIPI_VIDIN0]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_2/video_out]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins visp_ss_tile0/TILE1_ISP_MIPI_VIDIN0] [get_bd_intf_pins mipi_csi2_rx_subsyst_2/video_out] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_3/video_out]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins visp_ss_tile0/TILE1_ISP_MIPI_VIDIN4]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_3/video_out]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins visp_ss_tile0/TILE1_ISP_MIPI_VIDIN4]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins mipi_csi2_rx_subsyst_3/video_out] [get_bd_intf_pins visp_ss_tile0/TILE1_ISP_MIPI_VIDIN4] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins smartconnect_1/M00_AXI]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_0/csirxss_s_axi]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins smartconnect_1/M00_AXI]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_0/csirxss_s_axi]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins smartconnect_1/M00_AXI] [get_bd_intf_pins mipi_csi2_rx_subsyst_0/csirxss_s_axi] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins smartconnect_1/M01_AXI]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_1/csirxss_s_axi]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins smartconnect_1/M01_AXI]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_1/csirxss_s_axi]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins smartconnect_1/M01_AXI] [get_bd_intf_pins mipi_csi2_rx_subsyst_1/csirxss_s_axi] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins smartconnect_1/M02_AXI]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins visp_ss_tile0/S_AXI_LITE]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins smartconnect_1/M02_AXI]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins visp_ss_tile0/S_AXI_LITE]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins smartconnect_1/M02_AXI] [get_bd_intf_pins visp_ss_tile0/S_AXI_LITE] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins smartconnect_1/M03_AXI]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_intc_0/s_axi]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins smartconnect_1/M03_AXI]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_intc_0/s_axi]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins smartconnect_1/M03_AXI] [get_bd_intf_pins axi_intc_0/s_axi] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins smartconnect_1/M05_AXI]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_2/csirxss_s_axi]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins smartconnect_1/M05_AXI]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_2/csirxss_s_axi]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins smartconnect_1/M05_AXI] [get_bd_intf_pins mipi_csi2_rx_subsyst_2/csirxss_s_axi] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_3/csirxss_s_axi]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins smartconnect_1/M06_AXI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins mipi_csi2_rx_subsyst_3/csirxss_s_axi]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins smartconnect_1/M06_AXI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins mipi_csi2_rx_subsyst_3/csirxss_s_axi] [get_bd_intf_pins smartconnect_1/M06_AXI] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins visp_ss_tile0/TILE0_ISP0_NMU]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_0/S00_AXI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins visp_ss_tile0/TILE0_ISP0_NMU]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_0/S00_AXI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins visp_ss_tile0/TILE0_ISP0_NMU] [get_bd_intf_pins axi_noc2_0/S00_AXI] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins visp_ss_tile0/TILE0_ISP1_NMU]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_0/S01_AXI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins visp_ss_tile0/TILE0_ISP1_NMU]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_0/S01_AXI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins visp_ss_tile0/TILE0_ISP1_NMU] [get_bd_intf_pins axi_noc2_0/S01_AXI] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins visp_ss_tile0/TILE1_ISP0_NMU]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_0/S02_AXI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins visp_ss_tile0/TILE1_ISP0_NMU]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_0/S02_AXI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins visp_ss_tile0/TILE1_ISP0_NMU] [get_bd_intf_pins axi_noc2_0/S02_AXI] }
  }
  if { ([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins visp_ss_tile0/TILE1_ISP1_NMU]] eq "" || [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_0/S03_AXI]] eq "") || !([get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins visp_ss_tile0/TILE1_ISP1_NMU]] eq [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_noc2_0/S03_AXI]]) } {
    catch { connect_bd_intf_net [get_bd_intf_pins visp_ss_tile0/TILE1_ISP1_NMU] [get_bd_intf_pins axi_noc2_0/S03_AXI] }
  }

  # New net connections
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins dphy_clk_200M]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/dphy_clk_200M]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_1/dphy_clk_200M]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_2/dphy_clk_200M]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_3/dphy_clk_200M]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins dphy_clk_200M]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/dphy_clk_200M]] && [get_bd_nets -quiet -of_objects [get_bd_pins dphy_clk_200M]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_1/dphy_clk_200M]] && [get_bd_nets -quiet -of_objects [get_bd_pins dphy_clk_200M]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_2/dphy_clk_200M]] && [get_bd_nets -quiet -of_objects [get_bd_pins dphy_clk_200M]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_3/dphy_clk_200M]]) } {
    catch { connect_bd_net -net Net [get_bd_pins dphy_clk_200M] [get_bd_pins mipi_csi2_rx_subsyst_0/dphy_clk_200M] [get_bd_pins mipi_csi2_rx_subsyst_1/dphy_clk_200M] [get_bd_pins mipi_csi2_rx_subsyst_2/dphy_clk_200M] [get_bd_pins mipi_csi2_rx_subsyst_3/dphy_clk_200M] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins axi_intc_0/irq]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins irq]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins axi_intc_0/irq]] eq [get_bd_nets -quiet -of_objects [get_bd_pins irq]]) } {
    catch { connect_bd_net -net axi_intc_0_irq [get_bd_pins axi_intc_0/irq] [get_bd_pins irq] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins ext_reset_in]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_0/ext_reset_in]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins ext_reset_in]] eq [get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_0/ext_reset_in]]) } {
    catch { connect_bd_net -net ext_reset_in_1 [get_bd_pins ext_reset_in] [get_bd_pins proc_sys_reset_0/ext_reset_in] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins ilconcat_0/dout]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins axi_intc_0/intr]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins ilconcat_0/dout]] eq [get_bd_nets -quiet -of_objects [get_bd_pins axi_intc_0/intr]]) } {
    catch { connect_bd_net -net ilconcat_0_dout [get_bd_pins ilconcat_0/dout] [get_bd_pins axi_intc_0/intr] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/csirxss_csi_irq]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins ilconcat_0/In0]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/csirxss_csi_irq]] eq [get_bd_nets -quiet -of_objects [get_bd_pins ilconcat_0/In0]]) } {
    catch { connect_bd_net -net mipi_csi2_rx_subsyst_0_csirxss_csi_irq [get_bd_pins mipi_csi2_rx_subsyst_0/csirxss_csi_irq] [get_bd_pins ilconcat_0/In0] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_1/clkoutphy_out]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_3/shared_pll_clkoutphy_in]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_1/clkoutphy_out]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_3/shared_pll_clkoutphy_in]]) } {
    catch { connect_bd_net -net mipi_csi2_rx_subsyst_1_clkoutphy_out [get_bd_pins mipi_csi2_rx_subsyst_1/clkoutphy_out] [get_bd_pins mipi_csi2_rx_subsyst_3/shared_pll_clkoutphy_in] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_1/cnts_rxwordclkhs_out]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_3/cnts_rxwordclkhs_in]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_1/cnts_rxwordclkhs_out]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_3/cnts_rxwordclkhs_in]]) } {
    catch { connect_bd_net -net mipi_csi2_rx_subsyst_1_cnts_rxwordclkhs_out [get_bd_pins mipi_csi2_rx_subsyst_1/cnts_rxwordclkhs_out] [get_bd_pins mipi_csi2_rx_subsyst_3/cnts_rxwordclkhs_in] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_1/csirxss_csi_irq]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins ilconcat_0/In1]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_1/csirxss_csi_irq]] eq [get_bd_nets -quiet -of_objects [get_bd_pins ilconcat_0/In1]]) } {
    catch { connect_bd_net -net mipi_csi2_rx_subsyst_1_csirxss_csi_irq [get_bd_pins mipi_csi2_rx_subsyst_1/csirxss_csi_irq] [get_bd_pins ilconcat_0/In1] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_1/header_data]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp_mipi_vidin4_header_data]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_1/header_data]] eq [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp_mipi_vidin4_header_data]]) } {
    catch { connect_bd_net -net mipi_csi2_rx_subsyst_1_header_data [get_bd_pins mipi_csi2_rx_subsyst_1/header_data] [get_bd_pins visp_ss_tile0/tile0_isp_mipi_vidin4_header_data] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_1/header_valid]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp_mipi_vidin4_header_valid]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_1/header_valid]] eq [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp_mipi_vidin4_header_valid]]) } {
    catch { connect_bd_net -net mipi_csi2_rx_subsyst_1_header_valid [get_bd_pins mipi_csi2_rx_subsyst_1/header_valid] [get_bd_pins visp_ss_tile0/tile0_isp_mipi_vidin4_header_valid] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_1/pll_clkoutphy_90_out]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_3/shared_pll_clkoutphy_90_in]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_1/pll_clkoutphy_90_out]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_3/shared_pll_clkoutphy_90_in]]) } {
    catch { connect_bd_net -net mipi_csi2_rx_subsyst_1_pll_clkoutphy_90_out [get_bd_pins mipi_csi2_rx_subsyst_1/pll_clkoutphy_90_out] [get_bd_pins mipi_csi2_rx_subsyst_3/shared_pll_clkoutphy_90_in] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_1/pll_lock_out]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_3/shared_pll_locked_in]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_1/pll_lock_out]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_3/shared_pll_locked_in]]) } {
    catch { connect_bd_net -net mipi_csi2_rx_subsyst_1_pll_lock_out [get_bd_pins mipi_csi2_rx_subsyst_1/pll_lock_out] [get_bd_pins mipi_csi2_rx_subsyst_3/shared_pll_locked_in] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_2/csirxss_csi_irq]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins ilconcat_0/In2]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_2/csirxss_csi_irq]] eq [get_bd_nets -quiet -of_objects [get_bd_pins ilconcat_0/In2]]) } {
    catch { connect_bd_net -net mipi_csi2_rx_subsyst_2_csirxss_csi_irq [get_bd_pins mipi_csi2_rx_subsyst_2/csirxss_csi_irq] [get_bd_pins ilconcat_0/In2] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_2/header_data]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_isp_mipi_vidin0_header_data]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_2/header_data]] eq [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_isp_mipi_vidin0_header_data]]) } {
    catch { connect_bd_net -net mipi_csi2_rx_subsyst_2_header_data [get_bd_pins mipi_csi2_rx_subsyst_2/header_data] [get_bd_pins visp_ss_tile0/tile1_isp_mipi_vidin0_header_data] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_2/header_valid]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_isp_mipi_vidin0_header_valid]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_2/header_valid]] eq [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_isp_mipi_vidin0_header_valid]]) } {
    catch { connect_bd_net -net mipi_csi2_rx_subsyst_2_header_valid [get_bd_pins mipi_csi2_rx_subsyst_2/header_valid] [get_bd_pins visp_ss_tile0/tile1_isp_mipi_vidin0_header_valid] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_3/header_data]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_isp_mipi_vidin4_header_data]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_3/header_data]] eq [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_isp_mipi_vidin4_header_data]]) } {
    catch { connect_bd_net -net mipi_csi2_rx_subsyst_3_header_data [get_bd_pins mipi_csi2_rx_subsyst_3/header_data] [get_bd_pins visp_ss_tile0/tile1_isp_mipi_vidin4_header_data] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_3/header_valid]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_isp_mipi_vidin4_header_valid]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_3/header_valid]] eq [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_isp_mipi_vidin4_header_valid]]) } {
    catch { connect_bd_net -net mipi_csi2_rx_subsyst_3_header_valid [get_bd_pins mipi_csi2_rx_subsyst_3/header_valid] [get_bd_pins visp_ss_tile0/tile1_isp_mipi_vidin4_header_valid] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_0/interconnect_aresetn]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins smartconnect_1/aresetn]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_0/interconnect_aresetn]] eq [get_bd_nets -quiet -of_objects [get_bd_pins smartconnect_1/aresetn]]) } {
    catch { connect_bd_net -net proc_sys_reset_0_interconnect_aresetn [get_bd_pins proc_sys_reset_0/interconnect_aresetn] [get_bd_pins smartconnect_1/aresetn] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_0/peripheral_aresetn]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins axi_intc_0/s_axi_aresetn]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/s_axi_lite_rstn]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_pl_isp_rstn]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/video_aresetn]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/lite_aresetn]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_1/lite_aresetn]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_1/video_aresetn]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins peripheral_aresetn]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_2/lite_aresetn]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_2/video_aresetn]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_3/lite_aresetn]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_3/video_aresetn]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_pl_isp_rstn]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_0/peripheral_aresetn]] eq [get_bd_nets -quiet -of_objects [get_bd_pins axi_intc_0/s_axi_aresetn]] && [get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_0/peripheral_aresetn]] eq [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/s_axi_lite_rstn]] && [get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_0/peripheral_aresetn]] eq [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_pl_isp_rstn]] && [get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_0/peripheral_aresetn]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/video_aresetn]] && [get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_0/peripheral_aresetn]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/lite_aresetn]] && [get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_0/peripheral_aresetn]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_1/lite_aresetn]] && [get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_0/peripheral_aresetn]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_1/video_aresetn]] && [get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_0/peripheral_aresetn]] eq [get_bd_nets -quiet -of_objects [get_bd_pins peripheral_aresetn]] && [get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_0/peripheral_aresetn]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_2/lite_aresetn]] && [get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_0/peripheral_aresetn]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_2/video_aresetn]] && [get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_0/peripheral_aresetn]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_3/lite_aresetn]] && [get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_0/peripheral_aresetn]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_3/video_aresetn]] && [get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_0/peripheral_aresetn]] eq [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_pl_isp_rstn]]) } {
    catch { connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins axi_intc_0/s_axi_aresetn] [get_bd_pins visp_ss_tile0/s_axi_lite_rstn] [get_bd_pins visp_ss_tile0/tile0_pl_isp_rstn] [get_bd_pins mipi_csi2_rx_subsyst_0/video_aresetn] [get_bd_pins mipi_csi2_rx_subsyst_0/lite_aresetn] [get_bd_pins mipi_csi2_rx_subsyst_1/lite_aresetn] [get_bd_pins mipi_csi2_rx_subsyst_1/video_aresetn] [get_bd_pins peripheral_aresetn] [get_bd_pins mipi_csi2_rx_subsyst_2/lite_aresetn] [get_bd_pins mipi_csi2_rx_subsyst_2/video_aresetn] [get_bd_pins mipi_csi2_rx_subsyst_3/lite_aresetn] [get_bd_pins mipi_csi2_rx_subsyst_3/video_aresetn] [get_bd_pins visp_ss_tile0/tile1_pl_isp_rstn] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/header_data]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp_mipi_vidin0_header_data]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/header_data]] eq [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp_mipi_vidin0_header_data]]) } {
    catch { connect_bd_net -net tile0_isp_mipi_vidin0_header_data_1 [get_bd_pins mipi_csi2_rx_subsyst_0/header_data] [get_bd_pins visp_ss_tile0/tile0_isp_mipi_vidin0_header_data] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/header_valid]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp_mipi_vidin0_header_valid]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/header_valid]] eq [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp_mipi_vidin0_header_valid]]) } {
    catch { connect_bd_net -net tile0_isp_mipi_vidin0_header_valid_1 [get_bd_pins mipi_csi2_rx_subsyst_0/header_valid] [get_bd_pins visp_ss_tile0/tile0_isp_mipi_vidin0_header_valid] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins tile0_ref_dpll_clk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_ref_dpll_clk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_ref_dpll_clk]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins tile0_ref_dpll_clk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_ref_dpll_clk]] && [get_bd_nets -quiet -of_objects [get_bd_pins tile0_ref_dpll_clk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_ref_dpll_clk]]) } {
    catch { connect_bd_net -net tile0_ref_dpll_clk_1 [get_bd_pins tile0_ref_dpll_clk] [get_bd_pins visp_ss_tile0/tile0_ref_dpll_clk] [get_bd_pins visp_ss_tile0/tile1_ref_dpll_clk] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins video_aclk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_0/slowest_sync_clk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins smartconnect_1/aclk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins axi_intc_0/s_axi_aclk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/s_axi_lite_aclk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_pl_isp_vidin0_clk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/video_aclk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/lite_aclk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_1/lite_aclk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_1/video_aclk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_pl_isp_vidin4_clk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_2/lite_aclk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_2/video_aclk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_3/lite_aclk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_3/video_aclk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_pl_isp_vidin0_clk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_pl_isp_vidin4_clk]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins video_aclk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins proc_sys_reset_0/slowest_sync_clk]] && [get_bd_nets -quiet -of_objects [get_bd_pins video_aclk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins smartconnect_1/aclk]] && [get_bd_nets -quiet -of_objects [get_bd_pins video_aclk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins axi_intc_0/s_axi_aclk]] && [get_bd_nets -quiet -of_objects [get_bd_pins video_aclk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/s_axi_lite_aclk]] && [get_bd_nets -quiet -of_objects [get_bd_pins video_aclk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_pl_isp_vidin0_clk]] && [get_bd_nets -quiet -of_objects [get_bd_pins video_aclk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/video_aclk]] && [get_bd_nets -quiet -of_objects [get_bd_pins video_aclk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_0/lite_aclk]] && [get_bd_nets -quiet -of_objects [get_bd_pins video_aclk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_1/lite_aclk]] && [get_bd_nets -quiet -of_objects [get_bd_pins video_aclk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_1/video_aclk]] && [get_bd_nets -quiet -of_objects [get_bd_pins video_aclk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_pl_isp_vidin4_clk]] && [get_bd_nets -quiet -of_objects [get_bd_pins video_aclk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_2/lite_aclk]] && [get_bd_nets -quiet -of_objects [get_bd_pins video_aclk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_2/video_aclk]] && [get_bd_nets -quiet -of_objects [get_bd_pins video_aclk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_3/lite_aclk]] && [get_bd_nets -quiet -of_objects [get_bd_pins video_aclk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins mipi_csi2_rx_subsyst_3/video_aclk]] && [get_bd_nets -quiet -of_objects [get_bd_pins video_aclk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_pl_isp_vidin0_clk]] && [get_bd_nets -quiet -of_objects [get_bd_pins video_aclk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_pl_isp_vidin4_clk]]) } {
    catch { connect_bd_net -net video_aclk_1 [get_bd_pins video_aclk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins smartconnect_1/aclk] [get_bd_pins axi_intc_0/s_axi_aclk] [get_bd_pins visp_ss_tile0/s_axi_lite_aclk] [get_bd_pins visp_ss_tile0/tile0_pl_isp_vidin0_clk] [get_bd_pins mipi_csi2_rx_subsyst_0/video_aclk] [get_bd_pins mipi_csi2_rx_subsyst_0/lite_aclk] [get_bd_pins mipi_csi2_rx_subsyst_1/lite_aclk] [get_bd_pins mipi_csi2_rx_subsyst_1/video_aclk] [get_bd_pins visp_ss_tile0/tile0_pl_isp_vidin4_clk] [get_bd_pins mipi_csi2_rx_subsyst_2/lite_aclk] [get_bd_pins mipi_csi2_rx_subsyst_2/video_aclk] [get_bd_pins mipi_csi2_rx_subsyst_3/lite_aclk] [get_bd_pins mipi_csi2_rx_subsyst_3/video_aclk] [get_bd_pins visp_ss_tile0/tile1_pl_isp_vidin0_clk] [get_bd_pins visp_ss_tile0/tile1_pl_isp_vidin4_clk] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp0_fusa_irq]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins tile0_isp0_fusa_irq]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp0_fusa_irq]] eq [get_bd_nets -quiet -of_objects [get_bd_pins tile0_isp0_fusa_irq]]) } {
    catch { connect_bd_net -net visp_ss_tile0_tile0_isp0_fusa_irq [get_bd_pins visp_ss_tile0/tile0_isp0_fusa_irq] [get_bd_pins tile0_isp0_fusa_irq] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp0_isp_irq]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins tile0_isp0_isp_irq]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp0_isp_irq]] eq [get_bd_nets -quiet -of_objects [get_bd_pins tile0_isp0_isp_irq]]) } {
    catch { connect_bd_net -net visp_ss_tile0_tile0_isp0_isp_irq [get_bd_pins visp_ss_tile0/tile0_isp0_isp_irq] [get_bd_pins tile0_isp0_isp_irq] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp1_fusa_irq]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins tile0_isp1_fusa_irq]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp1_fusa_irq]] eq [get_bd_nets -quiet -of_objects [get_bd_pins tile0_isp1_fusa_irq]]) } {
    catch { connect_bd_net -net visp_ss_tile0_tile0_isp1_fusa_irq [get_bd_pins visp_ss_tile0/tile0_isp1_fusa_irq] [get_bd_pins tile0_isp1_fusa_irq] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp1_isp_irq]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins tile0_isp1_isp_irq]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp1_isp_irq]] eq [get_bd_nets -quiet -of_objects [get_bd_pins tile0_isp1_isp_irq]]) } {
    catch { connect_bd_net -net visp_ss_tile0_tile0_isp1_isp_irq [get_bd_pins visp_ss_tile0/tile0_isp1_isp_irq] [get_bd_pins tile0_isp1_isp_irq] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp_isr_irq]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins tile0_isp_isr_irq]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp_isr_irq]] eq [get_bd_nets -quiet -of_objects [get_bd_pins tile0_isp_isr_irq]]) } {
    catch { connect_bd_net -net visp_ss_tile0_tile0_isp_isr_irq [get_bd_pins visp_ss_tile0/tile0_isp_isr_irq] [get_bd_pins tile0_isp_isr_irq] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp_xmpu_interrupt]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins tile0_isp_xmpu_interrupt]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_isp_xmpu_interrupt]] eq [get_bd_nets -quiet -of_objects [get_bd_pins tile0_isp_xmpu_interrupt]]) } {
    catch { connect_bd_net -net visp_ss_tile0_tile0_isp_xmpu_interrupt [get_bd_pins visp_ss_tile0/tile0_isp_xmpu_interrupt] [get_bd_pins tile0_isp_xmpu_interrupt] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_nmu0_axi_clk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins axi_noc2_0/aclk0]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_nmu0_axi_clk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins axi_noc2_0/aclk0]]) } {
    catch { connect_bd_net -net visp_ss_tile0_tile0_nmu0_axi_clk [get_bd_pins visp_ss_tile0/tile0_nmu0_axi_clk] [get_bd_pins axi_noc2_0/aclk0] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_nmu1_axi_clk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins axi_noc2_0/aclk1]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile0_nmu1_axi_clk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins axi_noc2_0/aclk1]]) } {
    catch { connect_bd_net -net visp_ss_tile0_tile0_nmu1_axi_clk [get_bd_pins visp_ss_tile0/tile0_nmu1_axi_clk] [get_bd_pins axi_noc2_0/aclk1] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_isp0_fusa_irq]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins tile1_isp0_fusa_irq]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_isp0_fusa_irq]] eq [get_bd_nets -quiet -of_objects [get_bd_pins tile1_isp0_fusa_irq]]) } {
    catch { connect_bd_net -net visp_ss_tile0_tile1_isp0_fusa_irq [get_bd_pins visp_ss_tile0/tile1_isp0_fusa_irq] [get_bd_pins tile1_isp0_fusa_irq] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_isp0_isp_irq]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins tile1_isp0_isp_irq]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_isp0_isp_irq]] eq [get_bd_nets -quiet -of_objects [get_bd_pins tile1_isp0_isp_irq]]) } {
    catch { connect_bd_net -net visp_ss_tile0_tile1_isp0_isp_irq [get_bd_pins visp_ss_tile0/tile1_isp0_isp_irq] [get_bd_pins tile1_isp0_isp_irq] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_isp1_fusa_irq]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins tile1_isp1_fusa_irq]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_isp1_fusa_irq]] eq [get_bd_nets -quiet -of_objects [get_bd_pins tile1_isp1_fusa_irq]]) } {
    catch { connect_bd_net -net visp_ss_tile0_tile1_isp1_fusa_irq [get_bd_pins visp_ss_tile0/tile1_isp1_fusa_irq] [get_bd_pins tile1_isp1_fusa_irq] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_isp1_isp_irq]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins tile1_isp1_isp_irq]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_isp1_isp_irq]] eq [get_bd_nets -quiet -of_objects [get_bd_pins tile1_isp1_isp_irq]]) } {
    catch { connect_bd_net -net visp_ss_tile0_tile1_isp1_isp_irq [get_bd_pins visp_ss_tile0/tile1_isp1_isp_irq] [get_bd_pins tile1_isp1_isp_irq] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_isp_isr_irq]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins tile1_isp_isr_irq]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_isp_isr_irq]] eq [get_bd_nets -quiet -of_objects [get_bd_pins tile1_isp_isr_irq]]) } {
    catch { connect_bd_net -net visp_ss_tile0_tile1_isp_isr_irq [get_bd_pins visp_ss_tile0/tile1_isp_isr_irq] [get_bd_pins tile1_isp_isr_irq] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_isp_xmpu_interrupt]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins tile1_isp_xmpu_interrupt]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_isp_xmpu_interrupt]] eq [get_bd_nets -quiet -of_objects [get_bd_pins tile1_isp_xmpu_interrupt]]) } {
    catch { connect_bd_net -net visp_ss_tile0_tile1_isp_xmpu_interrupt [get_bd_pins visp_ss_tile0/tile1_isp_xmpu_interrupt] [get_bd_pins tile1_isp_xmpu_interrupt] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_nmu0_axi_clk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins axi_noc2_0/aclk2]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_nmu0_axi_clk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins axi_noc2_0/aclk2]]) } {
    catch { connect_bd_net -net visp_ss_tile0_tile1_nmu0_axi_clk [get_bd_pins visp_ss_tile0/tile1_nmu0_axi_clk] [get_bd_pins axi_noc2_0/aclk2] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_nmu1_axi_clk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins axi_noc2_0/aclk3]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_nmu1_axi_clk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins axi_noc2_0/aclk3]]) } {
    catch { connect_bd_net -net visp_ss_tile0_tile1_nmu1_axi_clk [get_bd_pins visp_ss_tile0/tile1_nmu1_axi_clk] [get_bd_pins axi_noc2_0/aclk3] }
  }
  if { ([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_nsu_axi_clk]] eq "" || [get_bd_nets -quiet -of_objects [get_bd_pins ISP_Tile1_ConfigNoc/aclk0]] eq "") || !([get_bd_nets -quiet -of_objects [get_bd_pins visp_ss_tile0/tile1_nsu_axi_clk]] eq [get_bd_nets -quiet -of_objects [get_bd_pins ISP_Tile1_ConfigNoc/aclk0]]) } {
    catch { connect_bd_net -net visp_ss_tile0_tile1_nsu_axi_clk [get_bd_pins visp_ss_tile0/tile1_nsu_axi_clk] [get_bd_pins ISP_Tile1_ConfigNoc/aclk0] }
  }

  current_bd_instance $oldCurInst
}

# Auto-execute: Update ISP_hier when this script is sourced
puts "Updating ISP_hier..."
update_ISP_hier / ISP_hier
delete_bd_objs [get_bd_nets ISP_hier/visp_ss_tile1_tile1_nsu_axi_clk] [get_bd_intf_nets ISP_hier/ISP_Tile1_ConfigNoc_M00_AXI] [get_bd_cells ISP_hier/visp_ss_tile1]
connect_bd_intf_net [get_bd_intf_pins ISP_hier/ISP_Tile1_ConfigNoc/M00_AXI] [get_bd_intf_pins ISP_hier/visp_ss_tile0/TILE1_ISP_NSU]
connect_bd_net [get_bd_pins ISP_hier/visp_ss_tile0/tile1_nsu_axi_clk] [get_bd_pins ISP_hier/ISP_Tile1_ConfigNoc/aclk0]
puts "ISP_hier updated successfully."

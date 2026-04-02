// Copyright (c) 2026 Advanced Micro Devices, Inc.
// SPDX-License-Identifier: MIT
// -----------------------------------------------

`timescale 1 ps / 1 ps

module versal_gen2_platform_wrapper
   (C0_LPDDR5X_bank700_701_ca,
    C0_LPDDR5X_bank700_701_ck_c,
    C0_LPDDR5X_bank700_701_ck_t,
    C0_LPDDR5X_bank700_701_cs,
    C0_LPDDR5X_bank700_701_dmi,
    C0_LPDDR5X_bank700_701_dq,
    C0_LPDDR5X_bank700_701_rdqs_c,
    C0_LPDDR5X_bank700_701_rdqs_t,
    C0_LPDDR5X_bank700_701_reset_n,
    C0_LPDDR5X_bank700_701_wck_c,
    C0_LPDDR5X_bank700_701_wck_t,
    C1_LPDDR5X_bank703_704_ca,
    C1_LPDDR5X_bank703_704_ck_c,
    C1_LPDDR5X_bank703_704_ck_t,
    C1_LPDDR5X_bank703_704_cs,
    C1_LPDDR5X_bank703_704_dmi,
    C1_LPDDR5X_bank703_704_dq,
    C1_LPDDR5X_bank703_704_rdqs_c,
    C1_LPDDR5X_bank703_704_rdqs_t,
    C1_LPDDR5X_bank703_704_reset_n,
    C1_LPDDR5X_bank703_704_wck_c,
    C1_LPDDR5X_bank703_704_wck_t,
    C2_LPDDR5X_bank708_709_ca,
    C2_LPDDR5X_bank708_709_ck_c,
    C2_LPDDR5X_bank708_709_ck_t,
    C2_LPDDR5X_bank708_709_cs,
    C2_LPDDR5X_bank708_709_dmi,
    C2_LPDDR5X_bank708_709_dq,
    C2_LPDDR5X_bank708_709_rdqs_c,
    C2_LPDDR5X_bank708_709_rdqs_t,
    C2_LPDDR5X_bank708_709_reset_n,
    C2_LPDDR5X_bank708_709_wck_c,
    C2_LPDDR5X_bank708_709_wck_t,
    C3_LPDDR5X_bank710_711_ca,
    C3_LPDDR5X_bank710_711_ck_c,
    C3_LPDDR5X_bank710_711_ck_t,
    C3_LPDDR5X_bank710_711_cs,
    C3_LPDDR5X_bank710_711_dmi,
    C3_LPDDR5X_bank710_711_dq,
    C3_LPDDR5X_bank710_711_rdqs_c,
    C3_LPDDR5X_bank710_711_rdqs_t,
    C3_LPDDR5X_bank710_711_reset_n,
    C3_LPDDR5X_bank710_711_wck_c,
    C3_LPDDR5X_bank710_711_wck_t,
    C4_LPDDR5X_bank714_715_ca,
    C4_LPDDR5X_bank714_715_ck_c,
    C4_LPDDR5X_bank714_715_ck_t,
    C4_LPDDR5X_bank714_715_cs,
    C4_LPDDR5X_bank714_715_dmi,
    C4_LPDDR5X_bank714_715_dq,
    C4_LPDDR5X_bank714_715_rdqs_c,
    C4_LPDDR5X_bank714_715_rdqs_t,
    C4_LPDDR5X_bank714_715_reset_n,
    C4_LPDDR5X_bank714_715_wck_c,
    C4_LPDDR5X_bank714_715_wck_t,
    GT_Serial_0_grx_n,
    GT_Serial_0_grx_p,
    GT_Serial_0_gtx_n,
    GT_Serial_0_gtx_p,
    MMI_GT_grx_n,
    MMI_GT_grx_p,
    MMI_GT_gtx_n,
    MMI_GT_gtx_p,
    fzetton_i2c_scl_s00,
    fzetton_i2c_sda_s01,
    FZETTON_LNH1983_MOSI,       //FMC_HPC_LA13_P,            FZETTON MOSI LMH 1983
    FZETTON_LNH1983_MISO,       //FMC_HPC_LA13_N,            FZETTON MISO LMH 1983
    FZETTON_LNH1983_SCLK,       //FMC_HPC_LA17_CC_P,         FZETTON SCLK LMH 1983
    FZETTON_RCLKR_SEL,          //FMC_HPC_LA09_N,            FZETTON RCLKR_SEL
    FZETTON_DRVR_SEL,           //FMC_HPC_LA09_P,            FZETTON DRVR_SEL
    FZETTON_RCVR_SEL,           //FMC_HPC_LA05_N,            FZETTON RCVR_SEL
    FZETTON_F_SPI_S0_CH_SEL,    //FMC_HPC_LA05_P,            FZETTON F_SPI_S0 Channel Select
    FZETTON_F_SPI_S1_CH_SEL,    //FMC_HPC_LA01_CC_N,         FZETTON F_SPI_S1 Channel Select
    FZETTON_LNH1983_INIT,       //FMC_HPC_LA12_N,            FZETTON LMH1983 INIT
    FZETTON_SWT_CH3_DIR,        //F
    gpio_dp_tri_i,
    gpio_led_tri_o,
    gpio_pb_tri_i,
    gt_refclk0_clk_n,
    gt_refclk0_clk_p,
    gt_refclk1_clk_n,
    gt_refclk1_clk_p,
    gt_refclk2_clk_n,
    gt_refclk2_clk_p,
    gt_refclk_clk_n,
    gt_refclk_clk_p,
    lpddr5_clk0_1_clk_n,
    lpddr5_clk0_1_clk_p,
    pl_uart_bank705_rxd,
    pl_uart_bank705_txd);
  output [6:0]C0_LPDDR5X_bank700_701_ca;
  output C0_LPDDR5X_bank700_701_ck_c;
  output C0_LPDDR5X_bank700_701_ck_t;
  output [1:0]C0_LPDDR5X_bank700_701_cs;
  inout [3:0]C0_LPDDR5X_bank700_701_dmi;
  inout [31:0]C0_LPDDR5X_bank700_701_dq;
  input [3:0]C0_LPDDR5X_bank700_701_rdqs_c;
  input [3:0]C0_LPDDR5X_bank700_701_rdqs_t;
  output C0_LPDDR5X_bank700_701_reset_n;
  output [3:0]C0_LPDDR5X_bank700_701_wck_c;
  output [3:0]C0_LPDDR5X_bank700_701_wck_t;
  output [6:0]C1_LPDDR5X_bank703_704_ca;
  output C1_LPDDR5X_bank703_704_ck_c;
  output C1_LPDDR5X_bank703_704_ck_t;
  output [1:0]C1_LPDDR5X_bank703_704_cs;
  inout [3:0]C1_LPDDR5X_bank703_704_dmi;
  inout [31:0]C1_LPDDR5X_bank703_704_dq;
  input [3:0]C1_LPDDR5X_bank703_704_rdqs_c;
  input [3:0]C1_LPDDR5X_bank703_704_rdqs_t;
  output C1_LPDDR5X_bank703_704_reset_n;
  output [3:0]C1_LPDDR5X_bank703_704_wck_c;
  output [3:0]C1_LPDDR5X_bank703_704_wck_t;
  output [6:0]C2_LPDDR5X_bank708_709_ca;
  output C2_LPDDR5X_bank708_709_ck_c;
  output C2_LPDDR5X_bank708_709_ck_t;
  output [1:0]C2_LPDDR5X_bank708_709_cs;
  inout [3:0]C2_LPDDR5X_bank708_709_dmi;
  inout [31:0]C2_LPDDR5X_bank708_709_dq;
  input [3:0]C2_LPDDR5X_bank708_709_rdqs_c;
  input [3:0]C2_LPDDR5X_bank708_709_rdqs_t;
  output C2_LPDDR5X_bank708_709_reset_n;
  output [3:0]C2_LPDDR5X_bank708_709_wck_c;
  output [3:0]C2_LPDDR5X_bank708_709_wck_t;
  output [6:0]C3_LPDDR5X_bank710_711_ca;
  output C3_LPDDR5X_bank710_711_ck_c;
  output C3_LPDDR5X_bank710_711_ck_t;
  output [1:0]C3_LPDDR5X_bank710_711_cs;
  inout [3:0]C3_LPDDR5X_bank710_711_dmi;
  inout [31:0]C3_LPDDR5X_bank710_711_dq;
  input [3:0]C3_LPDDR5X_bank710_711_rdqs_c;
  input [3:0]C3_LPDDR5X_bank710_711_rdqs_t;
  output C3_LPDDR5X_bank710_711_reset_n;
  output [3:0]C3_LPDDR5X_bank710_711_wck_c;
  output [3:0]C3_LPDDR5X_bank710_711_wck_t;
  output [6:0]C4_LPDDR5X_bank714_715_ca;
  output C4_LPDDR5X_bank714_715_ck_c;
  output C4_LPDDR5X_bank714_715_ck_t;
  output [1:0]C4_LPDDR5X_bank714_715_cs;
  inout [3:0]C4_LPDDR5X_bank714_715_dmi;
  inout [31:0]C4_LPDDR5X_bank714_715_dq;
  input [3:0]C4_LPDDR5X_bank714_715_rdqs_c;
  input [3:0]C4_LPDDR5X_bank714_715_rdqs_t;
  output C4_LPDDR5X_bank714_715_reset_n;
  output [3:0]C4_LPDDR5X_bank714_715_wck_c;
  output [3:0]C4_LPDDR5X_bank714_715_wck_t;
  input [3:0]GT_Serial_0_grx_n;
  input [3:0]GT_Serial_0_grx_p;
  output [3:0]GT_Serial_0_gtx_n;
  output [3:0]GT_Serial_0_gtx_p;
  input [3:0]MMI_GT_grx_n;
  input [3:0]MMI_GT_grx_p;
  output [3:0]MMI_GT_gtx_n;
  output [3:0]MMI_GT_gtx_p;
    inout   wire        FZETTON_RCLKR_SEL;          //FMC_HPC_LA09_N,            FZETTON RCLKR_SEL
    inout   wire        FZETTON_DRVR_SEL;           //FMC_HPC_LA09_P,            FZETTON DRVR_SEL
    inout   wire        FZETTON_RCVR_SEL;           //FMC_HPC_LA05_N,            FZETTON RCVR_SEL
    output   wire       FZETTON_F_SPI_S0_CH_SEL;    //FMC_HPC_LA05_P,            FZETTON F_SPI_S0 Channel Select
    output   wire       FZETTON_F_SPI_S1_CH_SEL;    //FMC_HPC_LA01_CC_N,         FZETTON F_SPI_S1 Channel Select
    output  wire        FZETTON_LNH1983_INIT;       //FMC_HPC_LA12_N,            FZETTON LMH1983 INIT
    output  wire        FZETTON_SWT_CH3_DIR;        //FMC_HPC_LA14_P,            FZETTON F_CH3_DIR
    inout   wire          fzetton_i2c_sda_s01;           //FMC_HPC_LA07_N,             FZETTON I2C mux SDA
    inout   wire        fzetton_i2c_scl_s00;           //FMC_HPC_LA07_P,             FZETTON I2C mux SCL
    inout   wire        FZETTON_LNH1983_MOSI;       //FMC_HPC_LA13_P,            FZETTON MOSI LMH 1983
    inout   wire        FZETTON_LNH1983_MISO;       //FMC_HPC_LA13_N,            FZETTON MISO LMH 1983
    inout   wire        FZETTON_LNH1983_SCLK;       //FMC_HPC_LA17_CC_P,         FZETTON SCLK LMH 1983
  input [3:0]gpio_dp_tri_i;
  output [3:0]gpio_led_tri_o;
  input [1:0]gpio_pb_tri_i;
  input gt_refclk0_clk_n;
  input gt_refclk0_clk_p;
  input gt_refclk1_clk_n;
  input gt_refclk1_clk_p;
  input [0:0]gt_refclk2_clk_n;
  input [0:0]gt_refclk2_clk_p;
  input [0:0]gt_refclk_clk_n;
  input [0:0]gt_refclk_clk_p;
  input lpddr5_clk0_1_clk_n;
  input lpddr5_clk0_1_clk_p;
  input pl_uart_bank705_rxd;
  output pl_uart_bank705_txd;
//--- GPI/GPO ---{
    wire bridge_gpi;
    wire [15:0] QUAD0_gpi_0 = {15'd0,bridge_gpi};
    wire [15:0] QUAD0_gpo_0;
    wire bridge_gpo = QUAD0_gpo_0[0];
  wire [6:0]C0_LPDDR5X_bank700_701_ca;
  wire C0_LPDDR5X_bank700_701_ck_c;
  wire C0_LPDDR5X_bank700_701_ck_t;
  wire [1:0]C0_LPDDR5X_bank700_701_cs;
  wire [3:0]C0_LPDDR5X_bank700_701_dmi;
  wire [31:0]C0_LPDDR5X_bank700_701_dq;
  wire [3:0]C0_LPDDR5X_bank700_701_rdqs_c;
  wire [3:0]C0_LPDDR5X_bank700_701_rdqs_t;
  wire C0_LPDDR5X_bank700_701_reset_n;
  wire [3:0]C0_LPDDR5X_bank700_701_wck_c;
  wire [3:0]C0_LPDDR5X_bank700_701_wck_t;
  wire [6:0]C1_LPDDR5X_bank703_704_ca;
  wire C1_LPDDR5X_bank703_704_ck_c;
  wire C1_LPDDR5X_bank703_704_ck_t;
  wire [1:0]C1_LPDDR5X_bank703_704_cs;
  wire [3:0]C1_LPDDR5X_bank703_704_dmi;
  wire [31:0]C1_LPDDR5X_bank703_704_dq;
  wire [3:0]C1_LPDDR5X_bank703_704_rdqs_c;
  wire [3:0]C1_LPDDR5X_bank703_704_rdqs_t;
  wire C1_LPDDR5X_bank703_704_reset_n;
  wire [3:0]C1_LPDDR5X_bank703_704_wck_c;
  wire [3:0]C1_LPDDR5X_bank703_704_wck_t;
  wire [6:0]C2_LPDDR5X_bank708_709_ca;
  wire C2_LPDDR5X_bank708_709_ck_c;
  wire C2_LPDDR5X_bank708_709_ck_t;
  wire [1:0]C2_LPDDR5X_bank708_709_cs;
  wire [3:0]C2_LPDDR5X_bank708_709_dmi;
  wire [31:0]C2_LPDDR5X_bank708_709_dq;
  wire [3:0]C2_LPDDR5X_bank708_709_rdqs_c;
  wire [3:0]C2_LPDDR5X_bank708_709_rdqs_t;
  wire C2_LPDDR5X_bank708_709_reset_n;
  wire [3:0]C2_LPDDR5X_bank708_709_wck_c;
  wire [3:0]C2_LPDDR5X_bank708_709_wck_t;
  wire [6:0]C3_LPDDR5X_bank710_711_ca;
  wire C3_LPDDR5X_bank710_711_ck_c;
  wire C3_LPDDR5X_bank710_711_ck_t;
  wire [1:0]C3_LPDDR5X_bank710_711_cs;
  wire [3:0]C3_LPDDR5X_bank710_711_dmi;
  wire [31:0]C3_LPDDR5X_bank710_711_dq;
  wire [3:0]C3_LPDDR5X_bank710_711_rdqs_c;
  wire [3:0]C3_LPDDR5X_bank710_711_rdqs_t;
  wire C3_LPDDR5X_bank710_711_reset_n;
  wire [3:0]C3_LPDDR5X_bank710_711_wck_c;
  wire [3:0]C3_LPDDR5X_bank710_711_wck_t;
  wire [6:0]C4_LPDDR5X_bank714_715_ca;
  wire C4_LPDDR5X_bank714_715_ck_c;
  wire C4_LPDDR5X_bank714_715_ck_t;
  wire [1:0]C4_LPDDR5X_bank714_715_cs;
  wire [3:0]C4_LPDDR5X_bank714_715_dmi;
  wire [31:0]C4_LPDDR5X_bank714_715_dq;
  wire [3:0]C4_LPDDR5X_bank714_715_rdqs_c;
  wire [3:0]C4_LPDDR5X_bank714_715_rdqs_t;
  wire C4_LPDDR5X_bank714_715_reset_n;
  wire [3:0]C4_LPDDR5X_bank714_715_wck_c;
  wire [3:0]C4_LPDDR5X_bank714_715_wck_t;
  wire [3:0]GT_Serial_0_grx_n;
  wire [3:0]GT_Serial_0_grx_p;
  wire [3:0]GT_Serial_0_gtx_n;
  wire [3:0]GT_Serial_0_gtx_p;
  wire [3:0]MMI_GT_grx_n;
  wire [3:0]MMI_GT_grx_p;
  wire [3:0]MMI_GT_gtx_n;
  wire [3:0]MMI_GT_gtx_p;
 // wire [31:0]QUAD0_gpi_0;
//  wire [31:0]QUAD0_gpo_0;
  wire clk_rxusrclk;
  wire clk_txusrclk;
  wire [31:0]fzetton_fmc_gpio_tri_o;
  wire fzetton_fmc_iic_scl_i;
//  wire fzetton_fmc_iic_scl_io;
  wire fzetton_fmc_iic_scl_o;
  wire fzetton_fmc_iic_scl_t;
  wire fzetton_fmc_iic_sda_i;
//  wire fzetton_fmc_iic_sda_io;
  wire fzetton_fmc_iic_sda_o;
  wire fzetton_fmc_iic_sda_t;
  wire fzetton_fmc_spi_io0_i;
  wire fzetton_fmc_spi_io0_io;
  wire fzetton_fmc_spi_io0_o;
  wire fzetton_fmc_spi_io0_t;
  wire fzetton_fmc_spi_io1_i;
  wire fzetton_fmc_spi_io1_io;
  wire fzetton_fmc_spi_io1_o;
  wire fzetton_fmc_spi_io1_t;
  wire fzetton_fmc_spi_sck_i;
  wire fzetton_fmc_spi_sck_io;
  wire fzetton_fmc_spi_sck_o;
  wire fzetton_fmc_spi_sck_t;
  wire [0:0]fzetton_fmc_spi_ss_i_0;
    wire [1:1]fzetton_fmc_spi_ss_i_1;
  wire [2:2]fzetton_fmc_spi_ss_i_2;
  wire [0:0]fzetton_fmc_spi_ss_io_0;
    wire [1:1]fzetton_fmc_spi_ss_io_1;
  wire [2:2]fzetton_fmc_spi_ss_io_2;
  wire [0:0]fzetton_fmc_spi_ss_o_0;
    wire [1:1]fzetton_fmc_spi_ss_o_1;
  wire [2:2]fzetton_fmc_spi_ss_o_2;
  wire fzetton_fmc_spi_ss_t;
  wire [3:0]gpio_dp_tri_i;
  wire [3:0]gpio_led_tri_o;
  wire [1:0]gpio_pb_tri_i;
  wire gt_refclk0_clk_n;
  wire gt_refclk0_clk_p;
  wire gt_refclk1_clk_n;
  wire gt_refclk1_clk_p;
  wire [0:0]gt_refclk2_clk_n;
  wire [0:0]gt_refclk2_clk_p;
  wire [0:0]gt_refclk_clk_n;
  wire [0:0]gt_refclk_clk_p;
    wire [2:0] fzetton_fmc_spi_ss;
  wire [31:0] fzetton_fmc_gpio;
  wire lpddr5_clk0_1_clk_n;
  wire lpddr5_clk0_1_clk_p;
  wire pl_uart_bank705_rxd;
  wire pl_uart_bank705_txd;
    assign FZETTON_LNH1983_INIT     = 1'b1;                  // LMH1983 INIT
  assign FZETTON_SWT_CH3_DIR     = 1'b0;                  // F_CH3_DIR  for ch4
  assign FZETTON_RCLKR_SEL     = fzetton_fmc_spi_ss[0]; //LOC = A30 | IOSTANDARD=LVCMOS25  RCLKR
  assign FZETTON_DRVR_SEL     = fzetton_fmc_spi_ss[1]; //LOC = B30 | IOSTANDARD=LVCMOS25  DRVR
  assign FZETTON_RCVR_SEL     = fzetton_fmc_spi_ss[2]; //LOC = AH22 | IOSTANDARD=LVCMOS25 RCVR
  assign FZETTON_F_SPI_S0_CH_SEL     = fzetton_fmc_gpio[0];   //LOC = G29 | IOSTANDARD=LVCMOS25 F_SPI_S0 Channel Select
  assign FZETTON_F_SPI_S1_CH_SEL     = fzetton_fmc_gpio[1];   //LOC = C26 | IOSTANDARD=LVCMOS25 F_SPI_S1 Channel Select

  IOBUF fzetton_fmc_iic_scl_iobuf
       (.I(fzetton_fmc_iic_scl_o),
        .IO(fzetton_i2c_scl_s00),
        .O(fzetton_fmc_iic_scl_i),
        .T(fzetton_fmc_iic_scl_t));
  IOBUF fzetton_fmc_iic_sda_iobuf
       (.I(fzetton_fmc_iic_sda_o),
        .IO(fzetton_i2c_sda_s01),
        .O(fzetton_fmc_iic_sda_i),
        .T(fzetton_fmc_iic_sda_t));
  IOBUF fzetton_fmc_spi_io0_iobuf
       (.I(fzetton_fmc_spi_io0_o),
        .IO(FZETTON_LNH1983_MOSI),
        .O(fzetton_fmc_spi_io0_i),
        .T(fzetton_fmc_spi_io0_t));
  IOBUF fzetton_fmc_spi_io1_iobuf
       (.I(fzetton_fmc_spi_io1_o),
        .IO(FZETTON_LNH1983_MISO),
        .O(fzetton_fmc_spi_io1_i),
        .T(fzetton_fmc_spi_io1_t));
  IOBUF fzetton_fmc_spi_sck_iobuf
       (.I(fzetton_fmc_spi_sck_o),
        .IO(FZETTON_LNH1983_SCLK),
        .O(fzetton_fmc_spi_sck_i),
        .T(fzetton_fmc_spi_sck_t));
  IOBUF fzetton_fmc_spi_ss_iobuf_0
       (.I(fzetton_fmc_spi_ss_o_0),
        .IO(fzetton_fmc_spi_ss[0]),
        .O(fzetton_fmc_spi_ss_i_0),
        .T(fzetton_fmc_spi_ss_t));
  IOBUF fzetton_fmc_spi_ss_iobuf_1
       (.I(fzetton_fmc_spi_ss_o_1),
        .IO(fzetton_fmc_spi_ss[1]),
        .O(fzetton_fmc_spi_ss_i_1),
        .T(fzetton_fmc_spi_ss_t));
  IOBUF fzetton_fmc_spi_ss_iobuf_2
       (.I(fzetton_fmc_spi_ss_o_2),
        .IO(fzetton_fmc_spi_ss[2]),
        .O(fzetton_fmc_spi_ss_i_2),
        .T(fzetton_fmc_spi_ss_t));
  versal_gen2_platform versal_gen2_platform_i
       (.C0_LPDDR5X_bank700_701_ca(C0_LPDDR5X_bank700_701_ca),
        .C0_LPDDR5X_bank700_701_ck_c(C0_LPDDR5X_bank700_701_ck_c),
        .C0_LPDDR5X_bank700_701_ck_t(C0_LPDDR5X_bank700_701_ck_t),
        .C0_LPDDR5X_bank700_701_cs(C0_LPDDR5X_bank700_701_cs),
        .C0_LPDDR5X_bank700_701_dmi(C0_LPDDR5X_bank700_701_dmi),
        .C0_LPDDR5X_bank700_701_dq(C0_LPDDR5X_bank700_701_dq),
        .C0_LPDDR5X_bank700_701_rdqs_c(C0_LPDDR5X_bank700_701_rdqs_c),
        .C0_LPDDR5X_bank700_701_rdqs_t(C0_LPDDR5X_bank700_701_rdqs_t),
        .C0_LPDDR5X_bank700_701_reset_n(C0_LPDDR5X_bank700_701_reset_n),
        .C0_LPDDR5X_bank700_701_wck_c(C0_LPDDR5X_bank700_701_wck_c),
        .C0_LPDDR5X_bank700_701_wck_t(C0_LPDDR5X_bank700_701_wck_t),
        .C1_LPDDR5X_bank703_704_ca(C1_LPDDR5X_bank703_704_ca),
        .C1_LPDDR5X_bank703_704_ck_c(C1_LPDDR5X_bank703_704_ck_c),
        .C1_LPDDR5X_bank703_704_ck_t(C1_LPDDR5X_bank703_704_ck_t),
        .C1_LPDDR5X_bank703_704_cs(C1_LPDDR5X_bank703_704_cs),
        .C1_LPDDR5X_bank703_704_dmi(C1_LPDDR5X_bank703_704_dmi),
        .C1_LPDDR5X_bank703_704_dq(C1_LPDDR5X_bank703_704_dq),
        .C1_LPDDR5X_bank703_704_rdqs_c(C1_LPDDR5X_bank703_704_rdqs_c),
        .C1_LPDDR5X_bank703_704_rdqs_t(C1_LPDDR5X_bank703_704_rdqs_t),
        .C1_LPDDR5X_bank703_704_reset_n(C1_LPDDR5X_bank703_704_reset_n),
        .C1_LPDDR5X_bank703_704_wck_c(C1_LPDDR5X_bank703_704_wck_c),
        .C1_LPDDR5X_bank703_704_wck_t(C1_LPDDR5X_bank703_704_wck_t),
        .C2_LPDDR5X_bank708_709_ca(C2_LPDDR5X_bank708_709_ca),
        .C2_LPDDR5X_bank708_709_ck_c(C2_LPDDR5X_bank708_709_ck_c),
        .C2_LPDDR5X_bank708_709_ck_t(C2_LPDDR5X_bank708_709_ck_t),
        .C2_LPDDR5X_bank708_709_cs(C2_LPDDR5X_bank708_709_cs),
        .C2_LPDDR5X_bank708_709_dmi(C2_LPDDR5X_bank708_709_dmi),
        .C2_LPDDR5X_bank708_709_dq(C2_LPDDR5X_bank708_709_dq),
        .C2_LPDDR5X_bank708_709_rdqs_c(C2_LPDDR5X_bank708_709_rdqs_c),
        .C2_LPDDR5X_bank708_709_rdqs_t(C2_LPDDR5X_bank708_709_rdqs_t),
        .C2_LPDDR5X_bank708_709_reset_n(C2_LPDDR5X_bank708_709_reset_n),
        .C2_LPDDR5X_bank708_709_wck_c(C2_LPDDR5X_bank708_709_wck_c),
        .C2_LPDDR5X_bank708_709_wck_t(C2_LPDDR5X_bank708_709_wck_t),
        .C3_LPDDR5X_bank710_711_ca(C3_LPDDR5X_bank710_711_ca),
        .C3_LPDDR5X_bank710_711_ck_c(C3_LPDDR5X_bank710_711_ck_c),
        .C3_LPDDR5X_bank710_711_ck_t(C3_LPDDR5X_bank710_711_ck_t),
        .C3_LPDDR5X_bank710_711_cs(C3_LPDDR5X_bank710_711_cs),
        .C3_LPDDR5X_bank710_711_dmi(C3_LPDDR5X_bank710_711_dmi),
        .C3_LPDDR5X_bank710_711_dq(C3_LPDDR5X_bank710_711_dq),
        .C3_LPDDR5X_bank710_711_rdqs_c(C3_LPDDR5X_bank710_711_rdqs_c),
        .C3_LPDDR5X_bank710_711_rdqs_t(C3_LPDDR5X_bank710_711_rdqs_t),
        .C3_LPDDR5X_bank710_711_reset_n(C3_LPDDR5X_bank710_711_reset_n),
        .C3_LPDDR5X_bank710_711_wck_c(C3_LPDDR5X_bank710_711_wck_c),
        .C3_LPDDR5X_bank710_711_wck_t(C3_LPDDR5X_bank710_711_wck_t),
        .C4_LPDDR5X_bank714_715_ca(C4_LPDDR5X_bank714_715_ca),
        .C4_LPDDR5X_bank714_715_ck_c(C4_LPDDR5X_bank714_715_ck_c),
        .C4_LPDDR5X_bank714_715_ck_t(C4_LPDDR5X_bank714_715_ck_t),
        .C4_LPDDR5X_bank714_715_cs(C4_LPDDR5X_bank714_715_cs),
        .C4_LPDDR5X_bank714_715_dmi(C4_LPDDR5X_bank714_715_dmi),
        .C4_LPDDR5X_bank714_715_dq(C4_LPDDR5X_bank714_715_dq),
        .C4_LPDDR5X_bank714_715_rdqs_c(C4_LPDDR5X_bank714_715_rdqs_c),
        .C4_LPDDR5X_bank714_715_rdqs_t(C4_LPDDR5X_bank714_715_rdqs_t),
        .C4_LPDDR5X_bank714_715_reset_n(C4_LPDDR5X_bank714_715_reset_n),
        .C4_LPDDR5X_bank714_715_wck_c(C4_LPDDR5X_bank714_715_wck_c),
        .C4_LPDDR5X_bank714_715_wck_t(C4_LPDDR5X_bank714_715_wck_t),
        .GT_Serial_0_grx_n(GT_Serial_0_grx_n),
        .GT_Serial_0_grx_p(GT_Serial_0_grx_p),
        .GT_Serial_0_gtx_n(GT_Serial_0_gtx_n),
        .GT_Serial_0_gtx_p(GT_Serial_0_gtx_p),
        .MMI_GT_grx_n(MMI_GT_grx_n),
        .MMI_GT_grx_p(MMI_GT_grx_p),
        .MMI_GT_gtx_n(MMI_GT_gtx_n),
        .MMI_GT_gtx_p(MMI_GT_gtx_p),
        .QUAD0_gpi_0(QUAD0_gpi_0),
        .QUAD0_gpo_0(QUAD0_gpo_0),
        .clk_rxusrclk(clk_rxusrclk),
        .clk_txusrclk(clk_txusrclk),
        .fzetton_fmc_gpio_tri_o(fzetton_fmc_gpio_tri_o),
        .fzetton_fmc_iic_scl_i(fzetton_fmc_iic_scl_i),
        .fzetton_fmc_iic_scl_o(fzetton_fmc_iic_scl_o),
        .fzetton_fmc_iic_scl_t(fzetton_fmc_iic_scl_t),
        .fzetton_fmc_iic_sda_i(fzetton_fmc_iic_sda_i),
        .fzetton_fmc_iic_sda_o(fzetton_fmc_iic_sda_o),
        .fzetton_fmc_iic_sda_t(fzetton_fmc_iic_sda_t),
        .fzetton_fmc_spi_io0_i(fzetton_fmc_spi_io0_i),
        .fzetton_fmc_spi_io0_o(fzetton_fmc_spi_io0_o),
        .fzetton_fmc_spi_io0_t(fzetton_fmc_spi_io0_t),
        .fzetton_fmc_spi_io1_i(fzetton_fmc_spi_io1_i),
        .fzetton_fmc_spi_io1_o(fzetton_fmc_spi_io1_o),
        .fzetton_fmc_spi_io1_t(fzetton_fmc_spi_io1_t),
        .fzetton_fmc_spi_sck_i(fzetton_fmc_spi_sck_i),
        .fzetton_fmc_spi_sck_o(fzetton_fmc_spi_sck_o),
        .fzetton_fmc_spi_sck_t(fzetton_fmc_spi_sck_t),
        .fzetton_fmc_spi_ss_i({fzetton_fmc_spi_ss_i_2,fzetton_fmc_spi_ss_i_1,fzetton_fmc_spi_ss_i_0}),
        .fzetton_fmc_spi_ss_o({fzetton_fmc_spi_ss_o_2,fzetton_fmc_spi_ss_o_1,fzetton_fmc_spi_ss_o_0}),
        .fzetton_fmc_spi_ss_t(fzetton_fmc_spi_ss_t),
        .gpio_dp_tri_i(gpio_dp_tri_i),
        .gpio_led_tri_o(gpio_led_tri_o),
        .gpio_pb_tri_i(gpio_pb_tri_i),
        .gt_refclk0_clk_n(gt_refclk0_clk_n),
        .gt_refclk0_clk_p(gt_refclk0_clk_p),
        .gt_refclk1_clk_n(gt_refclk1_clk_n),
        .gt_refclk1_clk_p(gt_refclk1_clk_p),
        .gt_refclk2_clk_n(gt_refclk2_clk_n),
        .gt_refclk2_clk_p(gt_refclk2_clk_p),
        .gt_refclk_clk_n(gt_refclk_clk_n),
        .gt_refclk_clk_p(gt_refclk_clk_p),
        .lpddr5_clk0_1_clk_n(lpddr5_clk0_1_clk_n),
        .lpddr5_clk0_1_clk_p(lpddr5_clk0_1_clk_p),
        .pl_uart_bank705_rxd(pl_uart_bank705_rxd),
        .pl_uart_bank705_txd(pl_uart_bank705_txd));
endmodule

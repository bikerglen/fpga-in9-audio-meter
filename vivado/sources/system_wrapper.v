//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
//Date        : Sat Jun 30 14:47:32 2018
//Host        : DESKTOP-BEAST running 64-bit major release  (build 9200)
//Command     : generate_target system_wrapper.bd
//Design      : system_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module system_wrapper
   (DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    blank,
    col,
    latch,
    row,
    rx_lrck,
    rx_mclk,
    rx_sclk,
    rx_sdin,
    sclk,
    spi_mosi,
    spi_sclk,
    spi_spare,
    spi_ss0,
    sys_clock,
    tx_lrck,
    tx_mclk,
    tx_sclk,
    tx_sdout);
  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  output blank;
  output col;
  output latch;
  output [3:0]row;
  output rx_lrck;
  output rx_mclk;
  output rx_sclk;
  input rx_sdin;
  output sclk;
  output spi_mosi;
  output spi_sclk;
  output [0:0]spi_spare;
  output [0:0]spi_ss0;
  input sys_clock;
  output tx_lrck;
  output tx_mclk;
  output tx_sclk;
  output tx_sdout;

  wire [14:0]DDR_addr;
  wire [2:0]DDR_ba;
  wire DDR_cas_n;
  wire DDR_ck_n;
  wire DDR_ck_p;
  wire DDR_cke;
  wire DDR_cs_n;
  wire [3:0]DDR_dm;
  wire [31:0]DDR_dq;
  wire [3:0]DDR_dqs_n;
  wire [3:0]DDR_dqs_p;
  wire DDR_odt;
  wire DDR_ras_n;
  wire DDR_reset_n;
  wire DDR_we_n;
  wire FIXED_IO_ddr_vrn;
  wire FIXED_IO_ddr_vrp;
  wire [53:0]FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;
  wire blank;
  wire col;
  wire latch;
  wire [3:0]row;
  wire rx_lrck;
  wire rx_mclk;
  wire rx_sclk;
  wire rx_sdin;
  wire sclk;
  wire spi_mosi;
  wire spi_sclk;
  wire [0:0]spi_spare;
  wire [0:0]spi_ss0;
  wire sys_clock;
  wire tx_lrck;
  wire tx_mclk;
  wire tx_sclk;
  wire tx_sdout;

  system system_i
       (.DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .blank(blank),
        .col(col),
        .latch(latch),
        .row(row),
        .rx_lrck(rx_lrck),
        .rx_mclk(rx_mclk),
        .rx_sclk(rx_sclk),
        .rx_sdin(rx_sdin),
        .sclk(sclk),
        .spi_mosi(spi_mosi),
        .spi_sclk(spi_sclk),
        .spi_spare(spi_spare),
        .spi_ss0(spi_ss0),
        .sys_clock(sys_clock),
        .tx_lrck(tx_lrck),
        .tx_mclk(tx_mclk),
        .tx_sclk(tx_sclk),
        .tx_sdout(tx_sdout));
endmodule

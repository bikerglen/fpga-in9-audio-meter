//=============================================================================================
// Audio Meter Verilog Wrapper
// Copyright 2018 by Glen Akins.
// All rights reserved.
// 
// Set editor tab stop to 4.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//=============================================================================================

module audio_wrapper #
(
	parameter integer C_S00_AXI_DATA_WIDTH  = 32,
	parameter integer C_S00_AXI_ADDR_WIDTH  = 8
)
(
	// 24.576MHz audio clock and pll locked indicator
	input	wire            mclk,
	input	wire            mclk_pll_locked,

    // i2s interface to digilent i2s2 pmod 
    output  wire            tx_mclk,    // JA[0]
    output  wire            tx_lrck,    // JA[1]
    output  wire            tx_sclk,    // JA[2]
    output  wire            tx_sdout,   // JA[3]
    output  wire            rx_mclk,    // JA[4]
    output  wire            rx_lrck,    // JA[5]
    output  wire            rx_sclk,    // JA[6]
    input   wire            rx_sdin,    // JA[7]

	// Ports of Axi Slave Bus Interface S00_AXI
	input   wire                                s00_axi_aclk,
	input   wire                                s00_axi_aresetn,
	input   wire     [C_S00_AXI_ADDR_WIDTH-1:0] s00_axi_awaddr,
	input   wire                          [2:0] s00_axi_awprot,
	input   wire                                s00_axi_awvalid,
	output  wire                                s00_axi_awready,
	input   wire     [C_S00_AXI_DATA_WIDTH-1:0] s00_axi_wdata,
	input   wire [(C_S00_AXI_DATA_WIDTH/8)-1:0] s00_axi_wstrb,
	input   wire                                s00_axi_wvalid,
	output  wire                                s00_axi_wready,
	output  wire                          [1:0] s00_axi_bresp,
	output  wire                                s00_axi_bvalid,
	input   wire                                s00_axi_bready,
	input   wire     [C_S00_AXI_ADDR_WIDTH-1:0] s00_axi_araddr,
	input   wire                          [2:0] s00_axi_arprot,
	input   wire                                s00_axi_arvalid,
	output  wire                                s00_axi_arready,
	output  wire     [C_S00_AXI_DATA_WIDTH-1:0] s00_axi_rdata,
	output  wire                          [1:0] s00_axi_rresp,
	output  wire                                s00_axi_rvalid,
	input   wire                                s00_axi_rready
);


//----------------------------------------
// assert mclk_rst until s00_axi_aresetn is deasserted and mclk PLL is locked
//----------------------------------------

reg mclk_rst, mclk_rst_0, mclk_rst_1, mclk_rst_2;

always @ (posedge mclk or negedge s00_axi_aresetn)
begin
	if (!s00_axi_aresetn)
	begin
		mclk_rst_0 <= 1; 
		mclk_rst_1 <= 1;
		mclk_rst_2 <= 1;
		mclk_rst <= 1;
	end
	else
	begin
		mclk_rst_0 <= !mclk_pll_locked; 
		mclk_rst_1 <= mclk_rst_0;
		mclk_rst_2 <= mclk_rst_1;
		mclk_rst <= mclk_rst_2;
	end
end


//----------------------------------------
// AXI Slave Interface
//----------------------------------------

wire  [9:0] peak_detect_block_size;

wire        twentylog10_fifo_empty;
wire        twentylog10_fifo_read;
wire [31:0] twentylog10_fifo_data;

wire [23:0]	timebase_reset_value;
reg       	timebase_flag;
wire      	timebase_flag_clear;

audio_wrapper_S_AXI # ( 
	.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
	.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
) audio_wrapper_S_AXI (
	.S_AXI_ACLK(s00_axi_aclk),
	.S_AXI_ARESETN(s00_axi_aresetn),
	.S_AXI_AWADDR(s00_axi_awaddr),
	.S_AXI_AWPROT(s00_axi_awprot),
	.S_AXI_AWVALID(s00_axi_awvalid),
	.S_AXI_AWREADY(s00_axi_awready),
	.S_AXI_WDATA(s00_axi_wdata),
	.S_AXI_WSTRB(s00_axi_wstrb),
	.S_AXI_WVALID(s00_axi_wvalid),
	.S_AXI_WREADY(s00_axi_wready),
	.S_AXI_BRESP(s00_axi_bresp),
	.S_AXI_BVALID(s00_axi_bvalid),
	.S_AXI_BREADY(s00_axi_bready),
	.S_AXI_ARADDR(s00_axi_araddr),
	.S_AXI_ARPROT(s00_axi_arprot),
	.S_AXI_ARVALID(s00_axi_arvalid),
	.S_AXI_ARREADY(s00_axi_arready),
	.S_AXI_RDATA(s00_axi_rdata),
	.S_AXI_RRESP(s00_axi_rresp),
	.S_AXI_RVALID(s00_axi_rvalid),
	.S_AXI_RREADY(s00_axi_rready),

	.peak_detect_block_size		(peak_detect_block_size),

	.twentylog10_fifo_empty		(twentylog10_fifo_empty),
	.twentylog10_fifo_read		(twentylog10_fifo_read),
	.twentylog10_fifo_data		(twentylog10_fifo_data),

	.timebase_reset_value		(timebase_reset_value),
	.timebase_flag				(timebase_flag),
	.timebase_flag_clear		(timebase_flag_clear)
);


//----------------------------------------
// I2S Audio Interface
//----------------------------------------

wire tx_ack;
wire [23:0] tx_left, tx_right;
wire rx_valid;
wire [23:0] rx_left, rx_right;

assign tx_left = rx_left;
assign tx_right = rx_right;

i2s_master_48kHz_24b i2s_master_48kHz_24b_0
(
	// 24.576MHz audio clock and synchronous active-high reset
	.mclk				(mclk),
	.mclk_rst			(mclk_rst),

    // i2s interface to digilent i2s2 pmod 
    .tx_mclk			(tx_mclk),
    .tx_lrck			(tx_lrck),
    .tx_sclk			(tx_sclk),
    .tx_sdout			(tx_sdout),
    .rx_mclk			(rx_mclk),
    .rx_lrck			(rx_lrck),
    .rx_sclk			(rx_sclk),
    .rx_sdin			(rx_sdin),

	// transmit data from PS/PL out to DAC
	.tx_ack				(tx_ack),
	.tx_left			(tx_left),
	.tx_right			(tx_right),
	
	// receive data from ADC in to PS/PL
	.rx_valid			(rx_valid),
	.rx_left			(rx_left),
	.rx_right			(rx_right)
);


//----------------------------------------
// Audio Samples ILA for Audio Levels Debug
//----------------------------------------

audio_samples_ila audio_samples_ila_0
(
	.clk                (mclk),
	.probe0             (tx_ack),  
	.probe1             (tx_left), 
	.probe2             (tx_right), 
	.probe3             (rx_valid), 
	.probe4             (rx_left), 
	.probe5             (rx_right)
);


//----------------------------------------
// Peak Detection
//----------------------------------------

wire peak_valid;
wire [22:0] peak_left;
wire [22:0] peak_right;

peak_detect peak_detect_left
(
	.clk				(mclk),
	.rst				(mclk_rst),
	.size				(peak_detect_block_size),
	.vin				(rx_valid),
	.din				(rx_left),
	.vout				(peak_valid),
	.dout				(peak_left)
);

peak_detect peak_detect_right
(
	.clk				(mclk),
	.rst				(mclk_rst),
	.size				(peak_detect_block_size),
	.vin				(rx_valid),
	.din				(rx_right),
	.vout				(),
	.dout				(peak_right)
);


//----------------------------------------
// Log10 -- output is s xxxx.xxxx xxxx xxxx
//----------------------------------------

wire log_valid;
wire [16:0] log_left, log_right;

log10 log10_left
(
	.clk				(mclk),
	.rst				(mclk_rst),
	.vin				(peak_valid),
	.din				({ peak_left, 1'b0 }),
	.vout				(log_valid),
	.dout				(log_left)
);

log10 log10_right
(
	.clk				(mclk),
	.rst				(mclk_rst),
	.vin				(peak_valid),
	.din				({ peak_right, 1'b0 }),
	.vout				(),
	.dout				(log_right)
);


//----------------------------------------
// Multiply by 20 -- output is s xxxx xxxx.xxxx xxxx xxxx
//----------------------------------------

reg twentyLog10_valid;
reg [20:0] twentyLog10_left, twentyLog10_right;

always @ (posedge mclk)
begin
	if (mclk_rst)
	begin
		twentyLog10_valid <= 0;
		twentyLog10_left <= 0; 
		twentyLog10_right <= 0;
	end
	else
	begin
		twentyLog10_valid <= log_valid;
		twentyLog10_left <= $signed (20) * $signed (log_left);
		twentyLog10_right <= $signed (20) * $signed (log_right);
	end
end


//----------------------------------------
// FIFO to transfer 20*log10(peak) values to CPU for display
//----------------------------------------

fifo_twentylog10 fifo_twentylog10 
(
  .wr_clk	(mclk),
  .wr_en	(twentyLog10_valid),
  .din		({ twentyLog10_left[20:5], twentyLog10_right[20:5] }),
  .full		(),

  .rd_clk	(s00_axi_aclk),
  .rd_en	(twentylog10_fifo_read),
  .dout		(twentylog10_fifo_data),
  .empty	(twentylog10_fifo_empty)
);


//----------------------------------------
// CPU main loop tasks timebase timer
//----------------------------------------

reg [23:0] timebase_counter;

always @ (posedge s00_axi_aclk or negedge s00_axi_aresetn)
begin
    if (!s00_axi_aresetn)
    begin
        timebase_counter <= 0;
        timebase_flag <= 0;
    end
    else
    begin
        if (timebase_counter == timebase_reset_value)
        begin
            timebase_counter <= 0;
            timebase_flag <= 1;
        end
        else
        begin
            timebase_counter <= timebase_counter + 1;
            if (timebase_flag_clear)
            begin
                timebase_flag <= 0;
            end
        end
    end
end

endmodule

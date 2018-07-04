//----------------------------------------
// testbench
//----------------------------------------

module testbench_aw1;

//----------------------------------------
// registers and wires
//----------------------------------------

reg aclk;
reg arst_n;
reg mclk;
reg mclk_pll_locked;

wire tx_mclk, tx_lrck, tx_sclk, tx_sdout;
wire rx_mclk, rx_lrck, rx_sclk, rx_sdin;


//----------------------------------------
// create 50MHz aclk
//----------------------------------------

initial aclk <= 0;
always #10.0 aclk <= ~aclk;


//----------------------------------------
// create 24.576MHz mclk
//----------------------------------------

initial mclk <= 0;
always #20.345 mclk <= ~mclk;


//----------------------------------------
// create mclk_pll_locked
//----------------------------------------

reg [9:0] mclk_pll_counter;
initial mclk_pll_locked <= 0;
always @ (posedge mclk or negedge arst_n)
begin
	if (!arst_n)
	begin
		mclk_pll_locked <= 0;
		mclk_pll_counter <= 1023;
	end
	else
	begin
		if (mclk_pll_counter != 0)
		begin
			mclk_pll_counter <= mclk_pll_counter - 1;
			mclk_pll_locked <= 0;
		end
		else
		begin
			mclk_pll_locked <= 1;
		end
	end
end


//----------------------------------------
// dut
//----------------------------------------

audio_wrapper audio_wrapper_0
(
	.mclk					(mclk),
	.mclk_pll_locked		(mclk_pll_locked),

    .tx_mclk				(tx_mclk),
    .tx_lrck				(tx_lrck),
    .tx_sclk				(tx_sclk),
    .tx_sdout				(tx_sdout),
    .rx_mclk				(rx_mclk),
    .rx_lrck				(rx_lrck),
    .rx_sclk				(rx_sclk),
    .rx_sdin				(rx_sdin),

	.s00_axi_aclk			(aclk),
	.s00_axi_aresetn		(arst_n),
	.s00_axi_awaddr			(8'b0),
	.s00_axi_awprot			(3'b0),
	.s00_axi_awvalid		(1'b0),
	.s00_axi_awready		(),
	.s00_axi_wdata			(32'b0),
	.s00_axi_wstrb			(4'b0),
	.s00_axi_wvalid			(1'b0),
	.s00_axi_wready			(),
	.s00_axi_bresp			(),
	.s00_axi_bvalid			(),
	.s00_axi_bready			(1'b0),
	.s00_axi_araddr			(8'b0),
	.s00_axi_arprot			(3'b0),
	.s00_axi_arvalid		(1'b0),
	.s00_axi_arready		(),
	.s00_axi_rdata			(),
	.s00_axi_rresp			(),
	.s00_axi_rvalid			(),
	.s00_axi_rready			(1'b0)
);


//----------------------------------------
// behavioral i2s slave transmitter
//----------------------------------------

wire tx_ack;
reg [23:0] tx_left = 24'h000000;
reg [23:0] tx_right = 24'h000000;

tb_i2s_slave_tx tb_i2s_slave_tx_0
(
	.ack					(tx_ack),
	.left					(tx_left),
	.right					(tx_right),
	.tx_mclk				(rx_mclk),
	.tx_lrck				(rx_lrck),
	.tx_sclk				(rx_sclk),
	.tx_sdout				(rx_sdin)
);


//----------------------------------------
// behavioral i2s slave receiver
//----------------------------------------

wire rx_ack;
wire [23:0] rx_left;
wire [23:0] rx_right;

tb_i2s_slave_rx tb_i2s_slave_rx_0
(
	.rx_mclk				(tx_mclk),
	.rx_lrck				(tx_lrck),
	.rx_sclk				(tx_sclk),
	.rx_sdin				(tx_sdout),
	.ack					(rx_ack),
	.left					(rx_left),
	.right					(rx_right)
);


//----------------------------------------
// read samples from file and send to dut using behavioral tx model
//----------------------------------------

integer tx_fin;
integer tx_count;
real tx_lflt, tx_rflt;
integer tx_lint, tx_rint;

initial
begin
	tx_fin = $fopen ("d:/users/glen/fpgas/audio-meter/sim_data/samples.txt", "r");
	tx_left <= 0;
	tx_right <= 0;
end

final
begin
	$fclose (tx_fin);
end

always @ (posedge tx_mclk)
begin
	if (tx_ack)
	begin
		tx_count = $fscanf (tx_fin, "%f %f", tx_lflt, tx_rflt);
		if (tx_count == 2) 
		begin
			tx_lint = tx_lflt * 8388607.0;
			tx_rint = tx_rflt * 8388607.0;
			tx_left = tx_lint;
			tx_right = tx_rint;
		end
		else
		begin
			tx_left = +1;
			tx_right = -1;
		end
	end
end


//----------------------------------------
// use behavioral rx model to get samples from dut and write to file
//----------------------------------------

// TODO


//----------------------------------------
// test script
//----------------------------------------

initial
begin
	// start with design in reset and wait a while
	arst_n <= 0;
	# 500;

	// release reset and wait a while
	arst_n <= 1;
	# 500;

	//----------------------------------------
	// vvv TEST GOES HERE vvv
	//----------------------------------------
	
	//----------------------------------------
	// ^^^ TEST GOES HERE ^^^
	//----------------------------------------
	
	// wait 100ms then end simulation
	#100_000_000;
	$finish;
end


//----------------------------------------
// test log10 module
//----------------------------------------

reg vin = 0;
reg [23:0] din = 0;
wire vout;
wire [16:0] dout;

log10 log10_0
(
    .clk    (mclk),
    .rst    (!arst_n),
    .vin    (vin),
    .din    (din),
    .vout   (vout),
    .dout   (dout)
);

initial 
begin

    # 1500;

    @ (posedge mclk) vin <= 1'b1; din <= 24'h000000;
    @ (posedge mclk) vin <= 1'b1; din <= 24'h000001;
    @ (posedge mclk) vin <= 1'b1; din <= 24'h600000;
    @ (posedge mclk) vin <= 1'b1; din <= 24'h808891;
    @ (posedge mclk) vin <= 1'b1; din <= 24'hdebeef;
    @ (posedge mclk) vin <= 1'b1; din <= 24'hFFFFFF;
    @ (posedge mclk) vin <= 1'b0;
    
    @ (posedge mclk) vin <= 1'b1; din <= 24'h800000;
    @ (posedge mclk) din <= 24'h400000;
    @ (posedge mclk) din <= 24'h200000;
    @ (posedge mclk) din <= 24'h100000;
    @ (posedge mclk) din <= 24'h80000;
    @ (posedge mclk) din <= 24'h40000;
    @ (posedge mclk) din <= 24'h20000;
    @ (posedge mclk) din <= 24'h10000;
    @ (posedge mclk) din <= 24'h8000;
    @ (posedge mclk) din <= 24'h4000;
    @ (posedge mclk) din <= 24'h2000;
    @ (posedge mclk) din <= 24'h1000;
    @ (posedge mclk) din <= 24'h800;
    @ (posedge mclk) din <= 24'h400;
    @ (posedge mclk) din <= 24'h200;
    @ (posedge mclk) din <= 24'h100;
    @ (posedge mclk) din <= 24'h80;
    @ (posedge mclk) din <= 24'h40;
    @ (posedge mclk) din <= 24'h20;
    @ (posedge mclk) din <= 24'h10;
    @ (posedge mclk) din <= 24'h8;
    @ (posedge mclk) din <= 24'h4;
    @ (posedge mclk) din <= 24'h2;
    @ (posedge mclk) din <= 24'h1;
    @ (posedge mclk) vin <= 1'b0;

end

endmodule


//----------------------------------------
// tb_i2s_slave_tx
//----------------------------------------

module tb_i2s_slave_tx
(
	output	reg				ack,
	input	wire	[23:0]	left,
	input	wire	[23:0]	right,

	input	wire			tx_mclk,
	input	wire			tx_lrck,
	input	wire			tx_sclk,
	output	wire			tx_sdout
);

reg tx_lrck_z = 0;
reg tx_sclk_z = 0;
reg [63:0] tx_shift = 0;

initial 
begin
	ack <= 0;
end

always @ (posedge tx_mclk)
begin
	// default
	ack <= 0;

	// detect rising edge of tx_sclk
	tx_sclk_z <= tx_sclk;
	if (tx_sclk && !tx_sclk_z)
	begin
		// detect falling edge of tx_lrck
		tx_lrck_z <= tx_lrck;
		if (!tx_lrck && tx_lrck_z)
		begin
			ack <= 1;
			tx_shift <= { 1'b0, left, 8'b0, right, 7'b0 };
		end
	end
	// detect falling edge of tx_sclk
	else if (!tx_sclk && tx_sclk_z)
	begin
		tx_shift <= { tx_shift[62:0], 1'b0 };
	end
end

assign tx_sdout = tx_shift[63];

endmodule


//----------------------------------------
// tb_i2s_slave_rx
//----------------------------------------

module tb_i2s_slave_rx
(
	input	wire			rx_mclk,
	input	wire			rx_lrck,
	input	wire			rx_sclk,
	input	wire			rx_sdin,

	output	reg				ack,
	output	reg		[23:0]	left,
	output	reg		[23:0]	right
);

reg [63:0] rx_shift = 0;
reg rx_lrck_z = 0;
reg rx_sclk_z = 0;

initial 
begin
	ack <= 0;
	left <= 0;
	right <= 0;
end

always @ (posedge rx_mclk)
begin
	// defaults
	ack <= 0;

	// detect rising edge on rx_sclk and capture data
	rx_sclk_z <= rx_sclk;
	if (rx_sclk && !rx_sclk_z)
	begin
		rx_shift <= { rx_shift[62:0], rx_sdin };
	end

	// detect falling edge on rx_sclk and write data to output registers
	rx_lrck_z <= rx_lrck;
	if (!rx_lrck && rx_lrck_z)
	begin
		ack <= 1;
		left <= rx_shift[62:39];
		right <= rx_shift[30:7];
	end
end

endmodule

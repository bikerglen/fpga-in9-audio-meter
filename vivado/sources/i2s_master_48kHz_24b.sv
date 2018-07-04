//=============================================================================================
// Audio Meter I2S Interface
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

// mclk = 24.576MHz
// lrclk = 24.576MHz / 512 = 48kHz
// sclk = 24.576MHz = 3.072MHz

module i2s_master_48kHz_24b
(
	// 24.576MHz audio clock and synchronous active-high reset
	input	wire			mclk,
	input	wire			mclk_rst,

    // i2s interface to digilent i2s2 pmod 
    output  wire            tx_mclk,
    output  wire            tx_lrck,
    output  wire            tx_sclk,
    output  wire            tx_sdout,
    output  wire            rx_mclk,
    output  wire            rx_lrck,
    output  wire            rx_sclk,
    input   wire            rx_sdin,

	// transmit data from PS/PL
	output	reg				tx_ack,
	input	wire	[23:0]	tx_left,
	input	wire	[23:0]	tx_right,
	
	// receive data to PS/PL
	output	reg				rx_valid,
	output	reg		[23:0]	rx_left,
	output	reg		[23:0]	rx_right
);

// master counter to drive the rest of the logic

reg [8:0] mclk_counter;

always @ (posedge mclk)
begin
	if (mclk_rst)
	begin
		mclk_counter <= 0;
	end
	else
	begin
		mclk_counter <= mclk_counter + 1;
	end
end

// create clocks

assign tx_mclk = mclk;				// divide by 1
assign tx_lrck = mclk_counter[8];	// divide by 256
assign tx_sclk = mclk_counter[2];	// divide by 8
assign rx_mclk = mclk;				// divide by 1
assign rx_lrck = mclk_counter[8];	// divide by 256
assign rx_sclk = mclk_counter[2];	// divide by 8

// send tx data

reg [63:0] tx_shift;

always @ (posedge mclk)
begin
	if (mclk_rst)
	begin
		tx_ack <= 0;
		tx_shift <= 0;
	end
	else
	begin
		tx_ack <= 0;
		if (mclk_counter == 511)
		begin
			tx_ack <= 1;
			tx_shift <= { 1'b0, tx_left, 8'b0, tx_right, 7'b0 };
		end
		else if (mclk_counter[2:0] == 7)
		begin
			tx_shift <= { tx_shift[62:0], 1'b0 };
		end
	end
end

assign tx_sdout = tx_shift[63];

// receive rx data 

reg rx_sdin_z, rx_sdin_zz;
reg [63:0] rx_shift;

always @ (posedge mclk)
begin
	if (mclk_rst)
	begin
		rx_valid <= 0;
		rx_left <= 0;
		rx_right <= 0;
		rx_sdin_z <= 0;
		rx_sdin_zz <= 0;
		rx_shift <= 0;
	end
	else
	begin
		rx_valid <= 0;
		rx_sdin_z <= rx_sdin;
		rx_sdin_zz <= rx_sdin_z;
		if (mclk_counter[2:0] == 6)
		begin
			rx_shift <= { rx_shift[62:0], rx_sdin_zz };
		end
		else if (mclk_counter == 511)
		begin
			rx_valid <= 1;
			rx_left <= rx_shift[62:39];
			rx_right <= rx_shift[30:7];
		end
	end
end

endmodule

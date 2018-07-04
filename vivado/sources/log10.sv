//=============================================================================================
// FIXED-POINT LOG10 CORDIC
// Copyright 2018 by Glen Akins.
// All rights reserved.
// 
// Set editor width to 96 and tab stop to 4.
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

// output y width = (number of integer bits to represent max sum of all norm table and 
//                  alpha table values) + (number of norm table / alpha fractional bits)
//        y width = numbits(-9) + 12 = 5 + 12 = 17 bits

module log10
(
    input  wire        clk,     // clock
    input  wire        rst,     // reset
    input  wire        vin,     // input data valid
    input  wire [23:0] din,     // input data	(0,+1), 24b => 0.xxxx xxxx xxxx xxxx xxxx xxxx
	output reg         vout,	// output data valid
	output reg  [16:0] dout		// output data	(-16,+16), 17b => s xxxx.xxxx xxxx xxxx
);


//----------------------------------------
// normalization
//----------------------------------------

wire        nv0, norm_v; 
reg         nv1, nv2, nv3, nv4, nv5;
wire [23:0] nx0, norm_x; 
reg  [23:0] nx1, nx2, nx3, nx4, nx5;
wire [16:0] ny0, norm_y; 
reg  [16:0] ny1, ny2, ny3, ny4, ny5;

assign nv0 = vin;
assign nx0 = din;
assign ny0 = 0;

// don't register first four stages

always @ (*)
begin
	// pass valids
	nv1 <= nv0;
	nv2 <= nv1;
	nv3 <= nv2;
	nv4 <= nv3;

	// normalization round 0
	if (nx0[23: 8] == 0) begin 
		nx1 <= { nx0[ 7:0], 16'b0 }; 
		ny1 <= ny0 - 19728; 
	end else begin
		nx1 <= nx0;
		ny1 <= ny0;
	end

	// normalization round 1
	if (nx1[23:16] == 0) begin 
		nx2 <= { nx1[15:0],  8'b0 }; 
		ny2 <= ny1 -  9864; 
	end else begin
		nx2 <= nx1;
		ny2 <= ny1;
	end

	// normalization round 2
	if (nx2[23:20] == 0) begin 
		nx3 <= { nx2[19:0],  4'b0 }; 
		ny3 <= ny2 -  4932; 
	end else begin
		nx3 <= nx2;
		ny3 <= ny2;
	end

	// normalization round 3
	if (nx3[23:22] == 0) begin 
		nx4 <= { nx3[21:0],  2'b0 }; 
		ny4 <= ny3 -  2466; 
	end else begin
		nx4 <= nx3;
		ny4 <= ny3;
	end
end

// register last stage before passing normalized value to cordic function

always @ (posedge clk)
begin
    if (rst)
    begin
		nv5 <= 0;
		nx5 <= 0;
		ny5 <= 0;
    end
    else
    begin
		// pass valid
		nv5 <= nv4;

		// normalization round 4
		if (nx4[23]    == 0) 
		begin 
			nx5 <= { nx4[22:0],  1'b0 }; 
			ny5 <= ny4 -  1233; 
		end else begin
			nx5 <= nx4;
			ny5 <= ny4;
		end
    end
end

assign norm_v = nv5;
assign norm_x = nx5;
assign norm_y = ny5;


//----------------------------------------
// cordic rounds
//----------------------------------------

wire        cv0; 
reg         cv1, cv2, cv3, cv4, cv5, cv6, cv7, cv8;

wire [23:0] cx0; 
reg  [23:0] cx1, cx2, cx3, cx4, cx5, cx6, cx7, cx8;

wire [16:0] cy0; 
reg  [16:0] cy1, cy2, cy3, cy4, cy5, cy6, cy7, cy8;

reg  [24:0] tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7;

assign cv0 = norm_v;
assign cx0 = norm_x;
assign cy0 = norm_y;

always @ (*)
begin
	cv1 <= cv0;
	cv2 <= cv1;
	cv3 <= cv2;

	tmp0 <= { 1'b0, cx0[23:0] } + { 2'b0, cx0[23:1] };		// tmp = x + (x >> 1)
	cx1 <= tmp0[24] ? cx0 : tmp0[23:0];
	cy1 <= tmp0[24] ? cy0 : (cy0 - 721);

	tmp1 <= { 1'b0, cx1[23:0] } + { 3'b0, cx1[23:2] };		// tmp = x + (x >> 2)
	cx2 <= tmp1[24] ? cx1 : tmp1[23:0];
	cy2 <= tmp1[24] ? cy1 : (cy1 - 396);

	tmp2 <= { 1'b0, cx2[23:0] } + { 4'b0, cx2[23:3] };		// tmp = x + (x >> 3)
	cx3 <= tmp2[24] ? cx2 : tmp2[23:0];
	cy3 <= tmp2[24] ? cy2 : (cy2 - 209);

	tmp3 <= { 1'b0, cx3[23:0] } + { 5'b0, cx3[23:4] };		// tmp = x + (x >> 4) 
end

always @ (posedge clk)
begin
	if (rst)
	begin
		cv4 <= 0;
		cx4 <= 0;
		cy4 <= 0;
	end
	else
	begin
		cv4 <= cv3;
		cx4 <= tmp3[24] ? cx3 : tmp3[23:0];
		cy4 <= tmp3[24] ? cy3 : (cy3 - 107);
	end
end

always @ (*)
begin
	cv5 <= cv4;
	cv6 <= cv5;
	cv7 <= cv6;

	tmp4 <= { 1'b0, cx4[23:0] } + { 6'b0, cx4[23:5] };		// tmp = x + (x >> 5)
	cx5 <= tmp4[24] ? cx4 : tmp4[23:0];
	cy5 <= tmp4[24] ? cy4 : (cy4 - 54);

	tmp5 <= { 1'b0, cx5[23:0] } + { 7'b0, cx5[23:6] };		// tmp = x + (x >> 6)
	cx6 <= tmp5[24] ? cx5 : tmp5[23:0];
	cy6 <= tmp5[24] ? cy5 : (cy5 - 27);

	tmp6 <= { 1'b0, cx6[23:0] } + { 8'b0, cx6[23:7] };		// tmp = x + (x >> 7)
	cx7 <= tmp6[24] ? cx6 : tmp6[23:0];
	cy7 <= tmp6[24] ? cy6 : (cy6 - 13);

	tmp7 <= { 1'b0, cx7[23:0] } + { 9'b0, cx7[23:8] };		// tmp = x + (x >> 8)
end

always @ (posedge clk)
begin
	if (rst)
	begin
		cv8 <= 0;
		cx8 <= 0;
		cy8 <= 0;
	end
	else
	begin
		cv8 <= cv7;
		cx8 <= tmp7[24] ? cx7 : tmp7[23:0];
		cy8 <= tmp7[24] ? cy7 : (cy7 - 6);
	end
end

assign vout = cv8;
assign dout = cy8;

endmodule

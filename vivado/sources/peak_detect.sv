module peak_detect
(
	input			   clk,
	input		  	   rst,
	input        [9:0] size,
	input  wire        vin,
	input  wire [23:0] din,		// s.xxxx xxxx xxxx xxxx xxxx xxx
	output reg         vout,
	output reg  [22:0] dout		// 0.xxxx xxxx xxxx xxxx xxxx xxx
);

reg [9:0] count;
wire [9:0] nextCount;
reg [22:0] absdin;
reg [22:0] peak;

assign nextCount = count + 1;

always @ (*)
begin
	if (din == 24'h800000)
	begin
		absdin <= 23'h7FFFFF;
	end
	else if (din[23])
	begin
		absdin <= (~din[22:0]) + 1;
	end
	else
	begin
		absdin <= din[22:0];
	end
end

always @ (posedge clk)
begin
	if (rst)
	begin
		count <= 0;
		vout <= 0;
		dout <= 0;
		peak <= 0;
	end
	else
	begin
		vout <= 0;
		if (vin)
		begin
			if (nextCount == size)
			begin
				count <= 0;
				vout <= 1;
				dout <= peak;
				peak <= absdin;
			end
			else
			begin
				count <= nextCount;
				vout <= 0;
				if (absdin > peak) 
				begin
					peak <= absdin;
				end
			end
		end
	end
end

endmodule

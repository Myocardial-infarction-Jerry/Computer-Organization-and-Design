`timescale 1ns / 1ps
module PC(
	input CLK,
	input Reset,
	input PCWre,
	input[31:0] newAddress,
	output reg[31:0] PCAddr
);
	initial begin
		PCAddr=	0;
	end
	always@(posedge CLK or negedge Reset) begin
		if (Reset == 0) begin
			PCAddr=	0;
		end
		else if (PCWre) begin
			PCAddr=	newAddress;
		end
	end
endmodule
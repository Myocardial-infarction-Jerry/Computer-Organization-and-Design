`timescale 1ns / 1ps
module Multiplexer32(
	input Select,
	input[31:0] DataIn1,
	input[31:0] DataIn2,
	output[31:0] DataOut
);
	assign DataOut=	Select ? DataIn2 : DataIn1;
endmodule
`timescale 1ns / 1ps
module Multiplexer5(
	input Select,
	input[4:0] DataIn1,
	input[4:0] DataIn2,
	output[4:0] DataOut
);
	assign DataOut=	Select ? DataIn2 : DataIn1;
endmodule
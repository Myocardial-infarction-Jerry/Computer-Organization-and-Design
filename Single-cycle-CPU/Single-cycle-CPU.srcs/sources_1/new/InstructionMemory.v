`timescale 1ns / 1ps
module InstructionMemory(
	input[31:0] IAddr,
	input RW,
	output reg[31:0] IDataOut
);
	reg[7:0] InstMemory[255:0];
	initial begin	//此处为绝对地址，注意斜杠方向
		$readmemb("C:/Users/Administrator/Documents/GitHub/Computer-Organization-and-Design/Single-cycle-CPU/input.txt", InstMemory);
	end
	always@(IAddr or RW) begin
		if (RW==0) begin
			IDataOut={InstMemory[IAddr], InstMemory[IAddr + 1], InstMemory[IAddr + 2], InstMemory[IAddr + 3]};
		end
	end
endmodule
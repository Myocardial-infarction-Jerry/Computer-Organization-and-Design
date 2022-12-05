`timescale 1ns / 1ps
module DataMemory(
	input[31:0] DAddr,
	input CLK,
	input mRD,
	input mWR,
	input[31:0] DataIn,
	output reg[31:0] DataOut
);
	reg[7:0] dataMemory [255:0];
	always@(mRD or DAddr) begin
		if (mRD) begin
			DataOut[7:0]=	dataMemory[DAddr + 3];
			DataOut[15:8]=	dataMemory[DAddr + 2];
			DataOut[23:16]=	dataMemory[DAddr + 1];
			DataOut[31:24]=	dataMemory[DAddr];
		end
	end
	always@(negedge CLK) begin	//总是在时钟下降沿到来时触发
		if (mWR) begin
			dataMemory[DAddr + 3]<=	DataIn[7:0];
			dataMemory[DAddr + 2]<=	DataIn[15:8];
			dataMemory[DAddr + 1]<=	DataIn[23:16];
			dataMemory[DAddr]<=		DataIn[31:24];
		end
	end
endmodule
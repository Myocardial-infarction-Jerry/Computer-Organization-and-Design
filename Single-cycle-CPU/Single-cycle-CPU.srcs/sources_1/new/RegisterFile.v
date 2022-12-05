`timescale 1ns / 1ps
module RegisterFile(
	input WE,
	input CLK,
	input[4:0] ReadReg1,
	input[4:0] ReadReg2,
	input[4:0] WriteReg,
	input[31:0] WriteData,
	output[31:0] ReadData1,
	output[31:0] ReadData2
);
	reg[31:0] registers[0:31];
	integer i;
	initial begin	//初始时，将32个寄存器全部赋值为0
		for(i = 0; i < 32; i = i + 1) 
			registers[i]<=0;
	end
	assign ReadData1=ReadReg1 ? registers[ReadReg1] : 0;
	assign ReadData2=ReadReg2 ? registers[ReadReg2] : 0;
	always@(negedge CLK) begin
		if (WriteReg&&WE) begin
			registers[WriteReg]=WriteData;
		end
	end
endmodule
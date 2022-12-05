`timescale 1ns / 1ps
module SingleCPU(
	input CLK,				//时钟信号
	input Reset,			//置零信号
	output[31:0] CurPC,		//当前指令地址
	output[31:0] newaddress,//下一个指令地址
	output[31:0] instcode,	//rs,rt寄存器所在指令
	output[31:0] Reg1Out,	//寄存器组rs寄存器的值
	output[31:0] Reg2Out,	//寄存器组rt寄存器的值
	output[31:0] ALU_Out,	//ALU的result输出值
	output[31:0] WriteData	//DB总线值
);
	wire ExtSel;			//位扩展信号，1为符号扩展，0为0扩展
	wire PCWre;				//PC工作信号，0不更改，1更改
	wire InsMemRW;			//指令寄存器信号，0为写，1为读
	wire RegDst;			//指令读取时判断是rt还是rd进入寄存器组的写数据端，0为rt，1为rd
	wire RegWre;			//寄存器组是否需要写功能，0为无写功能，1为些功能
	wire[2:0] ALUOp;		//ALU8种运算功能选择
	wire[1:0] PCSrc;		//PC正常+4还是要跳转，0为正常+4，1为跳转
	wire ALUSrcA;			//寄存器组Data1的输出，0为寄存器本身输出，1为指令码的最后16位立即数
	wire ALUSrcB;			//寄存器组Data2的输出，0位本身的输出，1为扩展后的立即数
	wire RD;				//读数据存储器功能，0时读取
	wire WR;				//写数据存储器功能，1时写
	wire DBDataSrc;			//决定将什么数据传入寄存器组Write Data端，0为ALU结果，1为存储器
	wire[4:0] WriteRegAddr;	//寄存器组Write Reg输入端
	wire[31:0] ALU_Input_A;	//ALU的A输入端
	wire[31:0] ALU_Input_B;	//ALU的B输入端
	wire zero;				//ALU的zero输出
	wire sign;				//ALU的sign输出
	wire[31:0] MemOut;		//存储器的输出
	wire[31:0] Ext_Imm;		//位扩展后的立即数
	wire[31:0] CurPC4 = CurPC + 4;
	assign newaddress =	(PCSrc == 2'b01) ? {CurPC4[31:28], instcode[25:0], 2'b00}:
						(PCSrc == 2'b10) ? CurPC4 + (Ext_Imm << 2) : CurPC4;
	PC pc(CLK, Reset, PCWre, newaddress, CurPC);
	ALU alu(ALU_Input_A, ALU_Input_B, ALUOp, ALU_Out, zero, sign);
	DataMemory dm(ALU_Out, CLK, RD, WR, Reg2Out, MemOut);
	SignZeroExtend sze(instcode[15:0], ExtSel, Ext_Imm);
	Multiplexer5 mux21R(RegDst, instcode[20:16], instcode[15:11], WriteRegAddr);
	Multiplexer32 mux21A(ALUSrcA, Reg1Out, {27'b000000000000000000000000000, instcode[10:6]}, ALU_Input_A);
	Multiplexer32 mux21B(ALUSrcB, Reg2Out, Ext_Imm, ALU_Input_B);
	Multiplexer32 mux21RW(DBDataSrc, ALU_Out, MemOut, WriteData);
	RegisterFile rf(RegWre, CLK, instcode[25:21], instcode[20:16], WriteRegAddr, WriteData, Reg1Out, Reg2Out);
	ControlUnit cu(ExtSel, PCWre, InsMemRW, RegDst, RegWre, ALUOp, PCSrc, ALUSrcA, ALUSrcB, RD, WR, DBDataSrc, instcode[31:26], zero, sign);
	InstructionMemory im(CurPC, InsMemRW, instcode);
endmodule
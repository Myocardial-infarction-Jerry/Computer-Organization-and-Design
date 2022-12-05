`timescale 1ns / 1ps
module ALU(
	input[31:0] A,				//输入A
	input[31:0] B,				//输入B
	input[2:0] ALUOp,			//ALU操作控制
	output reg[31:0] result,	//ALU运算结果
	output zero,				//运算结果result的标志，result为0输出1，否则输出0
	output sign					//运算结果result的正负性（有符号数的情况），result为负数输出1，否则输出0
);
	parameter _ADD=	3'b000;
	parameter _SUB=	3'b001;
	parameter _SLL=	3'b010;
	parameter _OR=	3'b011;
	parameter _AND=	3'b100;
	parameter _SLTU=3'b101;
	parameter _SLT=	3'b110;
	parameter _XOR=	3'b111;

	assign zero=	result == 0;
	assign sign=	result[31];

	always@(*)begin												//进行ALU计算
		case(ALUOp)												//进行运算
		_ADD:	result=	A + B;  								//加法
		_SUB:	result=	A - B;  								//减法
		_SLL:	result=	B << A;  								//B左移A位
		_OR:	result=	A | B;  								//或
		_AND:	result=	A & B;  								//与
		_SLTU:	result=	A < B;  								//比较A<B不带符号
		_SLT:	result=	A[31] != B[31] ? A[31] > B[31] : A < B;	//比较A<B带符号
		_XOR:	result=	A ^ B;									//异或
		default:result=	0;
		endcase
	end
endmodule
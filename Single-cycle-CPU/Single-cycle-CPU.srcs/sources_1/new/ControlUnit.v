`timescale 1ns / 1ps
module ControlUnit(
	output ExtSel,
	output PCWre,
	output InsMemRW,
	output RegDst,
	output RegWre,
	output[2:0] ALUOp,
	output[1:0] PCSrc,
	output ALUSrcA,
	output ALUSrcB,
	output mRD,
	output mWR,
	output DBDataSrc,
	input[5:0] op,
	input zero,
	input sign
);
	parameter ADD=	6'b000000;
	parameter SUB=	6'b000001;
	parameter ADDIU=6'b000010;
	parameter ANDI=	6'b010000;
	parameter AND=	6'b010001;
	parameter ORI=	6'b010010;
	parameter OR=	6'b010011;
	parameter SLL=	6'b011000;
	parameter SLTI=	6'b011100;
	parameter SW=	6'b100110;
	parameter LW=	6'b100111;
	parameter BEQ=	6'b110000;
	parameter BNE=	6'b110001;
	parameter BLTZ=	6'b110010;
	parameter J=	6'b111000;
	parameter HALT=	6'b111111;
	parameter _ADD=	3'b000;
	parameter _SUB=	3'b001;
	parameter _SLL=	3'b010;
	parameter _OR=	3'b011;
	parameter _AND=	3'b100;
	parameter _SLTU=3'b101;
	parameter _SLT=	3'b110;
	parameter _XOR=	3'b111;

	assign PCWre=		op != HALT;
	assign ALUSrcA=		op == SLL;
	assign ALUSrcB=		op == ADDIU || op == ANDI || op == ORI || op == SLTI || op == SW || op == LW;
	assign DBDataSrc=	op == LW;
	assign RegWre=		op != BEQ && op != BNE && op != BLTZ && op != SW && op != HALT;
	assign InsMemRW=	0;
	assign mRD=			op == LW;
	assign mWR=			op == SW;
	assign RegDst=		op != ADDIU && op != ANDI && op != ORI && op != SLTI && op != LW;
	assign ExtSel=		op != ANDI && op != ORI;
	assign PCSrc[0]=	op == J;
	assign PCSrc[1]=	op == BEQ && zero == 1 || op == BNE && zero == 0 || op == BLTZ && sign == 1;
	assign ALUOp=		op == SUB || op == BNE || op == BEQ || op == BLTZ ? _SUB :
						op == SLL ? _SLL:
						op == ORI || op == OR ? _OR :
						op == ANDI || op == AND ? _AND:
						op == SLTI ? _SLT : _ADD;
endmodule
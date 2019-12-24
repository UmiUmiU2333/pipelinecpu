`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:56:34 11/20/2019 
// Design Name: 
// Module Name:    regIDEX 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
//  D��EX�������ˮ�߼Ĵ���
module regIDEX(
    input CLK,
	input reset,
	 input clr,
    input [31:0] IR_D,
    input [31:0] PC4_D,
    input [31:0] RD1_D,
    input [31:0] RD2_D,
    input [31:0] EXT_D,
    output reg [31:0] IR_EX,
    output reg [31:0] PC4_EX,
    output reg [31:0] RD1_EX,
    output reg [31:0] RD2_EX,
    output reg [31:0] EXT_EX
    );
	 // �Ĵ�����ʼ��
	 initial begin
		IR_EX = 0;
		PC4_EX = 0;
		RD1_EX=0;
		RD2_EX= 0 ;
		EXT_EX = 0;
	 end
	 
	 // �����ظ��¼Ĵ���ֵ
	always @(posedge CLK)begin
		if(reset)begin
			IR_EX <= 0;
			PC4_EX <= 0;
			RD1_EX<=0;
			RD2_EX <= 0 ;
			EXT_EX <= 0;
		end else if(clr)begin
			IR_EX <= 0;
			PC4_EX <= 0;
			RD1_EX <= 0;
			RD2_EX <=0;
			EXT_EX <= 0;
		end else begin
			IR_EX <= IR_D;
			PC4_EX<= PC4_D;
			RD1_EX <= RD1_D;
			RD2_EX <= RD2_D;
			EXT_EX <= EXT_D;
		end
	end

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:59:34 11/20/2019 
// Design Name: 
// Module Name:    regEXMEM 
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
module regEXMEM(
    input CLK,
	input reset,
    input [31:0] IR_EX,
    input [31:0] PC4_EX,
    input [31:0] RD2_EX,
    input [31:0] AO_EX,
    output reg [31:0] IR_MEM,
    output reg [31:0] PC4_MEM,
    output reg[31:0] RD2_MEM,
    output reg [31:0] AO_MEM
    );
	 // �Ĵ�����ʼ��
	 initial begin
		IR_MEM = 0;
		PC4_MEM = 0;
		RD2_MEM=0;
		AO_MEM = 0 ;
	 end
	 
	 // �����ظ��¼Ĵ���ֵ
	always @(posedge CLK)begin
		if(reset)begin
			IR_MEM <= 0;
			PC4_MEM <= 0;
			RD2_MEM<=0;
			AO_MEM <= 0 ;
		end else begin
			IR_MEM <= IR_EX;
			PC4_MEM <= PC4_EX;
			RD2_MEM <= RD2_EX;
			AO_MEM <= AO_EX;
		end

	end

endmodule

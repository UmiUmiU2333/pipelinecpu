`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:03:06 11/20/2019 
// Design Name: 
// Module Name:    regMEMWB 
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
module regMEMWB(
    input CLK,
	input reset,
    input [31:0] IR_MEM,
    input [31:0] PC4_MEM,
    input [31:0] AO_MEM,
    input [31:0] DR_MEM,
    output reg [31:0] IR_WB,
    output reg [31:0] PC4_WB,
    output reg [31 :0] AO_WB,
    output reg [31:0] DR_WB
    );
	 // �Ĵ�����ʼ��
	 initial begin
		IR_WB = 0;
		PC4_WB = 0;
		AO_WB=0;
		DR_WB = 0 ;
	 end
	 
	 // �����ظ��¼Ĵ���ֵ
	always @(posedge CLK)begin
		if(reset)begin
			IR_WB <= 0;
			PC4_WB <= 0;
			AO_WB <= 0;
			DR_WB <= 0 ;
		end else begin
			IR_WB <= IR_MEM;
			PC4_WB <= PC4_MEM;
			AO_WB <= AO_MEM;
			DR_WB <= DR_MEM;
		end

	end

endmodule

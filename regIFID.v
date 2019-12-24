`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:48:13 11/20/2019 
// Design Name: 
// Module Name:    IFID 
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
// F��D�������ˮ�߼Ĵ���
// 
// 
module regIFID(
	input CLK,
	input reset,
	input en,
    input [31:0] IR_F,
    input [31:0] PC4_F,
    output reg [31:0] IR_D,
    output reg [31:0] PC4_D
    );
	 
	 // �Ĵ�����ʼ��
	 initial begin
		IR_D = 0;
		PC4_D = 0;
	 end
	 
	 // �����ظ��¼Ĵ���ֵ
	always @(posedge CLK)begin
		if(reset)begin
			IR_D <= 0;
			PC4_D <= 0;
		end else if(en)begin
			IR_D <= IR_F;
			PC4_D <= PC4_F;
		end else begin
			IR_D <= IR_D;  // ������
			PC4_D <= PC4_D;
		end
	end

endmodule

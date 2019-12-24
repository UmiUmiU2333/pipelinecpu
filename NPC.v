`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:22:58 11/20/2019 
// Design Name: 
// Module Name:    NPC 
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

// beq, j, jal ʹ�øò������֣� beq i16��չ��j��jal��i26��չ

// ����b��j��ָ��ֱ����npc
// sel =0, b�࣬ sel=1��j��
module NPC(
	 input [31:0] pc4,
    input [25:0] imm26,
	 input [1:0] sel,
    output [31:0] npc
    );
	 wire [15:0] imm16;
	 assign imm16 = imm26[15:0];
	 assign npc =  (sel == 0)?   (pc4 + { {14{imm16[15]}}, imm16, {2{1'b0}}}):  // b��
									(sel == 1)? {pc4[31:28] , imm26, {2{1'b0}}}:  // j��
									0;


endmodule

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

// beq, j, jal 使用该部件出现， beq i16拓展，j和jal是i26拓展

// 根据b类j类指令分别计算npc
// sel =0, b类， sel=1，j类
module NPC(
	 input [31:0] pc4,
    input [25:0] imm26,
	 input [1:0] sel,
    output [31:0] npc
    );
	 wire [15:0] imm16;
	 assign imm16 = imm26[15:0];
	 assign npc =  (sel == 0)?   (pc4 + { {14{imm16[15]}}, imm16, {2{1'b0}}}):  // b类
									(sel == 1)? {pc4[31:28] , imm26, {2{1'b0}}}:  // j类
									0;


endmodule

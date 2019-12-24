`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:41:18 11/09/2019 
// Design Name: 
// Module Name:    EXT 
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
// 输入16位立即数，输出拓展后的32位数
// Input sel= 0: 无符号拓展
// sel = 1: 符号拓展
module EXT(
		input[15:0] imm16,
		input[1:0] sel, 
		output[31:0] extOut
    );
	  /*input [15:0] imm16,
	 input [25:0] imm26,
    output [31:0] SignEXT,
    output [31:0] ZeroEXT,
    output [31:0] imm16SignEXTShift16,
	 output[31:0] imm16Shift2SignEXT,
	 output[27:0] imm26Shift2*/
	 // 注意符号拓展

	assign extOut = (sel == 0)? { {16{1'b0}}, imm16} :       // 无符号拓展
									(sel == 1)? {{16{imm16[15]}} , imm16 } :  // 符号拓展
									(sel == 2)? {imm16, {16{1'b0}}}:
									0;
	/*assign  imm16SignEXTShift16 = SignEXT << 16;
	assign imm16Shift2SignEXT = { {14{imm16[15]}} , imm16,{2{1'b0}}};  
	assign imm26Shift2 = {imm26, {2{1'b0}}};*/
endmodule











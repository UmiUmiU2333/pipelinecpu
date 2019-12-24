`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:28:24 11/09/2019 
// Design Name: 
// Module Name:    IFU 
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

// ������
module IFU(
    input Clk,
	input reset,
	input en,
    input [31:0] PCNext,

    output  [31:0] Instr,
    output reg [31:0] PCNow
    );
	 //  ʵ����IM��32bit * 1KB = 4KB
	 ROM1k32bit IM(
		.PCNow(PCNow), 
		.Sel(1'b1), 
		.D(Instr)
	 );
	 // ��ʼ��PC
	 initial begin
		  PCNow = 32'h00003000; 
	 end
	 
	always @(posedge Clk) begin
		if(reset)begin
			PCNow <= 32'h00003000; 
		end else if(en)begin
			PCNow <= PCNext;
		end else begin
			PCNow <= PCNow;
		end 	
		
	end

endmodule

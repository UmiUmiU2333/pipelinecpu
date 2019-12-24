`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:00:58 11/20/2019 
// Design Name: 
// Module Name:    Mux4 
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
module Mux4(
    input [MuxWidth-1 : 0] d0,
    input [MuxWidth-1 : 0]  d1,
    input [MuxWidth-1 : 0]  d2,
    input [MuxWidth-1 : 0]  d3,
    input [1:0] sel,
    output [MuxWidth-1 : 0]  dOut
    );
	parameter MuxWidth = 32;
	assign dOut =  (sel == 0 )? d0 : 
								(sel == 1 )?d1 :	
								(sel == 2 )?d2:	
								d3;	
endmodule

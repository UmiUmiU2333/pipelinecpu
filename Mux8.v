`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:01:40 11/25/2019 
// Design Name: 
// Module Name:    Mux8 
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
module Mux8(
    input [MuxWidth-1 : 0] d0,
    input [MuxWidth-1 : 0]  d1,
    input [MuxWidth-1 : 0]  d2,
    input [MuxWidth-1 : 0]  d3,
    input [MuxWidth-1 : 0] d4,
    input [MuxWidth-1 : 0]  d5,
    input [MuxWidth-1 : 0]  d6,
    input [MuxWidth-1 : 0]  d7,
    input [2:0] sel,
    output [MuxWidth-1 : 0] dout
    );
	parameter MuxWidth = 32;
	assign dout =  (sel == 0 )? d0 : 
			    (sel == 1 )?d1 :	
				(sel == 2 )?d2:	
				(sel == 3 )?d3:	
                (sel == 4 )?d4:	
                (sel == 5 )?d5:	
                (sel == 6 )?d6:	
                d7;	
endmodule



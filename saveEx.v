`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:14:28 12/10/2019 
// Design Name: 
// Module Name:    saveEx 
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
// Get new data to be written according to save type
`define op 31:26
module saveEx(
    input [31:0] IR,
    input [31:0] Addr,
    input [31:0] data_old,
    input [31:0] WD,
    output [31:0] data_new
    );
    parameter sbop = 6'b101000, shop = 6'b101001,swop = 6'b101011;

    wire [7:0] byte3, byte2, byte1,byte0, byte1_new, byte0_new;
    
    assign byte3 = data_old[31:24], byte2 = data_old[23:16], byte1 = data_old[15:8], byte0 = data_old[7:0],
    byte1_new = WD[15:8], byte0_new = WD[7:0];
    assign data_new = (IR[`op] == swop)? WD:
                    (IR[`op] == shop && (Addr % 4 == 0))? {byte3, byte2, byte1_new, byte0_new}: // addr: 0,4,8
                    (IR[`op] == shop && (Addr % 4 == 2))? {byte1_new, byte0_new, byte1, byte0}: // addr: 2,6,8
                    (IR[`op] == sbop && (Addr % 4 == 0))? {byte3, byte2, byte1, byte0_new}: // addr:0,4,8
                    (IR[`op] == sbop && (Addr % 4 == 1))? {byte3, byte2, byte0_new, byte0}: // addr:1,5,9
                    (IR[`op] == sbop && (Addr % 4 == 2))? {byte3, byte0_new, byte1, byte0}: // addr:2,6,10
                    (IR[`op] == sbop && (Addr % 4 == 3))? {byte0_new, byte2, byte1, byte0}:
                    0; // addr:3,7,11
endmodule

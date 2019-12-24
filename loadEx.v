`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:44:27 12/10/2019 
// Design Name: 
// Module Name:    loadEx 
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
// lw.lb,lbu,lh,lhu
`define op 31:26
module loadEx(
    input [31:0] IR,
    input [31:0] Addr,
    input [31:0] RD,
    output [31:0] RD_NEW
    );
    parameter lwop = 6'b100011, lbop = 6'b100000, lbuop = 6'b100100, lhop = 6'b100001, lhuop = 6'b100101;

    assign RD_NEW = (IR[`op] == lwop)? RD:
                    (IR[`op] == lhop && (Addr%4 == 0))? {{16{RD[15]}}, RD[15:0]}:  // signed ext
                    (IR[`op] == lhop && (Addr%4 == 2))? {{16{RD[31]}}, RD[31:16]}:  // 
                    (IR[`op] == lhuop && (Addr%4 == 0))? {{16{1'b0}}, RD[15:0]}:  // unsigned ext
                    (IR[`op] == lhuop && (Addr%4 == 2))? {{16{1'b0}}, RD[31:16]}:  // 
                    (IR[`op] == lbop && (Addr%4 == 0))? {{24{RD[7]}}, RD[7:0]}:  // signed ext
                    (IR[`op] == lbop && (Addr%4 == 1))? {{24{RD[15]}}, RD[15:8]}:  // 
                    (IR[`op] == lbop && (Addr%4 == 2))? {{24{RD[23]}}, RD[23:16]}:  // 
                    (IR[`op] == lbop && (Addr%4 == 3))? {{24{RD[31]}}, RD[31:24]}:  // 
                    (IR[`op] == lbuop && (Addr%4 == 0))? {{24{1'b0}}, RD[7:0]}:  // unsigned ext
                    (IR[`op] == lbuop && (Addr%4 == 1))? {{24{1'b0}}, RD[15:8]}:  // 
                    (IR[`op] == lbuop && (Addr%4 == 2))? {{24{1'b0}}, RD[23:16]}:  // 
                    (IR[`op] == lbuop && (Addr%4 == 3))? {{24{1'b0}}, RD[31:24]}:
                    0;  // 

                    

endmodule

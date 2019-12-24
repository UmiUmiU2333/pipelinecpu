`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:34:35 12/09/2019 
// Design Name: 
// Module Name:    instru_classification 
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
`define op 31:26
`define rs 25:21
`define rt 20:16
`define rd 15:11
`define func 5:0

module instru_classification(
    input [31:0] instru,
    output calc_r,
    output calc_i,
    output typeb,
	output store,
	output load,
	output mt,
	output mf,
	output mcalc,
	output [2:0] extra
    );
	// 指令集
	// addu, subu, ori, lw, sw, beq, lui, j, jal, jr, nop;
	parameter rop = 6'b000000, lwop = 6'b100011, swop = 6'b101011, beqop = 6'b000100,
	luiop = 6'b001111, oriop = 6'b001101, jalop = 6'b000011, jop=6'b000010,
    sltiop = 6'b001010, sltiuop = 6'b001011,
    xoriop =6'b001110, addiop =6'b001000 , addiuop = 6'b001001, andiop =6'b001100,
    bneop = 6'b000101, blezop = 6'b000110, bgtzop = 6'b000111, bltzop = 6'b000001, bgezop= 6'b000001, // bltz and bgez have the same op, bgez[rt] == 5'b00001
	sbop = 6'b101000, shop = 6'b101001,
	lbop = 6'b100000, lbuop = 6'b100100, lhop = 6'b100001, lhuop = 6'b100101,
    mfhifunc = 6'b010000, mflofunc=6'b010010, mthifunc = 6'b010001, mtlofunc = 6'b010011,
    multfunc = 6'b011000, multufunc = 6'b011001, divfunc = 6'b011010, divufunc = 6'b011011,
	maddop = 6'b011100;

	parameter addufunc = 6'b100001, subufunc = 6'b100011, jrfunc = 6'b001000,nopfunc=6'b000000,

    addfunc = 6'b100000, subfunc = 6'b100010, 
    sllfunc = 6'b000000, srlfunc=6'b000010 ,srafunc =6'b000011 , sllvfunc = 6'b000100, srlvfunc =6'b000110, sravfunc = 6'b000111,
    andfunc = 6'b100100, orfunc = 6'b100101, xorfunc = 6'b100110, norfunc = 6'b100111,
    sltfunc = 6'b101010,  sltufunc = 6'b101011;

	assign calc_i = (instru[`op] == oriop) | 
            (instru[`op] == andiop) | 
            (instru[`op] == xoriop) |
            (instru[`op] == addiop) |
            (instru[`op] == addiuop) |
            (instru[`op] == sltiop) |
            (instru[`op] == sltiuop);

	assign calc_r = ((instru[`op] == rop) && (instru[`func] == addufunc |
					instru[`func] == subufunc |
					instru[`func] == addfunc |
					instru[`func] == subfunc |
					instru[`func] == sllvfunc |
					instru[`func] == srlvfunc|
					instru[`func] == sravfunc |
					instru[`func] == andfunc |
					instru[`func] == orfunc |
					instru[`func] == xorfunc |
					instru[`func] == norfunc |
					instru[`func] == sltfunc |
					instru[`func] == sltufunc |
					(instru[`func] == sllfunc  && instru != 0)|
					instru[`func] == srlfunc |
					instru[`func] == srafunc 
					));
    assign typeb = (instru[`op] == beqop | instru[`op] == bneop | instru[`op] == blezop | instru[`op]==bgtzop
                | instru[`op] == bltzop | (instru[`op] == bgezop && instru[`rt] == 5'b00001));

	assign store = (instru[`op] == swop | instru[`op] == shop | instru[`op] == sbop);
	assign load =  (instru[`op] == lwop | instru[`op] == lhop | instru[`op] == lbop|
					instru[`op] == lhuop | instru[`op] == lbuop );

    assign mt = (instru[`op] == rop && (instru[`func] == mthifunc | instru[`func] == mtlofunc)),
    mf = (instru[`op] == rop && (instru[`func] == mfhifunc | instru[`func] == mflofunc));

	assign mcalc = (instru[`op] == rop && (instru[`func] == multfunc | instru[`func] == multufunc | instru[`func] == divfunc | instru[`func] == divufunc)) |
					(instru[`op] == maddop);

	assign extra = 0;	 
endmodule

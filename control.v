`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:57:06 11/11/2019 
// Design Name: 
// Module Name:    control 
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
module control(
	input [31:0] Instru,
	 output [21:0] ctrl,
	 output [2:0] extra
    );
	wire [5:0] func, op;
	assign func =  Instru[5:0];
	assign op = Instru[31:26];

	
	// Instru op And func
	parameter rop = 6'b000000, lwop = 6'b100011, swop = 6'b101011, beqop = 6'b000100,
	luiop = 6'b001111, oriop = 6'b001101, jalop = 6'b000011, jop=6'b000010,
    sltiop = 6'b001010, sltiuop = 6'b001011,
    xoriop =6'b001110, addiop =6'b001000 , addiuop = 6'b001001, andiop =6'b001100,
    bneop = 6'b000101, blezop = 6'b000110, bgtzop = 6'b000111, bltzop = 6'b000001, bgezop= 6'b000001, // bltz and bgez have the same op, bgez[rt] == 5'b00001
	sbop = 6'b101000, shop = 6'b101001,
	lbop = 6'b100000, lbuop = 6'b100100, lhop = 6'b100001, lhuop = 6'b100101;
	

	parameter addufunc = 6'b100001, subufunc = 6'b100011, jrfunc = 6'b001000,nopfunc=6'b000000,

    addfunc = 6'b100000, subfunc = 6'b100010, 
    sllfunc = 6'b000000, srlfunc=6'b000010 ,srafunc =6'b000011 , sllvfunc = 6'b000100, srlvfunc =6'b000110, sravfunc = 6'b000111,
    andfunc = 6'b100100, orfunc = 6'b100101, xorfunc = 6'b100110, norfunc = 6'b100111,
    sltfunc = 6'b101010,  sltufunc = 6'b101011,
	jalrfunc = 6'b001001,
	mfhifunc = 6'b010000, mflofunc=6'b010010, mthifunc = 6'b010001, mtlofunc = 6'b010011,
	multfunc = 6'b011000, multufunc = 6'b011001, divfunc = 6'b011010, divufunc = 6'b011011,
	maddop = 6'b011100;
	// 
	reg [31:0] Debug_InstrNow = 0;  // ASCII 
	
	// 
	always @(*)begin
		case(op)
			lwop: begin Debug_InstrNow = "lw"; end
			swop: begin Debug_InstrNow = "sw";end
			beqop: begin Debug_InstrNow = "beq";end
			luiop: begin Debug_InstrNow = "lui";end
			oriop: begin Debug_InstrNow = "ori";end
			jalop:begin Debug_InstrNow = "jal";end
			jop: begin Debug_InstrNow = "jal";end
			rop:begin
				case(func)
					addufunc: begin Debug_InstrNow = "addu";end
					subufunc: begin Debug_InstrNow = "subu";end
					jrfunc: begin  Debug_InstrNow = "jr";end
					nopfunc: begin Debug_InstrNow = "nop";end
				endcase
			end
		endcase
	end
	
	// Control Signal 
	wire [4:0] ALUOp; 
	wire [1:0] PCSrc_D, extSel, npcSel, ALUASrc,ALUBSrc;
	wire DM_WE_M, DM_RE_M, RF_WE_W;
	wire [1:0] RegDst, RegSrc;

	assign ctrl = {PCSrc_D, extSel, npcSel, ALUASrc, ALUBSrc, ALUOp, DM_WE_M, DM_RE_M, RF_WE_W, RegDst, RegSrc};
	 /*PCSrc_D = ctrl[21:20];
	 extSel = ctrl[19:18];
	 npcSel = ctrl[17:16];
	 ALUASrc = ctrl[15:14];
	 ALUBSrc  = ctrl[13:12];
	 ALUOp = ctrl[11:7]
	 DM_WE_M = ctrl[6];
	 DM_RE_M = ctrl[5];
	 RF_WE_W = ctrl[4];
	 RegDst = ctrl[3:2];
	 RegSrc = ctr;[1:0];
	 */

	// classification
	wire calc_i_z, calc_i_s; // Zero Ext or Sign EXT
	assign calc_i_z = (op == oriop) |
					(op == andiop) |
					(op == xoriop) ,

	calc_i_s = (op == addiop) |
				(op == addiuop)|
				(op == sltiop) |
				(op == sltiuop);

	// calc_r
	wire calc_r;
	assign calc_r = ((op== rop) && (func == addufunc |
					func == subufunc |
					func == addfunc |
					func == subfunc |
					func == sllvfunc |
					func == srlvfunc|
					func == sravfunc |
					func == andfunc |
					func == orfunc |
					func == xorfunc |
					func == norfunc |
					func == sltfunc |
					func == sltufunc |
					(func == sllfunc && Instru != 0 ) |  // Sll Not Nop
					func == srlfunc |
					func == srafunc
					));
	// typeb
	wire typeb;
    assign typeb = (op == beqop | op == bneop | op == blezop | op==bgtzop
                | op == bltzop | (op == bgezop && Instru[20:16] == 5'b00001));

	// 
	wire store, load; 
	assign store = (op == swop | op == shop | op == sbop);
	assign load =  (op == lwop | op == lhop | op == lbop|
					op == lhuop | op == lbuop );

    wire mt, mf;
    assign mt = (op == rop && (func == mthifunc | func == mtlofunc)),
    mf = (op == rop && (func == mfhifunc | func == mflofunc));

    wire mcalc;
    assign mcalc = (op == rop && (func == multfunc |func == multufunc| func == divfunc|  func == divufunc)) |
					(op == maddop);

// Ctrl Signal
	// Source of Next PC 
	// 0: PC4_F
	// 1: output of module NPC
	// 2: RD1_D
	// 3: bnpc(Jump if condition)

	assign PCSrc_D = typeb? 3:
					((op == rop) && (func == jrfunc | func == jalrfunc)) ? 2:
					(op == jop | op == jalop) ? 1:
					0;

	// extSel
	// 0, unsigned ext
	// 1, signed ext
	// 2, lui left shift 16
	assign extSel = (op == luiop) ? 2:
					(store | load | calc_i_s) ? 1:
					0;

	// npcSel, signal to control module npc
	// 0: type b Instru
	// 1: type J Instru
	assign npcSel = (op == jop | op == jalop) ? 1:
					0;


	// ALUASrc, Source of ALUA
	// 0: Rs, RD1_E
	// 1: 0
	assign ALUASrc = (op == luiop) ? 1:
					0;

	// ALUBSrc
	// 0: EXT_E
	// 1: RD2_E
	assign ALUBSrc = (calc_r | mcalc) ? 1:
					0;

	// ALUOp
	// 0: unsigned+
	// 1: unsigned- 
	// 2: and
	// 3: or
	// 4: xor
	// 5: SLTI
	// 6: SLTIU(Unsigned Num)
	// 7: signed +
	// 8: signed -
	// 9: SLLV, 10: SRLV, 11: SRAV, 12: SLL, 13: SRL, 14: SRA
	// 15: Nor
	// 16: SLT, Set less than
	// 17: SLTU
	assign ALUOp = (op == rop && func == subufunc) ? 1: 
				(op == andiop | (op == rop && func == andfunc)) ? 2:
				(op == oriop | (op == rop && func == orfunc)) ? 3: 
				(op == xoriop |(op == rop && func == xorfunc))? 4: 
				(op == sltiop) ? 5:
				(op == sltiuop) ? 6:
				(op == addiop | op == addiuop | (op == rop && func == addfunc)) ? 7:
				(op == rop && func == subfunc) ? 8:
				(op == rop && func == sllvfunc) ? 9:
				(op == rop && func == srlvfunc) ? 10:
				(op == rop && func == sravfunc) ? 11:
				(op == rop && func == sllfunc) ? 12:
				(op == rop && func == srlfunc) ? 13:
				(op == rop && func == srafunc) ? 14:
				(op == rop && func == norfunc) ? 15:	
				(op == rop && func == sltfunc) ? 16:	
				(op == rop && func == sltufunc) ? 17:	
				0;
	
	// DM_WE_M, Data MEM Write Enable
	assign DM_WE_M = store;

	// DM_RE_M
	assign DM_RE_M = load ;

	// RF_WE_W
	assign RF_WE_W = calc_r|
					calc_i_s| calc_i_z|
					load |
					(op == jalop) |
					(op == luiop) |
					((op == rop) && (func == jalrfunc))|
					mf;

	// RegDst, Addr of GRF When Write Enable
	// 0: Rt
	// 1: Rd
	// 2: 31
	assign RegDst = (op == jalop) ? 2:
					(calc_r | ((op == rop) && (func == jalrfunc))) | mf? 1:
					0;

	// RegSrc, Data of GRF When Write Enable
	// 0: DR_W, Data Read from MEM
	// 1: AO_W
	// 2: PC4_W
	assign RegSrc = (op == jalop | ((op == rop) && (func == jalrfunc))) ? 2:
					(calc_r | calc_i_s | calc_i_z | (op == luiop)) | mf? 1:
					0;

	// Extra
	assign extra[1] = 0,
	extra[0] = 0;

	
endmodule

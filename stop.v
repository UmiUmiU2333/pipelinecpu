`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    03:31:07 11/21/2019 
// Design Name: 
// Module Name:    stop 
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
// 读入D级、E级、M级指令，输出暂停信号
// stall = 1有效

module stop(
    input [31:0] IR_D,
    input [31:0] IR_E,
    input [31:0] IR_M,
    output stall
    );
	// 指令集
	// addu, subu, ori, lw, sw, beq, lui, j, jal, jr, nop;
	parameter rop = 6'b000000, lwop = 6'b100011, swop = 6'b101011, beqop = 6'b000100,
	luiop = 6'b001111, oriop = 6'b001101, jalop = 6'b000011, jop=6'b000010,
    sltiop = 6'b001010, sltiuop = 6'b001011,
    xoriop =6'b001110, addiop =6'b001000 , addiuop = 6'b001001, andiop =6'b001100,	
    bneop = 6'b000101, blezop = 6'b000110, bgtzop = 6'b000111, bltzop = 6'b000001, bgezop= 6'b000001; // bltz and bgez have the same op, bgez[rt] == 5'b00001
	
	parameter addufunc = 6'b100001, subufunc = 6'b100011, jrfunc = 6'b001000,nopfunc=6'b000000,

    addfunc = 6'b100000, subfunc = 6'b100010, 
    sllfunc = 6'b000000, srlfunc=6'b000010 ,srafunc =6'b000011 , sllvfunc = 6'b000100, srlvfunc =6'b000110, sravfunc = 6'b000111,
    andfunc = 6'b100100, orfunc = 6'b100101, xorfunc = 6'b100110, norfunc = 6'b100111,
    sltfunc = 6'b101010,  sltufunc = 6'b101011,
	jalrfunc = 6'b001001;

	// Instru Classification
		// Tuse, D_rs_0： D级指令在0个cycle后需要使用rs寄存器

	wire calc_i_D; // calc_i_D
	wire calc_r_D; // clac_r
	wire typeb_D;
	wire store_D;
	wire load_D;
	wire mt_D, mf_D;
	wire mcalc_D;
	wire [2:0] extra_D;
    instru_classification stop_class_D(
        IR_D,
        calc_r_D,
        calc_i_D,
        typeb_D,
		store_D,
		load_D,
		mt_D,
		mf_D,
		mcalc_D,
		extra_D
    );
	wire calc_i_E; // calc_i_E
	wire calc_r_E; // clac_r
	wire typeb_E;
	wire store_E;
	wire load_E;
	wire mt_E, mf_E;
	wire mcalc_E;
	wire [2:0] extra_E;
    instru_classification stop_class_E(
        IR_E,
        calc_r_E,
        calc_i_E,
        typeb_E,
		store_E,
		load_E,
		mt_E,
		mf_E,
		mcalc_E,
		extra_E
    );
	wire calc_i_M; // calc_i_M
	wire calc_r_M; // clac_r
	wire typeb_M;
	wire store_M;
	wire load_M;
	wire mt_M, mf_M;
	wire mcalc_M;
	wire [2:0] extra_M;
    instru_classification stop_class_M(
        IR_M,
        calc_r_M,
        calc_i_M,
        typeb_M,
		store_M,
		load_M,
		mt_M,
		mf_M,
		mcalc_M,
		extra_M
    );


	wire D_rs_0, D_rt_0, D_rs_1, D_rt_1, D_rs_2, D_rt_2;
	assign D_rs_0 = typeb_D |
				calc_i_D |
				((IR_D[`op] == rop) && ((IR_D[`func] == jrfunc) | (IR_D[`func] == jalrfunc))) ,  // About Need, jalr behave the same to jr 

	D_rt_0 = typeb_D,
	D_rs_1 = calc_r_D |
			load_D | 
			store_D |
			mt_D |
			mcalc_D,
	D_rt_1 = calc_r_D | mcalc_D,

	D_rs_2 = 0,
	D_rt_2 = store_D;
		// Tnew ori,addu,subu,lw
		// Tnew E_rt_1表示E级指令写rt寄存器的值能够在1个cycle后获得
		// 不用考虑 E_rt_3，因为E级指令2个cycle后W级，一定已经产生了需要更新的值，M_rt_2同理
	wire E_rt_1, E_rd_1, E_rt_2, E_rd_2;
	wire M_rt_1, M_rd_1;
	// All E_rt_2, E_rd_2 should appear in M_rt_1, M_rd_1
	assign E_rt_1 = calc_i_E,
	E_rd_1 = calc_r_E | mf_E ,      // jalr can get operation in D
	E_rt_2 = load_E, // After Mem Get Data  
	E_rd_2 = 0,
	M_rt_1 = load_M,  // After Mem Get Data  
	M_rd_1 = 0;

	// 产生暂停信号
	// D_rs_0 means D_Instru Need Data Now, E_rt_1 | E_rt_2 means E_Instru supply rt in future.
	// 
	assign stall = (D_rs_0 && (E_rt_1 | E_rt_2) && (IR_D[`rs]==IR_E[`rt]) && (IR_D[`rs]!=0)) |  // 0Register Special  
	(D_rs_0 && (E_rd_1 | E_rd_2) && (IR_D[`rs]==IR_E[`rd]) && (IR_D[`rs]!=0)) |
	(D_rs_0 && M_rt_1 && (IR_D[`rs]==IR_M[`rt]) && (IR_D[`rs]!=0)) |
	(D_rs_0 && M_rd_1 && (IR_D[`rs]==IR_M[`rd]) && (IR_D[`rs]!=0)) |
	(D_rt_0 && (E_rt_1 | E_rt_2) && (IR_D[`rt]==IR_E[`rt]) && (IR_D[`rt]!=0)) | 
	(D_rt_0 && (E_rd_1 | E_rd_2) && (IR_D[`rt]==IR_E[`rd]) && (IR_D[`rt]!=0)) |
	(D_rt_0 && M_rt_1 && (IR_D[`rt]==IR_M[`rt]) && (IR_D[`rt]!=0)) |
	(D_rt_0 && M_rd_1 && (IR_D[`rt]==IR_M[`rd]) && (IR_D[`rt]!=0)) |
	(D_rs_1 && E_rt_2 && (IR_D[`rs]==IR_E[`rt]) && (IR_D[`rs]!=0)) |
	(D_rs_1 && E_rd_2 && (IR_D[`rs]==IR_E[`rd]) && (IR_D[`rs]!=0)) |
	(D_rt_1 && E_rt_2 && (IR_D[`rt]==IR_E[`rt]) && (IR_D[`rt]!=0))|
	(D_rt_1 && E_rd_2 && (IR_D[`rt]==IR_E[`rd]) && (IR_D[`rt]!=0))|
	((mul.busy | mul.start) && (mt_D | mf_D | mcalc_D));
	 // rs [25:21], rt [20,16], rd[15:11];

endmodule

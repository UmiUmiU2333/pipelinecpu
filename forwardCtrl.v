`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:48:16 11/25/2019 
// Design Name: 
// Module Name:    forwardCtrl 
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

module forwardCtrl(
    input [31:0] IR_D,
    input [31:0] IR_E,
    input [31:0] IR_M,
    input [31:0] IR_W,
    output [2:0] ForwardRSD,
    output [2:0] ForwardRTD,
    output [2:0] ForwardRSE,
    output [2:0] ForwardRTE,
    input [2:0] ForwardRTM
    );
	// 指令集
	// addu, subu, ori, lw, sw, beq, lui, j, jal, jr, nop;
	parameter rop = 6'b000000, lwop = 6'b100011, swop = 6'b101011, beqop = 6'b000100,
	luiop = 6'b001111, oriop = 6'b001101, jalop = 6'b000011, jop=6'b000010,
    sltiop = 6'b001010, sltiuop = 6'b001011,
    xoriop = 6'b001110, addiop =6'b001000 , addiuop = 6'b001001, andiop =6'b001100;
    

	parameter addufunc = 6'b100001, subufunc = 6'b100011, jrfunc = 6'b001000,nopfunc=6'b000000,

    addfunc = 6'b100000, subfunc = 6'b100010, 
    sllfunc = 6'b000000, srlfunc=6'b000010 ,srafunc =6'b000011 , sllvfunc = 6'b000100, srlvfunc =6'b000110, sravfunc = 6'b000111,
    andfunc = 6'b100100, orfunc = 6'b100101, xorfunc = 6'b100110, norfunc = 6'b100111,
    sltfunc = 6'b101010,  sltufunc = 6'b101011,
    jalrfunc = 6'b001001;
    // Need and Supply Performance of every Instruction 
    // Get Need info from Tabel Tuse, Get Supply info from Table Tnew(forward)

        // D_need_rs means IR_D need GRF[rs]
    wire D_need_rs, D_need_rt, E_need_rs, E_need_rt, M_need_rs, M_need_rt;
    // assign D_need_rs = (IR_D[`op] == oriop) | (IR_D[`op] == beqop) |
    //                 ((IR_D[`op] == rop) && (IR_D[`func]==jrfunc)) |
    //                 (IR_D[`op] == oriop) |
    //                 ((IR_E[`op] == rop) && (IR_E[`func]==addufunc)) | 
    //                 ((IR_E[`op] == rop) && (IR_E[`func]==subufunc)) |
    //                 (IR_E[`op] == lwop)|
    //                 (IR_E[`op] == swop),
    // D_need_rt = (IR_D[`op] == beqop) |
    //             ((IR_E[`op] == rop) && (IR_E[`func]==addufunc)) | 
    //             ((IR_E[`op] == rop) && (IR_E[`func]==subufunc)) |   
    //             (IR_E[`op] == swop)
    //             ,
    // E_need_rs =  ((IR_E[`op] == rop) && (IR_E[`func]==addufunc)) | 
    //             ((IR_E[`op] == rop) && (IR_E[`func]==subufunc)) |
    //             (IR_E[`op] == lwop)|
    //             (IR_E[`op] == swop),
    // E_need_rt = ((IR_E[`op] == rop) && (IR_E[`func]==addufunc)) | 
    //             ((IR_E[`op] == rop) && (IR_E[`func]==subufunc)),
    // M_need_rs = 0,  // Stage M does not need GRF[rs]
    // M_need_rt = (IR_M[`op] == swop);
    assign  D_need_rs = 1,
    D_need_rt = 1,
    E_need_rs = 1,
    E_need_rt = 1,
    M_need_rs = 1,
    M_need_rt = 1;

    // Classification
    wire calc_i_M, calc_i_W;
    wire calc_R_M, calc_R_W;
    wire typeb_M, typeb_W;
    wire store_M, store_W;
    wire load_M, load_W;
    wire mt_M, mt_W;
    wire mf_M, mf_W;
    wire mcalc_M, mcalc_W;
    wire [2:0] extra_M, extra_W;
    instru_classification class_M(
        IR_M,
        calc_R_M,
        calc_i_M,
        typeb_M,
        store_M,
        load_M,
        mt_M,
        mf_M,
        mcalc_M,
        extra_M
    );

    instru_classification class_W(
        IR_W,
        calc_R_W,
        calc_i_W,
        typeb_W,
        store_W,
        load_W,
        mt_W,
        mf_W,
        mcalc_W,
        extra_W
    );

    wire jalr_E = ((IR_E[`op] == rop) && (IR_E[`func] == jalrfunc));
    wire jalr_M = ((IR_M[`op] == rop) && (IR_M[`func] == jalrfunc));
    wire jalr_W = ((IR_W[`op] == rop) && (IR_W[`func] == jalrfunc));
        // E_supply_rt means Instruction in Stage E will change value of IR_E[rt]
        // Mark E,M,W
    wire E_supply_rt, E_supply_rd, E_supply_31,
    M_supply_rt, M_supply_rd, M_supply_31,
    W_supply_rt, W_supply_rd, W_supply_31;

    assign E_supply_rt = (IR_E[`op]==luiop),
    E_supply_rd = jalr_E,
    E_supply_31 = (IR_E[`op]==jalop),
    M_supply_rt = calc_i_M|
                (IR_M[`op] == luiop),
    M_supply_rd = calc_R_M | jalr_M | mf_M,
    M_supply_31 = (IR_M[`op] == jalop),
    W_supply_rt = calc_i_W |
                load_W |
                (IR_W[`op] == luiop), 
    W_supply_rd = calc_R_W | jalr_W | mf_W,
    W_supply_31 = (IR_W[`op] == jalop);

        // Forward_D is controled by IR E,M,W
        // Port of ForwardRSD and ForwardRTD: RD1_D, EXT_EX, PC4_EX, AO_MEM, PC4_MEM, Mux_GRF_WD_Out, PC4_WB, 0
    assign ForwardRSD = (D_need_rs && E_supply_rt && (IR_D[`rs] == IR_E[`rt]) && (IR_D[`rs] != 0))?1: // 0Register Special 
                        (D_need_rs && E_supply_rd && (IR_D[`rs] == IR_E[`rd]) && (IR_D[`rs] != 0) && jalr_E)?2:   // jalr     
                        (D_need_rs && E_supply_rd && (IR_D[`rs] == IR_E[`rd]) && (IR_D[`rs] != 0))?0:
                        (D_need_rs && E_supply_31 && (IR_D[`rs] == 5'd31) && (IR_D[`rs] != 0))?2:   // jal delay slot Not forward
                        (D_need_rs && M_supply_rt && (IR_D[`rs] == IR_M[`rt])&& (IR_D[`rs] != 0))?3:
                        (D_need_rs && M_supply_rd && (IR_D[`rs] == IR_M[`rd])&& (IR_D[`rs] != 0) && jalr_M)?4:
                        (D_need_rs && M_supply_rd && (IR_D[`rs] == IR_M[`rd])&& (IR_D[`rs] != 0))?3:
                        (D_need_rs && M_supply_31 && (IR_D[`rs] == 5'd31)&& (IR_D[`rs] != 0))?4:
                        (D_need_rs && W_supply_rt && (IR_D[`rs] == IR_W[`rt])&& (IR_D[`rs] != 0))?5:
                        (D_need_rs && W_supply_rd && (IR_D[`rs] == IR_W[`rd])&& (IR_D[`rs] != 0) && jalr_W)?6:
                        (D_need_rs && W_supply_rd && (IR_D[`rs] == IR_W[`rd])&& (IR_D[`rs] != 0))?5:
                        (D_need_rs && W_supply_31 && (IR_D[`rs] == 5'd31)&& (IR_D[`rs] != 0))?6:
                        0;

    assign ForwardRTD = (D_need_rt && E_supply_rt && (IR_D[`rt] == IR_E[`rt])&& (IR_D[`rt] != 0))?1:
                        (D_need_rt && E_supply_rd && (IR_D[`rt] == IR_E[`rd])&& (IR_D[`rt] != 0) && jalr_E)?2:
                        (D_need_rt && E_supply_rd && (IR_D[`rt] == IR_E[`rd])&& (IR_D[`rt] != 0))?0:
                        (D_need_rt && E_supply_31 && (IR_D[`rt] == 5'd31) &&(IR_D[`rt] != 0))?2:
                        (D_need_rt && M_supply_rt && (IR_D[`rt] == IR_M[`rt]) &&(IR_D[`rt] != 0))?3:
                        (D_need_rt && M_supply_rd && (IR_D[`rt] == IR_M[`rd]) &&(IR_D[`rt] != 0) && jalr_M)?4:
                        (D_need_rt && M_supply_rd && (IR_D[`rt] == IR_M[`rd]) &&(IR_D[`rt] != 0))?3:
                        (D_need_rt && M_supply_31 && (IR_D[`rt] == 5'd31) &&(IR_D[`rt] != 0))?4:
                        (D_need_rt && W_supply_rt && (IR_D[`rt] == IR_W[`rt]) &&(IR_D[`rt] != 0))?5:
                        (D_need_rt && W_supply_rd && (IR_D[`rt] == IR_W[`rd]) &&(IR_D[`rt] != 0) && jalr_W)?6:
                        (D_need_rt && W_supply_rd && (IR_D[`rt] == IR_W[`rd]) &&(IR_D[`rt] != 0))?5:
                        (D_need_rt && W_supply_31 && (IR_D[`rt] == 5'd31) &&(IR_D[`rt] != 0))?6:
                        0;
            // Forward_E is controled by IR M,W
            // Port of ForwardRSE and ForwardRTE: RD2_EX, AO_MEM, PC4_MEM, Mux_GRF_WD_Out, PC4_WB,0,0,0,
    assign ForwardRSE = (E_need_rs && M_supply_rt && (IR_E[`rs] == IR_M[`rt]) &&(IR_E[`rs] != 0))?1:
                        (E_need_rs && M_supply_rd && (IR_E[`rs] == IR_M[`rd]) &&(IR_E[`rs] != 0) && jalr_M)?2:
                        (E_need_rs && M_supply_rd && (IR_E[`rs] == IR_M[`rd]) &&(IR_E[`rs] != 0))?1:
                        (E_need_rs && M_supply_31 && (IR_E[`rs] == 5'd31) &&(IR_E[`rs] != 0))?2:
                        (E_need_rs && W_supply_rt && (IR_E[`rs] == IR_W[`rt]) &&(IR_E[`rs] != 0))?3:
                        (E_need_rs && W_supply_rd && (IR_E[`rs] == IR_W[`rd]) &&(IR_E[`rs] != 0) && jalr_W)?4:
                        (E_need_rs && W_supply_rd && (IR_E[`rs] == IR_W[`rd]) &&(IR_E[`rs] != 0))?3:
                        (E_need_rs && W_supply_31 && (IR_E[`rs] == 5'd31) &&(IR_E[`rs] != 0))?4:
                        0;
    assign ForwardRTE = (E_need_rt && M_supply_rt && (IR_E[`rt] == IR_M[`rt]) &&(IR_E[`rt] != 0))?1:
                        (E_need_rt && M_supply_rd && (IR_E[`rt] == IR_M[`rd]) &&(IR_E[`rt] != 0) && jalr_M)?2:
                        (E_need_rt && M_supply_rd && (IR_E[`rt] == IR_M[`rd]) &&(IR_E[`rt] != 0))?1:
                        (E_need_rt && M_supply_31 && (IR_E[`rt] == 5'd31) &&(IR_E[`rt] != 0) )?2:
                        (E_need_rt && W_supply_rt && (IR_E[`rt] == IR_W[`rt]) &&(IR_E[`rt] != 0))?3:
                        (E_need_rt && W_supply_rd && (IR_E[`rt] == IR_W[`rd]) &&(IR_E[`rt] != 0) && jalr_W)?4:
                        (E_need_rt && W_supply_rd && (IR_E[`rt] == IR_W[`rd]) &&(IR_E[`rt] != 0))?3:
                        (E_need_rt && W_supply_31 && (IR_E[`rt] == 5'd31) &&(IR_E[`rt] != 0))?4:
                        0;
            // Forward_D is controled by W
            // Port of ForwardRTM : RD2_MEM, Mux_GRF_WD_Out, PC4_WB,0,0,0,0,0,
    assign ForwardRTM = (M_need_rt && W_supply_rt && (IR_M[`rt] == IR_W[`rt]) &&(IR_M[`rt] != 0))?1:
                        (M_need_rt && W_supply_rd && (IR_M[`rt] == IR_W[`rd]) &&(IR_M[`rt] != 0) && jalr_W) ?2:
                        (M_need_rt && W_supply_rd && (IR_M[`rt] == IR_W[`rd]) &&(IR_M[`rt] != 0))?1:
                        (M_need_rt && W_supply_31 && (IR_M[`rt] == 5'd31) &&(IR_M[`rt] != 0) )?2:
                        0;
endmodule

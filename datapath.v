`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:41:49 11/20/2019 
// Design Name: 
// Module Name:    datapath 
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
// ʵ��������ˮ��������ʵ��������ˮ���Ĵ���
// ���������ˮ�����ĸ���ˮ���Ĵ���

// ��λ�źŸ�λ4����ˮ���Ĵ�����pc��dm

// �ֲ�ʽ���룬ÿ��������InputΪ��ǰ��ˮ��ָ����CtrlWidthλ�Ĺ��п����ź�
// ��ExtraWidth�ı��ÿ����ź�

	 /*PCSrc_D = ctrl[20:19];
	 extSel = ctrl[18:17];
	 npcSel = ctrl[16:15];
	 ALUASrc = ctrl[14:13];
	 ALUBSrc  = ctrl[12:11];
	 ALUOp = ctrl[10:7]
	 DM_WE_M = ctrl[6];
	 DM_RE_M = ctrl[5];
	 RF_WE_W = ctrl[4];
	 RegDst = ctrl[3:2];
	 RegSrc = ctr;[1:0];
	 */
	
// Change Control Signal: Change datapath.CtrlWidth, Change datapath_Macro, Change Control, ALU
`define PCSrc_D 21:20
`define extSel 19:18
`define npcSel 17:16
`define ALUASrc 15:14
`define ALUBSrc 13:12
`define ALUOp 11:7
`define DM_WE_M 6
`define DM_RE_M 5
`define RF_WE_W 4
`define RegDst 3:2
`define RegSrc 1:0

`define op 31:26
`define rs 25:21
`define rt 20:16
`define rd 15:11
`define func 5:0

module datapath(
	input clk,
	input reset
    );
	 
	 // Wire Forward
	wire [31:0] RD1_D_F, RD2_D_F, RD1_E_F, RD2_E_F, RD2_MEM_F;
	 // 冻结PC，冻结IF_ID，清零ID_EX
	 wire mystop;
	 wire PCEn;
	 assign PCEn = ~mystop;
	 wire IR_D_En = ~mystop;
	 wire IR_E_clr = mystop;

	 parameter CtrlWidth = 22;
	 parameter ExtraWidth = 3;
	 
	 // Mux����ź�
	wire [31:0] Mux_PCSrc_Out, Mux_ALU_A_Out, Mux_ALU_B_Out, Mux_GRF_WD_Out;
	wire [4:0] Mux_GRF_WA_Out;
	 // 
	wire [31:0] IR_F, PC4_F;

	// F Stage
	
			// ifuPCNext_I_F: ��һ��PCֵ
			// ifuPCNow_O_F����ǰPCֵ
	wire [31:0] ifuPCNow_O_F;
	

	IFU ifu(
		.Clk(clk),
		.reset(reset),
		.en(PCEn),
		.PCNext(Mux_PCSrc_Out),
		.Instr(IR_F),
		.PCNow(ifuPCNow_O_F)
	);
			// ����PC+4 
	Adder adder(
		.A(ifuPCNow_O_F),
		.B(32'd4),
		.Out(PC4_F)
	);
			// ������һ����ˮ
			
	// regIFID
	wire [31:0] IR_D, PC4_D;
	regIFID myRegIFID(
	 .CLK(clk),
	 .reset(reset),
	 .en(IR_D_En),
    .IR_F(IR_F),
    .PC4_F(PC4_F),
    .IR_D(IR_D),
    .PC4_D(PC4_D)
	);

	// D Stage
	wire [31:0] RD1_D, RD2_D, EXT_D;
				// D����
			wire [CtrlWidth-1 : 0] ctrl_D;
			wire [ExtraWidth-1 : 0] extra_D;
			control control_D(
			.Instru(IR_D),
			.ctrl(ctrl_D),
			.extra(extra_D)
			);
			// ָ������
			wire [4:0] IR_D_rs, IR_D_rt;
			assign  IR_D_rs = IR_D[25:21];
			assign IR_D_rt = IR_D[20:16];
			
			wire[15:0] IR_D_imm16 = IR_D[15:0];
			wire[25:0] IR_D_imm26 = IR_D[25:0];
			
			wire [1:0] PCSrc_D = ctrl_D[`PCSrc_D];
			wire [1:0] extSel = ctrl_D[`extSel];
			wire [1:0] npcSel = ctrl_D[`npcSel];
			// �������
			
			// Condition of typeb Instru 
			wire cond_beq, cond_bne, cond_blez, cond_bgtz, cond_bltz, cond_bgez;
			assign cond_beq = (RD1_D_F == RD2_D_F),
			cond_bne = RD1_D_F != RD2_D_F,
			cond_blez =  $signed($signed(RD1_D_F) <= 0),
			cond_bgtz =  $signed($signed(RD1_D_F) > 0),
			cond_bltz =  $signed($signed(RD1_D_F) < 0),
			cond_bgez =  $signed($signed(RD1_D_F) >= 0);
			
			// compute next pc 
			wire [31:0] npc_D;
			NPC npc(
			PC4_D,
			IR_D_imm26,
			npcSel,
			npc_D
			);
			
			EXT ext(
			IR_D_imm16,
			extSel,
			EXT_D
			);
			
			// mux


			
			GRF grf(
			clk,
			reset,
			RF_WE_W,
			IR_D_rs,
			IR_D_rt,
			Mux_GRF_WA_Out,
			Mux_GRF_WD_Out,
			RD1_D,
			RD2_D
			);
			// ������һ����ˮ
			// un EXT_D
	// regIDEX
	parameter jalrfunc = 6'b001001;
	wire [31:0] IR_EX, PC4_EX, RD1_EX, RD2_EX, EXT_EX;
	wire [31:0] PC4_D_Mux;
	assign PC4_D_Mux = (IR_D[31:26] == 6'b000011 | ((IR_D[`op] == 0) && (IR_D[`func] == jalrfunc)))? PC4_D + 32'd4: PC4_D;  //jalop and jalrfunc, both pc4_D + 4

	regIDEX myRegIDEX(
	 .CLK(clk),
	 .reset(reset),
	 .clr(IR_E_clr), // ��ͣ����ź�
    .IR_D(IR_D),
    .PC4_D(PC4_D_Mux),    // jal PC4_D + 4
    .RD1_D(RD1_D_F),
    .RD2_D(RD2_D_F),
    .EXT_D(EXT_D),
    .IR_EX(IR_EX),
    .PC4_EX(PC4_EX),
    .RD1_EX(RD1_EX),
    .RD2_EX(RD2_EX),
    .EXT_EX(EXT_EX)
	);

	// Ex��
					// Ex
			wire [CtrlWidth-1 : 0] ctrl_EX;
			wire [ExtraWidth-1 : 0] extra_EX;
			control control_EX(
			.Instru(IR_EX),
			.ctrl(ctrl_EX),
			.extra(extra_EX)
			);
			

			wire [1:0] ALUASrc = ctrl_EX[`ALUASrc];
			
			wire [1:0] ALUBSrc = ctrl_EX[`ALUBSrc];
			wire [4:0] aluOp = ctrl_EX[`ALUOp] ;
			// alu
			wire [31:0] aluOut;
			wire aluZero;
			ALU alu(
			Mux_ALU_A_Out,
			Mux_ALU_B_Out, 
			aluOp,
			aluOut,
			aluZero
			);

			// Mul
			wire busy;
			wire [31:0] mul_out_E;
			Mul mul(
				clk, 
				reset,
				RD1_E_F,
				RD2_E_F,
				busy,
				mul_out_E
			);
			// 

	// regEXMEM
	wire[31:0] IR_MEM, PC4_MEM, RD2_MEM, AO_MEM;
	regEXMEM myRegEXMEM(
	    .CLK(clk),
	.reset(reset),
    .IR_EX(IR_EX),
    .PC4_EX(PC4_EX),
    .RD2_EX(RD2_E_F),
    .AO_EX( mul.mf? mul_out_E:aluOut), // move from mul or aluout
    .IR_MEM(IR_MEM),
    .PC4_MEM(PC4_MEM),
    .RD2_MEM(RD2_MEM),
    .AO_MEM(AO_MEM)
	
	);
	// MEM��
	
					// MEM����
			wire [CtrlWidth-1 : 0] ctrl_MEM;
			wire [ExtraWidth-1 : 0] extra_MEM;
			control control_MEM(
			.Instru(IR_MEM),
			.ctrl(ctrl_MEM),
			.extra(extra_MEM)
			);
			// �����ź�
			wire DM_RE, DM_WE;
			assign DM_RE = ctrl_MEM[`DM_RE_M];
			assign DM_WE = ctrl_MEM[`DM_WE_M];
			// �������
			wire [31:0] dmOut;
			DM dm(
				clk,
				reset,
				AO_MEM,
				RD2_MEM_F,
				DM_RE,
				DM_WE,
				dmOut
			);
			
			// ������һ����ˮ
	// regMEMWB
	wire [31:0] IR_WB, PC4_WB, AO_WB, DR_WB;
	regMEMWB myRegMEMWB(
		.CLK(clk),
	.reset(reset),
    .IR_MEM(IR_MEM),
    .PC4_MEM(PC4_MEM),
    .AO_MEM(AO_MEM),
    .DR_MEM(dmOut),
    .IR_WB(IR_WB),
    .PC4_WB(PC4_WB),
    .AO_WB(AO_WB),
    .DR_WB(DR_WB)
	);
	// WB��
						// WB����
			wire [CtrlWidth-1 : 0] ctrl_WB;
			wire [ExtraWidth-1 : 0] extra_WB;
			control control_WB(
			.Instru(IR_WB),
			.ctrl(ctrl_WB),
			.extra(extra_WB)
			);
			
			wire [4:0] IR_WB_Rd = IR_WB[15:11];
			wire [4:0] IR_WB_Rt = IR_WB[20:16];
			wire [1:0] RegDst = ctrl_WB[`RegDst];
			wire [1:0] RegSrc = ctrl_WB[`RegSrc];
			assign RF_WE_W = ctrl_WB[`RF_WE_W];
	
	


// Mux
			// aluAMux
			Mux4 #(
				.MuxWidth(32)
			)
			 Mux_ALU_A (
			 RD1_E_F,
			 32'b0,
			 0,
			 0,
			 ALUASrc,
			 Mux_ALU_A_Out
			);
			// aluBMux
			Mux4 #(
				.MuxWidth(32)
			)
			 Mux_ALU_B (
			 EXT_EX,
			 RD2_E_F,
			 0,
			 0,
			 ALUBSrc,
			 Mux_ALU_B_Out
			);
	// PCSrc 
			// judge if jump by typebָ condition  
			parameter beqop = 6'b000100,bneop = 6'b000101, blezop = 6'b000110, bgtzop = 6'b000111, bltzop = 6'b000001, bgezop= 6'b000001;

			wire bjump;
			assign bjump = (cond_beq && (IR_D[`op] == beqop)) | 
							(cond_bne && (IR_D[`op] == bneop)) |
							(cond_blez && (IR_D[`op] == blezop)) |
							(cond_bgtz && (IR_D[`op] == bgtzop)) |
							(cond_bltz && (IR_D[`op] == bltzop) && IR_D[`rt] == 0) |
							(cond_bgez && (IR_D[`op] == bgezop) && IR_D[`rt]==5'b00001);
							  // bgezop && bgez[`rt]==5'd1
							
			wire [31:0] bnpc_D;
			assign bnpc_D = bjump ? npc_D:(PC4_D+32'd4); // if not beq jump, PC4_D+31'd4
				Mux4 #(
				.MuxWidth(32)
			)
			 Mux_PCSrc (
			 PC4_F,
			 npc_D,
			 RD1_D_F,
			 bnpc_D,  // b��ָ������
			 PCSrc_D,  // D������Ŀ����ź�
			 Mux_PCSrc_Out
			);
		// Mux_GRF_WA 
			Mux4 #(
				.MuxWidth(5)
			)
			Mux_GRF_WA(
				IR_WB_Rt,
				IR_WB_Rd,
				5'd31,
				5'b0,
				RegDst,
				Mux_GRF_WA_Out
			);
			// Mux_GRF_WD
			Mux4 #(
				.MuxWidth(32)
			)
			Mux_GRF_WD(
				DR_WB,
				AO_WB,
				PC4_WB,  // delay slot
				0,
				RegSrc,
				Mux_GRF_WD_Out
			);
			
	// 
	stop stop(
	 IR_D,
	 IR_EX,
	 IR_MEM,
	 mystop
	 );
	 
	 // Forward
		// Forward Control
		wire [2:0] ForwardRSD, 
		ForwardRTD,
		ForwardRSE,
		ForwardRTE,
		ForwardRTM;
		forwardCtrl myForwardControl(
		IR_D,
		IR_EX,
		IR_MEM,
		IR_WB,
		ForwardRSD, 
		ForwardRTD,
		ForwardRSE,
		ForwardRTE,
		ForwardRTM
		);



	 	// Forward Mux

	 		Mux8 #(
				 .MuxWidth(32)
			 )
			MFRSD(
				RD1_D,
				EXT_EX,
				PC4_EX,
				AO_MEM,
				PC4_MEM,
				Mux_GRF_WD_Out,
				PC4_WB,
				0,
				ForwardRSD,
				RD1_D_F
			 );

	 		Mux8 #(
				 .MuxWidth(32)
			 )
			MFRTD(
				RD2_D,
				EXT_EX, 
				PC4_EX,
				AO_MEM,
				PC4_MEM,
				Mux_GRF_WD_Out,
				PC4_WB,
				0,
				ForwardRTD,
				RD2_D_F
			 );

	 		Mux8 #(
				 .MuxWidth(32)
			 )
			MFRSE(
				RD1_EX,
				AO_MEM,
				PC4_MEM,
				Mux_GRF_WD_Out,
				PC4_WB,
				0,0,0,
				ForwardRSE,
				RD1_E_F
			);

	 		Mux8 #(
				 .MuxWidth(32)
			 )
			MFRTE(
				RD2_EX,
				AO_MEM,
				PC4_MEM,
				Mux_GRF_WD_Out,
				PC4_WB,
				0,0,0,
				ForwardRTE,
				RD2_E_F			
			);

	 		Mux8 #(
				 .MuxWidth(32)
			 )
			MFRTM(
				RD2_MEM,
				Mux_GRF_WD_Out,
				PC4_WB,
				0,0,0,0,0,
				ForwardRTM,
				RD2_MEM_F
			);





















endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:32:51 11/09/2019 
// Design Name: 
// Module Name:    ALU 
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
`define s 10:6
module ALU(
    input [31:0] A,
    input [31:0] B,
    input [4:0] ALUCtrl,
    output [31:0] Result,
    output Zero
    );

	assign Result = (ALUCtrl == 0)? A + B : 
							(ALUCtrl == 1)? A - B:
							(ALUCtrl == 2)? A & B: 
							(ALUCtrl == 3)? A | B:
                            (ALUCtrl == 4)? A ^ B:
                            (ALUCtrl == 5)? ($signed($signed(A)<$signed(B))?32'd1:0):
                            (ALUCtrl == 6)? ($unsigned(A<B)?32'd1:0): // unsigned compare
                            (ALUCtrl == 7)? A + B: // $signed($signed(A) + $signed(B))
                            (ALUCtrl == 8)? A - B: //  $signed($signed(A) - $signed(B))
                            (ALUCtrl == 9)? B << A[4:0]:  // A: rs. B: rt
                            (ALUCtrl == 10)? B >> A[4:0]: 
                            (ALUCtrl == 11)? $signed($signed(B) >>> A[4:0]):  // SRAV
                            (ALUCtrl == 12)? B << datapath.IR_EX[`s]: // SLL
                            (ALUCtrl == 13)? B >> datapath.IR_EX[`s]:
                            (ALUCtrl == 14)? $signed($signed(B) >>> datapath.IR_EX[`s]): // *** B must be Signed when Shift Right  Arithmetic
                            (ALUCtrl == 15)? ~(A|B):
                            (ALUCtrl == 16)? ($signed($signed(A)<$signed(B))?32'd1:0) :
                            (ALUCtrl == 17)? ((A<B)?32'd1:0):
                            0;
	assign Zero = (Result == 0)? 1 : 0;
endmodule

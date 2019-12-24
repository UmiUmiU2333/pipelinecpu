`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:31:54 11/09/2019 
// Design Name: 
// Module Name:    GRF 
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
module GRF(
    input Clk,
	 input reset,
    input WE,
    input [4:0] RA1,
    input [4:0] RA2,
    input [4:0] WA,
    input [31:0] WD,
    output [31:0] RD1,
    output [31:0] RD2
    );
	parameter jalop = 6'b000011, jalrfunc = 6'b001001;
	reg [31:0] grf[31:0];
	
	integer i;
	initial begin: c
		for(i=0; i<1024; i=i+1)begin
			grf[i] = 0;
		end
	end

	initial begin
		grf[28] = 32'h00001800;
		grf[29] = 32'h00002ffc;
	end	
	
	assign RD1 = grf[RA1];
	assign RD2 = grf[RA2];
	
	// jalop and jalrfunc: -8, else: -4
	wire jal, jalr;
	assign jal = (datapath.IR_WB[31:26] == jalop),
	jalr = ((datapath.IR_WB[31:26] == 0) && (datapath.IR_WB[5:0] == jalrfunc));

	wire [31:0] PC_W ;
	assign PC_W = (jal | jalr) ?datapath.PC4_WB-32'd8: datapath.PC4_WB-4; // jal or jalr

	always @(posedge Clk) begin
		if(reset)begin: a
			integer i;
			for (i=1;i<32;i=i+1)begin
				grf[i] <= 0;
			end
			grf[28] <= 32'h00001800;
			grf[29] <= 32'h00002ffc;
		end else if(WE)begin
			$display("%d@%h: $%d <= %h", $time, PC_W , WA, WD); //��������WB��
			if(WA==0)begin
					grf[WA] <= 0;  // 0�Ĵ���
			end else begin
					grf[WA] <= WD;
			end
		end else begin
			grf[WA] <= grf[WA];
		end
	end

endmodule

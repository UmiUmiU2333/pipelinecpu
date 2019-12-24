`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:33:30 11/09/2019 
// Design Name: 
// Module Name:    DM 
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
module DM(
    input Clk,
	 input reset,
    input [31:0] Addr,
    input [31:0] WD,
    input RE,
    input WE,
    output reg [31:0] RD
    );
	 //RAM
	reg [31:0] DM [4095:0];
	
	//Ƭ
	wire[11:0] wordAddr = Addr[13:2];  // [1:0] decide byte

	integer i;
	// initialization
	initial begin
		for(i=0; i<4095; i=i+1)begin
			DM[i] <= 0;
		end
	end
	
	//
	wire [31:0] Data_old; // Read data using wordAddr
	assign Data_old = DM[wordAddr];
	// read
	wire [31:0] RD_New;
	loadEx loadExtra(
		datapath.IR_MEM,
		Addr,
		Data_old,
		RD_New
	);
	always @(*)begin
		if(RE)begin
			RD = RD_New;
		end else begin
		   RD = 0;
		end
	end
	
	
	// save
		// 
		wire [31:0]WD_new;

		saveEx saveExtra(
			datapath.IR_MEM,
			Addr,
			Data_old,
			WD,
			WD_new
		);

	always @(posedge Clk)begin
		if(reset)begin:dmreset
			integer i;
			for(i=0;i<4095;i=i+1)begin
				DM[i] <= 0;
			end
		end else if (WE)begin
			$display("%d@%h: *%h <= %h", $time, (datapath.PC4_MEM-4), (Addr - Addr%4), WD_new);
			DM[wordAddr] <= WD_new;
		end else begin
			DM[wordAddr] <= DM[wordAddr];
		end
	end

endmodule

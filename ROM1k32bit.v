`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:57:47 11/09/2019 
// Design Name: 
// Module Name:    ROM1k32bit 
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

module ROM1k32bit(
    input [31:0] PCNow,
    input Sel,
    output reg [31:0] D
    );

	// ROM
	reg [31:0] ROM [4095:0]; 
	integer i;
	
	initial begin  
		for (i=0; i<4096; i=i+1)begin
			ROM[i] = 0;
		end
		$readmemh("code.txt", ROM);
		$readmemh("code_handler.txt", ROM, 1120, 2047);
	end
	
	
	

	// func

	always @(*) begin
			if(Sel)begin
				D = ROM[(PCNow - 32'h00003000)/4];					
			end else begin
			D = 0;
			end
	end

endmodule

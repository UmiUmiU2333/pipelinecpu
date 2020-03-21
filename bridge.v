`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:17:19 12/26/2019 
// Design Name: 
// Module Name:    bridge 
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
`DEV1_Exception_Handler_Addr 32'h00004180
`DEV2_Timer0_Addr 32'h00007F0
`DEV3_Timer1_Addr 32'h00007F1
module bridge(
    input [31:0] PrAddr,
    input [31:0] PrWD,
    output [31:0] PrRD,
    output [31:0] DEV_Addr,
    output [31:0] DEV_WD,
    input [31:0] DEV1_Exception_Handler_RD,
    input [31:0] DEV2_Timer0_RD,
    input [31:0] DEV3_Timer1_RD,
    output [2:0] DEV_WE
    );
    assign DEV_Addr = PrAddr;

    wire HitDev1, HitDev2, HitDev3;
    // hit device
    assign HitDev1 = (PrAddr == `DEV1_Exception_Handler_Addr) ;
    assign HitDev2 = (PrAddr == `DEV2_Timer0_Addr) && (PrAddr[3:2]!=3); // Timer has Only 3 Reg
    assign HitDev3 = (PrAddr == `DEV3_Timer1_Addr) && (PrAddr[3:2]!=3);

    // WE of External Device
    assign DEV_WE = HitDev1? 1:
                    HitDev2? 2:
                    HitDev3? 4:
                    0;
    
    // PrRD
    assign PrRD = HitDev1? DEV1_Exception_Handler_RD:
                    HitDev2? DEV2_Timer0_RD:
                    HitDev3? DEV3_Timer1_RD:
                    0xffffffff;
    
    // DEV_WD
    assign DEV_WD = PrWD;


endmodule

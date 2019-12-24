`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:27:42 12/10/2019 
// Design Name: 
// Module Name:    Mul 
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
// mul, div, mf, mt
`define op 31:26
`define rs 25:21
`define rt 20:16
`define rd 15:11
`define func 5:0

module Mul(
    input clk,
    input reset,
    input [31:0] RD1,
    input [31:0] RD2,
    output reg busy,
    output reg [31:0] out
    );
    // Ctrl Inside
    wire [5:0] op, func;
    assign op = datapath.IR_EX[`op],
    func = datapath.IR_EX[`func];

    parameter rop = 6'b000000;
    parameter mfhifunc = 6'b010000, mflofunc=6'b010010, mthifunc = 6'b010001, mtlofunc = 6'b010011,
    multfunc = 6'b011000, multufunc = 6'b011001, divfunc = 6'b011010, divufunc = 6'b011011,
    maddop = 6'b011100;

    wire mt, mf, mthi, mtlo, mfhi, mflo;
    assign mt = (op == rop && (func == mthifunc | func == mtlofunc)),
    mf = (op == rop && (func == mfhifunc | func == mflofunc)),
    mthi = (op == rop && (func == mthifunc )),
    mtlo = (op == rop && (func == mtlofunc )),
    mfhi = (op == rop && (func == mfhifunc )),
    mflo = (op == rop && (func == mflofunc ));

    // Add type mcalc instru need to renew signal start 
    wire start;
    assign start = (op == rop && (func == multfunc | func == multufunc | func== divfunc | func== divufunc)) | 
                    (op == maddop);

    wire mult, multu, div, divu, madd;
    assign mult = (op == rop && (func == multfunc)),
    multu = (op == rop && (func == multufunc)),
    div = (op == rop && (func == divfunc)),
    divu = (op == rop && (func == divufunc)),
    madd = (op == maddop);

    // Reg
    reg [31:0] hi, lo;
    // Save result
    reg [63:0] result;

    // cType
    reg [31:0] counter;
    reg [31:0] Delay;

    // 5: mul 5cycle
    // 10: div 10cycle
    initial begin
        hi = 0;
        lo = 0;
        busy = 0;
        result = 0;
        Delay = 0;
        counter = 0;
        out = 0;
    end

    // Combination
    always @(*)begin
        // Read from hi,lo
        if (mfhi) begin
            out = hi;
        end else if (mflo) begin
            out = lo;
        end else begin
            out = out;
        end
    end
    // Write to hi, lo,  
    always @(posedge clk) begin
        if (reset) begin
        // Pay attention!! set All reg to 0 
            hi <= 0;
            lo <= 0;
            busy <= 0;
            out <= 0;
            result <= 0;
            counter <= 0;
            Delay <= 0;
        end else begin
        // NOT RESET   
            // when start, save to result reg, and write to hi,lo when negedge busy
            if (mthi) begin
                hi <= RD1;
            end else if (mtlo) begin
                lo <= RD1;
            end 

            if (start) begin
                // Add Instru, 1.set delay 2.add compute 
                // Compute and save to result reg. After busy period, save to hi
                if(mult)begin
                    result <= $signed(RD1) * $signed(RD2);
                end else if (multu) begin
                    result <=  RD1 * RD2;
                end else if (div)begin
                    if(RD2 == 0)begin
                        result <= {hi, lo};
                    end else begin
                        result[31:0] <=  $signed($signed(RD1) / $signed(RD2));
                        result[63:32] <=  $signed($signed(RD1) % $signed(RD2)); 
                    end                  
                end else if (divu) begin
                    if(RD2 == 0)begin
                        result <= {hi, lo};
                    end else begin 
                        result[31:0] <=  RD1 / RD2;
                        result[63:32] <=  RD1 % RD2;  
                    end                  
                end else if (madd) begin
                    result <= $signed({hi,lo}) + $signed(RD1) * $signed(RD2);
                end

                busy <= 1;
                counter <= counter +1;

                // Set delay
                if(mult | multu | madd)begin
                    Delay <= 5;
                end else if (div | divu)begin
                    Delay <= 10;
                end
            end 

            if (busy) begin
                if (counter != Delay)begin
                    counter <= counter + 1;
                end else begin
                    // Compute End, set busy = 0, save to hi,lo
                    busy <= 0;
                    Delay <= 0;
                    counter <= 0;// Write to hi,lo
                    hi <= result[63:32];
                    lo <= result[31:0];
                end
            end
        end
    end 

    



endmodule

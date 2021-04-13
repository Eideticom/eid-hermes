`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/17/2020 01:16:36 PM
// Design Name: 
// Module Name: ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "exception.svh"

import ALU_exception::*;
import global_exception::*;

module ALU(
    input [3:0] ALUControl,
    input is32Bit,
    input [63:0] operandA,
    input [63:0] operandB,
    output reg [63:0] ALUResult,
    output [1:0] arithmeticExc
    );
    wire [31:0] out32;
    wire [3:0] exception32;
    ALU32 alu32(ALUControl, operandA[31:0], operandB[31:0], out32, exception32);
    
    wire [63:0] out64;
    wire [3:0] exception64;
    ALU64 alu64(ALUControl, operandA, operandB, out64, exception64);
    
    assign ALUResult = (is32Bit)? {32'b0, out32}: out64;
    assign arithmeticExc = (is32Bit)? exception32: exception64;    
endmodule

module ALU32(
    input [3:0] ALUControl,
    input [31:0] A,
    input [31:0] B,
    output reg [31:0] ALUResult,
    output [1:0] arithmeticExc
    );
    wire [31:0] add_result;
    Hardware_Adder_32bit adder_(A, B, add_result);
    
    wire [31:0] sub_result;
    Hardware_Subtractor_32bit subtractor(A, B, sub_result);
    
    wire [31:0] mul_result;
    Mult_32bit multiplier(A, B, mul_result);
    
    wire [31:0] div_result;
    Div_32bit divider(A, B, div_result);
    
    wire [31:0] or_result;
    Or_32bit bitwiseOr(A, B, or_result);
    
    wire [31:0] and_result;
    And_32bit bitwiseAnd(A, B, and_result);
    
    wire [31:0] lsh_result;
    Lsh_32bit leftshift(A, B, lsh_result);
    
    wire [31:0] rsh_result;
    Rsh_32bit rightshift(A, B, rsh_result);   
     
    wire [31:0] neg_result;
    Negation_32bit negator(A, neg_result);   
        
    wire [31:0] mod_result;
    Modulus_32bit modulus(A, B, mod_result);   
        
    wire [31:0] xor_result;
    Xor_32bit bitwiseXor(A, B, xor_result);   
        
    wire [31:0] arsh_result;
    Signed_Rsh_32bit arithmeticRightShift(A, B, arsh_result);   
        
    wire [31:0] byteswap_result;
    byteswap32 byteswap(A, B, byteswap_result, ALUControl);
        
    
    always @(*) begin
    case (ALUControl)
      4'h0:
           ALUResult = add_result; // Addition
      4'h1: 
           ALUResult = sub_result; // Subtraction
      4'h2: 
           ALUResult = mul_result; // Multiplication
      4'h3: 
           ALUResult = div_result; // Division
      4'h4: 
           ALUResult = or_result; // Logical OR
      4'h5: 
           ALUResult = and_result; // Logical AND
      4'h6: 
           ALUResult = lsh_result; // Logical shift left
      4'h7: 
           ALUResult = rsh_result; // Logical shift right
      4'h8: 
           ALUResult = neg_result; // Negate
      4'h9: 
           ALUResult = mod_result; // Modulus
      4'ha: 
           ALUResult = xor_result; // XOR
      4'hb: 
           ALUResult = B; // Move // Changed to B
      4'hc: 
           ALUResult = arsh_result; // Arithmetic right shift
      4'hd, 4'he:
           ALUResult = byteswap_result; // Byteswap 
      default: ; // Exception
    endcase
    end
    
    // handle exceptions
    reg [1:0] exc;
    assign arithmeticExc = exc;
    always@(*) begin
        if (ALUControl == 4'h3 || ALUControl == 4'h9) begin // division and modulus
            if (B == 0) exc = DIVISION_BY_ZERO;
        end else if (ALUControl == 4'h6 || ALUControl == 4'h7 || ALUControl == 4'hc) begin //shifts
            if (B < 0 || B > 64) exc = INVALID_SHIFT_IMM;
        end else if (ALUControl == 4'hd || ALUControl == 4'he) begin // byteswaps
            if (B != 16 && B != 32) exc = INVALID_ENDIAN_IMM;
        end else begin
            exc = NO_EXCEPTION;
        end
    end

endmodule

module ALU64(
    input [3:0] ALUControl,
    input [63:0] A,
    input [63:0] B,
    output reg [63:0] ALUResult,
    output [1:0] arithmeticExc
    );
    
    wire [63:0] add_result;
    Hardware_Adder_64bit adder(A, B, add_result);
    
    wire [63:0] sub_result;
    Hardware_Subtractor_64bit subtractor(A, B, sub_result);
    
    wire [63:0] mul_result;
    Mult_64bit multiplier(A, B, mul_result);
    
    wire [63:0] div_result;
    Div_64bit divider(A, B, div_result);
    
    wire [63:0] or_result;
    Or_64bit bitwiseOr(A, B, or_result);
    
    wire [63:0] and_result;
    And_64bit bitwiseAnd(A, B, and_result);
    
    wire [63:0] lsh_result;
    Lsh_64bit leftshift(A, B, lsh_result);
    
    wire [63:0] rsh_result;
    Rsh_64bit rightshift(A, B, rsh_result);   
     
    wire [63:0] neg_result;
    Negation_64bit negator(A, neg_result);   
        
    wire [63:0] mod_result;
    Modulus_64bit modulus(A, B, mod_result);   
        
    wire [63:0] xor_result;
    Xor_64bit bitwiseXor(A, B, xor_result);   
        
    wire [63:0] arsh_result;
    Signed_Rsh_64bit arithmeticRightShift(A, B, arsh_result);   
        
    wire [63:0] byteswap_result;
    byteswap64 byteswap(A, B, byteswap_result, ALUControl);
        
    
    always @(*) begin
    case (ALUControl)
      4'h0:
           ALUResult = add_result; // Addition
      4'h1: 
           ALUResult = sub_result; // Subtraction
      4'h2: 
           ALUResult = mul_result; // Multiplication
      4'h3: 
           ALUResult = div_result; // Division
      4'h4: 
           ALUResult = or_result; // Logical OR
      4'h5: 
           ALUResult = and_result; // Logical AND
      4'h6: 
           ALUResult = lsh_result; // Logical shift left
      4'h7: 
           ALUResult = rsh_result; // Logical shift right
      4'h8: 
           ALUResult = neg_result; // Negate
      4'h9: 
           ALUResult = mod_result; // Modulus
      4'ha: 
           ALUResult = xor_result; // XOR
      4'hb: 
           ALUResult = B; // Move //Changed to B
      4'hc: 
           ALUResult = arsh_result; // Arithmetic right shift
      4'hd, 4'he:
           ALUResult = byteswap_result; // Byteswap 
      default: ; // Exception
    endcase
    end
    
    // handle exceptions
    reg [1:0] exc;
    assign arithmeticExc = exc;
    always@(*) begin
        if (ALUControl == 4'h3 || ALUControl == 4'h9) begin // division and modulus
            if (B == 0) exc = DIVISION_BY_ZERO;
        end else if (ALUControl == 4'h6 || ALUControl == 4'h7 || ALUControl == 4'hc) begin //shifts
            if (B < 0 || B > 64) exc = INVALID_SHIFT_IMM;
        end else if (ALUControl == 4'hd || ALUControl == 4'he) begin // byteswaps
            if (B != 16 && B != 32 && B != 64) exc = INVALID_ENDIAN_IMM;
        end else begin
            exc = NO_EXCEPTION;
        end
    end
endmodule

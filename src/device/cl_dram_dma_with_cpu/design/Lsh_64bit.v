`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2020 01:59:34 PM
// Design Name: 
// Module Name: Lsh_64bit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//		Left shifts the input a by the amount specified in the input b
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Lsh_64bit(
    input [63:0] a,
    input [63:0] b,
    output [63:0] c
    );
    
    assign c = a<<b;
    
endmodule

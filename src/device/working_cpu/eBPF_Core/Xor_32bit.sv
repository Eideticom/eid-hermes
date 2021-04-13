`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2020 01:48:19 PM
// Design Name: 
// Module Name: Xor_32bit
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


module Xor_32bit(
    input [31:0] a,
    input [31:0] b,
    output [31:0] c
    );
    
    assign c = a^b;
    
endmodule

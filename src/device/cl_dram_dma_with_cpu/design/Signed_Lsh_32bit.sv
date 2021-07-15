`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2020 02:20:56 PM
// Design Name: 
// Module Name: Signed_Lsh_32bit
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


module Signed_Lsh_32bit(
    input [31:0] a,
    input [31:0] b,
    output [31:0] c
    );
    
    assign c = a<<<b;
    
endmodule

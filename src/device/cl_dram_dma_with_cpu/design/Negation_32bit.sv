`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2020 02:31:05 PM
// Design Name: 
// Module Name: Negation_32bit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//		Reverses the sign of input a
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Negation_32bit(
    input [31:0] a,
    output [31:0] c
    );
    
    assign c = -a;
    
endmodule

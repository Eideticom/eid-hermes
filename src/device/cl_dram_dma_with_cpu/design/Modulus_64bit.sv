`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2020 02:37:14 PM
// Design Name: 
// Module Name: Modulus_64bit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//		Computes the modulus of a by b, note that like division this is likely slow
//		and a major improvement to the ALU speed would be improving this design.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Modulus_64bit(
    input [63:0] a,
    input [63:0] b,
    output [63:0] c
    );
    
    assign c = a%b;
    
endmodule

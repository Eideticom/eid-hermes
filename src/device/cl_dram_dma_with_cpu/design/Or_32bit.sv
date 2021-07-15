`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2020 01:38:01 PM
// Design Name: 
// Module Name: Or_32bit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//		Computes the logical OR of a OR b 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Or_32bit(
    input [31:0] a,
    input [31:0] b,
    output [31:0] c
    );
    
    assign c = a|b;
    
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2020 04:42:06 PM
// Design Name: 
// Module Name: Div_32bit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//		Simple division - note that this is NOT a good implementation, if we
//		had a pipelined processor we could use a far better multi-cycle division
//		IP block.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//		This is a major consideration for future improvements on the design.
// 
//////////////////////////////////////////////////////////////////////////////////


module Div_64bit(
    input [63:0] a,
    input [63:0] b,
    output [63:0] y
    );
    //Created as a module if we want to expand into our own custom implementation. 
    //Because we are only dealing with integer values, there is no worry
    //that the computation will result in a larger value. 64 bit outut is sufficient. 
    assign y = a/b;
    
endmodule

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


module Div_32bit(
    input [31:0] a,
    input [31:0] b,
    output [31:0] y
    );
    //Created as a module if we want to expand with our own custom implementation
    //Output is 32 bits since there is no worry of it being larger, due to values being
    //restricted to integers in eBPF.
    assign y = a/b;
    
endmodule

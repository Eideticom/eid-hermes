`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2020 12:54:50 AM
// Design Name: 
// Module Name: Mult_32bit
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


module Mult_32bit(
    input [31:0] a,
    input [31:0] b,
    output [31:0] y
    );
    //Can expand or do custom implementation. Reason for implementing as module
    //Used 64 bit result for 2x32bit multiplication. Can truncate or select fewer bits
    //as necessary
    assign y = a*b; 
    
endmodule

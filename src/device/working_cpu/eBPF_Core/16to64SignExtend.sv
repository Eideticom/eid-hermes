`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/11/2021 04:21:15 PM
// Design Name: 
// Module Name: 16to64SignExtend
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


module SixteenBitSignExtend(
    input signed [15:0] a,
    output signed [63:0] b
    );
    
    assign b = a;
    
    
endmodule

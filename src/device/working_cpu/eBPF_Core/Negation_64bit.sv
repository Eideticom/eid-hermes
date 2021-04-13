`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2020 02:31:05 PM
// Design Name: 
// Module Name: Negation_64bit
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


module Negation_64bit(
    input [63:0] a,
    output [63:0] c
    );
    
    assign c = -1 * a;
    
endmodule

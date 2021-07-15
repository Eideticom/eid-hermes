`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2020 03:00:42 PM
// Design Name: 
// Module Name: Hardware_Adder_64bit
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


module Hardware_Adder_64bit(
    input [63:0] a,
    input [63:0] b,
    output [63:0] c
    );
    
    assign c = a+b;
    
endmodule

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
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Div_32bit(
    input int a,
    input int b,
    output  int y
    );
    //Created as a module if we want to expand with our own custom implementation
    //Output is 32 bits since there is no worry of it being larger, due to values being
    //restricted to integers in eBPF.
    assign y = a/b;
    
endmodule

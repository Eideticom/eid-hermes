`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2020 04:39:27 PM
// Design Name: 
// Module Name: Div_64bit
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


module Div_64bit(
    input longint a,
    input longint b,
    output longint y
    );
    //Created as a module if we want to expand into our own custom implementation. 
    //Because we are only dealing with integer values, there is no worry
    //that the computation will result in a larger value. 64 bit outut is sufficient. 
    assign y = a/b;
    
endmodule

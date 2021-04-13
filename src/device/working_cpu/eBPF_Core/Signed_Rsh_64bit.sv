`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2020 02:20:56 PM
// Design Name: 
// Module Name: Signed_Rsh_64bit
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


module Signed_Rsh_64bit(
    input longint a,
    input longint b,
    output longint c
    );
    
    assign c = a>>>b;
    
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2020 11:31:27 PM
// Design Name: 
// Module Name: Adder_Onebit
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


module Adder_1bit(
    input a,
    input b,
    input cin,
    output s,
    output cout
    );
    wire wire_1;
    wire wire_2; 
    wire wire_3; 
   
    assign wire_1 = a^b; 
    assign wire_2 = wire_1&cin;
    assign wire_3 = a&b; 
    assign cout = wire_2|wire_3; 
    assign s = wire_1^cin;
    
endmodule

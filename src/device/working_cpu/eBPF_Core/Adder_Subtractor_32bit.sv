`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2020 12:24:56 AM
// Design Name: 
// Module Name: Adder_Subtractor_32bit
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


module Adder_Subtractor_32bit(
    input [31:0] a,
    input [31:0] b,
    input sub,
    output [31:0] sum,
    output cout
    );
    
    wire [31:0] b_sub;
    wire [15:0] result1; 
    wire [15:0] result2_1;
    wire [15:0] result2_2; 
    wire cout1;
    wire cout2;
    wire cout3;
    
    assign b_sub = sub?~b:b; 
    
    Adder_16bit instance1(.a(a[15:0]),.b(b_sub[15:0]),.cin(sub),.cout(cout1),.s(result1));
    Adder_16bit instance2_1(.a(a[31:16]),.b(b_sub[31:16]),.cin(1'b0),.cout(cout2),.s(result2_1));
    Adder_16bit instance2_2(.a(a[31:16]),.b(b_sub[31:16]),.cin(1'b1),.cout(cout3),.s(result2_2));
    
    assign sum = cout1?{result2_2,result1}:{result2_1,result1};
    assign cout = cout1?cout3:cout2;
    
endmodule
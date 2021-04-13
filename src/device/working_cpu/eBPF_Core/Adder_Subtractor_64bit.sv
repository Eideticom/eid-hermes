`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2020 03:17:30 PM
// Design Name: 
// Module Name: Adder_Subtractor_64bit
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


module Adder_Subtractor_64bit(
    input [63:0] a,
    input [63:0] b,
    input sub,
    output [63:0] sum,
    output cout
    );
    
    wire [63:0] b_sub;
    wire [31:0] result1;
    wire [31:0] result2; 
    wire [31:0] result3;
    wire cout1;
    wire cout2;
    wire cout3; 
    
    assign b_sub = sub?~b:b;
    
    Adder_Subtractor_32bit instance1(.a(a[31:0]),.b(b_sub[31:0]),.sub(sub),.cout(cout1),.sum(result1));
    Adder_Subtractor_32bit instance2(.a(a[63:32]),.b(b_sub[63:32]),.sub(1'b0),.cout(cout2),.sum(result2)); 
    Adder_Subtractor_32bit instance3(.a(a[63:32]),.b(b_sub[63:32]),.sub(1'b1),.cout(cout3),.sum(result3));
    
    assign sum = cout1?{result3,result1}:{result2,result1};
    assign cout = cout1?cout3:cout2;
    
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2020 11:46:13 PM
// Design Name: 
// Module Name: Adder_16bit
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


module Adder_16bit(
    input [15:0] a,
    input [15:0] b,
    input cin,
    output cout,
    output [15:0] s
    );
    
    wire cout1; 
    wire cout2; 
    wire cout3; 
    wire cout4; 
    wire cout5;
    wire cout6;
    wire cout7; 
    wire cout8; 
    wire cout9;
    wire cout10;
    wire cout11;
    wire cout12;
    wire cout13;
    wire cout14;
    wire cout15; 
    
    Adder_1bit instance_1(.a(a[0]),.b(b[0]),.cin(cin),.s(s[0]),.cout(cout1));
    Adder_1bit instance_2(.a(a[1]),.b(b[1]),.cin(cout1),.s(s[1]),.cout(cout2));
    Adder_1bit instance_3(.a(a[2]),.b(b[2]),.cin(cout2),.s(s[2]),.cout(cout3));
    Adder_1bit instance_4(.a(a[3]),.b(b[3]),.cin(cout3),.s(s[3]),.cout(cout4));
    Adder_1bit instance_5(.a(a[4]),.b(b[4]),.cin(cout4),.s(s[4]),.cout(cout5));
    Adder_1bit instance_6(.a(a[5]),.b(b[5]),.cin(cout5),.s(s[5]),.cout(cout6));
    Adder_1bit instance_7(.a(a[6]),.b(b[6]),.cin(cout6),.s(s[6]),.cout(cout7));
    Adder_1bit instance_8(.a(a[7]),.b(b[7]),.cin(cout7),.s(s[7]),.cout(cout8));
    Adder_1bit instance_9(.a(a[8]),.b(b[8]),.cin(cout8),.s(s[8]),.cout(cout9));
    Adder_1bit instance_10(.a(a[9]),.b(b[9]),.cin(cout9),.s(s[9]),.cout(cout10));
    Adder_1bit instance_11(.a(a[10]),.b(b[10]),.cin(cout10),.s(s[10]),.cout(cout11));
    Adder_1bit instance_12(.a(a[11]),.b(b[11]),.cin(cout11),.s(s[11]),.cout(cout12));
    Adder_1bit instance_13(.a(a[12]),.b(b[12]),.cin(cout12),.s(s[12]),.cout(cout13));
    Adder_1bit instance_14(.a(a[13]),.b(b[13]),.cin(cout13),.s(s[13]),.cout(cout14));
    Adder_1bit instance_15(.a(a[14]),.b(b[14]),.cin(cout14),.s(s[14]),.cout(cout15));
    Adder_1bit instance_16(.a(a[15]),.b(b[15]),.cin(cout15),.s(s[15]),.cout(cout));
    
endmodule

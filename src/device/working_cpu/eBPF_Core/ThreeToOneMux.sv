`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/11/2021 04:43:18 PM
// Design Name: 
// Module Name: ThreeToOneMux
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


module ThreeToOneMux(
    input [63:0] a,
    input [63:0] b,
    input [63:0] c,
    input [1:0] selector,
    output reg [63:0] out
    );
    
    always@(*)
    begin   
        if(selector == 2'b00)
            out = a;
        else if(selector == 2'b01)
            out = b;
        else if(selector == 2'b10)
            out = c;
        else
            out = 0;
     end   
        
endmodule

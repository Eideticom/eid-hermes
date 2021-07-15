`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/12/2021 07:32:43 PM
// Design Name: 
// Module Name: ThirtyTwoBitLeftPad
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


module ThirtyTwoBitLeftPad(
    input [31:0] a,
    output [63:0] out
    );
    
    assign out = {32'b0, a};
    
endmodule

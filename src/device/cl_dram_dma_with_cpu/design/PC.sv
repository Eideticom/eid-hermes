`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/11/2021 04:30:11 PM
// Design Name: 
// Module Name: PC
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


module PC(
    input [63:0] inputInstruction,
    output reg [63:0] outputInstruction,
    input clk,
    input continueRunning //Currently not implemented, need a better idea on the predicted functionality. 
    );
    
    always @(posedge clk)
    begin
            if(continueRunning == 1'b1)
            outputInstruction <= inputInstruction;
    end
    
    
endmodule

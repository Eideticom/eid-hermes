`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/28/2021 09:20:56 PM
// Design Name: 
// Module Name: DestReg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//		A simple register block for use in "saving" the register that is the dst
//		from the previous instruction - this only exists for support of the
//		lddw instruction(s)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module DestReg(
    input [3:0] dst,
    input clk,
    output reg [3:0] dstDelayed
    );
    
    always_ff @ (posedge clk) begin
        
        dstDelayed <= dst;
        
    end
    
endmodule



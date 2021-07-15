`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/19/2021 12:58:02 PM
// Design Name: 
// Module Name: Controller
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


module Controller( 
  output reg reset,
  output reg [63:0] DMTop, 
  output reg [63:0] DMBottom,
  output reg [63:0] IMBottom,
  output reg [63:0] IMTop
  );
    always @(*) begin
    
        reset <= 1'b0; //No input for state control, keep low 
        IMBottom <= 64'h0000_0000_1f00; //beginnning address of DIMM A : First address for Instruction Memory
        IMTop <= 64'h0007_ffff_ffff;   //End address of DIMM B : Last address for Instruction Memory
        DMBottom <= 64'h0008_0000_0000;  //Beginning address of DIMM C : First address for Data Memory 
        DMTop <= 64'h000f_ffff_ffff;  //End address of DIMM D : Last address for Data Memroy
        
    end

endmodule

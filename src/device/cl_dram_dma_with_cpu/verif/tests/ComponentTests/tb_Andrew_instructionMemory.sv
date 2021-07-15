`timescale 1ns / 1ps //Timescale used to specify what a "Time unit" is. timescale 1ns / 1ps = 1ns time unit with 1 ps precision. #20 = 20 time units = 20 ns


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2020 04:01:30 PM
// Design Name: 
// Module Name: tb_Adder_1bit
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


module tb_Andrew_instructionMemory;
   
   reg clk;
   
   reg [63:0] instructionRetrieved;
   reg [63:0] addressToAccess;
   
   
   instructionMemory UUT(.instructionAddress(addressToAccess), .instruction(instructionRetrieved));
   
  	initial
  	begin
  	     
  	     
  	     for(int i = 0; i< 16; i++)
  	     begin
  	         addressToAccess = i;
  	         #10;
  	     end
  	     
  	end
endmodule

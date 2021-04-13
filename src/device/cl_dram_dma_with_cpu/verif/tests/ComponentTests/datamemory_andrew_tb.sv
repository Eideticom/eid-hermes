`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/11/2021 12:38:26 PM
// Design Name: 
// Module Name: datamemory_andrew_tb
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


module datamemory_andrew_tb;

   reg clk;
   
   reg [63:0] instructionRetrieved;
   reg [63:0] addressToAccess;
   reg [63:0] dataRead;
   reg [63:0] writeData;
   reg[1:0] size;
   
   reg memWrite;
   reg memRead;
   
   dataMemory UUT(.address(addressToAccess), .readData(dataRead), .clk(clk), .memWrite(memWrite), .memRead(memRead), .sizeSelect(size), .writeData(writeData));
   
   always
        #5 clk = !clk;
   
   
  	initial
  	begin
  	     clk = 0;
  	     memRead = 1'b0;
  	     memWrite = 1'b1;
  	     size = 2'b10;
  	     writeData = 8'hab;
  	     
  	     for(int i = 0; i< 88; i++)
  	     begin
  	         addressToAccess = i;
  	         writeData = i;
  	         #10;
  	     end
  	     
  	     memRead = 1'b1;
  	     memWrite = 1'b0;
  	     size = 2'b11;
  	     writeData = 8'hab;
  	     
  	     for(int i = 0; i< 11; i++)
  	     begin
  	         addressToAccess = i*8;
  	         #10;
  	     end
  	     
  	     
  	end
endmodule

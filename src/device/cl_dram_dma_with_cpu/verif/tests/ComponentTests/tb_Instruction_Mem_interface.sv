`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/19/2021 01:54:56 PM
// Design Name: 
// Module Name: tb_Instruction_Mem_interface
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


module tb_Instruction_Mem_interface(

    );
    
    reg clk;
    reg fastclk;
    reg  [63:0] coreInstruction;
    reg [63:0] coreAddress = 64'h0xffffffff;
    reg readReady;
    wire readRequest;
    reg [63:0] memAddress;
    reg [63:0] memInstruction;
    reg read_instruct;
    string file_name = "add";
    
    instructionMemory instructionMemory(.instructionAddress(memAddress) ,.instruction(memInstruction) , .readReady(readReady), .read_request(readRequest), .read_instruct(read_instruct), .file_name(file_name) , .reset(reset)) ;
    Instruction_Mem_Interface instructInterface(.coreAddress(coreAddress), .memInstruction(memInstruction), .readReady(readReady), .clk(fastclk), .readRequest(readRequest), .memAddress(memAddress), .coreInstruction(coreInstruction));
    
    
    initial
  	begin
    clk = 0; 
  	     forever
  	         #5 clk = !clk;   
  	end
  	
  	initial
  	begin
    fastclk = 0; 
  	     forever
  	         #1 fastclk = !fastclk;   
  	end
    
    
    initial
    begin
        
        read_instruct = 1'b1;
        
        #15;
    
        coreAddress  = 64'h0;
        #10
        coreAddress = coreAddress + 8; // New program is loaded in
        #10;
        coreAddress = coreAddress + 8;
        #10;
        coreAddress = coreAddress + 8;
        #10;
        coreAddress = coreAddress + 8;
        #10;
        coreAddress = coreAddress + 8;
        #10;
        coreAddress = coreAddress + 8;
        #10;
        
    end
    
endmodule

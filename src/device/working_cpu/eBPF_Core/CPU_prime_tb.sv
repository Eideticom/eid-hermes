`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/12/2021 10:41:53 AM
// Design Name: 
// Module Name: CPU_tb
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


//`include "memory_opcode.svh"
`define fileNames(extension) `"add.extension`"
module CPU_prime_tb(

    );
    
    reg [63:0] instructionFromMem;
    reg [63:0] dataFromMem;
    reg [63:0] firstInstructionAddress = 0;
    reg reset;
    reg clk;
    reg memWrite; 
    reg memRead;
    reg [1:0] sizeSelect;
    reg [63:0] writeData;
    reg [63:0] addressForData;
    reg [63:0] addressForInstruction;
    reg[1:0] dataMemoryExc = 0;
    reg [1:0] instructionMemoryExc = 0;
    
    string file_name;
    
    
    CPU CPU(.instructionFromMem(instructionFromMem), .dataFromMem(dataFromMem), .firstInstructionAddress(firstInstructionAddress)
    ,.reset(reset), .clk(clk), .memWrite(memWrite), .memRead(memRead), .sizeSelect(sizeSelect), .writeData(writeData), .addressForData(addressForData),
    .addressForInstruction(addressForInstruction), .dataMemoryExc(dataMemoryExc) ,.instructionMemoryExc(instructionMemoryExc));
    
    
    reg instruct_read;
    reg data_read = 0;
    instructionMemory instructionMemory(.instructionAddress(addressForInstruction), .instruction(instructionFromMem), .read_instruct(instruct_read), .file_name(file_name), .reset(reset));
    dataMemory dataMemory(.clk(clk), .memWrite(memWrite), .memRead(memRead), .sizeSelect(sizeSelect), .writeData(writeData), .readData(dataFromMem), .address(addressForData), .data_read(data_read), .file_name(file_name));
    
    
    
       
   //reg clk;
   
   reg [63:0] instructionRetrieved;
   reg [63:0] addressToAccess;
   reg [63:0] resultFromFile [1:0];
   string  successful_tests [120:0];
   
   assign instructionRetrieved = instructionFromMem;
   assign addressToAccess = addressForInstruction;
   integer numSuccess = 0;
   
    initial
  	begin
    clk = 0; 
  	     forever
  	         #5 clk = !clk;   
  	end
  	  

initial
begin
	$display("Beginning CPU tests!"); 
	numSuccess = 0;


	file_name = "prime" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#10000
	$readmemh("prime.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "prime.bytes";
		$display("Success on Test: %s", file_name);
	end else begin
		$display("Failed on Test: %s", file_name);
		$display("Expected result : %h ", resultFromFile[0] );
		$display("Found result : %h ", CPU.rFile.gprs[0] );
	end
	instruct_read = 0;
	data_read = 0;
	resultFromFile[0] = 0;
	#5;
    
    file_name = "prime_68" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;
    
    #10000
	$readmemh("prime_68.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "prime_68.bytes";
		$display("Success on Test: %s", file_name);
	end else begin
		$display("Failed on Test: %s", file_name);
		$display("Expected result : %h ", resultFromFile[0] );
		$display("Found result : %h ", CPU.rFile.gprs[0] );
	end
	instruct_read = 0;
	data_read = 0;
	resultFromFile[0] = 0;
	#5;

end


endmodule

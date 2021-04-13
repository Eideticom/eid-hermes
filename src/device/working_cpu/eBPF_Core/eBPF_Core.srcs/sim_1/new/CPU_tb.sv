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
module CPU_tb(

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

	file_name = "add" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#50
	$readmemh("add.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "add.bytes";
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

	file_name = "alu-arith" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#190
	$readmemh("alu-arith.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "alu-arith.bytes";
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

	file_name = "alu-bit" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#210
	$readmemh("alu-bit.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "alu-bit.bytes";
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

	file_name = "alu" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#210
	instruct_read = 0;
	data_read = 0;
	resultFromFile[0] = 0;
	#5;

	file_name = "alu64-arith" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#190
	$readmemh("alu64-arith.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "alu64-arith.bytes";
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

	file_name = "alu64-bit" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#230
	$readmemh("alu64-bit.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "alu64-bit.bytes";
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

	file_name = "alu64" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#150
	instruct_read = 0;
	data_read = 0;
	resultFromFile[0] = 0;
	#5;

	file_name = "arsh-reg" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#50
	$readmemh("arsh-reg.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "arsh-reg.bytes";
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

	file_name = "arsh" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#40
	$readmemh("arsh.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "arsh.bytes";
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

	file_name = "arsh32-high-shift" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#50
	$readmemh("arsh32-high-shift.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "arsh32-high-shift.bytes";
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

	file_name = "arsh64" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#60
	$readmemh("arsh64.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "arsh64.bytes";
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

	file_name = "be16-high" ;
	instruct_read = 1;
	$display(" Memory should be initialized from be16-high.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#30
	$readmemh("be16-high.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "be16-high.bytes";
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

	file_name = "be16" ;
	instruct_read = 1;
	$display(" Memory should be initialized from be16.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#30
	$readmemh("be16.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "be16.bytes";
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

	file_name = "be32-high" ;
	instruct_read = 1;
	$display(" Memory should be initialized from be32-high.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#30
	$readmemh("be32-high.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "be32-high.bytes";
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

	file_name = "be32" ;
	instruct_read = 1;
	$display(" Memory should be initialized from be32.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#30
	$readmemh("be32.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "be32.bytes";
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

	file_name = "be64" ;
	instruct_read = 1;
	$display(" Memory should be initialized from be64.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#30
	$readmemh("be64.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "be64.bytes";
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

	file_name = "call-memfrob" ;
	instruct_read = 1;
	$display(" Memory should be initialized from call-memfrob.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#70
	$readmemh("call-memfrob.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "call-memfrob.bytes";
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

	file_name = "call-save" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#110
	$readmemh("call-save.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "call-save.bytes";
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

	file_name = "call" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#70
	$readmemh("call.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "call.bytes";
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

	file_name = "div32-high-divisor" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#50
	$readmemh("div32-high-divisor.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "div32-high-divisor.bytes";
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

	file_name = "div32-imm" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#40
	$readmemh("div32-imm.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "div32-imm.bytes";
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

	file_name = "div32-reg" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#50
	$readmemh("div32-reg.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "div32-reg.bytes";
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

	file_name = "div64-imm" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#40
	$readmemh("div64-imm.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "div64-imm.bytes";
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

	file_name = "div64-reg" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#50
	$readmemh("div64-reg.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "div64-reg.bytes";
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

	file_name = "early-exit" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#40
	$readmemh("early-exit.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "early-exit.bytes";
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

	file_name = "err-call-bad-imm" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#70
	$readmemh("err-call-bad-imm.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "err-call-bad-imm.bytes";
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

	file_name = "err-call-unreg" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#70
	$readmemh("err-call-unreg.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "err-call-unreg.bytes";
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

	file_name = "err-div-by-zero-imm" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#30
	$readmemh("err-div-by-zero-imm.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "err-div-by-zero-imm.bytes";
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

	file_name = "err-div-by-zero-reg" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#40
	$readmemh("err-div-by-zero-reg.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "err-div-by-zero-reg.bytes";
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

	file_name = "err-div64-by-zero-reg" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#40
	$readmemh("err-div64-by-zero-reg.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "err-div64-by-zero-reg.bytes";
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

	file_name = "err-endian-size" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#30
	$readmemh("err-endian-size.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "err-endian-size.bytes";
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

	file_name = "err-incomplete-lddw" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#20
	$readmemh("err-incomplete-lddw.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "err-incomplete-lddw.bytes";
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

	file_name = "err-incomplete-lddw2" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#20
	$readmemh("err-incomplete-lddw2.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "err-incomplete-lddw2.bytes";
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

	file_name = "err-invalid-reg-dst" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#20
	$readmemh("err-invalid-reg-dst.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "err-invalid-reg-dst.bytes";
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

	file_name = "err-invalid-reg-src" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#20
	$readmemh("err-invalid-reg-src.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "err-invalid-reg-src.bytes";
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

	file_name = "err-jmp-lddw" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#40
	$readmemh("err-jmp-lddw.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "err-jmp-lddw.bytes";
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

	file_name = "err-jmp-out" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#20
	$readmemh("err-jmp-out.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "err-jmp-out.bytes";
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

	file_name = "err-mod-by-zero-reg" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#40
	$readmemh("err-mod-by-zero-reg.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "err-mod-by-zero-reg.bytes";
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

	file_name = "err-mod64-by-zero-reg" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#40
	$readmemh("err-mod64-by-zero-reg.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "err-mod64-by-zero-reg.bytes";
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

	file_name = "err-stack-oob" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#20
	$readmemh("err-stack-oob.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "err-stack-oob.bytes";
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

	file_name = "err-unknown-opcode" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#20
	$readmemh("err-unknown-opcode.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "err-unknown-opcode.bytes";
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

	file_name = "err-write-r10" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#20
	$readmemh("err-write-r10.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "err-write-r10.bytes";
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

	file_name = "exit-not-last" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#60
	$readmemh("exit-not-last.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "exit-not-last.bytes";
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

	file_name = "exit" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#20
	$readmemh("exit.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "exit.bytes";
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

	file_name = "ja" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#40
	$readmemh("ja.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "ja.bytes";
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

	file_name = "jeq-imm" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#80
	$readmemh("jeq-imm.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "jeq-imm.bytes";
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

	file_name = "jeq-reg" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#90
	$readmemh("jeq-reg.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "jeq-reg.bytes";
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

	file_name = "jge-imm" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#80
	$readmemh("jge-imm.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "jge-imm.bytes";
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

	file_name = "jgt-imm" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#80
	$readmemh("jgt-imm.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "jgt-imm.bytes";
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

	file_name = "jgt-reg" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#100
	$readmemh("jgt-reg.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "jgt-reg.bytes";
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

	file_name = "jit-bounce" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#70
	$readmemh("jit-bounce.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "jit-bounce.bytes";
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

	file_name = "jle-imm" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#90
	$readmemh("jle-imm.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "jle-imm.bytes";
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

	file_name = "jle-reg" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#110
	$readmemh("jle-reg.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "jle-reg.bytes";
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

	file_name = "jlt-imm" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#80
	$readmemh("jlt-imm.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "jlt-imm.bytes";
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

	file_name = "jlt-reg" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#100
	$readmemh("jlt-reg.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "jlt-reg.bytes";
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

	file_name = "jmp" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#140
	instruct_read = 0;
	data_read = 0;
	resultFromFile[0] = 0;
	#5;

	file_name = "jne-reg" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#90
	$readmemh("jne-reg.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "jne-reg.bytes";
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

	file_name = "jset-imm" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#80
	$readmemh("jset-imm.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "jset-imm.bytes";
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

	file_name = "jset-reg" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#90
	$readmemh("jset-reg.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "jset-reg.bytes";
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

	file_name = "jsge-imm" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#90
	$readmemh("jsge-imm.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "jsge-imm.bytes";
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

	file_name = "jsge-reg" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#110
	$readmemh("jsge-reg.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "jsge-reg.bytes";
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

	file_name = "jsgt-imm" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#80
	$readmemh("jsgt-imm.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "jsgt-imm.bytes";
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

	file_name = "jsgt-reg" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#90
	$readmemh("jsgt-reg.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "jsgt-reg.bytes";
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

	file_name = "jsle-imm" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#90
	$readmemh("jsle-imm.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "jsle-imm.bytes";
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

	file_name = "jsle-reg" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#120
	$readmemh("jsle-reg.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "jsle-reg.bytes";
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

	file_name = "jslt-imm" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#80
	$readmemh("jslt-imm.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "jslt-imm.bytes";
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

	file_name = "jslt-reg" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#100
	$readmemh("jslt-reg.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "jslt-reg.bytes";
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

	file_name = "lddw" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#30
	$readmemh("lddw.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "lddw.bytes";
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

	file_name = "lddw2" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#30
	$readmemh("lddw2.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "lddw2.bytes";
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

	file_name = "ldx" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#80
	instruct_read = 0;
	data_read = 0;
	resultFromFile[0] = 0;
	#5;

	file_name = "ldxb-all" ;
	instruct_read = 1;
	$display(" Memory should be initialized from ldxb-all.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#310
	$readmemh("ldxb-all.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "ldxb-all.bytes";
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

	file_name = "ldxb" ;
	instruct_read = 1;
	$display(" Memory should be initialized from ldxb.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#20
	$readmemh("ldxb.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "ldxb.bytes";
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

	file_name = "ldxdw" ;
	instruct_read = 1;
	$display(" Memory should be initialized from ldxdw.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#20
	$readmemh("ldxdw.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "ldxdw.bytes";
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

	file_name = "ldxh-all" ;
	instruct_read = 1;
	$display(" Memory should be initialized from ldxh-all.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#410
	$readmemh("ldxh-all.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "ldxh-all.bytes";
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

	file_name = "ldxh-all2" ;
	instruct_read = 1;
	$display(" Memory should be initialized from ldxh-all2.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#310
	$readmemh("ldxh-all2.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "ldxh-all2.bytes";
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

	file_name = "ldxh-same-reg" ;
	instruct_read = 1;
	$display(" Memory should be initialized from ldxh-same-reg.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#40
	$readmemh("ldxh-same-reg.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "ldxh-same-reg.bytes";
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

	file_name = "ldxh" ;
	instruct_read = 1;
	$display(" Memory should be initialized from ldxh.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#20
	$readmemh("ldxh.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "ldxh.bytes";
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

	file_name = "ldxw-all" ;
	instruct_read = 1;
	$display(" Memory should be initialized from ldxw-all.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#310
	$readmemh("ldxw-all.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "ldxw-all.bytes";
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

	file_name = "ldxw" ;
	instruct_read = 1;
	$display(" Memory should be initialized from ldxw.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#20
	$readmemh("ldxw.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "ldxw.bytes";
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

	file_name = "le16" ;
	instruct_read = 1;
	$display(" Memory should be initialized from le16.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#30
	$readmemh("le16.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "le16.bytes";
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

	file_name = "le32" ;
	instruct_read = 1;
	$display(" Memory should be initialized from le32.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#30
	$readmemh("le32.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "le32.bytes";
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

	file_name = "le64" ;
	instruct_read = 1;
	$display(" Memory should be initialized from le64.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#30
	$readmemh("le64.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "le64.bytes";
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

	file_name = "lsh-reg" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#40
	$readmemh("lsh-reg.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "lsh-reg.bytes";
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

	file_name = "mod" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#50
	$readmemh("mod.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "mod.bytes";
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

	file_name = "mod32" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#40
	$readmemh("mod32.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "mod32.bytes";
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

	file_name = "mod64" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#90
	$readmemh("mod64.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "mod64.bytes";
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

	file_name = "mov" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#30
	$readmemh("mov.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "mov.bytes";
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

	file_name = "mul-loop" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#500
	$readmemh("mul-loop.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "mul-loop.bytes";
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

	file_name = "mul32-imm" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#30
	$readmemh("mul32-imm.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "mul32-imm.bytes";
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

	file_name = "mul32-reg-overflow" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#40
	$readmemh("mul32-reg-overflow.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "mul32-reg-overflow.bytes";
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

	file_name = "mul32-reg" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#40
	$readmemh("mul32-reg.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "mul32-reg.bytes";
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

	file_name = "mul64-imm" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#30
	$readmemh("mul64-imm.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "mul64-imm.bytes";
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

	file_name = "mul64-reg" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#40
	$readmemh("mul64-reg.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "mul64-reg.bytes";
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

	file_name = "neg" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#30
	$readmemh("neg.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "neg.bytes";
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

	file_name = "neg64" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#30
	$readmemh("neg64.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "neg64.bytes";
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

	file_name = "prime" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#160
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

	file_name = "rsh-reg" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#40
	$readmemh("rsh-reg.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "rsh-reg.bytes";
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

	file_name = "rsh32" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#40
	$readmemh("rsh32.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "rsh32.bytes";
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

	file_name = "st" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#50
	instruct_read = 0;
	data_read = 0;
	resultFromFile[0] = 0;
	#5;

	file_name = "stack" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#90
	$readmemh("stack.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "stack.bytes";
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

	file_name = "stack2" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#160
	$readmemh("stack2.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "stack2.bytes";
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

	file_name = "stb" ;
	instruct_read = 1;
	$display(" Memory should be initialized from stb.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#30
	$readmemh("stb.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "stb.bytes";
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

	file_name = "stdw" ;
	instruct_read = 1;
	$display(" Memory should be initialized from stdw.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#30
	$readmemh("stdw.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "stdw.bytes";
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

	file_name = "sth" ;
	instruct_read = 1;
	$display(" Memory should be initialized from sth.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#30
	$readmemh("sth.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "sth.bytes";
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

	file_name = "string-stack" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#280
	$readmemh("string-stack.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "string-stack.bytes";
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

	file_name = "stw" ;
	instruct_read = 1;
	$display(" Memory should be initialized from stw.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#30
	$readmemh("stw.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "stw.bytes";
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

	file_name = "stx" ;
	instruct_read = 1;
	data_read = 0;
	reset = 1;
	#15
	reset = 0;

	#50
	instruct_read = 0;
	data_read = 0;
	resultFromFile[0] = 0;
	#5;

	file_name = "stxb-all" ;
	instruct_read = 1;
	$display(" Memory should be initialized from stxb-all.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#190
	$readmemh("stxb-all.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "stxb-all.bytes";
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

	file_name = "stxb-all2" ;
	instruct_read = 1;
	$display(" Memory should be initialized from stxb-all2.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#80
	$readmemh("stxb-all2.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "stxb-all2.bytes";
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

	file_name = "stxb-chain" ;
	instruct_read = 1;
	$display(" Memory should be initialized from stxb-chain.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#210
	$readmemh("stxb-chain.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "stxb-chain.bytes";
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

	file_name = "stxb" ;
	instruct_read = 1;
	$display(" Memory should be initialized from stxb.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#40
	$readmemh("stxb.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "stxb.bytes";
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

	file_name = "stxdw" ;
	instruct_read = 1;
	$display(" Memory should be initialized from stxdw.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#60
	$readmemh("stxdw.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "stxdw.bytes";
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

	file_name = "stxh" ;
	instruct_read = 1;
	$display(" Memory should be initialized from stxh.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#40
	$readmemh("stxh.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "stxh.bytes";
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

	file_name = "stxw" ;
	instruct_read = 1;
	$display(" Memory should be initialized from stxw.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#40
	$readmemh("stxw.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "stxw.bytes";
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

	file_name = "subnet" ;
	instruct_read = 1;
	$display(" Memory should be initialized from subnet.mem");
	data_read = 1;
	reset = 1;
	#15
	reset = 0;

	#140
	$readmemh("subnet.res" ,resultFromFile);
	if(int'(CPU.rFile.gprs[0]) == int'(resultFromFile[0])) begin
		successful_tests[numSuccess ++] = "subnet.bytes";
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

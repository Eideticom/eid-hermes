`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/26/2021 03:18:52 PM
// Design Name: 
// Module Name: Hermes_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      The top level block for our design; includes the CPU, interface for AXI
//      and the interfaces for data and instruction memory
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Hermes_top(
	 input            aclk,
	 input            aresetn,
	 axi_bus_t.slave  cl_axi_mstr_bus,  // AXI Master Bus
	 cfg_bus_t.master axi_mstr_cfg_bus  // Config Bus for Register Access
    );

    wire [63:0] instructionFromMem;
    wire [63:0] dataFromMem;
    wire [63:0] firstInstructionAddress;
    reg        reset;
    wire        clk;
    wire [1:0]  dataMemoryExc;
    wire [1:0]  instructionMemoryExc;
    wire        memWrite;
    wire        memRead;
    wire [1:0]  sizeSelect;
    wire [63:0] writeData;
    wire [63:0] addressForData;
    wire [63:0] addressForInstruction;
    wire [4:0]  exception;
    wire [63:0] badAddress;
    wire [63:0] badInstruction; 
    wire continue_data_mem;
    wire continue_instruct_mem; 
    wire continue_cpu = continue_data_mem & continue_instruct_mem; //Need to add continue logic
    
	wire [63:0]	 IM_address;
	wire 		 IM_read_request;
	wire 		 IM_read_ready;
	wire  [63:0] IM_instruction;
	wire [63:0]	 DM_address;
	wire 		 DM_read_request;
	wire 		 DM_write_request;
	wire 		 DM_read_ready;
	wire 		 DM_write_finished;
	wire [63:0]	 DM_data_from_CPU;
	wire [63:0]  DM_data_to_CPU;
	wire [1:0]	 DM_block_size;
	wire 		 DM_write_ready;
	
     wire [63:0] DMTop;
     wire [63:0] DMBottom;
     wire [63:0] IMBottom;
     wire [63:0] IMTop;

CPU 
CPU(.instructionFromMem(instructionFromMem), 
.dataFromMem(dataFromMem),            
.firstInstructionAddress(IMBottom),
.reset(reset),
.clk(clk),                    
.dataMemoryExc(dataMemoryExc),          
.instructionMemoryExc(instructionMemoryExc),  
.PCContinue(continue_cpu),
.DMBottom(DMBottom),
.memWrite(memWrite),               
.memRead(memRead),                
.sizeSelect(sizeSelect),             
.writeData(writeData),              
.addressForData(addressForData),         
.addressForInstruction(addressForInstruction),  
.exception(exception),              
.badAddress(badAddress),             
.badInstruction(badInstruction)         
);

Data_Mem_Interface Data_Mem_Interface(
.address_to_mem(DM_address),
.address_from_cpu(addressForData),
.read_bit_from_cpu(memRead),
.read_request_to_mem(DM_read_request),
.write_bit_from_cpu(memWrite),
.write_request_to_mem(DM_write_request),
.size_select_from_cpu(sizeSelect),
.size_select_to_mem(DM_block_size),
.read_data_to_cpu(dataFromMem),
.read_data_from_mem(DM_data_to_CPU),
.write_data_from_cpu(writeData),
.write_data_to_mem(DM_data_from_CPU),
.DMBottom(DMBottom),
.DMTop(DMTop),
.read_ready_from_mem(DM_read_ready),
.write_finished_from_mem(DM_write_finished),
.write_ready_from_mem(DM_write_ready),
.clk(aclk),
.continue_to_cpu(continue_data_mem)
);

Instruction_Mem_Interface Instruction_Mem_Interface (
.coreAddress(addressForInstruction),
.memInstruction(IM_address),
.readReady(IM_read_ready),
.instructionMemExc(),
.clk(aclk),
.readRequest(IM_read_request),
.memAddress(IM_address),
.coreInstruction(instructionFromMem),
.continue_to_cpu(continue_instruct_mem)
);

Controller Interface_Controller(
.reset(reset),
.DMTop(DMTop),
.DMBottom(DMBottom),
.IMBottom(IMBottom),
.IMTop(IMTop)
);

axi_memory_interface Axi_Memory_Interface (
.aclk(aclk),
.aresetn(aresetn),
.cl_axi_mstr_bus(cl_axi_mstr_bus),
.axi_mstr_cfg_bus(axi_mstr_cfg_bus),
.IM_address(IM_address),
.IM_read_request(IM_read_request),
.IM_read_ready(IM_read_ready),
.IM_instruction(IM_instruction),
.DM_address(DM_address),
.DM_read_request(DM_read_request),
.DM_write_request(DM_write_request),
.DM_read_ready(DM_read_ready),
.DM_write_finished(DM_write_finished),
.DM_data_from_CPU(DM_data_from_CPU),
.DM_data_to_CPU(DM_data_to_CPU),
.DM_block_size(DM_block_size),
.DM_write_ready(DM_write_ready)
);
  
endmodule

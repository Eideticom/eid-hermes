`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Spencer Comin
// 
// Create Date: 01/22/2021 07:31:45 PM
// Design Name: 
// Module Name: ExceptionHandler
// Project Name: Hermes
// Target Devices: 
// Tool Versions: 
// Description: 
//      The main block for handling exceptions in the processor
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "exception.svh"

import global_exception::*;

module ExceptionHandler(
    input clk,
    input [1:0] ALUExc,
    input [1:0] controlExc,
    input [1:0] dataMemoryExc,
    input [1:0] instructionMemoryExc,
    input [1:0] registerExc,
    input [63:0] instructionAddress,
    input [63:0] instruction,
    output excCaught,
    output [4:0] exception,
    output [63:0] badAddress,
    output [63:0] badInstruction
    );
    
    wire [2:0] classCode;
    wire [1:0] descriptorCode;
    reg [63:0] lastAddress;
    
    const logic [4:0] NOTHING = {NO_CLASS, NO_EXCEPTION};
    
    assign excCaught = exception != NOTHING;
    
    assign badAddress = !excCaught ? '0 : instructionAddress;
    
    assign badInstruction = !excCaught ? '0 : instruction;
        
    assign exception =  controlExc             != NO_EXCEPTION ? {CONTROL_CLASS, controlExc}
                        : registerExc          != NO_EXCEPTION ? {REGISTER_CLASS, registerExc}
                        : ALUExc               != NO_EXCEPTION ? {ALU_CLASS, ALUExc}
                        : dataMemoryExc        != NO_EXCEPTION ? {DATA_MEMORY_CLASS, dataMemoryExc}
                        : instructionMemoryExc != NO_EXCEPTION ? {INSTRUCTION_MEMORY_CLASS, instructionMemoryExc}
                        :                                         NOTHING;
    
    /*
    always @(posedge(clk)) begin
        lastAddress <= instructionAddress;
    end
    */                  
endmodule

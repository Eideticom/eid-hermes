`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/19/2021 09:46:32 AM
// Design Name: 
// Module Name: Instruction_Mem_Interface
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      The state machine for instruction memory accesses in DRAM, handles read
//      requests to instruction memory for next instruction
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Instruction_Mem_Interface(
    input reg [63:0] coreAddress,
    input reg [63:0] memInstruction,
    input reg readReady,
    input instructionMemExc,
    input clk,
    output reg readRequest,
    output reg [63:0] memAddress,
    output reg [63:0] coreInstruction,
    output reg continue_to_cpu
    );
    
    // Assumptions in this interface: Assumes that it will be clocked with a higher speed than the CPU
    // Assumes that that starting address a program will be an address other than 0x0000000.. etc. 
    
    reg [1:0] state = 2'b0;
    reg [2:0] nextState = 2'b0;
    reg [63:0] lastAddress = 64'h0;
    initial begin
        readRequest = 1'b0;
    end
    
    always @(posedge clk) begin
        state <= nextState;
    end
    
    always @(negedge clk)begin
        lastAddress <= coreAddress;
    end

    always @(state, readReady, coreAddress) begin
    
        if (state == 2'b00) begin
            //idle
            readRequest = 1'b0;
            memAddress = 64'b0;
            continue_to_cpu = 1;
            coreInstruction = 64'b0 ;
            
            
            if(coreAddress != lastAddress) nextState = 2'b01;
        
        end 
        else if (state == 2'b01) begin
        
            // Core Address Changed -> Read Request
            readRequest = 1'b1;
            memAddress = coreAddress;
            coreInstruction = 64'b0 ;
            continue_to_cpu = 0;
            nextState = 2'b10;
            
        
        end 
        else if (state == 2'b10) begin
            nextState = 2'b10;
            continue_to_cpu = 0;
            coreInstruction = 64'b0 ;
            readRequest = 1'b0;
            memAddress = coreAddress;
            // Wait until we get readReady
            if (readReady == 1'b1) begin
                
                coreInstruction = memInstruction;
                continue_to_cpu = 1;
                readRequest = 1'b0;
                nextState = 2'b0;
               memAddress = 64'b0;
            end
            
        
        end 
        else begin
        
            // Some random default state
            readRequest = 1'b0;
            coreInstruction = 64'b0;
            memAddress = 64'b0;
            continue_to_cpu = 1;
            nextState = 2'b0;
        
        end
    
    end
    
endmodule

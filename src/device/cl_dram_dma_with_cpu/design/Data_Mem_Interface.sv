`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/19/2021 10:48:34 AM
// Design Name: 
// Module Name: Data_Mem_Interface
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      A state machine for use in our overall design with the CL_DRAM_DMA AWS
//      example. Contains the logic for interfacing with the AXI_MSTR axi interface
//      for read adn write requests to data memory
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Data_Mem_Interface(
    output reg [63:0] address_to_mem,
    input [63:0] address_from_cpu,
    input read_bit_from_cpu,
    output reg read_request_to_mem,
    input write_bit_from_cpu,
    output reg write_request_to_mem,
    input [1:0] size_select_from_cpu,
    output reg [1:0] size_select_to_mem,
    output reg [63:0] read_data_to_cpu,
    input [63:0] read_data_from_mem,
    input [63:0] write_data_from_cpu,
    output reg [63:0] write_data_to_mem,
    input [63:0] DMBottom,
    input [63:0] DMTop,
    input read_ready_from_mem,
    input write_finished_from_mem,
    input write_ready_from_mem,
    input clk,
    output reg continue_to_cpu
    );
    
    typedef enum logic [2:0] {
    DATA_MEM_IDLE = 3'd0,
    DATA_MEM_READ_REQUEST = 3'd1,
    DATA_MEM_READ_READY = 3'd2,
    DATA_MEM_WRITE_REQUEST = 3'd3,
    DATA_MEM_WRITE_READY = 3'd4,
    DATA_MEM_EXCEPTION = 3'd5
    } data_mem_states;
    
    data_mem_states current_state;
    data_mem_states next_state;
    
    always @(*) begin
    
        next_state [2:0] = DATA_MEM_IDLE;
        
        case(current_state)
            DATA_MEM_IDLE: begin
                        
                write_data_to_mem [63:0] = 64'h0;
                read_data_to_cpu [63:0] = 64'h0;
                size_select_to_mem [1:0] = 2'b00;
                write_request_to_mem = 1'b0;
                read_request_to_mem = 1'b0;
                address_to_mem [63:0] = 64'h0; 
                continue_to_cpu = 1;
                
                if(read_bit_from_cpu == 1'b1 && write_bit_from_cpu == 1'b0)  next_state [2:0] = DATA_MEM_READ_REQUEST;
                if(read_bit_from_cpu == 1'b0 && write_bit_from_cpu == 1'b1) next_state [2:0] = DATA_MEM_WRITE_REQUEST;
                else next_state [2:0] = DATA_MEM_IDLE; 
         
            end
            
            DATA_MEM_READ_REQUEST: begin
                address_to_mem [63:0] = address_from_cpu [63:0];
                read_request_to_mem = 1'b1;
                size_select_to_mem = size_select_from_cpu;
                
                write_data_to_mem [63:0] = 64'h0;
                read_data_to_cpu [63:0] = 64'h0;
                write_request_to_mem = 1'b0;
               
                continue_to_cpu = 0;
               
                if(read_ready_from_mem == 1'b1) next_state[2:0] = DATA_MEM_READ_READY;
                else next_state [2:0] = DATA_MEM_READ_REQUEST;
            end
            
            DATA_MEM_READ_READY : begin
                read_data_to_cpu [63:0] = read_data_from_mem [63:0];
                
                write_data_to_mem [63:0] = 64'h0;
                size_select_to_mem [1:0] = 2'b00;
                write_request_to_mem= 1'b0;
                read_request_to_mem = 1'b1;  // May have issues with the interaction between this and AXI
                address_to_mem [63:0] = 64'h0;
                continue_to_cpu = 1;
                
                next_state[2:0] = DATA_MEM_IDLE;
                
            end
            
            DATA_MEM_WRITE_REQUEST:begin
                address_to_mem [63:0] = address_from_cpu[63:0];
                write_request_to_mem = 1'b1;
                
                write_data_to_mem [63:0] = 64'h0;
                read_data_to_cpu [63:0] = 64'h0;
                size_select_to_mem [1:0] = size_select_from_cpu;
                read_request_to_mem = 1'b0;
                
                continue_to_cpu = 0;
                
                if(write_ready_from_mem == 1'b1) next_state [2:0] = DATA_MEM_WRITE_READY;
                else next_state [2:0] = DATA_MEM_WRITE_REQUEST;
            end
            DATA_MEM_WRITE_READY: begin
                write_data_to_mem [63:0] = write_data_from_cpu [63:0];
                address_to_mem [63:0] = address_from_cpu[63:0];
                
                read_data_to_cpu [63:0] = 64'h0;
                size_select_to_mem [1:0] = 2'b00;
                write_request_to_mem = 1'b1; // May have issues with the interaction between this and AXI
                read_request_to_mem = 1'b0;
                
                continue_to_cpu = 1;
                
                if(write_finished_from_mem == 1'b1) next_state [2:0] = DATA_MEM_IDLE;
                else next_state [2:0] = DATA_MEM_WRITE_READY;
            end
            DATA_MEM_EXCEPTION: begin
                
                write_data_to_mem [63:0] = 64'h0;
                read_data_to_cpu [63:0] = 64'h0;
                size_select_to_mem [1:0] = 2'b00;
                write_request_to_mem = 1'b0;
                read_request_to_mem = 1'b0;
                address_to_mem [63:0] = 64'h0;
                next_state [2:0] = DATA_MEM_IDLE;
                
                continue_to_cpu = 0;
            end
            
            default: begin
                write_data_to_mem [63:0] = 64'h0;
                read_data_to_cpu [63:0] = 64'h0;
                size_select_to_mem [1:0] = 2'b00;
                write_request_to_mem = 1'b0;
                read_request_to_mem = 1'b0;
                address_to_mem [63:0] = 64'h0;
                next_state [2:0] = DATA_MEM_IDLE;
                continue_to_cpu = 1;
            end
            
         endcase
        end
 
 
    always_ff @(posedge clk)
    begin
            current_state[2:0] <= next_state [2:0];
    end
    
    
endmodule

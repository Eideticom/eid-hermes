`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2020 02:23:17 PM
// Design Name: 
// Module Name: register_file
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

`include "exception.svh"

import global_exception::*;
import register_exception::*;

module register_file(
    input clk,
    input reset,
    input [3:0] dst,
    input [3:0] src,
    output logic [63:0] dstRead,
    output logic [63:0] srcRead,
    input logic [63:0] dstWrite,
    input writeEnable,
    output [1:0] registerExc
    );
    
    wire good_dst = dst < 10;
    wire good_src = src < 10;
    
    typedef logic [63:0] register;
    
    register [9:0] gprs;
    logic [3:0] last_dst;
    
    // read step    
    assign dstRead = good_dst ? gprs[dst] : 0;
    assign srcRead = good_src ? gprs[src] : 0;
    
    // write step
    always_ff @(posedge clk) begin
        if (writeEnable && good_dst)
            gprs[dst] <= dstWrite;
    end
    
    // exception
    assign registerExc = !good_dst ? INVALID_DST : !good_src ? INVALID_SRC : NO_EXCEPTION;
    
    
    //reset
    always @(reset)
    begin
        gprs[9:0] = 64'b0;
    end
endmodule
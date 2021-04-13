`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/26/2021 04:13:19 PM
// Design Name: 
// Module Name: LogicalControlUnit
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
`include "opcode.svh"
`include "jump_opcode.svh"
`include "alu_opcode.svh"
`include "memory_opcode.svh"


module LogicalControlUnit(
    input [7:0] opcode,
    input [1:0] byteSwapSelect,
    output reg regwrite,
    output reg memtoreg,
    output reg memwrite,
    output reg memread, 
    output reg writesrc,
    output reg dstSelect,
    output reg [1:0] immExtend,
    output reg [3:0] Branch,
    output reg [3:0] alucontrol,
    output reg [1:0] alusrca,
    output reg [1:0] alusrcb,
    output reg [1:0] datasize,
    output reg bit_32,
    // exception handling signals
    input clk,
    input excCaught,
    output [1:0] controlExc
    );
    
    const logic [7:0] LDDW_1 = 8'h18, LDDW_2 = 8'h00;
    const logic [7:0] EXIT = 8'h95, CALL = 8'h85;
    
    wire [2:0] opClass;
    wire [3:0] operation;
    wire immOrReg;
    wire LEorBE;
    wire [1:0] size;
    wire [2:0] mode;
    
    wire byteswap = (opClass == opcode_class::ALU32) && (operation == alu_opcode::BYTESWAP);
    wire load = (opClass == opcode_class::LD) || (opClass == opcode_class::LDX);
    wire store = (opClass == opcode_class::ST) || (opClass == opcode_class::STX);
    wire alu = (opClass == opcode_class::ALU32) || (opClass == opcode_class::ALU64);
    
    // LDDW state machine
    logic next_in_lddw = 0, in_lddw = 0;
    wire start_lddw = opcode == LDDW_1;
    wire end_lddw = opcode == LDDW_2;
    
    always @(posedge(clk)) begin
        if (start_lddw) begin // lddw first half
            in_lddw = 1;
        end 
        else if ((end_lddw && in_lddw) || opcode == EXIT ) begin
            in_lddw = 0;
        end
    end
    
    assign opClass = opcode[2:0];
    assign operation = opcode[7:4];
    assign immOrReg = opcode[3];
    assign LEorBE = opcode[3];
    assign size = opcode[4:3];
    assign mode = opcode[7:5];
    
    
    assign regwrite = alu || byteswap || load;
    // We want to write to reg in two cases:                               
    // 1. in any ALU result as well as byteswap
    // 2. in a load instruction 
    // In no other case will we be doing a reg write                                           
    
    assign memtoreg = (opClass == opcode_class::LDX);
    assign memwrite = store;
    assign memread = (opClass == opcode_class::LDX);
    assign writesrc = opClass == opcode_class::STX;
    assign dstSelect = end_lddw;
    assign immExtend = start_lddw ? 2'h1 : end_lddw ? 2'h2 : 0;
    assign Branch = opClass == opcode_class::JMP ? operation : jump_opcode::NO_JUMP;
    assign alucontrol = byteswap ?
                            (LEorBE ? alu_opcode::BE : alu_opcode::LE) :
                        start_lddw ?
                            alu_opcode::MOV :
                        end_lddw ?
                            alu_opcode::OR :
                        store || load ?
                            alu_opcode::ADD :
                            operation;                       
    
   
    assign alusrca = (alu || (opClass == opcode_class::JMP) || byteswap || store || end_lddw) ? 2'b1 : load ? 2'h2 : 0; // Added in opClass statement, since Alu src always be dst when it is a jump
    assign alusrcb =    (alu || opClass == opcode_class :: JMP) && !byteswap ?                       
                            {1'b0, immOrReg} :
                            store ?
                            2'h2 :
                            load && !(start_lddw || end_lddw) ? 2'h1 : 0;  // Current issue : Based on schematic 0 should select dstRead and 1 should select immExtended. This does not agree with the opcode, or this logic stated here
                                // ALU srcb added in the size because ALUsrcB depends on Size (Truthfully should be source vs. immediate for a jump
    
    
    
    assign datasize = size;
    assign bit_32 = (opClass == opcode_class::ALU32) && !(byteswap);
    
    
    // exception logic
    wire bad_opcode = (opcode == LDDW_2 && !in_lddw) || !recognized_opcode;
    
    reg recognized_opcode;
    always @(*) begin
        case (opcode)
            // ALU64 opcodes
            8'h07, 8'h0f, 8'h17, 8'h1f, 8'h27, 8'h2f, 8'h37, 8'h3f,
            8'h47, 8'h4f, 8'h57, 8'h5f, 8'h67, 8'h6f, 8'h77, 8'h7f,
            8'h87, 8'h8f, 8'h97, 8'h9f, 8'ha7, 8'haf, 8'hb7, 8'hbf,
            8'hc7, 8'hcf,
            
            // ALU32 opcodes
            8'h04, 8'h0c, 8'h14, 8'h1c, 8'h24, 8'h2c, 8'h34, 8'h3c,
            8'h44, 8'h4c, 8'h54, 8'h5c, 8'h64, 8'h6c, 8'h74, 8'h7c,
            8'h84, 8'h8c, 8'h94, 8'h9c, 8'ha4, 8'hac, 8'hb4, 8'hbc,
            8'hc4, 8'hcc,
            
            // Byteswap opcodes
            8'hd4, 8'hdc,
            
            // Memory opcodes
            8'h18, 8'h61, 8'h69, 8'h71, 8'h79, 8'h62, 8'h6a, 8'h72,
            8'h7a, 8'h63, 8'h6b, 8'h73, 8'h7b, 8'h00, // <-- LDDW_2
            
            // Jump opcodes
            8'h05,        8'h15, 8'h1d, 8'h25, 8'h2d, 8'h35, 8'h3d,
            8'h45, 8'h4d, 8'h55, 8'h5d, 8'h65, 8'h6d, 8'h75, 8'h7d,
            8'ha5, 8'had, 8'hb5, 8'hbd, 8'hc5, 8'hcd, 8'hd5, 8'hdd:
                recognized_opcode = 1;
            default: recognized_opcode = 0;
        endcase
    end

    assign controlExc = in_lddw && opcode != LDDW_2 ?
                control_exception::INCOMPLETE_LDDW :
                 opcode == EXIT ?
                control_exception::EXIT :
                bad_opcode ?
                control_exception::UNKNOWN_OPCODE :
                global_exception::NO_EXCEPTION ;
    
endmodule

`ifndef EXCEPTION_SVH
`define EXCEPTION_SVH

package ALU_exception;    
    // descriptor codes
    const logic [1:0] DIVISION_BY_ZERO = 2'b01, INVALID_ENDIAN_IMM = 2'b10, INVALID_SHIFT_IMM = 2'b11;
endpackage

package register_exception;    
    // descriptor codes
    const logic [1:0] INVALID_DST = 2'b01, INVALID_SRC = 2'b10;
endpackage

package control_exception;    
    // descriptor codes
    const logic [1:0] UNKNOWN_OPCODE = 2'b01, INCOMPLETE_LDDW = 2'b10, EXIT = 2'b11;
endpackage

package data_memory_exception;    
    // descriptor codes
    const logic [1:0] OUT_OF_BOUNDS_STORE = 2'b01, OUT_OF_BOUNDS_READ = 2'b10;
endpackage

package instruction_memory_exception;   
    // descriptor codes
    const logic [1:0] OUT_OF_BOUNDS = 2'b01, MIDDLE_OF_LDDW = 2'b10;
endpackage

package global_exception;
    // class codes
    const logic [2:0] NO_CLASS = 3'b000;
    const logic [2:0] ALU_CLASS = 3'b001;
    const logic [2:0] REGISTER_CLASS = 3'b010;
    const logic [2:0] CONTROL_CLASS = 3'b011;
    const logic [2:0] DATA_MEMORY_CLASS = 3'b101;
    const logic [2:0] INSTRUCTION_MEMORY_CLASS = 3'b110;
    // descriptor codes
    const logic [1:0] NO_EXCEPTION = 2'b00;
endpackage

`endif
`ifndef MEMORY_OPCODE_SVH
`define MEMORY_OPCODE_SVH

package memory_mode;

const logic [2:0]
	MEM = 3'h6,
	IMM = 3'h0;

endpackage

package data_size;

const logic [1:0]
	W  = 2'h0,
	H  = 2'h1,
	B  = 2'h2,
	DW = 2'h3;

endpackage

`endif
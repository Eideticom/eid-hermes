`ifndef OPCODE_SVH
`define OPCODE_SVH

package opcode_class;

const logic [2:0]
	LD    = 3'h0,
	LDX   = 3'h1,
	ST    = 3'h2,
	STX   = 3'h3,
	ALU32 = 3'h4,
	JMP   = 3'h5,
	ALU64 = 3'h7;

endpackage

`endif
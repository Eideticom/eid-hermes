`ifndef JUMP_OPCODE_SVH
`define JUMP_OPCODE_SVH

package jump_opcode;

const logic [3:0]
    NO_JUMP = 4'hf,
	JA   = 4'h0,
	JEQ  = 4'h1,
	JGT  = 4'h2,
	JGE  = 4'h3,
	JSET = 4'h4,
	JNE  = 4'h5,
	JSGT = 4'h6,
	JSGE = 4'h7,
	CALL = 4'h8,
	EXIT = 4'h9,
	JLT  = 4'ha,
	JLE  = 4'hb,
	JSLT = 4'hc,
	JSLE = 4'hd;

endpackage

`endif
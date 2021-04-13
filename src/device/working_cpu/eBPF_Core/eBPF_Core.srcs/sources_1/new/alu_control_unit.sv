`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/26/2020 09:30:51 PM
// Design Name: 
// Module Name: alu_control_unit
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

`include "alu_control.svh"

module alu_control_unit(
    input ALUcontrol_s ALUcontrol,
    output logic bits32,
    output op_e op,
    output logic le,
    output logic mod,
    output logic sub
    );
    
    assign mod = ALUcontrol.op == MOD;
    assign sub = ALUcontrol.op == SUB;
    assign le = ALUcontrol.op == LE;
    assign op = ALUcontrol.op;
    assign bits32 = ALUcontrol.bits32;

endmodule

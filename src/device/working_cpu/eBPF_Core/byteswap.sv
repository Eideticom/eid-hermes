`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Felipe Cupido
// 
// Create Date: 11/14/2020 02:10:06 PM
// Design Name: 
// Module Name: byteswap
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      Byteswap changes the order of bytes so that the output is either in Big Endian (BE) or Little Endian (LE) ordering.
//      If ALUControl is 0xD then the output is to be in LE ordering. Since our system uses LE by default, this requires no change
//      If the ALUControl is 0xE then the output is to be BE. So we reverse the order of our bytes. Note that the bits within any given byte 
//          remain in the same order relative to each other.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module byteswap64(
    input [63:0] src,
    input [63:0] imm,
    output reg [63:0] dst,
    input [3:0] ALUControl
    );
    
    always @(*) begin
    case (imm)
      64'd16: 
           dst = (ALUControl == 4'hd)? src : {48'b0, src[7:0], src[15:8]};
      64'd32: 
           dst = (ALUControl == 4'hd)? src : {32'b0, src[7:0], src[15:8], src[23:16], src[31:24]};  
      64'd64: 
           dst = (ALUControl == 4'hd)? src : {src[7:0], src[15:8], src[23:16], src[31:24], src[39:32], src[47:40], src[55:48], src[63:56]};
      default: ;// Exception
    endcase
    end
endmodule

module byteswap32(
    input [31:0] src,
    input [31:0] imm,
    output reg [31:0] dst,
    input [3:0] ALUControl
    );
    
    always @(*) begin
    case (imm)
      64'd16: 
           dst = (ALUControl == 4'hd)? src : {16'b0, src[7:0], src[15:8]};
      64'd32: 
           dst = (ALUControl == 4'hd)? src : {src[7:0], src[15:8], src[23:16], src[31:24]};  
      default: ;// Exception
    endcase
    end
endmodule


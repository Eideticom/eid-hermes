`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2020 02:40:27 PM
// Design Name: 
// Module Name: jump_comparator
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

module  jump_comparator(
    input [63:0] a,
    input [63:0] b,
    input [3:0] op,
    output reg jump
    );
    
    always @(a, b, op) begin
        case(op) inside
            4'h0: jump = '1;
            4'h1: jump = a == b;
            4'h2: jump = a > b;
            4'h3: jump = a >= b;
            4'h4: jump = | (a & b);
            4'h5: jump = a != b;
            4'h6: jump = $signed(a) > $signed(b);
            4'h7: jump = $signed(a) >= $signed(b);
            //
            //
            4'ha: jump = a < b;
            4'hb: jump = a <= b; // Why is this the lte operator??
            4'hc: jump = $signed(a) < $signed(b);
            4'hd: jump = $signed(a) <= $signed(b);
            default: jump <= '0;
        endcase
    end

endmodule

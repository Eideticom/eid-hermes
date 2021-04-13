`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/14/2021 04:47:04 PM
// Design Name: 
// Module Name: tb_rightZeroPad
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


module tb_rightZeroPad;

    reg [31:0] a;
    wire [63:0] out;
    
    localparam period = 20; 
    reg clk;

    ThirtyTwoBitRightPad UUT(.a(a), .out(out));
    
    always 
    begin
        clk = 1'b1; 
        #20; // high for 20 * timescale = 20 ns
    
        clk = 1'b0;
        #20; // low for 20 * timescale = 20 ns
    end
    
    always @(posedge clk)
    begin
    
        a = 32'b0;
        #period;
        
        if  (out != 64'b0)
            $display("Test failed for input 32'b0");
        
        a = {32{1'b1}};
        #period;
        
        if (out != { {32{1'b1}}, {32{1'b0}} })
            $display("Test failed for input 32'b1");
    
        a = { {8{1'b1}}, {8{1'b0}}, {8{1'b0}}, {8{1'b1}} };
        #period;
        
        if (out != { {8{1'b1}}, {8{1'b0}}, {8{1'b0}}, {8{1'b1}}, {32{1'b0}} })
            $display("Test failed for input 0xff0000ff");
    
        $stop;
    
    end

endmodule

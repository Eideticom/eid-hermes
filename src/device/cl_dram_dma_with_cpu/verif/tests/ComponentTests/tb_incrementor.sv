`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2020 02:54:18 PM
// Design Name: 
// Module Name: tb_incrementor
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


module tb_incrementor(

    );
    
    incrementor UUT(in_address, out_address);
    
    logic [31:0] in_address, out_address;
    logic clk;
    
    initial begin
        // some tests
        in_address = '0;
        clk = '1;
        #20
        in_address = 32'hf0f0f0f0;
        #20
        in_address = '1;
        #20
        $finish;
    end
    
    always begin
        #20
        clk = ~clk;
    end
    
endmodule

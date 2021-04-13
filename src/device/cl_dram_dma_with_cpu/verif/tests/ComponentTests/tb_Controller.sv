`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/19/2021 02:15:02 PM
// Design Name: 
// Module Name: MemoryTest
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


module tb_Controller();

    reg reset_test; 
    reg [63:0] DMTop_test;
    reg [63:0] DMBottom_test;     
    reg [63:0] IMBottom_test;
    reg [63:0] IMTop_test; 
    reg continue_val_test; 
    Controller uut(.reset(reset_test), .DMTop(DMTop_test),.DMBottom(DMBottom_test),.IMBottom(IMBottom_test),.IMTop(IMTop_test),.continue_val(continue_val_test)); 
    
    initial begin
    
        $display("TEST START");
        if (reset_test != 1'b0) $display("TEST FAILED RESET");
        else $display("RESET PASSED");
        
        if(DMTop_test != 64'h000f_ffff_ffff) $display("TEST FAILED DMTOP");
        else $display("DMTOP PASSED");
        
        if(DMBottom_test != 64'h0008_0000_0000) $display("TEST FAILED DMBOTTOM");
        else $display("DMBOTTOM PASSED");
        
        if(IMBottom_test != 64'h0000_0000_0000) $display("TEST FAILED IMBOTTOM");
        else $display("IMBOTTOM PASSED");
        
        if(IMTop_test != 64'h0007_ffff_ffff) $display("TEST FAILED IMTOP");
        else $display("IMTOP PASSED");
        
        if(continue_val_test != 1'b1) $display("TEST FAILED CONTINUE_VAL");
        else $display("CONTINUE_VAL PASSED");
        
        $display("TEST COMPLETED");
    end
    
endmodule

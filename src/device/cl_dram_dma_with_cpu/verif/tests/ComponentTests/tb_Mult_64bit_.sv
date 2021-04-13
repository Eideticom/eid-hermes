`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2020 09:07:54 PM
// Design Name: 
// Module Name: tb_Mult_64bit
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

`include "constants.svh";

module tb_Mult_64bit;

    //*Setup wires, vectors, signals etc. that will be used in the test
    longint a, b; // longint is a signed 64 bit value
    longlongint result; // longlongint is a signed 128 bit value
    logic mismatch;
    
    // inputs and outputs to test
    const longint MAXLONGINT = 64'd9223372036854775807; // update
    const longint MINLONGINT = ~MAXLONGINT; // update
    
    const longint a_tests[5:0] = '{4, 0, MINLONGINT, MAXLONGINT, MINLONGINT, MAXLONGINT};
    const longint b_tests[5:0] = '{6, -1, MINLONGINT, MINLONGINT, MAXLONGINT, MAXLONGINT};
    const longlongint expected_results[5:0] = '{24, 0, MINLONGINT*MINLONGINT, MAXLONGINT*MINLONGINT, MAXLONGINT*MINLONGINT, MAXLONGINT*MAXLONGINT};
    
    //*Setup the components which will be tested
    Mult_64bit UUT(.a(a), .b(b), .y(result));
    
    initial begin
        assert ($size(a_tests) == $size(b_tests) && $size(a_tests) == $size(expected_results));
        for (int i = 0; i < $size(a_tests); i++) begin
            a <= a_tests[i];
            b <= b_tests[i];
            #5
            mismatch <= result != expected_results[i];
            #15
            if (mismatch) begin
                $display("test failed for a=%d and b=%d", a, b);
                $display("expected %d, got %d", expected_results[i], result);
            end
        end
        $finish;
    end

    //Consider test implementation within the context of continuous integration testing. 
    
endmodule

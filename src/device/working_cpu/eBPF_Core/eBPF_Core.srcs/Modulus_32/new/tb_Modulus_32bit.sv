`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Spencer Comin
// 
// Create Date: 11/30/2020 2:22:54 PM
// Design Name: 
// Module Name: tb_Modulus_32bit
// Project Name: Hermes
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

module tb_Modulus_32bit;

    //*Setup wires, vectors, signals etc. that will be used in the test
    int a, b; // int is a signed 32 bit value
    int result; // int is a signed 32 bit value
    logic mismatch;
    
    // inputs and outputs to test
    const int MAXINT = 2147483647; // update
    const int MININT = ~MAXINT; // update
    
    const int a_tests[6:0] = '{15, 0, -1, MININT, MAXINT, MININT, MAXINT};
    const int b_tests[6:0] = '{-3, 9, -18, MININT, MININT, MAXINT, MAXINT};
    // expected results to match c program compiled with clang on macOS 11.0.1 with 1.6 GHz Dual-Core Intel Core i5 processor
    const int expected_results[6:0] = '{0, 0, -1, 0, MAXINT, -1, 0};
    
    //*Setup the components which will be tested
    Modulus_32bit UUT(.a(a), .b(b), .c(result));
    
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

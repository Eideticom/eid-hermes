`timescale 1ns / 1ps //Timescale used to specify what a "Time unit" is. timescale 1ns / 1ps = 1ns time unit with 1 ps precision. #20 = 20 time units = 20 ns


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Spencer Comin
// 
// Create Date: 12/01/2020 11:36:30 AM
// Design Name: 
// Module Name: tb_Adder_32bit
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


module tb_Adder_32bit;
    //*Setup wires, vectors, signals etc. that will be used in the test
    int a, b; // int is a signed 32 bit value
    logic sub;
    int result; // int is a signed 32 bit value
    logic mismatch;
    
    // inputs and outputs to test
    const int MAXINT = 2147483647; // update
    const int MININT = ~MAXINT; // update
    
    const int a_tests[6:0] = '{15, 0, -1, MININT, MAXINT, MININT, MAXINT};
    const int b_tests[6:0] = '{-3, 9, -18, MININT, MININT, MAXINT, MAXINT};
    // expected results to match c program compiled with clang on macOS 11.0.1 with 1.6 GHz Dual-Core Intel Core i5 processor
    const int expected_sums[6:0] = '{12, 9, -19, 0, -1, -1, -2};
    const int expected_differences[6:0] = '{18, -9, 17, 0, -1, 1, 0};
    
    //*Setup the components which will be tested
    Adder_Subtractor_32bit UUT(.a(a), .b(b), .sum(result), .sub(sub));
    
    initial begin
        assert ($size(a_tests) == $size(b_tests) &&
                $size(a_tests) == $size(expected_sums) &&
                $size(a_tests) == $size(expected_differences));
        // Addition tests
        sub = 1'b0;
        for (int i = 0; i < $size(a_tests); i++) begin
            a <= a_tests[i];
            b <= b_tests[i];
            #5
            mismatch <= result != expected_sums[i];
            #15
            if (mismatch) begin
                $display("addition test failed for a=%d and b=%d", a, b);
                $display("expected %d, got %d", expected_sums[i], result);
            end
        end
        // Subtraction tests
        sub = 1'b1;
        for (int i = 0; i < $size(a_tests); i++) begin
            a <= a_tests[i];
            b <= b_tests[i];
            #5
            mismatch <= result != expected_differences[i];
            #15
            if (mismatch) begin
                $display("subtraction test failed for a=%d and b=%d", a, b);
                $display("expected %d, got %d", expected_sums[i], result);
            end
        end
        $finish;
    end 
    
endmodule

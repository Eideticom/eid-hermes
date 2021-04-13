`timescale 1ns / 1ps //Timescale used to specify what a "Time unit" is. timescale 1ns / 1ps = 1ns time unit with 1 ps precision. #20 = 20 time units = 20 ns


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Spencer Comin
// 
// Create Date: 12/01/2020 1:40:30 PM
// Design Name: 
// Module Name: tb_Adder_64bit
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


module tb_Adder_64bit;
    //*Setup wires, vectors, signals etc. that will be used in the test
    longint a, b; // longint is a signed 64 bit value
    longint sum, diff; // longint is a signed 64 bit value
    logic sum_mismatch, diff_mismatch;
    
    // inputs and outputs to test
    const longint MAXLONGINT = 64'd9223372036854775807; // update
    const longint MINLONGINT = ~MAXLONGINT; // update
    
    const longint a_tests[6:0] = '{15, 0, -1, MINLONGINT, MAXLONGINT, MINLONGINT, MAXLONGINT};
    const longint b_tests[6:0] = '{-3, 9, -18, MINLONGINT, MINLONGINT, MAXLONGINT, MAXLONGINT};
    // expected results to match c program compiled with clang on macOS 11.0.1 with 1.6 GHz Dual-Core Intel Core i5 processor
    const longint expected_sums[6:0] = '{12, 9, -19, 0, -1, -1, -2};
    const longint expected_differences[6:0] = '{18, -9, 17, 0, -1, 1, 0};
    
    //*Setup the components which will be tested
    Hardware_Subtractor_64bit UUT_sub(.a(a), .b(b), .c(diff));
    Hardware_Adder_64bit UUT_add(.a(a), .b(b), .c(sum));
    
    
    initial begin
        assert ($size(a_tests) == $size(b_tests) &&
                $size(a_tests) == $size(expected_sums) &&
                $size(a_tests) == $size(expected_differences));
        for (int i = 0; i < $size(a_tests); i++) begin
            a <= a_tests[i];
            b <= b_tests[i];
            #5
            sum_mismatch <= sum != expected_sums[i];
            diff_mismatch <= diff != expected_differences[i];
            #15
            if (sum_mismatch) begin
                $display("addition test failed for a=%d and b=%d", a, b);
                $display("expected %d, got %d", expected_sums[i], sum);
            end
            if (diff_mismatch) begin
                $display("subtraction test failed for a=%d and b=%d", a, b);
                $display("expected %d, got %d", expected_differences[i], diff);
            end
        end
        $finish;
    end 
    
endmodule

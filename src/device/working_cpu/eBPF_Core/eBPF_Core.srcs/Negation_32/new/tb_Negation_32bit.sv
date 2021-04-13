`timescale 1ns / 1ps //Timescale used to specify what a "Time unit" is. timescale 1ns / 1ps = 1ns time unit with 1 ps precision. #20 = 20 time units = 20 ns


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Spencer Comin
// 
// Create Date: 12/26/2020 2:40:00 PM
// Design Name: 
// Module Name: tb_Negation_32bit
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


module tb_Negation_32bit;
    //*Setup wires, vectors, signals etc. that will be used in the test
    int a; // int is a signed 32 bit value
    int result; // int is a signed 32 bit value
    logic mismatch;
    
    // inputs and outputs to test
    const int MAXINT = 2147483647; // update
    const int MININT = ~MAXINT; // update
    
    const int a_tests[6:0] = '{15, 0, -1, MININT, MAXINT, MININT, MAXINT};
    // expected results to match c program compiled with clang on macOS 11.0.1 with 1.6 GHz Dual-Core Intel Core i5 processor
    const int expected_results[6:0] = '{-15, 0, 1, -2147483648, -2147483647, -2147483648, -2147483647};
    
    //*Setup the components which will be tested
    Negation_32bit UUT(.a(a), .c(result));
    
    initial begin
        assert ($size(a_tests) == $size(expected_results));
        // Addition tests
        for (int i = 0; i < $size(a_tests); i++) begin
            a <= a_tests[i];
            #5
            mismatch <= result != expected_results[i];
            #15
            if (mismatch) begin
                $display("addition test failed for a=%d", a);
                $display("expected %d, got %d", expected_results[i], result);
            end
        end
        $finish;
    end 
    
endmodule

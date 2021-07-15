`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2020 10:50:12 AM
// Design Name: 
// Module Name: tb_Mult_32bit
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


module tb_Mult_32bit;

    //*Setup wires, vectors, signals etc. that will be used in the test
    int a, b; // int is a signed 32 bit value
    longint result; // longint is a signed 64 bit value
    logic mismatch;
    
    // inputs and outputs to test
    const int MAXINT = 2147483647;
    const int MININT = -2147483648;
    
    const int a_tests[5:0] = '{4, 0, MININT, MAXINT, MININT, MAXINT};
    const int b_tests[5:0] = '{6, -1, MININT, MININT, MAXINT, MAXINT};
    const longint expected_results[5:0] = '{24, 0, MININT*MININT, MAXINT*MININT, MAXINT*MININT, MAXINT*MAXINT};
    
    //*Setup the components which will be tested
    Mult_32bit UUT(.a(a), .b(b), .y(result));
    
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

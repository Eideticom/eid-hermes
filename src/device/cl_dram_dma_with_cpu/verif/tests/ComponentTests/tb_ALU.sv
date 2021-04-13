`timescale 1ns / 1ps //Timescale used to specify what a "Time unit" is. timescale 1ns / 1ps = 1ns time unit with 1 ps precision. #20 = 20 time units = 20 ns


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Spencer Comin
// 
// Create Date: 01/11/2021 09:56:00 AM
// Design Name: 
// Module Name: tb_ALU
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

//`include "alu_opcode.svh"
//`include "alu_control.svh"


module tb_ALU;
    //Useful guide : https://verilogguide.readthedocs.io/en/latest/verilog/testbench.html

    //*Setup wires, vectors, signals etc. that will be used in the test
    logic [3:0] ALUControl;
    logic is32Bit;
    longint a;
    longint b;
    longint result;
    
    logic mismatch;
    
    // constants for tests
    const longint MAXLONGINT = 64'd9223372036854775807;
    const longint MINLONGINT = ~MAXLONGINT;
    const int MAXINT = 32'd2147483647;
    const int MININT = ~MAXINT;
    
    const longint a_64bit_tests[6:0] = '{15, 0, -1, MINLONGINT, MAXLONGINT, MINLONGINT, MAXLONGINT};
    const longint b_64bit_tests[6:0] = '{-3, 9, -18, MINLONGINT, MINLONGINT, MAXLONGINT, MAXLONGINT};
    const longint b_64bit_shift_tests[6:0] = '{0, 1, 5, 32, 50, 63, 65};
    
    const int a_32bit_tests[6:0] = '{15, 0, -1, MININT, MAXINT, MININT, MAXINT};
    const int b_32bit_tests[6:0] = '{-3, 9, -18, MININT, MININT, MAXINT, MAXINT};
    const int b_32bit_shift_tests[6:0] = '{0, 1, 5, 16, 24, 31, 33};

    
    /*
    << 32 BIT: {15, 0, -32, 0, -16777216, 0, -2, }
    << 64 BIT: {15, 0, -32, 0, -1125899906842624, 0, -2, }
    >> 32 BIT: {15, 0, 134217727, 32768, 127, 1, 1073741823, }
    >> 64 BIT: {15, 0, 576460752303423487, 2147483648, 8191, 1, 4611686018427387903, }
    % 32 BIT: {0, 0, -1, 0, 2147483647, -1, 0, }
    % 64 BIT: {0, 0, -1, 0, 9223372036854775807, -1, 0, }
    ^ 32 BIT: {-14, 9, 17, 0, -1, -1, 0, }
    ^ 64 BIT: {-14, 9, 17, 0, -1, -1, 0, }
    >>> 32 BIT: {15, 0, 0, -32768, 127, -1, 0, }
    >>> 64 BIT: {15, 0, 0, -2147483648, 8191, -1, 0, }
    LE 16: {15, 0, 65535, 0, 65535, 0, 65535, }
    LE 32: {15, 0, 4294967295, 0, 4294967295, 0, 4294967295, }
    LE 64: {15, 0, -1, -9223372036854775808, 9223372036854775807, -9223372036854775808, 9223372036854775807, }
    BE 16: {3840, 0, 65535, 0, 65535, 0, 65535, }
    BE 32: {251658240, 0, 4294967295, 0, 4294967295, 0, 4294967295, }
    BE 64: {1080863910568919040, 0, -1, 128, -129, 128, -129, }
    */
    
    // expected results
    const longint expected_64bit_sums[6:0]          = '{12, 9, -19, 0, -1, -1, -2};
    const longint expected_64bit_differences[6:0]   = '{18, -9, 17, 0, -1, 1, 0};
    const longint expected_64bit_negations[6:0]     = '{-15, 0, 1, MINLONGINT, -MAXLONGINT, MINLONGINT, -MAXLONGINT};
    const longint expected_64bit_modulos[6:0]       = '{0, 0, -1, 0, MAXLONGINT, -1, 0};
    const longint expected_64bit_divisions[6:0]     = '{-5, 0, 0, 1, 0, -1, 1};
    const longint expected_64bit_products[6:0]      = '{-45, 0, 18, 0, -64'd9223372036854775808, -64'd9223372036854775808, 1};
    const longint expected_64bit_OR[6:0]            = '{-1, 9, -1, -64'd9223372036854775808, -1, -1, 64'd9223372036854775807};
    const longint expected_64bit_AND[6:0]           = '{13, 0, -18, -64'd9223372036854775808, 0, 0, 64'd9223372036854775807};
    const longint expected_64bit_XOR[6:0]           = '{-14, 9, 17, 0, -1, -1, 0};
    const longint expected_64bit_leftshifts[6:0]    = '{15, 0, -32, 0, -64'd1125899906842624, 0, -2};
    const longint expected_64bit_lrightshifts[6:0]  = '{15, 0, 64'd576460752303423487, 64'd2147483648, 8191, 1, 64'd4611686018427387903};
    const longint expected_64bit_arightshifts[6:0]  = '{15, 0, 0, -64'd2147483648, 8191, -1, 0};


    const int expected_32bit_sums[6:0]           = '{12, 9, -19, 0, -1, -1, -2};
    const int expected_32bit_differences[6:0]    = '{18, -9, 17, 0, -1, 1, 0};
    const int expected_32bit_negations[6:0]      = '{-15, 0, 1, MININT, -MAXINT, MININT, -MAXINT};
    const int expected_32bit_modulos[6:0]        = '{0, 0, -1, 0, MAXINT, -1, 0};
    const int expected_32bit_divisions[6:0]       = '{-5, 0, 0, 1, 0, -1, 1};
    const int expected_32bit_products[6:0]       = '{-45, 0, 18, 0, -32'd2147483648, -32'd2147483648, 1};
    const int expected_32bit_OR[6:0]             = '{-1, 9, -1, -32'd2147483648, -1, -1, 32'd2147483647};
    const int expected_32bit_AND[6:0]            = '{13, 0, -18, -32'd2147483648, 0, 0, 32'd2147483647};
    const int expected_32bit_XOR[6:0]            = '{-14, 9, 17, 0, -1, -1, 0};
    const int expected_32bit_leftshifts[6:0]     = '{15, 0, -32, 0, -16777216, 0, -2};
    const int expected_32bit_lrightshifts[6:0]   = '{15, 0, 134217727, 32768, 127, 1, 1073741823};
    const int expected_32bit_arightshifts[6:0]   = '{15, 0, 0, -32768, 127, -1, 0};
    
    
    const longint expected_LE16[6:0] ='{15, 0, 65535, 0, 65535, 0, 65535};
    const longint expected_LE32[6:0] ='{15, 0, 64'd4294967295, 0, 64'd4294967295, 0, 64'd4294967295};
    const longint expected_LE64[6:0] ='{15, 0, -1, -64'd9223372036854775808, 64'd9223372036854775807, -64'd9223372036854775808, 64'd9223372036854775807};
    const longint expected_BE16[6:0] ='{3840, 0, 65535, 0, 65535, 0, 65535};
    const longint expected_BE32[6:0] ='{64'd251658240, 0, 64'd4294967295, 0, 64'd4294967295, 0, 64'd4294967295};
    const longint expected_BE64[6:0] ='{64'd1080863910568919040, 0, -1, 128, -129, 128, -129};

  	ALU UUT(.ALUControl(ALUControl),
  	        .operandA(a),
  	        .operandB(b),
  	        .is32Bit(is32Bit),
  	        .ALUResult(result));
  	        
  	// helper tasks
  	task verify_results_64(input string testname, input longint expected[6:0]);
  	     for (int i = 0; i < $size(a_64bit_tests); i++) begin
            a <= a_64bit_tests[i];
            b <= b_64bit_tests[i];
            #5
            mismatch <= result != expected[i];
            #15
            if (mismatch) begin
                $display("64 bit %s test failed for a=%d and b=%d", testname, a, b);
                $display("expected %d, got %d", expected[i], result);
            end
         end
  	endtask
  	
  	task verify_results_32(input string testname, input int expected[6:0]);
  	     for (int i = 0; i < $size(a_32bit_tests); i++) begin
            a <= {32'b0, a_32bit_tests[i]};
            b <= {32'b0, b_32bit_tests[i]};
            #5
            mismatch <= result[31:0] != expected[i];
            #15
            if (mismatch) begin
                $display("32 bit %s test failed for a=%d and b=%d", testname, a, b);
                $display("expected %d, got %d", expected[i], result);
            end
         end
  	endtask
  	
  	task verify_shift_32(input string testname, input int expected[6:0]);
  	     for (int i = 0; i < $size(a_32bit_tests); i++) begin
            a <= {32'b0, a_32bit_tests[i]};
            b <= {32'b0, b_32bit_shift_tests[i]};
            #5
            mismatch <= result[31:0] != expected[i];
            #15
            if (mismatch) begin
                $display("32 bit %s test failed for a=%d and b=%d", testname, a, b);
                $display("expected %d, got %d", expected[i], result);
            end
         end
  	endtask
  	
  	task verify_shift_64(input string testname, input longint expected[6:0]);
  	     for (int i = 0; i < $size(a_64bit_tests); i++) begin
            a <= a_64bit_tests[i];
            b <= b_64bit_shift_tests[i];
            #5
            mismatch <= result != expected[i];
            #15
            if (mismatch) begin
                $display("64 bit %s test failed for a=%d and b=%d", testname, a, b);
                $display("expected %d, got %d", expected[i], result);
            end
         end
  	endtask
  	
    initial begin
  	
         //64 bit tests
         is32Bit = 0;
         //addition
         ALUControl = 4'h0;
         verify_results_64("addition", expected_64bit_sums);
         //subtraction
         ALUControl = 4'h1;
         verify_results_64("subtraction", expected_64bit_differences);
         //multiplication
         ALUControl = 4'h2;
         verify_results_64("multiplication", expected_64bit_products);
         //division
         ALUControl = 4'h3;
         verify_results_64("division", expected_64bit_divisions);
         //or
         ALUControl = 4'h4;
         verify_results_64("OR", expected_64bit_OR);
         //and
         ALUControl = 4'h5;
         verify_results_64("AND", expected_64bit_AND);
         //lsh
         ALUControl = 4'h6;
         verify_shift_64("left shift", expected_64bit_leftshifts);
         //rsh
         ALUControl = 4'h7;
         verify_shift_64("logic right shift", expected_64bit_lrightshifts);
         //neg
         ALUControl = 4'h8;
         verify_results_64("negation", expected_64bit_negations);
         //mod
         ALUControl = 4'h9;
         verify_results_64("modulus", expected_64bit_modulos);
         //xor
         ALUControl = 4'ha;
         verify_results_64("XOR", expected_64bit_XOR);
         //move
         ALUControl = 4'hb;
         verify_results_64("move", a_64bit_tests);
         //arsh
         ALUControl = 4'hc;
         verify_shift_64("arithmetic right shift", expected_64bit_arightshifts);
         //le
         ALUControl = 4'hd;
         for (int i = 0; i < $size(a_64bit_tests); i++) begin
            a <= a_64bit_tests[i];
            b <= 64'd16;
            #5
            mismatch <= result != expected_LE16[i];
            #15
            if (mismatch) begin
                $display("LE 16 byteswap test failed for a=%d and b=%d", a, b);
                $display("expected %d, got %d", expected_LE16[i], result);
            end
            b <= 64'd32;
            #5
            mismatch <= result != expected_LE32[i];
            #15
            if (mismatch) begin
                $display("LE 32 byteswap test failed for a=%d and b=%d", a, b);
                $display("expected %d, got %d", expected_LE32[i], result);
            end
            b <= 64'd64;
            #5
            mismatch <= result != expected_LE64[i];
            #15
            if (mismatch) begin
                $display("LE 64 byteswap test failed for a=%d and b=%d", a, b);
                $display("expected %d, got %d", expected_LE64[i], result);
            end
         end
         //be
         ALUControl = 4'he;
         for (int i = 0; i < $size(a_64bit_tests); i++) begin
            a <= a_64bit_tests[i];
            b <= 64'd16;
            #5
            mismatch <= result != expected_BE16[i];
            #15
            if (mismatch) begin
                $display("BE 16 byteswap test failed for a=%d and b=%d", a, b);
                $display("expected %d, got %d", expected_BE16[i], result);
            end
            b <= 64'd32;
            #5
            mismatch <= result != expected_BE32[i];
            #15
            if (mismatch) begin
                $display("BE 32 byteswap test failed for a=%d and b=%d", a, b);
                $display("expected %d, got %d", expected_BE32[i], result);
            end
            b <= 64'd64;
            #5
            mismatch <= result != expected_BE64[i];
            #15
            if (mismatch) begin
                $display("BE 64 byteswap test failed for a=%d and b=%d", a, b);
                $display("expected %d, got %d", expected_BE64[i], result);
            end
         end
         
         //32 bit tests
         is32Bit = 1;
         //addition
         ALUControl = 4'h0;
         verify_results_32("addition", expected_32bit_sums);
         //subtraction
         ALUControl = 4'h1;
         verify_results_32("subtraction", expected_32bit_differences);
         //multiplication
         ALUControl = 4'h2;
         verify_results_32("multiplication", expected_32bit_products);
         //division
         ALUControl = 4'h3;
         verify_results_32("division", expected_32bit_divisions);
         //or
         ALUControl = 4'h4;
         verify_results_32("OR", expected_32bit_OR);
         //and
         ALUControl = 4'h5;
         verify_results_32("AND", expected_32bit_AND);
         //lsh
         ALUControl = 4'h6;
         verify_shift_32("left shift", expected_32bit_leftshifts);
         //rsh
         ALUControl = 4'h7;
         verify_shift_32("logic right shift", expected_32bit_lrightshifts);
         //neg
         ALUControl = 4'h8;
         verify_results_32("negation", expected_32bit_negations);
         //mod
         ALUControl = 4'h9;
         verify_results_32("modulus", expected_32bit_modulos);
         //xor
         ALUControl = 4'ha;
         verify_results_32("XOR", expected_32bit_XOR);
         //move
         ALUControl = 4'hb;
         verify_results_32("move", a_32bit_tests);
         //arsh
         ALUControl = 4'hc;
         verify_shift_32("arithmetic right shift", expected_32bit_arightshifts);
  	end

    //Consider test implementation within the context of continuous integration testing. 
    
endmodule

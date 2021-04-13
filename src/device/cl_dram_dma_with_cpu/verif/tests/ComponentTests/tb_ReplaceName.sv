`timescale 1ns / 1ps //Timescale used to specify what a "Time unit" is. timescale 1ns / 1ps = 1ns time unit with 1 ps precision. #20 = 20 time units = 20 ns


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2020 04:01:30 PM
// Design Name: 
// Module Name: tb_Adder_1bit
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


module tb_ReplaceName;
    //Useful guide : https://verilogguide.readthedocs.io/en/latest/verilog/testbench.html

    //*Setup wires, vectors, signals etc. that will be used in the test
    reg a,b; //Example : define the inputs which will be passed into UUT and will be manipulated during test
    wire result1, result2; //Example : define the outputs which will be passed into UUT and will be observed during testing
    
    //*Setup the components which will be tested
    //MyModule UUT (.input(in),.output(out)) Note: UUT "unit under test" is standard naming convention for instantiated test component
    
    //**INITIAL BLOCK**//
    //initial begin
    //
    //Initial statement is executed once in a simulation, and is initiated at t=0. The commands in the initial block
    //are executed sequentially. The initial block runs in parallel to other initial statements or computations. You
    //can specify 0 to many initial blocks in a simulation. The primary purpose of the initial block is to initialize 
    //any variables, signals, or ports. The initial block may also be used with delays (e.g. #20) to perform tests where
    //inputs are changes sequentially according to these delays.See below. Initial blocks are not synthesizable in hardware and therefore
    //are intended for simulations. 
    //
    //$finish can be specified at the end to terminate the session regardless of whatever else is running. 
    //
    //end
    //**INITIAL BLOCK END**//
    
    //**CLOCK**//
    reg clk; //Clock signal used in synchronizing the test
    localparam clock_half_period = 20; //Define the period of the clock in number of time units. 2*clock_half_period = clock_period
    //Generate clock signal
    always @(*) begin
        clk = 1'b1; //1
        #clock_half_period;
        clk = 1'b0; //0
        #clock_half_period;
    end
    //**END CLOCK**//
    
    //For testing, may be useful to use a vector of inputs and expected outputs. 
    
    //**SYNCHRONOUS ALWAYS BLOCK**//
    always @(posedge clk)
        begin
        	//This is one option. 
            //Vary inputs specified above with clock signal and/or delays. Consider all possible
            //combinations of inputs and verify that it matches the expected output. Perhaps
            //plot the expected waveform. This can be done by defining an expected_output wire
            //and assigning the desired output value to this. Display message, when an error occurs e.g. using $display. 
        end
   //**SYNCHRONOUS ALWAYS BLOCK END**//

   //**COMBINATIONAL ALWAYS BLOCK**//
   always @(*)
   		begin
   			//This is one option. 
            //Vary inputs specified above using delays. Consider all possible
            //combinations of inputs and verify that it matches the expected output. Perhaps
            //plot the expected waveform. This can be done by defining an expected_output wire
            //and assigning the desired output value to this. Display message, when an error occurs e.g. using $display. 
            //a = 0; 
            //b = 0; 
            //expected_sum = sum_output[1]       expected_sum is a wire
            //expected_carry = carry_output[1]   expected_carry is a wire
            //#wait_time
            //if(sum!=0||carry!=0)
           	//	$display("Test failed for 00")
           	//...
   		end

  	//**INITIAL BLOCK**//
  	//initial begin
  	//
  	//This is one option. 
    //a = 0; 
    //b = 0; 
    //expected_sum = sum_output[1]       expected_sum is a wire
    //expected_carry = carry_output[1]   expected_carry is a wire
    //#wait_time
    //if(sum!=0||carry!=0)
   	//	$display("Test failed for 00")
   	//
    //a = 1; 
    //b = 0; 
    //expected_sum = sum_output[2]       expected_sum is a wire
    //expected_carry = carry_output[2]   expected_carry is a wire
    //#wait_time
    //if(sum!=1||carry!=0)
   	//	$display("Test failed for 01")
  	//
  	//end
    //**INITIAL BLOCK END**//

    //Consider test implementation within the context of continuous integration testing. 
    
endmodule

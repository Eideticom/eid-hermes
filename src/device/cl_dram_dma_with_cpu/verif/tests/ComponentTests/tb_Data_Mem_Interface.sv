`timescale 1ns / 1ps

module tb_Data_Mem_Interface;
	logic mismatch;


	reg [63:0] read_data_from_mem;
	reg [63:0] write_data_from_cpu;
	reg write_bit_from_cpu;
	reg [63:0] address_from_cpu;
	reg read_bit_from_cpu;
	reg [1:0] size_select_from_cpu;
	reg [63:0] DMBottom;
	reg [63:0] DMTop;
	reg read_ready_from_mem;
	reg write_finished_from_mem;
	reg write_ready_from_mem;	

	wire [63:0] address_to_mem;
	wire read_request_to_mem;
	wire write_request_to_mem;
	wire [1:0] size_select_to_mem;
	wire [63:0] read_data_to_cpu;
	wire [63:0] write_data_to_mem;
	wire block_size_to_mem;

	//**CLOCK**//
	reg clk; //Clock signal used in synchronizing the test
	localparam clock_half_period = 10ns; //Define the period of the clock in number of time units. 2*clock_half_period = clock_period
	//Generate clock signal
    initial
  	begin
    clk = 0; 
  	     forever
  	         #1 clk = !clk;   
  	end
	//**END CLOCK**//

	//*Setup the components which will be tested
	Data_Mem_Interface UUT(
		.address_to_mem(address_to_mem),
		.address_from_cpu(address_from_cpu),
		.read_bit_from_cpu(read_bit_from_cpu),
		.read_request_to_mem(read_request_to_mem),
		.write_bit_from_cpu(write_bit_from_cpu),
		.write_request_to_mem(write_request_to_mem),
		.size_select_from_cpu(size_select_from_cpu),
		.size_select_to_mem(size_select_to_mem),
		.read_data_to_cpu(read_data_to_cpu),
		.read_data_from_mem(read_data_from_mem),
		.write_data_from_cpu(write_data_from_cpu),
		.write_data_to_mem(write_data_to_mem),
		.DMBottom(DMBottom),
		.DMTop(DMTop),
		.read_ready_from_mem(read_ready_from_mem),
		.write_finished_from_mem(write_finished_from_mem),
		.write_ready_from_mem(write_ready_from_mem),
		.clk(clk)
	);

	Dummy_Data_Memory Mem(
		.clk(clk),
		.write_request(write_request_to_mem),
		.read_ready(read_ready_from_mem),
		.write_ready(write_ready_from_mem),
		.write_finished(write_finished_from_mem),
		.address(address_to_mem),
		.block_size(size_select_to_mem),
		.write_data(write_data_to_mem),
		.read_data(read_data_from_mem)
	);

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
	
	// generate read and write requests
	
	
	//For testing, may be useful to use a vector of inputs and expected outputs. 
	
	const longint data [15:0] = '{64'hdeadbeefdeadbeef, 64'h1234567887654231, 64'ha5a5a5a5a5a5a5a5, 64'hfedcba0987654321,
								  64'hbadc0fee,			64'hf00dfeed,		  64'hc0feeee,			64'hc0c0beef,
								  64'hf00d,				64'h8888,			  64'hcab0,				64'he110,
								  64'haa,				64'hbb,				  64'hcc,				64'hcc};
	const longint addresses [15:0] = '{64'h00, 64'h08, 64'h10, 64'h18,
									   64'h20, 64'h24, 64'h28, 64'h2c,
									   64'h30, 64'h32, 64'h34, 64'h36,
									   64'h38, 64'h39, 64'h3a, 64'h3b};
	const logic [1:0] sizes [15:0] = '{2'b11, 2'b11, 2'b11, 2'b11,
									  2'b00, 2'b00, 2'b00, 2'b00,
									  2'b01, 2'b01, 2'b01, 2'b01,
									  2'b10, 2'b10, 2'b10, 2'b10};
	integer i;

	initial begin
		// cpu write all data
		write_bit_from_cpu <= 1'b1;
		read_bit_from_cpu <= 1'b0;
		for (i = 0; i < 16; i = i + 1) begin
			address_from_cpu <= addresses[i];
			size_select_from_cpu <= sizes[i];
			write_data_from_cpu <= data[i];
			#50ns;
		end

		//cpu read all data and compare
		write_bit_from_cpu <= 1'b0;
		read_bit_from_cpu <= 1'b1;
		for (i = 0; i < 16; i = i + 1) begin
			address_from_cpu <= addresses[i];
			size_select_from_cpu <= sizes[i];
			#50ns
			if (read_data_to_cpu != data[i])
				$display("Read data does not equal written data, expected %d, received %d", data[i], read_data_to_cpu);
		end 
	end
	
endmodule
// -----------------------------------------------------------------------------
// This block controls the data flow between the instruction memory interface
// (IM) and data memory interface (DM), and the DDR through an AXI interface to
// the S01 port of the AXI interconnect of the CL_DMA_PCIS_SLV module
// -----------------------------------------------------------------------------

module axi_memory_interface (

	 input            aclk,
	 input            aresetn,
	 axi_bus_t.slave  cl_axi_mstr_bus,  // AXI Master Bus
	 cfg_bus_t.master axi_mstr_cfg_bus,  // Config Bus for Register Access

	 input	[63:0]	 IM_address,
	 input			 IM_read_request,
	 output	reg		 IM_read_ready,
	 output	reg [63:0] IM_instruction,

	 input	[63:0]	 DM_address,
	 input			 DM_read_request,
	 input			 DM_write_request,
	 output reg		 DM_read_ready,
	 output			 DM_write_finished,
	 input	[63:0]	 DM_data_from_CPU,
	 output	reg [63:0] DM_data_to_CPU,
	 input	[1:0]	 DM_block_size,
	 output			 DM_write_ready
	 
);

 `include "cl_dram_dma_defines.vh"

// -----------------------------------------------------------------------------
// Parameters
// -----------------------------------------------------------------------------

	// State Machine States
	typedef enum logic [2:0] {
		SM_IDLE,
		SM_IM_READ_REQUEST,
		SM_IM_READ_DATA,
		SM_DM_READ_REQUEST,
		SM_DM_READ_DATA,
		SM_DM_WRITE_REQUEST,
		SM_DM_WRITE_DATA,
		SM_DM_WRITE_RESPONSE
									  } sm_states;    


// -----------------------------------------------------------------------------
// Internal signals
// -----------------------------------------------------------------------------

	// AXI Master State Machine
	sm_states sm_next_state;
	sm_states sm_current_state;

	logic in_state_idle;
	logic in_state_IM_read_request;
	logic in_state_IM_read_data;
	logic in_state_DM_read_request;
	logic in_state_DM_read_data;
	logic in_state_DM_write_request;
	logic in_state_DM_write_data;
	logic in_state_DM_write_response;

	// DM read/write size
	logic[2:0] DM_block_size_AXI;
	
	// valid byte lanes for write
	logic[7:0] wstrb;

	// output read ready signal next states
	logic IM_read_ready_ns;
	logic DM_read_ready_ns;
	

// -----------------------------------------------------------------------------
// State Machine
// -----------------------------------------------------------------------------


	// next state logic
	always_comb begin
	  // Default
	  sm_next_state = SM_IDLE;

	  case (sm_current_state)

		 SM_IDLE: begin
			if (IM_read_request)			sm_next_state = SM_IM_READ_REQUEST;
			else if (DM_read_request)		sm_next_state = SM_DM_READ_REQUEST;
			else if (DM_write_request)		sm_next_state = SM_DM_WRITE_REQUEST;
			else                			sm_next_state = SM_IDLE;
		 end

		 SM_IM_READ_REQUEST: begin
			 if (cl_axi_mstr_bus.arready)	sm_next_state = SM_IM_READ_DATA;
			 else							sm_next_state = SM_IM_READ_REQUEST;
		 end

		 SM_IM_READ_DATA: begin
			 if (cl_axi_mstr_bus.rvalid)	sm_next_state = SM_IDLE;
			 else							sm_next_state = SM_IM_READ_DATA;
		 end

		 SM_DM_READ_REQUEST: begin
			 if (cl_axi_mstr_bus.arready)	sm_next_state = SM_DM_READ_DATA;
			 else							sm_next_state = SM_DM_READ_REQUEST;
		 end

		 SM_DM_READ_DATA: begin
			 if (cl_axi_mstr_bus.rvalid)	sm_next_state = SM_IDLE;
			 else							sm_next_state = SM_DM_READ_DATA;
		 end

		 SM_DM_WRITE_REQUEST: begin
			 if (cl_axi_mstr_bus.awready)	sm_next_state = SM_DM_WRITE_DATA;
			 else							sm_next_state = SM_DM_WRITE_REQUEST;
		 end

		 SM_DM_WRITE_DATA: begin
			 if (cl_axi_mstr_bus.wready)	sm_next_state = SM_DM_WRITE_RESPONSE;
			 else							sm_next_state = SM_DM_WRITE_DATA;
		 end

		 SM_DM_WRITE_RESPONSE: begin
			 if (cl_axi_mstr_bus.bvalid)	sm_next_state = SM_IDLE;
			 else							sm_next_state = SM_DM_WRITE_RESPONSE;
		 end

		 default: sm_next_state  = SM_IDLE;

	  endcase
	end

	// SM Flop
	always_ff @(posedge aclk)
		if (!aresetn) begin
			sm_current_state <= SM_IDLE;
		end
		else begin
			sm_current_state <= sm_next_state;
		end

	// State nets
	assign in_state_idle 				= sm_current_state == SM_IDLE;
	assign in_state_IM_read_request 	= sm_current_state == SM_IM_READ_REQUEST;
	assign in_state_IM_read_data 		= sm_current_state == SM_IM_READ_DATA;
	assign in_state_DM_read_request 	= sm_current_state == SM_DM_READ_REQUEST;
	assign in_state_DM_read_data 		= sm_current_state == SM_DM_READ_DATA;
	assign in_state_DM_write_request 	= sm_current_state == SM_DM_WRITE_REQUEST;
	assign in_state_DM_write_data 		= sm_current_state == SM_DM_WRITE_DATA;
	assign in_state_DM_write_response 	= sm_current_state == SM_DM_WRITE_RESPONSE;

// -----------------------------------------------------------------------------
// AXI Bus Connections
// -----------------------------------------------------------------------------

	// calculate write size signals
	assign DM_block_size_AXI = 	DM_block_size == 2'b00 ? 3'b010 :	// word == 4 bytes == 2^2 B
								DM_block_size == 2'b01 ? 3'b001 :	// half word == 2 bytes == 2^1 B
								DM_block_size == 2'b10 ? 3'b000 :	// byte == 2^0 B
								DM_block_size == 2'b11 ? 3'b011 :	// double word == 8 bytes == 2^3 B
														 3'b011;	// defualt to double word

	assign wstrb = 	DM_block_size == 3'b000 ? 8'b00000001 : // 1 bytes
					DM_block_size == 3'b001 ? 8'b00000011 : // 2 bytes
					DM_block_size == 3'b010 ? 8'b00001111 : // 4 bytes
					DM_block_size == 3'b011 ? 8'b11111111 : // 8 bytes
												'1;

	// Write Address
	assign cl_axi_mstr_bus.awid[15:0]	= 16'b0;					// Only 1 outstanding command
	assign cl_axi_mstr_bus.awaddr[63:0]	= DM_address;				// Only ever write from DM
	assign cl_axi_mstr_bus.awlen[7:0]	= 8'h00;					// Always 1 burst
	assign cl_axi_mstr_bus.awsize[2:0]	= DM_block_size_AXI;		// Write size only depends on DM write size
	assign cl_axi_mstr_bus.awvalid		= in_state_DM_write_request;

	// Write Data
	assign cl_axi_mstr_bus.wid[15:0]	= 16'b0;					// Only 1 outstanding command
	assign cl_axi_mstr_bus.wdata[511:0]	= {'0, DM_data_from_CPU};	// Only write from DM
	assign cl_axi_mstr_bus.wstrb[63:0]	= {56'b0, wstrb};			// Determined by DM write size

	assign cl_axi_mstr_bus.wlast		= 1'b1;						// Always 1 burst
	assign cl_axi_mstr_bus.wvalid		= in_state_DM_write_data;

	// Write Response
	assign cl_axi_mstr_bus.bready		= in_state_DM_write_response;

	// Read Address
	assign cl_axi_mstr_bus.arid[15:0]	= 16'b0;					// Only 1 outstanding command
	assign cl_axi_mstr_bus.araddr[63:0]	= in_state_DM_read_request | in_state_DM_read_data ? DM_address : IM_address;
	assign cl_axi_mstr_bus.arlen[7:0]	= 8'h00;					// Always 1 burst
	assign cl_axi_mstr_bus.arsize[2:0]	= in_state_DM_read_request | in_state_DM_read_data ? DM_block_size_AXI : '1;
	assign cl_axi_mstr_bus.arvalid		= in_state_DM_read_request | in_state_IM_read_request;

	// Read Data
	assign cl_axi_mstr_bus.rready		= in_state_DM_read_data | in_state_IM_read_data;


// -----------------------------------------------------------------------------
// outputs to IM
// -----------------------------------------------------------------------------

	assign IM_read_ready_ns = in_state_IM_read_data & cl_axi_mstr_bus.rvalid;

	always_ff @(posedge aclk) begin
		IM_read_ready <= IM_read_ready_ns;
	end

	always_ff @(posedge aclk) begin
		if(~aresetn) begin
			IM_instruction <= '0;
		end else if (in_state_IM_read_data & cl_axi_mstr_bus.rvalid) begin
			IM_instruction <= cl_axi_mstr_bus.rdata[63:0];
		end else begin
			IM_instruction <= IM_instruction;
		end
	end

// -----------------------------------------------------------------------------
// outputs to DM
// -----------------------------------------------------------------------------

	assign DM_read_ready_ns = in_state_DM_read_data & cl_axi_mstr_bus.rvalid;

	always_ff @(posedge aclk) begin
		DM_read_ready <= DM_read_ready_ns;
	end

	assign DM_write_ready = cl_axi_mstr_bus.awready;

	always_ff @(posedge aclk) begin
		if(~aresetn) begin
			DM_data_to_CPU <= '0;
		end else if (in_state_DM_read_data & cl_axi_mstr_bus.rvalid) begin
			DM_data_to_CPU <= 	DM_block_size == 2'b00 ? {'0, cl_axi_mstr_bus.rdata[31:0]} :	// word == 32 bits
								DM_block_size == 2'b01 ? {'0, cl_axi_mstr_bus.rdata[15:0]} :	// half word == 16 bits
								DM_block_size == 2'b10 ? {'0, cl_axi_mstr_bus.rdata[7:0]}  :	// byte == 8 bits
								DM_block_size == 2'b11 ? 	  cl_axi_mstr_bus.rdata[63:0]  :	// double word == 63 bits == full output bus
														 	  cl_axi_mstr_bus.rdata[63:0];	// defualt to double word
		end else begin
			DM_data_to_CPU <= DM_data_to_CPU;
		end
	end

// -----------------------------------------------------------------------------
// cfg_bus stuff, can just ignore everything following this point
// -----------------------------------------------------------------------------

 // Command Registers
	logic        cmd_done_ns;
	logic [31:0] cmd_rd_data_ns;

	logic        cmd_go_q;
	logic        cmd_done_q;
	logic        cmd_rd_wrb_q;
	logic [31:0] cmd_addr_hi_q;
	logic [31:0] cmd_addr_lo_q;
	logic [31:0] cmd_rd_data_q;
	logic [31:0] cmd_wr_data_q;


	logic cfg_wr_stretch;
	logic cfg_rd_stretch;

	logic [ 7:0] cfg_addr_q  = 0; // Only care about lower 8-bits of address. Upper bits are decoded somewhere else.
	logic [31:0] cfg_wdata_q = 0;

// -----------------------------------------------------------------------------
// Register Access
// -----------------------------------------------------------------------------

	always @(posedge aclk)
		if (!aresetn)
		begin
			cfg_wr_stretch <= 0;
			cfg_rd_stretch <= 0;
		end
		else
		begin
			cfg_wr_stretch <= axi_mstr_cfg_bus.wr || (cfg_wr_stretch && !axi_mstr_cfg_bus.ack);
			cfg_rd_stretch <= axi_mstr_cfg_bus.rd || (cfg_rd_stretch && !axi_mstr_cfg_bus.ack);
			if (axi_mstr_cfg_bus.wr||axi_mstr_cfg_bus.rd)
			begin
				cfg_addr_q  <= axi_mstr_cfg_bus.addr[7:0];
				cfg_wdata_q <= axi_mstr_cfg_bus.wdata[31:0];
			end
		end

	//Readback mux
	always @(posedge aclk)
	begin
			case (cfg_addr_q)
				8'h00:      axi_mstr_cfg_bus.rdata[31:0] <= {29'b0, cmd_rd_wrb_q, cmd_done_q, cmd_go_q};
				8'h04:      axi_mstr_cfg_bus.rdata[31:0] <= cmd_addr_hi_q[31:0];
				8'h08:      axi_mstr_cfg_bus.rdata[31:0] <= cmd_addr_lo_q[31:0];
				8'h0C:      axi_mstr_cfg_bus.rdata[31:0] <= cmd_wr_data_q[31:0];
				8'h10:      axi_mstr_cfg_bus.rdata[31:0] <= cmd_rd_data_q[31:0];
				default:    axi_mstr_cfg_bus.rdata[31:0] <= 32'hffffffff;
			endcase
	end

	//Ack for cycle
	always_ff @(posedge aclk)
		if (!aresetn)
			axi_mstr_cfg_bus.ack <= 0;
		else
			axi_mstr_cfg_bus.ack <= ((cfg_wr_stretch||cfg_rd_stretch) && !axi_mstr_cfg_bus.ack);

// -----------------------------------------------------------------------------
// AXI Master Command Registers
// -----------------------------------------------------------------------------
// Offset     Register
// -------    --------------------
// 0x00       Command Control Register (CCR)
//             31:3 - Reserved
//                2 - Read/Write_B
//                1 - Done
//                0 - Go
// 0x04       Command Address High Register (CAHR)
//             31:0 - Address
// 0x08       Command Address Low Register (CALR)
//             31:0 - Address
// 0x0C       Command Write Data Register (CWDR)
//             31:0 - Write Data
// 0x10       Command Read Data Register (CRDR)
//             31:3 - Read Data

	// ----------------------
	// Command Go
	// ----------------------

	always_ff @(posedge aclk)
		if (!aresetn) begin
			cmd_go_q <= 1'b0;
		end
		else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == `CL_DRAM_DMA_AXI_MSTR_CCR_ADDR)) begin
			cmd_go_q <= cfg_wdata_q[0];
		end
		else begin
			cmd_go_q <= cmd_go_q & ~in_state_idle;
		end


	// ----------------------
	// Command Done
	// ----------------------

	assign cmd_done_ns = cmd_done_q | ((in_state_IM_read_data | in_state_DM_read_data) & cl_axi_mstr_bus.rvalid) |
												 ((in_state_DM_write_response) & cl_axi_mstr_bus.bvalid) ;

	always_ff @(posedge aclk)
		if (!aresetn) begin
			cmd_done_q <= 1'b0;
		end
		else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == `CL_DRAM_DMA_AXI_MSTR_CCR_ADDR)) begin
			cmd_done_q <= cfg_wdata_q[1];
		end
		else begin
			cmd_done_q <= cmd_done_ns;
		end


	// ----------------------
	// Command Rd/Wr_B
	// ----------------------

	always_ff @(posedge aclk)
		if (!aresetn) begin
			cmd_rd_wrb_q <= 1'b0;
		end
		else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == `CL_DRAM_DMA_AXI_MSTR_CCR_ADDR)) begin
			cmd_rd_wrb_q <= cfg_wdata_q[2];
		end
		else begin
			cmd_rd_wrb_q <= cmd_rd_wrb_q;
		end


	// ----------------------
	// Command Address - High
	// ----------------------

	always_ff @(posedge aclk)
		if (!aresetn) begin
			cmd_addr_hi_q[31:0] <= 32'h0000_0000;
		end
		else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == `CL_DRAM_DMA_AXI_MSTR_CAHR_ADDR)) begin
			cmd_addr_hi_q[31:0] <= cfg_wdata_q[31:0];
		end
		else begin
			cmd_addr_hi_q[31:0] <= cmd_addr_hi_q[31:0];
		end

	// ----------------------
	// Command Address - Low
	// ----------------------

	always_ff @(posedge aclk)
		if (!aresetn) begin
			cmd_addr_lo_q[31:0] <= 32'h0000_0000;
		end
		else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == `CL_DRAM_DMA_AXI_MSTR_CALR_ADDR)) begin
			cmd_addr_lo_q[31:0] <= cfg_wdata_q[31:0];
		end
		else begin
			cmd_addr_lo_q[31:0] <= cmd_addr_lo_q[31:0];
		end

	// ----------------------
	// Command Write Data
	// ----------------------

	always_ff @(posedge aclk)
		if (!aresetn) begin
			cmd_wr_data_q[31:0] <= 32'h0000_0000;
		end
		else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == `CL_DRAM_DMA_AXI_MSTR_CWDR_ADDR)) begin
			cmd_wr_data_q <= cfg_wdata_q[31:0];
		end
		else begin
			cmd_wr_data_q[31:0] <= cmd_wr_data_q[31:0];
		end

	// ----------------------
	// Command Read Data
	// ----------------------

	assign cmd_rd_data_ns[31:0] =
			((in_state_IM_read_data | in_state_DM_read_data) & cl_axi_mstr_bus.rvalid) ?
			(cl_axi_mstr_bus.rdata[511:0] >> (8 * cmd_addr_lo_q[5:0])) : cmd_rd_data_q[31:0];

	always_ff @(posedge aclk)
		if (!aresetn) begin
			cmd_rd_data_q[31:0] <= 32'h0000_0000;
		end
		else if (cfg_wr_stretch & ~axi_mstr_cfg_bus.ack & (cfg_addr_q == `CL_DRAM_DMA_AXI_MSTR_CRDR_ADDR)) begin
			cmd_rd_data_q <= cfg_wdata_q[31:0];
		end
		else begin
			cmd_rd_data_q[31:0] <= cmd_rd_data_ns[31:0];
		end

endmodule

// -----------------------------------------------------------------------------
// This module is a test of reading data from an address, changing it somehow,
// and writing it back to the same address
// -----------------------------------------------------------------------------

module change_data_test (

    input            aclk,
    input            aresetn,
    axi_bus_t.slave  cl_axi_mstr_bus,  // AXI Master Bus
    input [63:0]     data_address
);

 `include "cl_dram_dma_defines.vh"

  logic [31:0] local_storage;
  logic [63:0] address;
  logic address_changed;

  // synchronize address
  always_ff @(posedge aclk) begin
    if(~aresetn) begin
      address <= 0;
      address_changed <= 0;
    end else if (sm_in_state_idle) begin // only take new address if in idle
      address <= data_address;
      address_changed <= 1;
    end else begin
      address <= address;
      address_changed <= 0;
    end
  end

// -----------------------------------------------------------------------------
// Parameters
// -----------------------------------------------------------------------------

   // State Machine States
   typedef enum logic [2:0] {
      SM_IDLE,
      SM_R_REQUEST,
      SM_R_DATA,
      SM_CHANGE_DATA,
      SM_W_REQUEST,
      SM_W_DATA,
      SM_W_RESPONSE
   } sm_states;

   // Signals
   sm_states sm_next_state;
   sm_states sm_current_state;

   logic sm_in_state_idle;
   logic sm_in_state_r_request;
   logic sm_in_state_r_data;
   logic sm_in_state_change_data;
   logic sm_in_state_w_request;
   logic sm_in_state_w_data;
   logic sm_in_state_w_response;

   logic sm_input_make_read_request;
   logic sm_input_read_request_done;
   logic sm_input_data_read_done;
   logic sm_input_data_change_done;
   logic sm_input_write_request_done;
   logic sm_input_data_write_done;
   logic sm_input_write_response_received;

// -----------------------------------------------------------------------------
// State Machine
// -----------------------------------------------------------------------------
   
   // State Machine Logic
   always_comb begin

    case (sm_current_state)
      
      SM_IDLE: begin
        if (sm_input_make_read_request)
          sm_next_state <= SM_R_REQUEST;
        else
          sm_next_state <= SM_IDLE;
      end

      SM_R_REQUEST: begin
        if (sm_input_read_request_done)
          sm_next_state <= SM_R_DATA;
        else
          sm_next_state <= SM_R_REQUEST;
      end

      SM_R_DATA: begin
        if (sm_input_data_read_done)
          sm_next_state <= SM_CHANGE_DATA;
        else
          sm_next_state <= SM_R_DATA;
      end

      SM_CHANGE_DATA: begin
        if (sm_input_data_change_done)
          sm_next_state <= SM_W_REQUEST;
        else
          sm_next_state <= SM_CHANGE_DATA;
      end

      SM_W_REQUEST: begin
        if (sm_input_write_request_done)
          sm_next_state <= SM_W_DATA;
        else
          sm_next_state <= SM_W_REQUEST;
      end

      SM_W_DATA: begin
        if (sm_input_data_write_done)
          sm_next_state <= SM_W_RESPONSE;
        else
          sm_next_state <= SM_W_DATA;
      end

      SM_W_RESPONSE: begin
        if (sm_input_write_response_received)
          sm_next_state <= SM_IDLE;
        else
          sm_next_state <= SM_IDLE;
      end
      
      default: sm_next_state <= SM_IDLE;
    
    endcase

   end

   always_ff @(posedge aclk) begin
     if(~aresetn) begin
        sm_current_state <= SM_IDLE;
     end else begin
        sm_current_state <= sm_next_state;
     end
   end

   // State Machine Current State Outputs
   assign sm_in_state_idle        = sm_current_state == SM_IDLE;
   assign sm_in_state_r_request   = sm_current_state == SM_R_REQUEST;
   assign sm_in_state_r_data      = sm_current_state == SM_R_DATA;
   assign sm_in_state_change_data = sm_current_state == SM_CHANGE_DATA;
   assign sm_in_state_w_request   = sm_current_state == SM_W_REQUEST;
   assign sm_in_state_w_data      = sm_current_state == SM_W_DATA;
   assign sm_in_state_w_response  = sm_current_state == SM_W_RESPONSE;

// -----------------------------------------------------------------------------
// State Machine Inputs Logic
// -----------------------------------------------------------------------------

   assign sm_input_read_request_done       = cl_axi_mstr_bus.arready;
   assign sm_input_data_read_done          = cl_axi_mstr_bus.rvalid;
   assign sm_input_write_request_done      = cl_axi_mstr_bus.awready;
   assign sm_input_data_write_done         = cl_axi_mstr_bus.wready;
   assign sm_input_write_response_received = cl_axi_mstr_bus.bvalid;
   assign sm_input_make_read_request       = address_changed;
   assign sm_input_data_change_done        = sm_in_state_change_data;

// -----------------------------------------------------------------------------
// Action Logic !!!! MIGHT NEED TO BE FINISHED !!!!
// -----------------------------------------------------------------------------

   // reset
   always_ff @(posedge aclk) begin
     if(~aresetn) begin
       local_storage <= 0;
     end
   end

   // idle

   // read request

   // read data
   always_ff @(posedge aclk) begin
     if (sm_in_state_r_data && cl_axi_mstr_bus.rvalid) begin
       local_storage <= cl_axi_mstr_bus.rdata[31:0];
     end
   end

   // change data (byteswap)
   always_ff @(posedge aclk) begin
     if(sm_in_state_change_data) begin
        local_storage <= {local_storage[7:0], local_storage[15:8], local_storage[23:16], local_storage[31:24]};
     end
   end

   // write request

   // write data

   // write response

// -----------------------------------------------------------------------------
// AXI Bus Connections
// -----------------------------------------------------------------------------

   // Write Address
   assign cl_axi_mstr_bus.awid[15:0]   = 16'b0;                     // Only 1 outstanding command
   assign cl_axi_mstr_bus.awaddr[63:0] = address;
   assign cl_axi_mstr_bus.awlen[7:0]   = 8'h00;                     // Always 1 burst
   assign cl_axi_mstr_bus.awsize[2:0]  = 3'b010;                    // Always 4 bytes
   assign cl_axi_mstr_bus.awvalid      = sm_in_state_w_request;

   // Write Data
   assign cl_axi_mstr_bus.wid[15:0]    = 16'b0;                     // Only 1 outstanding command
   assign cl_axi_mstr_bus.wdata[511:0] = {480'b0, local_storage};
   assign cl_axi_mstr_bus.wstrb[63:0]  = 64'hF;                     // Always 4 bytes

   assign cl_axi_mstr_bus.wlast        = 1'b1;                      // Always 1 burst
   assign cl_axi_mstr_bus.wvalid       = sm_in_state_w_data;

   // Write Response
   assign cl_axi_mstr_bus.bready       = sm_in_state_w_response;

   // Read Address
   assign cl_axi_mstr_bus.arid[15:0]   = 16'b0;                     // Only 1 outstanding command
   assign cl_axi_mstr_bus.araddr[63:0] = address;
   assign cl_axi_mstr_bus.arlen[7:0]   = 8'h00;                     // Always 1 burst
   assign cl_axi_mstr_bus.arsize[2:0]  = 3'b010;                    // Always 4 bytes
   assign cl_axi_mstr_bus.arvalid      = sm_in_state_r_request;

   // Read Data
   assign cl_axi_mstr_bus.rready       = sm_in_state_r_data;

endmodule

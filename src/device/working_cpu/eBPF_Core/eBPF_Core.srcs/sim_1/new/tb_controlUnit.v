`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/14/2021 04:47:04 PM
// Design Name: 
// Module Name: tb_rightZeroPad
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


module tb_controlUnit;

    reg [7:0] opcode;
    wire regwrite;
    wire memtoreg;
    wire memwrite;
    wire memread;
    wire writesrc;
    wire dstSelect;
    wire [1:0] immExtend;
    wire [3:0] Branch;
    wire [3:0] alucontrol;
    wire [1:0] alusrca;
    wire [1:0] alusrcb;
    wire bit_32;
    
    localparam period = 20; 
    reg clk;

    ControlUnit UUT(
    .opcode(opcode),
    .regwrite(regwrite),
    .memtoreg(memtoreg),
    .memwrite(memwrite),
    .memread(memread), 
    .writesrc(writesrc),
    .dstSelect(dstSelect),
    .immExtend(immExtend),
    .Branch(Branch),
    .alucontrol(alucontrol),
    .alusrca(alusrca),
    .alusrcb(alusrcb),
    .bit_32(bit_32)
    );
    
    always 
    begin
        clk = 1'b1; 
        #20; // high for 20 * timescale = 20 ns
    
        clk = 1'b0;
        #20; // low for 20 * timescale = 20 ns
    end
    
    always @(posedge clk)
    begin
    
        //64 Bit
        opcode = 8'h00;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b1 ||
            writesrc    != 1'b1 ||
            dstSelect   != 1'b1 ||
            immExtend   != 2'b10 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0100 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h00");
        
        opcode = 8'h07;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h07");
        
        opcode = 8'h0f;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h0f");
        
        opcode = 8'h17;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0001 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h17");
        
        opcode = 8'h1f;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0001 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h1f");
        
        opcode = 8'h27;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0010 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h27");
        
        opcode = 8'h2f;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0010 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h2f");
        
        opcode = 8'h37;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0011 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h37");
        
        opcode = 8'h3f;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0011 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h3f");
        
        opcode = 8'h47;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0100 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h47");
        
        opcode = 8'h4f;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0100 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h4f");
        
        opcode = 8'h57;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0101 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h57");
        
        opcode = 8'h5f;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0101 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h5f");
        
        opcode = 8'h67;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0110 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h67");
        
        opcode = 8'h6f;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0110 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h6f");
        
        opcode = 8'h77;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0111 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h77");
        
        opcode = 8'h7f;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0111 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h7f");
        
        opcode = 8'h87;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b1000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h87");
        
        opcode = 8'h97;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b1001 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h97");
        
        opcode = 8'h9f;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b1001 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h9f");
        
        opcode = 8'ha7;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b1010 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode ha7");
        
        opcode = 8'haf;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b1010 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode haf");
        
        opcode = 8'hb7;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b1011 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode hb7");
        
        opcode = 8'hbf;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b1011 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode hbf");
        
        opcode = 8'hc7;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b1100 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode hc7");
        
        opcode = 8'hcf;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b1100 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode hcf");
        
        
        
        
        
        
        
        //32-Bit
        opcode = 8'h04;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b1
        )
            $display("Test failed for opcode h04");
        
        opcode = 8'h0c;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b1
        )
            $display("Test failed for opcode h0c");
        
        opcode = 8'h14;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0001 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b1
        )
            $display("Test failed for opcode h14");
        
        opcode = 8'h1c;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0001 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b1
        )
            $display("Test failed for opcode h1c");
        
        opcode = 8'h24;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0010 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b1
        )
            $display("Test failed for opcode h24");
        
        opcode = 8'h2c;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0010 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b1
        )
            $display("Test failed for opcode h2c");
        
        opcode = 8'h34;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0011 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b1
        )
            $display("Test failed for opcode h34");
        
        opcode = 8'h3c;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0011 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b1
        )
            $display("Test failed for opcode h3c");
        
        opcode = 8'h44;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0100 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b1
        )
            $display("Test failed for opcode h44");
        
        opcode = 8'h4c;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0100 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b1
        )
            $display("Test failed for opcode h4c");
        
        opcode = 8'h54;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0101 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b1
        )
            $display("Test failed for opcode h54");
        
        opcode = 8'h5c;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0101 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b1
        )
            $display("Test failed for opcode h5c");
        
        opcode = 8'h64;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0110 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b1
        )
            $display("Test failed for opcode h64");
        
        opcode = 8'h6c;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0110 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b1
        )
            $display("Test failed for opcode h6c");
        
        opcode = 8'h74;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0111 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b1
        )
            $display("Test failed for opcode h74");
        
        opcode = 8'h7c;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0111 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b1
        )
            $display("Test failed for opcode h7c");
        
        opcode = 8'h84;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b1000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b1
        )
            $display("Test failed for opcode h84");
        
        opcode = 8'h94;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b1001 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b1
        )
            $display("Test failed for opcode h94");
        
        opcode = 8'h9c;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b1001 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b1
        )
            $display("Test failed for opcode h9c");
        
        opcode = 8'ha4;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b1010 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b1
        )
            $display("Test failed for opcode ha4");
        
        opcode = 8'hac;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b1010 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b1
        )
            $display("Test failed for opcode hac");
        
        opcode = 8'hb4;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b1011 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b1
        )
            $display("Test failed for opcode hb4");
        
        opcode = 8'hbc;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b1011 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b1
        )
            $display("Test failed for opcode hbc");
        
        opcode = 8'hc4;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b1100 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b1
        )
            $display("Test failed for opcode hc4");
        
        opcode = 8'hcc;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b1100 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b1
        )
            $display("Test failed for opcode hcc");
        
        
        
        
        
        
        //Byteswap
        opcode = 8'hd4;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b1101 ||
            alusrca     != 2'b01 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode hd4");
        
        opcode = 8'hdc;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b1110 ||
            alusrca     != 2'b01 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode hdc");
        
        
        
        
        
        
        
        
        // Memory
        opcode = 8'h18;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b1 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b01 ||
            Branch      != 4'b0000 ||
            //alucontrol  != 4'b1101 ||
            //alusrca     != 2'b01 ||
            //alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h18");
        
        opcode = 8'h20;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b1 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            //alucontrol  != 4'b1101 ||
            //alusrca     != 2'b01 ||
            //alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h20");
        
        opcode = 8'h28;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b1 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            //alucontrol  != 4'b1101 ||
            //alusrca     != 2'b01 ||
            //alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h28");
            
        opcode = 8'h30;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b1 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            //alucontrol  != 4'b1101 ||
            //alusrca     != 2'b01 ||
            //alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h30");
            
        opcode = 8'h38;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b1 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            //alucontrol  != 4'b1101 ||
            //alusrca     != 2'b01 ||
            //alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h38");
            
        opcode = 8'h40;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b1 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            //alucontrol  != 4'b1101 ||
            //alusrca     != 2'b01 ||
            //alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h40");
            
        opcode = 8'h48;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b1 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            //alucontrol  != 4'b1101 ||
            //alusrca     != 2'b01 ||
            //alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h48");
            
        opcode = 8'h50;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b1 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            //alucontrol  != 4'b1101 ||
            //alusrca     != 2'b01 ||
            //alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h50");
            
        opcode = 8'h58;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b1 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            //alucontrol  != 4'b1101 ||
            //alusrca     != 2'b01 ||
            //alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h58");
            
        opcode = 8'h61;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b1 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b10 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h61");
            
        opcode = 8'h69;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b1 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b10 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h69");
            
        opcode = 8'h71;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b1 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b10 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h71");
            
        opcode = 8'h79;
        #period
        
        if (
            regwrite    != 1'b1 ||
            memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b1 ||
            //writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b10 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h79");
            
        opcode = 8'h62;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b1 ||
            memread     != 1'b0 ||
            writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0000 ||
            alusrca     != 2'b10 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h62");
            
        opcode = 8'h6a;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b1 ||
            memread     != 1'b0 ||
            writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0000 ||
            alusrca     != 2'b10 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h6a");
            
        opcode = 8'h72;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b1 ||
            memread     != 1'b0 ||
            writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0000 ||
            alusrca     != 2'b10 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h72");
            
        opcode = 8'h7a;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b1 ||
            memread     != 1'b0 ||
            writesrc    != 1'b1 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0000 ||
            alusrca     != 2'b10 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h7a");
            
        opcode = 8'h63;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b1 ||
            memread     != 1'b0 ||
            writesrc    != 1'b0 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0000 ||
            alusrca     != 2'b10 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h63");
            
        opcode = 8'h6b;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b1 ||
            memread     != 1'b0 ||
            writesrc    != 1'b0 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0000 ||
            alusrca     != 2'b10 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h6b");
            
        opcode = 8'h73;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b1 ||
            memread     != 1'b0 ||
            writesrc    != 1'b0 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0000 ||
            alusrca     != 2'b10 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h73");
            
        opcode = 8'h7b;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b1 ||
            memread     != 1'b0 ||
            writesrc    != 1'b0 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0000 ||
            alusrca     != 2'b10 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h7b");
            
            
            
            
            
            
        
        // Branch
        opcode = 8'h05;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b0 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0001 ||
            //alucontrol  != 4'b0000 ||
            //alusrca     != 2'b10 ||
            //alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h05");
        
        opcode = 8'h15;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b0 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0010 ||
            //alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h15");
        
        opcode = 8'h1d;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b0 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0010 ||
            //alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h1d");

        opcode = 8'h25;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b0 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0011 ||
            //alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h25");
        
        opcode = 8'h2d;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b0 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0011 ||
            //alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h2d");
        
        opcode = 8'h35;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b0 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0100 ||
            //alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h35");
        
        opcode = 8'h3d;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b0 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0100 ||
            //alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h3d");
        
        opcode = 8'ha5;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b0 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0101 ||
            //alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode ha5");
        
        opcode = 8'had;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b0 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0101 ||
            //alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode had");
        
        opcode = 8'hb5;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b0 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0110 ||
            //alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode hb5");
        
        opcode = 8'hbd;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b0 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0110 ||
            //alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode hbd");
        
        opcode = 8'h45;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b0 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0111 ||
            //alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h45");
        
        opcode = 8'h4d;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b0 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0111 ||
            //alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h4d");
        
        opcode = 8'h55;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b0 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b1000 ||
            //alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h55");
        
        opcode = 8'h5d;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b0 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b1000 ||
            //alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h5d");
        
        opcode = 8'h65;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b0 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b1001 ||
            //alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h65");
        
        opcode = 8'h6d;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b0 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b1001 ||
            //alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h6d");
        
        opcode = 8'h75;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b0 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b1010 ||
            //alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h75");
        
        opcode = 8'h7d;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b0 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b1010 ||
            //alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h7d");
        
        opcode = 8'hc5;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b0 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b1011 ||
            //alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode hc5");
        
        opcode = 8'hcd;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b0 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b1011 ||
            //alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode hcd");
        
        opcode = 8'hd5;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b0 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b1100 ||
            //alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b01 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode hd5");
        
        opcode = 8'hdd;
        #period
        
        if (
            regwrite    != 1'b0 ||
            //memtoreg    != 1'b1 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            //writesrc    != 1'b0 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b1100 ||
            //alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode hdd");
        
        opcode = 8'h95;
        #period
        
        if (
            regwrite    != 1'b0 ||
            memtoreg    != 1'b0 ||
            memwrite    != 1'b0 ||
            memread     != 1'b0 ||
            writesrc    != 1'b0 ||
            dstSelect   != 1'b0 ||
            immExtend   != 2'b00 ||
            Branch      != 4'b0000 ||
            alucontrol  != 4'b0000 ||
            alusrca     != 2'b00 ||
            alusrcb     != 2'b00 ||
            bit_32      != 1'b0
        )
            $display("Test failed for opcode h95");
    
        $stop;
    
    end

endmodule

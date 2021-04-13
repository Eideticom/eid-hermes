`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2020 06:29:21 PM
// Design Name: 
// Module Name: tb_register_file
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


module tb_register_file;

    //Input variables that will be varied
    reg writeEnable_input; 
    reg [3:0] dst_input; 
    reg [3:0] src_input; 
    reg [63:0] dstWrite_input; 
    
    //Output wires that will be monitored
    reg [63:0] dstRead_output; 
    reg [63:0] srcRead_output;
    
    logic mismatch1;
    logic mismatch2;  
    reg clk; //Clock signal used in synchronizing the test
    
    //Instantiate the component we would like to test. 
    register_file UUT(.clk(clk),.dst(dst_input),.src(src_input),.dstRead(dstRead_output),.srcRead(srcRead_output),.dstWrite(dstWrite_input),.writeEnable(writeEnable_input));
    
    reg  [31:0] writeEnable_input_vector;
    reg  [4:0] dst_input_vector [15:0];
    reg  [4:0] src_input_vector [15:0]; 
    reg  [63:0] dstWrite_input_vector [15:0];

    //Alternating 1 and 0 for the write enable. 
    initial 
    begin
    writeEnable_input_vector[0]  = 1'b1;
    writeEnable_input_vector[1]  = 1'b0;
    writeEnable_input_vector[2]  = 1'b1;
    writeEnable_input_vector[3]  = 1'b0;
    writeEnable_input_vector[4]  = 1'b1;
    writeEnable_input_vector[5]  = 1'b0;
    writeEnable_input_vector[6]  = 1'b1;
    writeEnable_input_vector[7]  = 1'b0;
    writeEnable_input_vector[8]  = 1'b1;
    writeEnable_input_vector[9]  = 1'b0;
    writeEnable_input_vector[10] = 1'b1;
    writeEnable_input_vector[11] = 1'b0;
    writeEnable_input_vector[12] = 1'b1;
    writeEnable_input_vector[13] = 1'b0;
    writeEnable_input_vector[14] = 1'b1;
    writeEnable_input_vector[15] = 1'b0;
    writeEnable_input_vector[16] = 1'b1;
    writeEnable_input_vector[17] = 1'b0;
    writeEnable_input_vector[18] = 1'b1;
    writeEnable_input_vector[19] = 1'b0;
    writeEnable_input_vector[20] = 1'b1;
    writeEnable_input_vector[21] = 1'b0;
    writeEnable_input_vector[22] = 1'b1;
    writeEnable_input_vector[23] = 1'b0;
    writeEnable_input_vector[24] = 1'b1;
    writeEnable_input_vector[25] = 1'b0;
    writeEnable_input_vector[26] = 1'b1;
    writeEnable_input_vector[27] = 1'b0;
    writeEnable_input_vector[28] = 1'b1;
    writeEnable_input_vector[29] = 1'b0;
    writeEnable_input_vector[30] = 1'b1;
    writeEnable_input_vector[31] = 1'b0;

    //All combinations of the register select. 
    dst_input_vector[0] = 4'b0000; 
    dst_input_vector[1] = 4'b0001; 
    dst_input_vector[2] = 4'b0010; 
    dst_input_vector[3] = 4'b0011; 
    dst_input_vector[4] = 4'b0100;
    dst_input_vector[5] = 4'b0101;
    dst_input_vector[6] = 4'b0110; 
    dst_input_vector[7] = 4'b0111; 
    dst_input_vector[8] = 4'b1000; 
    dst_input_vector[9] = 4'b1001; 
    dst_input_vector[10] = 4'b1010; 
    dst_input_vector[11] = 4'b1011; 
    dst_input_vector[12] = 4'b1100; 
    dst_input_vector[13] = 4'b1101; 
    dst_input_vector[14] = 4'b1110; 
    dst_input_vector[15] = 4'b1111;
    
    src_input_vector[0] = 4'b0000;
    src_input_vector[1] = 4'b0001; 
    src_input_vector[2] = 4'b0010; 
    src_input_vector[3] = 4'b0011; 
    src_input_vector[4] = 4'b0100; 
    src_input_vector[5] = 4'b0101; 
    src_input_vector[6] = 4'b0110;
    src_input_vector[7] = 4'b0111; 
    src_input_vector[8] = 4'b1000; 
    src_input_vector[9] = 4'b1001;
    src_input_vector[10] = 4'b1010;
    src_input_vector[11] = 4'b1011; 
    src_input_vector[12] = 4'b1100; 
    src_input_vector[13] = 4'b1101; 
    src_input_vector[14] = 4'b1110; 
    src_input_vector[15] =  4'b1111;

    dstWrite_input_vector[0]  = 64'b0001110010001111101111001011111110110101010011010111000011110000;
    dstWrite_input_vector[1]  = 64'b1010111110101100001001110001010110100111011111100111000110010000; 
    dstWrite_input_vector[2]  = 64'b1100100010000001110001001000001010101001111011001000001011001110; 
    dstWrite_input_vector[3]  = 64'b1101011110001001011111111010000100000100101010010110011001000001; 
    dstWrite_input_vector[4]  = 64'b1101001100001111110111111110001111000101101010110011101010110111; 
    dstWrite_input_vector[5]  = 64'b0011101101110000011001101100001110000000101101011001010011001001; 
    dstWrite_input_vector[6]  = 64'b0001100011000110110010001110111111010001111011101111101101001000; 
    dstWrite_input_vector[7]  = 64'b0101110111011110110010011101010110010001110000110110100110110100; 
    dstWrite_input_vector[8]  = 64'b0010000010010001000000001111110010001100110111101001000100101100; 
    dstWrite_input_vector[9]  = 64'b1011000111111001001011010001110100001110000111100001011101110001; 
    dstWrite_input_vector[10] = 64'b0001001101000000011100101100111001101011010110000100011100110001; 
    dstWrite_input_vector[11] = 64'b1111000000101110110000111100100000011100000011110111011011100111; 
    dstWrite_input_vector[12] = 64'b0010110101001001000100011011000010001010010100001100011011010010; 
    dstWrite_input_vector[13] = 64'b1110110110100010011000110111111110011001001100001001010100100000; 
    dstWrite_input_vector[14] = 64'b0110001110100011010110001100100000011001110110000110111110010001; 
    dstWrite_input_vector[15] = 64'b0110001100000110100001000111111011111110010101111111100110101110; 

    end
    
    initial 
    begin
      //main testing loop. 
       for(int i=0; i<16;i++)begin
            clk <= 1'b0;
            writeEnable_input <= writeEnable_input_vector[i*2];
            dst_input <= dst_input_vector[i]; 
            dstWrite_input <= dstWrite_input_vector[i]; 
            #10
            clk <= 1'b1; 
            #10
            writeEnable_input <= writeEnable_input_vector[(i*2)+1];
            dst_input <= dst_input_vector[i];
            src_input <= src_input_vector[i]; 
            #10
            mismatch1 <= dstRead_output != dstWrite_input_vector[i];
            mismatch2 <= srcRead_output != dstWrite_input_vector[i];
            #10
            if(mismatch1) begin
                $display("Test Failed for dstRead_output. dstRead=%h \t||\t expectedOutput=%h \t||\t Test=%d",dstRead_output,dstWrite_input_vector[i],i);
            end else begin
                $display("Dst Test=%d Good",i);
            end
            if(mismatch2) begin
                $display("Test Failed for srcRead_output. srcRead=%h \t||\t expectedOutput=%h \t||\t Test=%d",srcRead_output,dstWrite_input_vector[i],i);
            end else begin
                 $display("Src Test=%d Good",i);
            end
       end
       end

endmodule

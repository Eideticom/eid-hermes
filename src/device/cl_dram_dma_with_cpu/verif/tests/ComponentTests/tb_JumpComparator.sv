`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/15/2021 12:45:52 PM
// Design Name: 
// Module Name: tb_JumpComparator
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


module tb_JumpComparator;
    
    reg [63:0]a;
    reg [63:0]b;
    reg [3:0] op;
    wire jump;
    reg expected;
    reg mismatch = '0;
    
    jump_comparator UUT (.a(a), .b(b), .op(op), .jump(jump));
    
    // duration for each bit = 20 * timescale = 20 * 1 ns  = 20ns
    localparam period = 20;
     
    initial
        begin
			a = 64'h0;
			b = 64'h0;
			op = 4'h0;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x0 b=0x0 op=0x0 expected=1 ");

			a = 64'h5;
			b = 64'h5;
			op = 4'h0;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x5 b=0x5 op=0x0 expected=1 ");

			a = 64'h80;
			b = 64'h37;
			op = 4'h0;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x80 b=0x37 op=0x0 expected=1 ");

			a = 64'h2c;
			b = 64'h231;
			op = 4'h0;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x2c b=0x231 op=0x0 expected=1 ");

			a = 64'h76b47;
			b = 64'h76b47;
			op = 4'h0;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x76b47 b=0x76b47 op=0x0 expected=1 ");

			a = 64'hd5;
			b = 64'h1;
			op = 4'h0;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0xd5 b=0x1 op=0x0 expected=1 ");

			a = 64'h7fffffffffffffff;
			b = 64'h7fffffffffffffff;
			op = 4'h0;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x7fffffffffffffff b=0x7fffffffffffffff op=0x0 expected=1 ");

			a = 64'h0;
			b = 64'h0;
			op = 4'h1;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x0 b=0x0 op=0x1 expected=1 ");

			a = 64'h5;
			b = 64'h5;
			op = 4'h1;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x5 b=0x5 op=0x1 expected=1 ");

			a = 64'h80;
			b = 64'h37;
			op = 4'h1;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x80 b=0x37 op=0x1 expected=0 ");

			a = 64'h2c;
			b = 64'h231;
			op = 4'h1;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x2c b=0x231 op=0x1 expected=0 ");

			a = 64'h76b47;
			b = 64'h76b47;
			op = 4'h1;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x76b47 b=0x76b47 op=0x1 expected=1 ");

			a = 64'hd5;
			b = 64'h1;
			op = 4'h1;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0xd5 b=0x1 op=0x1 expected=0 ");

			a = 64'h7fffffffffffffff;
			b = 64'h7fffffffffffffff;
			op = 4'h1;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x7fffffffffffffff b=0x7fffffffffffffff op=0x1 expected=1 ");

			a = 64'h0;
			b = 64'h0;
			op = 4'h2;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x0 b=0x0 op=0x2 expected=0 ");

			a = 64'h5;
			b = 64'h5;
			op = 4'h2;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x5 b=0x5 op=0x2 expected=0 ");

			a = 64'h80;
			b = 64'h37;
			op = 4'h2;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x80 b=0x37 op=0x2 expected=1 ");

			a = 64'h2c;
			b = 64'h231;
			op = 4'h2;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x2c b=0x231 op=0x2 expected=0 ");

			a = 64'h76b47;
			b = 64'h76b47;
			op = 4'h2;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x76b47 b=0x76b47 op=0x2 expected=0 ");

			a = 64'hd5;
			b = 64'h1;
			op = 4'h2;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0xd5 b=0x1 op=0x2 expected=1 ");

			a = 64'h7fffffffffffffff;
			b = 64'h7fffffffffffffff;
			op = 4'h2;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x7fffffffffffffff b=0x7fffffffffffffff op=0x2 expected=0 ");

			a = 64'h0;
			b = 64'h0;
			op = 4'h3;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x0 b=0x0 op=0x3 expected=1 ");

			a = 64'h5;
			b = 64'h5;
			op = 4'h3;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x5 b=0x5 op=0x3 expected=1 ");

			a = 64'h80;
			b = 64'h37;
			op = 4'h3;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x80 b=0x37 op=0x3 expected=1 ");

			a = 64'h2c;
			b = 64'h231;
			op = 4'h3;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x2c b=0x231 op=0x3 expected=0 ");

			a = 64'h76b47;
			b = 64'h76b47;
			op = 4'h3;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x76b47 b=0x76b47 op=0x3 expected=1 ");

			a = 64'hd5;
			b = 64'h1;
			op = 4'h3;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0xd5 b=0x1 op=0x3 expected=1 ");

			a = 64'h7fffffffffffffff;
			b = 64'h7fffffffffffffff;
			op = 4'h3;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x7fffffffffffffff b=0x7fffffffffffffff op=0x3 expected=1 ");

			a = 64'h0;
			b = 64'h0;
			op = 4'h4;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x0 b=0x0 op=0x4 expected=0 ");

			a = 64'h5;
			b = 64'h5;
			op = 4'h4;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x5 b=0x5 op=0x4 expected=1 ");

			a = 64'h80;
			b = 64'h37;
			op = 4'h4;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x80 b=0x37 op=0x4 expected=0 ");

			a = 64'h2c;
			b = 64'h231;
			op = 4'h4;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x2c b=0x231 op=0x4 expected=1 ");

			a = 64'h76b47;
			b = 64'h76b47;
			op = 4'h4;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x76b47 b=0x76b47 op=0x4 expected=1 ");

			a = 64'hd5;
			b = 64'h1;
			op = 4'h4;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0xd5 b=0x1 op=0x4 expected=1 ");

			a = 64'h7fffffffffffffff;
			b = 64'h7fffffffffffffff;
			op = 4'h4;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x7fffffffffffffff b=0x7fffffffffffffff op=0x4 expected=1 ");

			a = 64'h0;
			b = 64'h0;
			op = 4'h5;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x0 b=0x0 op=0x5 expected=0 ");

			a = 64'h5;
			b = 64'h5;
			op = 4'h5;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x5 b=0x5 op=0x5 expected=0 ");

			a = 64'h80;
			b = 64'h37;
			op = 4'h5;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x80 b=0x37 op=0x5 expected=1 ");

			a = 64'h2c;
			b = 64'h231;
			op = 4'h5;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x2c b=0x231 op=0x5 expected=1 ");

			a = 64'h76b47;
			b = 64'h76b47;
			op = 4'h5;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x76b47 b=0x76b47 op=0x5 expected=0 ");

			a = 64'hd5;
			b = 64'h1;
			op = 4'h5;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0xd5 b=0x1 op=0x5 expected=1 ");

			a = 64'h7fffffffffffffff;
			b = 64'h7fffffffffffffff;
			op = 4'h5;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x7fffffffffffffff b=0x7fffffffffffffff op=0x5 expected=0 ");

			a = 64'hf;
			b = 64'hfffffffffffffffd;
			op = 4'h6;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0xf b=0xfffffffffffffffd op=0x6 expected=1 ");

			a = 64'h0;
			b = 64'h9;
			op = 4'h6;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x0 b=0x9 op=0x6 expected=0 ");

			a = 64'hffffffffffffffff;
			b = 64'hffffffffffffffee;
			op = 4'h6;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0xffffffffffffffff b=0xffffffffffffffee op=0x6 expected=1 ");

			a = 64'h8000000000000000;
			b = 64'h8000000000000000;
			op = 4'h6;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x8000000000000000 b=0x8000000000000000 op=0x6 expected=0 ");

			a = 64'h7fffffffffffffff;
			b = 64'h8000000000000000;
			op = 4'h6;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x7fffffffffffffff b=0x8000000000000000 op=0x6 expected=1 ");

			a = 64'h8000000000000000;
			b = 64'h7fffffffffffffff;
			op = 4'h6;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x8000000000000000 b=0x7fffffffffffffff op=0x6 expected=0 ");

			a = 64'h7fffffffffffffff;
			b = 64'h7fffffffffffffff;
			op = 4'h6;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x7fffffffffffffff b=0x7fffffffffffffff op=0x6 expected=0 ");

			a = 64'hf;
			b = 64'hfffffffffffffffd;
			op = 4'h7;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0xf b=0xfffffffffffffffd op=0x7 expected=1 ");

			a = 64'h0;
			b = 64'h9;
			op = 4'h7;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x0 b=0x9 op=0x7 expected=0 ");

			a = 64'hffffffffffffffff;
			b = 64'hffffffffffffffee;
			op = 4'h7;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0xffffffffffffffff b=0xffffffffffffffee op=0x7 expected=1 ");

			a = 64'h8000000000000000;
			b = 64'h8000000000000000;
			op = 4'h7;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x8000000000000000 b=0x8000000000000000 op=0x7 expected=1 ");

			a = 64'h7fffffffffffffff;
			b = 64'h8000000000000000;
			op = 4'h7;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x7fffffffffffffff b=0x8000000000000000 op=0x7 expected=1 ");

			a = 64'h8000000000000000;
			b = 64'h7fffffffffffffff;
			op = 4'h7;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x8000000000000000 b=0x7fffffffffffffff op=0x7 expected=0 ");

			a = 64'h7fffffffffffffff;
			b = 64'h7fffffffffffffff;
			op = 4'h7;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x7fffffffffffffff b=0x7fffffffffffffff op=0x7 expected=1 ");

			a = 64'h0;
			b = 64'h0;
			op = 4'ha;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x0 b=0x0 op=0xa expected=0 ");

			a = 64'h5;
			b = 64'h5;
			op = 4'ha;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x5 b=0x5 op=0xa expected=0 ");

			a = 64'h80;
			b = 64'h37;
			op = 4'ha;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x80 b=0x37 op=0xa expected=0 ");

			a = 64'h2c;
			b = 64'h231;
			op = 4'ha;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x2c b=0x231 op=0xa expected=1 ");

			a = 64'h76b47;
			b = 64'h76b47;
			op = 4'ha;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x76b47 b=0x76b47 op=0xa expected=0 ");

			a = 64'hd5;
			b = 64'h1;
			op = 4'ha;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0xd5 b=0x1 op=0xa expected=0 ");

			a = 64'h7fffffffffffffff;
			b = 64'h7fffffffffffffff;
			op = 4'ha;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x7fffffffffffffff b=0x7fffffffffffffff op=0xa expected=0 ");

			a = 64'h0;
			b = 64'h0;
			op = 4'hb;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x0 b=0x0 op=0xb expected=1 ");

			a = 64'h5;
			b = 64'h5;
			op = 4'hb;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x5 b=0x5 op=0xb expected=1 ");

			a = 64'h80;
			b = 64'h37;
			op = 4'hb;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x80 b=0x37 op=0xb expected=0 ");

			a = 64'h2c;
			b = 64'h231;
			op = 4'hb;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x2c b=0x231 op=0xb expected=1 ");

			a = 64'h76b47;
			b = 64'h76b47;
			op = 4'hb;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x76b47 b=0x76b47 op=0xb expected=1 ");

			a = 64'hd5;
			b = 64'h1;
			op = 4'hb;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0xd5 b=0x1 op=0xb expected=0 ");

			a = 64'h7fffffffffffffff;
			b = 64'h7fffffffffffffff;
			op = 4'hb;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x7fffffffffffffff b=0x7fffffffffffffff op=0xb expected=1 ");

			a = 64'hf;
			b = 64'hfffffffffffffffd;
			op = 4'hc;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0xf b=0xfffffffffffffffd op=0xc expected=0 ");

			a = 64'h0;
			b = 64'h9;
			op = 4'hc;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x0 b=0x9 op=0xc expected=1 ");

			a = 64'hffffffffffffffff;
			b = 64'hffffffffffffffee;
			op = 4'hc;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0xffffffffffffffff b=0xffffffffffffffee op=0xc expected=0 ");

			a = 64'h8000000000000000;
			b = 64'h8000000000000000;
			op = 4'hc;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x8000000000000000 b=0x8000000000000000 op=0xc expected=0 ");

			a = 64'h7fffffffffffffff;
			b = 64'h8000000000000000;
			op = 4'hc;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x7fffffffffffffff b=0x8000000000000000 op=0xc expected=0 ");

			a = 64'h8000000000000000;
			b = 64'h7fffffffffffffff;
			op = 4'hc;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x8000000000000000 b=0x7fffffffffffffff op=0xc expected=1 ");

			a = 64'h7fffffffffffffff;
			b = 64'h7fffffffffffffff;
			op = 4'hc;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x7fffffffffffffff b=0x7fffffffffffffff op=0xc expected=0 ");

			a = 64'hf;
			b = 64'hfffffffffffffffd;
			op = 4'hd;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0xf b=0xfffffffffffffffd op=0xd expected=0 ");

			a = 64'h0;
			b = 64'h9;
			op = 4'hd;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x0 b=0x9 op=0xd expected=1 ");

			a = 64'hffffffffffffffff;
			b = 64'hffffffffffffffee;
			op = 4'hd;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0xffffffffffffffff b=0xffffffffffffffee op=0xd expected=0 ");

			a = 64'h8000000000000000;
			b = 64'h8000000000000000;
			op = 4'hd;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x8000000000000000 b=0x8000000000000000 op=0xd expected=1 ");

			a = 64'h7fffffffffffffff;
			b = 64'h8000000000000000;
			op = 4'hd;
			expected = '0;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x7fffffffffffffff b=0x8000000000000000 op=0xd expected=0 ");

			a = 64'h8000000000000000;
			b = 64'h7fffffffffffffff;
			op = 4'hd;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x8000000000000000 b=0x7fffffffffffffff op=0xd expected=1 ");

			a = 64'h7fffffffffffffff;
			b = 64'h7fffffffffffffff;
			op = 4'hd;
			expected = '1;
			#period;
			mismatch = jump != expected;
			if(mismatch)
				 $display("test failed for inputs: a=0x7fffffffffffffff b=0x7fffffffffffffff op=0xd expected=1 ");
        
        end
endmodule

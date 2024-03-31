`timescale 1ns / 1ps
module top(
    input [4:1]A,
    input [4:1]B,
    input clk,
    input st,
    input rst,
    output [5:1]out
    );
    wire [7:1]T;
    serial_adder_fsm Control_Unit(clk, st, rst, T[7:1]);                                // Defining the Control Unit
    
    wire W1;
    or O1(W1, T[2], T[3], T[4], T[5], T[6]);
    serial_adder LogicUnit(A[4:1], B[4:1], clk, T[1], W1, T[7], st, rst, out[5:1]);     // Defining the Logic Unit
endmodule

// Code for FSM
module serial_adder_fsm(
    input clk,
    input st,
    input rst,
    output [7:1]T
    );
    
    wire W;
    wire [7:1]Tbar;
    ms_d_ff FF1( 0   , clk,rst,  st, T[1], Tbar[1]);
    ms_d_ff FF2( T[1], clk, st, rst, T[2], Tbar[2]);
    ms_d_ff FF3( T[2], clk, st, rst, T[3], Tbar[3]);
    ms_d_ff FF4( T[3], clk, st, rst, T[4], Tbar[4]);
    ms_d_ff FF5( T[4], clk, st, rst, T[5], Tbar[5]);
    ms_d_ff FF6( T[5], clk, st, rst, T[6], Tbar[6]);
    
    wire W1;
    or O1(W1, T[6], T[7]);
    ms_d_ff FF7( W1, clk, st, rst, T[7], Tbar[7]);
endmodule

// Code for serial_adder with separate inputs for InputLoading, Shift Right, and BufferOutput controls.
// This code is done with the aim of integrating these aforementioned controls with a one-hot-encoded FSM
`timescale 1ns / 1ps

module serial_adder(
    input [4:1]A,
    input [4:1]B,
    input clk,
    input L,
    input SR,
    input Bi,
    input st,
    input rst,
    output [5:1]out
    );
    
    wire [4:1]Aout;
    wire [4:1]Bout;
    wire Cin, Cout, Cinbar;
    rshiftregister RegA  (A[4:1], clk, L, SR, st, rst, Aout[4:1]);
    rshiftregister RegB  (B[4:1], clk, L, SR, st, rst, Bout[4:1]);
    
    full_adder FA(Aout[1], Bout[1], Cin, Sum, Cout);         // Note Aout/Bout[1] is the the LSB
    ms_d_ff DFF(Cout, clk, st, rst, Cin, Cinbar);
    
    rshiftregister5bit RegOut(Sum, clk, Bi, SR, st, rst, out[5:1]);
endmodule

// This is the code for a 4 bit shift register with load and shift right mode
module rshiftregister(
    //input q,             // Shift Right Input
    input [4:1]X,        // parallel inputs
    input clk,           // clk input 
    input L,             // load selection
    inout SR,            // shift right/buffer selection input
    input st,            // set input
    input rst,           // reset input
    output [4:1]out      // serial ouput (one bit at a time)
    );                   // therefore only out[0] the LSB is required
    wire W0, W1, W2, W3;
    wire [4:1]outbar;
    
	
	muxsp m4(X[4], 0     ,L ,SR , W3);  
	muxsp m3(X[3], out[4],L ,SR , W2);
	muxsp m2(X[2], out[3],L ,SR , W1);
	muxsp m1(X[1], out[2],L ,SR , W0);	
        
    ms_d_ff df3(W3, clk, st, rst, out[4], outbar[4]);
    ms_d_ff df2(W2, clk, st, rst, out[3], outbar[3]);
    ms_d_ff df1(W1, clk, st, rst, out[2], outbar[2]);
    ms_d_ff df0(W0, clk, st, rst, out[1], outbar[1]);
        
endmodule

// This is the code for a 5 bit shift register with buffer and shift right mode
module rshiftregister5bit(
    input q,             // Shift Right Input
    //input [4:1]X,      // This is a right shift register so parallel inputs are commented
    input clk,           // clk input 
    input B,
    input T,             // shift right selection input
    input st,            // set input
    input rst,           // reset input
    output [5:1]out      // serial ouput (one bit at a time)
    );                   // therefore only out[0] the LSB is required
    wire W0, W1, W2, W3, W4;
    wire [5:1]outbar;
    
	muxsp m5(out[5], q     ,B ,T , W4);  	
	muxsp m4(out[4], out[5],B ,T , W3);  
	muxsp m3(out[3], out[4],B ,T , W2);
	muxsp m2(out[2], out[3],B ,T , W1);
	muxsp m1(out[1], out[2],B ,T , W0);	
        
    ms_d_ff df4(W4, clk, st, rst, out[5], outbar[5]);
    ms_d_ff df3(W3, clk, st, rst, out[4], outbar[4]);
    ms_d_ff df2(W2, clk, st, rst, out[3], outbar[3]);
    ms_d_ff df1(W1, clk, st, rst, out[2], outbar[2]);
    ms_d_ff df0(W0, clk, st, rst, out[1], outbar[1]);
        
endmodule

// Module for full adder
module full_adder(
    input a,
    input b,
    input cin,
    output sum,
    output cout
    );
    
    wire W1, W2, W3;
    
    xor X1(sum, a, b, cin);
    and A1(W1, a, b);
    xor X2(W2, a, b);
    and A2(W3, W2, cin);
    or O1(cout, W1, W3);  
endmodule


// Module for special MUX
module muxsp( 
    input input1,
    input input2,
    input load, 
    input shiftright,        
    output out
    );
    wire W1, W2;
    and AND1(W1, input1, load);
    and AND2(W2, input2, shiftright);
    or OR1(out, W1, W2);
endmodule

// Module for edge triggered d flip flop
module ms_d_ff(
input d, input clk, input st, input rst, output q, output qbar
    );
    reg a;
    assign q = a;
    assign qbar = ~a;
    always @(posedge clk) begin
        if (st==1) a <=1;
        else if (rst==1) a<=0;
        else a <= d; 
    end
endmodule



`timescale 1ns / 1ps
module final(
    input a,         // Control unit Input
    input b,         // Control unit Input
    input [4:1]X,    // Logic unit Input
    input clk,
    input st,
    input rst,
    output [4:1]Z    // Output
    );
    
    wire [4:1]T;
    FSM fsm(a,b,clk, st, rst, T);
    RShiftLU LU(X,T,clk,st,rst,Z);
endmodule

// Control Unit
module FSM(
    input a,
    input b,
    input clk,
    input st,
    input rst,
    output [4:1]T
    );
    wire [4:1]Tbar;
    wire W1, W2;
    and A0(W1, ~a, ~b, T[1]);    
    or O1(W2, W1, T[4]);
    ms_d_ff M0(W2, clk, rst, st, T[1], Tbar[1]); //the first ff
    // Note how set and rst are interchanged in order to set state T[1]
    and A1(W3, a, T[1]); 
    ms_d_ff M1(W3, clk, st, rst, T[2], Tbar[2]); //the second ff
    
    and A2(W4, b, T[2]);
    ms_d_ff M2(W4, clk, st, rst, T[3], Tbar[3]); //the third ff
    
    and A4(W5, ~a, b, T[1]);
    and A5(W6, a, ~b, T[2]);
    or A6(W7, W5, W6, T[3]);
    ms_d_ff M3(W7, clk, st, rst, T[4], Tbar[4]); //the fourth ff
endmodule

// DataUnit
module RShiftLU(
    input [3:0]X,
    input [4:1]T,
    input clk,
    input st,
    input rst,
    output [4:1]Z
    );
    
    wire W1;
    wire [4:1]out;
    or G1(W1, T[2], T[3]);
    rshiftregister R1(X, clk, T[1], W1, st, rst, out);
    
    bufif1 buffer1(Z[1], out[1], T[4]);
    bufif1 buffer2(Z[2], out[2], T[4]);
    bufif1 buffer3(Z[3], out[3], T[4]);
    bufif1 buffer4(Z[4], out[4], T[4]);
endmodule

`timescale 1ns / 1ps
// This is the code for a 4 bit shift register with load input
module rshiftregister(
    //input q,           // Shift Right Input is commented out
                         // as in this application, we want to rotate
                         // the vectors only
    input [4:1]X,
    input clk,  
    input T0,         // clk input  
    input T1,             // shift right/buffer selection input
    input st,            // set input
    input rst,           // reset input
    output [4:1]out      // ouput
    );
    wire W0, W1, W2, W3;
    wire [4:1]outbar;
    
	muxsp m1(X[1], out[4],T0, T1, W0);  
	muxsp m2(X[2], out[1],T0, T1, W1);
	muxsp m3(X[3], out[2],T0, T1, W2);
	muxsp m4(X[4], out[3],T0, T1, W3);
        
    ms_d_ff df0(W0, clk, st, rst, out[1], outbar[1]);
    ms_d_ff df1(W1, clk, st, rst, out[2], outbar[2]);
    ms_d_ff df2(W2, clk, st, rst, out[3], outbar[3]);
    ms_d_ff df3(W3, clk, st, rst, out[4], outbar[4]);
    
endmodule

// Module for special MUX with dual selecting inputs
module muxsp( 
    input input1,
    input input2,
    input load0,
    input load1,
    output out
    );
    wire W1, W2;
    and AND1(W1, input1, load0);
    and AND2(W2, input2, load1);
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
// This code has succesfully fixed the problem of combinational loop
// by employing some behavioural modelling in the d_ff module


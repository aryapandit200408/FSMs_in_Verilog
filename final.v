`timescale 1ns / 1ps
// Module for Final Unit (top)
module final(
    input [3:0]X,
    input clk,
    input st,
    input rst,
    output [4:1]Zee,
    inout S,
    inout [4:1]T
    );
//    wire S;
//    wire [4:1]T;
    FSM_OneHot ControlUnit(S, clk, st, rst, T[4:1]);
    top LogicUnit(X[3:0], T[4:1], clk, st, rst, S, Zee[4:1]);
endmodule

// Module for Control Unit
module FSM_OneHot(
    input S,
    input clk,
    input set,
    input rst,
    output [4:1]Zee
    );
    wire [4:1]Zeebar;
    wire W1, W2;
    mux s_mux(Zee[4], Zee[3] , S, W1);
    mux s1_mux(Zee[3], 0, S, W2);
    ms_d_ff M0(W1  , clk, rst, set, Zee[1], Zeebar[1]); //the first ff
    // Note how set and rst are interchanged in order to set state T[1]
    // while other resting 
    ms_d_ff M1(Zee[1], clk, set, rst, Zee[2], Zeebar[2]); //the second ff
    ms_d_ff M2(Zee[2], clk, set, rst, Zee[3], Zeebar[3]); //the third ff
    ms_d_ff M3(W2  , clk, set, rst, Zee[4], Zeebar[4]); //the fourth ff     
endmodule

// Module for Logic Unit
module top(
    input [3:0]X,
    input [4:1]T,
    input clk,
    input set,
    input rst,
    output S,
    output  [4:1]Zee
    );
    wire [3:0]R;
    wire W2, W3, Sbar;
    register R1(X, clk, T[1], set, rst, R);
    or(W2, R[3],R[0]);
    d_ff s(W2, T[2], set, rst, S, Sbar);
    bufif1 buffer1(Zee[1], R[0], T[4] );
    bufif1 buffer2(Zee[2], R[1], T[4] );
    bufif1 buffer3(Zee[3], R[2], T[4] );
    bufif1 buffer4(Zee[4], R[3], T[4] );   
endmodule

// Module for Buffer Register with Load Control
module register(
    input [3:0]q, 
    input clk, 
    input T,
    input st,
    input rst,
    output [3:0]out
    );
    wire W0, W1, W2, W3;
    wire [3:0]outbar;

    mux m1(q[0], out[0], T, W0);
    mux m2(q[1], out[1], T, W1);
    mux m3(q[2], out[2], T, W2);
    mux m4(q[3], out[3], T, W3);
    ms_d_ff df0(W0, clk, st, rst, out[0], outbar[0]);
    ms_d_ff df1(W1, clk, st, rst, out[1], outbar[1]);
    ms_d_ff df2(W2, clk, st, rst, out[2], outbar[2]);
    ms_d_ff df3(W3, clk, st, rst, out[3], outbar[3]);
endmodule

// Module for MUX
module mux( 
    input input1,
    input input2,
    input load,
    output out
    );
    wire W1, W2;
    and AND1(W1, input1, load);
    and AND2(W2, input2, ~load);
    or OR1(out, W1, W2);
endmodule

// Module for ms d filp flop
module ms_d_ff(
input d, input clk,input st, input rst, output q, output qbar
    );
    wire MS1, MS2;
    d_ff mdff(d , clk, st, rst, MS1, MS2);
    d_ff sdff(MS1, ~clk, st, rst, q, qbar);
endmodule

// Module for level triggered d flip flop
module d_ff(input d, input clk, input st, input rst, output  q, output qbar);
    wire W1, W2;
    and N1(W1, d, clk);
    and N2(W2, ~d, clk);
    nand N3(q, qbar, ~W1, st); //We Choose Active Low for set
    nand N4(qbar, q, ~W2, rst); //We Choose Active Low for rst
endmodule

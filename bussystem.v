`timescale 1ns / 1ps
module system(
    input [4:1]in,
    input [4:1]l,
    input [4:1]en,
    input pst,
    input rst,
    input clk,
    output [4:1]Z
    );
    
    wire [4:1]Ao;
    wire [4:1]Bo;
    wire [4:1]BUS;
    
    tristate_load_reg C(in, clk, l[3], en[3], pst, rst, BUS);
    
    tristate_load_reg A(BUS, clk, l[1], en[1], pst, rst, BUS);
    
    tristate_load_reg B(BUS, clk, l[2], en[2], pst, rst, BUS);
    
    tristate_load_reg D(BUS, clk, l[4], en[4], pst, rst, Z);
    
endmodule

// Module for tristate buffer output load register
module tristate_load_reg(
    input [4:1]X,
    input clk,           // clk input             
    input L,             // load input
    input EN,            // enable input
    input st,            // set input
    input rst,           // reset input
    output [4:1]Z        // ouput
    );
    wire W0, W1, W2, W3;
    wire [4:1]out;    
    wire [4:1]outbar;
    
    // Note that the load input is made to be active low
  	mux m1(X[1], out[1], L, W0);  
  	mux m2(X[2], out[2], L, W1);
  	mux m3(X[3], out[3], L, W2);
  	mux m4(X[4], out[4], L, W3);
        
    ms_d_ff df0(W0, clk, st, rst, out[1], outbar[1]);
    ms_d_ff df1(W1, clk, st, rst, out[2], outbar[2]);
    ms_d_ff df2(W2, clk, st, rst, out[3], outbar[3]);
    ms_d_ff df3(W3, clk, st, rst, out[4], outbar[4]);

    // Note that the enable input in made to be active low
    bufif0 BUF1(Z[1], out[1], EN);
    bufif0 BUF2(Z[2], out[2], EN);
    bufif0 BUF3(Z[3], out[3], EN);
    bufif0 BUF4(Z[4], out[4], EN);
    
endmodule

// Module for MUX
module mux( 
    input input1,
    input input2,
    input load,
    output out
    );
    wire W1, W2;
    and AND1(W1, input1, ~load);
    and AND2(W2, input2, load);
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


## Design of a bus-based system in Verilog

<b>Aim</b>: To design and implement a bus-based system in Verilog

Design a 4-bit bus-based system consisting of two 4-bit registers A and B, one input unit consisting of 4 nos. of toggle switches, and one output unit

Perform the following:
1) Load register A by 2H (through the input unit).
2) Display the content of register A (on the output unit).
3) Load register B by 0H.
4) Display the content of register B.
5) Transfer the content of register A into register B.
6) Display the content of register B.

<div align="center">

![image](https://github.com/aryapandit200408/FSMs_in_Verilog/assets/115896451/849b43e2-01fe-49c0-aa70-8730b2e21aa1)


An illustration of the Machine in NM Multisim 14
</div>

<b>Design:-</b>
The design shall contain four tristate activated buffer registers let the input one be C, storing ones be A and B and the output be D

The structure of a tristate output loading register:-
Code:-
```verilog
`timescale 1ns / 1ps
module tristate_load_reg(
    input [4:1]X,
    input clk,          // clk input             
    input L,            // load input
    input EN,           // enable input
    input st,           // set input
    input rst,          // reset input
    output [4:1]Z       // output
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

    // Note that the enable input is made to be active low
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
```

The Elaborated Design:-

![image](https://github.com/aryapandit200408/FSMs_in_Verilog/assets/115896451/91edae0d-385c-49f9-a0b6-16450c0b2c38)




The System Unit:

Code:-
```verilog
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
```
The Elaborated Design:-

![image](https://github.com/aryapandit200408/FSMs_in_Verilog/assets/115896451/6e5f385f-4611-4e08-828f-ed7530f413d7)


<b>Testing for Functional Coverage (Using Behavioral Simulations):-</b>

Testbench Code:-

```verilog
`timescale 1ns / 1ps
module tb(
    );
    reg [4:1]in             ;
    reg [4:1]l = 4'b1111    ;
    reg [4:1]en = 4'b1111   ;
    reg pst                 ;
    reg rst                 ;
    reg clk                 ;
    wire [4:1]Z             ;
    
    system DUT(in, l, en, pst, rst, clk, Z);
    
    initial begin
    clk <= 0; 
    forever begin 
    #5
    clk = ~clk;
    end
    end
    
    initial begin
        pst <= 0;
        rst <= 0;
        #40
        // Loading BUS with 0010
        in = 4'b0010;
        l = 4'b1011;
        en = 4'b1011;
        #40
        // Loading Register with A
        l = 4'b1110;
        en = 4'b1011;
        #40
        // Loading BUS with 0000
        in = 4'b0000;
        l = 4'b1011;
        en = 4'b1011;
        #40
        // Loading Register with B
        l = 4'b1101;
        en = 4'b1011;
        #40
        // Ensuring the output of Reg A to the BUS
        l = 4'b1111;
        en = 4'b1110;
        #40
        l = 4'b0111;
        en = 4'b0110;
        
        end
        
endmodule

```

Running Simulations:-

![image](https://github.com/aryapandit200408/FSMs_in_Verilog/assets/115896451/c61ffb90-57c5-4b38-b0d2-93e340ca6960)




<b>Conclusion:-</b> The design has achieved functional coverage!!! yet again!!!

### Next Step: Implementing in FPGA:-

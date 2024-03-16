## FSM 2: Vector Transfer Operations-

<b>Aim</b>: To design and implement a digital system whose RTL Program is given

Given RTL Program Steps:-

![image](https://github.com/aryapandit200408/FSMs_in_Verilog/assets/115896451/d356c282-49a5-4180-91ea-6fea8b7ad79e)

<b>Detailed Explanation of the program steps:-</b>
1. If a = 0, b = 0 then control remains in T1
2. If a = 0, b = 1 then control moves to the lat state T4 then again to T1 for a fresh start
3. If a = 1, then the control moves to a new state T2
4. If b = 0, from T2, the control goes to state where another right rotation takes place by one-bit then to state T4
5. If b = 1, from T2, the control goes to state T3 then to T4
5. At state T4 a bus transfer takes place where contents of register R are put on the bus Z and we go back to state T1. Unless loaded, Z shall remain in an unconnected (Z) state

<div align="center">
  
![image](https://github.com/aryapandit200408/FSMs_in_Verilog/assets/115896451/39f6f319-fe02-4838-b3d0-6a80745ac281)


An illustration of the FSM
</div>

For this purpose we employ one hot encoding scheme. Let the states be T1, T2, T3, T4 etc

<b>Design:-</b>
We seperate athe design into a Control Unit (FSM) and Logic Unit. The Control Unit (CU) shall control the FSM and the Logic Unit (LU) shall output the value of S = R[0] | R[3] into CU. The CU in-turn shall input the state T into LU.

The Control Unit:

Code:-
```verilog
`timescale 1ns / 1ps
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
```

The Elaborated Design:-

![image](https://github.com/aryapandit200408/FSMs_in_Verilog/assets/115896451/40bb3344-7987-4bec-b726-d434328b5980)



The Logic Unit:

Code:-
```verilog
`timescale 1ns / 1ps
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

    // Trisate buffer activated by T4 state
    bufif1 buffer1(Z[1], out[1], T[4]);    
    bufif1 buffer2(Z[2], out[2], T[4]);
    bufif1 buffer3(Z[3], out[3], T[4]);
    bufif1 buffer4(Z[4], out[4], T[4]);
endmodule

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

// This code has successfully fixed the problem of the combinational loop
// During the time of bitstream generation
// by employing some behavioral modelling in the d_ff module

```
The Elaborated Design:-

![image](https://github.com/aryapandit200408/FSMs_in_Verilog/assets/115896451/b19a5fb0-d20f-4d0a-abcb-b2e6793c6840)


The Top Module:- (Connecting CU and LU)

Code:-
```verilog
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

```

Elaborated Design:-

![image](https://github.com/aryapandit200408/FSMs_in_Verilog/assets/115896451/0f7db5da-5f45-4e55-8821-efd16f1b2170)


<b>Testing for Functional Coverage (Using Behavioral Simulations):-</b>

Testbench Code:-

```verilog
`timescale 1ns / 1ps
module tb_fsm();
    reg a;
    reg b;
    reg [3:0]X;
    reg clk;
    reg st  =0 ;
    reg rst = 1;
    wire [4:1]T;
    
    final DUT(a, b, X,clk, st, rst, T[4:1]);
    initial begin
    clk=1'b0;
    forever  begin  
    #10; 
    clk = ~clk;
    end
    end

    initial begin
    X <= 4'b0101; 
    #10  
    st <= 0;
    rst <= 0;
    #10
    a <=0;
    b <=0;
    #45
    st <=0;
    #150  
    a = 0;
    b = 0;
    
    #150
    a = 1;
    b = 1;
    
    #150
    a = 0;
    b = 1;
    
    #150
    a = 1;
    b = 0;
    
    
    end
endmodule
```

Running Simulations:-

![image](https://github.com/aryapandit200408/FSMs_in_Verilog/assets/115896451/da34e588-b8bb-4ec1-aa8a-fcb7798218b6)


<b>Conclusion:-</b> The design has achieved functional coverage!!! yet again!!!

### Next Step: Implementing in FPGA:-


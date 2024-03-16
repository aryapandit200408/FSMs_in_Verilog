## FSM 1:-

<b>Aim</b>: To design and implement a digital system whose RTL Program is given

Given RTL Program Steps:-
1. R <--X
2. S <-- R[0] | R[3]
3. nul -> (S,~S)/(4,1)
4. Z = R --> (1)

<b>Detailed Explaination of the program steps:-</b>
1. There are a total of 4 time steps requiring a 4 state control unit
2. At state T1 contents of external vector input X gets stored into register R
3. At state T2 the logical OR of the Oth bit and 3rd bit of register R is stored into a register S
4. At state T3 a conditional jump occurs if S is 1 after step 2 then we jump to state T4 or if S is 0 we jump to state T1
5. At state T4 a bus transfer takes place where contents of register R is put on the bus Z and we go back to state T1. Unless loaded, Z shall remain in an unconnected (Z) state

<div align="center">
  
  ![image](https://github.com/aryapandit200408/FSMs_in_Verilog/assets/115896451/c812b4eb-e2d2-45a2-a83f-3342fa554106)

An illustration of the FSM
</div>

For this purpose we employ one hot encoding scheme. Let the states be T1, T2, T3, T4 etc

<b>Design:-</b>
We seperate athe design into a Control Unit (FSM) and Logic Unit. The Control Unit (CU) shall control the FSM and the Logic Unit (LU) shall output the value of S = R[0] | R[3] into CU. The CU in-turn shall input the state T into LU.

![image](https://github.com/aryapandit200408/FSMs_in_Verilog/assets/115896451/d1ee09e2-abec-49da-9ca7-4c18cce7b580)


The Control Unit:

Code:-
```verilog
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
```

The Elaborated Design:-

![image](https://github.com/aryapandit200408/FSMs_in_Verilog/assets/115896451/954394d9-60f5-44a9-93f6-d20a7170bd76)

The Logic Unit:

Code:-
```verilog
`timescale 1ns / 1ps
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
```
The Elaborated Design:-

![image](https://github.com/aryapandit200408/FSMs_in_Verilog/assets/115896451/3c23cacb-762d-4b43-a9b5-ae3b8ba739a0)

The Top Module:- (Connecting CU and LU)

Code:-
```verilog
`timescale 1ns / 1ps

module final(
    input [3:0]X,
    input clk,
    input st,
    input rst,
    output [4:1]Zee,
    inout S,
    inout [4:1]T
    );
    FSM_OneHot ControlUnit(S, clk, st, rst, T[4:1]);
    top LogicUnit(X[3:0], T[4:1], clk, st, rst, S, Zee[4:1]);
endmodule
```

Elaborated Design:-

![image](https://github.com/aryapandit200408/FSMs_in_Verilog/assets/115896451/ce856c24-65fc-458f-8a1a-e36a50d7336c)

<b>Testing for Functional Coveage (Using Behavioral Simulations):-</b>

Testbench Code:-

```verilog
`timescale 1ns / 1ps

module tb_fsm();
    reg [3:0]X;
    reg clk;
    reg set=1;
    reg rst=0;
    wire [4:1]Z;
    wire S;
    wire [4:1]T;
    
    final DUT(X[3:0], clk, set, rst, Z[4:1], S, T[4:1]);
    initial begin
    clk=1'b0;
    forever  begin  
    #10; 
    clk = ~clk;
    end
    end
    
    initial begin
    X <= 4'b0101;   
    #45
    set <= 1;
    rst <= 1;
    #150
    X <= 4'b0000; 
    #150
    X <= 4'b1000;  
    end
endmodule
```

Running Simulations:-

![image](https://github.com/aryapandit200408/FSMs_in_Verilog/assets/115896451/2d9b8e65-fcd8-4538-a0e7-110a58123ae8)
<b>Conclusion:-</b> The design has achieved functional coverage!!!

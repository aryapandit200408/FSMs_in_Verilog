# FSMs_in_Verilog

### This is a repo on my projects on FSM Design in Verilog

## FSM 1:-

Aim: To design and implement a digital system whose RTL Program is given

Given RTL Program Steps:-
1. R <--X
2. S <-- R[0] | R[3]
3. nul -> (S,~S)/(4,1)
4. Z = R --> (1)

Detailed Explaination of the program steps:-
1. There are a totoal of 4 time steps requiring a 4 state control unit
2. At state T1 contents of external vector input X gets stored into register R
3. At state T2 the logical OR of the Oth bit and 3rd bit of register R is stored into a register S
4. At state T3 a conditional jump occurs if S is 1 after step 2 then we jump to state T4 or if S is 0 we jump to state T1
5. At state T4 a bus transfer takes place where contents of register R is put on the bus Z and we go back to state T1

<div align="center">
![image](https://github.com/aryapandit200408/FSMs_in_Verilog/assets/115896451/c812b4eb-e2d2-45a2-a83f-3342fa554106)

An illustration of the FSM
</div>

For this purpose we employ one hot encoding scheme. Let the states be T1, T2, T3, T4 etc




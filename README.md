Verilog HDL used with Artix-7 FPGA to simulate calculator with 8 operations (add, subtract, multiply, divide, and, or, xor, divisor).

Inputs: 
- two 4-bit numbers "a" and "b"
- 1-bit selector bit for order of numbers (left or right of operand) "order"
- 3-bit selector bit to choose which operation "operation"
- clock and enable "clk" and "en" for BIN2BCD FSM and Multi-Digit Display timing

Outputs:
- 7-bit 7-seg display output "seg"
- 4-bit anode selector for 7-seg display "an"

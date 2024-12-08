`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2024 02:24:06 PM
// Design Name: 
// Module Name: calculator_tb
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


module calculator_tb;
  reg clk, en;
  reg [2:0] operation;
  reg [3:0] a, b;
  wire [6:0] seg;
  wire [3:0] an;
  
  calculator uut(clk, en, operation, a, b, seg, an);
  initial begin
    clk = 0;
    operation = 0;
    en = 0;
    a=5;
    b=4;
    forever #5 clk = ~clk;
  end
  
  
  initial begin
    #10 en = 1;
    #100000 operation = 1;
    #100000 operation = 2;
    #100000 operation = 3;
    #100000 operation = 4;
    #100000 operation = 5;
    #100000 operation = 6;
    #100000 operation = 7;
    #100000 $stop;
  end
endmodule

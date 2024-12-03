`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2024 02:29:45 PM
// Design Name: 
// Module Name: calculator
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


module calculator(
    input clk, en,
    input [2:0] operation,
    input [3:0] a, b,
    output [6:0] seg,
    output [3:0] an
    );
    wire [7:0] p;
    wire [3:0] sum;
    wire co;
    reg [11:0] bin = 0;
    wire [15:0] bcd;
    wire rdy;
    
    bit4_FA(a,b,0, sum, co);
    comb_mult uut1(a,b,p);
    bin2bcd uut2(clk, en, bin, bcd, rdy);
    lab5 uut3(bcd, clk, seg, an);
    
    always @(*) begin
        case(operation)
        0: //add
            bin = {7'b0,co,sum};
        1: //subtract
            bin = a-b;
        2: //multiply
            bin = {4'b0000,p};
        3: //divide
            bin = 3;
        4: //and
        ;
        5: //or
        ;
        6: //xor
        ;
        7: //nand
        ;
        endcase
    end
    
endmodule


//4 bit adder
module bit4_FA(
    input [3:0]a,b,
    input ci,
    output[3:0]sum,
    output co
    );
    wire c0, c1, c2;
    FA a0(a[0],b[0],ci,sum[0],c0);
    FA a1(a[1],b[1],c0,sum[1],c1);
    FA a2(a[2],b[2],c1,sum[2],c2);
    FA a3(a[3],b[3],c2,sum[3],co);
endmodule
//1 bit adder
module FA(
    input a,b,ci,
    output sum,co
    );
    assign sum=a^b^ci;
    assign co=(a&b)|(a&ci)|(b&ci);
endmodule








module comb_mult(
    input [3:0] a, b,
    output [7:0] p
    );
    wire [0:0] a0b0, a1b0, a2b0, a3b0, a0b1, a1b1, a2b1, a3b1, a0b2, a1b2, a2b2, a3b2, a0b3, a1b3, a2b3, a3b3;
    wire[7:0] pp1, pp2, pp3, pp4;
    assign a0b0 = a[0]*b[0]; assign a1b0 = a[1]*b[0]; assign a2b0 = a[2]*b[0]; assign a3b0 = a[3]*b[0]; 
    assign a0b1 = a[0]*b[1]; assign a1b1 = a[1]*b[1]; assign a2b1 = a[2]*b[1]; assign a3b1 = a[3]*b[1];  
    assign a0b2 = a[0]*b[2]; assign a1b2 = a[1]*b[2]; assign a2b2 = a[2]*b[2]; assign a3b2 = a[3]*b[2]; 
    assign a0b3 = a[0]*b[3]; assign a1b3 = a[1]*b[3]; assign a2b3 = a[2]*b[3]; assign a3b3 = a[3]*b[3];   
    
    assign pp1 = {4'b0, a3b0, a2b0, a1b0, a0b0};
    assign pp2 = {3'b0, a3b1, a2b1, a1b1, a0b1, 1'b0};
    assign pp3 = {2'b0, a3b2, a2b2, a1b2, a0b2, 2'b0};
    assign pp4 = {1'b0, a3b3, a2b3, a1b3, a0b3, 3'b0};
    
    
    assign p = pp1+pp2+pp3+pp4;
    
endmodule










module bin2bcd(
    input clk, en,
    input [11:0] bin,
    output reg [15:0] bcd,
    output reg rdy
    );
    parameter [2:0] idle = 0, setup = 1, add = 2, shift = 3, done = 4;
    reg [2:0] ps = 0,ns;
    parameter [3:0] max_shift = 12;
    reg [3:0] shifts = 0;
    reg busy;
    reg [27:0] bcd_bin, bcd_bin_mem;
    always @(posedge clk)
    begin
        ps<=ns;
        bcd_bin_mem<=bcd_bin;
        if(ps==idle)begin
            shifts <= 0;
            bcd_bin_mem <= {16'b0,bin};
        end
        
        if(rdy)
        begin
            bcd<=bcd_bin_mem[27:12];
        end
        
        if(ns==shift)
            shifts<=shifts+1;
    end
    

    
    always @(*)
    begin
        bcd_bin = bcd_bin_mem;
        case(ps)
        
            idle:
            begin
                busy = 0;
                rdy = 0;
                if(en)
                    ns=setup;
                else
                    ns = idle;
            end
            
            setup:
            begin
                busy = 1;
                rdy = 0;
                if(en)
                    ns=add;
                else
                    ns = idle;
            end
            
            add:
            begin
                busy = 1;
                rdy = 0;
                if(bcd_bin_mem[15:12] > 4)
                    bcd_bin[27:12] = bcd_bin_mem[27:12] + 3;
                if(bcd_bin_mem[19:16] > 4)
                    bcd_bin[27:16] = bcd_bin_mem[27:16] + 3;  
                if(bcd_bin_mem[23:20] > 4)
                    bcd_bin[27:20] = bcd_bin_mem[27:20] + 3;
                if(bcd_bin_mem[27:24] > 4)
                    bcd_bin[27:24] = bcd_bin_mem[27:24] + 3;
                    
                    
                if(en)
                    ns=shift;
                if(!en)
                    ns = idle;
            end

            
            shift:
            begin
                //shifts = shifts+1;
                busy = 1;
                rdy = 0;
                bcd_bin = {bcd_bin_mem[26:0], 1'b0};
                if(en && shifts==max_shift)
                    ns = done;
                if(en && shifts<max_shift)
                    ns = setup;
                if(!en)
                    ns = idle;
            end
            
            done:
            begin
                busy = 1;
                rdy = 1;  
                if(en)
                begin
                    ns=idle;
                end
                else
                    ns = idle;
                
                
            end
        endcase
    end
    
endmodule












module lab5(
    input [15:0]num,
    input clk,
    output [6:0]seg,
    output [3:0]an
    );
    
    wire [3:0]an_w, bcd;
    wire en;
    anode_gen uut1(clk,en,an_w);
    bcd_mux uut2(num,en,an_w,bcd);
    led_7seg uut3(clk,bcd,seg);
    assign an = ~(an_w);
endmodule






module led_7seg(
    input clk,
    input [3:0]i,
    output reg [6:0]seg
    );
    
    always @(*)
    begin
        case(i)
            0: seg = 7'b1000000;
            1: seg = 7'b1111001;
            2: seg = 7'b0100100;
            3: seg = 7'b0110000;
            4: seg = 7'b0011001;
            5: seg = 7'b0010010;
            6: seg = 7'b0000010;
            7: seg = 7'b1111000;
            8: seg = 7'b0000000;
            9: seg = 7'b0010000;
            10: seg = 7'b0000000;
            11: seg = 7'b0000000;
        endcase
    end
            
endmodule


module bcd_mux(
    input [15:0]num,
    input en,
    input [3:0]sel,
    output reg [3:0]bcd
    );
    
    
    always @(*)
    begin
    if(en) begin
        case(sel)
            4'b1000: bcd = num[15:12];
            4'b0100: bcd = num[11:8];
            4'b0010: bcd = num[7:4];
            4'b0001: bcd = num[3:0];
        endcase
    end
    end 
    
endmodule





module anode_gen(
    input clk,
    output reg en,
    output reg [3:0] an
);

     reg [7:0]count;
    initial
    begin
        an = 4'b0001;
        count = 0;
        en=1'b0;
    end
    
    
    always @(posedge clk)
    begin
        if(en)begin
        count<=count+1;
        end
        en <= 1'b1;
            
        if(count==8'd255)
        begin
          en = 1'b1;
            count<=0;                
            if(an==4'b0001)
                an<=4'b1000;
            else
                an <= an>>1;
        end
        //count<=count+1;
    end
    
endmodule

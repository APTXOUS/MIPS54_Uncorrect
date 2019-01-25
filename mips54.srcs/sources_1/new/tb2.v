`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/06/19 21:25:58
// Design Name: 
// Module Name: tb2
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

module Divider_cpu(
input I_CLK,
input Rst,
output reg O_CLK
    );
    integer i = 0;
    parameter divide_n = 5;
    initial begin
        O_CLK <= 0;
    end
    always@(posedge I_CLK)begin
        if(Rst == 0)begin
            if(i == divide_n-1)begin
                i <= 0;
                O_CLK<=~O_CLK;
            end
            else begin
                i <= i+1;
            end
        end
        else begin
            i <= 0;
            O_CLK <= 0;
        end
    end
endmodule


module input_action(
input I_CLK,
input Rst,
input [3:0]action,
output [31:0] data
);
reg [31:0] array;
integer i = 0;
    parameter divide_n = 2500000;
    always@(posedge I_CLK)begin
        if(Rst == 0)begin
            if(i == divide_n-1)begin
                i = 0;
               array={28'b0,action[3:0]};
            end
            else begin
                array=0;
                i = i+1;
            end
        end
        else begin
            i = 0;
            array=0;
        end
    end
 assign data=array;
endmodule

module tb2(
input clk_in,
input reset,
input ena,
output [3:0] VGA_R,
output [3:0] VGA_G,
output [3:0] VGA_B,
output VGA_HS,
output VGA_VS,
input [3:0] action
    );
    wire [31:0] inst;
    wire [31:0] pc;
    wire [31:0] addr;
    wire clk_div;
    wire gg;
    wire [31:0] data;
    wire [31:0] input_data;
    wire input_ena;
    
    input_action(
    clk_in,
    reset,
    action,
    input_data
    );
    
    Divider_cpu dd(clk_in,reset,clk_div);
    
    sccomp_dataflow uut(
    .clk_in(clk_div),
    .reset(reset),
    .inst(inst),
    .pc(pc),
    .addr(addr),
    .data_io_line(gg),
    .display_data(data),
    .input_data(input_data),
    .input_ena(input_ena)
        );
    
    warship (
     .VGA_R(VGA_R),
    .VGA_G(VGA_G),
    .VGA_B(VGA_B),
    .VGA_HS(VGA_HS),
    .VGA_VS(VGA_VS),
    .CLK(clk_in),
    .reg_from_cpu(data)
        );
endmodule

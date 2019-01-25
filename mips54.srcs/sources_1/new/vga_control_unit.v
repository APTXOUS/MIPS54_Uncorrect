`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/06/15 15:38:35
// Design Name: 
// Module Name: vga_control_unit
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


module vga_control_unit(
input clk,
input [31:0] reg_data,
input reg_to_vga_ena,
input reset,
output [3:0] VGA_R,
output [3:0] VGA_G,
output [3:0] VGA_B,
output VGA_HS,
output VGA_VS
    );
    reg [3:0] RED;
    reg [3:0] GREEN;
    reg [3:0] BLUE;
    wire [10:0] xx;
    wire [10:0] yy;
    wire color;

    wire [31:0] vga_data;
    
    always @(clk)
    begin
        if(color==1)
        begin
         RED=15;
         GREEN=15;
         BLUE=15;
        end
        else
        begin
         RED=0;
         GREEN=0;
         BLUE=0;
        end
    end
    
    VGA_RAM ram_vga(
    .cpu_to_vga(reg_to_vga_ena),
    .reset(reset),
    .reg_data(reg_data),
    .vga_data(vga_data)
        );
        
        
    vga_signal display(
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .clk(clk),
        .RED(RED),
        .GREEN(GREEN),
        .BLUE(BLUE),
        .xx(xx),
        .yy(yy)
            );
            
    
    number_control(
     .xx(xx),
     .yy(yy),
     .vgadata(vga_data),
     .color(color)
       );        
    
    
endmodule

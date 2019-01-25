`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/06/19 20:22:02
// Design Name: 
// Module Name: warship
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



module warship(
output  [3:0] VGA_R,
output [3:0] VGA_G,
output [3:0] VGA_B,
output VGA_HS,
output VGA_VS,
input CLK,
input [32:0] reg_from_cpu
    );
    reg [3:0]RED;
    reg [3:0]GREEN;
    reg [3:0]BLUE;
    wire [10:0] xx;
    wire [10:0] yy;
    reg [8:0] raddr;
    wire [23:0] data [1:0];
    wire [10:0] pos=reg_from_cpu[10:0];
    wire [5:0] type;

    
    assign type=(((yy-35)/20*32+(xx-144)/20)==pos)?1:0;
        
        
     always @(xx or yy)//control the colors
      begin
       if((xx>144)&&(yy>35)&&(xx<784)&&(yy<515))
           begin
           raddr<=(yy-35)%20*20+(xx-144)%20;
           BLUE<=data[type][7:4];
           GREEN<=data[type][15:12];
           RED<=data[type][23:20];
           end
      end
    blk_mem_gen_0 sea_pic(
        .clka(CLK),    // input wire clka
        .ena(1),      // input wire ena
        .addra(raddr),  // input wire [8 : 0] addra
        .douta(data[0])  // output wire [23 : 0] douta
      );
     blk_mem_gen_1 boat_pic(
          .clka(CLK),    // input wire clka
          .ena(1),      // input wire ena
          .addra(raddr),  // input wire [8 : 0] addra
          .douta(data[1])  // output wire [23 : 0] douta
        );  
      
      
        vga_signal display(
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .clk(CLK),
        .RED(RED),
        .GREEN(GREEN),
        .BLUE(BLUE),
        .xx(xx),
        .yy(yy)
            );
endmodule

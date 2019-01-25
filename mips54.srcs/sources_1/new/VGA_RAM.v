`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/06/15 15:20:06
// Design Name: 
// Module Name: VGA_RAM
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


module VGA_RAM(
input cpu_to_vga,
input reset,
input [31:0] reg_data,
output [31:0] vga_data
    );
    reg [31:0]array_vga_data;
    always @(*)
    begin
    if(reset)
        array_vga_data<=32'd0;
    else begin
         if(cpu_to_vga)
                array_vga_data<=reg_data;
            else
                array_vga_data<=array_vga_data;
         end
    end 
    assign vga_data=array_vga_data;
endmodule

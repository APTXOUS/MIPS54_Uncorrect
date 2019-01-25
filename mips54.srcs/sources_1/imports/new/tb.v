`timescale 1ns/1ns

module Divider_cpu(
input I_CLK,
input Rst,
output reg O_CLK
    );
    integer i = 0;
    parameter divide_n = 2;
    initial begin
        O_CLK = 0;
    end
    always@(posedge I_CLK)begin
        if(Rst == 0)begin
            if(i == divide_n-1)begin
                i = 0;
                O_CLK=~O_CLK;
            end
            else begin
                i = i+1;
            end
        end
        else begin
            i = 0;
            O_CLK = 0;
        end
    end
endmodule




module tb(
input clk_in,
input reset,
input ena,
output [3:0] VGA_R,
output [3:0] VGA_G,
output [3:0] VGA_B,
output VGA_HS,
output VGA_VS
);
wire [31:0] inst;
wire [31:0] pc;
wire [31:0] addr;
wire clk_div;
wire gg;
wire [31:0] data;
//integer file_output;
//integer counter=0;
Divider_cpu dd(clk_in,reset,clk_div);

sccomp_dataflow uut(
.clk_in(clk_div),
.reset(reset),
.inst(inst),
.pc(pc),
.addr(addr),
.data_io_line(gg),
.display_data(data)
    );
    
    
  vga_control_unit vga_output(
    .clk(clk_in),
    .reg_data(data),
    .reg_to_vga_ena(gg),
    .reset(reset),
    .VGA_R(VGA_R),
    .VGA_G(VGA_G),
    .VGA_B(VGA_B),
    .VGA_HS(VGA_HS),
    .VGA_VS(VGA_VS)
        );
    

endmodule
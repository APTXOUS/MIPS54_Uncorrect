`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/03 02:42:49
// Design Name: 
// Module Name: ram
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

module ram(
        input clk,
        input wena,
        input [8:0] addr,
        input [31:0] data_in,
        output [31:0] data_out
        );
    
    reg [31:0] arrary [0:512];
    always@(posedge clk) begin
        if(wena) begin
            arrary[addr]<=data_in;
        end
    end 
    assign data_out=arrary[addr];
endmodule
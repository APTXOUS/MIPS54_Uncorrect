`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/10 03:50:30
// Design Name: 
// Module Name: fuck_regfile
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

module RegFiles(
    input clk,
    input rst,
    input we,
    input [4:0] raddr1,
    input [4:0] raddr2,
    input [4:0] waddr,
    input [31:0] wdata,
    output [31:0] rdata1,
    output [31:0] rdata2,
    output [31:0] display_data,
    output [31:0] judge_data,
    input [31:0] input_data
    );
     reg [31:0] array_reg [0:31];
     integer i;
     always@(negedge clk or posedge rst) begin
            if(rst)  for(i=0;i<32;i=i+1) begin
                array_reg[i]<=32'b0;
            end
            else begin
                if(we&&waddr!=5'b0) array_reg[waddr]<=wdata;
                if(array_reg[31]==200)array_reg[30]<=input_data;
            end
        end

    
    assign rdata1=array_reg[raddr1];
    assign rdata2=array_reg[raddr2];
    
    assign judge_data=array_reg[31];
    assign display_data=array_reg[29];
    
    
endmodule
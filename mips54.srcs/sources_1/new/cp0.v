`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/19 14:17:54
// Design Name: 
// Module Name: cp0
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
module CP0( 
    input clk, 
    input rst, 
    input mfc0,            // CPU instruction is Mfc0 
    input mtc0,            // CPU instruction is Mtc0 
    input [31:0]pc, 
    input [4:0] addr,          // Specifies Cp0 register 
    input wire [31:0] data,      // Data from GP register to replace CP0 register 
    input teq_exc, 
    input eret,             // Instruction is ERET (Exception Return) 
    input [4:0]cause, 
    output [31:0] rdata,      // Data from CP0 register for GP register 
    output [31:0] status, 
    output [31:0]exc_addr  // Address for PC at the beginning of an exception 
    );
    parameter   SYSCALL=5'b10000,
                BREAK=5'b10010,
                TEQ=5'b11010,
                status_reg=12,
                epc_reg=14,
                cause_reg=13;

    reg [31:0] cp0 [31:0];
    assign status=cp0[status_reg];
    assign exc_addr=eret?cp0[epc_reg]:32'h4;
    assign rdata=mfc0?cp0[addr]:32'h00000000;
    wire excep_start=status[0]&&((cause==SYSCALL&&status[1])||(cause==BREAK&&status[2])||(status[3]&&cause==TEQ&&teq_exc));
    integer i;
    always@(posedge clk or posedge rst) begin
        if(rst)begin
            for(i=0;i<32;i=i+1)
                cp0[i]<=32'h00000000;
        end
        else begin
            if(mtc0)
                cp0[addr]<=data;
            else if(excep_start) begin
                cp0[status_reg]<= cp0[status_reg]<<5;
                cp0[epc_reg]<=pc;
                cp0[cause_reg]<={25'b0,cause,1'b0};
            end if(eret) begin
                cp0[status_reg]=cp0[status_reg]>>5;
            end
        end
    end


endmodule
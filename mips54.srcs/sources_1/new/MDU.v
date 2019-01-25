`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/06/03 17:09:07
// Design Name: 
// Module Name: MDU
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


module MDU(
       input clk,rst,
       input [2:0] mdu,
       input [31:0] rdata1,rdata2,
       output [63:0] mul_out,
       output reg pc_ena,
       output reg [31:0] hi,lo
    );
      wire div_start,divu_start,div_busy,divu_busy,div_over,divu_over;
      wire [63:0] mult_out,multu_out,div_out,divu_out;
      
      assign    mul_out    =    mult_out;
      
      always@(*)begin
          case(mdu)
              3'h3:    pc_ena    =    div_over ||mdu!=3'h3;
              3'h4:    pc_ena    =    divu_over||mdu!=3'h4;
              default:pc_ena    =    1'b1;
          endcase
      end      
      always@(posedge clk or posedge rst)begin
          if(rst) begin
              hi<=32'b0;
              lo<=32'b0;
          end
          else begin
              case(mdu)
                  3'h1:    {hi,lo}    <=    mult_out;
                  3'h2:    {hi,lo}    <=    multu_out;
                  3'h3:    {lo,hi}    <=    div_out;
                  3'h4:    {lo,hi}    <=    divu_out;
                  3'h5:    hi         <=    rdata1;
                  3'h6:    lo        <=    rdata1;
                  3'h7:    {hi,lo}    <=    mult_out;
              endcase
          end 
      end
      MULT mult(
          .clk(clk),
          .reset(mdu==3'h1||mdu==3'h7),
          .a(rdata1),
          .b(rdata2),
          .z(mult_out));

      MULTU multu(
          .clk(clk),
          .reset(mdu==3'h2),
          .a(rdata1),
          .b(rdata2),
          .z(multu_out));
      
      DIV DIV(
          .dividend(rdata1),
          .divisor(rdata2),
          .clock(clk),
          .reset(mdu!=3'h3),
          .start(div_start),
          .q(div_out[63:32]),
          .r(div_out[31:0]),
          .over(div_over),
          .busy(div_busy));
      
      DIVU DIVU(
          .dividend(rdata1),
          .divisor(rdata2),
          .clock(clk),
          .reset(mdu!=3'h4),
          .start(divu_start),
          .q(divu_out[63:32]),
          .r(divu_out[31:0]),
          .over(divu_over),
          .busy(divu_busy));
            
    assign    div_start    =    mdu==3'h3&&!div_busy;
    assign    divu_start    =    mdu==3'h4&&!divu_busy;
endmodule

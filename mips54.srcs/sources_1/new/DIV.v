`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/03/30 22:42:13
// Design Name: 
// Module Name: DIV
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


module DIV(
   input [31:0]dividend,        //被除数                
   input [31:0]divisor,          //除数            
   input start,                //启动除法运算            
   input clock,            
   input reset,            
   output [31:0]q,             //商            
   output [31:0]r,             //余数               
   output reg busy,               //除法器忙标志位 
   output reg over
);
    wire ready;
    reg [4:0] count;
    reg [31:0] reg_q= 32'b0;
    reg [31:0] reg_r= 32'b0;
    reg [31:0] reg_b= 32'b0;
    reg r_val;
    reg q_val;
    reg busy2,r_sign;
    assign  ready=~busy&busy2;
    wire [32:0] sub_add= r_sign?({reg_r,q[31]} + {1'b0,reg_b}):({reg_r,q[31]} - {1'b0,reg_b});  //加、 减法器  
    assign r=r_sign?( r_val?(~(reg_r+reg_b)+32'b1):(reg_r+reg_b)):( r_val?(~(reg_r)+32'b1):(reg_r));
    assign q=busy?reg_q:( q_val)?reg_q:((~reg_q)+32'b1);
    always @(posedge clock or posedge reset ) begin
        if(reset)begin       //重置信号      
            count<=5'b0;
            busy<=0;
            over<=0;
            busy2<=0;
            r_val<=0;   
            q_val<=0;
        end else begin
            busy2<=busy;
            if(start)begin
                reg_r <= 32'b0;            
                r_sign <= 0;            
                reg_q <= dividend[31]?((~dividend)+32'b1):dividend;            
                reg_b <= divisor[31]?((~divisor)+32'b1):divisor;
                r_val<=dividend[31];   
                q_val<=(dividend[31]==divisor[31])?1:0;
                count <= 5'b0;            
                busy <= 1'b1;  
            end else if(busy) begin
                reg_r<=sub_add[31:0];
                r_sign<=sub_add[32];
                reg_q<={reg_q[30:0],~sub_add[32]};
                count<=count+5'b00001;
                if(count==5'h1f)
                    busy<=0;
                    over<=1;
            end
        end
    end


endmodule

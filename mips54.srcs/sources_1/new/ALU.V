`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/04 08:10:07
// Design Name: 
// Module Name: alu
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


module alu(
    input [31:0] a,
    input [31:0] b,
    input [3:0] aluc,
    output reg signed [31:0] r,
    output reg zero,
    output reg carry,
    output reg negative,
    output reg overflow
    );
    parameter Addu=4'b0000,
                Add=4'b0010,
                Subu=4'b0001,
                Sub=4'b0011,
                And=4'b0100,
                Or=4'b0101,
                Xor=4'b0110,
                Nor=4'b0111,
                Lui1=4'b1001,
                Lui2=4'b1000,
                Slt=4'b1011,
                Sltu=4'b1010,
                Sra=4'b1100,
                Sll1=4'b1111,
                Sll2=4'b1110,
                Srl=4'b1101;
    always @(*)
    begin
        case(aluc)
        Addu:begin
            {carry,r}=a+b;
            if(r==32'h00000000)
                zero=1;
            else
                zero=0;
            negative=r[31];   
        end
        Add:begin
            r=a+b;
            if(r==32'h00000000)
                zero=1;
            else
                zero=0;
            negative=r[31];
            if(a[31]==b[31]&&a[31]==0)
                if(r[31]==1)
                    overflow=1;
                else
                    overflow=0;
             else if(a[31]==b[31]&&a[31]==1)
                if(r[31]==0)
                    overflow=1;
                else
                    overflow=0;
             else
                  overflow=0;
        end
        Subu:begin
            r=a-b;
            if(a<b)
                carry=1;
            else
                carry=0;
            if(r==32'h00000000)
                zero=1;
            else
                zero=0;
            negative=r[31];            
        end
        Sub:begin
            r=a-b;
            if(r==32'h00000000)
                zero=1;
            else
                zero=0;
             negative=r[31];  
             if(a[31]!=b[31])
                if(a[31]==1) begin
                    if(r[31]==1)
                        overflow=0;
                    else
                        overflow=1;
                 end
                 else begin
                    if(r[31==0])
                        overflow=0;
                    else
                        overflow=1;
                 end
        end
        And:begin
            r=a&b;
            if(r==32'h00000000)
                zero=1;
             else
                zero=0;
             negative=r[31]; 
        end
        Or:begin
            r=a|b;
            if(r==32'h00000000)
               zero=1;
            else
               zero=0;
            negative=r[31];            
        end
        Xor:begin
            r=a^b;
            if(r==32'h00000000)
               zero=1;
            else
               zero=0;
            negative=r[31];            
        end  
        Nor:begin
            r=~(a|b);
            if(r==32'h00000000)
               zero=1;
            else
               zero=0;
            negative=r[31];            
        end    
        Lui1:begin
            r={b[15:0],16'b0};
            if(r==32'h00000000)
               zero=1;
            else
               zero=0;
            negative=r[31];             
        end 
        Lui2:begin
            r={b[15:0],16'b0};
            if(r==32'h00000000)
               zero=1;
            else
               zero=0;
            negative=r[31];             
        end 
        Sltu:begin
            r=(a<b)?1:0;
            if(a-b==32'h00000000)
               zero=1;
            else
               zero=0;
            if(a-b<0)
                carry=1;
            else
                carry=0;
            negative=r[31];     
        end        
        Slt:begin
            if(a[31]==1&&b[31]==1)begin
                r=(a>b)?1:0;
                if(a==b)
                    zero=1;
                else
                    zero=0;
                negative=(a>b)?1:0;
            end
            else if(a[31]==0&&b[31]==0)begin
                r=(a<b)?1:0;
                if(a==b)
                    zero=1;
                else
                    zero=0;
                negative=(a<b)?1:0;
            end
            else if(a[31]==1&&b[31]==0) begin
                r=1;
                zero=0;
                negative=1;
            end 
           else begin
                r=0;
                zero=0;
                negative=0;
           end 
        end
        Sra:begin
            carry=b[0];

            r=b;
            r=r>>>a;
        if(r==32'h00000000)
            zero=1;
        else
            zero=0;
            negative=r[31];
        end
        Sll1:begin
            r=b<<a;
        if(r==0)
            zero=1;
        else
            zero=0;       
        carry=b[31];
        negative=r[31];     
        end
        Sll2:begin
            r=b<<a;
        if(r==0)
            zero=1;
        else
            zero=0;       
        carry=b[31];
        negative=r[31];     
        end
        Srl:begin
        r=b>>a;
        if(r==0)
            zero=1;
        else
            zero=0;    
        carry=b[0];
        negative=r[31];
        end
        endcase
    end
endmodule

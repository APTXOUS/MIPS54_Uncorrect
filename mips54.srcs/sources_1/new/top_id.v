`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/09 02:33:51
// Design Name: 
// Module Name: top_id
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


module sccomp_dataflow(
input clk_in,
input reset,
output [31:0] inst,
output [31:0] pc,
output [31:0] addr,
output data_io_line,
output [31:0] display_data,
input [31:0] input_data,
output input_ena
    );
    wire pc_ena;
    wire [31:0] pc_;
    wire [31:0] pc_in;
    wire [4:0] rs,rt,rd;
    wire [31:0] instr_in;
    wire [31:0] wdata;
    
    //alu_control
    wire [3:0] alu_op;
    wire [31:0] alu_r;
    wire [31:0] alu_a;
    wire [31:0] alu_b;
    wire z,c,o,n;

    //ram_control
    wire ram_wena;
    wire [31:0] ram_addr;
    wire [31:0] reg_data;
    wire [31:0] ram_data;
    //regfile control
 //   wire reg_wena;
 //   wire [4:0] reg_addr;
    wire [31:0] reg_data1;
    wire [31:0] reg_data2;
    wire mfc0;
    wire mtc0;
    wire eret;
    wire teq_exc;
    wire [4:0]cause;
    wire [31:0] status;
    wire [31:0] cp0_data;
    wire [31:0] exc_addr;
    wire [2:0] mdu;
    wire [63:0] mul_out;
    wire [31:0] hi,lo;
    wire [31:0] judge_data;
    
    //assign pc_ena=1;
    assign inst=instr_in;
    assign pc=pc_;
    assign addr=ram_addr;
   pcreg pcreg(
         clk_in,
         reset,
         pc_ena,
         pc_in,
         pc_);
         
    alu alu(
        alu_a,
        alu_b,
        alu_op,
        alu_r,
        z,
        c,
        n,
        o);  
    ram dmem(
        clk_in,
        ram_wena,
        ram_addr[8:0],
        reg_data,
        ram_data
        );
        
    CP0 cp0( 
        .clk(clk_in), 
        .rst(reset), 
        .mfc0(mfc0),            // CPU instruction is Mfc0 
        .mtc0(mtc0),            // CPU instruction is Mtc0 
        .pc(pc_), 
        .addr(rd),         // Specifies Cp0 register 
        .data(reg_data2),      // Data from GP register to replace CP0 register 
        .teq_exc(teq_exc), 
        .eret(eret),             // Instruction is ERET (Exception Return) 
        .cause(cause), 
        .rdata(cp0_data),      // Data from CP0 register for GP register 
         .status(status), 
         .exc_addr(exc_addr)   // Address for PC at the beginning of an exception 
         );
            
     MDU mdu0_0(
          .clk(clk_in),
          .rst(reset),
          .mdu(mdu),
          .rdata1(reg_data1),
          .rdata2(reg_data2),
          .mul_out(mul_out),
          .pc_ena(pc_ena),
           .hi(hi),
           .lo(lo)
             );       
      
  //   RegFiles cpu_ref(
  //      clk,
  //      rst,
 //       reg_wena,
 //       rs,
 //       rt,
 //       reg_addr,
 //       wdata,
 //       reg_data1,
 //       reg_data2
 //       );
    
    wire [31:0] ip_pc = (pc_-32'h00400000)/4;
   // wire [31:0] ip_pc = pc_/4;
    dist_mem_gen_0 imem_instr(
             .a(ip_pc[6:0]),      // input wire [15 : 0] a
             .spo(instr_in)  // output wire [31 : 0] spo
        );
   
   mips54 sccpu(
        .pc_in(pc_),
        .rst_in(reset),
        .clk(clk_in),
        .inst_i(instr_in),
        .rt(rt),
        .rs(rs),
        .rd(rd),
        .reg_data1_o(reg_data1),
        .reg_data2_o(reg_data2),
    //    .reg_wena(reg_wena),
   //     .reg_waddr(reg_addr),
        .reg_data(reg_data),
        .wdata(wdata),
        .dmem_wena(ram_wena),
        .dmem_waddr(ram_addr),
        .dmem_data(ram_data),
        .alu_r(alu_r),
        .alu_a(alu_a),
        .alu_b(alu_b),
        .alu_op(alu_op),
        .pc_next(pc_in),
        .hi(hi),
        .lo(lo),
        .cause(cause),
        .cp0_data(cp0_data),
        .mfc0(mfc0),
        .mtc0(mtc0),
        .eret(eret),
        .teq_exc(teq_exc),
        .exc_addr(exc_addr),
        .mul_out(mul_out[31:0]),
        .mdu(mdu)
        );
   
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/09 02:13:05
// Design Name: 
// Module Name: controlunit
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
`define R_TYPE 6'b000000
`define CP0   6'b010000
`define REGIMM 6'b000001
`define I_TYPE 6'b011100

module mips54(
    input [31:0] pc_in,
    input rst_in,
    input [31:0] inst_i,
    input clk,

    output [4:0] rt,
    output [4:0] rs,
    output [4:0] rd,
    //read from regfile
    output [31:0] reg_data1_o,
    output [31:0] reg_data2_o,
    

   // output pc_ena,
 //   output reg reg_ena,
 //   output [4:0] reg_waddr,
    output reg [31:0] reg_data,
    output reg [31:0] wdata,

    output dmem_wena,
    output [31:0]dmem_waddr,
    input [31:0] dmem_data,

  //  output alu_ena,

    input [31:0] alu_r,
    output reg [31:0] alu_a,
    output reg [31:0] alu_b,
    output reg [3:0]  alu_op,


    output reg [31:0] pc_next,


    input [31:0] exc_addr,

    input [31:0] hi,
    input [31:0] lo,


    input [31:0] cp0_data,
    input [31:0] mul_out,

    output reg [4:0] cause,

    output reg [2:0] mdu,
    
    output mfc0,
    output mtc0,
    output eret,
    output teq_exc
);

    //mips31
    //R-type
    parameter   
        ADDU    =   6'b100001,
        SUBU    =   6'b100011,
        ADD     =   6'b100000,
        SUB     =   6'b100010,
        AND     =   6'b100100,
        OR      =   6'b100101,
        XOR     =   6'b100110,
        NOR     =   6'b100111,
        SLT     =   6'b101010,
        SLTU    =   6'b101011,
        SRL     =   6'b000010,
        SRA     =   6'b000011,
        SLL     =   6'b000000,
        SLLV    =   6'b000100,
        SRLV    =   6'b000110,
        SRAV    =   6'b000111,
        JR      =   6'b001000,
        JALR    =   6'b001001,

        BREAK   =   6'b001101,
        SYSCALL =   6'b001100,
        TEQ     =   6'b110100,


        MFHI    =   6'b010000,
        MFLO    =   6'b010010,
        MTHI    =   6'b010001,
        MTLO    =   6'b010011,
        
        CLZ     =   6'b100000,    
        MUL     =   6'b000010,

        MULT    =   6'b011000,
        MULTU   =   6'b011001,
        DIV     =   6'b011010,
        DIVU    =   6'b011011,

    //I-typr
        ADDI    =   6'b001000,
        ADDIU   =   6'b001001,
        ANDI    =   6'b001100,
        ORI     =   6'b001101,
        XORI    =   6'b001110,
        LW      =   6'b100011,
        SW      =   6'b101011,
        BEQ     =   6'b000100,
        BNE     =   6'b000101,
        BLEZ    =   6'b000110,
        BGTZ    =   6'b000111,
        SLTI    =   6'b001010,
        SLTIU   =   6'b001011,
        LUI     =   6'b001111,
        J       =   6'b000010,
        JAL     =   6'b000011,
    //mips54
        LB      =   6'b100000,//Load Byte Function=6'h24    
        LBU     =   6'b100100,//1Load Byte Unsigned 
        LH      =   6'b100001,//Load high 
        LHU     =   6'b100101,//Load High Unsigned
        SB      =   6'b101000,//Send Byte
        SH      =   6'b101001,//Send High

        BGEZ    =   5'b00001,

    //cp0
        ERET    =   6'b011000,  //5-0&&25TH=1
        MFC0    =   5'b00000,   //20-16
        MTC0    =   5'b00100;


    //regimm


       
    parameter 
        _Addu=4'b0000,
        _Add=4'b0010,
        _Subu=4'b0001,
        _Sub=4'b0011,
        _And=4'b0100,
        _Or=4'b0101,
        _Xor=4'b0110,
        _Nor=4'b0111,
        _Lui1=4'b1001,
        _Lui2=4'b1000,
        _Slt=4'b1011,
        _Sltu=4'b1010,
        _Sra=4'b1100,
        _Sll1=4'b1111,
        _Sll2=4'b1110,
        _Srl=4'b1101;  


    parameter    
        _SYSCALL=   5'b10000,
        _BREAK  =   5'b10010,
         _TEQ   =   5'b11010;


    parameter
        _MULT=3'h1,
        _MULTU=3'h2,
        _DIV=3'h3,
        _DIVU=3'h4,
        _MTHI=3'h5,
        _MTLO=3'h6;
    //reg
    reg reg_wena;
    wire [31:0] reg_data1;
    wire [31:0] reg_data2;
    wire [4:0] reg_waddr;

    wire [5:0] func = inst_i[5:0];
    wire [4:0] shamt= inst_i[10:6];  
    wire [6:0] op   = inst_i[31:26]; 
    wire [15:0] imm = inst_i[15:0];
    wire [25:0] addr= inst_i[25:0];

    assign rt   = inst_i[20:16];
    assign rs   = inst_i[25:21];
    assign rd   = inst_i[15:11];
    
    assign reg_data1_o=reg_data1;
    assign reg_data2_o=reg_data2;

    wire [31:0] shamt_ext = {27'b0,inst_i[10:6]};
    wire     imm_sign    =   (op==ANDI||op==ORI||op==XORI)?1'b0:1'b1;
    wire [31:0] imm_ext   =   imm_sign?{{(16){imm[15]}},imm}:{16'b0,imm};

    wire [31:0] npc = pc_in+4;//next_normal_pc

    wire enable=1;
    wire disenable=0;

    wire [31:0] pc_branch=npc+{{(14){imm[15]}},imm,2'b00};//branch_target_pc
    wire [31:0] pc_jump={npc[31:28],addr,2'b00}; //jump_tareget_pc

    wire rdata1_2=(reg_data1==reg_data2)?1:0;
    assign    dmem_waddr    =   reg_data1  +   imm_ext;

    assign    eret        =    op==`CP0 && func==ERET;
    assign    mfc0        =    op==`CP0 && rs==MFC0;
    assign    mtc0        =    op==`CP0 && rs==MTC0;
    assign    teq_exc        =    reg_data1==reg_data2;
    
    
    reg  [31:0] load_data;

    //dmem_wena control
     assign dmem_wena =   op==SW || op==SH || op==SB;

     


    //reg_waddr control
    assign reg_waddr=(op==`R_TYPE||op==`I_TYPE)?rd:(op==JAL)?5'b11111:rt;

    always @(*)begin
        
        //reg_data_control
        case(op)
            SB:     reg_data    <=   {24'b0,reg_data2[7:0]};
            SH:     reg_data    <=   {16'b0,reg_data2[15:0]};
            SW:     reg_data    <=   reg_data2;
            default:reg_data    <=    reg_data2;
        endcase
    

        //load_data_control
       case(op)
            LB:     load_data   <=   {{24{dmem_data[7]}},dmem_data[7:0]};
            LBU:    load_data   <=   {24'b0,dmem_data[7:0]};
            LH:     load_data   <=   {{16{dmem_data[15]}},dmem_data[15:0]};
            LHU:    load_data   <=   {16'b0,dmem_data[15:0]};
            LW:     load_data   <=   dmem_data;
            default:load_data   <=   dmem_data;
        endcase

        case(op)
            `R_TYPE:case(func)
                    SYSCALL:cause<=_SYSCALL;
                    BREAK:cause<=_BREAK;
                    TEQ:cause<=_TEQ;
                    default:cause<=5'b00000;
                    endcase
            default:cause<=5'b00000;
        endcase

        if(op==`R_TYPE)
            case(func)
                MULT:    mdu        =    _MULT;
                MULTU:    mdu        =   _MULTU;
                DIV:    mdu        =    _DIV;
                DIVU:    mdu        =   _DIVU;
                MTHI:    mdu        =   _MTHI;
                MTLO:    mdu        =   _MTLO;
                default:mdu        =    3'h0;
            endcase
        else if(op==`I_TYPE)
                  case(func)
                        MUL:    mdu        =    3'h7;
                        default:mdu        =    3'h0;
                    endcase
        else
            mdu        =    3'h0;


        //reg_wena control
        case(op)
            `R_TYPE:
                case(func)
                MULTU,
                DIV,
                DIVU,
                MTHI,
                MTLO,
                BREAK,
                SYSCALL,
                JR:reg_wena<=disenable;
                default:reg_wena<=enable;
                endcase
            `CP0:       reg_wena <= rs==MFC0?enable:disenable;
            `I_TYPE,
            LB,
            LBU,
            LH,
            LHU,
            ADDI,
            ADDIU,
            ANDI,
            ORI,
            XORI,
            LW,
            SLTI,
            SLTIU,
            LUI,
            MUL,
            JAL:     reg_wena  <=  enable   ;
            default: reg_wena<=disenable;
        endcase


        //wdata_control
        case(op)
            `R_TYPE:case(func)
                JALR:   wdata   <=  npc;
                MFHI:   wdata   <=  hi;
                MFLO:   wdata   <=  lo;
                default:wdata   <=  alu_r;
            endcase 
            `I_TYPE:case(func)
                CLZ:case(reg_data1)
                    32'b1???????????????????????????????:   wdata   <=       32'h0;
                    32'b01??????????????????????????????:   wdata   <=       32'h1;
                    32'b001?????????????????????????????:   wdata   <=       32'h2;
                    32'b0001????????????????????????????:   wdata   <=       32'h3;
                    32'b00001???????????????????????????:   wdata   <=       32'h4;
                    32'b000001??????????????????????????:   wdata   <=       32'h5;
                    32'b0000001?????????????????????????:   wdata   <=       32'h6;
                    32'b00000001????????????????????????:   wdata   <=       32'h7;
                    32'b000000001???????????????????????:   wdata   <=       32'h8;
                    32'b0000000001??????????????????????:   wdata   <=       32'h9;
                    32'b00000000001?????????????????????:   wdata   <=       32'ha;
                    32'b000000000001????????????????????:   wdata   <=       32'hb;
                    32'b0000000000001???????????????????:   wdata   <=       32'hc;
                    32'b00000000000001??????????????????:   wdata   <=       32'hd;
                    32'b000000000000001?????????????????:   wdata   <=       32'he;
                    32'b0000000000000001????????????????:   wdata   <=       32'hf;
                    32'b00000000000000001???????????????:   wdata   <=       32'h10;
                    32'b000000000000000001??????????????:   wdata   <=       32'h11;
                    32'b0000000000000000001?????????????:   wdata   <=       32'h12;
                    32'b00000000000000000001????????????:   wdata   <=       32'h13;
                    32'b000000000000000000001???????????:   wdata   <=       32'h14;
                    32'b0000000000000000000001??????????:   wdata   <=       32'h15;
                    32'b00000000000000000000001?????????:   wdata   <=       32'h16;
                    32'b000000000000000000000001????????:   wdata   <=       32'h17;
                    32'b0000000000000000000000001???????:   wdata   <=       32'h18;
                    32'b00000000000000000000000001??????:   wdata   <=       32'h19;
                    32'b000000000000000000000000001?????:   wdata   <=       32'h1a;
                    32'b0000000000000000000000000001????:   wdata   <=       32'h1b;
                    32'b00000000000000000000000000001???:   wdata   <=       32'h1c;
                    32'b000000000000000000000000000001??:   wdata   <=       32'h1d;
                    32'b0000000000000000000000000000001?:   wdata   <=       32'h1e;
                    32'b00000000000000000000000000000001:   wdata   <=       32'h1f;
                    32'b00000000000000000000000000000000:   wdata   <=       32'h20;
                    endcase
                MUL:    wdata   <=    mul_out;
                default:wdata   <=    alu_r;
            endcase
            JAL:        wdata   <=   npc;
            LW,
            LB,
            LH,
            LBU,
            LHU:        wdata   <=   load_data;
            `CP0:    if(rs==MFC0) wdata<=cp0_data;
                     else       wdata<=alu_r;
            default:                wdata   <=   alu_r;
        endcase


        //pc_control
        case(op)
            `R_TYPE:
                case(func)
                    SYSCALL,
                    TEQ,
                    BREAK:pc_next<=exc_addr;
                    JALR,
                    JR:pc_next<=reg_data1;
                    default:pc_next<=npc;   
                endcase
            `CP0:case(func)
                    ERET:pc_next<=exc_addr;
                    default:pc_next<=npc;
                endcase
            `REGIMM:/*case(func)
                    BGEZ:if(!reg_data1[31])
                            pc_next<=pc_branch;
                        else
                            pc_next<=npc;
                    default:pc_next<=npc;
                    endcase
                    */
                    if(!reg_data1[31])
                        pc_next<=pc_branch;
                    else
                        pc_next<=npc;
            J:pc_next<=pc_jump;
            JAL:pc_next<=pc_jump;
            BEQ:if(rdata1_2)
                    pc_next<=pc_branch;
                else
                    pc_next<=npc;
            BNE:if(!rdata1_2)
                    pc_next<=pc_branch;
                else
                    pc_next<=npc;
            default:pc_next<=npc;
        endcase

        //alu_read_data
        case(op)
        `R_TYPE:
            case(func)
                SLL,
                SRL,
                SRA:begin
                    alu_a   <=   shamt_ext;
                    alu_b   <=   reg_data2;
                    end
                default:begin
                    alu_a   <=   reg_data1;
                    alu_b   <=   reg_data2;
                end
            endcase
        ADDI,
        ADDIU,
        ANDI,
        ORI,
        XORI,
        SLTI,
        SLTIU,
        LUI:begin
                alu_a   <=   reg_data1;
                alu_b   <=   imm_ext;
            end
        default:begin
                alu_a   <=   reg_data1;
                alu_b   <=   reg_data2;
        end
        endcase


     //judge_alu_operation
        case(op)
        `R_TYPE:case(func)
            ADDU:       alu_op  <=   _Addu;
            SUBU:       alu_op  <=   _Subu;
            ADD:        alu_op  <=   _Add;
            SUB:        alu_op  <=   _Sub;
            AND:        alu_op  <=   _And;
            OR:         alu_op  <=   _Or;
            XOR:        alu_op  <=   _Xor;
            NOR:        alu_op  <=   _Nor;
            SLT:        alu_op  <=   _Slt;
            SRL:        alu_op  <=   _Srl;
            SLL:        alu_op  <=   _Sll1;
            SRA:        alu_op  <=   _Sra;
            SLTU:       alu_op  <=   _Sltu;
            SRLV:       alu_op  <=   _Srl;
            SLLV:       alu_op  <=   _Sll2;
            SRAV:       alu_op  <=   _Sra;
            default:    alu_op  <=   _Addu;
        endcase
        ORI:            alu_op  <=   _Or;
        XORI:           alu_op  <=   _Xor;
        BEQ:            alu_op  <=   _Subu;
        BNE:            alu_op  <=   _Subu;
        ANDI:           alu_op  <=   _And;
        ADDIU:          alu_op  <=   _Addu;
        ADDI:           alu_op  <=   _Add;
        SLTI:           alu_op  <=   _Slt;
        SLTIU:          alu_op  <=   _Sltu;
        LUI:            alu_op  <=   _Lui2;
        default:        alu_op  <=   _Addu;
        endcase
    end
        
     RegFiles cpu_ref(
       clk,
       rst_in,
       reg_wena,
       rs,
       rt,
       reg_waddr,
       wdata,
       reg_data1,
       reg_data2
       );
       
endmodule
`timescale 1ns/1ps
`default_nettype none

module cpu (
    input wire clk,
    output wire [31:0] instr
);

//---------------------------- IF stage ------------------------------

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 1) pc

    localparam [31:0] RESET_PC       = 32'h0000_0000;  // starting address
    localparam        PCSRC_PLUS4    = 2'd0;
    localparam        PCSRC_BRANCH   = 2'd1;

    initial begin
        pc_if = RESET_PC; 
    end

    reg  [31:0] pc_if;
    wire [1:0]  pcsrc_if; // 0: pc+4, 1: branch
    wire [31:0] pc_plus4_if;
    wire [31:0] next_pc_if;
    wire branch_taken; // decided on MEM stage

    assign pc_plus4_if = pc_if + 32'd4;

    assign pcsrc_if = (branch_taken) ? PCSRC_BRANCH : PCSRC_PLUS4;
    assign next_pc_if = (pcsrc_if == PCSRC_PLUS4) ? pc_plus4_if : branch_target_mem;

    always @(posedge clk) begin
        pc_if <= next_pc_if;
    end

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 2) instruction memory

    wire [31:0] instr_if;

    instr_mem u_imem (
        .pc_if(pc_if),
        .instr_if(instr_if)
    );
    
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  IF/ID pipeline register
    
    assign instr = instr_id; // for debugging

    wire [31:0] pc_plus4_id;
    wire [31:0] instr_id;

    pipe_if_id u_ifid (
        .clk(clk),
        .pc_plus4_if(pc_plus4_if), 
        .instr_if(instr_if),

        .pc_plus4_id(pc_plus4_id),
        .instr_id(instr_id)
    );

//---------------------------- ID stage ------------------------------

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 3) instruction decoder

    wire [5:0]  opcode_id;
    wire [4:0]  rs_id;
    wire [4:0]  rt_id;
    wire [4:0]  rd_id;
    wire [4:0]  shamt_id;
    wire [5:0]  funct_id;

    wire [15:0] imm16_id;
    wire [25:0] jump_addr_id; 

    instr_decoder u_dec (
        .instr_id(instr_id), 
        .opcode_id(opcode_id), .rs_id(rs_id), .rt_id(rt_id), .rd_id(rd_id), .shamt_id(shamt_id), .funct_id(funct_id), 
        .imm16_id(imm16_id), .jump_addr_id(jump_addr_id)
    );
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 4) sign-extend

    sext16to32 sext (
        .imm16_id(imm16_id),
        .imm32_id(imm32_id)
    );
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 5) register file

    reg_file u_rf (
        .clk(clk),
        .rs_id(rs_id), .rt_id(rt_id), .writereg_wb(writereg_wb), 
        .datatowritereg(datatowritereg),
        .ctrl_regwrite_wb(ctrl_regwrite_wb),
        .readdata1_id(readdata1_id), .readdata2_id(readdata2_id)
    );

// ID/EX pipeline register
    // --------------------------------------

    wire ctrl_regdst_id, ctrl_branch_id, ctrl_memread_id, ctrl_memtoreg_id, ctrl_memwrite_id, ctrl_alusrc_id, ctrl_regwrite_id;
    wire [1:0] ctrl_aluop_id;
    wire [31:0] readdata1_id, readdata2_id;
    wire [31:0] imm32_id;

    wire ctrl_regdst_ex, ctrl_branch_ex, ctrl_memread_ex, ctrl_memtoreg_ex, ctrl_memwrite_ex, ctrl_alusrc_ex, ctrl_regwrite_ex;
    wire [1:0] ctrl_aluop_ex;
    wire [31:0] pc_plus4_ex;
    wire [31:0] readdata1_ex, readdata2_ex;
    wire [31:0] imm32_ex;
    wire [5:0] funct_ex;
    wire [4:0] rt_ex, rd_ex;

    pipe_id_ex u_idex (
        .clk(clk),
        .ctrl_regdst_id(ctrl_regdst_id), .ctrl_branch_id(ctrl_branch_id), .ctrl_memread_id(ctrl_memread_id), .ctrl_memtoreg_id(ctrl_memtoreg_id), .ctrl_memwrite_id(ctrl_memwrite_id), .ctrl_alusrc_id(ctrl_alusrc_id), .ctrl_regwrite_id(ctrl_regwrite_id),
        .ctrl_aluop_id(ctrl_aluop_id),
        .pc_plus4_id(pc_plus4_id),
        .readdata1_id(readdata1_id), .readdata2_id(readdata2_id),
        .imm32_id(imm32_id),
        .funct_id(funct_id),
        .rt_id(rt_id), .rd_id(rd_id),

        .ctrl_regdst_ex(ctrl_regdst_ex), .ctrl_branch_ex(ctrl_branch_ex), .ctrl_memread_ex(ctrl_memread_ex), .ctrl_memtoreg_ex(ctrl_memtoreg_ex), .ctrl_memwrite_ex(ctrl_memwrite_ex), .ctrl_alusrc_ex(ctrl_alusrc_ex), .ctrl_regwrite_ex(ctrl_regwrite_ex),
        .ctrl_aluop_ex(ctrl_aluop_ex),
        .pc_plus4_ex(pc_plus4_ex),
        .readdata1_ex(readdata1_ex), .readdata2_ex(readdata2_ex),
        .imm32_ex(imm32_ex),
        .funct_ex(funct_ex),
        .rt_ex(rt_ex), .rd_ex(rd_ex)
    );

//---------------------------- EX stage ------------------------------

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 6) main control unit (creating 9 control signals)

    wire ctrl_jump_id;

    ctrl_main u_mcu (
        .opcode_id(opcode_id),
        .ctrl_regdst_id(ctrl_regdst_id), .ctrl_jump_id(ctrl_jump_id), .ctrl_branch_id(ctrl_branch_id), .ctrl_memread_id(ctrl_memread_id), .ctrl_memtoreg_id(ctrl_memtoreg_id), .ctrl_memwrite_id(ctrl_memwrite_id), .ctrl_alusrc_id(ctrl_alusrc_id), .ctrl_regwrite_id(ctrl_regwrite_id),
        .ctrl_aluop_id(ctrl_aluop_id)
    );

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 7) ALU control 

    wire [3:0] ctrl_aluctrl_ex;

    ctrl_alu u_aluctrl (
        .ctrl_aluop_ex(ctrl_aluop_ex),
        .funct_ex(funct_ex),
        .ctrl_aluctrl_ex(ctrl_aluctrl_ex)
    );

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 8) ALU 

    wire [31:0] operand2;
    assign operand2 = (ctrl_alusrc_ex) ? imm32_ex : readdata2_ex;

    alu32 u_alu (
        .ctrl_aluctrl_ex(ctrl_aluctrl_ex),
        .operand1(readdata1_ex), .operand2(operand2), // operand1 is always readdata1_ex(rs_id value)
        .aluout_ex(aluout_ex),
        .ctrl_zero_ex(ctrl_zero_ex)
    );

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 9) branch target adder

    branch_adder u_btadd (
        .imm32_ex(imm32_ex),
        .pc_plus4_ex(pc_plus4_ex),
        .branch_target_ex(branch_target_ex)
    );

    assign writereg_ex = (ctrl_regdst_ex) ? rd_ex : rt_ex; 


    // EX/MEM pipeline register
    // --------------------------------------
    
    wire [31:0] branch_target_ex;
    wire ctrl_zero_ex;
    wire [31:0] aluout_ex;
    wire [31:0] writedata_ex;
    wire [4:0] writereg_ex;

    wire ctrl_branch_mem, ctrl_memread_mem, ctrl_memtoreg_mem, ctrl_memwrite_mem, ctrl_regwrite_mem;
    wire [31:0] branch_target_mem;
    wire ctrl_zero_mem;
    wire [31:0] aluout_mem;
    wire [31:0] writedata_mem;
    wire [4:0] writereg_mem;

    pipe_ex_mem u_exmem (
        .clk(clk),
        .ctrl_branch_ex(ctrl_branch_ex), .ctrl_memread_ex(ctrl_memread_ex), .ctrl_memtoreg_ex(ctrl_memtoreg_ex), .ctrl_memwrite_ex(ctrl_memwrite_ex), .ctrl_regwrite_ex(ctrl_regwrite_ex),
        .branch_target_ex(branch_target_ex),
        .ctrl_zero_ex(ctrl_zero_ex),
        .aluout_ex(aluout_ex),
        .writedata_ex(writedata_ex),
        .writereg_ex(writereg_ex),

        .ctrl_branch_mem(ctrl_branch_mem), .ctrl_memread_mem(ctrl_memread_mem), .ctrl_memtoreg_mem(ctrl_memtoreg_mem), .ctrl_memwrite_mem(ctrl_memwrite_mem), .ctrl_regwrite_mem(ctrl_regwrite_mem),
        .branch_target_mem(branch_target_mem),
        .ctrl_zero_mem(ctrl_zero_mem),
        .aluout_mem(aluout_mem),
        .writedata_mem(writedata_mem),
        .writereg_mem(writereg_mem)
    );

//---------------------------- MEM stage ------------------------------

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 10) data memory (MEM stage)

    assign writedata_ex = readdata2_ex;

    data_mem u_dmem (
        .clk(clk),
        .ctrl_memread_mem(ctrl_memread_mem), .ctrl_memwrite_mem(ctrl_memwrite_mem), .aluout_mem(aluout_mem), .writedata_mem(writedata_mem), .readdata_mem(readdata_mem)
    );

    // MEM/WB pipeline register
    // --------------------------------------

    wire [31:0] readdata_mem;

    wire ctrl_memtoreg_wb, ctrl_regwrite_wb;
    wire [31:0] readdata_wb;
    wire [31:0] aluout_wb;
    wire [4:0] writereg_wb;

    pipe_mem_wb u_memwb (
        .clk(clk),
        .ctrl_memtoreg_mem(ctrl_memtoreg_mem), .ctrl_regwrite_mem(ctrl_regwrite_mem),
        .readdata_mem(readdata_mem),
        .aluout_mem(aluout_mem),
        .writereg_mem(writereg_mem),

        .ctrl_memtoreg_wb(ctrl_memtoreg_wb), .ctrl_regwrite_wb(ctrl_regwrite_wb),
        .readdata_wb(readdata_wb),
        .aluout_wb(aluout_wb),
        .writereg_wb(writereg_wb)
    );
    

//---------------------------- WB stage ------------------------------

    assign branch_taken = ((ctrl_branch_mem === 1'b1) && (ctrl_zero_mem === 1'b1));

    wire [31:0] datatowritereg = (ctrl_memtoreg_wb) ? readdata_wb : aluout_wb;
    

   

endmodule

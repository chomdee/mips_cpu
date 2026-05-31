`timescale 1ns/1ps
`default_nettype none

module cpu (
    input wire clk,
    output wire [31:0] instr
);

//---------------------------- IF stage ------------------------------

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 1) pc

    initial begin
        pc_if = RESET_PC;
    end

    localparam [31:0] RESET_PC       = 32'h0000_0000;  // starting address
    localparam        PCSRC_PLUS4    = 2'd0;
    localparam        PCSRC_BRANCH   = 2'd1;
    localparam        PCSRC_EXCEPTION = 2'd2;
    localparam        PCSRC_ERET = 2'd3;

    reg  [31:0] pc_if;
    wire [1:0]  pcsrc_if; // 0: pc+4, 1: branch, 2: exception 3: eret
    wire [31:0] pc_plus4_if;
    wire [31:0] next_pc_if;
    wire branch_taken_ex; // decided on EX stage

    wire pc_write;

    assign pc_plus4_if = pc_if + 32'd4;

    assign pcsrc_if = (exception_req) ? PCSRC_EXCEPTION :
                      (is_eret) ? PCSRC_ERET:
                      (branch_taken_ex) ? PCSRC_BRANCH :
                      PCSRC_PLUS4;
    assign next_pc_if = (pcsrc_if == PCSRC_EXCEPTION) ? handler_pc :
                        (pcsrc_if == PCSRC_ERET) ? epc: 
                        (pcsrc_if == PCSRC_BRANCH) ? branch_target_ex : 
                        pc_plus4_if;

    always @(posedge clk) begin
        if (pc_write) 
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
    

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  IF/ID pipeline register
    
    assign instr = instr_id; // for debugging

    wire [31:0] pc_plus4_id;
    wire [31:0] instr_id;

    wire ifid_write;

    pipe_if_id u_ifid (
        .clk(clk),
        .final_flush_if_id(final_flush_if_id),

        .ifid_write(ifid_write),
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

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 6) main control unit (creating 9 control signals)

    wire ctrl_regdst;
    wire ctrl_jump;
    wire ctrl_branch;
    wire ctrl_memread;
    wire ctrl_memwrite;
    wire ctrl_alusrc;
    wire ctrl_regwrite;

    wire cp0_write;
    wire is_eret;

    wire [1:0] ctrl_wbsrc;
    wire [1:0] ctrl_aluop;

    ctrl_main u_mcu (
        .opcode_id(opcode_id),
        .rs_id(rs_id), .funct_id(funct_id),
        .ctrl_regdst(ctrl_regdst), .ctrl_jump(ctrl_jump), .ctrl_branch(ctrl_branch), .ctrl_memread(ctrl_memread), .ctrl_memwrite(ctrl_memwrite), .ctrl_alusrc(ctrl_alusrc), .ctrl_regwrite(ctrl_regwrite),
        .cp0_write(cp0_write), .is_eret(is_eret),
        .ctrl_wbsrc(ctrl_wbsrc), .ctrl_aluop(ctrl_aluop)
    );


    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 7) hazard detection unit

    wire final_flush_if_id;
    wire final_flush_id_ex;
    wire final_flush_ex_mem;
    wire final_flush_mem_wb;


    hazard_detection_unit u_hdu (
        .ctrl_memread_ex(ctrl_memread_ex),
        .rs_id(rs_id), .rt_id(rt_id), .rt_ex(rt_ex),

        .branch_taken_ex(branch_taken_ex),

        .exception_req(exception_req),
        .exc_flush_if_id(exc_flush_if_id),
        .exc_flush_id_ex(exc_flush_id_ex),
        .exc_flush_ex_mem(exc_flush_ex_mem),
        .exc_flush_mem_wb(exc_flush_mem_wb),

        .is_eret(is_eret),

        .pc_write(pc_write),
        .ifid_write(ifid_write),

        .final_flush_if_id(final_flush_if_id),
        .final_flush_id_ex(final_flush_id_ex),
        .final_flush_ex_mem(final_flush_ex_mem),
        .final_flush_mem_wb(final_flush_mem_wb)
    );

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////


// ID/EX pipeline register
    // --------------------------------------

    wire ctrl_regdst_id, ctrl_branch_id, ctrl_memread_id, ctrl_memwrite_id, ctrl_alusrc_id, ctrl_regwrite_id, cp0_write_id;
    wire [1:0] ctrl_wbsrc_id, ctrl_aluop_id;
    wire [31:0] readdata1_id, readdata2_id;
    wire [31:0] imm32_id;

    wire ctrl_regdst_ex, ctrl_branch_ex, ctrl_memread_ex,  ctrl_memwrite_ex, ctrl_alusrc_ex, ctrl_regwrite_ex, cp0_write_ex;
    wire [1:0] ctrl_wbsrc_ex, ctrl_aluop_ex;
    wire [31:0] pc_plus4_ex;
    wire [31:0] readdata1_ex, readdata2_ex;
    wire [31:0] imm32_ex;
    wire [5:0] funct_ex;
    wire [4:0] shamt_ex;
    wire [4:0] rt_ex, rd_ex, rs_ex;

    pipe_id_ex u_idex (
        .clk(clk),
        .final_flush_id_ex(final_flush_id_ex),

        .ctrl_regdst_id(ctrl_regdst), .ctrl_branch_id(ctrl_branch), .ctrl_memread_id(ctrl_memread), .ctrl_memwrite_id(ctrl_memwrite), .ctrl_alusrc_id(ctrl_alusrc), .ctrl_regwrite_id(ctrl_regwrite), .cp0_write_id(cp0_write),
        .ctrl_wbsrc_id(ctrl_wbsrc), .ctrl_aluop_id(ctrl_aluop),
        .pc_plus4_id(pc_plus4_id),
        .readdata1_id(readdata1_id), .readdata2_id(readdata2_id),
        .imm32_id(imm32_id),
        .funct_id(funct_id),
        .shamt_id(shamt_id),
        .rt_id(rt_id), .rd_id(rd_id), .rs_id(rs_id),

        .ctrl_regdst_ex(ctrl_regdst_ex), .ctrl_branch_ex(ctrl_branch_ex), .ctrl_memread_ex(ctrl_memread_ex), .ctrl_memwrite_ex(ctrl_memwrite_ex), .ctrl_alusrc_ex(ctrl_alusrc_ex), .ctrl_regwrite_ex(ctrl_regwrite_ex), .cp0_write_ex(cp0_write_ex),
        .ctrl_wbsrc_ex(ctrl_wbsrc_ex), .ctrl_aluop_ex(ctrl_aluop_ex),
        .pc_plus4_ex(pc_plus4_ex),
        .readdata1_ex(readdata1_ex), .readdata2_ex(readdata2_ex),
        .imm32_ex(imm32_ex),
        .funct_ex(funct_ex),
        .shamt_ex(shamt_ex),
        .rt_ex(rt_ex), .rd_ex(rd_ex), .rs_ex(rs_ex)
    );

//---------------------------- EX stage ------------------------------

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 8) ALU control 

    wire [3:0] ctrl_aluctrl_ex;

    ctrl_alu u_aluctrl (
        .ctrl_aluop_ex(ctrl_aluop_ex),
        .funct_ex(funct_ex),
        .ctrl_aluctrl_ex(ctrl_aluctrl_ex)
    );

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 9) forwarding unit

    wire [1:0] forwardA;
    wire [1:0] forwardB;
    wire [4:0] rd_mem;
    wire [4:0] rd_wb;

    forwarding_unit u_fwding_unit (
        .rs_ex(rs_ex), .rt_ex(rt_ex), .writereg_mem(writereg_mem), .writereg_wb(writereg_wb),
        .ctrl_regwrite_mem(ctrl_regwrite_mem), .ctrl_regwrite_wb(ctrl_regwrite_wb),
        .forwardA(forwardA), .forwardB(forwardB)
    );

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 10) operand1 MUX 

    wire [31:0] operand1;

    mux_operand1 u_muxop1 (
        .forwardA(forwardA),
        .readdata1_ex(readdata1_ex),
        .datatowritereg(datatowritereg),
        .aluout_mem(aluout_mem),
        .operand1(operand1)
    );

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 11) operand2 MUX 


    wire [31:0] operand2_forwarded;
    wire [31:0] operand2;

    mux_operand2 u_muxop2 (
        .forwardB(forwardB),
        .readdata2_ex(readdata2_ex),
        .datatowritereg(datatowritereg),
        .aluout_mem(aluout_mem),
        .operand2_forwarded(operand2_forwarded)
    );

    assign operand2 = (ctrl_alusrc_ex) ? imm32_ex : operand2_forwarded;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 12) ALU 

    wire div_by_zero_ex;

    alu32 u_alu (
        .ctrl_aluctrl_ex(ctrl_aluctrl_ex),
        .operand1(operand1), .operand2(operand2),
        .shamt_ex(shamt_ex), 
        .aluout_ex(aluout_ex),
        .ctrl_zero_ex(ctrl_zero_ex),
        .div_by_zero_ex(div_by_zero_ex)
    );

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 13) branch target adder

    branch_adder u_btadd (
        .imm32_ex(imm32_ex),
        .pc_plus4_ex(pc_plus4_ex),
        .branch_target_ex(branch_target_ex)
    );

    assign writereg_ex = (ctrl_regdst_ex) ? rd_ex : rt_ex; 
    assign branch_taken_ex = ((ctrl_branch_ex) && (ctrl_zero_ex));

    // EX/MEM pipeline register
    // --------------------------------------
    
    wire [31:0] branch_target_ex;
    wire ctrl_zero_ex;
    wire [31:0] aluout_ex;
    wire [31:0] writedata_ex;
    wire [4:0] writereg_ex;




    wire ctrl_memread_mem,  ctrl_memwrite_mem, ctrl_regwrite_mem, cp0_write_mem;
    wire [1:0] ctrl_wbsrc_mem;
    wire [31:0] aluout_mem;
    wire [31:0] writedata_mem;
    wire [4:0] writereg_mem;

    wire [4:0] rt_mem;

    pipe_ex_mem u_exmem (
        .clk(clk),
        .final_flush_ex_mem(final_flush_ex_mem),

        .ctrl_memread_ex(ctrl_memread_ex), .ctrl_memwrite_ex(ctrl_memwrite_ex), .ctrl_regwrite_ex(ctrl_regwrite_ex), .cp0_write_ex(cp0_write_ex),
        .ctrl_wbsrc_ex(ctrl_wbsrc_ex),
        .aluout_ex(aluout_ex),
        .writedata_ex(writedata_ex),
        .writereg_ex(writereg_ex),
        .rd_ex(rd_ex),
        .rt_ex(rt_ex),

        .ctrl_memread_mem(ctrl_memread_mem), .ctrl_memwrite_mem(ctrl_memwrite_mem), .ctrl_regwrite_mem(ctrl_regwrite_mem), .cp0_write_mem(cp0_write_mem),
        .ctrl_wbsrc_mem(ctrl_wbsrc_mem),
        .aluout_mem(aluout_mem),
        .writedata_mem(writedata_mem),
        .writereg_mem(writereg_mem),
        .rd_mem(rd_mem),
        .rt_mem(rt_mem)
    );

//---------------------------- MEM stage ------------------------------

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 14) data memory 

    assign writedata_ex = readdata2_ex;

    data_mem u_dmem (
        .clk(clk),
        .ctrl_memread_mem(ctrl_memread_mem), .ctrl_memwrite_mem(ctrl_memwrite_mem), .aluout_mem(aluout_mem), .writedata_mem(writedata_mem), .readdata_mem(readdata_mem)
    );

    // MEM/WB pipeline register
    // --------------------------------------

    wire [31:0] readdata_mem;

    wire ctrl_regwrite_wb;
    wire [1:0] ctrl_wbsrc_wb;
    wire [31:0] readdata_wb;
    wire [31:0] cp0_readdata_wb;
    wire [31:0] aluout_wb;
    wire [4:0] writereg_wb;

    pipe_mem_wb u_memwb (
        .clk(clk),
        .final_flush_mem_wb(final_flush_mem_wb),

        .ctrl_regwrite_mem(ctrl_regwrite_mem),
        .ctrl_wbsrc_mem(ctrl_wbsrc_mem), 
        .readdata_mem(readdata_mem),
        .aluout_mem(aluout_mem),
        .writereg_mem(writereg_mem),
        .rd_mem(rd_mem),
        .cp0_readdata_mem(cp0_readdata),

        .ctrl_regwrite_wb(ctrl_regwrite_wb),
        .ctrl_wbsrc_wb(ctrl_wbsrc_wb), 
        .readdata_wb(readdata_wb),
        .aluout_wb(aluout_wb),
        .writereg_wb(writereg_wb),
        .rd_wb(rd_wb),
        .cp0_readdata_wb(cp0_readdata_wb)
    );
    

//---------------------------- WB stage ------------------------------

    wire [31:0] datatowritereg = (ctrl_wbsrc_wb == 2'b00) ? aluout_wb :
                                (ctrl_wbsrc_wb == 2'b01) ? readdata_wb :
                                (ctrl_wbsrc_wb == 2'b10) ? cp0_readdata_wb :
                                32'h00000000;

//---------------------------- Exception -----------------------------

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 15) exception arbiter

    wire [31:0] pc_ex = pc_plus4_ex - 32'd4;

    wire exception_req; 

    wire [31:0] cause;
    wire [31:0] faulting_pc;

    wire exc_flush_if_id;
    wire exc_flush_id_ex;
    wire exc_flush_ex_mem;
    wire exc_flush_mem_wb;

    exc_arbiter u_exc_arbiter (
        .div_by_zero_ex(div_by_zero_ex),
        .pc_ex(pc_ex),

        .exception_req(exception_req),
        .cause(cause),
        .faulting_pc(faulting_pc),

        .exc_flush_if_id(exc_flush_if_id),
        .exc_flush_id_ex(exc_flush_id_ex),
        .exc_flush_ex_mem(exc_flush_ex_mem),
        .exc_flush_mem_wb(exc_flush_mem_wb)
    );

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 16) co-procsessor 0

    wire [31:0] cp0_readdata; 
    wire [31:0] cp0_writedata;
    wire [31:0] handler_pc;
    wire [31:0] epc;

    cp0 u_cp0(
        .clk(clk),
        .exception_req(exception_req),
        .cause_in(cause),
        .faulting_pc(faulting_pc),

        .cp0_addr(rd_mem),
        .cp0_writedata(writedata_mem),
        
        .cp0_write_mem(cp0_write_mem),

        .cp0_readdata(cp0_readdata),
        .handler_pc(handler_pc),
        .epc(epc)
    );


endmodule

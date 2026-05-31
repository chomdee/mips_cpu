`timescale 1ns/1ps
`default_nettype none

module pipe_id_ex (
    input clk,
    input final_flush_id_ex,

    input ctrl_regdst_id, ctrl_branch_id, ctrl_memread_id, ctrl_memwrite_id, ctrl_alusrc_id, ctrl_regwrite_id, cp0_write_id,
    input [1:0] ctrl_wbsrc_id, ctrl_aluop_id,
    input [31:0] pc_plus4_id,
    input [31:0] readdata1_id, readdata2_id,
    input [31:0] imm32_id,
    input [5:0] funct_id,
    input [4:0] shamt_id,
    input [4:0] rt_id, rd_id, rs_id,
    
    output reg ctrl_regdst_ex, ctrl_branch_ex, ctrl_memread_ex, ctrl_memwrite_ex, ctrl_alusrc_ex, ctrl_regwrite_ex, cp0_write_ex,
    output reg [1:0] ctrl_wbsrc_ex, ctrl_aluop_ex,
    output reg [31:0] pc_plus4_ex,
    output reg [31:0] readdata1_ex, readdata2_ex,
    output reg [31:0] imm32_ex,
    output reg [5:0] funct_ex,
    output reg [4:0] shamt_ex,
    output reg [4:0] rt_ex, rd_ex, rs_ex
);
    initial begin
        ctrl_regdst_ex = 0;
        ctrl_branch_ex = 0;
        ctrl_memread_ex = 0;
        ctrl_memwrite_ex = 0;
        ctrl_alusrc_ex = 0;
        ctrl_regwrite_ex = 0;
        cp0_write_ex = 0;

        ctrl_wbsrc_ex = 0;
        ctrl_aluop_ex = 0;

        pc_plus4_ex = 0;
        readdata1_ex = 0;
        readdata2_ex = 0;

        imm32_ex = 0;
        funct_ex = 0;
        shamt_ex = 0;

        rt_ex = 0;
        rd_ex = 0;
        rs_ex = 0;
    end

    always @(posedge clk) begin
        if (final_flush_id_ex) begin
            ctrl_regdst_ex <= 0;
            ctrl_branch_ex <= 0;
            ctrl_memread_ex <= 0;
            ctrl_wbsrc_ex <= 0;
            ctrl_aluop_ex <= 0;
            ctrl_memwrite_ex <= 0;
            ctrl_alusrc_ex <= 0;
            ctrl_regwrite_ex <= 0;
            cp0_write_ex <= 0;

            pc_plus4_ex <= 0;

            readdata1_ex <= 0;
            readdata2_ex <= 0;
            imm32_ex <= 0;
            funct_ex <= 0;
            
            rt_ex <= 0;
            rd_ex <= 0;
            rs_ex <= 0;
        end else begin
            ctrl_regdst_ex <= ctrl_regdst_id;
            ctrl_branch_ex <= ctrl_branch_id;
            ctrl_memread_ex <= ctrl_memread_id;
            ctrl_wbsrc_ex <= ctrl_wbsrc_id;
            ctrl_aluop_ex <= ctrl_aluop_id;
            ctrl_memwrite_ex <= ctrl_memwrite_id;
            ctrl_alusrc_ex <= ctrl_alusrc_id;
            ctrl_regwrite_ex <= ctrl_regwrite_id;
            cp0_write_ex <= cp0_write_id;

            pc_plus4_ex <= pc_plus4_id;

            readdata1_ex <= readdata1_id;
            readdata2_ex <= readdata2_id;
            imm32_ex <= imm32_id;
            funct_ex <= funct_id;
            
            rt_ex <= rt_id;
            rd_ex <= rd_id;
            rs_ex <= rs_id;
        end
    end
    
endmodule
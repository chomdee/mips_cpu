`timescale 1ns/1ps
`default_nettype none

module pipe_id_ex (
    input clk,
    input ctrl_regdst_id, ctrl_branch_id, ctrl_memread_id, ctrl_memtoreg_id, ctrl_memwrite_id, ctrl_alusrc_id, ctrl_regwrite_id,
    input [1:0] ctrl_aluop_id,
    input [31:0] pc_plus4_id,
    input [31:0] readdata1_id, readdata2_id,
    input [31:0] imm32_id,
    input [5:0] funct_id,
    input [4:0] rt_id, rd_id,
    
    output reg ctrl_regdst_ex, ctrl_branch_ex, ctrl_memread_ex, ctrl_memtoreg_ex, ctrl_memwrite_ex, ctrl_alusrc_ex, ctrl_regwrite_ex,
    output reg [1:0] ctrl_aluop_ex,
    output reg [31:0] pc_plus4_ex,
    output reg [31:0] readdata1_ex, readdata2_ex,
    output reg [31:0] imm32_ex,
    output reg [5:0] funct_ex,
    output reg [4:0] rt_ex, rd_ex
);

    always @(posedge clk) begin
        ctrl_regdst_ex <= ctrl_regdst_id;
        ctrl_branch_ex <= ctrl_branch_id;
        ctrl_memread_ex <= ctrl_memread_id;
        ctrl_memtoreg_ex <= ctrl_memtoreg_id;
        ctrl_aluop_ex <= ctrl_aluop_id;
        ctrl_memwrite_ex <= ctrl_memwrite_id;
        ctrl_alusrc_ex <= ctrl_alusrc_id;
        ctrl_regwrite_ex <= ctrl_regwrite_id;

        pc_plus4_ex <= pc_plus4_id;

        readdata1_ex <= readdata1_id;
        readdata2_ex <= readdata2_id;
        imm32_ex <= imm32_id;
        funct_ex <= funct_id;
        
        rt_ex <= rt_id;
        rd_ex <= rd_id;
    end
    
endmodule
`timescale 1ns/1ps
`default_nettype none

module mux_flush (
    input wire ctrl_flush_id_ex,
    input wire ctrl_regdst,
    input wire ctrl_jump,
    input wire ctrl_branch,
    input wire ctrl_memread,
    input wire ctrl_memtoreg,
    input wire ctrl_memwrite,
    input wire ctrl_alusrc,
    input wire ctrl_regwrite,
    input wire [1:0] ctrl_aluop,

    output reg ctrl_regdst_id,
    output reg ctrl_jump_id,
    output reg ctrl_branch_id,
    output reg ctrl_memread_id,
    output reg ctrl_memtoreg_id,
    output reg ctrl_memwrite_id,
    output reg ctrl_alusrc_id,
    output reg ctrl_regwrite_id,
    output reg [1:0] ctrl_aluop_id
);
    always @(*) begin

        if(ctrl_flush_id_ex) begin
            ctrl_regdst_id = 0;
            ctrl_jump_id = 0;
            ctrl_branch_id = 0;
            ctrl_memread_id = 0;
            ctrl_memtoreg_id = 0;
            ctrl_memwrite_id = 0;
            ctrl_alusrc_id = 0;
            ctrl_regwrite_id = 0;
            ctrl_aluop_id = 2'd0;
        end
        else begin
            ctrl_regdst_id = ctrl_regdst;
            ctrl_jump_id = ctrl_jump;
            ctrl_branch_id = ctrl_branch;
            ctrl_memread_id = ctrl_memread;
            ctrl_memtoreg_id = ctrl_memtoreg;
            ctrl_memwrite_id = ctrl_memwrite;
            ctrl_alusrc_id = ctrl_alusrc;
            ctrl_regwrite_id = ctrl_regwrite;
            ctrl_aluop_id = ctrl_aluop;
        end

    end
endmodule
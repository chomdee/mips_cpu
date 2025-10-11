`timescale 1ns/1ps
`default_nettype none

module pipe_ex_mem (
    input clk,
    input ctrl_branch_ex, ctrl_memread_ex, ctrl_memtoreg_ex, ctrl_memwrite_ex, ctrl_regwrite_ex,
    input [31:0] branch_target_ex,
    input ctrl_zero_ex,
    input [31:0] aluout_ex,
    input [31:0] writedata_ex,
    input [4:0] writereg_ex,
    input [4:0] rd_ex,

    output reg ctrl_branch_mem, ctrl_memread_mem, ctrl_memtoreg_mem, ctrl_memwrite_mem, ctrl_regwrite_mem,
    output reg [31:0] branch_target_mem,
    output reg ctrl_zero_mem,
    output reg [31:0] aluout_mem,
    output reg [31:0] writedata_mem,
    output reg [4:0] writereg_mem,
    output reg [4:0] rd_mem
);
    always @(posedge clk) begin
        ctrl_branch_mem <= ctrl_branch_ex;
        ctrl_memread_mem <= ctrl_memread_ex;
        ctrl_memtoreg_mem <= ctrl_memtoreg_ex;
        ctrl_memwrite_mem <= ctrl_memwrite_ex;
        ctrl_regwrite_mem <= ctrl_regwrite_ex;

        branch_target_mem <= branch_target_ex;
        ctrl_zero_mem <= ctrl_zero_ex;
        aluout_mem <= aluout_ex;
        writedata_mem <= writedata_ex;
        writereg_mem <= writereg_ex;
        rd_mem <= rd_ex;
    end
    
endmodule
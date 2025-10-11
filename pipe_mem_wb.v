`timescale 1ns/1ps
`default_nettype none

module pipe_mem_wb (
    input clk,
    input ctrl_memtoreg_mem, ctrl_regwrite_mem,
    input [31:0] readdata_mem,
    input [31:0] aluout_mem, // data writing to register
    input [4:0] writereg_mem,
    input [4:0] rd_mem,

    output reg ctrl_memtoreg_wb, ctrl_regwrite_wb,
    output reg [31:0] readdata_wb,
    output reg [31:0] aluout_wb,
    output reg [4:0] writereg_wb,
    output reg [4:0] rd_wb
);

    always @(posedge clk) begin
        ctrl_memtoreg_wb <= ctrl_memtoreg_mem;
        ctrl_regwrite_wb <= ctrl_regwrite_mem;

        readdata_wb <= readdata_mem;
        aluout_wb <= aluout_mem;
        rd_wb <= rd_mem;
        writereg_wb <= writereg_mem;
    end
    
endmodule
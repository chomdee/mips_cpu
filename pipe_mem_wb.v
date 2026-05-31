`timescale 1ns/1ps
`default_nettype none

module pipe_mem_wb (
    input clk,
    input final_flush_mem_wb,

    input ctrl_regwrite_mem,
    input [1:0] ctrl_wbsrc_mem, 
    input [31:0] readdata_mem,
    input [31:0] aluout_mem, // data writing to register
    input [4:0] writereg_mem,
    input [4:0] rd_mem,
    input [31:0] cp0_readdata_mem,

    output reg ctrl_regwrite_wb,
    output reg [1:0] ctrl_wbsrc_wb,
    output reg [31:0] readdata_wb,
    output reg [31:0] aluout_wb,
    output reg [4:0] writereg_wb,
    output reg [4:0] rd_wb,
    output reg [31:0] cp0_readdata_wb
);

    always @(posedge clk) begin
        if (final_flush_mem_wb) begin
            ctrl_wbsrc_wb <= 0;
            ctrl_regwrite_wb <= 0;

            readdata_wb <= 0;
            aluout_wb <= 0;
            rd_wb <= 0;
            writereg_wb <= 0;
            cp0_readdata_wb <= 0;

        end else begin
            ctrl_wbsrc_wb <= ctrl_wbsrc_mem;
            ctrl_regwrite_wb <= ctrl_regwrite_mem;

            readdata_wb <= readdata_mem;
            aluout_wb <= aluout_mem;
            rd_wb <= rd_mem;
            writereg_wb <= writereg_mem;

            cp0_readdata_wb <= cp0_readdata_mem;
        end
    end
    
endmodule
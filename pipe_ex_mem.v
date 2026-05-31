`timescale 1ns/1ps
`default_nettype none

module pipe_ex_mem (
    input clk,
    input final_flush_ex_mem,

    input ctrl_memread_ex, ctrl_memwrite_ex, ctrl_regwrite_ex, cp0_write_ex,
    input [1:0] ctrl_wbsrc_ex,
    input [31:0] aluout_ex,
    input [31:0] writedata_ex,
    input [4:0] writereg_ex,
    input [4:0] rd_ex,
    input [4:0] rt_ex,

    output reg ctrl_memread_mem, ctrl_memwrite_mem, ctrl_regwrite_mem, cp0_write_mem,
    output reg [1:0] ctrl_wbsrc_mem,
    output reg [31:0] aluout_mem,
    output reg [31:0] writedata_mem,
    output reg [4:0] writereg_mem,
    output reg [4:0] rd_mem,
    output reg [4:0] rt_mem
);
    always @(posedge clk) begin
        if(final_flush_ex_mem) begin
            ctrl_memread_mem <= 0;
            ctrl_wbsrc_mem <= 0;
            ctrl_memwrite_mem <= 0;
            ctrl_regwrite_mem <= 0;
            cp0_write_mem <= 0;

            aluout_mem <= 0;
            writedata_mem <= 0;
            writereg_mem <= 0;
            rd_mem <= 0;
            rt_mem <= 0;

        end else begin
            ctrl_memread_mem <= ctrl_memread_ex;
            ctrl_wbsrc_mem <= ctrl_wbsrc_ex;
            ctrl_memwrite_mem <= ctrl_memwrite_ex;
            ctrl_regwrite_mem <= ctrl_regwrite_ex;
            cp0_write_mem <= cp0_write_ex;

            aluout_mem <= aluout_ex;
            writedata_mem <= writedata_ex;
            writereg_mem <= writereg_ex;
            rd_mem <= rd_ex;
            rt_mem <= rt_ex;
        end
    end
    
    
endmodule
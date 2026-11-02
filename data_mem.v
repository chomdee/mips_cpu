`timescale 1ns/1ps
`default_nettype none

module data_mem (
    input wire clk,
    input wire ctrl_memread_mem,
    input wire ctrl_memwrite_mem,
    input wire [31:0] aluout_mem,
    input wire [31:0] writedata_mem, // data to write

    output wire [31:0] readdata_mem // data that read
);

    reg [31:0] memory [0:255];

    assign readdata_mem = (ctrl_memread_mem) ? memory[aluout_mem[9:2]] : 32'd0;

    always @(posedge clk) begin
        if (ctrl_memwrite_mem)
            memory[aluout_mem[9:2]] <= writedata_mem;
    end

endmodule
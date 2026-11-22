`timescale 1ns/1ps
`default_nettype none

module pipe_if_id (
    input wire clk,
    input wire rst,
    input wire final_flush_if_id,

    input wire ifid_write,
    input wire [31:0] pc_plus4_if,
    input wire [31:0] instr_if,

    output reg [31:0] pc_plus4_id,
    output reg [31:0] instr_id
);

    always @(posedge clk) begin
        if(rst) begin
            pc_plus4_id <= 0;
            instr_id <= 0;
        end
        else if(final_flush_if_id) begin
            pc_plus4_id <= 32'd0;
            instr_id <= 32'd0;
        end
        else if (ifid_write) begin
            pc_plus4_id <= pc_plus4_if;
            instr_id <= instr_if;
        end
    end
    
endmodule
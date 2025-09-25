`timescale 1ns/1ps
`default_nettype none

module pipe_if_id (
    input clk,
    input [31:0] pc_plus4_if,
    input [31:0] instr_if,

    output reg [31:0] pc_plus4_id,
    output reg [31:0] instr_id
);
    
    always @(posedge clk) begin
        pc_plus4_id <= pc_plus4_if;
        instr_id <= instr_if;
    end
    
endmodule
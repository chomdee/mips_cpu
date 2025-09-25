`timescale 1ns/1ps
`default_nettype none

module sext16to32 (
    imm16_id,
    imm32_id
);
    input [15:0] imm16_id;
    output [31:0] imm32_id;

    wire [31:0] imm32_id;
    assign imm32_id = {{16{imm16_id[15]}}, imm16_id};

endmodule
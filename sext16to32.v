`timescale 1ns/1ps
`default_nettype none

module sext16to32 (
    imm16_id,
    imm32_id
);
    input wire [15:0] imm16_id;
    output wire [31:0] imm32_id;

    assign imm32_id = {{16{imm16_id[15]}}, imm16_id};

endmodule
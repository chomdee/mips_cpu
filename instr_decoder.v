`timescale 1ns/1ps
`default_nettype none

module instr_decoder (
    input  wire [31:0] instr_id,

    output wire [5:0]  opcode_id,
    output wire [4:0]  rs_id,
    output wire [4:0]  rt_id,
    output wire [4:0]  rd_id,
    output wire [4:0]  shamt_id,
    output wire [5:0]  funct_id,

    output wire [15:0] imm16_id,        // branch offset raw
    output wire [25:0] jump_addr_id    // jump index (addr[25:0])
);

    assign opcode_id  = instr_id[31:26];
    assign rs_id      = instr_id[25:21];
    assign rt_id      = instr_id[20:16];
    assign rd_id      = instr_id[15:11];
    assign shamt_id   = instr_id[10:6];
    assign funct_id   = instr_id[5:0];
    assign imm16_id   = instr_id[15:0];
    assign jump_addr_id = instr_id[25:0];

endmodule

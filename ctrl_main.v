`timescale 1ns/1ps
`default_nettype none

module ctrl_main (
    input  [5:0] opcode_id,

    output reg   ctrl_regdst_id,
    output reg   ctrl_jump_id,
    output reg   ctrl_branch_id,
    output reg   ctrl_memread_id,
    output reg   ctrl_memtoreg_id,
    output reg   ctrl_memwrite_id,
    output reg   ctrl_alusrc_id,
    output reg   ctrl_regwrite_id,

    output reg [1:0] ctrl_aluop_id
);

    always @(*) begin
        ctrl_regdst_id   = 0;
        ctrl_jump_id     = 0;
        ctrl_branch_id   = 0;
        ctrl_memread_id  = 0;
        ctrl_memtoreg_id = 0;
        ctrl_memwrite_id = 0;
        ctrl_alusrc_id   = 0;
        ctrl_regwrite_id = 0;
        ctrl_aluop_id    = 2'b00;

        case (opcode_id)
            6'b000000: begin // R-type
                ctrl_regdst_id   = 1;
                ctrl_regwrite_id = 1;
                ctrl_aluop_id    = 2'b10;
            end
            6'b100011: begin // lw
                ctrl_alusrc_id   = 1;
                ctrl_memtoreg_id = 1;
                ctrl_regwrite_id = 1;
                ctrl_memread_id  = 1;
            end
            6'b101011: begin // sw
                ctrl_alusrc_id   = 1;
                ctrl_memwrite_id = 1;
                ctrl_aluop_id    = 2'b00;
            end
            6'b000100: begin // beq
                ctrl_branch_id   = 1;
                ctrl_aluop_id    = 2'b01;
            end
            6'b000101: begin // bne
                ctrl_branch_id   = 1;
                ctrl_aluop_id    = 2'b01;
            end
            6'b001000: begin // addi
                ctrl_alusrc_id   = 1;
                ctrl_regwrite_id = 1;
            end
            6'b000010: begin 
                ctrl_jump_id     = 1;
            end
            default: begin
                // none
            end
        endcase
    end
endmodule

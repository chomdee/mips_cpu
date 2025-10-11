`timescale 1ns/1ps
`default_nettype none

module ctrl_main (
    input  [5:0] opcode_id,

    output reg   ctrl_regdst,
    output reg   ctrl_jump,
    output reg   ctrl_branch,
    output reg   ctrl_memread,
    output reg   ctrl_memtoreg,
    output reg   ctrl_memwrite,
    output reg   ctrl_alusrc,
    output reg   ctrl_regwrite,

    output reg [1:0] ctrl_aluop
);

    always @(*) begin
        ctrl_regdst   = 0;
        ctrl_jump     = 0;
        ctrl_branch   = 0;
        ctrl_memread  = 0;
        ctrl_memtoreg = 0;
        ctrl_memwrite = 0;
        ctrl_alusrc   = 0;
        ctrl_regwrite = 0;
        ctrl_aluop    = 2'b00;

        case (opcode_id)
            6'b000000: begin // R-type
                ctrl_regdst   = 1;
                ctrl_regwrite = 1;
                ctrl_aluop    = 2'b10;
            end
            6'b100011: begin // lw
                ctrl_alusrc   = 1;
                ctrl_memtoreg = 1;
                ctrl_regwrite = 1;
                ctrl_memread  = 1;
            end
            6'b101011: begin // sw
                ctrl_alusrc   = 1;
                ctrl_memwrite = 1;
                ctrl_aluop    = 2'b00;
            end
            6'b000100: begin // beq
                ctrl_branch   = 1;
                ctrl_aluop    = 2'b01;
            end
            6'b000101: begin // bne
                ctrl_branch   = 1;
                ctrl_aluop    = 2'b01;
            end
            6'b001000: begin // addi
                ctrl_alusrc   = 1;
                ctrl_regwrite = 1;
            end
            6'b000010: begin 
                ctrl_jump     = 1;
            end
            default: begin
                // none
            end
        endcase
    end
endmodule

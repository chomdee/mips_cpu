`timescale 1ns/1ps
`default_nettype none

module ctrl_main (
    input  [5:0] opcode_id,
    input  [4:0] rs_id,
    input  [5:0] funct_id, 

    output reg   ctrl_regdst,
    output reg   ctrl_jump,
    output reg   ctrl_branch,
    output reg   ctrl_memread,
    output reg   ctrl_memwrite,
    output reg   ctrl_alusrc,
    output reg   ctrl_regwrite,

    output reg   cp0_write,
    output reg   is_eret,

    output reg [1:0] ctrl_wbsrc,
    output reg [1:0] ctrl_aluop
);

    always @(*) begin
        ctrl_regdst   = 0;
        ctrl_jump     = 0;
        ctrl_branch   = 0;
        ctrl_memread  = 0;
        ctrl_memwrite = 0;
        ctrl_alusrc   = 0;
        ctrl_regwrite = 0;

        ctrl_wbsrc = 2'b00;
        ctrl_aluop    = 2'b00;

        cp0_write = 0;
        is_eret = 0;

        case (opcode_id)
            6'b000000: begin // R-type
                ctrl_regdst   = 1;
                ctrl_regwrite = 1;
                ctrl_aluop    = 2'b10;
            end
            6'b010000: begin // CP0
                case(rs_id) 
                    5'b00000: begin // mfc0
                        ctrl_regwrite = 1; 
                        ctrl_regdst = 0; // select where to write
                        ctrl_wbsrc = 2'b10; // select data to write
                    end
                    5'b00100: begin // mtc0
                        cp0_write = 1;
                    end
                    5'b10000: begin
                        case(funct_id)
                            6'b011000: begin
                                is_eret = 1;
                            end
                        endcase
                    end
                endcase
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
            6'b100011: begin // lw
                ctrl_alusrc   = 1;
                ctrl_wbsrc = 1;
                ctrl_regwrite = 1;
                ctrl_memread  = 1;
            end
            6'b101011: begin // sw
                ctrl_alusrc   = 1;
                ctrl_memwrite = 1;
                ctrl_aluop    = 2'b00;
            end
            default: begin
                // none
            end
        endcase
    end
endmodule

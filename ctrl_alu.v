module ctrl_alu (
    input  [1:0] ctrl_aluop_ex,
    input  [5:0] funct_ex,
    output reg [3:0] ctrl_aluctrl_ex
);

    always @(*) begin
        case (ctrl_aluop_ex)
            2'b00: ctrl_aluctrl_ex = 4'b0010; // lw, sw → add
            2'b01: ctrl_aluctrl_ex = 4'b0110; // beq → subtract
            2'b10: begin               // R-type → decided by funct_ex
                case (funct_ex)
                    6'b100000: ctrl_aluctrl_ex = 4'b0010; // add
                    6'b100010: ctrl_aluctrl_ex = 4'b0110; // sub
                    6'b100100: ctrl_aluctrl_ex = 4'b0000; // and
                    6'b100101: ctrl_aluctrl_ex = 4'b0001; // or
                    6'b100111: ctrl_aluctrl_ex = 4'b1100; // nor
                    6'b101010: ctrl_aluctrl_ex = 4'b0111; // slt
                    default:   ctrl_aluctrl_ex = 4'b1111; // undefined
                endcase
            end
            2'b11: ctrl_aluctrl_ex = 4'b0010; // addtitional alu ctrl
            default: ctrl_aluctrl_ex = 4'b0000;
        endcase
    end
endmodule

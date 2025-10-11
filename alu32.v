`timescale 1ns/1ps
`default_nettype none

module alu32 (
    input [3:0] ctrl_aluctrl_ex, 
    input [31:0] operand1, operand2, 
    input [4:0] shamt_ex,

    output reg [31:0] aluout_ex, 
    output ctrl_zero_ex
);

    assign ctrl_zero_ex = (aluout_ex==0);
    
    always @(ctrl_aluctrl_ex, operand1, operand2) begin
        case (ctrl_aluctrl_ex)
            4'b0000: aluout_ex = operand1 & operand2;
            4'b0001: aluout_ex = operand1 | operand2;
            4'b0010: aluout_ex = operand1 + operand2;
            4'b0110: aluout_ex = operand1 - operand2;
            4'b0111: aluout_ex = operand1 < operand2 ? 1 : 0; // slt
            4'b1000: aluout_ex = operand2 << shamt_ex; // sll
            4'b1100: aluout_ex = ~(operand1 | operand2); // nor
            default: aluout_ex = 0;
        endcase        
    end
endmodule
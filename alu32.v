`timescale 1ns/1ps
`default_nettype none

module alu32 (
    input wire [3:0] ctrl_aluctrl_ex, 
    input wire [31:0] operand1, operand2, 
    input wire [4:0] shamt_ex, 

    output reg [31:0] aluout_ex, 
    output wire ctrl_zero_ex,
    output wire div_by_zero_ex
);

    assign ctrl_zero_ex = (aluout_ex==0);
    assign div_by_zero_ex = ((operand2 == 0) && (ctrl_aluctrl_ex == 4'b1001));

    
    always @(*) begin
        if(!div_by_zero_ex) begin
            case (ctrl_aluctrl_ex)
                4'b0000: aluout_ex = operand1 & operand2;
                4'b0001: aluout_ex = operand1 | operand2;
                4'b0010: aluout_ex = operand1 + operand2;
                4'b0110: aluout_ex = operand1 - operand2;
                4'b0111: aluout_ex = $signed(operand1) < $signed(operand2) ? 1 : 0; // slt
                4'b1000: aluout_ex = operand2 << shamt_ex; // sll
                4'b1001: aluout_ex = $signed(operand1) / $signed(operand2); // simplified version of div
                4'b1100: aluout_ex = ~(operand1 | operand2); // nor
                default: aluout_ex = 0;
            endcase
        end 
        else begin
            aluout_ex = 32'd0;
        end
    end
endmodule
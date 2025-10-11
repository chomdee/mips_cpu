`timescale 1ns/1ps
`default_nettype none

module mux_operand1 (
    input [1:0] forwardA,
    input [31:0] readdata1_ex,
    input [31:0] datatowritereg,
    input [31:0] aluout_mem,

    output reg [31:0] operand1
);

    always @(*) begin
        case (forwardA)
            2'b00: operand1 = readdata1_ex;
            2'b10: operand1 = aluout_mem;
            2'b01: operand1 = datatowritereg;
            default: operand1 = readdata1_ex;
        endcase
    end
    
endmodule
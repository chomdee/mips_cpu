`timescale 1ns/1ps
`default_nettype none

module mux_operand2 (
    input wire [1:0] forwardB,
    input wire [31:0] readdata2_ex,
    input wire [31:0] datatowritereg,
    input wire [31:0] aluout_mem,

    output reg [31:0] operand2_forwarded
);

    always @(*) begin
        case (forwardB)
            2'b00: operand2_forwarded = readdata2_ex;
            2'b10: operand2_forwarded = aluout_mem;
            2'b01: operand2_forwarded = datatowritereg;
            default: operand2_forwarded = readdata2_ex;
        endcase
    end
    
endmodule
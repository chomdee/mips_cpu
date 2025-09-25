`timescale 1ns/1ps
`default_nettype none

module branch_adder (
    input [31:0] imm32_ex,
    input [31:0] pc_plus4_ex,

    output reg [31:0] branch_target_ex
);
    wire [31:0] imm32_2sl;

    assign imm32_2sl = imm32_ex << 2;

    always @(*) begin
        branch_target_ex = pc_plus4_ex + imm32_2sl;
    end
    
endmodule
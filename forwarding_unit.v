`timescale 1ns/1ps
`default_nettype none

module forwarding_unit (
    input [4:0] rs_ex,
    input [4:0] rt_ex,
    input [4:0] writereg_mem,
    input [4:0] writereg_wb,
    input ctrl_regwrite_mem,
    input ctrl_regwrite_wb,

    output reg [1:0] forwardA,
    output reg [1:0] forwardB
);

    always @(*) begin
    if ((ctrl_regwrite_mem) && (writereg_mem != 5'd0) && (writereg_mem == rs_ex))
        forwardA = 2'b10;    // MEM hazard
    else if ((ctrl_regwrite_wb) && (writereg_wb != 5'd0) && (writereg_wb == rs_ex))
        forwardA = 2'b01;    // WB hazard
    else
        forwardA = 2'b00;    // No hazard
    end

    always @(*) begin
        if ((ctrl_regwrite_mem) && (writereg_mem != 5'd0) && (writereg_mem == rt_ex))
            forwardB = 2'b10;    // MEM hazard
        else if ((ctrl_regwrite_wb) && (writereg_wb != 5'd0) && (writereg_wb == rt_ex))
            forwardB = 2'b01;    // WB hazard
        else
            forwardB = 2'b00;    // No hazard
    end

    
endmodule
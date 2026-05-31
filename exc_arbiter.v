`timescale 1ns/1ps
`default_nettype none

module exc_arbiter (
    // All exception signals
    input  wire div_by_zero_ex,
    
    // All stage PCs
    input  wire [31:0] pc_ex,

    // outputs 
    output wire exception_req,
    output reg [31:0] cause,
    output reg [31:0] faulting_pc,

    output wire exc_flush_if_id,
    output wire exc_flush_id_ex,
    output wire exc_flush_ex_mem,
    output wire exc_flush_mem_wb
);

    wire exc_req_id = 1'b0;
    wire exc_req_ex = div_by_zero_ex;
    wire exc_req_mem = 1'b0;
    wire exc_req_wb = 1'b0;

    assign exception_req = exc_req_id | exc_req_ex | exc_req_mem | exc_req_wb;

    assign exc_flush_if_id = exc_req_id | exc_req_ex | exc_req_mem | exc_req_wb;
    assign exc_flush_id_ex = exc_req_ex | exc_req_mem | exc_req_wb;
    assign exc_flush_ex_mem = exc_req_mem | exc_req_wb;
    assign exc_flush_mem_wb = exc_req_wb;

    always @(*) begin
        cause         = 32'd0;
        faulting_pc   = 32'd0;

        if (div_by_zero_ex == 1'b1) begin
            cause         = 32'd1;  
            faulting_pc   = pc_ex;
        end
    end
    
endmodule
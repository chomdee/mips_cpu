`timescale 1ns/1ps
`default_nettype none

module cp0 (
    input wire clk,
    input wire exception_req,
    input wire [31:0] cause_in,
    input wire [31:0] faulting_pc,

    input wire [4:0] cp0_addr, // $rd regsiter
    input wire [31:0] cp0_writedata, // the data to write (mtc0)
    
    input wire cp0_write_mem, // the write control signal


    output reg [31:0] cp0_readdata, // the data to read (mfc0)
    output wire [31:0] handler_pc,
    output reg [31:0] epc
);
    reg [31:0] cause;


    always @(posedge clk) begin
        if(exception_req) begin
            cause <= cause_in;
            epc <= faulting_pc;
        end else if (cp0_write_mem) begin 
            case (cp0_addr)
                5'd13: cause  <= cp0_writedata;
                5'd14: epc  <= cp0_writedata; 
            endcase
        end
    end

    assign handler_pc = 32'h0000_0030;

    always @(*) begin
        case (cp0_addr)
            5'd13: cp0_readdata = cause;
            5'd14: cp0_readdata = epc;
            default: cp0_readdata = 32'h00000000;
        endcase
    end 
    
endmodule
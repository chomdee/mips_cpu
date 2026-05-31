`timescale 1ns/1ps
`default_nettype none

module reg_file (
    input clk,
    input [4:0] rs_id, rt_id, writereg_wb, // the register numbers to read & write
    input [31:0] datatowritereg, // the data to write
    input ctrl_regwrite_wb, // the write control signal

    output [31:0] readdata1_id, readdata2_id,
    output [31:0] cp0_writedata
);
    reg [31:0] RF [31:0]; // 2D register file

    initial begin
        RF[0] = 32'd0; // $zero register reset
        
        // example first settings
        // using program.hex to operate
        RF[8] = 32'd24; // $t0
        RF[9]  = 32'd0; // $t1
        RF[10] = 32'd0; // $t2
        RF[11] = 32'd10; // $t3
        RF[12] = 32'd10; // $t4
        RF[13] = 32'd0;  // $t5
        RF[14] = 32'd0; // $t6
        RF[15] = 32'd0; // $t7
        RF[24] = 32'h0F0F0F0F; // $t8
    end

    assign readdata1_id = RF[rs_id];
    assign readdata2_id = RF[rt_id];

    always @(posedge clk) begin    
        if (ctrl_regwrite_wb && (writereg_wb != 5'd0)) begin
            RF[writereg_wb] <= datatowritereg; 
        end     
    end

endmodule
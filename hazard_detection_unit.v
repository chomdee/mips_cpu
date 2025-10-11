`timescale 1ns/1ps
`default_nettype none

module hazard_detection_unit (
    input ctrl_memread_ex,
    input [4:0] rs_id, rt_id, rt_ex,

    output reg ctrl_nop,
    output reg pc_write,
    output reg ifid_write
);  
    initial begin
        ctrl_nop = 0;
        pc_write = 1; 
        ifid_write = 1;
    end

    always @(*) begin
        ctrl_nop = 0;
        pc_write = 1;
        ifid_write = 1;

        if((ctrl_memread_ex) && ((rt_ex == rs_id) || (rt_ex == rt_id))) begin
            ctrl_nop = 1;
            pc_write = 0;
            ifid_write = 0;
        end 
    end
endmodule
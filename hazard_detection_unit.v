`timescale 1ns/1ps
`default_nettype none

module hazard_detection_unit (
    input ctrl_memread_ex,
    input [4:0] rs_id, rt_id, rt_ex,

    input branch_taken_ex,

    input exception_req,
    input exc_flush_if_id,
    input exc_flush_id_ex,
    input exc_flush_ex_mem,
    input exc_flush_mem_wb,

    input is_eret,

    output reg pc_write,
    output reg ifid_write,

    output final_flush_if_id,
    output final_flush_id_ex,
    output final_flush_ex_mem,
    output final_flush_mem_wb
);  
    reg ctrl_nop;

    initial begin

        ctrl_nop = 0;
        pc_write = 1; 
        ifid_write = 1;
    end
    
    assign final_flush_if_id = branch_taken_ex | exc_flush_if_id | is_eret;
    assign final_flush_id_ex = ctrl_nop | branch_taken_ex | exc_flush_id_ex | is_eret;
    assign final_flush_ex_mem = exc_flush_ex_mem;
    assign final_flush_mem_wb = exc_flush_mem_wb;

    always @(*) begin
        ctrl_nop = 0;
        pc_write = 1;
        ifid_write = 1;
        
        if (exception_req) begin
            pc_write = 1;
            ifid_write = 1;
        end
        // load-use stall(flush가 아닌 bubble!!!)
        else if ((ctrl_memread_ex) && ((rt_ex == rs_id) || (rt_ex == rt_id))) begin
            ctrl_nop = 1;
            pc_write = 0; // 다음 명령어를 가져오지 말라는 의미.
                          // 즉, cpu.v 에서 next_pc_if에 저장되어있던 값이 전달이 되지 않음. (한 턴 쉬자)

            ifid_write = 0; // if_PR(pipeline register)에서 id_PR로 넘기지 말라는 의미.
                            // 즉, 여기서도 pc_plus4_if에 값이 저장되어있지만 1 cycle 동안 옮겨지지 않음. (한 턴 쉬자)
        end 
    end
endmodule
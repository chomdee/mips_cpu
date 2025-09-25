module data_mem (
    input clk,
    input ctrl_memread_mem,
    input ctrl_memwrite_mem,
    input [31:0] aluout_mem,
    input [31:0] writedata_mem, // data to write

    output [31:0] readdata_mem // data that read
);

    reg [31:0] memory [255:0];
    
    initial begin
        #2000; // time of program finish
        $writememh("memory_dump.hex", uut.u_dmem.memory);
    end

    assign readdata_mem = (ctrl_memread_mem) ? memory[aluout_mem[9:2]] : 32'd0;

    always @(posedge clk) begin
        if (ctrl_memwrite_mem)
            memory[aluout_mem[9:2]] <= writedata_mem;
    end

endmodule
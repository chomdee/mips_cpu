module instr_mem (
    input [31:0] pc_if,
    output reg [31:0] instr_if
);

    reg [31:0] memory [0:255];  // 256 word = 1 KB

    initial begin
        $readmemh("program.hex", memory);
    end

    always @(*) begin
        instr_if = memory[pc_if[9:2]]; // word addressing
    end
    
endmodule
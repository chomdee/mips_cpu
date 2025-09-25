`timescale 1ns/1ps

module cpu_tb;
    reg clk;
    wire [31:0] instr;

    // CPU instance
    cpu uut (
        .clk(clk),
        .instr(instr)
    );

    wire [31:0] RF8  = uut.u_rf.RF[8];   // $t0
    wire [31:0] RF9  = uut.u_rf.RF[9];   // $t1
    wire [31:0] RF10 = uut.u_rf.RF[10];  // $t2
    wire [31:0] RF12 = uut.u_rf.RF[12];  // $t4
    wire [31:0] RF13 = uut.u_rf.RF[13];  // $t5
    wire [31:0] RF15 = uut.u_rf.RF[15];  // $t7
    wire [31:0] RF24 = uut.u_rf.RF[24];  // $t8


    initial begin
        clk = 0;
        forever #50 clk = ~clk;  
    end

    always @(posedge clk) begin
        $display("time=%0t pc=%h instr=%h", $time, uut.pc_if, uut.instr);
    end

    initial begin
        $dumpfile("cpu_tb.vcd");
        $dumpvars(0, cpu_tb);
        #2000 $finish; 
    end
endmodule
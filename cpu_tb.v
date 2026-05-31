`timescale 1ns/1ps
`default_nettype none

module cpu_tb;
    reg clk;
    wire [31:0] instr;

    // CPU instance
    cpu uut (
        .clk(clk),
        .instr(instr)
    );

    wire [31:0] RF0  = uut.u_rf.RF[0];   // $zero
    wire [31:0] RF1  = uut.u_rf.RF[1];   // $at
    wire [31:0] RF2  = uut.u_rf.RF[2];   // $v0
    wire [31:0] RF3  = uut.u_rf.RF[3];   // $v1
    wire [31:0] RF4  = uut.u_rf.RF[4];   // $a0
    wire [31:0] RF5  = uut.u_rf.RF[5];   // $a1
    wire [31:0] RF6  = uut.u_rf.RF[6];   // $a2
    wire [31:0] RF7  = uut.u_rf.RF[7];   // $a3

    wire [31:0] RF8  = uut.u_rf.RF[8];   // $t0
    wire [31:0] RF9  = uut.u_rf.RF[9];   // $t1
    wire [31:0] RF10 = uut.u_rf.RF[10];  // $t2
    wire [31:0] RF11 = uut.u_rf.RF[11];  // $t3
    wire [31:0] RF12 = uut.u_rf.RF[12];  // $t4
    wire [31:0] RF13 = uut.u_rf.RF[13];  // $t5
    wire [31:0] RF14 = uut.u_rf.RF[14];  // $t6
    wire [31:0] RF15 = uut.u_rf.RF[15];  // $t7

    wire [31:0] RF16 = uut.u_rf.RF[16];  // $s0
    wire [31:0] RF17 = uut.u_rf.RF[17];  // $s1
    wire [31:0] RF18 = uut.u_rf.RF[18];  // $s2
    wire [31:0] RF19 = uut.u_rf.RF[19];  // $s3
    wire [31:0] RF20 = uut.u_rf.RF[20];  // $s4
    wire [31:0] RF21 = uut.u_rf.RF[21];  // $s5
    wire [31:0] RF22 = uut.u_rf.RF[22];  // $s6
    wire [31:0] RF23 = uut.u_rf.RF[23];  // $s7

    wire [31:0] RF24 = uut.u_rf.RF[24];  // $t8
    wire [31:0] RF25 = uut.u_rf.RF[25];  // $t9
    wire [31:0] RF26 = uut.u_rf.RF[26];  // $k0
    wire [31:0] RF27 = uut.u_rf.RF[27];  // $k1
    wire [31:0] RF28 = uut.u_rf.RF[28];  // $gp
    wire [31:0] RF29 = uut.u_rf.RF[29];  // $sp
    wire [31:0] RF30 = uut.u_rf.RF[30];  // $fp/$s8
    wire [31:0] RF31 = uut.u_rf.RF[31];  // $ra



    initial begin
        clk = 0;
        forever #50 clk = ~clk;  
    end

    always @(posedge clk) begin
        $display("time=%0t pc=%h instr=%h", $time, uut.pc_if, uut.instr);
    end

    initial begin
        $dumpfile("build/cpu_tb.vcd");
        $dumpvars(0, cpu_tb);
        #5000 $finish; 
    end
endmodule
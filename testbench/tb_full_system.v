`timescale 1ns / 1ps

module tb_full_system;

    // Inputs
    reg clk;
    reg rst;
    reg s1_raw;
    reg s2_raw;
    reg mode;
    reg manual_light;

    // Outputs
    wire buzzer;
    wire red;
    wire yellow;
    wire green;
    wire light;
    wire [6:0] seg;
    wire [3:0] an;

    // DUT
    full_system uut (
        .clk(clk),
        .rst(rst),
        .s1_raw(s1_raw),
        .s2_raw(s2_raw),
        .mode(mode),
        .manual_light(manual_light),
        .buzzer(buzzer),
        .red(red),
        .yellow(yellow),
        .green(green),
        .light(light),
        .seg(seg),
        .an(an)
    );

    // Clock: 100 MHz (10 ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize
        clk = 0;
        rst = 1;
        s1_raw = 1;
        s2_raw = 1;
        mode = 0;
        manual_light = 0;

        // Reset
        #100;
        rst = 0;
        #50;

        // =========================
        // SCENARIO 1: ENTRY (S1 → S2)
        // =========================
        s1_raw = 0;
        #20_000_000;

        s2_raw = 0;
        #20_000_000;

        s1_raw = 1;
        #20_000_000;

        s2_raw = 1;
        #20_000_000;

        // =========================
        // SCENARIO 2: EXIT (S2 → S1)
        // =========================
        s2_raw = 0;
        #20_000_000;

        s1_raw = 0;
        #20_000_000;

        s2_raw = 1;
        #20_000_000;

        s1_raw = 1;
        #20_000_000;

        // =========================
        // SCENARIO 3: INVALID TIMEOUT
        // =========================
        s1_raw = 0;
        #600_000_000;

        s2_raw = 0;
        #20_000_000;

        s1_raw = 1;
        s2_raw = 1;

        // Finish
        #100;
        $stop;
    end

endmodule

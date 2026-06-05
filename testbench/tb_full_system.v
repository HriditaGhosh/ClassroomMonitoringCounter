`timescale 1ns / 1ps

module tb_full_system;

    // =========================================================
    // DUT Ports
    // =========================================================
    reg  clk;
    reg  rst;
    reg  s1_raw;
    reg  s2_raw;
    reg  mode;
    reg  manual_light;

    wire buzzer;
    wire red;
    wire yellow;
    wire green;
    wire light;
    wire [6:0] seg;
    wire [3:0]  an;

    // =========================================================
    // DUT Instantiation
    // =========================================================
    full_system uut (
        .clk         (clk),
        .rst         (rst),
        .s1_raw      (s1_raw),
        .s2_raw      (s2_raw),
        .mode        (mode),
        .manual_light(manual_light),
        .buzzer      (buzzer),
        .red         (red),
        .yellow      (yellow),
        .green       (green),
        .light       (light),
        .seg         (seg),
        .an          (an)
    );

    // =========================================================
    // Clock: 100 MHz  →  10 ns period
    // =========================================================
    always #5 clk = ~clk;

    // =========================================================
    // Helper Parameters
    // =========================================================
    // Debounce window ≈ 500 000 cycles @ 100 MHz = 5 ms
    // We wait 30 ms per sensor edge to be safely past debounce
    parameter DEBOUNCE_WAIT = 30_000_000; // 30 ms in ns

    // =========================================================
    // Monitor – prints whenever any output changes
    // =========================================================
    initial begin
        $monitor("[%0t ns]  red=%b  yellow=%b  green=%b  buzzer=%b  light=%b  seg=%b  an=%b",
                 $time, red, yellow, green, buzzer, light, seg, an);
    end

    // =========================================================
    // Task: perform one ENTRY  (S1 first, then S2)
    // =========================================================
    task do_entry;
        begin
            s1_raw = 0; #(DEBOUNCE_WAIT);   // outer sensor triggered
            s2_raw = 0; #(DEBOUNCE_WAIT);   // inner sensor triggered
            s1_raw = 1; #(DEBOUNCE_WAIT);   // outer sensor released
            s2_raw = 1; #(DEBOUNCE_WAIT);   // inner sensor released
        end
    endtask

    // =========================================================
    // Task: perform one EXIT  (S2 first, then S1)
    // =========================================================
    task do_exit;
        begin
            s2_raw = 0; #(DEBOUNCE_WAIT);   // inner sensor triggered
            s1_raw = 0; #(DEBOUNCE_WAIT);   // outer sensor triggered
            s2_raw = 1; #(DEBOUNCE_WAIT);   // inner sensor released
            s1_raw = 1; #(DEBOUNCE_WAIT);   // outer sensor released
        end
    endtask

    // =========================================================
    // Main Stimulus
    // =========================================================
    integer i;

    initial begin
        // ----- Initialise -----------------------------------------
        clk          = 0;
        rst          = 1;
        s1_raw       = 1;   // active-low, idle = 1
        s2_raw       = 1;
        mode         = 0;   // auto light mode
        manual_light = 0;

        // ----- Reset pulse ----------------------------------------
        #200;
        rst = 0;
        #100;

        // ============================================================
        // SCENARIO 1 – Single ENTRY
        //   Expected: count = 1,  green LED on,  no buzzer
        // ============================================================
        $display("\n--- SCENARIO 1: Single Entry ---");
        do_entry;
        #50;
        $display("  >> count should be 1 | green=%b (expect 1)  red=%b (expect 0)  buzzer=%b (expect 0)", green, red, buzzer);

        // ============================================================
        // SCENARIO 2 – Single EXIT
        //   Expected: count = 0,  green LED on (or off per design),  no buzzer
        // ============================================================
        $display("\n--- SCENARIO 2: Single Exit ---");
        do_exit;
        #50;
        $display("  >> count should be 0 | green=%b  red=%b  buzzer=%b", green, red, buzzer);

        // ============================================================
        // SCENARIO 3 – Underflow guard  (exit when count = 0)
        //   Counter must stay at 0, no wrap-around
        // ============================================================
        $display("\n--- SCENARIO 3: Exit at count=0 (underflow guard) ---");
        do_exit;
        #50;
        $display("  >> count should still be 0 | green=%b  red=%b", green, red);

        // ============================================================
        // SCENARIO 4 – Multiple entries up to WARNING threshold (≥ 18)
        //   Expected after 18 entries: yellow LED on
        // ============================================================
        $display("\n--- SCENARIO 4: Fill to WARNING level (18 people) ---");
        for (i = 0; i < 18; i = i + 1) begin
            do_entry;
        end
        #50;
        $display("  >> count should be 18 | yellow=%b (expect 1)  red=%b (expect 0)  buzzer=%b (expect 0)", yellow, red, buzzer);

        // ============================================================
        // SCENARIO 5 – Two more entries to reach FULL (≥ 20)
        //   Expected: red LED on,  buzzer active
        // ============================================================
        $display("\n--- SCENARIO 5: Fill to FULL capacity (20 people) ---");
        do_entry;   // count = 19
        do_entry;   // count = 20  → FULL
        #50;
        $display("  >> count should be 20 | red=%b (expect 1)  buzzer=%b (expect 1)  yellow=%b (expect 0)", red, buzzer, yellow);

        // ============================================================
        // SCENARIO 6 – One exit from FULL  (count drops to 19 → WARNING)
        //   Expected: yellow LED on,  buzzer off
        // ============================================================
        $display("\n--- SCENARIO 6: One exit from FULL ---");
        do_exit;
        #50;
        $display("  >> count should be 19 | yellow=%b (expect 1)  red=%b (expect 0)  buzzer=%b (expect 0)", yellow, red, buzzer);

        // ============================================================
        // SCENARIO 7 – Invalid / Timeout  (S1 triggered, but S2 never fires)
        //   FSM should self-reset after timeout; count must not change
        // ============================================================
        $display("\n--- SCENARIO 7: Invalid sequence - FSM timeout ---");
        s1_raw = 0;
        #600_000_000;   // 600 ms > typical FSM timeout window
        s1_raw = 1;
        #(DEBOUNCE_WAIT);
        $display("  >> count should be unchanged (19) | red=%b  yellow=%b  buzzer=%b", red, yellow, buzzer);

        // ============================================================
        // SCENARIO 8 – Manual light override
        //   mode = 1  (manual),  manual_light = 1  → light should be ON
        // ============================================================
        $display("\n--- SCENARIO 8: Manual light override ---");
        mode         = 1;
        manual_light = 1;
        #(DEBOUNCE_WAIT);
        $display("  >> light=%b (expect 1 in manual mode)", light);

        manual_light = 0;
        #(DEBOUNCE_WAIT);
        $display("  >> light=%b (expect 0 in manual mode, manual_light=0)", light);

        mode = 0;   // back to auto
        #(DEBOUNCE_WAIT);

        // ============================================================
        // SCENARIO 9 – Reset during operation
        //   Expected: count back to 0, all outputs cleared
        // ============================================================
        $display("\n--- SCENARIO 9: Mid-operation reset ---");
        rst = 1;
        #200;
        rst = 0;
        #100;
        $display("  >> after reset | red=%b (expect 0)  yellow=%b (expect 0)  buzzer=%b (expect 0)", red, yellow, buzzer);

        // ============================================================
        // SCENARIO 10 – Re-entry after reset
        //   Verify system works normally from count = 0 again
        // ============================================================
        $display("\n--- SCENARIO 10: Normal entry after reset ---");
        do_entry;
        #50;
        $display("  >> count should be 1 | green=%b (expect 1)", green);

        // ----- Done --------------------------------------------------
        $display("\n========== Simulation Complete ==========");
        #100;
        $stop;
    end

endmodule

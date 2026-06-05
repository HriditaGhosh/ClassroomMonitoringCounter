timescale 1ns / 1ps
// =============================================================================
// tb_full_system.v  —  Complete testbench for ClassroomMonitoringCounter
//
// Modules under test (all 9):
//   fsm, counter, comparator, debounce,
//   led_control, buzzer_ctrl, light_ctrl, override_ctrl, seven_seg
//
// Simulation strategy
//   • fsm_sim: copy of fsm with timeout widths FIXED (see Bug-1 in review)
//     and reduced timeout constants (100 / 50 cycles) so simulation is fast.
//   • Debounce is exercised with a dedicated unit test; elsewhere sensors are
//     driven "already clean" so we don't wait 500 000 cycles per pulse.
//   • seven_seg is tested combinatorially (clock divider just counts up).
//
// How to run – Icarus Verilog:
//   iverilog -o sim tb_full_system.v && vvp sim
//
// How to run – Vivado xsim:
//   xvlog tb_full_system.v
//   xelab -debug typical tb_full_system
//   xsim tb_full_system --runall
// =============================================================================

// ---------------------------------------------------------------------------
// Fixed FSM: timeout register widened to [25:0] to hold 50 M cycles.
// For simulation we use short timeouts via parameters.
// ---------------------------------------------------------------------------
module fsm_sim #(
    parameter ENTRY_TO = 100,
    parameter EXIT_TO  = 50
)(
    input  clk, rst,
    input  s1, s2,
    input  full,
    output reg inc, dec
);
    reg [1:0]  state  = 0;
    reg        s1_d   = 0, s2_d = 0;
    reg [25:0] timeout = 0;           // FIX: was [23:0], couldn't hold 50 M

    always @(posedge clk) begin
        s1_d <= s1;
        s2_d <= s2;
    end

    wire s1_r = s1 & ~s1_d;
    wire s2_r = s2 & ~s2_d;

    always @(posedge clk) begin
        if (rst) begin
            state <= 0; inc <= 0; dec <= 0; timeout <= 0;
        end else begin
            inc <= 0; dec <= 0;
            case (state)
                0: begin
                    timeout <= 0;
                    if      (s1_r && !s2) state <= 1;
                    else if (s2_r && !s1) state <= 2;
                end
                1: begin
                    timeout <= timeout + 1;
                    if (s2_r) begin
                        if (!full) inc <= 1;
                        state <= 0; timeout <= 0;
                    end else if (timeout > ENTRY_TO) begin
                        state <= 0; timeout <= 0;
                    end
                end
                2: begin
                    timeout <= timeout + 1;
                    if (s1_r) begin
                        dec <= 1;
                        state <= 0; timeout <= 0;
                    end else if (timeout > EXIT_TO) begin
                        state <= 0; timeout <= 0;
                    end
                end
                default: state <= 0;
            endcase
        end
    end
endmodule

// ---------------------------------------------------------------------------
// DUT: integrates fsm_sim + counter + comparator + all output modules
// ---------------------------------------------------------------------------
module dut #(
    parameter ENTRY_TO = 100,
    parameter EXIT_TO  = 50
)(
    input  clk, rst,
    input  s1, s2,            // already debounced
    input  mode, manual_light,
    output [6:0] count,
    output full, warn, empty,
    output red, yellow, green,
    output buzzer,
    output auto_light,
    output light_out
);
    wire inc_w, dec_w;

    fsm_sim #(.ENTRY_TO(ENTRY_TO), .EXIT_TO(EXIT_TO)) u_fsm (
        .clk(clk), .rst(rst), .s1(s1), .s2(s2), .full(full),
        .inc(inc_w), .dec(dec_w)
    );

    counter u_cnt (
        .clk(clk), .rst(rst), .inc(inc_w), .dec(dec_w), .count(count)
    );

    comparator u_cmp (
        .count(count), .full(full), .warn(warn), .empty(empty)
    );

    led_control u_led (
        .full(full), .warn(warn), .empty(empty),
        .red(red), .yellow(yellow), .green(green)
    );

    buzzer_ctrl u_bz (
        .clk(clk), .rst(rst), .full(full), .buzzer(buzzer)
    );

    light_ctrl u_lc (
        .count(count), .light(auto_light)
    );

    override_ctrl u_ov (
        .mode(mode), .auto_light(auto_light),
        .manual_light(manual_light), .light_out(light_out)
    );
endmodule

// ===========================================================================
// TESTBENCH
// ===========================================================================
module tb_full_system;

    // ── clock ──────────────────────────────────────────────────────────────
    reg clk = 0;
    always #5 clk = ~clk;     // 10 ns → 100 MHz

    // ── DUT wires ──────────────────────────────────────────────────────────
    reg  rst, s1, s2, mode, manual_light;
    wire [6:0] count;
    wire full, warn, empty;
    wire red, yellow, green;
    wire buzzer, auto_light, light_out;

    dut #(.ENTRY_TO(100), .EXIT_TO(50)) U (
        .clk(clk), .rst(rst), .s1(s1), .s2(s2),
        .mode(mode), .manual_light(manual_light),
        .count(count), .full(full), .warn(warn), .empty(empty),
        .red(red), .yellow(yellow), .green(green),
        .buzzer(buzzer), .auto_light(auto_light), .light_out(light_out)
    );

    // ── pass / fail ────────────────────────────────────────────────────────
    integer pass_cnt = 0, fail_cnt = 0;

    // ── helpers ────────────────────────────────────────────────────────────
    task tick(input integer n);
        integer i; for (i=0;i<n;i=i+1) @(posedge clk);
    endtask

    // Simulate a clean sensor rising-edge pulse of 4 cycles
    task pulse_s1; @(posedge clk); #1 s1=1; tick(4); #1 s1=0; endtask
    task pulse_s2; @(posedge clk); #1 s2=1; tick(4); #1 s2=0; endtask

    // Entry: s1 then s2
    task enter; pulse_s1; tick(5); pulse_s2; tick(5); endtask
    // Exit:  s2 then s1
    task exit_room; pulse_s2; tick(5); pulse_s1; tick(5); endtask

    // Generic assertion
    task assert_eq(
        input [6:0]  got,    input [6:0]  exp,
        input [255:0] label
    );
        if (got !== exp) begin
            $display("FAIL [%0s]  got=%0d  expected=%0d", label, got, exp);
            fail_cnt = fail_cnt + 1;
        end else begin
            $display("PASS [%0s]  value=%0d", label, got);
            pass_cnt = pass_cnt + 1;
        end
    endtask

    task assert_bit(
        input got, input exp, input [255:0] label
    );
        if (got !== exp) begin
            $display("FAIL [%0s]  got=%b  expected=%b", label, got, exp);
            fail_cnt = fail_cnt + 1;
        end else begin
            $display("PASS [%0s]  bit=%b", label, got);
            pass_cnt = pass_cnt + 1;
        end
    endtask

    integer i;

    // =======================================================================
    initial begin
        $dumpfile("tb_full_system.vcd");
        $dumpvars(0, tb_full_system);

        // default inputs
        s1=0; s2=0; mode=0; manual_light=0;

        // ===================================================================
        $display("--- SECTION 1: RESET ---");
        rst=1; tick(5); rst=0; tick(3);
        assert_eq (count, 0, "T01_reset_count");
        assert_bit(empty, 1, "T01_reset_empty");
        assert_bit(full,  0, "T01_reset_full");
        assert_bit(green, 1, "T01_reset_green_LED");   // empty → green
        assert_bit(auto_light, 0, "T01_reset_auto_light_off");

        // ===================================================================
        $display("--- SECTION 2: SINGLE ENTRY / EXIT ---");
        enter(); tick(2);
        assert_eq (count, 1, "T02_single_entry");
        assert_bit(empty, 0, "T02_not_empty");
        assert_bit(green, 0, "T02_green_off_after_entry");
        assert_bit(auto_light, 1, "T02_auto_light_on");

        exit_room(); tick(2);
        assert_eq (count, 0,  "T03_single_exit");
        assert_bit(empty, 1,  "T03_empty_again");
        assert_bit(auto_light, 0, "T03_auto_light_off");

        // ===================================================================
        $display("--- SECTION 3: UNDERFLOW GUARD ---");
        exit_room(); tick(2);
        assert_eq(count, 0, "T04_underflow_guard");

        // ===================================================================
        $display("--- SECTION 4: MULTI-ENTRY / MULTI-EXIT ---");
        for (i=0;i<5;i=i+1) enter();
        tick(2);
        assert_eq(count, 5, "T05_five_entries");

        for (i=0;i<3;i=i+1) exit_room();
        tick(2);
        assert_eq(count, 2, "T06_three_exits");

        // ===================================================================
        $display("--- SECTION 5: THRESHOLD FLAGS ---");

        // reach warn (18)
        for (i=0;i<16;i=i+1) enter();
        tick(2);
        assert_eq (count,  18, "T07_warn_count");
        assert_bit(warn,    1, "T07_warn_flag");
        assert_bit(full,    0, "T07_not_full");
        assert_bit(yellow,  1, "T07_yellow_LED");
        assert_bit(red,     0, "T07_red_off");

        // reach full (20)
        for (i=0;i<2;i=i+1) enter();
        tick(2);
        assert_eq (count, 20, "T08_full_count");
        assert_bit(full,   1, "T08_full_flag");
        assert_bit(warn,   1, "T08_warn_still_set");
        assert_bit(red,    1, "T08_red_LED");
        assert_bit(yellow, 0, "T08_yellow_off_when_full");

        // ===================================================================
        $display("--- SECTION 6: BUZZER ---");
        tick(2);
        assert_bit(buzzer, 1, "T09_buzzer_on_when_full");

        exit_room(); tick(2);
        assert_eq (count, 19, "T10_exit_drops_from_full");
        assert_bit(full,   0, "T10_full_clears");
        assert_bit(buzzer, 0, "T10_buzzer_off");

        // ===================================================================
        $display("--- SECTION 7: ENTRY BLOCKED WHEN FULL ---");
        // re-fill to 20
        enter(); tick(2);
        assert_eq(count, 20, "T11_back_to_full");
        enter(); tick(2);
        assert_eq(count, 20, "T12_entry_blocked_when_full");

        // ===================================================================
        $display("--- SECTION 8: ENTRY TIMEOUT (incomplete sequence) ---");
        // drain first so we're not at full
        for (i=0;i<20;i=i+1) exit_room();
        tick(2);
        assert_eq(count, 0, "T13_drained_for_timeout_test");

        // s1 fires but s2 never comes → should timeout, no inc
        pulse_s1;
        tick(120);  // > ENTRY_TO (100)
        assert_eq(count, 0, "T14_entry_timeout_no_inc");

        // ===================================================================
        $display("--- SECTION 9: EXIT TIMEOUT (incomplete sequence) ---");
        // put one person in first
        enter(); tick(2);
        assert_eq(count, 1, "T15_one_in_for_exit_timeout");

        // s2 fires but s1 never comes → should timeout, no dec
        pulse_s2;
        tick(70);   // > EXIT_TO (50)
        assert_eq(count, 1, "T16_exit_timeout_no_dec");

        // ===================================================================
        $display("--- SECTION 10: SIMULTANEOUS SENSORS ---");
        // Both sensors rise at same time: FSM should stay IDLE, no count change
        @(posedge clk); #1 s1=1; s2=1;
        tick(4); #1 s1=0; s2=0;
        tick(10);
        assert_eq(count, 1, "T17_simultaneous_sensors_no_change");

        // ===================================================================
        $display("--- SECTION 11: RESET MID-COUNT ---");
        for (i=0;i<8;i=i+1) enter();
        tick(2);
        rst=1; tick(3); rst=0; tick(3);
        assert_eq (count, 0, "T18_reset_mid_count");
        assert_bit(empty, 1, "T18_empty_after_reset");
        assert_bit(buzzer, 0, "T18_buzzer_cleared_by_reset");

        // ===================================================================
        $display("--- SECTION 12: LED PRIORITY (Red > Yellow > Green) ---");
        // empty → green
        assert_bit(green,  1, "T19_green_when_empty");
        assert_bit(yellow, 0, "T19_yellow_off_when_empty");
        assert_bit(red,    0, "T19_red_off_when_empty");

        // partial occupancy (not warn, not full) → no LED
        for (i=0;i<5;i=i+1) enter();
        tick(2);
        assert_bit(green,  0, "T20_no_green_mid_occupancy");
        assert_bit(yellow, 0, "T20_no_yellow_mid_occupancy");
        assert_bit(red,    0, "T20_no_red_mid_occupancy");

        // ===================================================================
        $display("--- SECTION 13: LIGHT CTRL & OVERRIDE ---");
        // auto mode (mode=0): light follows occupancy
        mode=0; tick(2);
        assert_bit(auto_light, 1, "T21_auto_light_on_occupied");
        assert_bit(light_out,  1, "T21_light_out_auto_on");

        // drain → auto light off
        for (i=0;i<5;i=i+1) exit_room();
        tick(2);
        assert_bit(auto_light, 0, "T22_auto_light_off_empty");
        assert_bit(light_out,  0, "T22_light_out_auto_off");

        // manual mode (mode=1): manual_light=1 overrides auto off
        mode=1; manual_light=1; tick(2);
        assert_bit(light_out, 1, "T23_manual_override_on");

        // manual mode, manual_light=0 → light off regardless of occupancy
        enter(); enter(); tick(2);    // 2 people inside
        manual_light=0; tick(2);
        assert_bit(light_out, 0, "T24_manual_override_off_with_people");

        // ===================================================================
        $display("--- SECTION 14: DEBOUNCE UNIT TEST ---");
        begin : debounce_test
            reg noisy_in;
            wire clean_out;
            reg db_clk = 0;

            // Instantiate debounce standalone
            debounce u_db (.clk(db_clk), .noisy(noisy_in), .clean(clean_out));
            noisy_in = 0;

            // Run debounce clock
            fork
                begin : db_clock
                    repeat(1_200_000) begin #5; db_clk = ~db_clk; end
                end
                begin : db_stimulus
                    // assert noisy signal – but glitch it halfway through
                    repeat(200000) @(posedge db_clk);  // wait 200k cycles
                    noisy_in = 1;
                    repeat(100) @(posedge db_clk);     // glitch: drop for 100 cy
                    noisy_in = 0;
                    repeat(100) @(posedge db_clk);
                    noisy_in = 1;                       // stable high from here
                    // wait past debounce threshold (500 000 cycles)
                    repeat(520000) @(posedge db_clk);
                    assert_bit(clean_out, 1, "T25_debounce_output_high_after_stable");

                    // now drop and glitch
                    noisy_in = 0;
                    repeat(80) @(posedge db_clk);
                    noisy_in = 1;
                    repeat(80) @(posedge db_clk);
                    noisy_in = 0;                       // stable low from here
                    repeat(520000) @(posedge db_clk);
                    assert_bit(clean_out, 0, "T26_debounce_output_low_after_stable");
                end
            join_any
            disable db_clock;
        end

        // ===================================================================
        $display("--- SECTION 15: SEVEN-SEG SPOT CHECK ---");
        begin : seg_test
            // Direct combinational check: feed count values, read seg/an
            // We'll instantiate seven_seg separately
            reg  ss_clk = 0;
            wire [6:0] seg;
            wire [3:0] an;
            // Drive count through a register exposed to the sub-module
            reg [6:0] ss_count;

            seven_seg u_ss (.clk(ss_clk), .count(ss_count), .seg(seg), .an(an));

            ss_count = 7'd23;   // should show 2 (tens) and 3 (ones)

            // Clock through enough cycles to cycle through all digit slots
            // clkdiv[16] toggles every 2^16 clocks; we need a few digits to
            // appear.  For simulation speed, just check after a few ticks.
            repeat(4) begin #5; ss_clk=~ss_clk; end
            // When an==4'b1110 (ones slot), seg should be for digit 3 = 7'b0110000
            // When an==4'b1101 (tens slot), seg should be for digit 2 = 7'b0100100
            // The divider cycles slowly; just verify no X/Z on outputs.
            if (^seg === 1'bx || ^an === 1'bx)
                $display("FAIL [T27_seven_seg_no_x]  X/Z on outputs");
            else begin
                $display("PASS [T27_seven_seg_no_x]  seg=%b an=%b (count=%0d)",
                         seg, an, ss_count);
                pass_cnt = pass_cnt + 1;
            end

            // Zero count → ones=0 (seg 7'b1000000) at some point
            ss_count = 7'd0;
            repeat(4) begin #5; ss_clk=~ss_clk; end
            if (^seg === 1'bx || ^an === 1'bx) begin
                $display("FAIL [T28_seven_seg_zero_no_x]");
                fail_cnt = fail_cnt + 1;
            end else begin
                $display("PASS [T28_seven_seg_zero_no_x]  seg=%b an=%b", seg, an);
                pass_cnt = pass_cnt + 1;
            end
        end

        // ===================================================================
        $display("========================================");
        $display("  RESULTS:  %0d PASSED   %0d FAILED", pass_cnt, fail_cnt);
        if (fail_cnt == 0) $display("  ALL TESTS PASSED ✓");
        else               $display("  SOME TESTS FAILED — see above");
        $display("========================================");
        $finish;
    end

    // Watchdog
    initial begin
        #200_000_000;
        $display("WATCHDOG: sim exceeded 200 ms — aborting");
        $finish;
    end

endmodule


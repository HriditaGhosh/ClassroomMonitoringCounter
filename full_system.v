
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/22/2026 07:59:23 AM
// Design Name: 
// Module Name: full_system
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module full_system(
    input clk, rst,
    input s1_raw, s2_raw,
    input mode, manual_light,
    output [6:0] seg,
    output [3:0] an,
    output red, yellow, green,
    output buzzer, light
);

wire s1, s2;
wire inc_raw, dec_raw;
wire [6:0] count;
wire full, warn, empty;
wire auto_light;

// invert BEFORE debounce (LM393 Active Low)
wire s1_ah = ~s1_raw;
wire s2_ah = ~s2_raw;

// debounce
debounce d1(clk, s1_ah, s1);
debounce d2(clk, s2_ah, s2);

// FSM
fsm f(clk, rst, s1, s2, full, inc_raw, dec_raw);

// counter
counter c(clk, rst, inc_raw, dec_raw, count);

// comparator
comparator cmp(count, full, warn, empty);

// outputs
led_control led(full, warn, empty, red, yellow, green);
seven_seg ss(clk, count, seg, an);
buzzer_ctrl bz(clk, rst, full, buzzer);
light_ctrl lc(count, auto_light);
override_ctrl ov(mode, auto_light, manual_light, light);

endmodule


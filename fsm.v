`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2026 08:36:07 PM
// Design Name: 
// Module Name: fsm
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


module fsm(
    input clk, rst,
    input s1, s2,
    input full,
    output reg inc, dec
);

reg [1:0] state = 0;
reg s1_d = 0, s2_d = 0;
reg [23:0] timeout = 0;

always @(posedge clk) begin
    s1_d <= s1;
    s2_d <= s2;
end

wire s1_r = s1 & ~s1_d;
wire s2_r = s2 & ~s2_d;

always @(posedge clk) begin
    if(rst) begin
        state   <= 0;
        inc     <= 0;
        dec     <= 0;
        timeout <= 0;
    end else begin
        inc <= 0;
        dec <= 0;

        case(state)
            0: begin
                timeout <= 0;
                if(s1_r && !s2) state <= 1;
                else if(s2_r && !s1) state <= 2;
            end

            1: begin
                timeout <= timeout + 1;
                if(s2_r) begin
                    if(!full) inc <= 1;
                    state <= 0; timeout <= 0;
                end
                else if(timeout > 26'd50000000) begin
                    state <= 0; timeout <= 0;
                end
            end

            2: begin
                timeout <= timeout + 1;
                if(s1_r) begin
                    dec <= 1;
                    state <= 0; timeout <= 0;
                end
                else if(timeout > 24'd5000000) begin
                    state <= 0; timeout <= 0;
                end
            end

            default: state <= 0;
        endcase
    end
end

endmodule


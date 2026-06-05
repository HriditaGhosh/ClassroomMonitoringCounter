`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2026 08:33:22 PM
// Design Name: 
// Module Name: seven_seg
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


module seven_seg(
    input clk,
    input [6:0] count,
    output reg [6:0] seg,
    output reg [3:0] an
);

reg [16:0] clkdiv=0;
reg [1:0] digit=0;
reg [3:0] num;

always @(posedge clk) begin
    clkdiv <= clkdiv + 1;
    digit <= clkdiv[16:15];
end

wire [3:0] tens = count / 10;
wire [3:0] ones = count % 10;

always @(*) begin
    case(digit)
        0: begin an=4'b1110; num=ones; end
        1: begin an=4'b1101; num=tens; end
        default: begin an=4'b1111; num=0; end
    endcase
end

always @(*) begin
    case(num)
        0: seg=7'b1000000;
        1: seg=7'b1111001;
        2: seg=7'b0100100;
        3: seg=7'b0110000;
        4: seg=7'b0011001;
        5: seg=7'b0010010;
        6: seg=7'b0000010;
        7: seg=7'b1111000;
        8: seg=7'b0000000;
        9: seg=7'b0010000;
        default: seg=7'b1111111;
    endcase
end

endmodule



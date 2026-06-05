`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2026 08:36:22 PM
// Design Name: 
// Module Name: debounce
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

module debounce(input clk, input noisy, output reg clean=0);

reg [19:0] cnt=0;
reg s1=0, s2=0;

always @(posedge clk) begin
    s1 <= noisy;
    s2 <= s1;

    if(s2 == clean)
        cnt <= 0;
    else begin
        cnt <= cnt + 1;
        if(cnt == 20'd500000) begin   // reduced delay (stable)
            clean <= s2;
            cnt <= 0;
        end
    end
end

endmodule



`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2026 08:37:19 PM
// Design Name: 
// Module Name: buzzer_ctrl
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


module buzzer_ctrl(
    input clk,
    input rst,
    input full,
    output reg buzzer
);

always @(posedge clk) begin
    if(rst)
        buzzer <= 0;
    else
        buzzer <= full;
end

endmodule
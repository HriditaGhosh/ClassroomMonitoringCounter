`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2026 08:35:49 PM
// Design Name: 
// Module Name: led_control
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
/////////////////////////////////////////////////////////////////////////////////
module led_control(
    input full, warn, empty,
    output reg red, yellow, green
);

always @(*) begin
    red = 0; yellow = 0; green = 0;

    if(full)
        red = 1;
    else if(warn)
        yellow = 1;
    else if(empty)
        green = 1;
end

endmodule


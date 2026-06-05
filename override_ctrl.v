`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2026 08:33:53 PM
// Design Name: 
// Module Name: override_ctrl
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


module override_ctrl(
    input mode,
    input auto_light,
    input manual_light,
    output light_out
);

assign light_out = (mode) ? manual_light : auto_light;

endmodule


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2026 08:36:43 PM
// Design Name: 
// Module Name: counter
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

module counter(
    input clk, rst,
    input inc, dec,
    output reg [6:0] count = 0
);

always @(posedge clk) begin
    if(rst)
        count <= 0;
    else if(inc && count < 99)
        count <= count + 1;
    else if(dec && count > 0)
        count <= count - 1;
end

endmodule


`timescale 1ns / 1ps

module PE #(
    parameter N = 8
)(
    input clk,
    input rst,
    input clr_acc,

    input  [N-1:0] a_in,
    input  [N-1:0] b_in,

    output reg [N-1:0] a_out,
    output reg [N-1:0] b_out,
    output reg [2*N:0] acc
);

always @(posedge clk) begin
    if (rst) begin
        a_out <= 0;
        b_out <= 0;
        acc   <= 0;
    end
    else begin
        a_out <= a_in;
        b_out <= b_in;

        if (clr_acc)
            acc <= a_in * b_in;
        else
            acc <= acc + (a_in * b_in);
    end
end

endmodule
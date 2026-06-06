`timescale 1ns / 1ps

module axis_rx#
(   parameter WIDTH = 64
)(  input clk,
    input rst,
    input [WIDTH-1:0] s_axis_tdata,
    input s_axis_tvalid,
    output s_axis_tready,
    output reg [WIDTH-1:0] data_out,
    output reg valid_out
);

assign s_axis_tready = 1'b1;

always @(posedge clk)
begin
    if(rst)
    begin
        data_out  <= 0;
        valid_out <= 0;
    end
    else
    begin
        valid_out <= 0;

        if(s_axis_tvalid)
        begin
            data_out  <= s_axis_tdata;
            valid_out <= 1;
        end
    end
end
endmodule
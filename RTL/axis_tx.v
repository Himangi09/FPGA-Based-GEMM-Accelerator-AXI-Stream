`timescale 1ns / 1ps

module axis_tx#
(   parameter WIDTH = 272
)(  input clk,
    input rst,
    input [WIDTH-1:0] data_in,
    input valid_in,
    output reg [WIDTH-1:0] m_axis_tdata,
    output reg m_axis_tvalid,
    input m_axis_tready
);

always @(posedge clk)
begin
    if(rst)
    begin
        m_axis_tvalid <= 0;
        m_axis_tdata  <= 0;
    end
    else
    begin
        if(valid_in)
        begin
            m_axis_tdata  <= data_in;
            m_axis_tvalid <= 1;
        end
        else if(m_axis_tvalid && m_axis_tready)
        begin
            m_axis_tvalid <= 0;
        end
    end
end
endmodule
`timescale 1ns / 1ps

module systolic_array_NxN #(
    parameter N = 8,
    parameter Size = 4
)(
    input clk,
    input rst,
    input start,

    input  [N-1:0] a_in[Size-1:0],
    input  [N-1:0] b_in[Size-1:0],

    output [2*N:0] result[Size-1:0][Size-1:0],
    output done
);

wire [N-1:0] a_bus[Size-1:0][Size:0];
wire [N-1:0] b_bus[Size:0][Size-1:0];
wire [2*N:0] acc[Size-1:0][Size-1:0];

reg [$clog2(3*Size+1)-1:0] c_count;
reg active;
reg done_reg;
reg clr_acc_reg;

assign done = done_reg;

always @(posedge clk) begin
    if (rst) begin
        c_count     <= 0;
        active      <= 0;
        done_reg    <= 0;
        clr_acc_reg <= 0;
    end
    else if (start) begin
        c_count     <= 0;
        active      <= 1;
        done_reg    <= 0;
        clr_acc_reg <= 1;
    end
    else if (active) begin
        clr_acc_reg <= 0;

        if (c_count < (3*Size-1))
            c_count <= c_count + 1;
        else begin
            active   <= 0;
            done_reg <= 1;
            c_count  <= 0;
        end
    end
    else begin
        done_reg <= 0;
    end
end

//-----------------------------------------------------
// Input skewing registers
//-----------------------------------------------------

reg [N-1:0] a_delay[Size-1:0][Size-1:0];
reg [N-1:0] b_delay[Size-1:0][Size-1:0];

integer i,j;

always @(posedge clk) begin
    if (rst) begin
        for(i=0;i<Size;i=i+1)
            for(j=0;j<Size;j=j+1)
                a_delay[i][j] <= 0;
    end
    else begin
        for(i=0;i<Size;i=i+1) begin
            a_delay[i][0] <= start ? a_in[i] : 0;

            for(j=1;j<Size;j=j+1)
                a_delay[i][j] <= a_delay[i][j-1];
        end
    end
end

integer g,h;

always @(posedge clk) begin
    if (rst) begin
        for(g=0;g<Size;g=g+1)
            for(h=0;h<Size;h=h+1)
                b_delay[g][h] <= 0;
    end
    else begin
        for(g=0;g<Size;g=g+1) begin
            b_delay[g][0] <= start ? b_in[g] : 0;

            for(h=1;h<Size;h=h+1)
                b_delay[g][h] <= b_delay[g][h-1];
        end
    end
end

//-----------------------------------------------------
// Connect skewed inputs
//-----------------------------------------------------

genvar x,y;

generate
    for(y=0;y<Size;y=y+1) begin
        assign a_bus[y][0] = a_delay[y][y];
    end
endgenerate

generate
    for(x=0;x<Size;x=x+1) begin
        assign b_bus[0][x] = b_delay[x][x];
    end
endgenerate

//-----------------------------------------------------
// PE Array
//-----------------------------------------------------

genvar r,c;

generate
    for(r=0;r<Size;r=r+1) begin : ROW

        for(c=0;c<Size;c=c+1) begin : COL

            PE #(
                .N(N)
            ) pe_inst (
                .clk(clk),
                .rst(rst),
                .clr_acc(clr_acc_reg),

                .a_in(a_bus[r][c]),
                .b_in(b_bus[r][c]),

                .a_out(a_bus[r][c+1]),
                .b_out(b_bus[r+1][c]),

                .acc(acc[r][c])
            );

            assign result[r][c] = acc[r][c];

        end
    end
endgenerate

endmodule
`timescale 1ns / 1ps

module systolic_array_axi_top_tb();

    parameter N    = 8;
    parameter Size = 4;

    reg clk;
    reg rst;

    reg  [2*N*Size-1:0] s_axis_tdata;
    reg                 s_axis_tvalid;
    wire                s_axis_tready;

    wire [(2*N+1)*Size*Size-1:0] m_axis_tdata;
    wire                         m_axis_tvalid;
    reg                          m_axis_tready;

    systolic_array_axi_top #(
        .N(N),
        .Size(Size)
    ) uut (
        .clk(clk),
        .rst(rst),

        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),

        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready)
    );

    //------------------------------------------
    // Clock
    //------------------------------------------
    always #5 clk = ~clk;

    //------------------------------------------
    // Matrices
    //------------------------------------------
    reg [N-1:0] A[Size-1:0][Size-1:0];
    reg [N-1:0] B[Size-1:0][Size-1:0];

    reg [(2*N+1)*Size*Size-1:0] expected_result;

    integer i,j,t;
    integer errors;

    reg [31:0] sum;
    reg [31:0] dut_val;
    reg [31:0] exp_val;

    //------------------------------------------
    // Golden Model
    //------------------------------------------
    task compute_golden;
    begin
        expected_result = 0;

        for(i=0;i<Size;i=i+1) begin
            for(j=0;j<Size;j=j+1) begin

                sum = A[i][0] * B[0][j];

                expected_result[((i*Size+j)*(2*N+1)) +: (2*N+1)]
                    = sum;
            end
        end
    end
    endtask

    //------------------------------------------
    // Send AXI Input
    //------------------------------------------
    task send_axi_input;
    begin

        @(posedge clk);

        s_axis_tvalid <= 1'b1;

        for(i=0;i<Size;i=i+1) begin

            s_axis_tdata[i*N +: N]
                <= A[i][0];

            s_axis_tdata[(Size+i)*N +: N]
                <= B[0][i];
        end

        @(posedge clk);

        s_axis_tvalid <= 1'b0;
        s_axis_tdata  <= 0;

    end
    endtask

    //------------------------------------------
    // Main Test
    //------------------------------------------
    initial begin

        clk = 0;
        rst = 1;

        s_axis_tdata  = 0;
        s_axis_tvalid = 0;

        m_axis_tready = 1;

        #20;
        rst = 0;

        for(t=0;t<5;t=t+1) begin

            $display("\n===== TEST %0d =====",t);

            errors = 0;

            //----------------------------------
            // Random Matrices
            //----------------------------------
            for(i=0;i<Size;i=i+1) begin
                for(j=0;j<Size;j=j+1) begin

                    A[i][j] = $urandom_range(1,5);
                    B[i][j] = $urandom_range(1,5);

                end
            end

            //----------------------------------
            // Golden
            //----------------------------------
            compute_golden();

            //----------------------------------
            // Send Data
            //----------------------------------
            send_axi_input();

            //----------------------------------
            // Wait For Output
            //----------------------------------
            @(posedge m_axis_tvalid);

            $display("OUTPUT RECEIVED");

            //----------------------------------
            // Compare
            //----------------------------------
            for(i=0;i<Size;i=i+1) begin
                for(j=0;j<Size;j=j+1) begin

                    dut_val =
                    m_axis_tdata[((i*Size+j)*(2*N+1))
                    +: (2*N+1)];

                    exp_val =
                    expected_result[((i*Size+j)*(2*N+1))
                    +: (2*N+1)];

                    if(dut_val !== exp_val) begin

                        $display(
                        "MISMATCH [%0d][%0d] DUT=%0d EXP=%0d",
                        i,j,dut_val,exp_val);

                        errors = errors + 1;
                    end
                end
            end

            if(errors==0)
                $display("TEST PASSED");
            else
                $display("TEST FAILED : %0d ERRORS",errors);

        end

        $display("\n===== SIMULATION DONE =====");
        $finish;

    end

endmodule
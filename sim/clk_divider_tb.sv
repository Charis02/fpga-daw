`default_nettype none
`timescale 1ns / 1ps

module clock_divider_tb();
    logic mclk;
    logic clk10;
    logic clk25;
    logic clk50;

    clock_divider #(
        .IN_TO_OUT(10)
    )
    clk10gen
    (
        .clk_in(mclk),
        .clk_out(clk10)
    );

    clock_divider #(
        .IN_TO_OUT(4)
    )
    clk25gen
    (
        .clk_in(mclk),
        .clk_out(clk25)
    );

    clock_divider #(
        .IN_TO_OUT(2)
    )
    clk50gen
    (
        .clk_in(mclk),
        .clk_out(clk50)
    );

    always begin
        mclk = !mclk;
        #10;
    end

    initial begin
        $dumpfile("clk_divider.vcd");
        $dumpvars(0, clock_divider_tb);
        $display("Starting Simulation.");
        mclk = 0;

        #2000;

        $display("Simulation over.");

        $finish;
    end

endmodule

`default_nettype wire
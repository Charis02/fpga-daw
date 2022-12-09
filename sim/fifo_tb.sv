`default_nettype none
`timescale 1ns / 1ps

module fifo_tb#(
    parameter WIDTH = 16,
    parameter DEPTH = 64
)
();
    logic clk;
    logic rst;

    logic rd;
    logic [WIDTH-1:0] dout;
    logic wr;
    logic [WIDTH-1:0] din;

    fifo#(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    )
    uut ( // unit under test
        .clk(clk),
        .rst(rst),

        .rd(rd), 
        .dout(dout),

        .wr(wr),   
        .din(din)  
    );

    always begin
        clk = !clk;
        #10;
    end

    initial begin
        $dumpfile("fifo.vcd");
        $dumpvars(0, fifo_tb);
        $display("Starting Simulation.");
        clk = 1;
        rst = 0;
        rd <= 0;
        wr <= 0;
        din <= 0;

        #20;

        // Test 1
        $display("Test 1: -1-2-3-4-...-20");

        for (int i = 1;i <= 20;i++) begin
            wr <= 1;
            din <= i;

            #80;

            wr <= 0;

            #40;
        end

        for (int i = 0;i < 20;i++) begin
            rd <= 1;
            #20;
            rd <= 0;
            #80;
        end

        $display("Test 2: Overflow and roll over");

        for (int i = 21;i <= 68;i++) begin
            wr <= 1;
            din <= i;

            #20;

            wr <= 0;

            #20;
        end

        for (int i = 21;i < 69;i++) begin
            rd <= 1;
            #20;
            rd <= 0;
            #80;
        end

        $display("Finished simulation.");

        $finish;
    end

endmodule

`default_nettype wire
`default_nettype none
`timescale 1ns / 1ps

module i2s_transmitter_tb#(parameter WIDTH = 16)();
    logic mclk;
    logic rst;

    logic sclk;
    logic ws;

    logic sd_tx;
    logic [WIDTH-1:0] tx_data_l;
    logic [WIDTH-1:0] tx_data_r;

    i2s_transmitter uut(
        .mclk(mclk),
        .rst(rst),

        .tx_data_l(tx_data_l),
        .tx_data_r(tx_data_r),

        .sd_tx(sd_tx),

        .sclk(sclk),
        .ws(ws)
    );

    logic [2*WIDTH-1:0] transmit_message;

    always begin
        mclk = !mclk;
        #10;
    end

    initial begin
        $dumpfile("i2s_transmitter.vcd");
        $dumpvars(0, i2s_transmitter_tb);
        $display("Starting Simulation.");
        mclk = 0;
        rst = 0;
        tx_data_l = 0;
        tx_data_r = 0;
        #20;

        // Test  1

        $display("Test 1: Two 16-bit messages");

        rst=1;
        tx_data_r = 16'h1111;
        tx_data_l = 16'hffff;
        #20;
        rst = 0;
        #20;

        for(int i = 0;i < 32;i++) begin
            #(24*20);
        end

        for(int i = 0;i < 32;i++) begin
            #(24*20);
        end

        for(int i = 0;i < 32;i++) begin
            #(24*20);
        end

        #(24*20);
        #(24*20);
        #(24*20);

        $finish;
    end

endmodule

`default_nettype wire
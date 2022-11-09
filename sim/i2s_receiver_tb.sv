`default_nettype none
`timescale 1ns / 1ps

module i2s_receiver_tb#(parameter WIDTH = 16)();
    logic mclk;
    logic rst;

    logic sclk;
    logic ws;

    logic sd_rx;
    logic [WIDTH-1:0] rx_data_l;
    logic [WIDTH-1:0] rx_data_r;

    i2s_receiver uut(
        .mclk(mclk),
        .rst(rst),

        .sd_rx(sd_rx),

        .rx_data_l(rx_data_l),
        .rx_data_r(rx_data_r),

        .sclk(sclk),
        .ws(ws)
    );

    logic [2*WIDTH-1:0] receive_message;

    always begin
        mclk = !mclk;
        #10;
    end

    initial begin
        $dumpfile("i2s_receiver.vcd");
        $dumpvars(0, i2s_receiver_tb);
        $display("Starting Simulation.");
        mclk = 0;
        rst = 0;
        sd_rx = 0;

        #(4*20);

        // Test  1

        $display("Test 1: Two 16-bit messages");


        receive_message = 16'hffff;

        for(int i = WIDTH-1;i >= 0;i--) begin
            sd_rx = receive_message[i];

            #(8*20);
        end

        for(int i = WIDTH;i < 32;i++) begin
            sd_rx = 0;

            #(8*20);
        end
        receive_message = 16'h8111;

        for(int i = WIDTH-1;i >= 0;i--) begin
            sd_rx = receive_message[i];

            #(8*20);
        end

        for(int i = WIDTH;i < 32;i++) begin
            sd_rx = 0;

            #(8*20);
        end

        #(8*20);
        #(8*20);
        #(8*20);

        $finish;
    end

endmodule

`default_nettype wire
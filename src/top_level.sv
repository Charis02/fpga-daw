`default_nettype none
`timescale 1ns / 1ps

module top_level(
    input wire clk, //clock @ 11.29 mhz
    input wire btnc, //btnc (used for reset)

    output logic [1:0] i2s_mclk,    // main clocks of i2s module
    output logic [1:0] i2s_lrclk,   // left right clocks of i2s module
    output logic [1:0] i2s_sclk,    // serial clocks of i2s module
    input wire i2s_sdin,    // input of i2s (receive)
    output logic i2s_sdout  // output of i2s (transmit)
);
    logic sys_rst = btnc;
    logic clk_22;

    clk_wiz_22 clk_wiz( // this generates a clock of 22.579 MHz
        .clk_in1(clk),
        .clk_out1(clk_22)
    );

    assign i2s_mclk[0] = clk_22;    // main clock for i2s transmit
    assign i2s_mclk[1] = clk_22;    // main clock for i2s receive

    logic [15:0] i2s_data_l; // data received which will also be passed to the transmitter (left channel)
    logic [15:0] i2s_data_r; // data received which will also be passed to the transmitter (right channel)

    i2s_receiver receiver(
        .mclk(i2s_mclk[1]),
        .rst(sys_rst),
        .sd_rx(i2s_sdin),
        .rx_data_l(i2s_data_l), // our output (the received values)
        .rx_data_r(i2s_data_r), // our output (the received values)
        .sclk(i2s_sclk[1]),
        .ws(i2s_lrclk[1])
    );

    i2s_transmitter transmitter(
        .mclk(i2s_mclk[0]),
        .rst(sys_rst),
        .tx_data_l(i2s_data_r), // these contain whatever was received 
        .tx_data_r(i2s_data_l), // these contain whatever was received 
        .sd_tx(i2s_sdout),
        .sclk(i2s_sclk[0]),
        .ws(i2s_lrclk[0])
    );

endmodule

`default_nettype wire
`default_nettype none
`timescale 1ns / 1ps

module top_level#(
    parameter WORD_WIDTH = 8
)
(
    input wire clk, //clock @ 100 MHz
    input wire btnc, //btnc (used for reset)

    output logic [1:0] i2s_mclk,    // main clocks of i2s module
    output logic [1:0] i2s_lrclk,   // left right clocks of i2s module
    output logic [1:0] i2s_sclk,    // serial clocks of i2s module
    input wire i2s_sdin,    // input of i2s (receive)
    output logic i2s_sdout,  // output of i2s (transmit)

    input wire [0:0] sd_dat_in,
    output logic [2:0] sd_dat_out,
    output logic sd_reset, 
    output logic sd_sck, 
    output logic sd_cmd,
    input wire sd_cd,

    input wire [15:0] sw,
);
    logic sys_rst = btnc;

    // i2s section

    logic clk_22;

    clk_wiz_22 clk_wiz( // this generates a clock of 22.579 MHz
        .clk_in1(clk),
        .clk_out1(clk_22)
    );

    logic clk_100 = clk_wiz.clk_in1_clk_wiz_0; // i hope this isn't illegal

    assign i2s_mclk[0] = clk_22;    // main clock for i2s transmit
    assign i2s_mclk[1] = clk_22;    // main clock for i2s receive

    logic [WORD_WIDTH-1:0] i2s_data_l; // data received which will also be passed to the transmitter (left channel)
    logic [WORD_WIDTH-1:0] i2s_data_r; // data received which will also be passed to the transmitter (right channel)

    i2s_receiver#(
        .WIDTH(WORD_WIDTH)
    ) receiver(
        .mclk(i2s_mclk[1]),
        .rst(sys_rst),
        .sd_rx(i2s_sdin),
        .rx_data_l(i2s_data_l), // our output (the received values)
        .rx_data_r(i2s_data_r), // our output (the received values)
        .sclk(i2s_sclk[1]),
        .ws(i2s_lrclk[1])
    );

    logic [WORD_WIDTH-1:0] i2s_data_l_transmit;
    
    logic [WORD_WIDTH-1:0] i2s_data_l_transmit_final = (sw[15]) ? i2s_data_l_transmit : 0;

    i2s_transmitter#(
        .WIDTH(WORD_WIDTH)
    ) transmitter(
        .mclk(i2s_mclk[0]),
        .rst(sys_rst),
        .tx_data_l((sw[1]) ? i2s_data_l : i2s_data_l_transmit_final), // these contain whatever was received 
        .tx_data_r(i2s_data_r), // these contain whatever was received 
        .sd_tx(i2s_sdout),
        .sclk(i2s_sclk[0]),
        .ws(i2s_lrclk[0])
    );

    track_store_load#(
        .WORD_WIDTH(WORD_WIDTH)
    ) store_load(
        .clk(clk_100),
        .rst(sys_rst),
        .store_req(sw[0]),
        .load_req(sw[15]),
        
        .din(i2s_data_l),
        .wr(~i2s_lrclk[1]),

        .dout(i2s_data_l_transmit),
        .rd(i2s_lrclk[0]),

        .sd_dat_in(sd_dat_in),
        .sd_dat_out(sd_dat_out),
        .sd_reset(sd_reset),
        .sd_sck(sd_sck),
        .sd_cmd(sd_cmd)
    );

endmodule

`default_nettype wire
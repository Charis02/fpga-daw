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

    input wire [15:0] sw
);
    logic sys_rst = btnc;

    // i2s section

    logic clk_22;
    logic clk_100;

    clk_wiz_22 clk_wiz( // this generates a clock of 22.579 MHz
        .clk_in1(clk),
        .clk_out1(clk_22),
        .clk_out2(clk_100)
    );

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

    logic [WORD_WIDTH-1:0] i2s_data_transmit;

    i2s_transmitter#(
        .WIDTH(WORD_WIDTH)
    ) transmitter(
        .mclk(i2s_mclk[0]),
        .rst(sys_rst),
        .tx_data_l((sw[1]) ? i2s_data_l : i2s_data_transmit), // these contain whatever was received 
      //  .tx_data_r((sw[1]) ? i2s_data_l : i2s_data_transmit), // these contain whatever was received 
        .tx_data_r(i2s_data_r), // these contain whatever was received 
        .sd_tx(i2s_sdout),
        .sclk(i2s_sclk[0]),
        .ws(i2s_lrclk[0])
    );

    logic [WORD_WIDTH-1:0] store_load_din;
    logic store_load_wr;
    logic [WORD_WIDTH-1:0] store_load_dout;
    logic store_load_rd;

    track_store_load#(
        .WORD_WIDTH(WORD_WIDTH)
    ) store_load(
        .clk(clk_100),
        .rst(sys_rst),
        .store_req(sw[0]),
        .load_req(sw[15]),
        
        .din(store_load_din),
        .wr(store_load_wr),

        .dout(store_load_dout),
        .rd(store_load_rd),

        .sd_dat_in(sd_dat_in),
        .sd_dat_out(sd_dat_out),
        .sd_reset(sd_reset),
        .sd_sck(sd_sck),
        .sd_cmd(sd_cmd)
    );
    
    
//    ila_0 my_ila(
//        .clk(clk_100),
//        .probe0(store_load_rd),
//        .probe1(i2s_lrclk[1]),
//        .probe2(clock_cross_bram_100_to_22_out),
//        .probe3(clock_cross_bram_22_to_100_out)
//    );
    
    logic [15:0] clock_cross_bram_100_to_22_out;
    logic [15:0] clock_cross_bram_22_to_100_out;
    logic [7:0] i2s_new_data;
    logic i2s_lrclk_prev;
    logic i2s_clock_change;

    blk_mem_gen_0 
    clock_cross_bram_22_to_100
    (
        .clka(clk_22),        // Clock in
        .addra(0),  // use port A for writes
        .ena(1'b1),    // Always on (?)
        .dina({0,i2s_lrclk[1],i2s_data_l}),
        .wea(1'b1),

        .clkb(clk_100), // clock out
        .addrb(0), // use port B for reads
        .enb(1'b1), // always on (?)
        .doutb(clock_cross_bram_22_to_100_out)
    );
    
    blk_mem_gen_0 
    clock_cross_bram_100_to_22
    (
        .clka(clk_100),        // Clock in
        .addra(0),  // use port A for writes
        .ena(1'b1),    // Always on (?)
        .dina({0,store_load_dout}),
        .wea(1'b1),

        .clkb(clk_22), // clock out
        .addrb(0), // use port B for reads
        .enb(1'b1), // always on (?)
        .doutb(clock_cross_bram_100_to_22_out)
    );
    
    assign store_load_din = clock_cross_bram_22_to_100_out[7:0];
    assign store_load_wr = clock_cross_bram_22_to_100_out[8];
    assign store_load_rd = clock_cross_bram_22_to_100_out[8];
    assign i2s_data_transmit = clock_cross_bram_100_to_22_out[7:0];

endmodule

`default_nettype wire
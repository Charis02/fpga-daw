`default_nettype none
`timescale 1ns / 1ps

module top_level(
    input wire clk, //clock @ 11.29 mhz
    input wire btnc, //btnc (used for reset)
    input wire [15:0] sw,

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

    logic [15:0] i2s_data_out_delay_l; 
    logic [15:0] i2s_data_out_delay_r;

    logic [15:0] i2s_data_out_distortion_l; 
    logic [15:0] i2s_data_out_distortion_r;

    logic [15:0] i2s_data_out_l; 
    logic [15:0] i2s_data_out_r;

    i2s_receiver receiver(
        .mclk(i2s_mclk[1]),
        .rst(sys_rst),
        .sd_rx(i2s_sdin),
        .rx_data_l(i2s_data_l), // our output (the received values)
        .rx_data_r(i2s_data_r), // our output (the received values)
        .sclk(i2s_sclk[1]),
        .ws(i2s_lrclk[1])
    );

    delay delay_module(
        .clk_in(clk_22),
        .rst_in(sys_rst),
        .delay_enable(sw[0]),
        .echo_enable(sw[1]),
        .data_dry_l(i2s_data_l),
        .data_dry_r(i2s_data_r),
        .data_wet_l(i2s_data_out_delay_l),
        .data_wet_r(i2s_data_out_delay_r)
    );

    distortion distortion_module(
        .clk_in(clk_22),
        .rst_in(sys_rst),
        .distorion_enable(sw[2]),
        .bit_amount(16'd3),
        .data_dry_l(i2s_data_out_delay_l),
        .data_dry_r(i2s_data_out_delay_r),
        .data_wet_l(i2s_data_out_distortion_l),
        .data_wet_r(i2s_data_out_distortion_r)
    );

    limiter limiter_module(
        .clk_in(clk_22),
        .rst_in(sys_rst),
        .limiter_enable(sw[3]),
        .limiter_type(1'b0),
        .limit(1 << 10),
        .data_dry_l(i2s_data_out_distortion_l),
        .data_dry_r(i2s_data_out_distortion_r),
        .data_wet_l(i2s_data_out_l),
        .data_wet_r(i2s_data_out_r)
    );

    i2s_transmitter transmitter(
        .mclk(i2s_mclk[0]),
        .rst(sys_rst),
        .tx_data_l(i2s_data_out_l), // these contain whatever was received 
        .tx_data_r(i2s_data_out_r), // these contain whatever was received 
        .sd_tx(i2s_sdout),
        .sclk(i2s_sclk[0]),
        .ws(i2s_lrclk[0])
    );
/*

    logic up, down, right, left;
    debouncer db2(
        .rst_in(btnc),
        .clk_in(clk),
        .dirty_in(btnu),
        .clean_out(up));

    debouncer db3(
        .rst_in(btnc),
        .clk_in(clk),
        .dirty_in(btnd),
        .clean_out(down));

    debouncer db0(
        .rst_in(btnc),
        .clk_in(clk),
        .dirty_in(btnl),
        .clean_out(left));

    debouncer db1(
        .rst_in(btnc),
        .clk_in(clk),
        .dirty_in(btnr),
        .clean_out(right));
*/

    /* Video Pipeline */
    /*
    logic clk_65mhz;

    clk_wiz_lab3 clk_gen(
        .clk_in1(clk_100mhz),
        .clk_out1(clk_65mhz));

    
    

    logic [10:0] hcount;    // pixel on current line
    logic [9:0] vcount;     // line number
    logic hsync, vsync, blank; //control signals for vga

    vga vga_gen(
        .pixel_clk_in(clk_65mhz),
        .hcount_out(hcount),
        .vcount_out(vcount),
        .hsync_out(hsync),
        .vsync_out(vsync),
        .blank_out(blank));

    logic [4:0] gui_page = 0;
    logic [6:0] gui_cursor_main_menu = 0;
    logic [11:0] pixel_color;
    logic [16:0] delay_enable = 0;
    logic [16:0] distortion_enable = 0;
    logic [16:0] chorus_enable = 0;
    logic [16:0] mute;
    logic solo_enable = 0;
    logic [4:0] solo = 0;    

    graphical_user_interface gui(
        .pixel_clk_in(clk_65mhz),
        .rst_in(btnc),
        .up_in(up),
        .down_in(down),
        .left_in(left),
        .right_in(right),
        .gui_page(gui_page),
        .gui_cursor_main_menu(gui_cursor_main_menu),
        .delay_enable(delay_enable),
        .chorus_enable(chorus_enable),
        .distortion_enable(distortion_enable),
        .solo_enable(solo_enable),
        .mute(mute),
        .solo(solo),
        .hcount_in(hcount),
        .vcount_in(vcount),
        .pixel_out(pixel_color));

    logic [11:0] color;

    vga_mux vgam(
        .sel_in(sw[1:0]),
        .hcount_in(hcount),
        .vcount_in(vcount),
        .pixel_color_in(pixel_color),
        .color_out(color)
    );

    assign vga_r = ~blank ? color[11:8]: 0;
    assign vga_g = ~blank ? color[7:4] : 0;
    assign vga_b = ~blank ? color[3:0] : 0;

    assign vga_hs = ~hsync;
    assign vga_vs = ~vsync;

    */

endmodule

`default_nettype wire
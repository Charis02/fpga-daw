`default_nettype none
`timescale 1ns / 1ps

module top_level#(
    parameter WORD_WIDTH = 8,
    parameter CHANNELS = 4
)
(
    input wire clk, //clock @ 100 MHz
    input wire btnc, btnl, btnr, btnu, btnd, //btnc (used for reset)

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
    output logic [3:0] vga_r, vga_g, vga_b,
    output logic vga_hs, vga_vs,
    input wire sd_cd,

    input wire [15:0] sw
);
    logic sys_rst = btnc;

    // i2s section

    logic clk_22;
    logic clk_65mhz;
    logic clk_100;

    clk_wiz0 clk_wiz( // this generates a clock of 22.579 MHz
        .clk_in1(clk),
        .clk_out1(clk_22),
        .clk_out2(clk_100),
        .clk_out3(clk_65mhz)
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

    logic [15:0] i2s_data_transmit;
    logic [15:0] out_l;
    logic [15:0] out_r;

    assign out_l = i2s_data_l <<< 7;
    assign out_r = i2s_data_r <<< 7;

    i2s_transmitter#(
        .WIDTH(16)
    ) transmitter(
        .mclk(i2s_mclk[0]),
        .rst(sys_rst),
        .tx_data_l((sw[2]) ? out_l : i2s_data_transmit), // these contain whatever was received 
        .tx_data_r((sw[2]) ? out_r : i2s_data_transmit), // these contain whatever was received
        .sd_tx(i2s_sdout),
        .sclk(i2s_sclk[0]),
        .ws(i2s_lrclk[0])
    );

    logic [WORD_WIDTH-1:0] store_load_din;
    logic store_load_wr, record;
    logic [4:0] record_channel;
    logic [WORD_WIDTH-1:0] store_load_dout;
    logic [$clog2(CHANNELS):0][WORD_WIDTH-1:0] store_load_mdout;
    logic store_load_rd;
    logic store_load_mrd;

    track_store_load#(
        .WORD_WIDTH(WORD_WIDTH),
        .CHANNELS(CHANNELS)
    ) store_load(
        .clk(clk_65mhz),
        .rst(sys_rst),
        .store_req(record),
        .load_req(sw[15]),
        .mix_req(sw[1]),

        .initial_addr(record_channel<<25),
        
        .din(store_load_din),
        .wr(store_load_wr),

        .dout(store_load_dout),
        .rd(store_load_rd),

        .mdout(store_load_mdout),
        .mrd(store_load_mrd),

        .sd_dat_in(sd_dat_in),
        .sd_dat_out(sd_dat_out),
        .sd_reset(sd_reset),
        .sd_sck(sd_sck),
        .sd_cmd(sd_cmd)
    );


    


    logic up, down, right, left;
    logic up_clean, down_clean, right_clean, left_clean, enter_clean;
    debouncer db2(
        .rst_in(sys_rst),
        .clk_in(clk_65mhz),
        .dirty_in(btnu),
        .clean_out(up));

    edge_detector ed2(
        .rst_in(sys_rst),
        .clk_in(clk_65mhz),
        .dirty_in(up),
        .clean_out(up_clean)
    );

    debouncer db3(
        .rst_in(sys_rst),
        .clk_in(clk_65mhz),
        .dirty_in(btnd),
        .clean_out(down));

    edge_detector ed3(
        .rst_in(sys_rst),
        .clk_in(clk_65mhz),
        .dirty_in(down),
        .clean_out(down_clean)
    );

    debouncer db0(
        .rst_in(sys_rst),
        .clk_in(clk_65mhz),
        .dirty_in(btnl),
        .clean_out(left));

    edge_detector ed0(
        .rst_in(sys_rst),
        .clk_in(clk_65mhz),
        .dirty_in(left),
        .clean_out(left_clean)
    );

    debouncer db1(
        .rst_in(sys_rst),
        .clk_in(clk_65mhz),
        .dirty_in(btnr),
        .clean_out(right));

    edge_detector ed1(
        .rst_in(sys_rst),
        .clk_in(clk_65mhz),
        .dirty_in(right),
        .clean_out(right_clean)
    );


    enter_btn entr_btn(
        .rst_in(sys_rst),
        .clk_in(clk_65mhz),
        .dirty_in(sw[4]),
        .clean_out(enter_clean)
    );

    /* Video Pipeline */   

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

    logic [5:0] gui_cursor;
    logic [11:0] color;
    logic [4:0] effect_enable;
    logic [4:0] delay_enable;
    logic [4:0] echo_enable;
    logic [4:0] chorus_enable;
    logic [4:0] distortion_enable;
    logic [4:0] limiter_enable;
    logic solo_enable;
    logic [4:0] solo;    
    logic [4:0] mute;
    logic [4:0][3:0] volume;

    
    graphical_user_interface guii(
        .pixel_clk_in(clk_65mhz),
        .rst_in(sys_rst),
        .enter_in(enter_clean),
        .up_in(up_clean),
        .down_in(down_clean),
        .left_in(left_clean),
        .right_in(right_clean),
        .record(record),
        .record_channel(record_channel),
        .gui_cursor(gui_cursor),
        .effect_enable(effect_enable),
        .delay_enable(delay_enable),
        .echo_enable(echo_enable),
        .chorus_enable(chorus_enable),
        .distortion_enable(distortion_enable),
        .limiter_enable(limiter_enable),
        .solo_enable(solo_enable),
        .solo(solo),
        .mute(mute),
        .volume(volume),
        .hcount_in(hcount),
        .vcount_in(vcount),
        .pixel_out(color));

        


    assign vga_r = ~blank ? color[11:8]: 0;
    assign vga_g = ~blank ? color[7:4] : 0;
    assign vga_b = ~blank ? color[3:0] : 0;

    assign vga_hs = ~hsync;
    assign vga_vs = ~vsync;
    logic [$clog2(CHANNELS):0][WORD_WIDTH-1:0] effects_in;
    logic signed [$clog2(CHANNELS):0][WORD_WIDTH-1:0] delay_dout;
    logic signed [$clog2(CHANNELS):0][WORD_WIDTH-1:0] echo_dout;
    logic signed [$clog2(CHANNELS):0][WORD_WIDTH-1:0] effects_dout;
    logic [15:0] mixer_dout;

    generate
        genvar i;
        for(i=0; i<CHANNELS; i=i+1)begin
            delay#(
                .WIDTH(WORD_WIDTH)
            ) delay(
                .clk_in(clk_65mhz),
                .rst_in(sys_rst),
                .delay_enable(delay_enable[i]),
                .echo_enable(0),
                .data_dry(store_load_mdout[i]),
                .data_wet(delay_dout[i])
            );
        end
    endgenerate

    generate
        genvar j;
        for(j=0; j<CHANNELS; j=j+1)begin
            delay#(
                .WIDTH(WORD_WIDTH)
            ) echo(
                .clk_in(clk_65mhz),
                .rst_in(sys_rst),
                .delay_enable(0),
                .echo_enable(echo_enable[j]),
                .data_dry(delay_dout[j]),
                .data_wet(echo_dout[j])
            );
        end
    endgenerate

    generate
        genvar k;
        for(k=0; k<CHANNELS; k=k+1)begin
            distortion#(
                .WIDTH(WORD_WIDTH)
            ) distortion(
                .clk_in(clk_65mhz),
                .rst_in(sys_rst),
                .distortion_enable(distortion_enable[k]),
                .data_dry(echo_dout[k]),
                .data_wet(effects_dout[k])
            );
        end
    endgenerate
    /*
    effects#(
        .WIDTH(WORD_WIDTH),
        .CHANNELS(CHANNELS)
    ) effect(
        .clk_in(clk_65mhz),
        .rst_in(sys_rst),
        .effect_enable(effect_enable),
        .delay_enable(delay_enable),
        .echo_enable(echo_enable),
        .distortion_enable(distortion_enable),
        .limiter_enable(limiter_enable),
        .data_dry(store_load_mdout),
        .data_wet(effects_dout)
    );
    */

    
    mixer#(
        .WIDTH(WORD_WIDTH),
        .CHANNELS(CHANNELS)
    ) mix(
        .clk_in(clk_65mhz),
        .rst_in(sys_rst),

        .data_dry(effects_dout),
        //.volume(volume),
        .mute(mute),
        .solo_enable(solo_enable),
        .solo(solo),

        .data_wet(mixer_dout)
    );
    

    logic [15:0] clock_cross_bram_65_to_22_out;
    logic [15:0] clock_cross_bram_22_to_100_out;
    logic [15:0] clock_cross_bram_100_to_65_out1;
    logic [15:0] clock_cross_bram_100_to_65_out2;
    logic i2s_lrclk_prev;
    logic i2s_clock_change;
    logic [7:0] i2s_data_to_store;

    always_ff @(posedge clk_22) begin
        i2s_lrclk_prev <= i2s_lrclk[1];
        i2s_clock_change <= (i2s_lrclk[1] != i2s_lrclk_prev) ? 1 : 0;
        i2s_data_to_store <= (i2s_lrclk[1] == 1) ? i2s_data_l : i2s_data_r;
    end

    blk_mem_gen_0 
    clock_cross_bram_100_to_65_1
    (
        .clka(clk_100),        // Clock in
        .addra(0),  // use port A for writes
        .ena(1'b1),    // Always on (?)
        .dina({store_load_mdout[1], store_load_mdout[0]}),
        .wea(1'b1),

        .clkb(clk_65mhz), // clock out
        .addrb(0), // use port B for reads
        .enb(1'b1), // always on (?)
        .doutb(clock_cross_bram_100_to_65_out1)
    );

    blk_mem_gen_0 
    clock_cross_bram_100_to_65_2
    (
        .clka(clk_100),        // Clock in
        .addra(0),  // use port A for writes
        .ena(1'b1),    // Always on (?)
        .dina({store_load_mdout[3], store_load_mdout[2]}),
        .wea(1'b1),

        .clkb(clk_65mhz), // clock out
        .addrb(0), // use port B for reads
        .enb(1'b1), // always on (?)
        .doutb(clock_cross_bram_100_to_65_out2)
    );

    blk_mem_gen_0 
    clock_cross_bram_22_to_100
    (
        .clka(clk_22),        // Clock in
        .addra(0),  // use port A for writes
        .ena(1'b1),    // Always on (?)
        .dina({0,i2s_clock_change,i2s_data_to_store}),
        .wea(1'b1),

        .clkb(clk_100), // clock out
        .addrb(0), // use port B for reads
        .enb(1'b1), // always on (?)
        .doutb(clock_cross_bram_22_to_100_out)
    );
    
    blk_mem_gen_0 
    clock_cross_bram_65_to_22
    (
        .clka(clk_65mhz),        // Clock in
        .addra(0),  // use port A for writes
        .ena(1'b1),    // Always on (?)
        .dina(mixer_dout),
        .wea(1'b1),

        .clkb(clk_22), // clock out
        .addrb(0), // use port B for reads
        .enb(1'b1), // always on (?)
        .doutb(clock_cross_bram_65_to_22_out)
    );
    
    assign effects_in[0] = clock_cross_bram_100_to_65_out1[7:0];
    assign effects_in[1] = clock_cross_bram_100_to_65_out1[15:8];
    assign effects_in[2] = clock_cross_bram_100_to_65_out2[7:0];
    assign effects_in[3] = clock_cross_bram_100_to_65_out2[15:8];
    assign store_load_din = clock_cross_bram_22_to_100_out[7:0];
    assign store_load_wr = clock_cross_bram_22_to_100_out[8];
    assign store_load_rd = clock_cross_bram_22_to_100_out[8];
    assign store_load_mrd = clock_cross_bram_22_to_100_out[8];
    assign i2s_data_transmit = clock_cross_bram_65_to_22_out[15:0];
endmodule

`default_nettype wire
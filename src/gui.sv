`timescale 1ns / 1ps
`default_nettype none

module graphical_user_interface (
    input wire pixel_clk_in,
    input wire rst_in,
    input wire enter_in,
    input wire up_in,
    input wire down_in,
    input wire left_in,
    input wire right_in,
    output logic record,
    output logic [4:0] record_channel,
    output logic [5:0] gui_cursor,
    output logic [4:0] effect_enable,
    output logic [4:0] delay_enable,
    output logic [4:0] echo_enable,
    output logic [4:0] chorus_enable,
    output logic [4:0] distortion_enable,
    output logic [4:0] limiter_enable,
    output logic solo_enable,
    output logic [4:0] solo,
    output logic [4:0] mute,
    output logic [4:0][3:0] volume,

    input wire [10:0] hcount_in,
    input wire [9:0]  vcount_in,

    output logic [11:0] pixel_out
);
    parameter background = 12'h888;
    parameter REC1 = 6'd0;
    parameter VOL1 = 6'd1;
    parameter SOL1 = 6'd2;
    parameter MUT1 = 6'd3;
    parameter EFF1 = 6'd4;
    parameter DEL1 = 6'd5;
    parameter ECH1 = 6'd6;
    parameter CHO1 = 6'd7;
    parameter DIS1 = 6'd8;
    parameter LIM1 = 6'd9;
    parameter REC2 = 6'd10;
    parameter VOL2 = 6'd11;
    parameter SOL2 = 6'd12;
    parameter MUT2 = 6'd13;
    parameter EFF2 = 6'd14;
    parameter DEL2 = 6'd15;
    parameter ECH2 = 6'd16;
    parameter CHO2 = 6'd17;
    parameter DIS2 = 6'd18;
    parameter LIM2 = 6'd19;
    parameter REC3 = 6'd20;
    parameter VOL3 = 6'd21;
    parameter SOL3 = 6'd22;
    parameter MUT3 = 6'd23;
    parameter EFF3 = 6'd24;
    parameter DEL3 = 6'd25;
    parameter ECH3 = 6'd26;
    parameter CHO3 = 6'd27;
    parameter DIS3 = 6'd28;
    parameter LIM3 = 6'd29;
    parameter REC4 = 6'd30;
    parameter VOL4 = 6'd31;
    parameter SOL4 = 6'd32;
    parameter MUT4 = 6'd33;
    parameter EFF4 = 6'd34;
    parameter DEL4 = 6'd35;
    parameter ECH4 = 6'd36;
    parameter CHO4 = 6'd37;
    parameter DIS4 = 6'd38;
    parameter LIM4 = 6'd39;
    parameter RECM = 6'd40;
    parameter VOLM = 6'd41;
    parameter SOLM = 6'd42;
    parameter MUTM = 6'd43;
    parameter EFFM = 6'd44;
    parameter DELM = 6'd45;
    parameter ECHM = 6'd46;
    parameter CHOM = 6'd47;
    parameter DISM = 6'd48;
    parameter LIMM = 6'd49;
    logic in_box, in_selected_box_h, in_selected_box_v;
    logic [11:0] delay_out;
    logic [11:0] record_out;
    logic [11:0] volume_out;
    logic [11:0] solo_out;
    logic [11:0] mute_out;
    logic [11:0] effects_out;
    logic [11:0] echo_out;
    logic [11:0] chorus_out;
    logic [11:0] distortion_out;
    logic [11:0] limiter_out;
    logic [10:0] hcount_sprite_in;
    logic background_solo;
    logic background_mute;
    logic background_effects;
    logic background_delay;
    logic background_echo;
    logic background_chorus;
    logic background_distortion;
    logic background_limiter;

    

    record_sprite #(.WIDTH(150), .HEIGHT(60)) record_image(
        .pixel_clk_in(pixel_clk_in),
        .rst_in(rst_in),
        .x_in(hcount_sprite_in),
        .hcount_in(hcount_in),
        .y_in(84), 
        .vcount_in(vcount_in),
        .pixel_out(record_out)
    );

    volume_sprite #(.WIDTH(150), .HEIGHT(60)) volume_image(
        .pixel_clk_in(pixel_clk_in),
        .rst_in(rst_in),
        .x_in(hcount_sprite_in),
        .hcount_in(hcount_in),
        .y_in(84 + 60), 
        .vcount_in(vcount_in),
        .pixel_out(volume_out)
    );

    solo_sprite #(.WIDTH(150), .HEIGHT(60)) solo_image(
        .pixel_clk_in(pixel_clk_in),
        .rst_in(rst_in),
        .x_in(hcount_sprite_in),
        .hcount_in(hcount_in),
        .y_in(84 + 60 * 2), 
        .vcount_in(vcount_in),
        .bckrnd(background_solo),
        .pixel_out(solo_out)
    );

    mute_sprite #(.WIDTH(150), .HEIGHT(60)) mute_image(
        .pixel_clk_in(pixel_clk_in),
        .rst_in(rst_in),
        .x_in(hcount_sprite_in),
        .hcount_in(hcount_in),
        .y_in(84 + 60 * 3), 
        .vcount_in(vcount_in),
        .bckrnd(background_mute),
        .pixel_out(mute_out)
    );

    effects_sprite #(.WIDTH(150), .HEIGHT(60)) effects_image(
        .pixel_clk_in(pixel_clk_in),
        .rst_in(rst_in),
        .x_in(hcount_sprite_in),
        .hcount_in(hcount_in),
        .y_in(84 + 60 * 4), 
        .vcount_in(vcount_in),
        .bckrnd(background_effects),
        .pixel_out(effects_out)
    );

    delay_sprite #(.WIDTH(150), .HEIGHT(60)) delay_image(
        .pixel_clk_in(pixel_clk_in),
        .rst_in(rst_in),
        .x_in(hcount_sprite_in),
        .hcount_in(hcount_in),
        .y_in(84 + 60 * 5), 
        .vcount_in(vcount_in),
        .bckrnd(background_delay),
        .pixel_out(delay_out)
    );

    echo_sprite #(.WIDTH(150), .HEIGHT(60)) echo_image(
        .pixel_clk_in(pixel_clk_in),
        .rst_in(rst_in),
        .x_in(hcount_sprite_in),
        .hcount_in(hcount_in),
        .y_in(84 + 60 * 6), 
        .vcount_in(vcount_in),
        .bckrnd(background_echo),
        .pixel_out(echo_out)
    );

    chorus_sprite #(.WIDTH(150), .HEIGHT(60)) chorus_image(
        .pixel_clk_in(pixel_clk_in),
        .rst_in(rst_in),
        .x_in(hcount_sprite_in),
        .hcount_in(hcount_in),
        .y_in(84 + 60 * 7), 
        .vcount_in(vcount_in),
        .bckrnd(background_chorus),
        .pixel_out(chorus_out)
    );

    distortion_sprite #(.WIDTH(150), .HEIGHT(60)) distortion_image(
        .pixel_clk_in(pixel_clk_in),
        .rst_in(rst_in),
        .x_in(hcount_sprite_in),
        .hcount_in(hcount_in),
        .y_in(84 + 60 * 8), 
        .vcount_in(vcount_in),
        .bckrnd(background_distortion),
        .pixel_out(distortion_out)
    );

    limiter_sprite #(.WIDTH(150), .HEIGHT(60)) limiter_image(
        .pixel_clk_in(pixel_clk_in),
        .rst_in(rst_in),
        .x_in(hcount_sprite_in),
        .hcount_in(hcount_in),
        .y_in(84 + 60 * 9), 
        .vcount_in(vcount_in),
        .bckrnd(background_limiter),
        .pixel_out(limiter_out)
    );
    

    always_comb begin
        in_box = 0;
        in_selected_box_h = 0;
        in_selected_box_v = 0;
        if((hcount_in - 62 >= 150 * 0 && hcount_in - 62 <= 150 * 1) && (gui_cursor >= 0 && gui_cursor < 10)) in_selected_box_h = 1;
        if((hcount_in - 62 >= 150 * 1 && hcount_in - 62 <= 150 * 2) && (gui_cursor >= 10 && gui_cursor < 20)) in_selected_box_h = 1;
        if((hcount_in - 62 >= 150 * 2 && hcount_in - 62 <= 150 * 3) && (gui_cursor >= 20 && gui_cursor < 30)) in_selected_box_h = 1;
        if((hcount_in - 62 >= 150 * 3 && hcount_in - 62 <= 150 * 4) && (gui_cursor >= 30 && gui_cursor < 40)) in_selected_box_h = 1;
        if((hcount_in - 62 >= 150 * 5 && hcount_in - 62 <= 150 * 6) && (gui_cursor >= 40 && gui_cursor < 50)) in_selected_box_h = 1;
        for (integer i = 0; i < 7; i = i+1) begin
            if(hcount_in - 62 == i * 150) begin
                integer j = i;
                if(i > 4) j = 4;
                if(vcount_in >= 84 && vcount_in <= 684) in_box = 1;
                hcount_sprite_in = hcount_in;
                background_solo = solo_enable && solo == j;
                background_mute = mute[j];
                background_effects = effect_enable[j];
                background_delay = delay_enable[j];
                background_echo = echo_enable[j];
                background_chorus = chorus_enable[j];
                background_distortion = distortion_enable[j];
                background_limiter = limiter_enable[j];
            end
        end

        if((vcount_in - 84 >= 60 * 0 && vcount_in - 84 <= 60 * 1) && (gui_cursor % 10 == 0)) in_selected_box_v = 1;
        if((vcount_in - 84 >= 60 * 1 && vcount_in - 84 <= 60 * 2) && (gui_cursor % 10 == 1)) in_selected_box_v = 1;
        if((vcount_in - 84 >= 60 * 2 && vcount_in - 84 <= 60 * 3) && (gui_cursor % 10 == 2)) in_selected_box_v = 1;
        if((vcount_in - 84 >= 60 * 3 && vcount_in - 84 <= 60 * 4) && (gui_cursor % 10 == 3)) in_selected_box_v = 1;
        if((vcount_in - 84 >= 60 * 4 && vcount_in - 84 <= 60 * 5) && (gui_cursor % 10 == 4)) in_selected_box_v = 1;
        if((vcount_in - 84 >= 60 * 5 && vcount_in - 84 <= 60 * 6) && (gui_cursor % 10 == 5)) in_selected_box_v = 1;
        if((vcount_in - 84 >= 60 * 6 && vcount_in - 84 <= 60 * 7) && (gui_cursor % 10 == 6)) in_selected_box_v = 1;
        if((vcount_in - 84 >= 60 * 7 && vcount_in - 84 <= 60 * 8) && (gui_cursor % 10 == 7)) in_selected_box_v = 1;
        if((vcount_in - 84 >= 60 * 8 && vcount_in - 84 <= 60 * 9) && (gui_cursor % 10 == 8)) in_selected_box_v = 1;
        if((vcount_in - 84 >= 60 * 9 && vcount_in - 84 <= 60 * 10) && (gui_cursor % 10 == 9)) in_selected_box_v = 1;
        for (integer i = 0; i < 11; i = i+1) begin
            if(vcount_in - 84 == i * 60)begin
                if((hcount_in >= 62 && hcount_in <= 662) || (hcount_in >= 812 && hcount_in <= 962)) in_box = 1;
            end
        end
    end

    always_ff @( posedge pixel_clk_in ) begin
        if(rst_in) begin
            gui_cursor <= 0;
            effect_enable <= 0;
            delay_enable <= 0;
            echo_enable <= 0;
            chorus_enable <= 0;
            distortion_enable <= 0;
            limiter_enable <= 0;
            solo_enable <= 0;
            solo <= 0;
            mute <= 0;
            record <= 0;
            record_channel <= 0;
            // delay_out <= 12'hfff;
            // record_out <= 12'hfff;
            // volume_out <= 12'hfff;
            // solo_out <= 12'hfff;
            // limiter_out <= 12'hfff;
            // mute_out <= 12'hfff;
            // effects_out <= 12'hfff;
            // echo_out <= 12'hfff;
            // chorus_out <= 12'hfff;
            // distortion_out<= 12'hfff;
            for (integer i = 0; i < 5 ; i = i+1) begin
                volume[i] <= 0;
            end
        end else begin
            //MOVE CURSOR
            if(right_in && gui_cursor < RECM) gui_cursor <= gui_cursor + 6'd10;
            else if(right_in) gui_cursor <= gui_cursor - 6'd40;
            else if(left_in && gui_cursor >= REC2) gui_cursor <= gui_cursor - 6'd10;
            else if(left_in) gui_cursor <= gui_cursor + 6'd40;
            else if(up_in && gui_cursor > REC1) gui_cursor <= gui_cursor - 6'd1;
            else if(down_in && gui_cursor < LIMM) gui_cursor <= gui_cursor + 6'd1;
            //ENTER_PRESSED
            if(enter_in) begin
                //RECORD TBD
                if(gui_cursor == REC1 || gui_cursor == REC2 || gui_cursor == REC3 || gui_cursor == REC4) begin
                    if(record == 0) begin
                        record <= 1;
                        if(gui_cursor == REC1) record_channel <= 4'd0;
                        if(gui_cursor == REC2) record_channel <= 4'd1;
                        if(gui_cursor == REC3) record_channel <= 4'd2;
                        if(gui_cursor == REC4) record_channel <= 4'd3;
                    end else begin
                        record <= 0;
                        record_channel <= 0;
                    end
                end
                //VOLUME
                if(gui_cursor == VOL1) begin
                    if(volume[0] < 10) volume[0] <= volume[0] + 1;
                    else volume[0] <= 1;
                end
                if(gui_cursor == VOL2) begin
                    if(volume[1] < 10) volume[1] <= volume[1] + 1;
                    else volume[1] <= 1;
                end
                if(gui_cursor == VOL3) begin
                    if(volume[2] < 10) volume[2] <= volume[2] + 1;
                    else volume[2] <= 1;
                end
                if(gui_cursor == VOL4) begin
                    if(volume[3] < 10) volume[3] <= volume[3] + 1;
                    else volume[3] <= 1;
                end
                if(gui_cursor == VOLM) begin
                    if(volume[4] < 10) volume[4] <= volume[4] + 1;
                    else volume[4] <= 1;
                end
                //SOLO
                if(gui_cursor == SOL1) begin
                    if(solo_enable && solo == 0) solo_enable <= 0; //Unsolo this
                    else begin
                        solo_enable <= 1;
                        solo <= 0;
                    end
                end
                if(gui_cursor == SOL2) begin
                    if(solo_enable && solo == 1) solo_enable <= 0; //Unsolo this
                    else begin
                        solo_enable <= 1;
                        solo <= 1;
                    end
                end
                if(gui_cursor == SOL3) begin
                    if(solo_enable && solo == 2) solo_enable <= 0; //Unsolo this
                    else begin
                        solo_enable <= 1;
                        solo <= 2;
                    end
                end
                if(gui_cursor == SOL4) begin
                    if(solo_enable && solo == 3) solo_enable <= 0; //Unsolo this
                    else begin
                        solo_enable <= 1;
                        solo <= 3;
                    end
                end
                if(gui_cursor == SOLM) begin
                    if(solo_enable && solo == 4) solo_enable <= 0; //Unsolo this
                    else begin
                        solo_enable <= 1;
                        solo <= 4;
                    end
                end
                //MUTE
                if(gui_cursor == MUT1) mute[0] <= mute[0] == 1'b1 ? 0 : 1;
                if(gui_cursor == MUT2) mute[1] <= mute[1] == 1'b1 ? 0 : 1; 
                if(gui_cursor == MUT3) mute[2] <= mute[2] == 1'b1 ? 0 : 1;
                if(gui_cursor == MUT4) mute[3] <= mute[3] == 1'b1 ? 0 : 1;
                if(gui_cursor == MUTM) mute[4] <= mute[4] == 1'b1 ? 0 : 1;
                //EFFECTS
                if(gui_cursor == EFF1) effect_enable[0] <= effect_enable[0] == 1'b1 ? 0 : 1;
                if(gui_cursor == EFF2) effect_enable[1] <= effect_enable[1] == 1'b1 ? 0 : 1;
                if(gui_cursor == EFF3) effect_enable[2] <= effect_enable[2] == 1'b1 ? 0 : 1;
                if(gui_cursor == EFF4) effect_enable[3] <= effect_enable[3] == 1'b1 ? 0 : 1;
                if(gui_cursor == EFFM) effect_enable[4] <= effect_enable[4] == 1'b1 ? 0 : 1;
                //DELAY
                if(gui_cursor == DEL1) delay_enable[0] <= delay_enable[0] == 1'b1 ? 0 : 1;
                if(gui_cursor == DEL2) delay_enable[1] <= delay_enable[1] == 1'b1 ? 0 : 1;
                if(gui_cursor == DEL3) delay_enable[2] <= delay_enable[2] == 1'b1 ? 0 : 1;
                if(gui_cursor == DEL4) delay_enable[3] <= delay_enable[3] == 1'b1 ? 0 : 1;
                if(gui_cursor == DELM) delay_enable[4] <= delay_enable[4] == 1'b1 ? 0 : 1;
                //ECHO
                if(gui_cursor == ECH1) echo_enable[0] <= echo_enable[0] == 1'b1 ? 0 : 1;
                if(gui_cursor == ECH2) echo_enable[1] <= echo_enable[1] == 1'b1 ? 0 : 1;
                if(gui_cursor == ECH3) echo_enable[2] <= echo_enable[2] == 1'b1 ? 0 : 1;
                if(gui_cursor == ECH4) echo_enable[3] <= echo_enable[3] == 1'b1 ? 0 : 1;
                if(gui_cursor == ECHM) echo_enable[4] <= echo_enable[4] == 1'b1 ? 0 : 1;
                //CHORUS
                if(gui_cursor == CHO1) chorus_enable[0] <= chorus_enable[0] == 1'b1 ? 0 : 1;
                if(gui_cursor == CHO2) chorus_enable[1] <= chorus_enable[1] == 1'b1 ? 0 : 1;
                if(gui_cursor == CHO3) chorus_enable[2] <= chorus_enable[2] == 1'b1 ? 0 : 1;
                if(gui_cursor == CHO4) chorus_enable[3] <= chorus_enable[3] == 1'b1 ? 0 : 1;
                if(gui_cursor == CHOM) chorus_enable[4] <= chorus_enable[4] == 1'b1 ? 0 : 1;
                //DISTORTION
                if(gui_cursor == DIS1) distortion_enable[0] <= distortion_enable[0] == 1'b1 ? 0 : 1;
                if(gui_cursor == DIS2) distortion_enable[1] <= distortion_enable[1] == 1'b1 ? 0 : 1;
                if(gui_cursor == DIS3) distortion_enable[2] <= distortion_enable[2] == 1'b1 ? 0 : 1;
                if(gui_cursor == DIS4) distortion_enable[3] <= distortion_enable[3] == 1'b1 ? 0 : 1;
                if(gui_cursor == DISM) distortion_enable[4] <= distortion_enable[4] == 1'b1 ? 0 : 1;
                //LIMITER
                if(gui_cursor == LIM1) limiter_enable[0] <= limiter_enable[0] == 1'b1 ? 0 : 1;
                if(gui_cursor == LIM2) limiter_enable[1] <= limiter_enable[1] == 1'b1 ? 0 : 1;
                if(gui_cursor == LIM3) limiter_enable[2] <= limiter_enable[2] == 1'b1 ? 0 : 1;
                if(gui_cursor == LIM4) limiter_enable[3] <= limiter_enable[3] == 1'b1 ? 0 : 1;
                if(gui_cursor == LIMM) limiter_enable[4] <= limiter_enable[4] == 1'b1 ? 0 : 1;
            end
            if(in_selected_box_h && in_selected_box_v && in_box) pixel_out <= 12'hfff;
            else if(in_box) pixel_out <= 0;
            else if(((hcount_in >= 62 && hcount_in <= 662) || (hcount_in >= 812 && hcount_in <= 962))) begin
                pixel_out <= background & delay_out & record_out & volume_out & solo_out & limiter_out
                                & mute_out & effects_out & echo_out & chorus_out & distortion_out;
            end
            else pixel_out <= background;
        end
    end



endmodule


`default_nettype wire

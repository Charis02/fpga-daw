`default_nettype none
`timescale 1ns / 1ps

module mixer#(parameter WIDTH = 16, CHANNELS = 4)(
    input wire clk_in,
    input wire rst_in, 
    input wire solo_enable, 
    input wire [4:0] solo,
    input wire rst_in, 

    input wire signed [$clog2(CHANNELS):0][WIDTH-1:0] data_dry,    // clean input

    input wire [$clog2(CHANNELS):0] mute, 

    output logic signed [15:0] data_wet    // output
);
    //logic signed [$clog2(CHANNELS):0][CHANNELS+WIDTH-1:0] data_weighted;
    //logic signed [CHANNELS+WIDTH+1:0] data_summed = 0;
    logic signed [WIDTH+1:0] data_summed = 0;
    logic signed [$clog2(CHANNELS):0][WIDTH-1:0] data_dry_to_sum;

    always_comb begin
        data_dry_to_sum[0] = mute[0] ? 0 : data_dry[0];
        data_dry_to_sum[1] = mute[1] ? 0 : data_dry[1];
        data_dry_to_sum[2] = mute[2] ? 0 : data_dry[2];
        data_dry_to_sum[3] = mute[3] ? 0 : data_dry[3];
    end
    // always_comb begin
    //     data_summed = 0;
    //     /*
    //     for (integer i = 0; i < CHANNELS; i = i+1) begin
    //         data_weighted[i] = mute[i] ? 0 : $signed(data_dry[i] * $signed({1'b0,volume[i]}));
    //     end
    //     for (integer i = 0; i < CHANNELS; i = i+1) begin
    //         data_summed = $signed(data_summed + data_weighted[i]);
    //     end
    //     */
    //     for (integer i = 0; i < CHANNELS; i = i+1) begin
    //         data_summed = $signed(data_summed + data_dry[i]);
    //     end
    // end
    

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            data_wet <= 0;
        end else begin
            //data_wet <= data_summed[CHANNELS+WIDTH+1 : CHANNELS+WIDTH+1 - (WIDTH - 1)];
            if(solo_enable && solo == 0) data_wet <= data_dry[0] <<< 7;
            else if(solo_enable && solo == 1) data_wet <= data_dry[1] <<< 7;
            else if(solo_enable && solo == 2) data_wet <= data_dry[2] <<< 7;
            else if(solo_enable && solo == 3) data_wet <= data_dry[3] <<< 7;
    
            else data_wet <= $signed(data_dry_to_sum[0] + data_dry_to_sum[1] + data_dry_to_sum[2] + data_dry_to_sum[3]) <<< 6;
        end
    end


endmodule
`default_nettype wire
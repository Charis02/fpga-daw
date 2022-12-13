`default_nettype none
`timescale 1ns / 1ps

module mixer#(parameter WIDTH = 16, CHANNELS = 4)(
    input wire clk_in,
    input wire rst_in, 

    input wire signed [$clog2(CHANNELS):0][WIDTH-1:0] data_dry,    // clean input

    input wire [$clog2(CHANNELS):0][3:0] volume,
    input wire [$clog2(CHANNELS):0] mute, 

    output logic signed [WIDTH-1:0] data_wet    // output
);
    logic signed [$clog2(CHANNELS):0][CHANNELS+WIDTH-1:0] data_weighted;
    logic signed [CHANNELS+WIDTH+1:0] data_summed = 0;

    always_comb begin
        data_summed = 0;
        for (integer i = 0; i < CHANNELS; i = i+1) begin
            data_weighted[i] = mute[i] ? 0 : $signed(data_dry[i] * $signed({1'b0,volume[i]}));
        end
        for (integer i = 0; i < CHANNELS; i = i+1) begin
            data_summed = $signed(data_summed + data_weighted[i]);
        end
    end

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            data_wet <= 0;
        end else begin
            data_wet <= data_summed[CHANNELS+WIDTH+1 : CHANNELS+WIDTH+1 - 15];
        end
    end


endmodule
`default_nettype wire
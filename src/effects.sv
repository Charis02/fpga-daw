`default_nettype none
`timescale 1ns / 1ps

module effects#(parameter WIDTH = 16, CHANNELS = 4)(
    input wire clk_in, //clock @ 11.29 mhz
    input wire rst_in, 
    input wire effect_enable,
    input wire delay_enable,
    input wire echo_enable,
    input wire distortion_enable,
    input wire limiter_enable,

    input wire signed [$clog2(CHANNELS):0][WIDTH-1:0] data_dry,

    output logic signed [$clog2(CHANNELS):0][WIDTH-1:0] data_wet
);

    
    logic signed [$clog2(CHANNELS):0][WIDTH-1:0] data_after_delay;
    logic signed [$clog2(CHANNELS):0][WIDTH-1:0] data_after_echo;
    logic signed [$clog2(CHANNELS):0][WIDTH-1:0] data_after_chorus;
    logic signed [$clog2(CHANNELS):0][WIDTH-1:0] data_after_distortion;

    generate
        genvar i;
        for(i=0; i<CHANNELS; i=i+1)begin
            delay#(
                .WIDTH(WIDTH)
            ) delay(
                .clk_in(clk_in),
                .rst_in(rst_in),
                .delay_enable(delay_enable),
                .echo_enable(0),
                .data_dry(data_dry[i]),
                .data_wet(data_after_delay[i])
            );
            delay#(
                .WIDTH(WIDTH)
            ) echo(
                .clk_in(clk_in),
                .rst_in(rst_in),
                .delay_enable(0),
                .echo_enable(echo_enable),
                .data_dry(data_after_delay[i]),
                .data_wet(data_after_echo[i])
            );

            distortion#(
                .WIDTH(WIDTH)
            ) distortion(
                .clk_in(clk_in),
                .rst_in(rst_in),
                .distortion_enable(distortion_enable),
                .data_dry(data_after_echo[i]),
                .data_wet(data_after_distortion[i])
            );

            limiter#(
                .WIDTH(WIDTH)
            ) limiter(
                .clk_in(clk_in),
                .rst_in(rst_in),
                .limiter_enable(limiter_enable),
                .limit(8'b01111100),
                .data_dry(data_after_distortion[i]),
                .data_wet(data_wet[i])
            );
            
        end
    endgenerate


    always_ff @( posedge clk_in ) begin
        if(rst_in) begin
            for(integer i=0; i<CHANNELS; i=i+1)begin
                data_after_delay[i] <= 0;
                data_after_echo[i] <= 0;
                data_after_chorus[i] <= 0;
                data_after_distortion[i] <= 0;
            end
        end
    end
    


endmodule
`default_nettype wire
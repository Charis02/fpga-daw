`default_nettype none
`timescale 1ns / 1ps

module chorus#(parameter WIDTH = 16)(
    input wire clk_in, //clock @ 11.29 mhz
    input wire rst_in, 
    input wire chorus_enable,

    input wire signed [WIDTH-1:0] data_dry,    

    output logic signed [WIDTH-1:0] data_wet 
);

    logic signed [WIDTH-1:0] first_delay;
    logic signed [WIDTH-1:0] second_delay;
    logic signed [WIDTH-1:0] third_delay;

    delay#(
        .WIDTH(WIDTH),
        .SAMPLES_SAVED(5000)
    ) delay1(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .delay_enable(chorus_enable),
        .echo_enable(0),
        .data_dry(data_dry),
        .data_wet(first_delay)
    ); 

    delay#(
        .WIDTH(WIDTH),
        .SAMPLES_SAVED(10000)
    ) delay2(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .delay_enable(chorus_enable),
        .echo_enable(0),
        .data_dry(first_delay),
        .data_wet(second_delay)
    ); 

    delay#(
        .WIDTH(WIDTH),
        .SAMPLES_SAVED(20000)
    ) delay3(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .delay_enable(chorus_enable),
        .echo_enable(0),
        .data_dry(second_delay),
        .data_wet(third_delay)
    ); 

    delay#(
        .WIDTH(WIDTH),
        .SAMPLES_SAVED(30000)
    ) delay4(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .delay_enable(chorus_enable),
        .echo_enable(0),
        .data_dry(third_delay),
        .data_wet(data_wet)
    ); 

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            first_delay <= 0;
            second_delay <= 0;
            third_delay <= 0;
        end
    end
    



endmodule
`default_nettype wire
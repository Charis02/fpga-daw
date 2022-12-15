`default_nettype none
`timescale 1ns / 1ps

module distortion#(parameter WIDTH = 16)(
    input wire clk_in, //clock @ 11.29 mhz
    input wire rst_in, 
    input wire distortion_enable,

    input wire [WIDTH-1:0] data_dry,    //  clean input

    output logic [WIDTH-1:0] data_wet    //  output
);
    logic [WIDTH-1:0] mid_step;

    always_ff @(posedge clk_in) begin
        if(!rst_in) begin
            if(!distortion_enable) begin
                data_wet <= data_dry;
            end else begin
                mid_step <= data_dry >>> 3;
                data_wet <= mid_step <<< 3;
            end
        end
    end



endmodule
`default_nettype wire
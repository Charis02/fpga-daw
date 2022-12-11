`default_nettype none
`timescale 1ns / 1ps

module distortion#(parameter WIDTH = 16)(
    input wire clk_in, //clock @ 11.29 mhz
    input wire rst_in, 
    input wire distorion_enable,

    input wire [WIDTH-1:0] bit_amount,
    input wire [WIDTH-1:0] data_dry_l,    // left clean input
    input wire [WIDTH-1:0] data_dry_r,    // right clean input

    output logic [WIDTH-1:0] data_wet_l,    // left output
    output logic [WIDTH-1:0] data_wet_r    // right input
);
    logic [WIDTH-1:0] mid_step_l;
    logic [WIDTH-1:0] mid_step_r;

    always_ff @(posedge clk_in) begin
        if(!rst_in) begin
            if(!distorion_enable) begin
                data_wet_l <= data_dry_l;
                data_wet_r <= data_dry_r;
            end else begin
                mid_step_l <= data_dry_l >>> 12;
                mid_step_r <= data_dry_r >>> 12;
                data_wet_l <= mid_step_l <<< 12;
                data_wet_r <= mid_step_r <<< 12;
            end
        end
    end



endmodule
`default_nettype wire
`default_nettype none
`timescale 1ns / 1ps

module limiter#(parameter WIDTH = 16)(
    input wire clk_in, //clock @ 11.29 mhz
    input wire rst_in, 
    input wire limiter_enable,
    input wire limiter_type,
    input wire [WIDTH-1:0] limit, 

    input wire [WIDTH-1:0] data_dry_l,    // left clean input
    input wire [WIDTH-1:0] data_dry_r,    // right clean input

    output logic [WIDTH-1:0] data_wet_l,    // left output
    output logic [WIDTH-1:0] data_wet_r    // right input
);


    always_ff @(posedge clk_in) begin
        if(!rst_in) begin
            if(!limiter_enable) begin
                data_wet_l <= data_dry_l;
                data_wet_r <= data_dry_r;
            end else begin
                if(!limiter_type) begin // hard
                    if(data_dry_l > limit) data_wet_l <= limit;
                    else if(data_dry_l < -1 * limit) data_wet_l <= -1 * limit;

                    if(data_dry_r > limit) data_wet_r <= limit;
                    else if(data_dry_r < -1 * limit) data_wet_r <= -1 * limit;
                end else begin //soft: TODO
                    data_wet_l <= data_dry_l;
                    data_wet_r <= data_dry_r;
                end
            end
        end
    end



endmodule
`default_nettype wire
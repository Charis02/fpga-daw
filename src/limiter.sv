`default_nettype none
`timescale 1ns / 1ps

module limiter#(parameter WIDTH = 16)(
    input wire clk_in, //clock @ 11.29 mhz
    input wire rst_in, 
    input wire limiter_enable,
    input wire [WIDTH-1:0] limit, 

    input wire [WIDTH-1:0] data_dry,    

    output logic [WIDTH-1:0] data_wet 
);


    always_ff @(posedge clk_in) begin
        if(!rst_in) begin
            if(!limiter_enable) begin
                data_wet <= data_dry;
            end else begin
                if(data_dry > limit) data_wet <= limit;
                else if(data_dry < $signed(-1 * limit)) data_wet <= $signed(-1 * limit);
            end
        end
    end
    



endmodule
`default_nettype wire
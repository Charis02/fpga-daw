`timescale 1ns / 1ps
`default_nettype none

module edge_detector (
                  input wire clk_in,
                  input wire rst_in,
                  input wire dirty_in,
                  output logic clean_out);


    logic last = 0;
    always_ff @(posedge clk_in) begin
        if(dirty_in && last) begin
            clean_out <= 0;
        end
        if(dirty_in && !last) begin
            clean_out <= 1;
            last <= 1;
        end
        if(!dirty_in) begin
            clean_out <= 0;
            last <= 0;
        end
    end

endmodule

module enter_btn (
                  input wire clk_in,
                  input wire rst_in,
                  input wire dirty_in,
                  output logic clean_out);


    logic last;
    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            last <= dirty_in;
        end
        if(dirty_in != last) begin
            last <= dirty_in;
            clean_out <= 1;
        end else clean_out <= 0;
    end

endmodule
`default_nettype wire


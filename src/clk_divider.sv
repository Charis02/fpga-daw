`default_nettype none
`timescale 1ns / 1ps

module clock_divider#(
    parameter IN_TO_OUT = 4 // freq(clk_out) * IN_TO_OUT = freq(clk_out)
)
(
    input wire clk_in, // clock @ 100 MHz
    output logic clk_out // clock @ 100/IN_TO_OUT MHz
);
    logic [$clog2(IN_TO_OUT)-2:0] cnt;  // counts rising edges of main clock
    initial cnt = 0;
    initial clk_out = 0;

    always_ff @(posedge clk_in) begin
        if (cnt == IN_TO_OUT/2 - 1) begin // time to flip the clock
            clk_out <= !clk_out;    // flip it
            cnt <= 0;   // reset counter
        end else begin
            cnt <= cnt+1;
        end
    end

endmodule

`default_nettype wire
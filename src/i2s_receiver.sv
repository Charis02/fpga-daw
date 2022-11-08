`default_nettype none
`timescale 1ns / 1ps

// I2S Receiver, utilizing CS5343
// Timing diagram: https://statics.cirrus.com/pubs/proDatasheet/CS5343-44_F5.pdf

module i2s_receiver#(
    parameter WIDTH = 16,
    parameter MAIN_TO_SERIAL = 24, // period of serial clock measuring with main clock rising edges
    parameter MAIN_TO_LEFT_RIGHT = 1536, // period of ws clock measuring with main clock rising edges
    parameter SERIAL_TO_LEFT_RIGHT = 64, // period of ws clock measuring with serial clock rising edges
    parameter SAMPLING_RATE = 44100 // this probably does not matter  
)
(
    input wire mclk, // main clock
    input wire rst, // reset signal

    input wire sd_rx, // 1 bit receiving input

    output logic [WIDTH-1:0] rx_data_l,
    output logic [WIDTH-1:0] rx_data_r,

    output logic sclk,
    output logic ws
);

logic [$clog2(MAIN_TO_SERIAL):0] sclk_cnt;
logic [$clog2(SERIAL_TO_LEFT_RIGHT):0] ws_cnt;

logic [WIDTH-1:0] rx_data_buffer_l;
logic [WIDTH-1:0] rx_data_buffer_r;

logic sclk_change;
logic ws_change;

always_ff @(posedge mclk) begin
    if (rst) begin  // reset stuff
        sclk_cnt <= 0;
        ws_cnt <= 0;
        sclk <= 0;
        ws <= 0;
        sclk_change <= 0;
        ws_change <= 0;
    end else begin
        if (sclk_cnt < MAIN_TO_SERIAL/2-1) begin  // less than half period of sclk
            sclk_cnt <= sclk_cnt+1;
            sclk_change <= 0;
        end else begin  // half period, edge!
           sclk_cnt <= 0;
           sclk <= !sclk;
           sclk_change <= 1;


           if(sclk == 0) begin //rising edge of clock
            if (ws_cnt < SERIAL_TO_LEFT_RIGHT/2-1) begin   // less than half period of ws
                    ws_cnt <= ws_cnt+1;
                    ws_change <= 0;
            end else begin   // half period, edge!
                    ws_cnt <= 0;
                    ws <= !ws;
                    ws_change <= 1;
            end
           end
        end
    end
end

always_ff @(posedge mclk) begin
    if (rst) begin
        rx_data_buffer_l <= 0;
        rx_data_buffer_r <= 0;
        rx_data_l <= 0;
        rx_data_r <= 0;
    end else begin
        if (ws_change) begin // we changed channel! we must output the new channel
            // we change both for convenience
            rx_data_l <= rx_data_buffer_l;
            rx_data_r <= rx_data_buffer_r;
        end else if (sclk_change && sclk == 1) begin // poedge of sclk
            if (ws_cnt > 0 && ws_cnt <= WIDTH) begin // maybe not necessary to check ws_cnt > 0
                if (ws == 0) begin // left channel
                    rx_data_buffer_l <= {rx_data_buffer_l[WIDTH-2:0],sd_rx};
                end else begin // right channel
                    rx_data_buffer_r <= {rx_data_buffer_r[WIDTH-2:0],sd_rx};
                end
            end
        end
    end
end

endmodule

`default_nettype wire
`default_nettype none
`timescale 1ns / 1ps

// I2S Transmitter, utilizing CS5344
// Timing diagram: https://statics.cirrus.com/pubs/proDatasheet/CS5343-44_F5.pdf

module i2s_transmitter#(
    parameter WIDTH = 16,
    parameter MAIN_TO_SERIAL = 8, // period of serial clock measuring with main clock rising edges
    parameter MAIN_TO_LEFT_RIGHT = 256, // period of ws clock measuring with main clock rising edges
    parameter SERIAL_TO_LEFT_RIGHT = 64 // period of ws clock measuring with serial clock rising edges
)
(
    input wire mclk, // main clock
    input wire rst, // reset signal

    input wire [WIDTH-1:0] tx_data_l,
    input wire [WIDTH-1:0] tx_data_r,

    output logic sd_tx, // 1 bit transmitting output

    output logic sclk,
    output logic ws
);

    logic [$clog2(MAIN_TO_SERIAL):0] sclk_cnt;  // used to count serial clock intervals
    logic [$clog2(SERIAL_TO_LEFT_RIGHT):0] ws_cnt; // used to count ws clock intervals
    initial sclk_cnt = 0;
    initial ws_cnt = 0;
    initial sclk = 0;
    initial ws = 0;

    logic [WIDTH-1:0] tx_data_buffer_l; // temporarily store input (left channel)
    logic [WIDTH-1:0] tx_data_buffer_r; // temporarily store input (right channel)
    initial tx_data_buffer_l = 0;
    initial tx_data_buffer_r = 0;

    // serial clock generation:
    // Every MAIN_TO_SERIAL/2 rising edges of main clock, flip serial clock
    always_ff @(posedge mclk) begin
        if (rst) begin // reset stuff
            sclk <= 0;
            sclk_cnt <= 0;
        end else begin
            if (sclk_cnt == MAIN_TO_SERIAL/2-1) begin // it's time to flip sclk
                sclk <= !sclk;
                sclk_cnt <= 0;  // reset counter
            end else begin  // don't flip sclk yet.. just increase the counter
                sclk_cnt <= sclk_cnt+1;
            end
        end
    end

    // word select clock generation
    // Every SERIAL_TO_LEFT_RIGHT/2 rising edges of serial clock, flip word select clock
    // In here we also keep track of our input
    always_ff @(posedge mclk) begin
        if (rst) begin
            ws <= 0;
            ws_cnt <= 0;
            tx_data_buffer_r = 0;
            tx_data_buffer_l = 0;
        end else begin
            if (sclk_cnt == 0) begin    // in the previous cycle we flipped the sclk, so there was an edge
            // the above could also be == MAIN_TO_SERIAL/2-1 but it is not necessary (probably) (i hope)
                if (sclk == 1) begin // posedge of sclk -> increase lr clock counter
                    if (ws_cnt == SERIAL_TO_LEFT_RIGHT/2-1) begin // it's time to flip left right clock
                        ws <= !ws;
                        ws_cnt <= 0;    // reset counter

                        // we flipped the word select, so we have received a new input and we have to output it
                        tx_data_buffer_l <= tx_data_l;  // output left channel
                        tx_data_buffer_r <= tx_data_r;  // output right channel
                    end else begin  // don't flip lrclk yet.. just increase the counter
                        ws_cnt <= ws_cnt+1;
                    end
                end else begin // negedge of serial clock -> read data
                    if (ws_cnt <= WIDTH) begin // only read as many data as we can fit, the other is garbage
                        if (ws == 1) begin // right channel
                            sd_tx <= tx_data_buffer_r[WIDTH-1];
                            tx_data_buffer_r <= {tx_data_buffer_r[WIDTH-2:0],1'b0};
                        end else begin // left channel
                            sd_tx <= tx_data_buffer_l[WIDTH-1];
                            tx_data_buffer_l <= {tx_data_buffer_l[WIDTH-2:0],1'b0};
                        end
                    end
                end
            end
        end
    end
endmodule

`default_nettype wire
`default_nettype none
`timescale 1ns / 1ps

module track_store_load#
(
    parameter WORD_WIDTH = 16
)
(
    input wire clk, //clock @ 100 MHz
    input wire rst, // system reset

    input wire store_req,   // asserted when we are also going to assert rd
    input wire load_req,    // asserted when we are going to also assert wr

    input wire [WORD_WIDTH-1:0] din,
    input logic wr,    // asserted when we have a new value on din

    output logic [WORD_WIDTH-1:0] dout, // 2 (or 0????) cycles after rd is asserted, we have a valid output here
    input logic rd, // asserted when we need a new value on dout

    input wire [0:0] sd_dat_in,
    output logic [2:0] sd_dat_out,
    output logic sd_reset, 
    output logic sd_sck, 
    output logic sd_cmd
);
    // -------------------------SD CARD SECTION--------------------------------

    logic clk_25;

    // this will generate a 25MHz clock in clk_25
    clock_divider #(
        .IN_TO_OUT(4)
    ) clk25gen
    (
        .clk_in(clk),
        .clk_out(clk_25)
    );

    // for spi mode reset is low sd_dat[1:0] are high
    assign sd_reset = 1'b0;
    assign sd_dat_out[1:0] = 2'b11;


    // sd write inputs/outputs
    logic sd_wr;
    logic [7:0] sd_din;
    logic ready_for_next_byte;
    logic ready_for_next_byte_prev;
    logic ready_for_next_byte_posedge = ready_for_next_byte&~ready_for_next_byte_prev;

    // sd read inputs/outputs
    logic sd_rd;
    logic [7:0] sd_dout;
    logic byte_available;

    // general sd
    logic sd_ready;
    logic [31:0] sd_addr;

    sd_controller sdControl(
        // common stuff
        .clk(clk_25),
        .reset(rst),
        .cs(sd_dat_out[2]),
        .mosi(sd_cmd),
        .miso(sd_dat_in[0]),
        .sclk(sd_sck),

        .ready(sd_ready),   // is the sd ready for a new read/write?
        .address(sd_addr), // what address am i reading from (must be multiple of 512)

        // read
        .rd(sd_rd),  // read enable for sd
        .dout(sd_dout), // read value
        .byte_available(byte_available),    // is there a new byte

        // write
        .wr(sd_wr), // write enable for sd
        .din(sd_din),   // write value
        .ready_for_next_byte(ready_for_next_byte)   // can i give new byte
    );

    // ------------------------- (STORE) INPUT - FIFO - SD PIPELINE SECTION--------------------------------

    logic storing;
    logic [8:0] store_byte_cnt;

    logic read_next_fifo_store;
    initial read_next_fifo_store = 0;
    logic [WORD_WITH-1:0] fifo_store_dout;
    logic [$clog2(WORD_WIDTH-1)-1:0] fifo_store_index;
    assign sd_din = fifo_store_dout[7+fifo_store_index:fifo_store_index];
    
    logic wr_prev;
    logic wr_posedge = wr&~wr_prev;

    fifo#(
        .WIDTH(WORD_WIDTH),
        .DEPTH(2048)
    )
    fifo_store( // fifo that holds what we are about to store in the sd
        .clk(clk),
        .rst(rst),

        .rd(read_next_fifo_store),
        .dout(fifo_store_dout),

        .wr(read_req&wr_posedge),
        .din(din)
    );

    always_ff @(posedge clk) begin  // input -> fifo store
        if (rst) begin
        end else if(storing) begin
            if (wr_posedge) begin
                store_byte_cnt <= store_byte_cnt+1;

                if (store_byte_cnt == 511) begin
                    store_to_sd <= 1;

                    if (!store_req) begin
                        storing <= 0;
                    end
                end
            end
        end else if (store_req) begin
            store_byte_cnt <= 0;
            storing <= 1;
        end

        wr_prev <= wr;  // to calculate posedge
    end
'
    always_ff @(posedge clk) begin // fifo store -> sd card
        if (rst) begin
        end else if (ready_for_next_byte_posedge) begin // we can give a new byte
            sd_wr <= 0;
            
            if (fifo_store_index == WORD_WIDTH - 8) begin
                fifo_store_index <= 0;
                read_next_fifo_store <= 1;
            end else begin
                fifo_store_index <= fifo_store_index + 8;
            end
        end else if (store_to_sd) begin // there are 512 bytes in the fifo waiting to be stored
            if (ready) begin
                sd_wr <= 1;
                store_to_sd <= 0;
                fifo_store_index <= 0;
                read_next_fifo_store <= 1;
            end
        end

        if (read_next_fifo_store) read_next_fifo_store <= 0;    // reset it to be ready for next read

        ready_for_next_byte_prev <= ready_for_next_byte;    // to calculate posedge
    end

    logic loading;
    initial loading = 0;
    logic [8:0] load_byte_cnt;
    initial load_byte_cnt = 0;
    logic write_next_fifo_load; // requests to load from sd to fifo new 512 byte sequence

    logic [$clog2(WORD_WIDTH-1)-1:0] fifo_load_index;

    logic rd_prev;
    logic rd_posedge = rd&~rd_prev;

    logic [WORD_WIDTH-1:0] current_word;

    fifo#(
        .WIDTH(WORD_WIDTH),
        .DEPTH(2048)
    )
    fifo_load( // fifo that holds what we just loaded from sd
        .clk(clk),
        .rst(rst),

        .rd(load_req&rd_posedge),
        .dout(dout),

        .wr((loading && fifo_load_index == 0) ? 1 : 0),
        .din(current_word)
    );

    always_ff @(posedge clk) begin  // sd card -> fifo load
        if (rst) begin
        end else if(loading) begin
            sd_rd <= 0;
            if (byte_available_posedge) begin
                current_word <= {sd_dout,current_word};
                if (fifo_load_index == WORD_WIDTH-8) begin
                    fifo_load_index <= 0;
                end else begin
                    fifo_load_index <= fifo_load_index + 8;
                end
            end else if (ready) begin
                loading <= 0;
            end
        end else if (write_next_fifo_load) begin
            if (ready) begin
                write_next_fifo_load <= 0;
                loading <= 1;
                sd_rd <= 1;
            end
        end
    end


    always_ff @(posedge clk) begin // fifo load -> output
        if (rst) begin
        end else if (rd_posedge && load_req) begin // new word request
            load_byte_cnt <= load_byte_cnt + WORD_WIDTH/8;  // add how many bytes we retrieved from fifo
            if (load_byte_cnt == 512-WORD_WIDTH/8) begin
                write_next_fifo_load <= 1;
            end
        end

        rd_prev <= rd;
    end

endmodule

`default_nettype wire
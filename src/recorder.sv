`default_nettype none
`timescale 1ns / 1ps

module track_store_load#
(
    parameter WORD_WIDTH = 16,
    parameter CHANNELS = 1
)
(
    input wire clk, //clock @ 100 MHz
    input wire rst, // system reset

    input wire store_req,   // asserted when we are also going to assert rd
    input wire load_req,    // asserted when we are going to also assert wr
    input wire mix_req, // asserted when we are going to also assert mrd

    input wire [31:0] initial_addr,

    input wire [WORD_WIDTH-1:0] din,
    input wire wr,    // asserted when we have a new value on din

    output logic [WORD_WIDTH-1:0] dout, // at most 2 cycles after rd is asserted, we have a valid output here
    input wire rd, // asserted when we need a new value on dout

    output logic [$clog2(CHANNELS):0][WORD_WIDTH-1:0] mdout,    // at most 2 cycles after mrd is asserted, we have a valid output here
    input wire mrd,
    
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

    // sd read inputs/outputs
    logic sd_rd;
    logic [7:0] sd_dout;
    logic byte_available;
    logic byte_available_prev;

    // general sd
    logic sd_ready;
    logic [31:0] sd_addr;
    logic [31:0] sd_addr_load;
    logic [31:0] sd_addr_store;

    assign sd_addr = (load_req) ? sd_addr_load : ((store_req) ? sd_addr_store : sd_addr_mix);
    assign sd_rd = (load_req) ? sd_rd_load : sd_rd_mix;

    sd_controller sdControl(
        // common stuff
        .real_clk(clk), // the real clock that drives our always
        .clk(clk_25),   // to avoid using more clock domains
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
    logic store_to_sd;
    logic [8:0] store_byte_cnt;

//   logic read_next_fifo_store;
//    initial read_next_fifo_store = 0;
    logic [WORD_WIDTH-1:0] fifo_store_dout;
    logic [$clog2(WORD_WIDTH)-1:0] fifo_store_index;
    initial fifo_store_index = 0;
    logic [WORD_WIDTH-1:0] fifo_store_word;
    assign sd_din = fifo_store_dout;//fifo_store_word[7:0];
    
    logic wr_prev;

    fifo#(
        .WIDTH(WORD_WIDTH),
        .DEPTH(4096)
    )
    fifo_store( // fifo that holds what we are about to store in the sd
        .clk(clk),
        .rst(rst),

        .rd(sd_wr&ready_for_next_byte),  // only move read pointer when read
        .dout(fifo_store_dout),

        .wr((storing && wr == 1) ? 1'b1 : 1'b0),    // write into the fifo when we have a new value (wr) and we are storing (storing)
        .din(din)   // driven directly from input
    );

    always_ff @(posedge clk) begin  // input -> fifo store
        if (rst) begin  
            store_byte_cnt <= 0;
            storing <= 0;
        end else if(storing) begin
            if (wr == 1 && wr_prev == 0) begin
                store_byte_cnt <= store_byte_cnt+WORD_WIDTH/8;

                if (store_byte_cnt == 512-WORD_WIDTH/8) begin
                    if (!store_req) begin
                        storing <= 0;
                    end
                end
            end
        end else if (store_req) begin
            store_byte_cnt <= 0;
            storing <= 1;
        end

        if (!store_req) begin
            sd_addr_store <= initial_addr;
        end else if (sd_wr && ready_for_next_byte == 1 && ready_for_next_byte_prev == 0 && cnt_ready_for_next_byte_posedge == 511) begin
            sd_addr_store <= sd_addr_store + 512;
        end

        wr_prev <= wr;  // to calculate posedge
    end
    
    logic [10:0] cnt_ready_for_next_byte_posedge;

    always_ff @(posedge clk) begin // fifo store -> sd card
        if (rst) begin
            cnt_ready_for_next_byte_posedge <= 0;
            sd_wr <= 0;
        end else if (sd_wr && ready_for_next_byte == 1 && ready_for_next_byte_prev == 0) begin // we can give a new byte
                cnt_ready_for_next_byte_posedge <= cnt_ready_for_next_byte_posedge+1;
                
                if (cnt_ready_for_next_byte_posedge == 511) begin
                    sd_wr <= 0;
                end
            
           /*     if (fifo_store_index == WORD_WIDTH - 8) begin
                    fifo_store_word <= fifo_store_dout;
                    fifo_store_index <= 0;
                end else begin
                    fifo_store_index <= fifo_store_index + 8;   // count how many bytes of the word we have stored into the sd
                    fifo_store_word <= fifo_store_word >> 8;
                end */
        end else if (store_to_sd) begin // there are 512 bytes in the fifo waiting to be stored
            if (sd_ready) begin // the sd is ready
                sd_wr <= 1;
                fifo_store_index <= 0;
                cnt_ready_for_next_byte_posedge <= 0;
            end
        end

        if (storing && wr == 1 && wr_prev == 0 && store_byte_cnt == 512-WORD_WIDTH/8) begin  // time to store stuff from fifo to sd
            store_to_sd <= 1;
        end else if (store_to_sd && sd_ready) begin // the request is accepted from sd card, reset flag
            store_to_sd <= 0;
        end

        ready_for_next_byte_prev <= ready_for_next_byte;    // to calculate posedge
    end

    // ------------------------- (LOAD) SD - FIFO - OUTPUT PIPELINE SECTION--------------------------------

    logic [8:0] load_byte_cnt;
    logic [3:0] write_next_fifo_load; // requests to load from sd to fifo new 512 byte sequence

    logic [8:0] cnt_byte_available_posedge;
    logic rd_prev;

    logic sd_rd_load;
    initial sd_rd_load = 0;

    fifo#(
        .WIDTH(WORD_WIDTH),
        .DEPTH(4096)
    )
    fifo_load( // fifo that holds what we just loaded from sd
        .clk(clk),
        .rst(rst),

        .rd((load_req == 1 && rd == 1 && rd_prev == 0) ? 1 : 0),
        .dout(dout),

        .wr((load_req == 1 && sd_rd_load == 1 && byte_available == 1 && byte_available_prev == 0) ? 1 : 0),  // write on negative edge of byte available to ensure current_word is updated
        .din(sd_dout)
    );

    always_ff @(posedge clk) begin  // sd card -> fifo load
        if (rst) begin
            cnt_byte_available_posedge <= 0;
            sd_rd_load <= 0;
            write_next_fifo_load <= 3;
        end else if (sd_rd_load == 1 && byte_available == 1 && byte_available_prev == 0) begin // byte available posedge
            if (cnt_byte_available_posedge == 511) begin
                cnt_byte_available_posedge <= 0;
                sd_rd_load <= 0;
            end else begin
                cnt_byte_available_posedge <= cnt_byte_available_posedge + 1;
            end
                
//            current_word <= sd_dout;
//                
//                if (WORD_WIDTH == 8) begin
//                    current_word <= sd_dout;
//                end else begin
//                    current_word <= {current_word[WORD_WIDTH-9:0],sd_dout};
//                end
                
//                if (fifo_load_index == WORD_WIDTH-8) begin
//                    fifo_load_index <= 0;
//                end else begin
//                    fifo_load_index <= fifo_load_index + 8;
//                end
        end else if (load_req == 1 && write_next_fifo_load > 0) begin
            if (sd_ready) begin
                sd_rd_load <= 1;
                cnt_byte_available_posedge <= 0;
            end
        end

        if (!load_req) begin
            sd_addr_load <= initial_addr;
            write_next_fifo_load <= 3;
        end else if (sd_rd_load == 1 && byte_available == 1 && byte_available_prev == 0 && cnt_byte_available_posedge == 511) begin
            sd_addr_load <= sd_addr_load+512;
        end
        
        if (load_req == 1 && rd == 1 && rd_prev == 0 && load_byte_cnt == 511) begin
            write_next_fifo_load <= write_next_fifo_load + 1;
        end else if(load_req == 1 && write_next_fifo_load > 0 && sd_ready == 1) begin
            write_next_fifo_load <= write_next_fifo_load - 1;
        end

        byte_available_prev <= byte_available; // to calculate posedge
    end


    always_ff @(posedge clk) begin // fifo load -> output
        if (rst) begin
            load_byte_cnt <= 0;
        end else if (rd == 1 && rd_prev == 0  && load_req == 1) begin // new word request
            load_byte_cnt <= load_byte_cnt + 1;  // add how many bytes we retrieved from fifo
        end
        rd_prev <= rd;
    end


    // ------------------------- (MIX LOAD) SD - FIFO - OUTPUT PIPELINE SECTION--------------------------------

    logic [8:0] mix_byte_cnt; // how many bytes have been loaded from fifo to output (resets every 512)
    logic [$clog2(CHANNELS):0] current_channel;   // which channel are we currently retrieving data for from the sd
    logic [3:0] mix_write_next_fifo_load; // how many requests to load from sd to fifo new 512 byte sequence are pending
    
    logic [8:0] mix_cnt_byte_available_posedge; // how many bytes have been retrieved from current sector
    logic mrd_prev;
    logic [31:0] sd_addr_mix_offset;    // offset for sd addresses (increments of 512)
    logic [31:0] sd_addr_mix;    // actual sd address of current track
    logic sd_rd_mix;
    initial sd_rd_mix = 0;

    generate
        genvar i;

        for (i = 0;i < CHANNELS;i = i+1) begin
            fifo#(
                .WIDTH(WORD_WIDTH),
                .DEPTH(8192)
            )
            fifo_mix( // fifo that holds what we just loaded from sd
                .clk(clk),
                .rst(rst),

                .rd((mix_req == 1 && mrd == 1 && mrd_prev == 0) ? 1 : 0),
                .dout(mdout[i]),

                .wr((current_channel == i && mix_req == 1 && sd_rd_mix == 1 && byte_available == 1 && byte_available_prev == 0) ? 1 : 0),
                .din(sd_dout)
            );
        end
    endgenerate

    always_ff @(posedge clk) begin  // sd card -> fifo mix
        if (rst) begin
            mix_cnt_byte_available_posedge <= 0;
            sd_rd_mix <= 0;
            mix_write_next_fifo_load <= 3;
        end else if (sd_rd_mix == 1 && byte_available == 1 && byte_available_prev == 0) begin // byte available posedge
            if (mix_cnt_byte_available_posedge == 511) begin
                mix_cnt_byte_available_posedge <= 0;
                sd_rd_mix <= 0;
            end else begin
                mix_cnt_byte_available_posedge <= mix_cnt_byte_available_posedge + 1;
            end
        end else if (mix_req == 1 && mix_write_next_fifo_load > 0) begin
            if (sd_ready) begin
                sd_rd_mix <= 1;
                mix_cnt_byte_available_posedge <= 0;
            end
        end

        if (!mix_req) begin
            sd_addr_mix_offset <= 0;
            mix_write_next_fifo_load <= 7;
            current_channel <= 0;
        end else if (sd_rd_mix == 1 && byte_available == 1 && byte_available_prev == 0 && mix_cnt_byte_available_posedge == 511) begin
            if(current_channel == CHANNELS-1) begin
                sd_addr_mix_offset <= sd_addr_mix_offset + 512;
                sd_addr_mix <= sd_addr_mix_offset+512;
                current_channel <= 0;
                mix_write_next_fifo_load <= mix_write_next_fifo_load - 1;
            end else begin
                sd_addr_mix <= ((current_channel+1) << 25)+sd_addr_mix_offset;
                current_channel <= current_channel+1;
            end
        end else if (mix_req == 1 && mrd == 1 && mrd_prev == 0 && mix_byte_cnt == 511) begin
            mix_write_next_fifo_load <= mix_write_next_fifo_load + 1;
        end
    end


    always_ff @(posedge clk) begin // fifo load -> output
        if (rst) begin
            mix_byte_cnt <= 0;
        end else if (mrd == 1 && mrd_prev == 0  && mix_req == 1) begin // new word request
            mix_byte_cnt <= mix_byte_cnt + 1;  // add how many bytes we retrieved from fifo
        end
        mrd_prev <= mrd;
    end

endmodule

`default_nettype wire
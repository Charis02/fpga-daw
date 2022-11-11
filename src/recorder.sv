`default_nettype none
`timescale 1ns / 1ps

module recorder(
    input wire clk, //clock @ 100 MHz
    input wire rst,

    input wire record_req,
    input wire play_req,
    input wire [7:0] byte_in,
    output logic [7:0] byte_out,

    input wire [3:0] sd_dat,
    output logic sd_reset, 
    output logic sd_sck, 
    output logic sd_cmd
);
    // sd card section

    logic clk_25;

    clock_divider #(
        .IN_TO_OUT(4)
    ) clk25gen
    (
        .clk_in(clk),
        .clk_out(clk_25)
    );

    assign sd_reset = 1'b0;
    assign sd_dat[2:1] = 2'b11;

    // sd controller inputs
    logic rd; // read enable
    logic wr; // write enable
    logic [31:0] addr;          // starting address for read/write operation
    initial addr = 0;
    
    // sd controller outputs
    logic ready;                // high when ready for new read/write operation
    logic byte_available;       // high when byte available for read
    logic ready_for_next_byte;  // high when ready for new byte to be written

    sd_controller sdControl(
        .clk(clk_25),
        .reset(rst),
        .cs(sd_dat[3]),
        .mosi(sd_cmd),
        .miso(sd_dat[0]),
        .sclk(sd_sck),
        .ready(ready),
        .address(addr),
        .rd(rd),
        .dout(byte_out),
        .byte_available(byte_available),
        .wr(wr),
        .din(byte_in),
        .ready_for_next_byte(ready_for_next_byte)
    );

    logic [8:0] byte_cnt;
    initial byte_cnt = 0;
    
    logic byte_available_before;

    always_ff @(posedge clk) begin
        if (rst) begin
            byte_cnt <= 0;
        end else begin
            if (ready_for_next_byte) begin
                byte_cnt <= byte_cnt + 1;

                if(byte_cnt == 511) begin
                    addr <= addr+512;

                    if (!record_req)
                        wr <= 0;
                end
            end else if (byte_available && !byte_available_before) begin
                if(byte_cnt == 511) begin
                    addr <= addr+512;

                    if (!play_req)
                        rd <= 0;
                end
            end else if(record_req) begin
                addr <= 0;
                wr <= 1;
            end else if(play_req) begin
                addr <= 0;
                rd <= 1;
            end

            byte_available_before <= byte_available;
        end
    end
endmodule

`default_nettype wire
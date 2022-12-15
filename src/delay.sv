`default_nettype none
`timescale 1ns / 1ps

module delay#(parameter WIDTH = 16)(
    input wire clk_in, //clock @ 11.29 mhz
    input wire rst_in, 
    input wire delay_enable,
    input wire echo_enable,

    input wire signed [WIDTH-1:0] data_dry,    // left clean input

    output logic signed [WIDTH-1:0] data_wet    // left output
);

    localparam SAMPLES_SAVED = 30000;

    logic [$clog2(SAMPLES_SAVED)-1:0] addr_pointer_read = 0;
    logic [$clog2(SAMPLES_SAVED)-1:0] addr_pointer_write = 0;
    logic signed [WIDTH-1:0] delayed_sample;
    logic signed [WIDTH-1:0] delay_in;

    
    logic signed [WIDTH:0] value;
    
    xilinx_true_dual_port_read_first_1_clock_ram #(
        .RAM_WIDTH(WIDTH),
        .RAM_DEPTH(SAMPLES_SAVED))
    line0 (
        //Write Side (16.67MHz)
        .addra(addr_pointer_write),
        .clka(clk_in),
        .wea(1'b1),
        .dina(delay_in),
        .ena(1'b1),
        .regcea(1'b1),
        .rsta(rst_in),
        .douta(),
        //Read Side (65 MHz)
        .addrb(addr_pointer_read),
        .dinb(0),
        // .clkb(clk_in),
        .web(1'b0),
        .enb(1'b1),
        .regceb(1'b1),
        .rstb(rst_in),
        .doutb(delayed_sample)
    );
    
    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            addr_pointer_read <= 1;
            addr_pointer_write <= 0;
            delay_in <= 0;
            delay_in <= 0;
        end else begin
            value <= $signed(data_dry + $signed(delayed_sample >>> 1));
            if(delay_enable) begin
                delay_in <= data_dry;
                data_wet <= value[WIDTH:1];
            end else if(echo_enable) begin
                delay_in <= value[WIDTH:1];
                data_wet <= value[WIDTH:1];
            end else begin
                data_wet <= data_dry;
            end
            if(addr_pointer_read + 1 == SAMPLES_SAVED) addr_pointer_read <= 0;
            else addr_pointer_read <= addr_pointer_read + 1;
            addr_pointer_write <= addr_pointer_read;
        end
    end
    
    /*

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            addr_pointer <= 0;
        end else begin
            if(!delay_enable) begin
                data_wet_l <= data_dry_l;
                data_wet_r <= data_dry_r;
            end else begin
                data_wet_l <= value_l[15:0] >>> 1; //TODO: check for overflow.
                data_wet_r <= value_r[15:0] >>> 1; //TODO: check for overflow.
            end
            if(addr_pointer + 1 == SAMPLES_SAVED) addr_pointer <= 0;
            else addr_pointer <= addr_pointer + 1;
            addr_pointer_write <= addr_pointer;
        end
    end

    */

endmodule
`default_nettype wire
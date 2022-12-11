`default_nettype none
`timescale 1ns / 1ps

module delay#(parameter WIDTH = 16)(
    input wire clk_in, //clock @ 11.29 mhz
    input wire rst_in, 
    input wire delay_enable,
    input wire echo_enable,

    input wire signed [WIDTH-1:0] data_dry_l,    // left clean input
    input wire signed [WIDTH-1:0] data_dry_r,    // right clean input

    output logic signed [WIDTH-1:0] data_wet_l,    // left output
    output logic signed [WIDTH-1:0] data_wet_r    // right input
);

    localparam SAMPLES_SAVED = 30000;

    logic [$clog2(SAMPLES_SAVED)-1:0] addr_pointer_read = 0;
    logic [$clog2(SAMPLES_SAVED)-1:0] addr_pointer_write = 0;
    logic [15:0] delayed_sample_l;
    logic [15:0] delayed_sample_r;
    logic [15:0] delay_in_l;
    logic [15:0] delay_in_r;

    
    logic [16:0] value_l;
    logic [16:0] value_r;


    
    xilinx_true_dual_port_read_first_1_clock_ram #(
        .RAM_WIDTH(WIDTH),
        .RAM_DEPTH(SAMPLES_SAVED))
    line0 (
        //Write Side (16.67MHz)
        .addra(addr_pointer_write),
        .clka(clk_in),
        .wea(1'b1),
        .dina(delay_in_l),
        .ena(1'b1),
        .regcea(1'b1),
        .rsta(rst_in),
        .douta(),
        //Read Side (65 MHz)
        .addrb(addr_pointer_read),
        .dinb(16'b0),
        // .clkb(clk_in),
        .web(1'b0),
        .enb(1'b1),
        .regceb(1'b1),
        .rstb(rst_in),
        .doutb(delayed_sample_l)
    );

    xilinx_true_dual_port_read_first_1_clock_ram #(
        .RAM_WIDTH(WIDTH),
        .RAM_DEPTH(SAMPLES_SAVED))
    line1 (
        //Write Side (16.67MHz)
        .addra(addr_pointer_write),
        .clka(clk_in),
        .wea(1'b1),
        .dina(delay_in_r),
        .ena(1'b1),
        .regcea(1'b1),
        .rsta(rst_in),
        .douta(),
        //Read Side (65 MHz)
        .addrb(addr_pointer_read),
        .dinb(16'b0),
        // .clkb(clk_in),
        .web(1'b0),
        .enb(1'b1),
        .regceb(1'b1),
        .rstb(rst_in),
        .doutb(delayed_sample_r)
    );

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            addr_pointer_read <= 1;
            addr_pointer_write <= 0;
            delay_in_l <= 0;
            delay_in_r <= 0;
        end else begin
            value_l <= (data_dry_l >> 1)+ (delayed_sample_l >> 1);
            value_r <= (data_dry_r >> 1) + (delayed_sample_r >> 1);
            if(delay_enable) begin
                delay_in_l <= data_dry_l;
                delay_in_r <= data_dry_r;
                data_wet_l <= value_l[15:0];
                data_wet_r <= value_r[15:0];
            end else if(echo_enable) begin
                delay_in_l <= value_l[15:0];
                delay_in_r <= value_r[15:0];
                data_wet_l <= value_l[15:0];
                data_wet_r <= value_r[15:0];
            end else begin
                data_wet_l <= data_dry_l;
                data_wet_r <= data_dry_r;
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
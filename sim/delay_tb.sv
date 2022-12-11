`default_nettype none
`timescale 1ns / 1ps

module delay_tb#(parameter WIDTH = 16)();
    logic clk;
    logic rst;
    logic delay_enable = 1;

    logic [WIDTH-1:0] data_dry_l;
    logic [WIDTH-1:0] data_dry_r;

    logic [WIDTH-1:0] data_after_delay_l;
    logic [WIDTH-1:0] data_after_delay_r;

    delay delay_module(
        .clk_in(clk),
        .rst_in(rst),
        .delay_enable(delay_enable),
        .data_dry_l(data_dry_l),
        .data_dry_r(data_dry_r),
        .data_wet_l(data_after_delay_l),
        .data_wet_r(data_after_delay_r)
    );


    always begin
        clk = !clk;
        #5;
    end

    initial begin
        $dumpfile("delat.vcd");
        $dumpvars(0, delay_tb);
        $display("Starting Simulation.");
        clk = 0;
        rst = 0;

        #(10);
        rst = 1;
        #(10);
        rst = 0;    

        $display("Test:");



        for(int i = 1; i < 96000;i++) begin
            data_dry_l = i;
            data_dry_r = i;
            if(i % 10000 == 0) $display("at sample: %d. out_l: %d. out_r: %d, delayed: %d, ptr: %d", i, data_after_delay_l, data_after_delay_r, delay_module.delayed_sample_l, delay_module.addr_pointer);
            #(10);
        end




        $finish;
    end

endmodule

`default_nettype wire
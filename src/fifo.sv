`default_nettype none
`timescale 1ns / 1ps

module fifo#
(
    parameter WIDTH = 16,
    parameter DEPTH = 512
)
(
    input wire clk, //clock @ 100 MHz
    input wire rst,
    
    input wire rd,  // assert when you need a new value
    output logic [WIDTH-1:0] dout,  // 2 clk cycles later, we have a valid new value here

    input wire wr,  // assert to write a new value
    input wire [WIDTH-1:0] din
);
    logic [$clog2(DEPTH)-1:0] read_pointer;
    logic [$clog2(DEPTH)-1:0] write_pointer;
    initial read_pointer = 0;
    initial write_pointer = 0;

    logic rd_prev;
    logic wr_prev;

    xilinx_true_dual_port_read_first_1_clock_ram #(
        .RAM_WIDTH(WIDTH),                       // Specify RAM data width
        .RAM_DEPTH(DEPTH)                     // Specify RAM depth (number of entries)
    ) 
    bram
    (
        .clka(clk),        // Clock
        .addra(write_pointer),  // use port A for writes
        .ena(1'b1),    // Always on (?)
        .rsta(rst), // reset with system
        .dina(din), 
        .wea((wr == 1 && wr_prev == 0) ? 1 : 0),  // Port A write enable

        .addrb(read_pointer), // use port B for reads
        .enb(1'b1), // always on (?)
        .rstb(rst), // reset with system
        .regceb(1'b1),  // read enable on
        .doutb(dout)
    );
    
    always_ff @(posedge clk) begin
        if (rst) begin
            read_pointer <= 0;
            write_pointer <= 0;
        end else begin
            if (rd == 1 && rd_prev == 0) begin
                if (read_pointer + 1 < DEPTH)
                    read_pointer <= read_pointer + 1;
                else 
                    read_pointer <= 0;
            end
            if (wr == 1 && wr_prev == 0) begin
                if (write_pointer + 1 < DEPTH)
                    write_pointer <= write_pointer + 1;
                else
                    write_pointer <= 0;
            end
        end

        rd_prev <= rd;
        wr_prev <= wr;
    end


endmodule

`default_nettype wire
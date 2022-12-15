`timescale 1ns / 1ps
`default_nettype none

`include "iverilog_hack.svh"


module record_sprite #(
  parameter WIDTH=150, HEIGHT=60) (
  input wire pixel_clk_in,
  input wire rst_in,
  input wire [10:0] x_in, hcount_in,
  input wire [9:0]  y_in, vcount_in,
  
  output logic [11:0] pixel_out);

  logic [11:0] COLOR;
  logic COLOR_ADDR;

  parameter white = 12'hfff;

  // calculate rom address
  logic [$clog2(WIDTH*HEIGHT)-1:0] image_addr;
  assign image_addr = (hcount_in - x_in) + ((vcount_in - y_in) * WIDTH);

  logic in_sprite;
  assign in_sprite = ((hcount_in >= x_in && hcount_in < (x_in + WIDTH)) &&
                      (vcount_in >= y_in && vcount_in < (y_in + HEIGHT)));

  xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(1),                       // Specify RAM data width
    .RAM_DEPTH(WIDTH * HEIGHT),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(record.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) pos_to_color_addr (
    .addra(image_addr),     // Address bus, width determined from RAM_DEPTH
    .dina(8'b0),       // RAM input data, width determined from RAM_WIDTH
    .clka(pixel_clk_in),       // Clock
    .wea(1'b0),         // Write enable
    .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(1'b1),   // Output register enable
    .douta(COLOR_ADDR)      // RAM output data, width determined from RAM_WIDTH
  );


  // Modify the line below to use your BRAMs!
  assign COLOR = COLOR_ADDR == 0 ? white : 0;
  assign pixel_out = in_sprite ? COLOR : white;
endmodule

module volume_sprite #(
  parameter WIDTH=150, HEIGHT=60) (
  input wire pixel_clk_in,
  input wire rst_in,
  input wire [10:0] x_in, hcount_in,
  input wire [9:0]  y_in, vcount_in,
  
  
  output logic [11:0] pixel_out);

  logic [11:0] COLOR;
  logic COLOR_ADDR;

  parameter white = 12'hfff;

  // calculate rom address
  logic [$clog2(WIDTH*HEIGHT)-1:0] image_addr;
  assign image_addr = (hcount_in - x_in) + ((vcount_in - y_in) * WIDTH);

  logic in_sprite;
  assign in_sprite = ((hcount_in >= x_in && hcount_in < (x_in + WIDTH)) &&
                      (vcount_in >= y_in && vcount_in < (y_in + HEIGHT)));

  xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(1),                       // Specify RAM data width
    .RAM_DEPTH(WIDTH * HEIGHT),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(volume.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) pos_to_color_addr (
    .addra(image_addr),     // Address bus, width determined from RAM_DEPTH
    .dina(8'b0),       // RAM input data, width determined from RAM_WIDTH
    .clka(pixel_clk_in),       // Clock
    .wea(1'b0),         // Write enable
    .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(1'b1),   // Output register enable
    .douta(COLOR_ADDR)      // RAM output data, width determined from RAM_WIDTH
  );


  // Modify the line below to use your BRAMs!
  assign COLOR = COLOR_ADDR == 0 ? white : 0;
  assign pixel_out = in_sprite ? COLOR : white;
endmodule

module solo_sprite #(
  parameter WIDTH=150, HEIGHT=60) (
  input wire pixel_clk_in,
  input wire rst_in,
  input wire [10:0] x_in, hcount_in,
  input wire [9:0]  y_in, vcount_in,
  input wire bckrnd,
  
  output logic [11:0] pixel_out);

  logic [11:0] COLOR;
  logic COLOR_ADDR;

  parameter white = 12'hfff;

  // calculate rom address
  logic [$clog2(WIDTH*HEIGHT)-1:0] image_addr;
  assign image_addr = (hcount_in - x_in) + ((vcount_in - y_in) * WIDTH);

  logic in_sprite;
  assign in_sprite = ((hcount_in >= x_in && hcount_in < (x_in + WIDTH)) &&
                      (vcount_in >= y_in && vcount_in < (y_in + HEIGHT)));

  xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(1),                       // Specify RAM data width
    .RAM_DEPTH(WIDTH * HEIGHT),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(solo.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) pos_to_color_addr (
    .addra(image_addr),     // Address bus, width determined from RAM_DEPTH
    .dina(8'b0),       // RAM input data, width determined from RAM_WIDTH
    .clka(pixel_clk_in),       // Clock
    .wea(1'b0),         // Write enable
    .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(1'b1),   // Output register enable
    .douta(COLOR_ADDR)      // RAM output data, width determined from RAM_WIDTH
  );


  // Modify the line below to use your BRAMs!
  assign COLOR = COLOR_ADDR == 0 ? (bckrnd ? 12'h00f : white) : 0;
  assign pixel_out = in_sprite ? COLOR : white;
endmodule

module mute_sprite #(
  parameter WIDTH=150, HEIGHT=60) (
  input wire pixel_clk_in,
  input wire rst_in,
  input wire [10:0] x_in, hcount_in,
  input wire [9:0]  y_in, vcount_in,
  input wire bckrnd,
  
  output logic [11:0] pixel_out);

  logic [11:0] COLOR;
  logic COLOR_ADDR;

  parameter white = 12'hfff;

  // calculate rom address
  logic [$clog2(WIDTH*HEIGHT)-1:0] image_addr;
  assign image_addr = (hcount_in - x_in) + ((vcount_in - y_in) * WIDTH);

  logic in_sprite;
  assign in_sprite = ((hcount_in >= x_in && hcount_in < (x_in + WIDTH)) &&
                      (vcount_in >= y_in && vcount_in < (y_in + HEIGHT)));

  xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(1),                       // Specify RAM data width
    .RAM_DEPTH(WIDTH * HEIGHT),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(mute.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) pos_to_color_addr (
    .addra(image_addr),     // Address bus, width determined from RAM_DEPTH
    .dina(8'b0),       // RAM input data, width determined from RAM_WIDTH
    .clka(pixel_clk_in),       // Clock
    .wea(1'b0),         // Write enable
    .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(1'b1),   // Output register enable
    .douta(COLOR_ADDR)      // RAM output data, width determined from RAM_WIDTH
  );


  // Modify the line below to use your BRAMs!
  assign COLOR = COLOR_ADDR == 0 ? (bckrnd ? 12'hf00 : white) : 0;
  assign pixel_out = in_sprite ? COLOR : white;
endmodule

module effects_sprite #(
  parameter WIDTH=150, HEIGHT=60) (
  input wire pixel_clk_in,
  input wire rst_in,
  input wire [10:0] x_in, hcount_in,
  input wire [9:0]  y_in, vcount_in,
  input wire bckrnd,
  
  output logic [11:0] pixel_out);

  logic [11:0] COLOR;
  logic COLOR_ADDR;

  parameter white = 12'hfff;

  // calculate rom address
  logic [$clog2(WIDTH*HEIGHT)-1:0] image_addr;
  assign image_addr = (hcount_in - x_in) + ((vcount_in - y_in) * WIDTH);

  logic in_sprite;
  assign in_sprite = ((hcount_in >= x_in && hcount_in < (x_in + WIDTH)) &&
                      (vcount_in >= y_in && vcount_in < (y_in + HEIGHT)));

  xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(1),                       // Specify RAM data width
    .RAM_DEPTH(WIDTH * HEIGHT),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(effects.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) pos_to_color_addr (
    .addra(image_addr),     // Address bus, width determined from RAM_DEPTH
    .dina(8'b0),       // RAM input data, width determined from RAM_WIDTH
    .clka(pixel_clk_in),       // Clock
    .wea(1'b0),         // Write enable
    .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(1'b1),   // Output register enable
    .douta(COLOR_ADDR)      // RAM output data, width determined from RAM_WIDTH
  );


  // Modify the line below to use your BRAMs!
  assign COLOR = COLOR_ADDR == 0 ? (bckrnd ? 12'h0f0 : 12'hf00) : 0;
  assign pixel_out = in_sprite ? COLOR : white;
endmodule

module delay_sprite #(
  parameter WIDTH=150, HEIGHT=60) (
  input wire pixel_clk_in,
  input wire rst_in,
  input wire [10:0] x_in, hcount_in,
  input wire [9:0]  y_in, vcount_in,
  input wire bckrnd,
  
  output logic [11:0] pixel_out);

  logic [11:0] COLOR;
  logic COLOR_ADDR;

  parameter white = 12'hfff;

  // calculate rom address
  logic [$clog2(WIDTH*HEIGHT)-1:0] image_addr;
  assign image_addr = (hcount_in - x_in) + ((vcount_in - y_in) * WIDTH);

  logic in_sprite;
  assign in_sprite = ((hcount_in >= x_in && hcount_in < (x_in + WIDTH)) &&
                      (vcount_in >= y_in && vcount_in < (y_in + HEIGHT)));

  xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(1),                       // Specify RAM data width
    .RAM_DEPTH(WIDTH * HEIGHT),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(delay.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) pos_to_color_addr (
    .addra(image_addr),     // Address bus, width determined from RAM_DEPTH
    .dina(8'b0),       // RAM input data, width determined from RAM_WIDTH
    .clka(pixel_clk_in),       // Clock
    .wea(1'b0),         // Write enable
    .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(1'b1),   // Output register enable
    .douta(COLOR_ADDR)      // RAM output data, width determined from RAM_WIDTH
  );


  // Modify the line below to use your BRAMs!
  assign COLOR = COLOR_ADDR == 0 ? (bckrnd ? 12'h0f0 : 12'hf00) : 0;
  assign pixel_out = in_sprite ? COLOR : white;
endmodule


module echo_sprite #(
  parameter WIDTH=150, HEIGHT=60) (
  input wire pixel_clk_in,
  input wire rst_in,
  input wire [10:0] x_in, hcount_in,
  input wire [9:0]  y_in, vcount_in,
  input wire bckrnd,
  
  output logic [11:0] pixel_out);

  logic [11:0] COLOR;
  logic COLOR_ADDR;

  parameter white = 12'hfff;

  // calculate rom address
  logic [$clog2(WIDTH*HEIGHT)-1:0] image_addr;
  assign image_addr = (hcount_in - x_in) + ((vcount_in - y_in) * WIDTH);

  logic in_sprite;
  assign in_sprite = ((hcount_in >= x_in && hcount_in < (x_in + WIDTH)) &&
                      (vcount_in >= y_in && vcount_in < (y_in + HEIGHT)));

  xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(1),                       // Specify RAM data width
    .RAM_DEPTH(WIDTH * HEIGHT),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(echo.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) pos_to_color_addr (
    .addra(image_addr),     // Address bus, width determined from RAM_DEPTH
    .dina(8'b0),       // RAM input data, width determined from RAM_WIDTH
    .clka(pixel_clk_in),       // Clock
    .wea(1'b0),         // Write enable
    .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(1'b1),   // Output register enable
    .douta(COLOR_ADDR)      // RAM output data, width determined from RAM_WIDTH
  );


  // Modify the line below to use your BRAMs!
  assign COLOR = COLOR_ADDR == 0 ? (bckrnd ? 12'h0f0 : 12'hf00) : 0;
  assign pixel_out = in_sprite ? COLOR : white;
endmodule

module chorus_sprite #(
  parameter WIDTH=150, HEIGHT=60) (
  input wire pixel_clk_in,
  input wire rst_in,
  input wire [10:0] x_in, hcount_in,
  input wire [9:0]  y_in, vcount_in,
  input wire bckrnd,
  
  output logic [11:0] pixel_out);

  logic [11:0] COLOR;
  logic COLOR_ADDR;

  parameter white = 12'hfff;

  // calculate rom address
  logic [$clog2(WIDTH*HEIGHT)-1:0] image_addr;
  assign image_addr = (hcount_in - x_in) + ((vcount_in - y_in) * WIDTH);

  logic in_sprite;
  assign in_sprite = ((hcount_in >= x_in && hcount_in < (x_in + WIDTH)) &&
                      (vcount_in >= y_in && vcount_in < (y_in + HEIGHT)));

  xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(1),                       // Specify RAM data width
    .RAM_DEPTH(WIDTH * HEIGHT),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(chorus.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) pos_to_color_addr (
    .addra(image_addr),     // Address bus, width determined from RAM_DEPTH
    .dina(8'b0),       // RAM input data, width determined from RAM_WIDTH
    .clka(pixel_clk_in),       // Clock
    .wea(1'b0),         // Write enable
    .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(1'b1),   // Output register enable
    .douta(COLOR_ADDR)      // RAM output data, width determined from RAM_WIDTH
  );


  // Modify the line below to use your BRAMs!
  assign COLOR = COLOR_ADDR == 0 ? (bckrnd ? 12'h0f0 : 12'hf00) : 0;
  assign pixel_out = in_sprite ? COLOR : white;
endmodule

module distortion_sprite #(
  parameter WIDTH=150, HEIGHT=60) (
  input wire pixel_clk_in,
  input wire rst_in,
  input wire [10:0] x_in, hcount_in,
  input wire [9:0]  y_in, vcount_in,
  input wire bckrnd,
  
  output logic [11:0] pixel_out);

  logic [11:0] COLOR;
  logic COLOR_ADDR;

  parameter white = 12'hfff;

  // calculate rom address
  logic [$clog2(WIDTH*HEIGHT)-1:0] image_addr;
  assign image_addr = (hcount_in - x_in) + ((vcount_in - y_in) * WIDTH);

  logic in_sprite;
  assign in_sprite = ((hcount_in >= x_in && hcount_in < (x_in + WIDTH)) &&
                      (vcount_in >= y_in && vcount_in < (y_in + HEIGHT)));

  xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(1),                       // Specify RAM data width
    .RAM_DEPTH(WIDTH * HEIGHT),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(distortion.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) pos_to_color_addr (
    .addra(image_addr),     // Address bus, width determined from RAM_DEPTH
    .dina(8'b0),       // RAM input data, width determined from RAM_WIDTH
    .clka(pixel_clk_in),       // Clock
    .wea(1'b0),         // Write enable
    .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(1'b1),   // Output register enable
    .douta(COLOR_ADDR)      // RAM output data, width determined from RAM_WIDTH
  );


  // Modify the line below to use your BRAMs!
  assign COLOR = COLOR_ADDR == 0 ? (bckrnd ? 12'h0f0 : 12'hf00) : 0;
  assign pixel_out = in_sprite ? COLOR : white;
endmodule

module limiter_sprite #(
  parameter WIDTH=150, HEIGHT=60) (
  input wire pixel_clk_in,
  input wire rst_in,
  input wire [10:0] x_in, hcount_in,
  input wire [9:0]  y_in, vcount_in,
  input wire bckrnd,
  
  output logic [11:0] pixel_out);

  logic [11:0] COLOR;
  logic COLOR_ADDR;

  parameter white = 12'hfff;

  // calculate rom address
  logic [$clog2(WIDTH*HEIGHT)-1:0] image_addr;
  assign image_addr = (hcount_in - x_in) + ((vcount_in - y_in) * WIDTH);

  logic in_sprite;
  assign in_sprite = ((hcount_in >= x_in && hcount_in < (x_in + WIDTH)) &&
                      (vcount_in >= y_in && vcount_in < (y_in + HEIGHT)));

  xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(1),                       // Specify RAM data width
    .RAM_DEPTH(WIDTH * HEIGHT),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(limiter.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) pos_to_color_addr (
    .addra(image_addr),     // Address bus, width determined from RAM_DEPTH
    .dina(8'b0),       // RAM input data, width determined from RAM_WIDTH
    .clka(pixel_clk_in),       // Clock
    .wea(1'b0),         // Write enable
    .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(1'b1),   // Output register enable
    .douta(COLOR_ADDR)      // RAM output data, width determined from RAM_WIDTH
  );


  // Modify the line below to use your BRAMs!
  assign COLOR = COLOR_ADDR == 0 ? (bckrnd ? 12'h0f0 : 12'hf00) : 0;
  assign pixel_out = in_sprite ? COLOR : white;
endmodule



`default_nettype none

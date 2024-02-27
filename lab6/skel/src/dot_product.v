// Implement a vector dot product of a and b
// using a single-port SRAM of 5-bit address width, 16-bit data width

module dot_product #(
  localparam ADDR_WIDTH = 5,
  localparam WIDTH = 32
) (
  input clk,
  input rst,

  input [ADDR_WIDTH:0] len,

  // input vector a
  input [WIDTH-1:0] a_data,
  input a_valid,
  output reg a_ready,

  // input vector b
  input [WIDTH-1:0] b_data,
  input b_valid,
  output reg b_ready,

  // dot product result c
  output [WIDTH-1:0] c_data,
  output reg c_valid,
  input c_ready
);

localparam STATE_READ = 2'd0;
localparam STATE_CALC_LOAD_A = 2'd1;
localparam STATE_CALC_LOAD_B = 2'd2;
localparam STATE_CALC_DONE = 2'd3;

wire a_fire, b_fire, c_fire;
assign a_fire = a_valid && a_ready;
assign b_fire = b_valid && b_ready;
assign c_fire = c_valid && c_ready;

reg we;
wire [3:0] wmask = 4'b1111;
reg [ADDR_WIDTH:0] addr;
reg [WIDTH-1:0] din;
wire [WIDTH-1:0] dout;

sram22_64x32m4w8 sram (
  .clk(clk),
  .we(we),
  .wmask(wmask),
  .addr(addr),
  .din(din),
  .dout(dout)
);

// TODO: fill in the rest of this module.

endmodule

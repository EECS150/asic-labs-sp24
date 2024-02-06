`include "/home/ff/eecs151/verilog_lib/EECS151.v"

module divider #(
    WIDTH = 4
) (
  input clk,

  input start,
  output done,

  input [WIDTH-1:0] dividend,
  input [WIDTH-1:0] divisor,
  output [WIDTH-1:0] quotient,
  output [WIDTH-1:0] remainder
);

  // Feel free to change the code as long as your final code implements a divider
  // Check the algorithm described in the slides (URL in the spec)
  // Pay attention to the block diagram(s)

  assign quotient  = 0;
  assign remainder = 0;
  assign done = 0;

endmodule

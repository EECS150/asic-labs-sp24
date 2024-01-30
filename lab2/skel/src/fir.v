module fir #(
    parameter NUM_INPUT_BITS = 4,
    parameter NUM_OUTPUT_BITS = 16
)  (
    input clk,
    input rst,
    input signed [NUM_INPUT_BITS-1:0] In,
    output signed [NUM_OUTPUT_BITS-1:0] Out );


wire signed [NUM_INPUT_BITS-1:0] delay_chain0, delay_chain1, delay_chain2, delay_chain3, delay_chain4;

REGISTER_R #(.N(NUM_INPUT_BITS)) delay_step0 (.clk(clk), .rst(rst), .d(In), .q(delay_chain0));
REGISTER_R #(.N(NUM_INPUT_BITS)) delay_step1 (.clk(clk), .rst(rst), .d(delay_chain0), .q(delay_chain1));
REGISTER_R #(.N(NUM_INPUT_BITS)) delay_step2 (.clk(clk), .rst(rst), .d(delay_chain1), .q(delay_chain2));
REGISTER_R #(.N(NUM_INPUT_BITS)) delay_step3 (.clk(clk), .rst(rst), .d(delay_chain2), .q(delay_chain3));
REGISTER_R #(.N(NUM_INPUT_BITS)) delay_step4 (.clk(clk), .rst(rst), .d(delay_chain3), .q(delay_chain4));

addertree #(.NUM_INPUT_BITS(NUM_INPUT_BITS), .NUM_OUTPUT_BITS(NUM_OUTPUT_BITS)) add0 (
    .in0(delay_chain0), 
    .in1(delay_chain1), 
    .in2(delay_chain2), 
    .in3(delay_chain3), 
    .in4(delay_chain4), 
    .Out(Out)
);


endmodule

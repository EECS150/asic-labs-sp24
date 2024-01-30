 module addertree #(
    parameter NUM_INPUT_BITS = 4, 
    parameter NUM_OUTPUT_BITS = 16
) (
    input signed [NUM_INPUT_BITS-1:0] in0, 
    input signed [NUM_INPUT_BITS-1:0] in1, 
    input signed [NUM_INPUT_BITS-1:0] in2, 
    input signed [NUM_INPUT_BITS-1:0] in3, 
    input signed [NUM_INPUT_BITS-1:0] in4, 
    output signed [NUM_OUTPUT_BITS-1:0] Out );


assign Out = in0 + in4 + ( in1 << 2) + (in3 << 2) + (in2 << 4) ;

endmodule

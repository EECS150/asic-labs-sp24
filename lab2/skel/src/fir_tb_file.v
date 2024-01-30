`timescale 1 ns /  100 ps

module fir_tb_file();

wire signed [3:0] In;
wire signed [15:0] Out;
reg clk;

reg [4:0] index_counter;
initial index_counter = 0;
wire signed [15:0] Out_correct;
reg signed [15:0] Out_correct_array [25:0];
reg signed [3:0] input_array [25:0];

initial clk = 0;
always #(`CLOCK_PERIOD/2) clk <= ~clk;

fir dut ( .In(In), .clk(clk), .Out(Out) );



initial begin
$vcdpluson;
 repeat (26) @(negedge clk);
$vcdplusoff;
$finish;

end

initial begin
    $readmemb("../../src/data_b.txt", Out_correct_array);
    $readmemb("../../src/input.txt", input_array);
end
assign Out_correct = Out_correct_array[index_counter];
assign In = input_array[index_counter];
always @(negedge clk) begin
    $display($time, ": Out should be %d, got %d", Out_correct, Out);
    index_counter <= index_counter + 1;
end

endmodule

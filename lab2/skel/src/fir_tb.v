`timescale 1 ns /  1 ps

module fir_tb();

reg signed [3:0] In;
wire signed [15:0] Out;
reg clk, rst;

integer i=0;

initial clk = 0;
always #(`CLOCK_PERIOD/2) clk <= ~clk;

fir dut ( .In(In), .clk(clk), .Out(Out), .rst(rst) );
initial begin

$vcdpluson;
 rst <= 1'b1;
 @(negedge clk) rst <= 1'b0;
  In <= 4'd0;
 @(negedge clk)  In<= 4'd1;
 @(negedge clk)  In<= 4'd0;
 repeat(5) @(negedge clk) ;
 @(negedge clk)  In<= 4'hF;
 repeat (5) @(negedge clk) ;
 @(negedge clk)  In<= 4'd4;
 @(negedge clk)  In<= 4'd16;
 @(negedge clk)  In<= 4'd4;
 @(negedge clk)  In<= 4'd1;
 @(negedge clk)  In<= 4'd0;
 @(negedge clk)  In<= 4'd8;
 @(negedge clk)  In<= 4'd9;
 @(negedge clk)  In<= 4'd10;
 @(negedge clk)  In<= 4'd11;
 @(negedge clk)  In<= 4'd12;
 @(negedge clk)  In<= 4'd13;
 @(negedge clk)  In<= 4'd14;
 @(negedge clk)  In<= 4'd15;
$vcdplusoff;
$finish;

end

reg [4:0] index_counter;
initial index_counter = -1;
wire signed [15:0] Out_correct;
wire signed [25:0] [15:0] Out_correct_array;
assign Out_correct_array[0] = 0;
assign Out_correct_array[1] = 0;
assign Out_correct_array[2] = 1;
assign Out_correct_array[3] = 4;
assign Out_correct_array[4] = 16;
assign Out_correct_array[5] = 4;
assign Out_correct_array[6] = 1;
assign Out_correct_array[7] = 0;
assign Out_correct_array[8] = 0;
assign Out_correct_array[9] = -1;
assign Out_correct_array[10] = -5;
assign Out_correct_array[11] = -21;
assign Out_correct_array[12] = -25;
assign Out_correct_array[13] = -26;
assign Out_correct_array[14] = -26;
assign Out_correct_array[15] = -21;
assign Out_correct_array[16] = -5;
assign Out_correct_array[17] = 63;
assign Out_correct_array[18] = 32;
assign Out_correct_array[19] = 72;
assign Out_correct_array[20] = 24;
assign Out_correct_array[21] = -31;
assign Out_correct_array[22] = -161;
assign Out_correct_array[23] = -173;
assign Out_correct_array[24] = -156;
assign Out_correct_array[25] = -130;
assign Out_correct = Out_correct_array[index_counter];
always @(negedge clk) begin
        $display($time, ": Out should be %d, got %d", Out_correct, Out);
        index_counter <= index_counter + 1;
end

endmodule

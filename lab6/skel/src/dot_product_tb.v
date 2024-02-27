
module dot_product_tb;
  localparam integer NUM_TESTS = 3;
  localparam integer WIDTH = 16;
  localparam integer SIZE  = 16;

  reg clk = 0;
  reg rst;
  always #(`CLOCK_PERIOD / 2) clk = ~clk;

  // Test vectors for a and b
  reg [WIDTH-1:0] tv_a [NUM_TESTS-1:0][0:SIZE-1];
  reg [WIDTH-1:0] tv_b [NUM_TESTS-1:0][0:SIZE-1];
  // We will compare the "software" version of the dot product with
  // the hardware implementation
  reg [WIDTH-1:0] sw_dot_product_result [NUM_TESTS-1:0];
  integer i;
  integer j;
  initial begin
    #0;
    for (i = 0; i < NUM_TESTS; i = i + 1) begin
      sw_dot_product_result[i] = 0;
    end

    // Test1
    tv_a[0]  = {0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30};
    tv_b[0]  = {1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31};
    // Test2
    tv_a[1]  = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16};
    tv_b[1]  = {1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0};
    // Test3
    tv_a[2]  = {5,14,6,2,1,10,7,1,2,5,9,0,4,2,1,0};
    tv_b[2]  = {0,12,17,0,16,7,8,3,5,11,0,1,0,6,2,13};


    @(negedge clk);
    for (j = 0; j < NUM_TESTS; j = j + 1) begin
      for (i = 0; i < SIZE; i = i + 1) begin
        sw_dot_product_result[j] = sw_dot_product_result[j] + tv_a[j][i] * tv_b[j][i];
      end
    end
  end

  reg [WIDTH-1:0] a_data, b_data;
  reg a_valid, b_valid;
  wire a_ready, b_ready;

  wire [WIDTH-1:0] c_data;
  wire c_valid;
  reg c_ready;

  reg [5:0] vector_size;

  dot_product #(.WIDTH(WIDTH)) dut (
    .clk(clk),
    .rst(rst),

    .len(vector_size),

    .a_data(a_data),
    .a_valid(a_valid),
    .a_ready(a_ready),

    .b_data(b_data),
    .b_valid(b_valid),
    .b_ready(b_ready),

    .c_data(c_data),
    .c_valid(c_valid),
    .c_ready(c_ready)
  );

  // Debug info
  // always @(posedge clk) begin
  //   $display("time %d",
  //     $time
  //   );
  // end

  // Count the number of cycles to evaluate performance
  reg [31:0] num_cycles = 0;
  always @(posedge clk) begin
    if (rst == 1'b0) begin
      num_cycles <= num_cycles + 1;
    end else begin
      num_cycles <= 0;
    end
  end

  integer t;
  integer k;
  reg fail = 1'b0;

  // Provide stimulus for DUT
  initial begin
    #0;
    $vcdpluson;
    $vcdplusmemon;

    rst = 1;
    
    vector_size = SIZE;
    a_data = 0;
    b_data = 0;
    a_valid = 0;
    b_valid = 0;

    // Hold reset signal for some time
    repeat (10) @(posedge clk);
    // Note: we should reset on the negedge clk to prevent
    // race behavior (caught by +evalorder in VCS)
    @(negedge clk);
    rst = 0;

    for (t = 0; t < NUM_TESTS; t = t + 1) begin
      $display("Begin Test %d:", t);
      // Write test data into SRAMs of DUT (in various orders)
      case (t)
        // All A before B
        0: begin
          for (k = 0; k < vector_size; k = k + 1) begin
            // We should adopt a practice of changing signals
            // on the negedge clk
            @(negedge clk);
            a_data = tv_a[t][k];
            a_valid = 1'b1;
          end

          @(negedge clk);
          a_valid = 1'b0;

          for (k = 0; k < vector_size; k = k + 1) begin
            @(negedge clk);
            b_data = tv_b[t][k];
            b_valid = 1'b1;
          end

          @(negedge clk);
          b_valid = 1'b0;
        end 

        // All B before A
        1: begin
          for (k = 0; k < vector_size; k = k + 1) begin
            @(negedge clk);
            b_data = tv_b[t][k];
            b_valid = 1'b1;
          end
          
          @(negedge clk);
          b_valid = 1'b0;

          for (k = 0; k < vector_size; k = k + 1) begin
            @(negedge clk);
            a_data = tv_a[t][k];
            a_valid = 1'b1;
          end

          @(negedge clk);
          a_valid = 1'b0;
        end

        // A, B interspersed
        2: begin
          @(negedge clk);
          for (k = 0; k < vector_size; k = k + 1) begin
            // A
            a_data = tv_a[t][k];
            a_valid = 1'b1;
            @(negedge clk);
            a_valid = 1'b0;
            // B
            b_data = tv_b[t][k];
            b_valid = 1'b1;
            @(negedge clk);
            b_valid = 1'b0;
          end
        end
      endcase

      // Ready to accept output from DUT
      c_ready = 1'b1;

      // Wait until the dp result is valid
      while (c_valid == 1'b0) begin
        @(posedge clk);
      end

      // Check result
      $display("Result: hw=%d, sw=%d", c_data, sw_dot_product_result[t]);
      if (c_data == sw_dot_product_result[t])
        $display("TEST %d PASSED!", t);
      else begin
        $display("TEST %d FAILED!", t);
        fail = 1'b1;
      end

      $display("Number of cycles: %d\n---", num_cycles);
    end

    if (fail == 1'b0)
      $display(">== ALL TESTS PASSED! ==<");
    else
      $display(">== TESTS FAILED! ==<");

    $vcdplusoff;

    $finish();
  end

  // Timeout check
  initial begin
    // Wait for 12_000 ns. Shouldn't be this long
    #12000;
    $display("TIMEOUT");
    $finish();
  end

endmodule

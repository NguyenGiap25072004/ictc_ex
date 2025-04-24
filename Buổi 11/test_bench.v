`timescale 1ns/1ps

module tb_gray_counter;

  parameter CLK_PERIOD = 10; 

  reg clk;
  reg rst_n;
  reg count_en;
  reg count_clr;
  wire [7:0] count;
  wire overflow;

  reg [7:0] expected_gray_count;
  reg [8:0] binary_count_ref; 

  integer pass_count = 0;
  integer fail_count = 0;
  integer test_count = 0;

  counter dut (
      .clk(clk),
      .rst_n(rst_n),
      .count_en(count_en),
      .count_clr(count_clr),
      .count(count),
      .overflow(overflow)
  );

  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  function [7:0] bin2gray (input [7:0] bin);
    bin2gray = bin ^ (bin >> 1);
  endfunction

  task check_count (input [7:0] expected_val, input expected_of);
    test_count = test_count + 1;
    #1; 
    if (count === expected_val && overflow === expected_of) begin
      pass_count = pass_count + 1;
    end else begin
      $display("[TIME %0t] FAILED Check: Count=%h (Exp:%h), Overflow=%b (Exp:%b)", $time, count, expected_val, overflow, expected_of);
      fail_count = fail_count + 1;
    end
  endtask
  
  task check_count_only (input [7:0] expected_val);
    test_count = test_count + 1;
    #1; 
    if (count === expected_val) begin
      pass_count = pass_count + 1;
    end else begin
      $display("[TIME %0t] FAILED Check: Count=%h (Exp:%h)", $time, count, expected_val);
      fail_count = fail_count + 1;
    end
  endtask

  initial begin
    integer i;
    reg found_hff;
    reg overflow_at_hff;
    reg overflow_elsewhere;

    $display("--------------------------------------------------");
    $display("Starting Gray Counter Testbench Simulation");
    $display("--------------------------------------------------");

    // ---- 1. Initialization and Asynchronous Reset Test (VPlan ID 1) ----
    $display("\n[TEST] Asynchronous Reset Test");
    rst_n = 1'b1;    
    count_en = 1'b0;
    count_clr = 1'b0;
    binary_count_ref = 9'b0;
    expected_gray_count = bin2gray(binary_count_ref[7:0]);
    #(CLK_PERIOD * 2); 

    count_en = 1'b1; 
    #(CLK_PERIOD * 5.2); 
    $display("[TIME %0t] Asserting rst_n low asynchronously...", $time);
    rst_n = 1'b0;   
    #1; 
    test_count = test_count+1; 
    if (count === 8'h00 && overflow === 1'b0) begin
        $display("[TIME %0t] PASSED: Async reset check. Count = %h, Overflow = %b", $time, count, overflow);
        pass_count = pass_count + 1;
    end else begin
        $display("[TIME %0t] FAILED: Async reset check. Count = %h (Exp: 00), Overflow = %b (Exp: 0)", $time, count, overflow);
        fail_count = fail_count + 1;
    end

    #(CLK_PERIOD * 1.5); 
    $display("[TIME %0t] De-asserting rst_n high...", $time);
    rst_n = 1'b1;    
    count_en = 1'b0; 
    binary_count_ref = 9'b0;
    expected_gray_count = bin2gray(binary_count_ref[7:0]);

    // ---- 2. Initial Value Check (VPlan ID 2) ----
    $display("\n[TEST] Initial Value Check (count_en = 0)");
    @(posedge clk);
    $display("[Check] Initial Value after reset release");
    check_count(expected_gray_count, 1'b0);
    @(posedge clk);
    $display("[Check] Hold initial value with count_en=0");
    check_count(expected_gray_count, 1'b0);

    // ---- 3. Enable Counting (VPlan ID 3) ----
    $display("\n[TEST] Enable Counting Test (count_en = 1)");
    count_en = 1'b1;
    count_clr = 1'b0;
    repeat (5) begin
      @(posedge clk);
      binary_count_ref = binary_count_ref + 1;
      expected_gray_count = bin2gray(binary_count_ref[7:0]);
      $display("[Check] Counting Enabled: Step %d", binary_count_ref);
      check_count_only(expected_gray_count);
    end

    // ---- 4. Disable Counting (VPlan ID 4) ----
    $display("\n[TEST] Disable Counting Test (count_en = 0)");
    count_en = 1'b0;
    expected_gray_count = count; 
    repeat (3) begin
      @(posedge clk);
      $display("[Check] Counting Disabled - Hold Value");
      check_count_only(expected_gray_count);
    end

    // ---- 5. Resume Counting (VPlan ID 5) ----
    $display("\n[TEST] Resume Counting Test (count_en = 1)");
    count_en = 1'b1;
    repeat (3) begin
      @(posedge clk);
      binary_count_ref = binary_count_ref + 1; 
      expected_gray_count = bin2gray(binary_count_ref[7:0]);
      $display("[Check] Counting Resumed: Step %d", binary_count_ref);
      check_count_only(expected_gray_count);
    end

    // ---- 6 & 7. Synchronous Clear Test & Priority (VPlan ID 6, 7) ----
    $display("\n[TEST] Synchronous Clear Test (count_clr = 1)");
    count_clr = 1'b1;
    count_en = 1'b1; 
    binary_count_ref = 9'b0; 
    expected_gray_count = bin2gray(binary_count_ref[7:0]);
    @(posedge clk);
    $display("[Check] Sync Clear (en=1)"); 
    check_count(expected_gray_count, 1'b0);

    count_clr = 1'b0; 
    count_en = 1'b0; 
    @(posedge clk);
    $display("[Check] After Clear, en=0"); 
    check_count(expected_gray_count, 1'b0);

    // ---- 8 & 9. Full Sequence and Standard Overflow (VPlan ID 8, 9) ----
    $display("\n[TEST] Full Sequence and Standard Overflow Test");
    rst_n = 1'b0; #5; rst_n = 1'b1; 
    count_en = 1'b1;
    count_clr = 1'b0;
    binary_count_ref = 9'b0;
    expected_gray_count = 8'h00;
    @(posedge clk);
    $display("[Check] Seq: Start at 0");
    check_count_only(expected_gray_count);

    for (i = 0; i < 256; i = i + 1) begin
        @(posedge clk);
        binary_count_ref = binary_count_ref + 1;
        expected_gray_count = bin2gray(binary_count_ref[7:0]);
        if (binary_count_ref == 9'b1_0000_0000) begin 
            $display("[Check] Seq: Check Gray(255)=%h", count); 
            check_count(count, 1'b0); 
        end else if (binary_count_ref == 9'd1) begin 
             $display("[Check] Seq: Check Overflow=1, Count=0 after wrap");
             check_count(expected_gray_count, 1'b1); 
        end else if (binary_count_ref == 9'd2) begin 
             $display("[Check] Seq: Check Overflow=0 after wrap");
             check_count(expected_gray_count, 1'b0); 
        end else begin
            check_count_only(expected_gray_count);
        end
    end

    // ---- 10. Overflow at 8'hFF Check (VPlan ID 10) ----
    $display("\n[TEST] Overflow at 8'hFF Check (Slide Spec)");
    rst_n = 1'b0; #5; rst_n = 1'b1; 
    count_en = 1'b1;
    count_clr = 1'b0;
    binary_count_ref = 9'b0;
    found_hff = 0; 
    overflow_at_hff = 0;
    overflow_elsewhere = 0;
    @(posedge clk); 

    for (i = 0; i < 260; i = i + 1) begin 
      @(posedge clk);
      binary_count_ref = binary_count_ref + 1; // Internal reference
      #1; 
      if (count === 8'hFF) begin
        found_hff = 1;
        if (overflow === 1'b1) begin
            overflow_at_hff = 1;
        end
        $display("[TIME %0t] INFO: Reached count = 8'hFF, Overflow = %b", $time, overflow);
      end else begin
        if (overflow === 1'b1 && binary_count_ref != 9'd1) begin
           overflow_elsewhere = 1;
           $display("[TIME %0t] INFO: Overflow high when count = %h (not FF, not wrap)", $time, count);
        end
      end
    end

    test_count = test_count + 1; 
    if (found_hff && overflow_at_hff && !overflow_elsewhere) begin
        $display("[TIME %0t] PASSED?: Overflow at 8'hFF check (as per slide). Overflow asserted ONLY at count=8'hFF.", $time);
        pass_count = pass_count + 1;
    end else if (!found_hff) begin
         $display("[TIME %0t] FAILED (vs Slide Spec): Overflow at 8'hFF check. Count never reached 8'hFF.", $time);
         fail_count = fail_count + 1;
    end else if (!overflow_at_hff) begin
         $display("[TIME %0t] FAILED (vs Slide Spec): Overflow at 8'hFF check. Overflow was NOT asserted when count was 8'hFF.", $time);
         fail_count = fail_count + 1;
    end else if (overflow_elsewhere) begin
         $display("[TIME %0t] FAILED (vs Slide Spec): Overflow at 8'hFF check. Overflow was asserted at times other than count=8'hFF (and standard wrap).", $time);
         fail_count = fail_count + 1;
    end else begin
         $display("[TIME %0t] FAILED (vs Slide Spec): Overflow at 8'hFF check. Unexpected condition.", $time);
         fail_count = fail_count + 1;
    end


    $display("\n--------------------------------------------------");
    $display("Simulation Finished!");
    $display("Total Checks Attempted: %0d", test_count);
    $display("Passed Checks: %0d", pass_count);
    $display("Failed Checks: %0d", fail_count);
    $display("--------------------------------------------------");

    if (fail_count == 0) begin
        $display("****** PASSED ******");
    end else begin
        $display("###### FAILED ######");
    end

    $finish; 
  end

endmodule

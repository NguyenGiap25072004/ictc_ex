`timescale 1ns/1ps

module test_bench;

  parameter CLK_PERIOD = 20; 


  reg clk;
  reg rst_n;
  reg valid;
  reg [7:0] data_in;
  reg [1:0] parity_mode;
  wire txd;


  integer pass_count = 0;
  integer fail_count = 0;
  integer test_count = 0;
  reg test_failed;


  top dut (
      .CLK(clk),
      .RST_N(rst_n),
      .VALID(valid),
      .DATA_IN(data_in),
      .PARITY_MODE(parity_mode),
      .TXD(txd)
  );


  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  // --- Helper Functions/Tasks ---

  // Calculates expected parity bit (mode: 1=odd, 0=even)
  function calculate_parity_bit(input [7:0] data, input mode);
    begin 
      reg parity_interim;
      parity_interim = ^data;
      if (mode == 1) calculate_parity_bit = ~parity_interim;
      else calculate_parity_bit = parity_interim;
    end 
  endfunction

  // Applies stimulus for one cycle VALID assertion
  task apply_stimulus(input [7:0] d_in, input vld, input [1:0] p_mode);
    begin 
      @(posedge clk);
      data_in <= d_in;
      valid <= vld;
      parity_mode <= p_mode;
      if (vld) @(posedge clk) valid <= 1'b0;
    end 
  endtask

  // Performs a transmission check
  task run_and_check_transmission( input [7:0] current_data,
                                   input [1:0] current_parity_mode );
    begin 
      
      reg expected_parity;
      integer expected_bit_count;
      reg [8:0] received_data; 
      integer bit_idx;       
      reg expected_bit;       

      
      test_count = test_count + 1;
      test_failed = 1'b0;

      case (current_parity_mode)
        2'b00, 2'b11: expected_bit_count = 8;
        2'b01: begin expected_bit_count = 9; expected_parity = calculate_parity_bit(current_data, 1); end // Odd
        2'b10: begin expected_bit_count = 9; expected_parity = calculate_parity_bit(current_data, 0); end // Even
        default: begin expected_bit_count = 8; $display("ERROR: Invalid PARITY_MODE %b", current_parity_mode); end
      endcase

      apply_stimulus(current_data, 1'b1, current_parity_mode);

      @(posedge clk); 

      // --- Monitor TXD Output ---
      begin 
          
          for (bit_idx = 0; bit_idx < expected_bit_count; bit_idx = bit_idx + 1) begin
              #1;
              received_data[bit_idx] = txd;
              @(posedge clk);
          end

          
          for (bit_idx = 0; bit_idx < expected_bit_count; bit_idx = bit_idx + 1) begin
              if (bit_idx < 8) begin
                  expected_bit = current_data[bit_idx];
              end else begin
                  expected_bit = expected_parity;
              end

              if (received_data[bit_idx] !== expected_bit) begin
                  $display("[TIME %0t] FAILED: Bit Mismatch at index %d. Got %b, Expected %b", $time, bit_idx, received_data[bit_idx], expected_bit);
                  test_failed = 1'b1;
              end
          end

          // Báo cáo kết quả
          if (!test_failed) begin
             pass_count = pass_count + 1;
          end else begin
             $display("[TIME %0t] FAILED: Check for DATA=0x%h, MODE=%b", $time, current_data, current_parity_mode);
             fail_count = fail_count + 1;
          end
      end 
    end 
  endtask


  // --- Main Test Sequence ---
  initial begin

    integer j;
    reg [7:0] test_data;

    $display("--------------------------------------------------");
    $display("Starting Homework 2 Testbench Simulation");
    $display("--------------------------------------------------");

    // 1. Reset Sequence
    rst_n = 1'b0;
    valid = 1'b0;
    data_in = 8'h00;
    parity_mode = 2'b00;
    # (CLK_PERIOD * 5);
    rst_n = 1'b1;
    #1;

    // 2. Check Idle State
    $display("\n[TEST] IDLE State Check");
    test_count = test_count + 1;
    if (txd === 1'b1) begin pass_count=pass_count+1; end
    else begin $display("[TIME %0t] FAILED: IDLE State Check (Post-Reset). TXD=%b (Exp: 1)", $time, txd); fail_count=fail_count+1; end
    #(CLK_PERIOD * 2);

    // 3. Run Transmission Tests based on VPlan
    $display("\n[Run VPlan 3,6: Data 55 / No Parity 00]"); run_and_check_transmission(8'h55, 2'b00);
    $display("\n[Run VPlan 6: Data AA / No Parity 00]"); run_and_check_transmission(8'hAA, 2'b00);
    $display("\n[Run VPlan 7: Data F0 / No Parity 11]"); run_and_check_transmission(8'hF0, 2'b11);
    $display("\n[Run VPlan 7: Data 0F / No Parity 11]"); run_and_check_transmission(8'h0F, 2'b11);
    $display("\n[Run VPlan 5: Bit Order Check (A1)]"); run_and_check_transmission(8'hA1, 2'b00);

    $display("\n[Run VPlan 9: Data A3 / Odd Parity]"); run_and_check_transmission(8'hA3, 2'b01);
    $display("\n[Run VPlan 8: Data 55 / Odd Parity]"); run_and_check_transmission(8'h55, 2'b01);

    $display("\n[Run VPlan 10: Data C3 / Even Parity]"); run_and_check_transmission(8'hC3, 2'b10);
    $display("\n[Run VPlan 11: Data B4 / Even Parity]"); run_and_check_transmission(8'hB4, 2'b10);

    // Edge Cases
    $display("\n[Run Edge Case: Data 00 / Odd Parity]"); run_and_check_transmission(8'h00, 2'b01);
    $display("\n[Run Edge Case: Data 00 / Even Parity]"); run_and_check_transmission(8'h00, 2'b10);
    $display("\n[Run Edge Case: Data FF / Odd Parity]"); run_and_check_transmission(8'hFF, 2'b01);
    $display("\n[Run Edge Case: Data FF / Even Parity]"); run_and_check_transmission(8'hFF, 2'b10);

    // --- Complex Scenarios ---

    // Back-to-Back Test (VPlan 13)
    $display("\n[TEST] Back-to-Back Transmission");
    $display("\n[Run B2B - Packet 1]"); run_and_check_transmission(8'h11, 2'b00);
    @(posedge clk); 
    $display("\n[Run B2B - Packet 2]"); run_and_check_transmission(8'h22, 2'b01);

    // Reset During Transmission Test (VPlan 15)
    $display("\n[TEST] Reset During Transmission");
    apply_stimulus(8'hCC, 1'b1, 2'b10);
    @(posedge clk);
    repeat (4) @(posedge clk);
    $display("[TIME %0t] Asserting RST_N during transmission...", $time);
    rst_n <= 1'b0;
    #1;
    test_count=test_count+1;
    if (txd === 1'b1) begin $display("[TIME %0t] PASSED: Reset Mid-Transmit. TXD went idle.", $time); pass_count=pass_count+1; end
    else begin $display("[TIME %0t] FAILED: Reset Mid-Transmit. TXD=%b (Exp: 1)", $time, txd); fail_count=fail_count+1; end
    #(CLK_PERIOD*2);
    rst_n <= 1'b1;
    @(posedge clk);


    // ---- Final Report ----
    $display("\n--------------------------------------------------");
    $display("Simulation Finished!");
    $display("Total Checks Performed (approx): %0d", test_count);
    $display("Passed Checks: %0d", pass_count);
    $display("Failed Checks: %0d", fail_count);
    $display("--------------------------------------------------");
    if (fail_count == 0) $display("****** ALL CHECKS PASSED ******");
    else $display("###### SOME CHECKS FAILED - Check VPlan for Bugs ######");
    $finish;
  end

endmodule

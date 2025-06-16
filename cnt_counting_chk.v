task run_test();
    reg [31:0] read_val_lo, read_val_hi;
    reg [63:0] count_before, count_after, count_delta;
    integer    wait_cycles;
begin
    wait_cycles = 260;

    $display("\n\n--- Starting Test: Counter Counting (Robust Check) ---");

    // === SCENARIO 1: Test basic counting and TDR0 overflow ===
    $display("[SCENARIO] Testing TDR0 overflow by checking the count delta");

    // 1. Configure timer and read value BEFORE starting
    timer_reg_write(TCR_OFFSET, 0); // Ensure timer is off
    timer_reg_write(TDR0_OFFSET, 32'hFFFF_FFFA);
    timer_reg_write(TDR1_OFFSET, 32'h0);
    
    // Let value settle and read it back
    timer_reg_read(TDR0_OFFSET, read_val_lo);
    timer_reg_read(TDR1_OFFSET, read_val_hi);
    count_before = {read_val_hi, read_val_lo};
    
    // 2. Enable timer and wait for a number of cycles
    timer_reg_write(TCR_OFFSET, 1);
    #(wait_cycles * CLK_PERIOD);

    // 3. Stop timer and read value AFTER
    timer_reg_write(TCR_OFFSET, 0);
    timer_reg_read(TDR0_OFFSET, read_val_lo);
    timer_reg_read(TDR1_OFFSET, read_val_hi);
    count_after = {read_val_hi, read_val_lo};

    // 4. Check if the DIFFERENCE is correct
    // The difference should be very close to wait_cycles. We allow a small margin for APB task latencies.
    count_delta = count_after - count_before;
    if (count_delta >= wait_cycles - 2 && count_delta <= wait_cycles + 2) begin
        $display("[CHECK PASSED] Counter incremented by %0d, which is within the expected margin of %0d", count_delta, wait_cycles);
    end else begin
        $display("**************************************************");
        $display("[CHECK FAILED] Counter increment value is incorrect.");
        $display("    -> Count Before   = %0d", count_before);
        $display("    -> Count After    = %0d", count_after);
        $display("    -> Actual Delta   = %0d", count_delta);
        $display("    -> Expected Delta ~ %0d", wait_cycles);
        $display("**************************************************");
        g_error_count = g_error_count + 1;
    end

    // === SCENARIO 2: Check counter stops when timer_en is 0 ===
    $display("[SCENARIO] Check counter stops when timer_en is 0");
    // count_after from previous test is our new 'before' value
    count_before = count_after;

    #(wait_cycles * CLK_PERIOD); // Wait again while timer is disabled

    timer_reg_read(TDR0_OFFSET, read_val_lo);
    timer_reg_read(TDR1_OFFSET, read_val_hi);
    count_after = {read_val_hi, read_val_lo};

    check_value(count_after, count_before, "Check counter value did not change when disabled");
    
    // Final result
    if (g_error_count == 0) $display("--- TEST PASSED ---");
    else $display("--- TEST FAILED ---");
end
endtask

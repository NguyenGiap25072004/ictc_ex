task run_test();
    reg [31:0] read_val_lo, read_val_hi;
    reg [63:0] count_before, count_after, count_delta, expected_delta;
    integer    num_cycles;
    reg [31:0] tcr_val;
    integer    idx;
begin
    $display("\n\n--- Starting Test: Counter Control with div_val (Robust Check) ---");

    for (idx = 0; idx < 9; idx = idx + 1) begin
        num_cycles = 512;
        
        $display("[SCENARIO] Testing with div_val = %0d for %0d cycles", idx, num_cycles);
        
        // 1. Reset and read counter value BEFORE starting
        timer_reg_write(TCR_OFFSET, 0); // Ensure timer is off
        timer_reg_write(TDR0_OFFSET, 0);
        timer_reg_write(TDR1_OFFSET, 0);
        timer_reg_read(TDR0_OFFSET, read_val_lo);
        timer_reg_read(TDR1_OFFSET, read_val_hi);
        count_before = {read_val_hi, read_val_lo};
        
        // 2. Enable timer with division
        tcr_val = (idx << 8) | (1 << 1) | (1 << 0); // div_val, div_en, timer_en
        timer_reg_write(TCR_OFFSET, tcr_val);

        // 3. Wait for N cycles
        #(num_cycles * CLK_PERIOD);

        // 4. Stop timer and read counter value AFTER
        timer_reg_write(TCR_OFFSET, 0);
        timer_reg_read(TDR0_OFFSET, read_val_lo);
        timer_reg_read(TDR1_OFFSET, read_val_hi);
        count_after = {read_val_hi, read_val_lo};

        // 5. Check the DIFFERENCE
        count_delta = count_after - count_before;
        // Expected ticks = total cycles / division_factor. Allow for a small +/- 2 margin due to APB latency.
        expected_delta = num_cycles / (1 << idx); 
        
        if (count_delta >= expected_delta - 2 && count_delta <= expected_delta + 2) begin
             $display("[CHECK PASSED] @ %0t : div_val=%0d, count delta is within margin (Actual: %0d, Expected: ~%0d)", $time, idx, count_delta, expected_delta);
        end else begin
             $display("**************************************************");
             $display("[CHECK FAILED] @ %0t : div_val=%0d, count delta is out of margin", $time, idx);
             $display("    -> Count Before = %0d", count_before);
             $display("    -> Count After  = %0d", count_after);
             $display("    -> Delta        = %0d", count_delta);
             $display("    -> Expected ~   = %0d", expected_delta);
             $display("**************************************************");
             g_error_count = g_error_count + 1;
        end
    end

    if (g_error_count == 0) $display("--- TEST PASSED ---");
    else $display("--- TEST FAILED ---");
end
endtask

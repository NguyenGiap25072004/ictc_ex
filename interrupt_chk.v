task run_test();
    reg [31:0] read_val;
    $display("\n\n--- Starting Test: Interrupt Generation and Clearing ---");
    
    // Setup for interrupt
    timer_reg_write(TDR0_OFFSET, 0);
    timer_reg_write(TDR1_OFFSET, 0);
    timer_reg_write(TCMP0_OFFSET, 100); // Interrupt when counter reaches 100
    timer_reg_write(TCMP1_OFFSET, 0);
    timer_reg_write(TIER_OFFSET, 1);    // Enable interrupt
    timer_reg_write(TCR_OFFSET, 1);     // Enable timer

    wait(tim_int === 1'b1);
    $display("[CHECK PASSED] @ %0t: Interrupt signal was asserted.", $time);

    // Check status register
    timer_reg_read(TISR_OFFSET, read_val);
    check_value(read_val, 1, "Check TISR status bit is set after interrupt");
    
    // Disable interrupt and check mask
    timer_reg_write(TIER_OFFSET, 0);
    #1;
    if (tim_int === 1'b0) $display("[CHECK PASSED] @ %0t: Interrupt signal masked (de-asserted).", $time);
    else begin $display("[CHECK FAILED] @ %0t: Interrupt not masked.", $time); g_error_count = g_error_count+1; end

    // Clear interrupt status
    timer_reg_write(TISR_OFFSET, 1); // Write-1-to-Clear
    timer_reg_read(TISR_OFFSET, read_val);
    check_value(read_val, 0, "Check TISR status bit is cleared by W1C");
    
    if (g_error_count == 0) $display("--- TEST PASSED ---");
    else $display("--- TEST FAILED ---");
endtask
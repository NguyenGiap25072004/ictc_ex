task run_test();
begin // <--- THÊM BEGIN
    reg [31:0] read_val;
    $display("\n\n--- Starting Test: Interrupt Generation and Clearing ---");
    
    timer_reg_write(TDR0_OFFSET, 0);
    timer_reg_write(TDR1_OFFSET, 0);
    timer_reg_write(TCMP0_OFFSET, 100);
    timer_reg_write(TCMP1_OFFSET, 0);
    timer_reg_write(TIER_OFFSET, 1);
    timer_reg_write(TCR_OFFSET, 1);

    wait(tim_int === 1'b1);
    $display("[CHECK PASSED] @ %0t: Interrupt signal was asserted.", $time);

    timer_reg_read(TISR_OFFSET, read_val);
    check_value(read_val, 1, "Check TISR status bit is set after interrupt");
    
    timer_reg_write(TIER_OFFSET, 0);
    #1;
    if (tim_int === 1'b0) $display("[CHECK PASSED] @ %0t: Interrupt signal masked (de-asserted).", $time);
    else begin $display("[CHECK FAILED] @ %0t: Interrupt not masked.", $time); g_error_count = g_error_count+1; end

    timer_reg_write(TISR_OFFSET, 1);
    timer_reg_read(TISR_OFFSET, read_val);
    check_value(read_val, 0, "Check TISR status bit is cleared by W1C");
    
    if (g_error_count == 0) $display("--- TEST PASSED ---");
    else $display("--- TEST FAILED ---");
end // <--- THÊM END
endtask

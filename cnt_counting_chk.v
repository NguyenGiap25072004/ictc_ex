task run_test();
    reg [31:0] read_val_lo, read_val_hi;
    reg [63:0] final_count;
    integer wait_cycles = 260;
begin
    $display("\n\n--- Starting Test: Counter Counting and Overflow ---");
    $display("[SCENARIO] Testing TDR0 overflow");
    timer_reg_write(TDR0_OFFSET, 32'hFFFF_FFFA);
    timer_reg_write(TDR1_OFFSET, 32'h0000_0000);
    timer_reg_write(TCR_OFFSET, 1);
    #(wait_cycles * CLK_PERIOD);
    timer_reg_write(TCR_OFFSET, 0);
    timer_reg_read(TDR0_OFFSET, read_val_lo);
    timer_reg_read(TDR1_OFFSET, read_val_hi);
    final_count = {read_val_hi, read_val_lo};
    check_value(final_count, 64'hFFFF_FFFA + wait_cycles, "Check counter value after TDR0 overflow");
    if (g_error_count == 0) $display("--- TEST PASSED ---");
    else $display("--- TEST FAILED ---");
end
endtask

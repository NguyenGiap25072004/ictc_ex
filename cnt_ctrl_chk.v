task run_test();
begin // <--- THÊM BEGIN
    reg [31:0] read_val_lo, read_val_hi;
    reg [63:0] final_count;
    integer num_cycles = 512;
    reg [31:0] tcr_val;

    $display("\n\n--- Starting Test: Counter Control with div_val ---");

    $display("[SCENARIO] Testing with div_val = 8");
    tcr_val = (8 << 8) | (1 << 1) | (1 << 0);
    timer_reg_write(TCR_OFFSET, tcr_val);

    #(num_cycles * CLK_PERIOD);

    timer_reg_write(TCR_OFFSET, 0);
    timer_reg_read(TDR0_OFFSET, read_val_lo);
    timer_reg_read(TDR1_OFFSET, read_val_hi);
    final_count = {read_val_hi, read_val_lo};

    check_value(final_count, num_cycles / 256, "Check counter value with division enabled");

    if (g_error_count == 0) $display("--- TEST PASSED ---");
    else $display("--- TEST FAILED ---");
end // <--- THÊM END
endtask

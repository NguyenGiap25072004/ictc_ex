task run_test();
    reg [31:0] read_val_lo, read_val_hi;
    reg [63:0] final_count;
    integer    num_cycles;
    reg [31:0] tcr_val;
    integer    idx;
begin
    $display("\n\n--- Starting Test: Counter Control with div_val ---");

    for (idx = 0; idx < 9; idx = idx + 1) begin
        num_cycles = 512; // Gán giá trị ở đây
        if ((1 << idx) > num_cycles) begin
            // Make sure we wait at least one divided clock cycle
            num_cycles = (1 << idx) * 2;
        end

        $display("[SCENARIO] Testing with div_val = %0d", idx);
        tcr_val = (idx << 8) | (1 << 1) | (1 << 0); // div_val, div_en, timer_en
        
        timer_reg_write(TDR0_OFFSET, 0); // Reset counter before each test
        timer_reg_write(TDR1_OFFSET, 0);
        timer_reg_write(TCR_OFFSET, tcr_val);

        #(num_cycles * CLK_PERIOD);

        timer_reg_write(TCR_OFFSET, 0); // Disable timer
        timer_reg_read(TDR0_OFFSET, read_val_lo);
        timer_reg_read(TDR1_OFFSET, read_val_hi);
        final_count = {read_val_hi, read_val_lo};

        check_value(final_count, num_cycles / (1 << idx), "Check counter value with division enabled");
    end

    if (g_error_count == 0) $display("--- TEST PASSED ---");
    else $display("--- TEST FAILED ---");
end
endtask

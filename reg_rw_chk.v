task run_test();
    reg [31:0] read_val;
begin
    $display("\n\n--- Starting Test: General Register Read/Write Access ---");
    $display("[SCENARIO] Testing TCMP0 Read/Write");
    timer_reg_write(TCMP0_OFFSET, 32'hA5A5_A5A5);
    timer_reg_read(TCMP0_OFFSET, read_val);
    check_value(read_val, 32'hA5A5_A5A5, "Check R/W for TCMP0");
    $display("[SCENARIO] Testing TIER Read/Write (only bit 0 is RW)");
    timer_reg_write(TIER_OFFSET, 32'hFFFF_FFFF);
    timer_reg_read(TIER_OFFSET, read_val);
    check_value(read_val, 32'h0000_0001, "Check R/W for TIER");
    $display("[SCENARIO] Testing TISR Write-1-to-Clear");
    timer_reg_write(TDR0_OFFSET, 99);
    timer_reg_write(TDR1_OFFSET, 0);
    timer_reg_write(TCMP0_OFFSET, 100);
    timer_reg_write(TCMP1_OFFSET, 0);
    timer_reg_write(TCR_OFFSET, 1);
    @(posedge clk);
    timer_reg_write(TCR_OFFSET, 0);
    timer_reg_read(TISR_OFFSET, read_val);
    check_value(read_val, 1, "Check TISR is set by hardware");
    timer_reg_write(TISR_OFFSET, 1);
    timer_reg_read(TISR_OFFSET, read_val);
    check_value(read_val, 0, "Check TISR is cleared by software");
    if (g_error_count == 0) $display("--- TEST PASSED ---");
    else $display("--- TEST FAILED ---");
end
endtask

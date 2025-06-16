task run_test();
begin // <--- THÊM BEGIN
    reg [31:0] read_val;
    $display("\n\n--- Starting Test: Register Initial (Reset) Values ---");

    timer_reg_read(TCR_OFFSET,   read_val);
    check_value(read_val, 32'h0000_0100, "Check TCR reset value");
    timer_reg_read(TDR0_OFFSET,  read_val);
    check_value(read_val, 32'h0, "Check TDR0 reset value");
    timer_reg_read(TDR1_OFFSET,  read_val);
    check_value(read_val, 32'h0, "Check TDR1 reset value");
    timer_reg_read(TCMP0_OFFSET, read_val);
    check_value(read_val, 32'hFFFF_FFFF, "Check TCMP0 reset value");
    timer_reg_read(TCMP1_OFFSET, read_val);
    check_value(read_val, 32'hFFFF_FFFF, "Check TCMP1 reset value");
    timer_reg_read(TIER_OFFSET,  read_val);
    check_value(read_val, 32'h0, "Check TIER reset value");
    timer_reg_read(TISR_OFFSET,  read_val);
    check_value(read_val, 32'h0, "Check TISR reset value");
    timer_reg_read(THCSR_OFFSET, read_val);
    check_value(read_val, 32'h0, "Check THCSR reset value");

    if (g_error_count == 0) $display("--- TEST PASSED ---");
    else $display("--- TEST FAILED ---");
end // <--- THÊM END
endtask

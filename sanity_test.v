task run_test();
begin // <--- THÊM BEGIN
    reg [31:0] data_from_dut;
    $display("\n\n--- Starting Test: Sanity Check ---");
    $display("[INFO] This test performs a basic R/W and interrupt check.");

    timer_reg_read(TDR0_OFFSET, data_from_dut);
    check_value(data_from_dut, 32'h0, "Sanity: Check TDR0 reset value");
    
    timer_reg_write(TCMP0_OFFSET, 32'h0000_FFFF);
    timer_reg_write(TCMP1_OFFSET, 32'h0);
    timer_reg_write(TIER_OFFSET, 1);
    
    timer_reg_write(TCR_OFFSET, 1);
    timer_reg_read(TCR_OFFSET, data_from_dut);
    check_value(data_from_dut, 32'h1, "Sanity: Check timer is enabled");

    $display("[INFO] @ %0t: Timer is running, waiting for interrupt...", $time);
    repeat (65536) @(posedge clk);
    #1;

    if (tim_int == 1'b1) begin
        $display("[CHECK PASSED] @ %0t: Interrupt was successfully asserted.", $time);
    end else begin
        $display("**************************************************");
        $display("[CHECK FAILED] @ %0t: Interrupt did NOT assert when expected.", $time);
        $display("**************************************************");
        g_error_count = g_error_count + 1;
    end
    
    if (g_error_count == 0) $display("--- SANITY TEST PASSED ---");
    else $display("--- SANITY TEST FAILED ---");
end // <--- THÊM END
endtask

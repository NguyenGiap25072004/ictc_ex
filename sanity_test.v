// Sanity test: A quick, basic check to ensure the core functionality is working.
task run_test();
    reg [31:0] data_from_dut; // Internal variable to hold read data

    $display("\n\n--- Starting Test: Sanity Check ---");
    $display("[INFO] This test performs a basic R/W and interrupt check.");

    // 1. Check a register's reset value.
    // TDR0 should be 0 after reset. We read it directly from the live counter.
    timer_reg_read(TDR0_OFFSET, data_from_dut);
    check_value(data_from_dut, 32'h0, "Sanity: Check TDR0 reset value");
    
    // 2. Configure the timer for an interrupt.
    timer_reg_write(TCMP0_OFFSET, 32'h0000_FFFF); // Interrupt at count = 65535
    timer_reg_write(TCMP1_OFFSET, 32'h0);
    timer_reg_write(TIER_OFFSET, 1);             // Enable interrupt output
    
    // 3. Start the timer.
    timer_reg_write(TCR_OFFSET, 1);              // timer_en = 1
    timer_reg_read(TCR_OFFSET, data_from_dut);
    check_value(data_from_dut, 32'h1, "Sanity: Check timer is enabled");

    // 4. Wait for the interrupt to occur.
    $display("[INFO] @ %0t: Timer is running, waiting for interrupt...", $time);
    // Wait for counter to reach 65535 and one more cycle for the interrupt to assert
    repeat (65536) @(posedge clk);
    #1; // Allow a small delay for the signal to propagate through combinatorial logic

    // 5. Check if the interrupt signal is high.
    if (tim_int == 1'b1) begin
        $display("[CHECK PASSED] @ %0t: Interrupt was successfully asserted.", $time);
    end else begin
        $display("**************************************************");
        $display("[CHECK FAILED] @ %0t: Interrupt did NOT assert when expected.", $time);
        $display("**************************************************");
        g_error_count = g_error_count + 1;
    end
    
    // Final test result
    if (g_error_count == 0) $display("--- SANITY TEST PASSED ---");
    else $display("--- SANITY TEST FAILED ---");

endtask
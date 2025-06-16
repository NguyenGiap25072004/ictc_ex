task run_test();
    reg [31:0] read_val;
    reg [11:0] reserved_addr;
begin
    reserved_addr = 12'hF00; // Gán giá trị ở đây

    $display("\n\n--- Starting Test: Reserved Address Space ---");
    
    $display("[SCENARIO] Writing and reading from a reserved address 0x%0h", reserved_addr);
    timer_reg_write(reserved_addr, 32'hFFFF_FFFF);
    timer_reg_read(reserved_addr, read_val);
    check_value(read_val, 32'h0, "Check reserved address follows RAZ/WI");

    if (g_error_count == 0) $display("--- TEST PASSED ---");
    else $display("--- TEST FAILED ---");
end
endtask

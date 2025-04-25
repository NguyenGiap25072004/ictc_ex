`timescale 1ns / 1ps

module counter_top_tb;

parameter CLK_PERIOD = 10;
parameter T_HOLD = (CLK_PERIOD / 2); 

reg          clk_tb;
reg          rst_n_tb;
reg          wr_en_tb;
reg          rd_en_tb;
reg  [9:0]   addr_tb;
reg  [31:0]  wdata_tb;
wire [31:0]  rdata_tb;
wire         overflow_tb; 

integer error_count = 0;
integer test_count = 0;

counter_top dut (
    .clk      (clk_tb),
    .rst_n    (rst_n_tb),
    .wr_en    (wr_en_tb),
    .rd_en    (rd_en_tb),
    .addr     (addr_tb),
    .wdata    (wdata_tb),
    .rdata    (rdata_tb),
    .overflow (overflow_tb)
);

initial begin
    clk_tb = 0;
    forever #(CLK_PERIOD / 2) clk_tb = ~clk_tb;
end

// Task write
task write_reg;
    input [9:0]  address;
    input [31:0] data;
    begin
        @(posedge clk_tb);
        addr_tb  = address;
        wdata_tb = data;
        wr_en_tb = 1;
        @(posedge clk_tb);
        wr_en_tb = 0;
        addr_tb  = 10'hXXX; 
        wdata_tb = 32'hX;
        $display("[%0t] INFO: WRITE Addr=0x%h Data=0x%h", $time, address, data);
    end
endtask

// Task read
task read_reg;
    input [9:0] address;
    begin
        @(posedge clk_tb);
        addr_tb  = address;
        rd_en_tb = 1;
        @(posedge clk_tb); 
        rd_en_tb = 0;
        addr_tb  = 10'hXXX; 
    end
endtask

// Task for checking read data 
task check_read;
    input [9:0]  address;
    input [31:0] expected_data;
    begin
        test_count = test_count + 1;
        read_reg(address); 
        if (rdata_tb === expected_data) begin
            $display("[%0t] INFO: TESTCASE %0d: PASS (Addr=0x%h, Expected=0x%h, Got=0x%h)",
                     $time, test_count, address, expected_data, rdata_tb);
        end else begin
            $display("[%0t] ERROR: TESTCASE %0d: FAIL - Addr=0x%h, Expected=0x%h, Got=0x%h",
                     $time, test_count, address, expected_data, rdata_tb);
            error_count = error_count + 1;
        end
        #(T_HOLD); 
    end
endtask

// Task to generate a pulse via CR write 
task generate_pulse;
    begin 
        write_reg(10'h000, 32'h00000001); 
        #(CLK_PERIOD);
    end 
endtask


// Stimulus 
initial begin
    $display("--------------------------------------------------");
    $display("Self-Checking Testbench Started at time %0t", $time);
    $display("--------------------------------------------------");
    $monitor("[%0t] Addr=0x%h WrEn=%b RdEn=%b WData=0x%h | RData=0x%h | Overflow=%b",
             $time, addr_tb, wr_en_tb, rd_en_tb, wdata_tb, rdata_tb, overflow_tb);

    // 1. Initialize and Reset
    rst_n_tb = 1; wr_en_tb = 0; rd_en_tb = 0; addr_tb = 10'hXXX; wdata_tb = 32'hX;
    #5;
    rst_n_tb = 0; 
    $display("[%0t] INFO: Applying Reset (rst_n = 0)", $time);
    #(CLK_PERIOD * 2);
    rst_n_tb = 1; 
    $display("[%0t] INFO: Releasing Reset (rst_n = 1)", $time);
    #(CLK_PERIOD);

    // 2. Check initial status (counter=0, overflow_sticky=0)
    $display("[%0t] INFO: Starting TESTCASE %0d 'Read Initial Status'", $time, test_count+1); 
    check_read(10'h004, 32'h00000000); 

    // 3. Generate pulses and check count
    $display("[%0t] INFO: Generating 3 count pulses...", $time);
    generate_pulse(); 
    generate_pulse(); 
    generate_pulse(); 
    #(CLK_PERIOD);    
    $display("[%0t] INFO: Starting TESTCASE %0d 'Read Count after 3 pulses'", $time, test_count+1);
    check_read(10'h004, 32'h00000003); // Expect SR[2:0]=3

    // 4. Clear the counter
    $display("[%0t] INFO: Clearing the counter...", $time);
    write_reg(10'h000, 32'h00000002); // Write CR[1]=1 
    #(CLK_PERIOD * 2); 
    $display("[%0t] INFO: Starting TESTCASE %0d 'Read Count after Clear'", $time, test_count+1);
    check_read(10'h004, 32'h00000000); // Expect SR[2:0]=0

    // 5. Deassert clear, keep counter stopped
    $display("[%0t] INFO: Deasserting clear...", $time);
    write_reg(10'h000, 32'h00000000); // Write CR[1]=0, CR[0]=0
    #(CLK_PERIOD);
    $display("[%0t] INFO: Starting TESTCASE %0d 'Read Count after Deassert Clear'", $time, test_count+1);
    check_read(10'h004, 32'h00000000);

    // 6. Count until overflow 
    $display("[%0t] INFO: Counting to overflow (7 -> 0)...", $time);
    repeat (7) begin // Generate 7 pulses to reach count=7
      generate_pulse();
    end
    $display("[%0t] INFO: Starting TESTCASE %0d 'Read Count before Overflow pulse'", $time, test_count+1);
    check_read(10'h004, 32'h00000007); // Expect SR[2:0]=7, SR[3]=0

    generate_pulse(); 
    #(CLK_PERIOD);    
    $display("[%0t] INFO: Checking status after overflow pulse...", $time);
    $display("[%0t] INFO: Starting TESTCASE %0d 'Read Status after Overflow'", $time, test_count+1);
    check_read(10'h004, 32'h00000008); // Expect SR[2:0]=0, SR[3]=1

    // 7. Read status again 
    #(CLK_PERIOD * 2);
    $display("[%0t] INFO: Reading status again (sticky bit check)...", $time);
    $display("[%0t] INFO: Starting TESTCASE %0d 'Read Status - Sticky Check'", $time, test_count+1);
    check_read(10'h004, 32'h00000008); // Expected SR[3]=1

    // 8. Clear the sticky overflow bit by writing 0 to SR[3]
    $display("[%0t] INFO: Clearing sticky overflow bit...", $time);
    write_reg(10'h004, 32'h00000000); // Write 0 to SR[3] 
    #(CLK_PERIOD);
    $display("[%0t] INFO: Starting TESTCASE %0d 'Read Status after Clear Sticky Bit'", $time, test_count+1);
    check_read(10'h004, 32'h00000000); // Expected SR[3]=0

     // 9. Test Reserved Address Read (RAZ)
    $display("[%0t] INFO: Reading Reserved Address 0x08...", $time);
    $display("[%0t] INFO: Starting TESTCASE %0d 'Read Reserved Address (RAZ)'", $time, test_count+1);
    check_read(10'h008, 32'h00000000); // Expected RData = 0

    // 10. Test Reserved Address Write (WI)
    $display("[%0t] INFO: Writing to Reserved Address 0x08...", $time);
    write_reg(10'h008, 32'hDEADBEEF);
    #(CLK_PERIOD);
    $display("[%0t] INFO: Checking control/status regs after WI attempt...", $time);
    $display("[%0t] INFO: Starting TESTCASE %0d 'Check CR after WI'", $time, test_count+1);
    check_read(10'h000, 32'h00000000); // CR[1:0] should be 0 from step 5
    $display("[%0t] INFO: Starting TESTCASE %0d 'Check SR after WI'", $time, test_count+1);
    check_read(10'h004, 32'h00000000); // SR[3] was cleared, counter value is 0

    #(CLK_PERIOD * 2);

    // Final 
    $display("--------------------------------------------------");
    if (error_count == 0) begin
        $display("RESULT: ALL %0d TESTS PASSED", test_count);
    end else begin
        $display("RESULT: %0d/%0d TESTS FAILED", error_count, test_count);
    end
    $display("Testbench Finished at time %0t", $time);
    $display("--------------------------------------------------");
    $finish;
end

endmodule 
//----------------------------------------------------------------------//
// Module: counter_top_tb
//----------------------------------------------------------------------//
// Description:
// Simple testbench for the counter_top module (Homework 2).
// Tests reset, clear, enable/disable, reading count, overflow.
//----------------------------------------------------------------------//
`timescale 1ns / 1ps

module counter_top_tb;

reg          clk_tb;
reg          rst_n_tb;
reg          wr_en_tb;
reg          rd_en_tb;
reg  [9:0]   addr_tb;
reg  [31:0]  wdata_tb;
wire [31:0]  rdata_tb;
wire         overflow_tb;

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

parameter CLK_PERIOD = 10;
initial begin
    clk_tb = 0;
    forever #(CLK_PERIOD / 2) clk_tb = ~clk_tb;
end

// Task register write
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
        addr_tb  = 10'h0; // Clear address bus after write
        wdata_tb = 32'h0; // Clear data bus after write
        $display("[%0t] WRITE Addr=0x%h Data=0x%h", $time, address, data);
    end
endtask

// Task register read
task read_reg;
    input [9:0] address;
    begin
        @(posedge clk_tb);
        addr_tb  = address;
        rd_en_tb = 1;
        @(posedge clk_tb); 
        rd_en_tb = 0;
        addr_tb  = 10'h0; // Clear address bus after read
        $display("[%0t] READ Addr=0x%h RData=0x%h", $time, address, rdata_tb);
    end
endtask

// Stimulus 
initial begin
    $display("--------------------------------------------------");
    $display("Counter Top Testbench Started at time %0t", $time);
    $display("--------------------------------------------------");
    $monitor("[%0t] Addr=0x%h WrEn=%b RdEn=%b WData=0x%h | RData=0x%h | CountEn=%b CountClr=%b Count=%d Overflow=%b",
             $time, addr_tb, wr_en_tb, rd_en_tb, wdata_tb, rdata_tb, dut.count_en_sig, dut.count_clr_sig, dut.count_val_sig, overflow_tb); // Monitor internal signals if possible

    // 1. Initialize and Reset
    rst_n_tb = 1;
    wr_en_tb = 0;
    rd_en_tb = 0;
    addr_tb  = 10'h0;
    wdata_tb = 32'h0;
    #5;
    rst_n_tb = 0; 
    $display("[%0t] Applying Reset", $time);
    #(CLK_PERIOD * 2);
    rst_n_tb = 1; 
    $display("[%0t] Releasing Reset", $time);
    #(CLK_PERIOD);

    // 2. Read initial counter value (should be 0)
    read_reg(10'h004); 

    // 3. Enable counter and let it count a few cycles
    $display("[%0t] Enabling counter...", $time);
    write_reg(10'h000, 32'h00000001); // Write 1 to count_start (bit 0)
    #(CLK_PERIOD * 5); 
    read_reg(10'h004); // Read counter value (expected 5)

    // 4. Disable counter
    $display("[%0t] Disabling counter...", $time);
    write_reg(10'h000, 32'h00000000); // Write 0 to count_start (bit 0)
    #(CLK_PERIOD * 3); 
    read_reg(10'h004); // Read counter value (should still be 5)

    // 5. Clear counter while it's disabled
    $display("[%0t] Clearing counter while disabled...", $time);
    write_reg(10'h000, 32'h00000002); // Write 1 to count_clr (bit 1)
    #(CLK_PERIOD);
    read_reg(10'h004); // Read counter value (should be 0)
    write_reg(10'h000, 32'h00000000); 

    // 6. Enable counter and test overflow
    $display("[%0t] Enabling counter to test overflow...", $time);
    write_reg(10'h000, 32'h00000001); 

    #(CLK_PERIOD * 260);
    $display("[%0t] Check count value after ~260 cycles...", $time);
    read_reg(10'h004); // Read counter value (should be around 4 if overflow worked)
    write_reg(10'h000, 32'h00000000); 

    // 7. Test Reserved Address Read (RAZ)
    $display("[%0t] Reading Reserved Address 0x10...", $time);
    read_reg(10'h010); // Expected RData = 0

    // 8. Test Reserved Address Write (WI)
    $display("[%0t] Writing to Reserved Address 0x10...", $time);
    write_reg(10'h010, 32'hDEADBEEF);
    $display("[%0t] Reading control/status regs to check for side effects...", $time);
    read_reg(10'h000); 
    read_reg(10'h004); 

    #(CLK_PERIOD * 2);
    $display("--------------------------------------------------");
    $display("Counter Top Testbench Finished at time %0t", $time);
    $display("--------------------------------------------------");
    $finish;
end

endmodule 
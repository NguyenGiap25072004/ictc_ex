//----------------------------------------------------------------------//
// Module: register_file_tb
//----------------------------------------------------------------------//
// Description:
// A simple testbench for the register_file module.
// Tests reset, read/write to valid registers, read from RO mirror
// registers, write attempt to RO, and read/write to reserved address.
//----------------------------------------------------------------------//
`timescale 1ns / 1ps

module register_file_tb;

reg          clk_tb;
reg          rst_n_tb;
reg          wr_en_tb;
reg          rd_en_tb;
reg  [9:0]   addr_tb;
reg  [31:0]  wdata_tb;
wire [31:0]  rdata_tb;

register_file dut (
    .clk      (clk_tb),
    .rst_n    (rst_n_tb),
    .wr_en    (wr_en_tb),
    .rd_en    (rd_en_tb),
    .addr     (addr_tb),
    .wdata    (wdata_tb),
    .rdata    (rdata_tb)
);

parameter CLK_PERIOD = 10;
initial begin
    clk_tb = 0;
    forever #(CLK_PERIOD / 2) clk_tb = ~clk_tb;
end

// Stimulus 
initial begin
    $display("--------------------------------------------------");
    $display("Testbench Started at time %0t", $time);
    $display("--------------------------------------------------");

    // 1. Initialize inputs and apply reset
    rst_n_tb = 1; 
    wr_en_tb = 0;
    rd_en_tb = 0;
    addr_tb  = 10'h0;
    wdata_tb = 32'h0;
    #5; // Wait a bit

    rst_n_tb = 0; 
    $display("[%0t] Applying Reset (rst_n = 0)", $time);
    #(CLK_PERIOD * 2); 

    rst_n_tb = 1; 
    $display("[%0t] Releasing Reset (rst_n = 1)", $time);
    #(CLK_PERIOD);

    // 2. Read default values after reset
    $display("[%0t] Reading default values...", $time);
    rd_en_tb = 1;
    addr_tb  = 10'h000; 
    #(CLK_PERIOD);
    $display("[%0t] Read DATA0 (addr 0x0): %h", $time, rdata_tb); // Expected: 00000000

    addr_tb  = 10'h004; // Read SR_DATA0
    #(CLK_PERIOD);
    $display("[%0t] Read SR_DATA0 (addr 0x4): %h", $time, rdata_tb); // Expected: 00000000

    addr_tb  = 10'h008; // Read DATA1
    #(CLK_PERIOD);
    $display("[%0t] Read DATA1 (addr 0x8): %h", $time, rdata_tb); // Expected: FFFFFFFF

    addr_tb  = 10'h00C; // Read SR_DATA1
    #(CLK_PERIOD);
    $display("[%0t] Read SR_DATA1 (addr 0xC): %h", $time, rdata_tb); // Expected: FFFFFFFF
    rd_en_tb = 0;
    #(CLK_PERIOD);

    // 3. Write to DATA0 and read back
    $display("[%0t] Writing 0xAAAAAAAA to DATA0...", $time);
    wr_en_tb = 1;
    addr_tb  = 10'h000;
    wdata_tb = 32'hAAAAAAAA;
    #(CLK_PERIOD); 
    wr_en_tb = 0;
    wdata_tb = 32'h0; 
    #(CLK_PERIOD); 

    $display("[%0t] Reading back from DATA0 and SR_DATA0...", $time);
    rd_en_tb = 1;
    addr_tb  = 10'h000; // Read DATA0
    #(CLK_PERIOD);
    $display("[%0t] Read DATA0 (addr 0x0): %h", $time, rdata_tb); // Expected: AAAAAAAA

    addr_tb  = 10'h004; // Read SR_DATA0
    #(CLK_PERIOD);
    $display("[%0t] Read SR_DATA0 (addr 0x4): %h", $time, rdata_tb); // Expected: AAAAAAAA
    rd_en_tb = 0;
    #(CLK_PERIOD);

    // 4. Write to DATA1 and read back
    $display("[%0t] Writing 0xBBBBBBBB to DATA1...", $time);
    wr_en_tb = 1;
    addr_tb  = 10'h008;
    wdata_tb = 32'hBBBBBBBB;
    #(CLK_PERIOD); 
    wr_en_tb = 0;
    wdata_tb = 32'h0;
    #(CLK_PERIOD); 

    $display("[%0t] Reading back from DATA1 and SR_DATA1...", $time);
    rd_en_tb = 1;
    addr_tb  = 10'h008; // Read DATA1
    #(CLK_PERIOD);
    $display("[%0t] Read DATA1 (addr 0x8): %h", $time, rdata_tb); // Expected: BBBBBBBB

    addr_tb  = 10'h00C; // Read SR_DATA1
    #(CLK_PERIOD);
    $display("[%0t] Read SR_DATA1 (addr 0xC): %h", $time, rdata_tb); // Expected: BBBBBBBB
    rd_en_tb = 0;
    #(CLK_PERIOD);

    // 5. Attempt to write to RO register (SR_DATA0 @ 0x4)
    $display("[%0t] Attempting to write 0xCCCCCCCC to SR_DATA0 (addr 0x4)...", $time);
    wr_en_tb = 1;
    addr_tb  = 10'h004;
    wdata_tb = 32'hCCCCCCCC;
    #(CLK_PERIOD);
    wr_en_tb = 0;
    wdata_tb = 32'h0;
    #(CLK_PERIOD);

    $display("[%0t] Verifying DATA0 was not affected...", $time);
    rd_en_tb = 1;
    addr_tb  = 10'h000; // Read DATA0
    #(CLK_PERIOD);
    $display("[%0t] Read DATA0 (addr 0x0): %h", $time, rdata_tb); // Expected: AAAAAAAA (should not change)
    rd_en_tb = 0;
    #(CLK_PERIOD);

    // 6. Test Reserved Address Access 
    $display("[%0t] Testing Reserved Address 0x10...", $time);
    // Write Ignored (WI) test
    $display("[%0t] Attempting to write 0xDDDDDDDD to Reserved Addr 0x10...", $time);
    wr_en_tb = 1;
    addr_tb  = 10'h010;
    wdata_tb = 32'hDDDDDDDD;
    #(CLK_PERIOD);
    wr_en_tb = 0;
    wdata_tb = 32'h0;
    #(CLK_PERIOD);
    $display("[%0t] Verifying internal registers were not affected...", $time);
     rd_en_tb = 1;
    addr_tb  = 10'h000; // Read DATA0
    #(CLK_PERIOD);
    $display("[%0t] Read DATA0 (addr 0x0): %h", $time, rdata_tb); // Expected: AAAAAAAA
    addr_tb  = 10'h008; // Read DATA1
    #(CLK_PERIOD);
    $display("[%0t] Read DATA1 (addr 0x8): %h", $time, rdata_tb); // Expected: BBBBBBBB

    // Read As Zero test
    $display("[%0t] Reading from Reserved Addr 0x10...", $time);
    addr_tb  = 10'h010;
    #(CLK_PERIOD);
    $display("[%0t] Read Reserved Addr (addr 0x10): %h", $time, rdata_tb); // Expected: 00000000
    rd_en_tb = 0;
    #(CLK_PERIOD * 2);


    $display("--------------------------------------------------");
    $display("Testbench Finished at time %0t", $time);
    $display("--------------------------------------------------");
    $finish; 
end

endmodule 

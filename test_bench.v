// Main Testbench for the APB Timer IP
module test_bench;

    // Register Address Map
    parameter TCR_OFFSET   = 12'h00;
    parameter TDR0_OFFSET  = 12'h04;
    parameter TDR1_OFFSET  = 12'h08;
    parameter TCMP0_OFFSET = 12'h0C;
    parameter TCMP1_OFFSET = 12'h10;
    parameter TIER_OFFSET  = 12'h14;
    parameter TISR_OFFSET  = 12'h18;
    parameter THCSR_OFFSET = 12'h1C;

    // Timing and Message Width Parameters
    parameter CLK_PERIOD      = 50; // Corresponds to 20MHz clock with 1ns timescale
    parameter MAX_MSG_LENGTH  = 128; // Max characters for display messages

    // DUT Interface signals
    reg  clk, rst_n;
    reg  psel, pwrite, penable, dbg_mode;
    reg  [11:0] paddr;
    reg  [31:0] pwdata;
    reg  [3:0]  pstrb;
    wire [31:0] prdata;
    wire        pready;
    wire        tim_int;
    wire        pslverr;
    
    // Testbench internal variables
    integer g_error_count;
    reg     inject_psel_error;
    reg     inject_penable_error;

    // DUT (Design Under Test) Instantiation
    timer_top u_timer (
        .sys_clk    (clk),
        .sys_rst_n  (rst_n),
        .tim_psel   (psel),
        .tim_pwrite (pwrite),
        .tim_penable(penable),
        .tim_paddr  ({20'h4000_1, paddr}), // Concatenate base address
        .tim_pwdata (pwdata),
        .tim_prdata (prdata),
        .tim_pready (pready),
        .tim_pstrb  (pstrb),
        .tim_pslverr(pslverr),
        .dbg_mode   (dbg_mode),
        .tim_int    (tim_int)
    );

    // Include the specific test case file to be run
    `include "run_test.v"

    // Clock generator
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Reset generator
    initial begin
        rst_n = 1'b0;
        #(CLK_PERIOD * 2);
        rst_n = 1'b1;
    end
    
    // Main test execution flow
    initial begin
        // Initialize all driving signals
        psel = 0;
        penable = 0;
        pwrite = 0;
        paddr = 0;
        pwdata = 0;
        pstrb = 0;
        dbg_mode = 0;
        g_error_count = 0;
        inject_psel_error = 0;
        inject_penable_error = 0;
        
        // Wait for reset to complete
        wait (rst_n === 1'b1);
        #(CLK_PERIOD * 2);

        // Call the main test task from the included file
        run_test();

        // Final delay before finishing
        #(CLK_PERIOD * 2);
        $finish;
    end

    // Task for an APB Write transaction
    task timer_reg_write;
        input [11:0] addr_in;
        input [31:0] data_in;
        begin
            $display("[TB INFO] @ %0t : APB Write to Addr = 0x%0h, Data = 0x%0h", $time, addr_in, data_in);
            
            @(posedge clk);
            // Setup Phase
            psel   = 1'b1 & ~inject_psel_error;
            pwrite = 1'b1;
            paddr  = addr_in;
            pwdata = data_in;
            pstrb  = 4'b1111; // Always full 32-bit write

            @(posedge clk);
            // Access Phase
            penable = 1'b1 & ~inject_penable_error;
            wait (pready === 1'b1);

            @(posedge clk);
            // End of transaction, return to idle
            psel    = 1'b0;
            penable = 1'b0;
            pwrite  = 1'b0;
        end
    endtask

    // Task for an APB Read transaction
    task timer_reg_read;
        input  [11:0] addr_in;
        output [31:0] data_out;
        begin
            @(posedge clk);
            // Setup Phase
            psel   = 1'b1 & ~inject_psel_error;
            pwrite = 1'b0;
            paddr  = addr_in;

            @(posedge clk);
            // Access Phase
            penable = 1'b1 & ~inject_penable_error;
            wait (pready === 1'b1);
            #1; // Wait a small delta for data to propagate
            data_out = prdata;

            @(posedge clk);
            // End of transaction
            psel    = 1'b0;
            penable = 1'b0;
            
            $display("[TB INFO] @ %0t : APB Read from Addr = 0x%0h, Data = 0x%0h", $time, addr_in, data_out);
        end
    endtask

    // Task to compare read data with expected data
    task check_value;
        input [31:0] actual_data;
        input [31:0] expected_data;
        // *** SỬA LỖI: THAY THẾ 'string' BẰNG MẢNG 'reg' ĐỂ TƯƠNG THÍCH VERILOG ***
        input [(MAX_MSG_LENGTH*8)-1:0] message; 
        begin
            if (actual_data !== expected_data) begin
                $display("**************************************************");
                $display("[CHECK FAILED] @ %0t : %s", $time, message);
                $display("    -> Expected = 0x%0h", expected_data);
                $display("    -> Actual   = 0x%0h", actual_data);
                $display("**************************************************");
                g_error_count = g_error_count + 1;
            end else begin
                $display("[CHECK PASSED] @ %0t : %s (Value: 0x%0h)", $time, message, actual_data);
            end
        end
    endtask

endmodule

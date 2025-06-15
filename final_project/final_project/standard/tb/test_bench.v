`timescale 1ns/1ps
module test_bench;
	reg 		clk, rst_n;
	reg		psel, pwrite, penable;
	reg  [31:0]	paddr;
	reg  [31:0]	pwdata;
	reg		dbg_mode;
	reg [3:0]	tim_pstrb;
	wire [31:0]	prdata;
	wire		pready;
	wire		pslverr;
	wire		tim_int;

	// Declare default value
	parameter	CLK_PERIOD 	= 5;
	parameter	TCR_ADDR	= 32'h40001000;
	parameter       TDR0_ADDR       = 32'h40001004;
	parameter       TDR1_ADDR       = 32'h40001008;
	parameter       TCMP0_ADDR      = 32'h4000100C;
	parameter       TCMP1_ADDR      = 32'h40001010;
	parameter       TIER_ADDR       = 32'h40001014;
	parameter       TISR_ADDR       = 32'h40001018;
	parameter       THCSR_ADDR      = 32'h4000101C;

	// Default value
	parameter       TCR_DEFAULT     = 32'h100;
	parameter       TDR0_DEFAULT    = 32'h0;
	parameter       TDR1_DEFAULT    = 32'h0;
	parameter       TCMP0_DEFAULT   = 32'hFFFFFFFF;
	parameter       TCMP1_DEFAULT   = 32'hFFFFFFFF;
	parameter       TIER_DEFAULT    = 32'h0;
	parameter       TISR_DEFAULT    = 32'h0;
	parameter       THCSR_DEFAULT   = 32'h0;
	parameter       RDATA_DEFAULT   = 32'h0;
	parameter	TCR_MASK	= 32'h00000F03;
	parameter       TIER_MASK       = 32'h00000001;
	parameter       TISR_MASK       = 32'h00000001;
	parameter	TDR_TCMP_MASK	= 32'hFFFFFFFF;
	parameter	MASK_64BIT	= 64'hFFFFFFFFFFFFFFFF;

	// Testbench variable
	integer 	error;
	
	// DUT Initialize
	timer_top DUT (
		.sys_clk	(clk),
		.sys_rst_n	(rst_n),
		.tim_psel	(psel),
		.tim_pwrite	(pwrite),
		.tim_penable	(penable),
		.tim_paddr	(paddr),
		.tim_pwdata	(pwdata),
		.tim_prdata	(prdata),
		.tim_pready	(pready),
		.tim_pstrb	(/*tim_pstrb*/),
		.tim_pslverr	(pslverr),
		.tim_int	(tim_int),
		.dbg_mode	(dbg_mode)
	);
	// Import Testcase
	
	`include "run_test.v"

	// Clock initialization
	initial begin
		clk = 0;
		#5;
		forever #2.5 clk = ~clk;	
	end
	// Test sequence
	initial begin

		initialize_system();
		
		#1;
		run_test();
		$display("The number of Error: %d:", error);
		#1;
	
		if (error != 0) begin
			$display("==========================================================");
			$display("--------------------- TEST FAILED!! ----------------------");
			$display("==========================================================");
		end else begin
			$display("==========================================================");
			$display("--------------------- TEST SUCCESS! ----------------------"); 		
			$display("=========================================================="); 		
		end
	
		$finish;
	end
	
	// VIP
	// Write task
	task 	write;
		input [31:0] 	address;
		input [31:0] 	data;
		begin
			@(posedge clk);	// Set up Phase
			paddr  	= address;
			pwrite	= 1'b1;
			pwdata 	= data;
			psel 	= 1'b1;
			
			@(posedge clk); // Access Phase
			penable	= 1'b1;
			wait (pready == 1'b1);
			
			@(posedge clk);
			pwrite	= 1'b0;
			psel 	= 1'b0;
			penable	= 1'b0;
			paddr	= 32'h0;
			pwdata	= 32'h0;
			$display("====================================");
			$display("[%0t] WRITE: Addr = 0x%h, Data = 0x%h", $time, address, data);
			$display("====================================");
		end
	endtask

	// Read task
	task 	read;
		input  [31:0]   address;
		output [31:0]   data;
		begin
			@(posedge clk); // Set up Phase
			paddr  	= address;
			pwrite  = 1'b0;
			psel    = 1'b1;

			@(posedge clk); // Access Phase
			penable	= 1'b1;
			wait (pready == 1'b1);
			#1;
			data  	= prdata;

			@(posedge clk);
			pwrite	= 1'b0;
			psel	= 1'b0;
			penable	= 1'b0;
			paddr	= 32'h0;
			pwdata	= 32'h0;
			#1;
			$display("====================================");
			$display("[%0t] READ: Addr = 0x%h, Data = 0x%h", $time, address, data);
			$display("====================================");
		end
	endtask

	// Compare task
	task 	cmp;
		input [31:0]	actual_data;
		input [31:0]	expected_data;
		input [31:0]	mask;
		begin	
		#1;
		if ( (actual_data & mask) == (expected_data & mask) ) begin
			$display("====================================");
			$display("At [t=%10d] - [PASS] Expected: 0x%h, Got: 0x%h", $time, expected_data & mask, actual_data & mask);
			$display("====================================");
		end else begin
			$display("====================================");
			$display("At [t=%10d] - [FAIL] Expected: 0x%h, Got: 0x%h", $time, expected_data & mask, actual_data & mask);
			$display("====================================");
			error = error + 1;
		end
		end	
	endtask

	// Initialize system
	task 	initialize_system;
	begin
		rst_n 		= 1'b0;
		dbg_mode	= 1'b0;
		paddr  		= 32'h0;
		psel 		= 1'b0;
		pwrite   	= 1'b0;
		penable		= 1'b0;
		pwdata		= 32'h0;
		error 		= 0;
		error 		= 1;
		#(CLK_PERIOD*2);
		rst_n		= 1'b1;
		error 		= 0;
	end
	endtask

	// Reset DUT
	task 	reset_dut;
		begin
			rst_n = 0;
			#(CLK_PERIOD*2);
			rst_n = 1;
		end
	endtask
	
	// Counter for verification
	task	counter_check;
		// Input
		input		timer_en;
		input		div_en;
		input [3:0]	div_val;
		input [63:0]	start_count;
		input [63:0]	elapsed_cycles;

		// Output
		output [63:0]	expected_count;

		// Internal variable		
		integer		div_factor;

		begin
		// Initialize the counter	
		expected_count = start_count;

		// Calculate the division factor for expected_count: div_factor = 2^div_val
		if (timer_en) begin
			if (div_en) begin		
				if (div_val == 4'b0) begin
					div_factor = 1;
					$display("No division.");
				end else if (div_val > 4'b1000) begin
					div_factor = div_factor;
					$display("Div val prohibit detected, div_val does not change.");
				end else begin
					div_factor = 1 << div_val; // div_factor = 2 ^ div_val
					$display("Div_val = %h.", div_val);
				end
			end else begin
				div_factor = 1;
				$display("Count in default mode.");
			end

			if (expected_count == 64'h0) begin
				$display("Counter overflow");
				expected_count = start_count + (elapsed_cycles / div_factor);
			end else begin 
				expected_count = start_count + (elapsed_cycles / div_factor);
			end

		end else begin
			expected_count = expected_count;
			$display("Counter disable");
		end
		$display("expected_count = %h", expected_count);
		end
	endtask
	
	// Counter DUT
	task	counter_dut;
		input		timer_en;
		input		div_en;
		input [3:0]	div_val;
		input		int_en;
		
		input [63:0]	start_count;
		input [63:0]	int_cmp;
		inout [31:0]	test_cycles;
		
		output [63:0]	actual_count;
		output [63:0]	elapsed_cycles;

		integer		start_time;
		integer		end_time;

		begin

		if (int_en) begin
			$display("Interrupt enable");		
			// Compare register
			write(TCMP0_ADDR, int_cmp[31:0]);
			write(TCMP1_ADDR, int_cmp[63:32]);
			
			// Time to interrupt
			if (start_count > int_cmp) begin
				test_cycles = ((64'hFFFFFFFFFFFFFFFF - start_count + 64'h1) + int_cmp )*(1 << div_val);
			end else begin
				test_cycles = (int_cmp - start_count)*(1 << div_val);
			end
			$display("Cycles needed to count to interrupt value: %d", test_cycles);

			// Enable interrupt
			write(TIER_ADDR, {31'h0, int_en});
		
		end else begin
			$display("Interrupt disable");		
		end	

		// Counter data initilize
		write(TDR0_ADDR, start_count[31:0]);
		write(TDR1_ADDR, start_count[63:32]);	
		
		// Counter start counting
		write(TCR_ADDR, {20'h0, div_val, 6'h0, div_en, timer_en});   	 	
		@(posedge clk);			// Wait for count_en
		
		// Count sequence => Capture count_en H and L time
		start_time = $time;
		repeat (test_cycles - 3) @(posedge clk);
		write(TCR_ADDR, 32'h00000000);		// Disable counter
		@ (posedge clk);			// Disable count_en
		end_time = $time;
		
		// Calculate elapsed cycles
		elapsed_cycles = (end_time - start_time)/(CLK_PERIOD);

		// Read TDR register
		read(TDR0_ADDR, actual_count[31:0]);
		read(TDR1_ADDR, actual_count[63:32]);
		$display("actual_count = %h", actual_count);
		
		// Initialize Counter 
		write(TDR0_ADDR, 32'h0);
		write(TDR1_ADDR, 32'h0);

		end		
	endtask	
	
endmodule

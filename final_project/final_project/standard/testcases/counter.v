task run_test;
	reg			timer_en;
	reg			div_en;
	reg [3:0] 		div_val;
	reg			int_en;
	reg [63:0]		start_count;
	reg [63:0]		int_cmp;
	reg [31:0]		test_cycles;

	reg [63:0]		elapsed_cycles;
	reg [63:0]      	actual;
	reg [63:0]		expected;

	begin

	$display("==========================================================");
	$display("----------------- TEST C1: Counter Init ------------------");
	$display("==========================================================");
	
	expected = 64'h0;
	read(TDR0_ADDR, actual[31:0]);
	read(TDR1_ADDR, actual[63:32]);
	cmp(actual, expected, MASK_64BIT);

	$display("==========================================================");
	$display("--------------- TEST C2: Counter Increment ---------------");
	$display("==========================================================");
	
	// Count task
	timer_en 	= 1'b1;
	div_en	 	= 1'b0;
	div_val  	= 4'b0000;
	int_en		= 1'b0;
	int_cmp		= 64'h0000000000000000;
	start_count	= 64'h1;
	start_count 	= $urandom_range(64'h0000000000000000, 64'hFFFFFFFFFFFFFFFF);
	test_cycles	= $urandom_range(200, 500);

	counter_dut(timer_en, div_en, div_val, int_en, start_count, int_cmp, test_cycles, actual, elapsed_cycles);
	counter_check(timer_en, div_en, div_val, start_count, elapsed_cycles, expected);
	cmp(actual, expected, MASK_64BIT);

	$display("==========================================================");
	$display("--------------- TEST C3: Counter Overflow ----------------");
	$display("==========================================================");
	timer_en 	= 1'b1;
	div_en	 	= 1'b0;
	div_val  	= 4'b0000;
	int_en		= 1'b0;
	int_cmp		= 64'h0000000000000000;
	start_count 	= 64'hFFFFFFFFFFFFFFFA;
	test_cycles	= 5;

	counter_dut(timer_en, div_en, div_val, int_en, start_count, int_cmp, test_cycles, actual, elapsed_cycles);
	counter_check(timer_en, div_en, div_val, start_count, elapsed_cycles, expected);
	
	if (expected !== actual) begin
		$display("t=%10d FAIL: the counter overflow and the value is not %h",$time, expected);
		error = error + 1;
	end else begin
		$display("t=%10d PASS: the counter overflow and the value after overflow is %h", $stime, expected);
	end

	$display("==========================================================");
	$display("--------------- TEST C4: Counter Disable -----------------");
	$display("==========================================================");
	
	$display("After counter stops counting (timer_en H -> L)");
	read(TDR0_ADDR, actual[31:0]);
	read(TDR1_ADDR, actual[63:32]);
	expected = 64'h0;	
	cmp(actual, expected, MASK_64BIT);

	end
endtask

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
	$display("------------ TEST CC1: Counter Control Mode --------------");
	$display("==========================================================");

	// Count task
	timer_en 	= 1'b1;
	div_en	 	= 1'b1;		// Enable Control mode
	div_val 	= 4'b0000;
	int_en		= 1'b0;
	int_cmp		= 64'h0000000000000000;

	// Loop for testing
	for (div_val = 4'b0000; div_val <= 4'b1000; div_val = div_val + 1) begin
		start_count 	= $urandom_range(64'h0000000000000000, 64'hFFFFFFFFFFFFFFFF);
		test_cycles	= $urandom_range(200, 500);
//		start_count	= 64'h1;
//		test_cycles	= 10;
		$display("                              ");
		$display("Running test with div_val = %b (Counting Speed is divided by %2d)", div_val, 1 << div_val);
		$display("                              ");
		$display("Test cycles = %3d", test_cycles);
		$display("                              ");
		$display("Counting from = %h", start_count);
		$display("                              ");
		counter_dut(timer_en, div_en, div_val, int_en, start_count, int_cmp, test_cycles, actual, elapsed_cycles);
		counter_check(timer_en, div_en, div_val, start_count, elapsed_cycles, expected);
		$display("It took %3d period for counter to increase its value", 1 << div_val);
		cmp(actual, expected, MASK_64BIT);
	end
	
	$display("==========================================================");
	$display("--------- TEST CC2: Counter Div Change Prohibit ----------");
	$display("==========================================================");

	$display("Set timer_en = 0"); 
	write(TCR_ADDR, 32'b0);
	#5;
	$display("Change div_val = 4'b0101"); 
	write(TCR_ADDR, {20'b0, 4'b0101, 6'b0, 2'b0});
	read(TCR_ADDR, actual);
	expected = 32'h00000500;
	cmp(actual, expected, MASK_64BIT);

	$display("Set timer_en = 1 and div_en = 1"); 
	write(TCR_ADDR, 32'h00000503);
	read(TCR_ADDR, actual);
	expected = 32'h00000503;
	cmp(actual, expected, MASK_64BIT);

	$display("Choose prohibit div_val = 4'b1010 ===> Div_val doesn't change");
	write(TCR_ADDR, 32'h00000a00);
	read(TCR_ADDR, actual);
	expected = 32'h00000500;
	cmp(actual, expected, MASK_64BIT);
	end
endtask

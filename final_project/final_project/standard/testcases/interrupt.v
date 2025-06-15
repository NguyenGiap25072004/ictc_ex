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

		$display("=============================================");
		$display("-------- TEST I1: INTERRUPT ASSERTED --------");
		$display("=============================================");

		// Counter data initilize
		timer_en 	= 1'b1;
		div_en	 	= 1'b0;
		div_val  	= 4'b0000;
		int_en		= 1'b1;
//		start_count 	= $urandom_range(64'h0000000000000000, 64'h00000000000000FF);
//		int_cmp 	= $urandom_range(64'h0000000000000000, 64'h000000000000FFFF);
//		test_cycles	= $urandom_range(200, 500);
		start_count     = 64'hFFFF_FFFF_FFFF_FFF0;
		int_cmp         = 64'hFFFF_FFFF_FFFF_FFF9;
		test_cycles     = 10;

		counter_dut(timer_en, div_en, div_val, int_en, start_count, int_cmp, test_cycles, actual, elapsed_cycles);


		// Read interrupt status
		$display("Interrupt register status");  	 	
		read(TISR_ADDR, actual);
		cmp(actual[0], 1'b1, 1'b1);

		// Check interrupt pin 	 	
		$display("Interrupt output status");
		cmp(tim_int, 1'b1, 1'b1);

		$display("=============================================");
		$display("-------- TEST I2: INTERRUPT MASK ------------");
		$display("=============================================");
		
		$display("Clear interrupt enable bit in TIER register bit 0");
		write(TIER_ADDR, 32'h00000000);
		$display("Check interrupt status in TISR Register bit 0");
		read(TISR_ADDR, actual);
		cmp(tim_int, 1'b0, 1'b1);
		$display("Set int_en = 0 turn interrupt pin into low");
		cmp(actual[0], 1'b1, 1'b1);
		$display("Set int_en = 0 do not clear interrupt status bit");

		$display("=============================================");
		$display("-------- TEST I3: INTERRUPT CLEARED ---------");
		$display("=============================================");
	
		// Read status interrupt
		read(TISR_ADDR, actual);
		$display("The interrupt status is %h", actual[0]);
		$display("Write 1 to clear interrupt status");
		write(TISR_ADDR, 32'h1);
		read(TISR_ADDR, actual);
		cmp(actual[0], 1'b0, 1'b1);

	end
endtask

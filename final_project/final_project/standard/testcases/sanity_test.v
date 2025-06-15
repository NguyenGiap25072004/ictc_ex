task run_test;
     reg [31:0]	read_data;

     begin	
 	$display("====================================");
	$display("-----------SANITY TEST--------------");
	$display("====================================");

	reset_dut();
	
	read(TDR0_ADDR, read_data);
	cmp(read_data, TDR0_DEFAULT, TDR_TCMP_MASK);
	
	// Write to TCMP0
	write(TCMP0_ADDR, 32'h0000FFFF);	
	read(TCMP0_ADDR, read_data);
	cmp(read_data, 32'h0000FFFF, TDR_TCMP_MASK);

	// Write to TCMP1
	write(TCMP1_ADDR, 32'h00000000);	
	read(TCMP1_ADDR, read_data);
	cmp(read_data, 32'h00000000, TDR_TCMP_MASK);

	// Enable Interrupt
	write(TIER_ADDR, 32'h00000001);
	read(TIER_ADDR, read_data);
	cmp(read_data, 32'h00000001, TIER_MASK);

	// Start Timer
	write(TCR_ADDR, 32'h00000001);
	read(TCR_ADDR, read_data);
	cmp(read_data, 32'h00000001, TCR_MASK);

	// Interrupt Assertion
	repeat (65535) @ (posedge clk);
	if (tim_int == 1) begin
		$display("-----------INTERRUPT IS HERE --------------");	
	end else begin
		$display("-----------NO INTERRUPT --------------");
		error = error + 1;
	end
     end
endtask

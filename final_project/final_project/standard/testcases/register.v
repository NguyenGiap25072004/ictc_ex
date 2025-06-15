task run_test;
	reg [31:0] read_data;
	
     	begin	
 		$display("=============================================");
		$display("----- TEST R1: REGISTER INITIALIZATION ------");
		$display("=============================================");
		
		reset_dut();
		
		$display("---------   TCR Register   ---------");
		read(TCR_ADDR, read_data);
		cmp(read_data, TCR_DEFAULT, TCR_MASK);
		
		$display("---------   TDR0 Register  ---------");
		read(TDR0_ADDR, read_data);
		cmp(read_data, TDR0_DEFAULT, TDR_TCMP_MASK);

		$display("---------   TDR1 Register  ---------");
		read(TDR1_ADDR, read_data);
		cmp(read_data, TDR1_DEFAULT, TDR_TCMP_MASK);

		$display("--------   TCMP0 Register  ---------");
		read(TCMP0_ADDR, read_data);
		cmp(read_data, TCMP0_DEFAULT, TDR_TCMP_MASK);	

		$display("--------   TCMP1 Register  ---------");
		read(TCMP1_ADDR, read_data);
		cmp(read_data, TCMP1_DEFAULT, TDR_TCMP_MASK);		

		$display("---------   TIER Register  ---------");
		read(TIER_ADDR, read_data);
		cmp(read_data, TIER_DEFAULT, TIER_MASK);

		$display("---------   TISR Register  ---------");
		read(TISR_ADDR, read_data);
		cmp(read_data, TISR_DEFAULT, TISR_MASK);

		$display("---------   THCSR Register  --------");
		read(THCSR_ADDR, read_data);
		cmp(read_data, THCSR_DEFAULT, TISR_MASK);
	
		$display("=============================================");
		$display("--------- TEST R2: REGISTER ACCESS ----------");
		$display("=============================================");

		$display("---------   TCR Register   ---------");
		write(TCR_ADDR, 32'h10101000);
		read(TCR_ADDR, read_data);
		cmp(read_data, 32'h00000000, TCR_MASK);

		$display("---------   TDR0 Register  ---------");
		write(TDR0_ADDR, 32'h00000F0F);
		read(TDR0_ADDR, read_data);
		cmp(read_data, 32'h00000F0F, TDR_TCMP_MASK);		

		$display("---------   TDR1 Register  ---------");
		write(TDR1_ADDR, 32'h0000F0F0);
		read(TDR1_ADDR, read_data);
		cmp(read_data, 32'h0000F0F0, TDR_TCMP_MASK);
		
		$display("--------   TCMP0 Register  ---------");
		write(TCMP0_ADDR, 32'h00000000);
		read(TCMP0_ADDR, read_data);
		cmp(read_data, 32'h00000000, TDR_TCMP_MASK);

		$display("--------   TCMP1 Register  ---------");
		write(TCMP1_ADDR, 32'h00000000);
		read(TCMP1_ADDR, read_data);
		cmp(read_data, 32'h00000000, TDR_TCMP_MASK);

		$display("---------   TIER Register  ---------");
		write(TIER_ADDR, 32'h00001111);
		read(TIER_ADDR, read_data);
		cmp(read_data, 32'h00000001, TIER_MASK);

		$display("---------   TISR Register  ---------");
		write(TISR_ADDR, 32'h00001111);
		read(TISR_ADDR, read_data);
		cmp(read_data, 32'h00000000, TISR_MASK);

		$display("---------   THCSR Register  --------");
		write(THCSR_ADDR, 32'h00001111);
		read(THCSR_ADDR, read_data);
		cmp(read_data, 32'h00000001, TISR_MASK);

		$display("===============================================");
		$display("--------- TEST R3: REG RESERVED BITS ----------");
		$display("===============================================");

		reset_dut();
		$display("Write to reserved bits of TCR, TIER, TISR.");
		$display("						");
		$display("---------   TCR Register   ---------");
		write(TCR_ADDR, 32'hFFFFF0FC);
		read(TCR_ADDR, read_data);
		cmp(read_data, 32'h0, TDR_TCMP_MASK);
		
		$display("---------   TIER Register  ---------");
		write(TIER_ADDR, 32'h11111110);
		read(TIER_ADDR, read_data);
		cmp(read_data, 32'h0, TDR_TCMP_MASK);
		
		$display("---------   TISR Register  ---------");
		write(TISR_ADDR, 32'h11111110);
		read(TISR_ADDR, read_data);
		cmp(read_data, 32'h0, TDR_TCMP_MASK);

		$display("---------   THCSR Register  --------");
		write(THCSR_ADDR, 32'h11111110);
		read(THCSR_ADDR, read_data);
		cmp(read_data, 32'h0, TDR_TCMP_MASK);


		$display("=============================================");
		$display("--------- TEST R4: TISR RW1C CHECK ----------");	
		$display("=============================================");

		// Trigger interrupt first
		reset_dut();
		write(TIER_ADDR, 32'h00000001);
		write(TCMP0_ADDR, 32'h00000100);
		write(TCMP1_ADDR, 32'h00000000);
		write(TDR0_ADDR, 32'h00000100);
		write(TDR1_ADDR, 32'h00000000);
		write(TCR_ADDR, 32'h00000001); 		
		read(TISR_ADDR, read_data);
		cmp(read_data, 32'h00000001, TISR_MASK);

		$display("------- INTERRUPT TRIGGERED --------");

		write(TISR_ADDR, 32'h00000001);
		$display("--------- CLEAR INTERRUPT ----------");
		read(TISR_ADDR, read_data);
		cmp(read_data, 32'h00000000, TISR_MASK);


	end
endtask

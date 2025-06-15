task run_test;
	reg [31:0] 	read_data;
	reg [31:0]	address;
	integer		choice;
	parameter 	BASE_ADDR 	= 32'h40001000;
	parameter       END_ADDR  	= 32'h4000101C;
	parameter       NON_DEF_ADDR  	= 32'h40001020;

	begin
	
	reset_dut();		
	
	$display("=============================================");
	$display("---------- TEST A1: APB WRITE/READ ----------");
	$display("=============================================");
	
	write(TDR0_ADDR, 32'h00000F0F);
	read(TDR0_ADDR, read_data);
	cmp(read_data, 32'h00000F0F, TDR_TCMP_MASK);

	$display("=============================================");
	$display("---- TEST A2: WRITE TO INVALID ADDRESSES ----");
	$display("=============================================");
	
	choice 	= $urandom_range(0, 1);
       	if (choice == 0) begin
		address = $urandom_range(32'h0 , BASE_ADDR - 1);
	end else begin
		address	= $urandom_range(END_ADDR + 1, 32'hFFFFFFFF);
	end

	write(address, 32'h10101001);
	read(address , read_data);
	cmp(read_data, RDATA_DEFAULT, TDR_TCMP_MASK);
	


	$display("===================================================");
	$display("---- TEST A3: WRITE TO NON-DEFINED ADDRESSES ------");
	$display("===================================================");

	reset_dut();		
	write(NON_DEF_ADDR, 32'h0000000F);
	read(NON_DEF_ADDR, read_data);
	cmp(read_data, RDATA_DEFAULT, TDR_TCMP_MASK);

	end
endtask

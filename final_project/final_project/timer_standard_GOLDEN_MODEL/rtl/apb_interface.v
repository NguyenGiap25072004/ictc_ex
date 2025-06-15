module apb_interface (
	// System signals
	input wire		clk, 
	input wire		rst_n,
	// APB  signals from Master
	input wire 		psel, pwrite, penable, 
	input wire [31:0] 	paddr, 
	// Output to APB Master
	output wire		pslverr, pready,
	output wire [11:0]	addr,
	output wire 		wr_en, rd_en
);
	
	// Transform APB signals into IP signals
	wire 		addr_valid 	= (paddr[31:12] == 20'h40001);	// Base address check
	
	assign          wr_en       	= psel & pwrite  & penable & addr_valid;
	assign          rd_en       	= psel & ~pwrite & penable & addr_valid;
	assign 		addr     	= paddr[11:0];		// 12 bits address to register

	assign 		pready 		= 1'b1;			// No wait state
	assign 		pslverr  	= 1'b0;                 // No error handling
	
endmodule


module apb_interface (
	// System signals
	input wire		clk,
	input wire		rst_n,
	// APB signals from Master
	input wire 		psel, pwrite, penable,
	input wire [31:0] 	paddr,
	// Output to APB Master
	output wire		pslverr, pready,
	output wire [11:0]	addr,
	output wire 		wr_en, rd_en
);

	// Base address check to validate the access
	wire 		addr_valid = (paddr[31:12] == 20'h40001);

	// Generate internal read/write strobes from APB signals
	assign		wr_en	= psel & pwrite  & penable & addr_valid;
	assign		rd_en	= psel & ~pwrite & penable & addr_valid;

	// Extract the 12-bit offset address for internal use
	assign 		addr	= paddr[11:0];

	// Implement simplified APB response (no wait, no error)
	assign 		pready 	= 1'b1;
	assign 		pslverr	= 1'b0;

endmodule

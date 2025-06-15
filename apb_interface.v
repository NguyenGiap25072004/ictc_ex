module apb_interface (
	// System signals
	input wire		clk,
	input wire		rst_n,
	// APB signals from Master
	input wire 		psel, pwrite, penable,
	input wire [31:0] 	paddr,
	// Output to APB Master
	output wire		pslverr, pready,
	// Decoded signals for internal blocks
	output wire [11:0]	addr,
	output wire 		wr_en, rd_en
);

	// The IP is considered selected only when the base address matches.
	wire is_addr_valid = (paddr[31:12] == 20'h40001);

	// Generate a single-cycle write strobe for the register block.
	assign wr_en = psel && pwrite && penable && is_addr_valid;
	
	// Generate a single-cycle read strobe for the register block.
	assign rd_en = psel && !pwrite && penable && is_addr_valid;
	
	// Provide the lower 12 bits of the address to the register block.
	assign addr = paddr[11:0];

	// This timer IP does not have wait states.
	assign pready = 1'b1;
	
	// This timer IP does not generate slave errors.
	assign pslverr = 1'b0;

endmodule

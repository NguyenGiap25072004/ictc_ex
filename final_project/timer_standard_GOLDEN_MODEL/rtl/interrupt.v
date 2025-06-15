module interrupt (
	// Input
	input wire 	int_en,		// From register
	input wire	int_st,
	// Output signals
	output wire	interrupt	// System output
);
	assign interrupt = int_st & int_en;
endmodule

module interrupt (
	// Input from register block
	input wire 	int_en,
	input wire	int_st,
	// System interrupt output
	output wire	interrupt
);
	// Interrupt is asserted only when status is pending AND enable bit is set
	assign interrupt = int_st & int_en;

endmodule

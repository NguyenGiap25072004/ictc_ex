// This module generates the final interrupt output signal
module interrupt (
	// Inputs from the register block
	input wire 	int_en,		// Interrupt enable bit from TIER
	input wire	int_st,		// Interrupt status bit from TISR
	// Final interrupt signal to top-level
	output wire	interrupt
);

	// The interrupt signal is a logical AND of the status and enable bits.
	assign interrupt = (int_st && int_en);
	
endmodule

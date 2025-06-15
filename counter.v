module counter (
	// System
	input wire 		clk,
	input wire 		rst_n,
	// Input signals
	input wire		count_en,
	input wire 		tdr0_wr_sel,
	input wire 		tdr1_wr_sel,
	input wire [31:0]	wdata,
	// Output signals
	output wire [63:0] 	count_val
);

	// Internal 64-bit counter register
	reg [63:0] 	count_reg;

	// Counter logic: handles reset, software writes, and counting
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			count_reg <= 64'd0;
		end
		// Priority: Software write has higher priority than counting
		else if (tdr0_wr_sel) begin
			count_reg[31:0] <= wdata;
		end
		else if (tdr1_wr_sel) begin
			count_reg[63:32] <= wdata;
		end
		// If enabled, perform counting
		else if (count_en) begin
			// Check for overflow and wrap around
			if (count_reg == 64'hFFFF_FFFF_FFFF_FFFF)
				count_reg <= 64'd0;
			else
				count_reg <= count_reg + 1;
		end
	end

	// Assign internal register to output
	assign count_val = count_reg;

endmodule

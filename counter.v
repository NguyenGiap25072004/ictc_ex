module counter (
	// System signals
	input wire 		clk,
	input wire 		rst_n,
	// Control and data inputs
	input wire		count_en,    // Enable signal from counter_control block
	input wire 		tdr0_wr_sel, // Write select for lower 32 bits
	input wire 		tdr1_wr_sel, // Write select for upper 32 bits
	input wire [31:0]	wdata,       // Write data from APB bus
	// Counter value output
	output wire [63:0] 	count_val
);

	// Internal register to hold the 64-bit count value
	reg [63:0] 	counter_value_reg;

	// Main sequential block for the counter
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			counter_value_reg <= 64'h0;
		end else begin
			// Software writes have the highest priority
			if (tdr0_wr_sel) begin
				counter_value_reg[31:0]  <= wdata;
			end else if (tdr1_wr_sel) begin
				counter_value_reg[63:32] <= wdata;
			// Counting is performed if enabled and no writes are occurring
			end else if (count_en) begin
			    // Handle overflow condition
				if (counter_value_reg == 64'hFFFFFFFFFFFFFFFF)
					counter_value_reg <= 64'h0;
				else
					counter_value_reg <= counter_value_reg + 1;
			// If no write and not enabled, hold the value
			end else begin
				counter_value_reg <= counter_value_reg;
			end
		end
	end

	// Connect internal register to the output port
	assign count_val = counter_value_reg;
	
endmodule

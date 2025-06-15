module counter_control (
	// System signals
	input wire 		clk,
	input wire 		rst_n,
	// Register signals
	input wire 		timer_en,
	input wire 		div_en,
	input wire [3:0] 	div_val,
	// To counter
	output wire 		count_en
);

	// Internal counter for division logic
	reg  [7:0]	div_count;
	wire [7:0]	div_limit;

	// Combinational logic to determine the division limit
	assign div_limit = (div_val == 4'b0000) ? 8'd0 :
	                   (div_val == 4'b0001) ? 8'd1 :
	                   (div_val == 4'b0010) ? 8'd3 :
	                   (div_val == 4'b0011) ? 8'd7 :
	                   (div_val == 4'b0100) ? 8'd15 :
	                   (div_val == 4'b0101) ? 8'd31 :
	                   (div_val == 4'b0110) ? 8'd63 :
	                   (div_val == 4'b0111) ? 8'd127 :
	                   (div_val == 4'b1000) ? 8'd255 :
	                   8'd0; 

	// Tick generation logic
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			div_count <= 8'd0;
		end
		// When timer is disabled, reset the divider
		else if (!timer_en) begin
			div_count <= 8'd0;
		end
		// When division mode is active
		else if (div_en) begin
			if (div_count == div_limit)
				div_count <= 8'd0;
			else
				div_count <= div_count + 1;
		end
		// In default mode, reset the divider
		else begin
		    div_count <= 8'd0;
		end
	end

	// The final count_en is generated based on mode and state
	assign count_en = timer_en &&
	                  ( (div_en && (div_count == div_limit)) || !div_en );

endmodule

module counter_control (
	// System signals
	input wire 		clk,
	input wire 		rst_n,
	// Inputs from Register block
	input wire 		timer_en,
	input wire 		div_en,
	input wire [3:0] 	div_val,
	// Output to Counter block
	output wire 		count_en
);

	// Internal register for division counting
	reg [7:0]	divider_reg;
	// Internal register to generate the final tick, creating a 1-cycle latency
	reg 		tick_enable_reg;

	// This function determines the divider limit based on div_val.
	// This logic is kept identical to the original student's refactored version.
	function [7:0] get_limit;
		input [3:0] div_val_in;
		begin
			case (div_val_in)
				4'b0000: get_limit = 8'd0;
				4'b0001: get_limit = 8'd1;
				4'b0010: get_limit = 8'd3;
				4'b0011: get_limit = 8'd7;
				4'b0100: get_limit = 8'd15;
				4'b0101: get_limit = 8'd31;
				4'b0110: get_limit = 8'd63;
				4'b0111: get_limit = 8'd127;
				4'b1000: get_limit = 8'd255;
				default: get_limit = 8'd0; // Safe default
			endcase
		end
	endfunction

	// Sequential logic that mimics the original's behavior, including the 1-cycle latency
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			tick_enable_reg <= 1'b0;
			divider_reg	    <= 8'b0;
		end else begin
			if (timer_en) begin
				if (div_en) begin
					// Controlled counting mode
					if (divider_reg == get_limit(div_val)) begin
						divider_reg 	<= 8'b0;
						tick_enable_reg	<= 1'b1;
					end else begin
						divider_reg	    <= divider_reg + 1;
						tick_enable_reg	<= 1'b0;
					end
				end else begin
					// Default mode: tick every cycle
					tick_enable_reg	<= 1'b1;
				end
			end else begin
				// Reset state and tick when timer is disabled
				divider_reg		<= 8'b0;
				tick_enable_reg	<= 1'b0;
			end
		end
	end
	
	// Final output assignment from the register
	assign count_en = tick_enable_reg;

endmodule

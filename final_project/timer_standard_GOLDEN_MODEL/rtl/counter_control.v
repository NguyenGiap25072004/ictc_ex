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
	// Internal register
	reg [7:0]	div_count;
	reg 		count_en_reg;
	// Function for choosing div val
	function [7:0] limit;
		input [3:0]  div_val_in;
		begin
			case (div_val_in)
				4'b0000: limit = 8'd0;		// No division
				4'b0001: limit = 8'd1;
				4'b0010: limit = 8'd3;
				4'b0011: limit = 8'd7;
				4'b0100: limit = 8'd15;
				4'b0101: limit = 8'd31;
				4'b0110: limit = 8'd63;
				4'b0111: limit = 8'd127;
				4'b1000: limit = 8'd255;
				default: limit = limit;
			endcase
		end
	endfunction
	// Counter control logic	
	always @ (posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			count_en_reg 	<= 1'h0;
			div_count	<= 8'h0;
		end else begin
			if (timer_en) begin
				if (div_en) begin
					// Control mode
					if (div_count == limit(div_val)) begin
						div_count 	<= 8'h0;
						count_en_reg	<= 1'h1;
					end else begin
						div_count	<= div_count + 1'h1;
						count_en_reg	<= 1'h0;
					end
				end else begin
					// Default mode
					count_en_reg		<= 1'h1;
				end
			end else begin 
				// Timer disable
				div_count		<= 8'h0;
				count_en_reg		<= 1'h0;
			end
		end
	end
	
	// Output	
	assign count_en = count_en_reg;

endmodule


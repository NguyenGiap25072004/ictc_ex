module counter (
	// System
	input wire 		clk, rst_n,
	// Input signals
        input wire		count_en,
	input wire 		tdr0_wr_sel, tdr1_wr_sel,
	input wire [31:0]	wdata,
	// Output signals
	output wire [63:0] 	count_val
);
	// Internal register
	reg [63:0] 	count_reg;
	// Counter logic
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			count_reg <= 64'h0;
		end else begin
		// Initialization form TDR0_1 registers
			if (tdr0_wr_sel) begin
				count_reg[31:0]  <= wdata;
			end else if (tdr1_wr_sel) begin
				count_reg[63:32] <= wdata;
			end else if (count_en) begin
			    if (count_reg == 64'hFFFFFFFFFFFFFFFF)
				count_reg <= 64'h0;
			    else 
				count_reg <= count_reg + 64'h1;
			end else begin
				count_reg <= count_reg;
			end
		end
	end
	// Output
	assign count_val	= count_reg;
endmodule

module register(
	// System signals
	input  wire 		clk,
	input  wire 		rst_n,
	// Input from APB Interface
	input  wire 		wr_en,
	input  wire 		rd_en,
	input  wire [11:0] 	addr,
	input  wire [31:0]	wdata,
	// Input from Counter
	input  wire [63:0]	count_val,
	// Output to other blocks
	output wire 		tdr0_wr_sel,
	output wire		tdr1_wr_sel,
	output wire         timer_en,
	output wire         div_en,
	output wire [3:0]	div_val,
	output wire 		int_en,
	output wire		    int_st,
	// Output to APB Interface
	output wire [31:0]  rdata
);
	// Address Decoding Parameters
	localparam TCR_ADDR   = 12'h000;
	localparam TDR0_ADDR  = 12'h004;
	localparam TDR1_ADDR  = 12'h008;
	localparam TCMP0_ADDR = 12'h00C;
	localparam TCMP1_ADDR = 12'h010;
	localparam TIER_ADDR  = 12'h014;
	localparam TISR_ADDR  = 12'h018;
	localparam THCSR_ADDR = 12'h01C;

	// Internal signals and registers
	reg [7:0]  sel_reg; // One-hot select register
	reg [31:0] tcr_reg;
	reg [31:0] tcmp0_reg, tcmp1_reg;
	reg [31:0] tier_reg;
	reg [31:0] tisr_reg;
	reg [31:0] thcsr_reg;
	reg [31:0] rdata_reg;

	wire compare_match;

	// One-hot address decoder (Combinational, corrected from original)
	always @(*) begin
		case (addr)
			TCR_ADDR:   sel_reg = 8'b0000_0001;
			TDR0_ADDR:  sel_reg = 8'b0000_0010;
			TDR1_ADDR:  sel_reg = 8'b0000_0100;
			TCMP0_ADDR: sel_reg = 8'b0000_1000;
			TCMP1_ADDR: sel_reg = 8'b0001_0000;
			TIER_ADDR:  sel_reg = 8'b0010_0000;
			TISR_ADDR:  sel_reg = 8'b0100_0000;
			THCSR_ADDR: sel_reg = 8'b1000_0000;
			default:    sel_reg = 8'b0000_0000;
		endcase
	end

	// TCR (Timer Control Register) Logic
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			tcr_reg <= 32'h0000_0100; // Default: div_val = 1
		else if (wr_en && sel_reg[0]) begin // Check write to TCR
			tcr_reg[0]      <= wdata[0];  // timer_en
			tcr_reg[1]      <= wdata[1];  // div_en
			if (wdata[11:8] <= 4'b1000)   // Only update div_val if valid
				tcr_reg[11:8] <= wdata[11:8];
		end
	end

	// TCMP (Timer Compare Registers) Logic
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			tcmp0_reg <= 32'hFFFF_FFFF;
			tcmp1_reg <= 32'hFFFF_FFFF;
		end else begin
			if (wr_en && sel_reg[3]) tcmp0_reg <= wdata; // Check write to TCMP0
			if (wr_en && sel_reg[4]) tcmp1_reg <= wdata; // Check write to TCMP1
		end
	end

	// TIER (Timer Interrupt Enable Register) Logic
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			tier_reg <= 32'h0;
		else if (wr_en && sel_reg[5]) // Check write to TIER
			tier_reg[0] <= wdata[0];
	end

	// TISR (Timer Interrupt Status Register) Logic
	assign compare_match = (count_val == {tcmp1_reg, tcmp0_reg});
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			tisr_reg[0] <= 1'b0;
		else if (wr_en && sel_reg[6] && wdata[0]) // W1C for TISR
			tisr_reg[0] <= 1'b0;
		else if (compare_match)
			tisr_reg[0] <= 1'b1;
	end

	// THCSR (Timer Halt Control Status Register) Logic - Dummy register
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			thcsr_reg <= 32'h0;
		else if (wr_en && sel_reg[7]) // Check write to THCSR
			thcsr_reg[0] <= wdata[0];
	end

	// Read Data Mux - Purely combinational to avoid latches
	always @(*) begin
	    // The sel_reg is one-hot, so a parallel case is fine.
		case (sel_reg)
			8'b0000_0001: rdata_reg = tcr_reg;
			8'b0000_0010: rdata_reg = count_val[31:0];
			8'b0000_0100: rdata_reg = count_val[63:32];
			8'b0000_1000: rdata_reg = tcmp0_reg;
			8'b0001_0000: rdata_reg = tcmp1_reg;
			8'b0010_0000: rdata_reg = tier_reg;
			8'b0100_0000: rdata_reg = tisr_reg;
			8'b1000_0000: rdata_reg = thcsr_reg;
			default:      rdata_reg = 32'd0; // RAZ: Read-As-Zero
		endcase
	end

	// Output Assignments
	assign timer_en    = tcr_reg[0];
	assign div_en      = tcr_reg[1];
	assign div_val     = tcr_reg[11:8];
	assign tdr0_wr_sel = wr_en && sel_reg[1]; // Use sel_reg for write select
	assign tdr1_wr_sel = wr_en && sel_reg[2]; // Use sel_reg for write select
	assign int_en      = tier_reg[0];
	assign int_st      = tisr_reg[0];
	assign rdata       = rd_en ? rdata_reg : 32'bz; // Output z when not reading

endmodule

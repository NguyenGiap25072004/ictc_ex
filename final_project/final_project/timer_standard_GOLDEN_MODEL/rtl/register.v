module register(	
	// System signals
	input  wire 		clk,
	input  wire 		rst_n,
	// Input 
	input  wire 		wr_en,
	input  wire 		rd_en,
	input  wire [11:0] 	addr,
	input  wire [31:0]	wdata,
	input  wire [63:0]	count_val,
	// Output
	output wire 		tdr0_wr_sel,
	output wire		tdr1_wr_sel,
	output wire             timer_en,
	output wire             div_en,
	output wire [3:0]	div_val,
	output wire 		int_en,
	output wire		int_st,
	output wire [31:0]      rdata
);	
	// Address list
	parameter TCR_ADDR	 = 12'h000;
	parameter TDR0_ADDR	 = 12'h004;
	parameter TDR1_ADDR      = 12'h008;
	parameter TCMP0_ADDR     = 12'h00C;
	parameter TCMP1_ADDR     = 12'h010;
	parameter TIER_ADDR      = 12'h014;
	parameter TISR_ADDR      = 12'h018;
	parameter THCSR_ADDR     = 12'h01C;
	// Default value
	parameter TCR_DEFAULT    = 32'h100;
	parameter TDR0_DEFAULT   = 32'h0;
	parameter TDR1_DEFAULT   = 32'h0;
	parameter TCMP0_DEFAULT  = 32'hFFFFFFFF;
	parameter TCMP1_DEFAULT  = 32'hFFFFFFFF;
	parameter TIER_DEFAULT   = 32'h0;
	parameter TISR_DEFAULT   = 32'h0;
	parameter THCSR_DEFAULT  = 32'h0;
	parameter RDATA_DEFAULT  = 32'h0;
	// Internal signal list
	reg [7:0] 	sel_reg;	// Decoder
	reg [31:0]	tcr_reg;	// timer control register 
	reg [31:0]      tdr0_reg;
	reg [31:0]      tdr1_reg;
	reg [31:0]      tcmp0_reg;
	reg [31:0]      tcmp1_reg;
	reg [31:0]      tier_reg;
	reg [31:0]      tisr_reg;
	reg [31:0]      thcsr_reg;
	reg [31:0]	rdata_reg;   	
	
	wire [31:0]	tdr0_temp;
	wire [31:0]     tdr1_temp;
	wire		div_val_en;
	wire		compare_match;
	// Choose address via one hot decoder
	always @ (*) begin
		if (!rst_n) begin
			sel_reg	= 8'h0;
		end else begin
		case (addr)
		 	TCR_ADDR   :  	 sel_reg = 8'b00000001;
			TDR0_ADDR  :	 sel_reg = 8'b00000010;
			TDR1_ADDR  :     sel_reg = 8'b00000100;
			TCMP0_ADDR :     sel_reg = 8'b00001000;
			TCMP1_ADDR :     sel_reg = 8'b00010000;
			TIER_ADDR  :	 sel_reg = 8'b00100000;
			TISR_ADDR  :     sel_reg = 8'b01000000;
			THCSR_ADDR :     sel_reg = 8'b10000000;
			default:	 sel_reg = 8'b00000000;
		endcase
		end	
	end
	// TCR Register
	assign div_val_en = (wdata[11:8] <= 4'b1000);		// Condition - 
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) 
			tcr_reg 	<= TCR_DEFAULT;
		else begin
			if (sel_reg[0] && wr_en && div_val_en ) begin	// && !tcr_reg[0] div_val changes when timer_en is LOW
				tcr_reg[11:8] 	<= wdata[11:8];
			end else begin
				tcr_reg[11:8] 	<= tcr_reg[11:8];
			end

			if (sel_reg[0] && wr_en) begin			// div_en  && !tcr_reg[0]
				tcr_reg[1]	<= wdata[1];
			end else begin
				tcr_reg[1]	<= tcr_reg[1];
			end

			if (sel_reg[0] && wr_en) begin				// timer_en
				tcr_reg[0]	<= wdata[0];
			end else begin
				tcr_reg[0]      <= tcr_reg[0];
			end
		end		
	end

	// TDR0 Register
	assign tdr0_temp = (wr_en && sel_reg[1]) ? wdata : count_val[31:0];
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			tdr0_reg		<= TDR0_DEFAULT;
		else 
			tdr0_reg		<= tdr0_temp;
	end
	// TDR1 Register
	assign tdr1_temp = (wr_en && sel_reg[2]) ? wdata : count_val[63:32];
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			tdr1_reg        	<= TDR1_DEFAULT;
		else
			tdr1_reg                <= tdr1_temp;
	end
	// TCMP0 Register
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			tcmp0_reg 		<= TCMP0_DEFAULT;
		else if (wr_en && sel_reg[3])
			tcmp0_reg           	<= wdata;
		else
			tcmp0_reg		<= tcmp0_reg;
	end
	// TCMP1 Register
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			tcmp1_reg               <= TCMP1_DEFAULT;
		else if (wr_en && sel_reg[4])
			tcmp1_reg               <= wdata;
		else
			tcmp1_reg               <= tcmp1_reg;
	end
	// TIER Register
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			tier_reg		<= TIER_DEFAULT;
		else if (wr_en && sel_reg[5])
			tier_reg[0]             <= wdata[0];
		else 
			tier_reg[0]             <= tier_reg[0];
	end
	// TISR Register
	assign compare_match = (count_val == {tcmp1_reg, tcmp0_reg});
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			tisr_reg                <= TISR_DEFAULT;
		else if (wr_en && sel_reg[6] && wdata[0])
			tisr_reg[0]	<= 1'b0;
		else if (compare_match) 
			tisr_reg[0]	<= 1'b1;
		else
			tisr_reg[0] 	<= tisr_reg[0];
	end
	// THCSR Register
	always @ (posedge clk or negedge rst_n) begin
                if (!rst_n)
                        thcsr_reg <= THCSR_DEFAULT;
                else if (wr_en && sel_reg[7])
                        thcsr_reg[0] <= wdata[0];
                else 
                        thcsr_reg[0] <= thcsr_reg[0];
        end
	// Read output
	always @ (*) begin
		if (rd_en) begin
		case (sel_reg)
			8'b00000001: rdata_reg = tcr_reg;
			8'b00000010: rdata_reg = tdr0_reg;
			8'b00000100: rdata_reg = tdr1_reg;
			8'b00001000: rdata_reg = tcmp0_reg;
			8'b00010000: rdata_reg = tcmp1_reg;
			8'b00100000: rdata_reg = tier_reg;
			8'b01000000: rdata_reg = tisr_reg;
			8'b10000000: rdata_reg = thcsr_reg;
			default:     rdata_reg = RDATA_DEFAULT;
		endcase
		end else begin
			rdata_reg = RDATA_DEFAULT;
		end
	end
	// Connect to output of module
	assign timer_en		= tcr_reg[0];
	assign div_en		= tcr_reg[1];
	assign div_val		= tcr_reg[11:8];
	assign tdr0_wr_sel	= wr_en && sel_reg[1];
	assign tdr1_wr_sel      = wr_en && sel_reg[2];
	assign int_en           = tier_reg[0];
	assign int_st		= tisr_reg[0];
	assign rdata 		= rdata_reg; 

endmodule

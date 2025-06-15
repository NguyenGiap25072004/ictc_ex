module register(	
	// System signals
	input  wire 		clk,
	input  wire 		rst_n,
	// Interface to APB decoder
	input  wire 		wr_en,
	input  wire 		rd_en,
	input  wire [11:0] 	addr,
	input  wire [31:0]	wdata,
	// Interface to Counter
	input  wire [63:0]	count_val,
	// Interface to other blocks
	output wire 		tdr0_wr_sel,
	output wire		tdr1_wr_sel,
	output wire         timer_en,
	output wire         div_en,
	output wire [3:0]	div_val,
	output wire 		int_en,
	output wire		    int_st,
	// Interface to APB decoder
	output wire [31:0]  rdata
);	
	// Address Map
	parameter TCR_ADDR   = 12'h000;
	parameter TDR0_ADDR  = 12'h004;
	parameter TDR1_ADDR  = 12'h008;
	parameter TCMP0_ADDR = 12'h00C;
	parameter TCMP1_ADDR = 12'h010;
	parameter TIER_ADDR  = 12'h014;
	parameter TISR_ADDR  = 12'h018;
	parameter THCSR_ADDR = 12'h01C;
	
	// Default Values
	parameter TCR_DEFAULT   = 32'h100;
	parameter TDR0_DEFAULT  = 32'h0;
	parameter TDR1_DEFAULT  = 32'h0;
	parameter TCMP0_DEFAULT = 32'hFFFFFFFF;
	parameter TCMP1_DEFAULT = 32'hFFFFFFFF;
	parameter TIER_DEFAULT  = 32'h0;
	parameter TISR_DEFAULT  = 32'h0;
	parameter THCSR_DEFAULT = 32'h0;
	parameter RDATA_DEFAULT = 32'h0;
	
	// Internal signals
	reg [7:0] 	addr_sel_onehot;
	reg [31:0]	timer_ctrl_reg;
	reg [31:0]  timer_data0_reg;
	reg [31:0]  timer_data1_reg;
	reg [31:0]  timer_cmp0_reg;
	reg [31:0]  timer_cmp1_reg;
	reg [31:0]  timer_int_en_reg;
	reg [31:0]  timer_int_st_reg;
	reg [31:0]  timer_halt_reg;
	reg [31:0]	read_data_bus;	
	
	wire		div_val_is_valid;
	wire		is_compare_match;
	
	// One-hot address decoder (original flawed logic is preserved)
	always @ (*) begin
		if (!rst_n) begin
			addr_sel_onehot = 8'h0;
		end else begin
            case (addr)
                TCR_ADDR  : addr_sel_onehot = 8'b00000001;
                TDR0_ADDR : addr_sel_onehot = 8'b00000010;
                TDR1_ADDR : addr_sel_onehot = 8'b00000100;
                TCMP0_ADDR: addr_sel_onehot = 8'b00001000;
                TCMP1_ADDR: addr_sel_onehot = 8'b00010000;
                TIER_ADDR : addr_sel_onehot = 8'b00100000;
                TISR_ADDR : addr_sel_onehot = 8'b01000000;
                THCSR_ADDR: addr_sel_onehot = 8'b10000000;
                default:    addr_sel_onehot = 8'b00000000;
            endcase
		end	
	end
	
	// TCR Register Logic
	assign div_val_is_valid = (wdata[11:8] <= 4'b1000);
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) timer_ctrl_reg <= TCR_DEFAULT;
		else begin
			if (addr_sel_onehot[0] && wr_en && div_val_is_valid )
				timer_ctrl_reg[11:8] <= wdata[11:8];
			else
				timer_ctrl_reg[11:8] <= timer_ctrl_reg[11:8];

			if (addr_sel_onehot[0] && wr_en)
				timer_ctrl_reg[1] <= wdata[1];
			else
				timer_ctrl_reg[1] <= timer_ctrl_reg[1];

			if (addr_sel_onehot[0] && wr_en)
				timer_ctrl_reg[0] <= wdata[0];
			else
				timer_ctrl_reg[0] <= timer_ctrl_reg[0];
		end		
	end

	// TDR0 Shadow Register (original flawed logic is preserved)
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			timer_data0_reg <= TDR0_DEFAULT;
		else 
			timer_data0_reg <= (wr_en && addr_sel_onehot[1]) ? wdata : count_val[31:0];
	end
	
	// TDR1 Shadow Register (original flawed logic is preserved)
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			timer_data1_reg <= TDR1_DEFAULT;
		else
			timer_data1_reg <= (wr_en && addr_sel_onehot[2]) ? wdata : count_val[63:32];
	end
	
	// TCMP0 Register
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) timer_cmp0_reg <= TCMP0_DEFAULT;
		else if (wr_en && addr_sel_onehot[3]) timer_cmp0_reg <= wdata;
		else timer_cmp0_reg <= timer_cmp0_reg;
	end
	
	// TCMP1 Register
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) timer_cmp1_reg <= TCMP1_DEFAULT;
		else if (wr_en && addr_sel_onehot[4]) timer_cmp1_reg <= wdata;
		else timer_cmp1_reg <= timer_cmp1_reg;
	end
	
	// TIER Register
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) timer_int_en_reg <= TIER_DEFAULT;
		else if (wr_en && addr_sel_onehot[5]) timer_int_en_reg[0] <= wdata[0];
		else timer_int_en_reg[0] <= timer_int_en_reg[0];
	end
	
	// TISR Register
	assign is_compare_match = (count_val == {timer_cmp1_reg, timer_cmp0_reg});
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) timer_int_st_reg <= TISR_DEFAULT;
		else if (wr_en && addr_sel_onehot[6] && wdata[0]) timer_int_st_reg[0] <= 1'b0;
		else if (is_compare_match) timer_int_st_reg[0] <= 1'b1;
		else timer_int_st_reg[0] <= timer_int_st_reg[0];
	end
	
	// THCSR Register
	always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) timer_halt_reg <= THCSR_DEFAULT;
        else if (wr_en && addr_sel_onehot[7]) timer_halt_reg[0] <= wdata[0];
        else timer_halt_reg[0] <= timer_halt_reg[0];
    end
    
	// Read Mux (original latchy logic is preserved)
	always @ (*) begin
		if (rd_en) begin
            case (addr_sel_onehot)
                8'b00000001: read_data_bus = timer_ctrl_reg;
                8'b00000010: read_data_bus = timer_data0_reg;
                8'b00000100: read_data_bus = timer_data1_reg;
                8'b00001000: read_data_bus = timer_cmp0_reg;
                8'b00010000: read_data_bus = timer_cmp1_reg;
                8'b00100000: read_data_bus = timer_int_en_reg;
                8'b01000000: read_data_bus = timer_int_st_reg;
                8'b10000000: read_data_bus = timer_halt_reg;
                default:     read_data_bus = RDATA_DEFAULT;
            endcase
		end else begin
			read_data_bus = RDATA_DEFAULT;
		end
	end
	
	// Output Assignments
	assign timer_en		= timer_ctrl_reg[0];
	assign div_en		= timer_ctrl_reg[1];
	assign div_val		= timer_ctrl_reg[11:8];
	assign tdr0_wr_sel	= wr_en && addr_sel_onehot[1];
	assign tdr1_wr_sel  = wr_en && addr_sel_onehot[2];
	assign int_en       = timer_int_en_reg[0];
	assign int_st		= timer_int_st_reg[0];
	assign rdata 		= read_data_bus;

endmodule

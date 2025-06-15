module timer_top(
	// System Signals
	input 	wire 		sys_clk,
	input	wire 		sys_rst_n,
	input	wire		dbg_mode,
	// APB Slave Interface
	input 	wire		tim_psel,
	input	wire 		tim_pwrite,
	input	wire 		tim_penable,
	input 	wire [31:0] 	tim_paddr,
	input	wire [31:0] 	tim_pwdata,
	input	wire [3:0]	tim_pstrb,
	output	wire [31:0]	tim_prdata,
	output	wire		tim_pready,
	output	wire		tim_pslverr,
	// Interrupt Output
	output	wire		tim_int
);
	// Internal wires for connecting modules
	wire [11:0] address;
	wire        wr_en, rd_en;
	wire        timer_en, div_en, raw_count_en;
	wire [3:0]  div_val;
	wire        int_en, int_st;
	wire        tdr0_wr_sel, tdr1_wr_sel;
	wire [63:0] count2reg;
	wire        final_count_en; // Wire for final count enable signal

	// ** Implement dbg_mode functionality as per specification **
	// The counter only gets enabled if not in debug mode.
	assign final_count_en = raw_count_en & !dbg_mode;

	apb_interface APB_INTERFACE(
		.clk        (sys_clk),
		.rst_n      (sys_rst_n),
		.psel       (tim_psel),
		.pwrite     (tim_pwrite),
		.penable    (tim_penable),
		.paddr      (tim_paddr),
		.pready     (tim_pready),
		.pslverr    (tim_pslverr),
		.addr       (address),
		.wr_en      (wr_en),
		.rd_en      (rd_en)
	);

	register REG_SET (
		.clk         (sys_clk),
		.rst_n       (sys_rst_n),
		.wr_en       (wr_en),
		.rd_en       (rd_en),
		.addr        (address),
		.wdata       (tim_pwdata),
		.count_val   (count2reg),
		.timer_en    (timer_en),
		.div_en      (div_en),
		.div_val     (div_val),
		.tdr0_wr_sel (tdr0_wr_sel),
		.tdr1_wr_sel (tdr1_wr_sel),
		.int_en      (int_en),
		.int_st      (int_st),
		.rdata       (tim_prdata)
	);

	counter_control COUNTER_CONTROL (
		.clk        (sys_clk),
		.rst_n      (sys_rst_n),
		.timer_en   (timer_en),
		.div_en     (div_en),
		.div_val    (div_val),
		.count_en   (raw_count_en) // Output is the 'raw' enable
	);

	counter COUNTER (
		.clk         (sys_clk),
		.rst_n       (sys_rst_n),
		.count_en    (final_count_en), // Use the final, debug-gated enable
		.tdr0_wr_sel (tdr0_wr_sel),
		.tdr1_wr_sel (tdr1_wr_sel),
		.wdata       (tim_pwdata),
		.count_val   (count2reg)
	);

	interrupt INTERRUPT(
		.int_en    (int_en),
		.int_st    (int_st),
		.interrupt (tim_int)
	);

endmodule

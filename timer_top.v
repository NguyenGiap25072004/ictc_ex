module timer_top(
	input 	wire 		sys_clk,
	input	wire 		sys_rst_n,
	// APB interface
	input 	wire		tim_psel,
	input	wire 		tim_pwrite,
	input	wire 		tim_penable,
	input 	wire [31:0] 	tim_paddr,
	input	wire [31:0] 	tim_pwdata,
	input	wire		dbg_mode, // This input is unused, as per original design
	input	wire [3:0]	tim_pstrb,
	output	wire [31:0]	tim_prdata,
	output	wire		tim_pready,
	output	wire		tim_pslverr,
	output	wire		tim_int
);

	// Wires connecting the sub-modules
	wire [11:0] decoded_addr;
	wire        write_strobe, read_strobe;
	wire        cfg_timer_en, cfg_div_en, tick_en;
	wire [3:0]  cfg_div_val;
	wire        irq_en_bit, irq_status_bit;
	wire        sel_tdr0_write, sel_tdr1_write;
	wire [63:0] current_count_val;

	// Instantiate the APB Interface block
	apb_interface u_apb_if (
		.clk        (sys_clk),
		.rst_n      (sys_rst_n),
		.psel		(tim_psel),
		.pwrite		(tim_pwrite),
		.penable	(tim_penable),
		.paddr		(tim_paddr),
		.pready		(tim_pready),
		.pslverr	(tim_pslverr),
		.addr		(decoded_addr),
		.wr_en		(write_strobe),
		.rd_en		(read_strobe)
	);

	// Instantiate the Register Set block
	register u_reg_file (
		.clk		(sys_clk),
		.rst_n		(sys_rst_n),
		.wr_en		(write_strobe),
		.rd_en		(read_strobe),
		.addr		(decoded_addr),
		.wdata		(tim_pwdata),
		.count_val	(current_count_val),
		.timer_en	(cfg_timer_en),
		.div_en		(cfg_div_en),
		.div_val	(cfg_div_val),
		.tdr0_wr_sel(sel_tdr0_write),
		.tdr1_wr_sel(sel_tdr1_write),
		.int_en		(irq_en_bit),
		.int_st     (irq_status_bit),
		.rdata		(tim_prdata)
	);

	// Instantiate the Counter Control block
	counter_control u_counter_ctrl (
		.clk		(sys_clk),
		.rst_n		(sys_rst_n),
		.timer_en	(cfg_timer_en),
		.div_en		(cfg_div_en),
		.div_val	(cfg_div_val),
		.count_en	(tick_en)
	);

	// Instantiate the Counter block
	counter u_counter (
		.clk		    (sys_clk),
		.rst_n		    (sys_rst_n),
		.count_en	    (tick_en), // NOTE: dbg_mode is NOT connected here, per original logic
		.tdr0_wr_sel	(sel_tdr0_write),
		.tdr1_wr_sel    (sel_tdr1_write),
		.wdata		    (tim_pwdata),
		.count_val	    (current_count_val)
	);

	// Instantiate the Interrupt Generation block
	interrupt u_interrupt (
		.int_en		(irq_en_bit),
		.int_st		(irq_status_bit),
		.interrupt	(tim_int)
	);

endmodule

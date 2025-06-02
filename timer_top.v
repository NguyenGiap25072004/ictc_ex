module timer_top_standard (
    input wire                      sys_clk,
    input wire                      sys_rst_n,

    // APB Interface
    input wire                      tim_psel,
    input wire                      tim_penable,
    input wire                      tim_pwrite,
    input wire [31:0]               tim_paddr,   
    input wire [31:0]               tim_pwdata,
    input wire [3:0]                tim_pstrb,   
    output wire [31:0]              tim_prdata,
    output wire                     tim_pready,
    output wire                     tim_pslverr,

    // Debug Mode Input 
    input wire                      dbg_mode,

    // Interrupt Output
    output wire                     tim_int
);

// Parameters for Sub-Modules
localparam P_APB_ADDR_WIDTH   = 12;
localparam P_APB_DATA_WIDTH   = 32;
localparam P_APB_BASE_ADDR_HI = 20'h4000_1; // For 0x40001xxx

// Internal Wires connecting sub-modules

// APB Slave <-> Register File
wire [P_APB_ADDR_WIDTH-1:0]   s_reg_addr_offset;
wire                          s_reg_wr_en;
wire                          s_reg_rd_en;
wire [P_APB_DATA_WIDTH-1:0]   s_reg_wdata_to_regs; // from APB slave
wire [P_APB_DATA_WIDTH-1:0]   s_reg_rdata_from_regs; // to APB slave

// Register File -> Counter Control
wire                          s_timer_en_for_ctrl;
wire                          s_div_en_for_ctrl;
wire [3:0]                    s_div_val_for_ctrl;
wire                          s_halt_req_for_ctrl; // To counter_control 

// Register File -> Timer Counter
wire                          s_load_tdr0_en;
wire                          s_load_tdr1_en;
wire [P_APB_DATA_WIDTH-1:0]   s_tdr_load_data;

// Timer Counter -> Register File
wire [P_APB_DATA_WIDTH-1:0]   s_counter_val_low_to_reg;
wire [P_APB_DATA_WIDTH-1:0]   s_counter_val_high_to_reg;

// Counter Control -> Timer Counter
wire                          s_main_counter_pulse_en;

// Timer Counter -> Interrupt Logic
wire [63:0]                   s_current_counter_val_to_int_logic;

// Register File -> Interrupt Logic
wire [31:0]                   s_tcmp0_val_from_reg;
wire [31:0]                   s_tcmp1_val_from_reg;
wire [63:0]                   s_current_compare_val_to_int_logic;
wire                          s_timer_en_for_int_logic;
wire                          s_int_module_en_for_int_logic; // TIER.int_en

// Interrupt Logic -> Register File
wire                          s_trigger_set_int_status;

// Instantiate APB Slave Interface
apb_slave_if_standard #(
    .ADDR_WIDTH   (P_APB_ADDR_WIDTH),
    .DATA_WIDTH   (P_APB_DATA_WIDTH),
    .BASE_ADDR_HI (P_APB_BASE_ADDR_HI)
) i_apb_slave_if (
    .clk          (sys_clk),
    .rst_n        (sys_rst_n),

    .psel         (tim_psel),
    .penable      (tim_penable),
    .pwrite       (tim_pwrite),
    .paddr        (tim_paddr),    // Full 32-bit address
    .pwdata       (tim_pwdata),

    .prdata       (tim_prdata),
    .pready       (tim_pready),
    .pslverr      (tim_pslverr),

    .reg_file_rdata_i        (s_reg_rdata_from_regs),
    .reg_file_addr_offset_o  (s_reg_addr_offset),
    .reg_file_wr_en_o        (s_reg_wr_en),
    .reg_file_rd_en_o        (s_reg_rd_en),
    .reg_file_wdata_o        (s_reg_wdata_to_regs)
);

// Instantiate Register File
register_standard i_register_file (
    .clk                (sys_clk),
    .rst_n              (sys_rst_n),

    .apb_addr_offset_i  (s_reg_addr_offset),
    .apb_wr_en_i        (s_reg_wr_en),
    .apb_rd_en_i        (s_reg_rd_en),
    .apb_wdata_i        (s_reg_wdata_to_regs),
    .apb_rdata_o        (s_reg_rdata_from_regs),

    .counter_val_low_i  (s_counter_val_low_to_reg),
    .counter_val_high_i (s_counter_val_high_to_reg),
    .load_tdr0_en_o     (s_load_tdr0_en),
    .load_tdr1_en_o     (s_load_tdr1_en),
    .tdr_load_data_o    (s_tdr_load_data),

    .interrupt_trigger_condition_i (s_trigger_set_int_status),

    .timer_en_o         (s_timer_en_for_ctrl), 
    .div_en_o           (s_div_en_for_ctrl),
    .div_val_o          (s_div_val_for_ctrl),
    .halt_req_o         (s_halt_req_for_ctrl),
    .tcmp0_val_o        (s_tcmp0_val_from_reg),
    .tcmp1_val_o        (s_tcmp1_val_from_reg),
    .int_enable_o       (s_int_module_en_for_int_logic), // TIER.int_en output

    .tim_int_o          (tim_int)
);

// Instantiate Counter Control Logic
counter_control_standard i_counter_control (
    .clk            (sys_clk),
    .rst_n          (sys_rst_n),

    .timer_en_i     (s_timer_en_for_ctrl),
    .div_en_i       (s_div_en_for_ctrl),
    .div_val_i      (s_div_val_for_ctrl),
    .halt_req_i     (s_halt_req_for_ctrl), 

    .main_counter_pulse_en_o (s_main_counter_pulse_en)
);

// Instantiate Timer Counter
timer_counter_standard i_timer_counter (
    .clk                 (sys_clk),
    .rst_n               (sys_rst_n),

    .timer_en_i          (s_timer_en_for_ctrl), // Overall timer enable from TCR
    .count_pulse_en_i    (s_main_counter_pulse_en),

    .load_tdr0_pulse_i   (s_load_tdr0_en),
    .load_tdr1_pulse_i   (s_load_tdr1_en),
    .tdr_load_data_i     (s_tdr_load_data),

    .cnt_val_out         (s_current_counter_val_to_int_logic) // 64-bit output
);

// Assign low and high parts of counter value to register file
assign s_counter_val_low_to_reg  = s_current_counter_val_to_int_logic[31:0];
assign s_counter_val_high_to_reg = s_current_counter_val_to_int_logic[63:32];

// Instantiate Interrupt Logic
// Combine TCMP0 and TCMP1 from register file for interrupt logic
assign s_current_compare_val_to_int_logic = {s_tcmp1_val_from_reg, s_tcmp0_val_from_reg};
assign s_timer_en_for_int_logic           = s_timer_en_for_ctrl; // Same timer_en signal

interrupt_logic_standard i_interrupt_logic (
    .current_counter_val_i     (s_current_counter_val_to_int_logic),
    .current_compare_val_i     (s_current_compare_val_to_int_logic),
    .timer_enabled_i           (s_timer_en_for_int_logic),
    .interrupt_module_en_i     (s_int_module_en_for_int_logic), // TIER.int_en from register

    .trigger_set_int_status_o  (s_trigger_set_int_status)
);

endmodule

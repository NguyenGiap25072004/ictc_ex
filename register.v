module register_standard (

    input wire                      clk,
    input wire                      rst_n,

    // APB Interface 
    input wire [11:0]               apb_addr_offset_i, 
    input wire                      apb_wr_en_i,       
    input wire                      apb_rd_en_i,       
    input wire [31:0]               apb_wdata_i,       
    output wire [31:0]              apb_rdata_o,       

    input wire [31:0]               counter_val_low_i,  
    input wire [31:0]               counter_val_high_i, 
    output wire                     load_tdr0_en_o,     
    output wire                     load_tdr1_en_o,     
    output wire [31:0]              tdr_load_data_o,    

    input wire                      interrupt_trigger_condition_i, // From interrupt_logic: (timer_en & TIER.int_en & match)

    // Outputs to counter_control
    output wire                     timer_en_o,
    output wire                     div_en_o,
    output wire [3:0]               div_val_o,
    output wire                     halt_req_o,         // THCSR.halt_req 

    // Output to timer_top (final interrupt)
    output wire                     tim_int_o
);

// Register Address 

localparam ADDR_TCR   = 12'h000; // Timer Control Register
localparam ADDR_TDR0  = 12'h004; // Timer Data Register 0 (Lower 32-bits of counter)
localparam ADDR_TDR1  = 12'h008; // Timer Data Register 1 (Upper 32-bits of counter)
localparam ADDR_TCMP0 = 12'h00C; // Timer Compare Register 0
localparam ADDR_TCMP1 = 12'h010; // Timer Compare Register 1
localparam ADDR_TIER  = 12'h014; // Timer Interrupt Enable Register
localparam ADDR_TISR  = 12'h018; // Timer Interrupt Status Register
localparam ADDR_THCSR = 12'h01C; // Timer Halt Control Status Register


// Register Default Values 
// TCR: timer_en=0 (bit 0), div_en=0 (bit 1), reserved=0 (bits 7:2),
//      div_val=4'b0001 (bits 11:8), reserved=0 (bits 31:12)
localparam TCR_DEFAULT   = {20'h0, 4'b0001, 6'h0, 1'b0, 1'b0};
localparam TCMP0_DEFAULT = 32'hFFFF_FFFF;
localparam TCMP1_DEFAULT = 32'hFFFF_FFFF;
localparam TIER_DEFAULT  = 32'h0000_0000; // TIER.int_en (bit 0) = 0
localparam TISR_DEFAULT  = 32'h0000_0000; // TISR.int_st (bit 0) = 0
localparam THCSR_DEFAULT = 32'h0000_0000; // THCSR.halt_req (bit 0)=0, THCSR.halt_ack (bit 1, Reserved for Std)=0


// Register Declarations

reg [31:0] tcr_reg;   // Timer Control Register
reg [31:0] tcmp0_reg; // Timer Compare Register 0
reg [31:0] tcmp1_reg; // Timer Compare Register 1
reg [31:0] tier_reg;  // Timer Interrupt Enable Register (only bit 0 is R/W)
reg [31:0] tisr_reg;  // Timer Interrupt Status Register (only bit 0 is RW1C)
reg [31:0] thcsr_reg; // Timer Halt Control Status Register (bit 0 R/W, bit 1 RO=0 for Std)

// Wire for Read Data Multiplexer Output

wire [31:0] rdata_mux_out;

// Register Write Logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tcr_reg   <= TCR_DEFAULT;
        tcmp0_reg <= TCMP0_DEFAULT;
        tcmp1_reg <= TCMP1_DEFAULT;
        tier_reg  <= TIER_DEFAULT;
        tisr_reg  <= TISR_DEFAULT;
        thcsr_reg <= THCSR_DEFAULT;
    end else begin
        // TCR Write Logic
        if (apb_wr_en_i && (apb_addr_offset_i == ADDR_TCR)) begin
            // timer_en (bit 0) - R/W
            tcr_reg[0] <= apb_wdata_i[0];
            if (!tcr_reg[0]) begin
                tcr_reg[1] <= apb_wdata_i[1];
            end
            // div_val (bits 11:8) - R/W
            if (!tcr_reg[0]) begin 
                if (apb_wdata_i[11:8] <= 4'h8) begin // Valid div_val is 0 to 8
                    tcr_reg[11:8] <= apb_wdata_i[11:8];
                end
            end
        end

        // TCMP0 Write Logic
        if (apb_wr_en_i && (apb_addr_offset_i == ADDR_TCMP0)) begin
            tcmp0_reg <= apb_wdata_i;
        end

        // TCMP1 Write Logic
        if (apb_wr_en_i && (apb_addr_offset_i == ADDR_TCMP1)) begin
            tcmp1_reg <= apb_wdata_i;
        end

        // TIER Write Logic (only bit 0 is R/W)
        if (apb_wr_en_i && (apb_addr_offset_i == ADDR_TIER)) begin
            tier_reg[0] <= apb_wdata_i[0]; // TIER.int_en
            // tier_reg[31:1] remain 0 (reserved)
        end

        // TISR Write Logic (bit 0 is RW1C - Write 1 to Clear)
        if (apb_wr_en_i && (apb_addr_offset_i == ADDR_TISR)) begin
            if (apb_wdata_i[0]) begin 
                tisr_reg[0] <= 1'b0;   
            end
        end

        // THCSR Write Logic (bit 0 R/W, bit 1 RO=0)
        if (apb_wr_en_i && (apb_addr_offset_i == ADDR_THCSR)) begin
            thcsr_reg[0] <= apb_wdata_i[0]; // THCSR.halt_req
        end
    end
end

// TISR.int_st 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
    end else begin
        if (!(apb_wr_en_i && (apb_addr_offset_i == ADDR_TISR) && apb_wdata_i[0])) begin 
             if (interrupt_trigger_condition_i) begin
                tisr_reg[0] <= 1'b1; 
            end
        end
    end
end

// Read Data Mux
assign rdata_mux_out =
    (apb_addr_offset_i == ADDR_TCR)   ? tcr_reg :
    (apb_addr_offset_i == ADDR_TDR0)  ? counter_val_low_i :  
    (apb_addr_offset_i == ADDR_TDR1)  ? counter_val_high_i : 
    (apb_addr_offset_i == ADDR_TCMP0) ? tcmp0_reg :
    (apb_addr_offset_i == ADDR_TCMP1) ? tcmp1_reg :
    (apb_addr_offset_i == ADDR_TIER)  ? tier_reg :
    (apb_addr_offset_i == ADDR_TISR)  ? tisr_reg :
    (apb_addr_offset_i == ADDR_THCSR) ? {thcsr_reg[31:2], 1'b0, thcsr_reg[0]} : // Ensure THCSR[1] (halt_ack) reads as 0
    32'h00000000; 

assign apb_rdata_o = apb_rd_en_i ? rdata_mux_out : 32'h0; 

// Outputs for TDR Loading to timer_counter
assign load_tdr0_en_o  = apb_wr_en_i && (apb_addr_offset_i == ADDR_TDR0);
assign load_tdr1_en_o  = apb_wr_en_i && (apb_addr_offset_i == ADDR_TDR1);
assign tdr_load_data_o = apb_wdata_i; 

// Control Signal Outputs (from TCR and THCSR)

assign timer_en_o = tcr_reg[0];  // TCR.timer_en
assign div_en_o   = tcr_reg[1];  // TCR.div_en
assign div_val_o  = tcr_reg[11:8]; // TCR.div_val
assign halt_req_o = thcsr_reg[0]; // THCSR.halt_req 

// Final Interrupt Output (tim_int)

assign tim_int_o = tier_reg[0] && tisr_reg[0]; 

endmodule

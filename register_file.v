module register_file #(
    parameter ADDR_WIDTH = 12,
    parameter DATA_WIDTH = 32
) 
(
    input wire                  clk,
    input wire                  rst_n,

    // Interface from APB  
    input wire [ADDR_WIDTH-1:0] addr,         
    input wire                  wr_en,       
    input wire                  rd_en,        
    input wire [DATA_WIDTH-1:0] wdata,       

    // Interface to APB
    output reg [DATA_WIDTH-1:0] rdata,        

    // Interface from Timer Core Logic
    input wire [63:0]           core_mtime,           
    input wire                  core_int_pending_set, 

    // Interface to Timer Core Logic
    output wire [31:0]          reg_tcr_val,    
    output wire [63:0]          reg_tcmp_val,    
    output wire [31:0]          reg_tier_val,   
    output wire [31:0]          reg_tisr_val,    
    output wire [31:0]          reg_thcsr_val    
);

localparam TCR   = 12'h000;
localparam TDR0  = 12'h004;
localparam TDR1  = 12'h008;
localparam TCMP0 = 12'h00C;
localparam TCMP1 = 12'h010;
localparam TIER  = 12'h014;
localparam TISR  = 12'h018;
localparam THCSR = 12'h01C;

localparam TCR_DEFAULT   = 32'h0000_0100; // timer_en=0, div_en=0, div_val=1
localparam TDR0_DEFAULT  = 32'h0000_0000;
localparam TDR1_DEFAULT  = 32'h0000_0000;
localparam TCMP0_DEFAULT = 32'hFFFF_FFFF;
localparam TCMP1_DEFAULT = 32'hFFFF_FFFF;
localparam TIER_DEFAULT  = 32'h0000_0000; // int_en=0
localparam TISR_DEFAULT  = 32'h0000_0000; // int_st=0
localparam THCSR_DEFAULT = 32'h0000_0000; // halt_req=0, halt_ack=0

// Register 

reg [31:0] tcr_reg;
reg [31:0] tdr0_reg;      // Holds written value for mtime low (RW)
reg [31:0] tdr1_reg;      // Holds written value for mtime high (RW)
reg [31:0] tcmp0_reg;
reg [31:0] tcmp1_reg;
reg [31:0] tier_reg;
reg [31:0] tisr_reg;      // Bit 0 is int_st (RW1C)
reg [31:0] thcsr_reg;     // Bit 0 RW but unused, Bit 1 RO=0

wire       wen_tisr_clear; // Signal to clear TISR[0] via write

// Write 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tcr_reg   <= TCR_DEFAULT;
        tdr0_reg  <= TDR0_DEFAULT;
        tdr1_reg  <= TDR1_DEFAULT;
        tcmp0_reg <= TCMP0_DEFAULT;
        tcmp1_reg <= TCMP1_DEFAULT;
        tier_reg  <= TIER_DEFAULT;
        tisr_reg  <= TISR_DEFAULT;
        thcsr_reg <= THCSR_DEFAULT;
    end else begin
        // TCR (Handle RO bits [7:2] and [31:12])
        if (wr_en && (addr == TCR)) begin
            // Write only RW bits: [11:8] div_val, [1] div_en, [0] timer_en
            tcr_reg[11:8] <= wdata[11:8];
            tcr_reg[1]    <= wdata[1];
            tcr_reg[0]    <= wdata[0];
        end

        // TDR0/1 Logic 
        if (wr_en && (addr == TDR0)) begin
            tdr0_reg <= wdata; 
        end
        if (wr_en && (addr == TDR1)) begin
            tdr1_reg <= wdata; 
        end

        // TCMP0/1 Logic
        if (wr_en && (addr == TCMP0)) begin
            tcmp0_reg <= wdata;
        end
        if (wr_en && (addr == TCMP1)) begin
            tcmp1_reg <= wdata;
        end

        // TIER (Only bit 0 RW)
        if (wr_en && (addr == TIER)) begin
            tier_reg[0] <= wdata[0];
        end

        // TISR  (RW1C for bit 0)
        if (wr_en && (addr == TISR) && wdata[0]) begin 
            tisr_reg[0] <= 1'b0; // Clear int_st
        end else if (core_int_pending_set) begin 
            tisr_reg[0] <= 1'b1; // Set int_st
        end

        // THCSR (bit 0 RW, bit 1 RO=0)
        if (wr_en && (addr == THCSR)) begin
            thcsr_reg[0] <= wdata[0]; 
        end
        thcsr_reg[1] <= 1'b0;

    end 
end 


// Read 
// Use address directly for selection
always @(*) begin

    rdata = 32'b0;
    if (rd_en) begin 
        case (addr)
            TCR:   rdata = tcr_reg;
            TDR0:  rdata = core_mtime[31:0];   
            TDR1:  rdata = core_mtime[63:32]; 
            TCMP0: rdata = tcmp0_reg;
            TCMP1: rdata = tcmp1_reg;
            TIER:  rdata = tier_reg;
            TISR:  rdata = tisr_reg;
            THCSR: rdata = thcsr_reg;         
            default: rdata = 32'b0;            
        endcase
    end
end

assign reg_tcr_val   = tcr_reg;
assign reg_tcmp_val  = {tcmp1_reg, tcmp0_reg}; 
assign reg_tier_val  = tier_reg;
assign reg_tisr_val  = tisr_reg;
assign reg_thcsr_val = thcsr_reg; 

endmodule 

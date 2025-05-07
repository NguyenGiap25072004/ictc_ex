module timer_reg_file_standard_decoder #(
    parameter ADDR_WIDTH = 12,
    parameter DATA_WIDTH = 32
) (
    input wire                  clk,
    input wire                  rst_n,

    // from APB 
    input wire [ADDR_WIDTH-1:0] addr,         
    input wire                  wr_en,        
    input wire                  rd_en,        
    input wire [DATA_WIDTH-1:0] wdata,        

    // to APB
    output reg [DATA_WIDTH-1:0] rdata,        

    input wire [63:0]           mtime,           
    input wire                  int_pending_set, 

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

localparam TCR_DEFAULT   = 32'h0000_0100;
localparam TDR0_DEFAULT  = 32'h0000_0000;
localparam TDR1_DEFAULT  = 32'h0000_0000;
localparam TCMP0_DEFAULT = 32'hFFFF_FFFF;
localparam TCMP1_DEFAULT = 32'hFFFF_FFFF;
localparam TIER_DEFAULT  = 32'h0000_0000;
localparam TISR_DEFAULT  = 32'h0000_0000;
localparam THCSR_DEFAULT = 32'h0000_0000;


reg [7:0]  reg_sel;      // [0]=TCR, [1]=TDR0, [2]=TDR1, [3]=TCMP0, [4]=TCMP1, [5]=TIER, [6]=TISR, [7]=THCSR

reg [31:0] tcr_reg;
reg [31:0] tdr0_reg;
reg [31:0] tdr1_reg;
reg [31:0] tcmp0_reg;
reg [31:0] tcmp1_reg;
reg [31:0] tier_reg;
reg [31:0] tisr_reg;
reg [31:0] thcsr_reg;


always @(*) begin
    // Default 
    reg_sel = 8'b0000_0000;
    case (addr)
        TCR:   reg_sel = 8'b0000_0001; // [0]
        TDR0:  reg_sel = 8'b0000_0010; // [1]
        TDR1:  reg_sel = 8'b0000_0100; // [2]
        TCMP0: reg_sel = 8'b0000_1000; // [3]
        TCMP1: reg_sel = 8'b0001_0000; // [4]
        TIER:  reg_sel = 8'b0010_0000; // [5]
        TISR:  reg_sel = 8'b0100_0000; // [6]
        THCSR: reg_sel = 8'b1000_0000; // [7]
        default: reg_sel = 8'b0000_0000; 
    endcase
end

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

        // TCR 
        if (wr_en && reg_sel[0]) begin 
            tcr_reg[11:8] <= wdata[11:8]; // div_val
            tcr_reg[1]    <= wdata[1];    // div_en
            tcr_reg[0]    <= wdata[0];    // timer_en
        end

        // TDR0/1 
        if (wr_en && reg_sel[1]) begin 
            tdr0_reg <= wdata;
        end
        if (wr_en && reg_sel[2]) begin 
            tdr1_reg <= wdata;
        end

        // TCMP0/1 
        if (wr_en && reg_sel[3]) begin 
            tcmp0_reg <= wdata;
        end
        if (wr_en && reg_sel[4]) begin 
            tcmp1_reg <= wdata;
        end

        // TIER 
        if (wr_en && reg_sel[5]) begin 
            tier_reg[0] <= wdata[0]; 
        end

        // TISR 
        if (wr_en && reg_sel[6] && wdata[0]) begin 
            tisr_reg[0] <= 1'b0; 
        end else if (int_pending_set) begin
            tisr_reg[0] <= 1'b1; 
        end

        // THCSR 
        if (wr_en && reg_sel[7]) begin 
            thcsr_reg[0] <= wdata[0]; 
        end
        thcsr_reg[1] <= 1'b0;

    end 
end 

// Read 
always @(*) begin
    rdata = 32'b0;
    if (rd_en) begin 
        if (reg_sel[0])      rdata = tcr_reg;
        else if (reg_sel[1]) rdata = mtime[31:0];   
        else if (reg_sel[2]) rdata = mtime[63:32];  
        else if (reg_sel[3]) rdata = tcmp0_reg;
        else if (reg_sel[4]) rdata = tcmp1_reg;
        else if (reg_sel[5]) rdata = tier_reg;
        else if (reg_sel[6]) rdata = tisr_reg;
        else if (reg_sel[7]) rdata = thcsr_reg;
        else                 rdata = 32'b0;             
    end
end

assign reg_tcr_val   = tcr_reg;
assign reg_tcmp_val  = {tcmp1_reg, tcmp0_reg};
assign reg_tier_val  = tier_reg;
assign reg_tisr_val  = tisr_reg;
assign reg_thcsr_val = thcsr_reg;

endmodule 

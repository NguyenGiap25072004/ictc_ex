module apb_transfer #(
    parameter ADDR_WIDTH = 12,
    parameter DATA_WIDTH = 32,
    parameter BASE_ADDR_HI = 20'h4000_1 
)

(
    
    input wire                  clk, 
    input wire                  rst_n,

    input wire                  psel,    
    input wire                  penable, 
    input wire                  pwrite,  
    input wire [31:0]           paddr,  
    input wire [DATA_WIDTH-1:0] pwdata, 

    output wire [DATA_WIDTH-1:0] prdata, 
    output wire                 pready, 
    output wire                 pslverr, 

    input wire [DATA_WIDTH-1:0] reg_rdata,     
    output wire [ADDR_WIDTH-1:0] reg_addr_offset,
    output wire                 reg_wr_en,    
    output wire                 reg_rd_en,     
    output wire [DATA_WIDTH-1:0] reg_wdata      
);

// Internal Signals
wire       is_selected;     
wire       is_access_phase; // ACCESS phase (psel & penable)

assign is_selected = (paddr[31:12] == BASE_ADDR_HI); 
assign reg_addr_offset = paddr[ADDR_WIDTH-1:0];    

// APB Phase Detection
// Access phase is when both psel and penable are high
assign is_access_phase = psel & penable;

// PREADY Logic (No Wait States)
assign pready = 1'b1; 

// PSLVERR Logic (No Error Handling)
assign pslverr = 1'b0; 


assign reg_wr_en = is_selected & is_access_phase & pwrite;
assign reg_rd_en = is_selected & is_access_phase & ~pwrite;

assign reg_wdata = pwdata;

assign prdata = reg_rdata;

endmodule 

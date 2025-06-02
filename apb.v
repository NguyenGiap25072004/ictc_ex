module apb_slave_if_standard #(
    parameter ADDR_WIDTH = 12,   
    parameter DATA_WIDTH = 32,    
    parameter BASE_ADDR_HI = 20'h4000_1 
) (

    input wire                      clk,
    input wire                      rst_n,

    // APB Interface Signals (Inputs from APB Master)
    input wire                      psel,    
    input wire                      penable, 
    input wire                      pwrite,  
    input wire [31:0]               paddr,   
    input wire [DATA_WIDTH-1:0]     pwdata,  
    // input wire [3:0]                pstrb,   // For advanced level

    // APB Interface Signals (Outputs to APB Master)
    output wire [DATA_WIDTH-1:0]    prdata,  
    output wire                     pready,  
    output wire                     pslverr, 

    // Interface to Register File module
    input wire [DATA_WIDTH-1:0]     reg_file_rdata_i,      
    output wire [ADDR_WIDTH-1:0]    reg_file_addr_offset_o,
    output wire                     reg_file_wr_en_o,      
    output wire                     reg_file_rd_en_o,     
    output wire [DATA_WIDTH-1:0]    reg_file_wdata_o      
);


// Wires

wire         is_selected_by_addr; 
wire         is_access_phase;     
wire         is_read_access;
wire         is_write_access;

// Address Decoding and Offset Generation

assign is_selected_by_addr = (paddr[31:12] == BASE_ADDR_HI);
assign reg_file_addr_offset_o = paddr[ADDR_WIDTH-1:0];

// APB Phase Detection

assign is_access_phase = psel & penable;
assign is_read_access  = is_selected_by_addr & is_access_phase & !pwrite;
assign is_write_access = is_selected_by_addr & is_access_phase & pwrite;

// APB Outputs to Master

// PREADY
assign pready = 1'b1;

// PSLVERR
assign pslverr = 1'b0;

// PRDATA
assign prdata = is_read_access ? reg_file_rdata_i : {DATA_WIDTH{1'b0}};

// Register File Control Signal Generation
assign reg_file_wr_en_o = is_write_access;
assign reg_file_rd_en_o = is_read_access;
assign reg_file_wdata_o = pwdata; 

endmodule

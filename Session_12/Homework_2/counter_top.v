//----------------------------------------------------------------------//
// Module: counter_top
//----------------------------------------------------------------------//
// Description:
// Top-level module instantiating and connecting the register file
// controller and the counter module for Homework 2.
//----------------------------------------------------------------------//
module counter_top (
    input               clk,
    input               rst_n,

    input               wr_en,
    input               rd_en,
    input      [9:0]    addr,
    input      [31:0]   wdata,
    output     [31:0]   rdata,

    output              overflow
);

wire        count_en_sig;
wire        count_clr_sig;
wire [7:0]  count_val_sig;

register_file_ctrl reg_ctrl_inst (
    .clk        (clk),
    .rst_n      (rst_n),
    .wr_en      (wr_en),
    .rd_en      (rd_en),
    .addr       (addr),
    .wdata      (wdata),
    .rdata      (rdata),     
    .count      (count_val_sig), 
    .count_en   (count_en_sig), 
    .count_clr  (count_clr_sig) 
);

counter counter_inst (
    .clk        (clk),
    .rst_n      (rst_n),
    .count_en   (count_en_sig),  
    .count_clr  (count_clr_sig),  
    .count      (count_val_sig),  
    .overflow   (overflow)       
);

endmodule 
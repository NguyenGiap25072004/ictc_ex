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

wire        pulse_sig;
wire        count_clr_sig;
wire [2:0]  count_val_sig;
wire        overflow_sig_from_counter;

pulse_register_ctrl reg_ctrl_inst (
    .clk                    (clk),
    .rst_n                  (rst_n),
    .wr_en                  (wr_en),
    .rd_en                  (rd_en),
    .addr                   (addr),
    .wdata                  (wdata),
    .rdata                  (rdata),                      
    .count                  (count_val_sig),              
    .overflow_from_counter  (overflow_sig_from_counter),  
    .pulse                  (pulse_sig),                  
    .count_clr              (count_clr_sig)               
);

pulse_counter_3bit counter_inst (
    .clk        (clk),
    .rst_n      (rst_n),
    .pulse      (pulse_sig),                
    .count_clr  (count_clr_sig),             
    .count      (count_val_sig),             
    .overflow   (overflow_sig_from_counter)  
);

assign overflow = overflow_sig_from_counter;

endmodule 
//----------------------------------------------------------------------//
// Module: register_file_ctrl
//----------------------------------------------------------------------//
// Description:
// Register file to control and monitor the 'counter' module.
// Implements the register map from Homework 2.
// Generates count_en and count_clr signals.
// Reads count value. Handles reserved addresses with RAZ/WI.
//----------------------------------------------------------------------//
module register_file_ctrl (
    input               clk,
    input               rst_n,

    input               wr_en,
    input               rd_en,
    input      [9:0]    addr,
    input      [31:0]   wdata,
    output reg [31:0]   rdata, 

    input      [7:0]    count,      
    output              count_en,   
    output              count_clr   
);

reg count_start_reg; // Controls count_en (bit 0 of Ctrl Reg)
reg count_clr_reg;   // Controls count_clr (bit 1 of Ctrl Reg)

// Sequential Logic: 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_start_reg <= 1'b0; 
        count_clr_reg   <= 1'b0; 
    end else begin
        if (wr_en && addr == 10'h000) begin 
            count_start_reg <= wdata[0];
            count_clr_reg   <= wdata[1];
        end
    end
end

// Combinational Logic: Control Signal Outputs
assign count_en  = count_start_reg;
assign count_clr = count_clr_reg;

// Combinational Logic: Read Path
always @(*) begin
    if (!rd_en) begin
        rdata = 32'h00000000; 
    end else begin
        case (addr)
            10'h000 : // Control Register
                rdata = {30'b0, count_clr_reg, count_start_reg}; 
            10'h004 : // Status Register
                rdata = {24'b0, count[7:0]}; 
            default : // Reserved Addresses
                rdata = 32'h00000000; 
        endcase
    end
end

endmodule 
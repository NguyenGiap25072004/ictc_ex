//----------------------------------------------------------------------//
// Module: register_file
//----------------------------------------------------------------------//
// Description:
// Implements a simple register file with 4 registers:
// - DATA0 @ 0x0 (RW, default 0)
// - SR_DATA0 @ 0x4 (RO, mirrors DATA0, default 0)
// - DATA1 @ 0x8 (RW, default 0xFFFFFFFF)
// - SR_DATA1 @ 0xC (RO, mirrors DATA1, default 0xFFFFFFFF)
// Handles 32-bit access only.
// Reserved addresses (not 0x0, 0x4, 0x8, 0xC within 0x000-0x3FF)
// are handled with RAZ/WI (Read As Zero, Write Ignored).
//----------------------------------------------------------------------//

module register_file (

    input               clk,      
    input               rst_n,   

    // Bus Interface Signals
    input               wr_en,    
    input               rd_en,    
    input      [9:0]    addr,    
    input      [31:0]   wdata,    
    output reg [31:0]   rdata     
);

reg [31:0] data0_reg; // DATA0 0x0
reg [31:0] data1_reg; // DATA1 0x8

// Sequential Logic: 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data0_reg <= 32'h00000000;
        data1_reg <= 32'hFFFFFFFF;
    end else begin
        if (wr_en) begin
            if (addr == 10'h000) begin
                data0_reg <= wdata;
            end
            else if (addr == 10'h008) begin
                data1_reg <= wdata;
            end
        end
    end
end

// Combinational Logic
always @(*) begin
    if (!rd_en) begin
        rdata = 32'h00000000;
    end else begin
        case (addr)
            10'h000 : rdata = data0_reg;       // Read DATA0
            10'h004 : rdata = data0_reg;       // Read SR_DATA0 
            10'h008 : rdata = data1_reg;       // Read DATA1
            10'h00C : rdata = data1_reg;       // Read SR_DATA1 
            default : rdata = 32'h00000000;    // Read As Zero (RAZ) for all other addresses
        endcase
    end
end

endmodule 

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
    // System Signals
    input               clk,      // Clock
    input               rst_n,    // Asynchronous Reset, active low

    // Bus Interface Signals
    input               wr_en,    // Write Enable
    input               rd_en,    // Read Enable
    input      [9:0]    addr,     // Address bus (10 bits)
    input      [31:0]   wdata,    // Write Data bus (32 bits)
    output reg [31:0]   rdata     // Read Data bus (32 bits) - Using 'reg' for always@(*) block
);

// Internal storage registers
reg [31:0] data0_reg; // For DATA0 @ 0x0
reg [31:0] data1_reg; // For DATA1 @ 0x8

//----------------------------------------------------------------------//
// Sequential Logic: Register Writes and Reset
//----------------------------------------------------------------------//
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // Reset condition
        data0_reg <= 32'h00000000;
        data1_reg <= 32'hFFFFFFFF;
    end else begin
        // Write condition (only on clock edge if not in reset)
        if (wr_en) begin
            // Only write to valid RW addresses
            if (addr == 10'h000) begin
                data0_reg <= wdata;
            end
            else if (addr == 10'h008) begin
                data1_reg <= wdata;
            end
            // Writes to 0x4, 0xC (RO) and reserved addresses are ignored (WI)
        end
    end
end

//----------------------------------------------------------------------//
// Combinational Logic: Read Path
//----------------------------------------------------------------------//
// Note: Using always@(*) for read logic for clarity with case statement
always @(*) begin
    if (!rd_en) begin
        // Output 0 if read is not enabled
        rdata = 32'h00000000;
    end else begin
        // Select read data based on address when read is enabled
        case (addr)
            10'h000 : rdata = data0_reg;       // Read DATA0
            10'h004 : rdata = data0_reg;       // Read SR_DATA0 (mirrors DATA0)
            10'h008 : rdata = data1_reg;       // Read DATA1
            10'h00C : rdata = data1_reg;       // Read SR_DATA1 (mirrors DATA1)
            default : rdata = 32'h00000000;    // Read As Zero (RAZ) for all other addresses
        endcase
    end
end

/* // Alternative using assign statement for read path:
assign rdata = rd_en
               ? ( (addr == 10'h000 || addr == 10'h004) ? data0_reg
                 : (addr == 10'h008 || addr == 10'h00C) ? data1_reg
                 : 32'h0 ) // RAZ for others
               : 32'h0;     // Output 0 if rd_en is low
*/

endmodule // register_file
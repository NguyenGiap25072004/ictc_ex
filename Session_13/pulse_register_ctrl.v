module pulse_register_ctrl (
    input               clk,
    input               rst_n,

    input               wr_en,
    input               rd_en,
    input      [9:0]    addr,
    input      [31:0]   wdata,
    output reg [31:0]   rdata,

    input      [2:0]    count,            
    input               overflow_from_counter,
    output reg          pulse,           
    output              count_clr        
);

reg count_clr_reg;      
reg overflow_sticky_reg; 

wire write_pulse_en_detected = wr_en && (addr == 10'h000) && wdata[0];

// Sequential Logic: Control/Status Registers, Reset, Pulse
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_clr_reg       <= 1'b0;
        overflow_sticky_reg <= 1'b0;
        pulse               <= 1'b0; 
    end else begin
        pulse <= write_pulse_en_detected;

        if (wr_en && (addr == 10'h000)) begin
            count_clr_reg <= wdata[1];
        end

        if (overflow_from_counter) begin 
            overflow_sticky_reg <= 1'b1;
        end else if (wr_en && (addr == 10'h004) && !wdata[3]) begin 
            overflow_sticky_reg <= 1'b0;
        end
    end
end

// Combinational Logic: Control Signal Output & Read Path
assign count_clr = count_clr_reg;

// Read Path Logic
always @(*) begin
    rdata = 32'h00000000;
    if (rd_en) begin
        case (addr)
            10'h000 : 
                rdata = {30'b0, count_clr_reg, 1'b0};
            10'h004 : 
                rdata = {28'b0, overflow_sticky_reg, count[2:0]};
            default : 
                rdata = 32'h00000000;
        endcase
    end
end

endmodule 
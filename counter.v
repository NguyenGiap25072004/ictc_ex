module timer_counter_standard (
    input wire        clk,
    input wire        rst_n,

    input wire        timer_en_i,            // From register (TCR.timer_en) 
    input wire        count_pulse_en_i,      // From counter_control

    // APB TDR write signals (from register)
    input wire        load_tdr0_pulse_i,     // Single cycle pulse to load cnt_val_out[31:0]
    input wire        load_tdr1_pulse_i,     // Single cycle pulse to load cnt_val_out[63:32]
    input wire [31:0] tdr_load_data_i,       // Data from APB (via register) to load into TDR

    // Compare value (from register, composed from TCMP0 & TCMP1 regs)
    input wire [63:0] tcmp_val_i,

    // Counter output and compare match output
    output reg [63:0] cnt_val_out,           // Current 64-bit counter value
    output wire       cmp_match_out          // Output to interrupt
);

// Compare Match Logic
assign cmp_match_out = (cnt_val_out == tcmp_val_i);

// Counter Implementation: 64-bit count-up register

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_val_out <= 64'd0; 
    end else begin
        // Priority: TDR Load > Counting
        if (load_tdr0_pulse_i) begin
            cnt_val_out[31:0] <= tdr_load_data_i; // Load lower 32 bits from APB wdata
        end else if (load_tdr1_pulse_i) begin
            cnt_val_out[63:32] <= tdr_load_data_i; // Load upper 32 bits from APB wdata
        end else if (timer_en_i && count_pulse_en_i) begin
            cnt_val_out <= cnt_val_out + 1;       // Increment counter
        end

    end
end

endmodule

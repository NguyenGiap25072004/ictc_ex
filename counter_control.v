module counter_control_standard (
    input wire        clk,
    input wire        rst_n,

    input wire        timer_en_i,   // TCR.timer_en
    input wire        div_en_i,     // TCR.div_en
    input wire [3:0]  div_val_i,    // TCR.div_val
  //input wire        halt_req_i,   // THCSR.halt_req 

    output wire       main_counter_pulse_en_o // Enable pulse for the main timer_counter
);

// Internal Prescaler for Division Logic
reg  [7:0] prescaler_cnt;         // Counts from 0 up to prescaler_limit_val
wire [7:0] prescaler_limit_val;   // Limit value derived from div_val_i
wire       prescaler_reaches_limit;
wire       prescaler_rst;
wire [7:0] prescaler_cnt_next;

// Mode Detection (based on timer_en and div_en/div_val)
wire       is_default_mode;          // Timer counts at system clock speed
wire       is_control_mode_div_by_1; // div_en=1, div_val=0 (counts at system clock speed)
wire       is_control_mode_div_by_N; // div_en=1, div_val > 0 (counts at divided speed)

assign prescaler_limit_val = {4'b0, div_val_i}; 

// Determine active modes 
assign is_default_mode          = timer_en_i && !div_en_i;
assign is_control_mode_div_by_1 = timer_en_i && div_en_i && (div_val_i == 4'b0000);
assign is_control_mode_div_by_N = timer_en_i && div_en_i && (div_val_i > 4'b0000 && div_val_i <= 4'h8); // Valid div_val 1-8

// Check if prescaler counter reaches its limit
assign prescaler_reaches_limit = (prescaler_cnt == div_val_i); // Counts 0 to div_val_i

// Reset condition for the prescaler counter
assign prescaler_rst = !timer_en_i ||                               // Timer is disabled
                       !div_en_i ||                                 // Not in division mode (default or control_div_by_1 active)
                       (is_control_mode_div_by_N && prescaler_reaches_limit); // Reached limit in div_by_N mode

// Next value for the prescaler counter
assign prescaler_cnt_next = prescaler_rst ? 8'd0 :
                            (is_control_mode_div_by_N ? prescaler_cnt + 1 :
                             prescaler_cnt); // Holds if not div_by_N and not time to reset

// Prescaler counter register
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        prescaler_cnt <= 8'd0;
    end else begin
        prescaler_cnt <= prescaler_cnt_next;
    end
end

// Generate the final main_counter_pulse_en_o signal
assign main_counter_pulse_en_o =
    is_default_mode ||                                  // Always enable if in default mode & timer_en
    is_control_mode_div_by_1 ||                         // Always enable if in control_mode_div_by_1 & timer_en
    (is_control_mode_div_by_N && prescaler_reaches_limit); // Pulse when prescaler reaches limit in div_by_N mode

endmodule

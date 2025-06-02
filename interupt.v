module interrupt_logic_standard (
    input wire [63:0] current_counter_val_i, // Current 64-bit counter value (from timer_counter)
    input wire [63:0] current_compare_val_i, // Current 64-bit compare value (from register TCMP regs)
    input wire        timer_enabled_i,       // TCR.timer_en (from register)
    input wire        interrupt_module_en_i, // TIER.int_en (from register)

    // Output to register
    output wire       trigger_set_int_status_o // Condition to set TISR.int_st in register
);

// Internal Wires
wire         counter_matches_compare; // True if counter equals compare value

// Interrupt Condition Logic

// 1. Check if current_counter_val_i equals current_compare_val_i
assign counter_matches_compare = (current_counter_val_i == current_compare_val_i);

assign trigger_set_int_status_o = timer_enabled_i && interrupt_module_en_i && counter_matches_compare;


endmodule

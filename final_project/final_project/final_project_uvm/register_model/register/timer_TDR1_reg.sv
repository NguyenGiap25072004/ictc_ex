class timer_TDR1_reg extends uvm_reg;
  `uvm_object_utils(timer_TDR1_reg)

  rand uvm_reg_field TDR1;

  function new(string name="timer_TDR1_reg");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    // Create object instance for each field
    this.TDR1 = uvm_reg_field::type_id::create("TDR1");

    // Configure each field
    this.TDR1.configure(.parent(this),  
                       .size(32),
                       .lsb_pos(0),
                       .access("RW"),
                       .volatile(1'b0),
                       .reset(32'h0000_0000),
                       .has_reset(1),
                       .is_rand(1),
                       .individually_accessible(1));
  endfunction

endclass

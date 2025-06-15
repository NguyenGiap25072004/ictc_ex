class timer_TIER_reg extends uvm_reg;
  `uvm_object_utils(timer_TIER_reg)

  rand uvm_reg_field int_en;

  function new(string name="timer_TIER_reg");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    // Create object instance for each field
    this.int_en = uvm_reg_field::type_id::create("int_en");

    // Configure each field
    this.int_en.configure(.parent(this),  
                       .size(1),
                       .lsb_pos(0),
                       .access("RW"),
                       .volatile(1'b0),
                       .reset(1'b0),
                       .has_reset(1),
                       .is_rand(1),
                       .individually_accessible(1));
  endfunction

endclass

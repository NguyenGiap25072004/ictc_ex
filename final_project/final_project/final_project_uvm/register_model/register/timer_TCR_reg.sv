class timer_TCR_reg extends uvm_reg;
  `uvm_object_utils(timer_TCR_reg)

  rand uvm_reg_field timer_en;
  rand uvm_reg_field div_en;
  rand uvm_reg_field div_val;

  function new(string name="timer_TCR_reg");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    // Create object instance for each field
    this.timer_en = uvm_reg_field::type_id::create("timer_en");
    this.div_en = uvm_reg_field::type_id::create("div_en");
    this.div_val = uvm_reg_field::type_id::create("div_val");

    // Configure each field
    this.timer_en.configure(.parent(this),  
                       .size(1),
                       .lsb_pos(0),
                       .access("RW"),
                       .volatile(1'b0),
                       .reset(1'b0),
                       .has_reset(1),
                       .is_rand(1),
                       .individually_accessible(1));
    this.div_en.configure(.parent(this),  
                       .size(1),
                       .lsb_pos(1),
                       .access("RW"),
                       .volatile(1'b0),
                       .reset(1'b0),
                       .has_reset(1),
                       .is_rand(1),
                       .individually_accessible(1));
    this.div_val.configure(.parent(this),  
                       .size(4),
                       .lsb_pos(8),
                       .access("RW"),
                       .volatile(1'b0),
                       .reset(4'b0001),
                       .has_reset(1),
                       .is_rand(1),
                       .individually_accessible(1));
  endfunction

endclass

class timer_TCMP1_reg extends uvm_reg;
  `uvm_object_utils(timer_TCMP1_reg)

  rand uvm_reg_field TCMP1;

  function new(string name="timer_TCMP1_reg");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    // Create object instance for each field
    this.TCMP1 = uvm_reg_field::type_id::create("TCMP1");

    // Configure each field
    this.TCMP1.configure(.parent(this),  
                       .size(32),
                       .lsb_pos(0),
                       .access("RW"),
                       .volatile(1'b0),
                       .reset(32'hFFFF_FFFF),
                       .has_reset(1),
                       .is_rand(1),
                       .individually_accessible(1));
  endfunction

endclass

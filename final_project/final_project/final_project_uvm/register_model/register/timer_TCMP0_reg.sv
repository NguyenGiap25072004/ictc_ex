class timer_TCMP0_reg extends uvm_reg;
  `uvm_object_utils(timer_TCMP0_reg)

  rand uvm_reg_field TCMP0;

  function new(string name="timer_TCMP0_reg");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    // Create object instance for each field
    this.TCMP0 = uvm_reg_field::type_id::create("TCMP0");

    // Configure each field
    this.TCMP0.configure(.parent(this),  
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

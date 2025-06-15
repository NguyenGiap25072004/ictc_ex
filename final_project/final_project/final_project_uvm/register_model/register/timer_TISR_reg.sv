class timer_TISR_reg extends uvm_reg;
  `uvm_object_utils(timer_TISR_reg)

  rand uvm_reg_field int_st;

  function new(string name="timer_TISR_reg");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    // Create object instance for each field
    this.int_st = uvm_reg_field::type_id::create("int_st");

    // Configure each field
    this.int_st.configure(.parent(this),  
                       .size(1),
                       .lsb_pos(0),
                       .access("W1C"),
                       .volatile(1'b0),
                       .reset(1'b0),
                       .has_reset(1),
                       .is_rand(1),
                       .individually_accessible(1));
  endfunction

endclass

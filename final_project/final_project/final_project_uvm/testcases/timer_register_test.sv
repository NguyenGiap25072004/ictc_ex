class timer_register_test extends timer_base_test;
  `uvm_component_utils(timer_register_test)

  function new(string name="timer_register_test", uvm_component parent);
    super.new(name,parent);
  endfunction: new

  virtual task main_phase(uvm_phase phase);
    uvm_reg_hw_reset_seq default_register_seq = uvm_reg_hw_reset_seq::type_id::create("default_register_seq");
    uvm_reg_bit_bash_seq bit_bash_seq = uvm_reg_bit_bash_seq::type_id::create("bit_bash_seq");
    
    phase.raise_objection(this);
    default_register_seq.model = env.regmodel;
    bit_bash_seq.model         = env.regmodel;
    
    // Default register test
    default_register_seq.start(null);

    // Read/Write register test
    // Register div_val only valid from 4'b0000 -> 4'b1000, Others is reseverd. Ignore, will check in function test
    regmodel.TCR.div_val.set_compare(UVM_NO_CHECK);
    bit_bash_seq.start(null);

    phase.drop_objection(this);
  endtask

endclass

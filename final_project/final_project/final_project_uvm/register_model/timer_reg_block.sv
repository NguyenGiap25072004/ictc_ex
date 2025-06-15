class timer_reg_block extends uvm_reg_block;
  `uvm_object_utils(timer_reg_block)

  rand timer_TCR_reg    TCR;
  rand timer_TDR0_reg   TDR0;
  rand timer_TDR1_reg   TDR1;
  rand timer_TCMP0_reg  TCMP0;
  rand timer_TCMP1_reg  TCMP1;
  rand timer_TIER_reg   TIER;
  rand timer_TISR_reg   TISR;

  uvm_reg_map apb_map;

  function new(string name="timer_reg_block");
    super.new(name,UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    TCR = timer_TCR_reg::type_id::create("TCR");
    TCR.configure(this);
    TCR.build();
    
    TDR0 = timer_TDR0_reg::type_id::create("TDR0");
    TDR0.configure(this);
    TDR0.build();

    TDR1 = timer_TDR1_reg::type_id::create("TDR1");
    TDR1.configure(this);
    TDR1.build();
    
    TCMP0 = timer_TCMP0_reg::type_id::create("TCMP0");
    TCMP0.configure(this);
    TCMP0.build();
    
    TCMP1 = timer_TCMP1_reg::type_id::create("TCMP1");
    TCMP1.configure(this);
    TCMP1.build();
    
    TIER = timer_TIER_reg::type_id::create("TIER");
    TIER.configure(this);
    TIER.build();
    
    TISR = timer_TISR_reg::type_id::create("TISR");
    TISR.configure(this);
    TISR.build();

    apb_map = create_map("apb_map",0,4,UVM_LITTLE_ENDIAN,1);

    apb_map.add_reg(TCR,  `UVM_REG_ADDR_WIDTH'h00, "RW");
    apb_map.add_reg(TDR0, `UVM_REG_ADDR_WIDTH'h04, "RW");
    apb_map.add_reg(TDR1, `UVM_REG_ADDR_WIDTH'h08, "RW");
    apb_map.add_reg(TCMP0,`UVM_REG_ADDR_WIDTH'h0C, "RW");
    apb_map.add_reg(TCMP1,`UVM_REG_ADDR_WIDTH'h10, "RW");
    apb_map.add_reg(TIER, `UVM_REG_ADDR_WIDTH'h14, "RW");
    apb_map.add_reg(TISR, `UVM_REG_ADDR_WIDTH'h18, "RW");

    lock_model();
  endfunction

endclass

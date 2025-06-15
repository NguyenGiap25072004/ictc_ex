class timer_env extends uvm_env;
  `uvm_component_utils(timer_env)

  apb_master_agent apb_agt;
  timer_scoreboard timer_sb;

  virtual apb_if    apb_vif;
  apb_configuration apb_cfg;

  timer_reg_block  regmodel;
  timer_reg2apb_adapter  apb_adapter;

  // Predictor class creation
  uvm_reg_predictor #(apb_master_transaction) apb_predictor;

  function new(string name="timer_env", uvm_component parent);
    super.new(name,parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_if)::get(this,"","apb_vif",apb_vif))
      `uvm_fatal(get_type_name(),$sformatf("Failed to get apb_vif from uvm_config_db"))
    if(!uvm_config_db#(apb_configuration)::get(this,"","apb_cfg",apb_cfg))
      `uvm_fatal(get_type_name(),$sformatf("Failed to get apb_cfg from uvm_config_db"))

    apb_agt = apb_master_agent::type_id::create("apb_agt",this);
    timer_sb = timer_scoreboard::type_id::create("timer_sb",this);
   
    apb_adapter = timer_reg2apb_adapter::type_id::create("apb_adapter");
    regmodel = timer_reg_block::type_id::create("regmodel",this);
    regmodel.build();

    apb_predictor = uvm_reg_predictor#(apb_master_transaction)::type_id::create("apb_predictor",this);

    uvm_config_db#(virtual apb_if)::set(this,"apb_agt","apb_if",apb_vif);
    uvm_config_db#(apb_configuration)::set(this,"apb_agt","apb_cfg",apb_cfg);
  endfunction: build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(regmodel.get_parent() == null)
      regmodel.apb_map.set_sequencer(apb_agt.sequencer, apb_adapter);
    
    // Predictor connection
    apb_predictor.map = regmodel.apb_map;
    apb_predictor.adapter = apb_adapter;
    apb_agt.monitor.item_observed_port.connect(apb_predictor.bus_in);
    
    // Connect monitor to scoreboard
    apb_agt.monitor.item_observed_port.connect(timer_sb.apb_port);
  endfunction: connect_phase

endclass

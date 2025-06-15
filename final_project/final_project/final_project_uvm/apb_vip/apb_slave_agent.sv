//=============================================================================
// Project       : APB VIP
//=============================================================================
// Filename      : apb_slave_agent.sv
// Author        : Huy Nguyen
// Company       : NO
// Date          : 13-Dec-2021
//=============================================================================
// Description   : 
//
//
//
//=============================================================================
`ifndef GUARD_APB_SLAVE_AGENT__SV
`define GUARD_APB_SLAVE_AGENT__SV

class apb_slave_agent extends uvm_agent;
  `uvm_component_utils(apb_slave_agent)

  virtual apb_if apb_vif;

  apb_configuration    cfg;
  apb_slave_monitor   monitor;
  apb_slave_driver    driver;
  apb_slave_sequencer sequencer;
  apb_status           share_status;

  local string msg = "[APB_VIP][APB_SLAVE_AGENT]";  
  local string config_id    = "apb_cfg";
  local string interface_id = "apb_if";

  function new(string name="apb_slave_agent", uvm_component parent);
    super.new(name,parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    /** Applying the virtual interface received through the config db */
    if(!uvm_config_db#(virtual apb_if)::get(this,"","apb_if",apb_vif))
      `uvm_fatal(msg,$sformatf("Failed to get %0s from uvm_config_db. Please check!",interface_id))

    /** Applying the configuration received through the config db */
    if(!uvm_config_db#(apb_configuration)::get(this,"","apb_cfg",cfg))
      `uvm_fatal(msg,$sformatf("Failed to get %0s from uvm_config_db. Please check!",config_id))

    /** Create share status object for futher implementation */
      share_status = apb_status::type_id::create("share_status");
      uvm_config_db#(apb_status)::set(this,"monitor","share_status",share_status);

    /** Create component and set the virtual interface to lower component
     * Default Agent is Active mode.
     */
    if(cfg.is_active) begin
      `uvm_info(msg,$sformatf("Active agent is configued"),UVM_LOW)
      driver = apb_slave_driver::type_id::create("driver", this);
      sequencer = apb_slave_sequencer::type_id::create("sequencer", this);
      monitor = apb_slave_monitor::type_id::create("monitor", this);

      /** Pass configuration to sub component */
      uvm_config_db#(apb_configuration)::set(this,"driver","apb_cfg",cfg);
      uvm_config_db#(apb_configuration)::set(this,"monitor","apb_cfg",cfg);

      /** Pass virtual interface to sub component */
      uvm_config_db#(virtual apb_if)::set(this,"driver","apb_if",apb_vif);
      uvm_config_db#(virtual apb_if)::set(this,"monitor","apb_if",apb_vif);

      /** Pass share status to driver */
      uvm_config_db#(apb_status)::set(this,"driver","share_status",share_status);
    end
    else begin
      `uvm_info(msg,$sformatf("Passive agent is configued"),UVM_LOW)
      monitor = apb_slave_monitor::type_id::create("monitor", this);

      /** Pass virtual interface to sub component */
      uvm_config_db#(virtual apb_if)::set(this,"monitor","apb_if",apb_vif);

      /** Pass configuration to sub component */
      uvm_config_db#(apb_configuration)::set(this,"monitor","apb_cfg",cfg);
    end

  endfunction: build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(cfg.is_active) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
      sequencer.get_cfg(this.cfg);
      driver.sequencer = this.sequencer;
    end
  endfunction: connect_phase

endclass: apb_slave_agent

`endif



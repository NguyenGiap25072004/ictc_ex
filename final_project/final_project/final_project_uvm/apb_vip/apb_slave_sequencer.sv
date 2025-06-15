//=============================================================================
// Project       : APB VIP
//=============================================================================
// Filename      : apb_slave_sequencer.sv
// Author        : Huy Nguyen
// Company       : NO
// Date          : 13-Dec-2021
//=============================================================================
// Description   : 
//
//
//
//=============================================================================
`ifndef GUARD_APB_SLAVE_SEQUENCER__SV
`define GUARD_APB_SLAVE_SEQUENCER__SV

typedef class apb_slave_agent;
typedef class apb_status;
class apb_slave_sequencer extends uvm_sequencer #(apb_slave_transaction);
  `uvm_component_utils(apb_slave_sequencer)

  apb_configuration    cfg;
  apb_status           share_status;

  apb_slave_transaction predict_req;
  event                 new_transaction;

  local string msg = "[APB_SLAVE_VIP][APB_SLAVE_SEQUENCER]";  

  function new(string name="apb_slave_sequencer", uvm_component parent);
    super.new(name,parent);
  endfunction: new

  function void get_cfg(ref apb_configuration cfg);
    this.cfg = cfg;
  endfunction: get_cfg

  task wait_next_transaction(output apb_slave_transaction slave_trans);
    @(new_transaction);
    slave_trans = this.predict_req;
  endtask: wait_next_transaction

endclass: apb_slave_sequencer

`endif



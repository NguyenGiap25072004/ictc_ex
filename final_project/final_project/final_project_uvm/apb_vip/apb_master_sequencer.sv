//=============================================================================
// Project       : APB VIP
//=============================================================================
// Filename      : apb_master_sequencer.sv
// Author        : Huy Nguyen
// Company       : NO
// Date          : 13-Dec-2021
//=============================================================================
// Description   : 
//
//
//
//=============================================================================
`ifndef GUARD_APB_MASTER_SEQUENCER__SV
`define GUARD_APB_MASTER_SEQUENCER__SV

typedef class apb_master_agent;
typedef class apb_status;
class apb_master_sequencer extends uvm_sequencer #(apb_master_transaction);
  `uvm_component_utils(apb_master_sequencer)

  apb_configuration    cfg;
  apb_status           share_status;

  local string msg = "[APB_MASTER_VIP][APB_MASTER_SEQUENCER]";  

  function new(string name="apb_master_sequencer", uvm_component parent);
    super.new(name,parent);
  endfunction: new

  function void get_cfg(ref apb_configuration cfg);
    this.cfg = cfg;
  endfunction: get_cfg


endclass: apb_master_sequencer

`endif



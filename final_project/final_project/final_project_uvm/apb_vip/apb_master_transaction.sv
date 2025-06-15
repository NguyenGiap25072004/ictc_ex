//=============================================================================
// Project       : APB VIP
//=============================================================================
// Filename      : apb_master_transaction.sv
// Author        : Huy Nguyen
// Company       : NO
// Date          : 13-Dec-2021
//=============================================================================
// Description   : 
//
//
//
//=============================================================================
`ifndef APB_MASTER_TRANSACTION__SV
`define APB_MASTER_TRANSACTION__SV

class apb_master_transaction extends apb_transaction;
  `uvm_object_utils_begin(apb_master_transaction)
  `uvm_object_utils_end

  constraint master_default {
    pslverr_enable == 0;
    num_wait_cycle == 0;
  }

  function void pre_randomize();
  endfunction: pre_randomize

  function void post_randomize();
  endfunction: post_randomize

  function new(string name="apb_master_transaction");
    super.new(name);
  endfunction: new

endclass: apb_master_transaction

`endif



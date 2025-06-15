//=============================================================================
// Project       : APB VIP
//=============================================================================
// Filename      : apb_slave_transaction.sv
// Author        : Huy Nguyen
// Company       : NO
// Date          : 13-Dec-2021
//=============================================================================
// Description   : 
//
//
//
//=============================================================================
`ifndef APB_SLAVE_TRANSACTION__SV
`define APB_SLAVE_TRANSACTION__SV

class apb_slave_transaction extends apb_transaction;
  `uvm_object_utils_begin(apb_slave_transaction)
  `uvm_object_utils_end

  function void pre_randomize();
  endfunction: pre_randomize

  function void post_randomize();
  endfunction: post_randomize

  function new(string name="apb_slave_transaction");
    super.new(name);
  endfunction: new

endclass: apb_slave_transaction

`endif



//=============================================================================
// Project       : APB VIP
//=============================================================================
// Filename      : apb_transaction.sv
// Author        : Huy Nguyen
// Company       : NO
// Date          : 13-Dec-2021
//=============================================================================
// Description   : 
//
//
//
//=============================================================================
`ifndef APB_TRANSACTION__SV
`define APB_TRANSACTION__SV

class apb_transaction extends uvm_sequence_item;

  rand apb_types::xact_type_enum  xact_type;
  rand bit[`APB_ADDR_WIDTH-1:0]   address;
  rand bit[`APB_DATA_WIDTH-1:0]   data;
  rand bit                        pslverr_enable;
  rand int                        num_wait_cycle;

  `uvm_object_utils_begin (apb_transaction)
    `uvm_field_enum       (apb_types::xact_type_enum      ,xact_type      ,UVM_ALL_ON |UVM_HEX )
    `uvm_field_int        (address        ,UVM_ALL_ON |UVM_HEX )
    `uvm_field_int        (data           ,UVM_ALL_ON |UVM_HEX )
    `uvm_field_int        (pslverr_enable ,UVM_ALL_ON |UVM_HEX )
    `uvm_field_int        (num_wait_cycle ,UVM_ALL_ON |UVM_DEC )
  `uvm_object_utils_end

  function void pre_randomize();
  endfunction: pre_randomize

  function void post_randomize();
  endfunction: post_randomize

  function new(string name="apb_transaction");
    super.new(name);
  endfunction: new

endclass: apb_transaction

`endif



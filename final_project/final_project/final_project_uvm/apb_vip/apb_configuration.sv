//=============================================================================
// Project       : APB VIP
//=============================================================================
// Filename      : apb_configuration.sv
// Author        : Huy Nguyen
// Company       : NO
// Date          : 13-Dec-2021
//=============================================================================
// Description   : 
//
//
//
//=============================================================================
`ifndef APB_CONFIGURATION__SV
`define APB_CONFIGURATION__SV

class apb_configuration extends uvm_object;

  bit  is_active = 1;

  `uvm_object_utils_begin (apb_configuration)
    `uvm_field_int        (is_active ,UVM_ALL_ON |UVM_HEX )
  `uvm_object_utils_end

  function new(string name="apb_configuration");
    super.new(name);
  endfunction: new

endclass: apb_configuration

`endif



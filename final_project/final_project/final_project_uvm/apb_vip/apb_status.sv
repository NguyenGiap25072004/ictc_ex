//=============================================================================
// Project       : APB VIP
//=============================================================================
// Filename      : apb_status.sv
// Author        : Huy Nguyen
// Company       : NO
// Date          : 13-Dec-2021
//=============================================================================
// Description   : 
//
//
//
//=============================================================================
`ifndef APB_STATUS__SV
`define APB_STATUS__SV

class apb_status extends uvm_object;

  `uvm_object_utils_begin(apb_status)
  `uvm_object_utils_end

  function new(string name="apb_status");
    super.new(name);
  endfunction: new

endclass: apb_status

`endif



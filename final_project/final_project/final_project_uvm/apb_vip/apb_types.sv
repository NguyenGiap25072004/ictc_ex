//=============================================================================
// Project       : APB VIP
//=============================================================================
// Filename      : apb_types.sv
// Author        : Huy Nguyen
// Company       : NO
// Date          : 13-Dec-2021
//=============================================================================
// Description   : 
//
//
//
//=============================================================================
`ifndef APB_TYPES__SV
`define APB_TYPES__SV

class apb_types extends uvm_object;
  `uvm_object_utils(apb_types)

  typedef enum bit {
       WRITE = 1
      ,READ  = 0
  } xact_type_enum;
  
  typedef enum {
       IDLE
      ,SETUP
      ,ACCESS
      ,IN_RESET
  } apb_state_enum;

  function new(string name="apb_types");
    super.new(name);
  endfunction: new

endclass: apb_types

`endif



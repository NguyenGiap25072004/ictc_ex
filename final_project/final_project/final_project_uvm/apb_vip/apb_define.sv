//=============================================================================
// Project       : APB VIP
//=============================================================================
// Filename      : apb_define.sv
// Author        : Huy Nguyen
// Company       : NO
// Date          : 13-Dec-2021
//=============================================================================
// Description   : Define can override by environment
//
//
//
//=============================================================================
`ifndef GUARD_APB_DEFINE__SV
`define GUARD_APB_DEFINE__SV

  `ifndef FORK_GUARD_BEGIN
    `define FORK_GUARD_BEGIN fork begin
  `endif

  `ifndef FORK_GUARD_END
    `define FORK_GUARD_END   end join
  `endif

  `ifndef APB_ADDR_WIDTH
     `define APB_ADDR_WIDTH     32         
  `endif

  `ifndef APB_DATA_WIDTH
     `define APB_DATA_WIDTH     32         
  `endif

  `ifndef APB_PSEL_WIDTH
     `define APB_PSEL_WIDTH     1          
  `endif

  `ifndef APB_IF_SETUP_TIME
     `define APB_IF_SETUP_TIME  1          
  `endif

  `ifndef APB_IF_HOLD_TIME
     `define APB_IF_HOLD_TIME   1          
  `endif

`endif



//=============================================================================
// Project       : APB VIP
//=============================================================================
// Filename      : apb_if.sv
// Author        : Huy Nguyen
// Company       : NO
// Date          : 13-Dec-2021
//=============================================================================
// Description   : 
//
//
//
//=============================================================================
`ifndef GUARD_APB_IF__SV
`define GUARD_APB_IF__SV

interface apb_if();

  logic                        pclk;  
  logic                        presetn;  
  logic [`APB_ADDR_WIDTH-1:0]  paddr;  
  logic                        pwrite; 
  logic [`APB_PSEL_WIDTH-1:0]  psel;   
  logic                        penable;
  logic [`APB_DATA_WIDTH-1:0]  pwdata; 
  logic                        pready; 
  logic [`APB_DATA_WIDTH-1:0]  prdata; 
  logic                        pslverr;

  /* Clocking block that defines VIP APB Master Interface signal synchronization and directionality */
  clocking apb_master_cb @ ( posedge pclk );
    default input #`APB_IF_SETUP_TIME output #`APB_IF_HOLD_TIME;
    output psel;
    output penable;
    output pwrite;
    output paddr;
    output pwdata;
    input prdata;
    input pready;
    input pslverr;
   endclocking: apb_master_cb
 
  /* Clocking block that defines VIP APB Slave Interface signal synchronization and directionality */
  clocking apb_slave_cb @ ( posedge pclk );
    default input #`APB_IF_SETUP_TIME output #`APB_IF_HOLD_TIME;
    input psel;
    input penable;
    input pwrite;
    input paddr;
    input pwdata;
//HN-    output prdata;
//HN-    output pready;
//HN-    output pslverr;
  endclocking: apb_slave_cb
  
  /* Clocking block that defines VIP APB Monitor Interface signal synchronization and directionality. */
  clocking apb_monitor_cb @ ( posedge pclk );
    default input #`APB_IF_SETUP_TIME output #`APB_IF_HOLD_TIME;
    input presetn;
    input psel;
    input penable;
    input pwrite;
    input paddr;
    input pwdata;
    input prdata;
    input pready;
    input pslverr;
  endclocking: apb_monitor_cb

endinterface

`endif



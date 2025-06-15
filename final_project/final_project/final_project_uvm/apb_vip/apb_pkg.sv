//=============================================================================
// Project       : APB VIP
//=============================================================================
// Filename      : apb_pkg.sv
// Author        : Huy Nguyen
// Company       : NO
// Date          : 13-Dec-2021
//=============================================================================
// Description   : 
//
//
//
//=============================================================================
`ifndef GUARD_APB_PACKAGE__SV
`define GUARD_APB_PACKAGE__SV

package apb_pkg;
  import uvm_pkg::*;

//  `include "apb_timescale.sv"
  `include "apb_define.sv"
  `include "apb_types.sv"
  `include "apb_configuration.sv"
  `include "apb_status.sv"
  `include "apb_transaction.sv"
  `include "apb_master_transaction.sv"
  `include "apb_master_sequencer.sv"
  `include "apb_master_driver.svp"
  `include "apb_master_monitor.svp"
  `include "apb_master_agent.sv"
  `include "apb_slave_transaction.sv"
  `include "apb_slave_sequencer.sv"
  `include "apb_slave_auto_response.sv"
  `include "apb_slave_driver.svp"
  `include "apb_slave_monitor.svp"
  `include "apb_slave_agent.sv"

endpackage: apb_pkg

`endif




covergroup APB_GROUP;
  APB_XACT: coverpoint apb_pkt.xact_type {
    bins APB_WRITE = {apb_types::WRITE};
    bins APB_READ  = {apb_types::READ};
  }
  APB_ADDRESS: coverpoint apb_pkt.address {
    bins MDR = {8'h00};
    bins DLL = {8'h01};
    bins DLH = {8'h02};
    bins LCR = {8'h03};
    bins IER = {8'h04};
  }
  TEST: cross APB_XACT , APB_ADDRESS;

endgroup

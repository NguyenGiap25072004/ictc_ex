class timer_cov_wrapper extends uvm_object;
  `uvm_object_utils(timer_cov_wrapper)

  apb_master_transaction apb_pkt;

  `include "timer_cov.sv";

  function new(string name="timer_cov_wrapper");
    super.new(name);
    apb_pkt = new();
    APB_GROUP = new();
  endfunction

  virtual function void apb_sample(apb_master_transaction m_apb_pkt);
    $cast(apb_pkt,m_apb_pkt);
    APB_GROUP.sample();
  endfunction

endclass

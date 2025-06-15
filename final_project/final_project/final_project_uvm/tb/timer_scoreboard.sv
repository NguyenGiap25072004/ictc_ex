`uvm_analysis_imp_decl(_apb)
`uvm_analysis_imp_decl(_timer)

class timer_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(timer_scoreboard)

  timer_cov_wrapper func_cov;

  uvm_analysis_imp_apb #(apb_master_transaction, timer_scoreboard) apb_port;
//HN-  uvm_analysis_imp_timer  #(timer_transaction, timer_scoreboard) ;

  function new(string name="timer_scoreboard", uvm_component parent);
    super.new(name,parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    func_cov = new();
    apb_port = new("apb_port",this);
  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);
  endtask: run_phase

  virtual function void write_apb(apb_master_transaction trans);
    `uvm_info(get_type_name(),"Get packet from APB...",UVM_HIGH)
    func_cov.apb_sample(trans);
  endfunction: write_apb

//HN-  virtual function void write_rhs(timer_transaction trans);
//HN-    `uvm_info(get_type_name(),"Get packet from rhs...",UVM_MEDIUM)
//HN-  endfunction: write_rhs

  virtual function void check_phase(uvm_phase phase);
    super.check_phase(phase);
  endfunction: check_phase

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
  endfunction: report_phase

endclass: timer_scoreboard



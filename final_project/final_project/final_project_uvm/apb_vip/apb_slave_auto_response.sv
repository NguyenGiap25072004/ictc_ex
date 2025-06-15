//=============================================================================
// Project       : APB VIP
//=============================================================================
// Filename      : apb_slave_auto_response.sv
// Author        : Huy Nguyen
// Company       : NO
// Date          : 13-Dec-2021
//=============================================================================
// Description   : 
//
//
//
//=============================================================================
`ifndef GUARD_APB_SLAVE_AUTO_RESPONSE__SV
`define GUARD_APB_SLAVE_AUTO_RESPONSE__SV

class apb_slave_auto_response extends uvm_sequence #(apb_slave_transaction);
  `uvm_object_utils(apb_slave_auto_response)
  `uvm_declare_p_sequencer(apb_slave_sequencer)

  apb_slave_transaction req_rsp;

  function new(string name="apb_slave_auto_response");
    super.new(name);
  endfunction: new

  virtual task body();

    forever begin
      p_sequencer.wait_next_transaction(req_rsp); 
      `uvm_info(get_name(),$sformatf("Slave get request from master is: \n%s",req_rsp.sprint()),UVM_LOW)
      req = apb_slave_transaction::type_id::create("req");
      start_item(req);
      assert(req.randomize() with { solve xact_type before data;
                                    req.xact_type == req_rsp.xact_type;
                                    req.address   == req_rsp.address;
                                    if(req.xact_type == apb_types::WRITE) {
                                      req.data == req_rsp.data;
                                    }                                    
                                   req.num_wait_cycle dist { 0:/70,
                                                             [1:5] :/20,
                                                             [6:10]:/10};
                                   req.pslverr_enable dist {0:/70,
                                                            1:/30};                                   
                                  })
      else begin
        `uvm_fatal(get_name(),$sformatf("Randomize failed"))
      end
      finish_item(req);
    end
  endtask: body

endclass: apb_slave_auto_response

`endif



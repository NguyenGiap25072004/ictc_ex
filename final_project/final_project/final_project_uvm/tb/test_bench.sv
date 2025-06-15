`timescale 1ps/1ps
module test_bench;

  import uvm_pkg::*;
  import apb_pkg::*;
  import timer_test_pkg::*;

  reg  clk, rst_n;
  reg  dbg_mode;
  wire tim_int;

  /** Instantiate APB Interface */
  apb_if i_apb_if();

  //instance DUT
  timer_top u_timer 
  (
      .sys_clk    (   clk     ),
      .sys_rst_n  (   rst_n   ),
      .tim_psel   (  i_apb_if.psel    ),
      .tim_pwrite (  i_apb_if.pwrite  ),
      .tim_penable(  i_apb_if.penable ),
      .tim_paddr   ( i_apb_if.paddr    ),
      .tim_pwdata  ( i_apb_if.pwdata   ),
      .tim_prdata  ( i_apb_if.prdata   ),
      .tim_pready  ( i_apb_if.pready   ),
      .tim_pstrb   (/* i_apb_if.pstrb*/), // VIP is not support strobe feature yet
      .tim_pslverr ( i_apb_if.pslverr  ),
      .dbg_mode    ( dbg_mode ) ,
      .tim_int     ( tim_int));
  	
  initial begin 
    clk = 0;
    forever #25 clk = ~clk;
  end

  initial begin
    rst_n = 1'b0;
    #100 rst_n = 1'b1;
  end
  
  //Connect to CLK&RST source
  assign i_apb_if.pclk    = clk;
  assign i_apb_if.presetn = rst_n;

  /** Set the VIP interface on the environment */
  initial begin
    uvm_config_db#(virtual apb_if)::set(uvm_root::get(),"uvm_test_top","apb_vif",i_apb_if);

    /** Start the UVM test */
    run_test();
  end

endmodule

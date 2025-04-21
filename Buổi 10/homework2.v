`timescale 1ns / 1ps 

module test_bench;

  // Tín hiệu Master
  reg pclk;
  reg psel;
  reg pwrite;
  reg penable;
  reg [15:0] paddr;
  reg [31:0] pwdata;

  // Tín hiệu Slave
  reg pready;
  reg [31:0] prdata;

  parameter CLK_PERIOD = 10; 
  initial begin
    pclk = 0;
    forever #(CLK_PERIOD / 2) pclk = ~pclk; 
  end

  // ---- Logic mô phỏng Slave ----
  reg [3:0] target_delay_reg; 
  reg [3:0] current_wait_reg; 
  reg transfer_active_prev_reg; 

  initial begin
      // Khởi tạo giá trị ban đầu cho logic Slave
      pready = 1'b0;
      prdata = 32'hxxxxxxxx;
      current_wait_reg = 0;
      transfer_active_prev_reg = 0;
      target_delay_reg = 0;
  end

  always @(posedge pclk) begin
      logic transfer_active_now;
      transfer_active_now = psel && penable; 

      if (!transfer_active_now) begin
          pready <= 1'b0; 
          current_wait_reg <= 0; 
      end else begin 
          if (!transfer_active_prev_reg) begin
              target_delay_reg <= $urandom_range(5, 0); 
              current_wait_reg <= 0; 
              $display("TIME %0t: [SLAVE] Access detected. Random delay = %0d cycles.", $time, target_delay_reg);

              if (target_delay_reg == 0) begin
                  pready <= 1'b1;
                  $display("TIME %0t: [SLAVE] Asserting PREADY (0 cycle delay).", $time);
                  if (!pwrite) begin 
                      prdata <= $random; 
                      $display("TIME %0t: [SLAVE] Providing PRDATA = 0x%h (valid on next edge)", $time, prdata);
                  end
              end else begin
                  pready <= 1'b0;
              end
          end else if (!pready) begin
              if (current_wait_reg < target_delay_reg) begin
                   current_wait_reg <= current_wait_reg + 1; 
              end

              if (current_wait_reg + 1 == target_delay_reg) begin
                  pready <= 1'b1; 
                  $display("TIME %0t: [SLAVE] Asserting PREADY after %0d wait cycles (effective next edge).", $time, target_delay_reg);
                  if (!pwrite) begin 
                      prdata <= $random; 
                      $display("TIME %0t: [SLAVE] Providing PRDATA = 0x%h (valid on next edge)", $time, prdata);
                  end
              end
          end
      end
      transfer_active_prev_reg <= transfer_active_now; 
  end

  // ---- Task: Write Transfer----
  task apb_master_write (input [15:0] addr_in, input [31:0] data_in);
    begin
      // --- SETUP ---
      paddr   <= addr_in;
      pwdata  <= data_in;
      pwrite  <= 1'b1;
      psel    <= 1'b1;
      penable <= 1'b0;
      @(posedge pclk);
      $display("TIME %0t: [WRITE] Setup Phase   -> Addr=0x%h, WData=0x%h, PSEL=1, PWRITE=1, PENABLE=0", $time, addr_in, data_in);

      // --- ACCESS Phase + Wait States ---
      penable <= 1'b1; 
      $display("TIME %0t: [WRITE] Access Phase Start -> PENABLE=1", $time);

      // --- Chờ PREADY ---
      $display("TIME %0t: [WRITE] Waiting for PREADY...", $time);
      while (!pready) begin
        @(posedge pclk);
         $display("TIME %0t: [WRITE] Still waiting... (PREADY=%b)", $time, pready);
      end
      // Pready = 1 tại sườn clock này

      $display("TIME %0t: [WRITE] PREADY detected!", $time);
      @(posedge pclk); 

      // --- END ---
      $display("TIME %0t: [WRITE] End Phase     -> PSEL=0, PWRITE=0, PENABLE=0", $time);
      psel    <= 1'b0;
      penable <= 1'b0;
      pwrite  <= 1'b0;
    end
  endtask 

  // ---- Task: Master Read Transfer ----
  task apb_master_read (input [15:0] addr_in);
    reg [31:0] read_data_reg; 
    begin
      // --- SETUP ---
      paddr   <= addr_in;
      pwrite  <= 1'b0; 
      psel    <= 1'b1;
      penable <= 1'b0;
      pwdata  <= 32'hxxxxxxxx;
      @(posedge pclk);
      $display("TIME %0t: [READ]  Setup Phase   -> Addr=0x%h, PSEL=1, PWRITE=0, PENABLE=0", $time, addr_in);

      // --- ACCESS Phase + Wait States ---
      penable <= 1'b1;
      $display("TIME %0t: [READ]  Access Phase Start -> PENABLE=1", $time);

      // --- Chờ PREADY ---
      $display("TIME %0t: [READ]  Waiting for PREADY...", $time);
      while (!pready) begin
        @(posedge pclk);
        $display("TIME %0t: [READ] Still waiting... (PREADY=%b)", $time, pready);
      end
      // Pready = 1 tại sườn clock này

      // --- Đọc dữ liệu và In ra ---
      read_data_reg = prdata; 
      $display("TIME %0t: [READ]  PREADY detected! Reading PRDATA = 0x%h", $time, read_data_reg);

      @(posedge pclk); 

      // --- END ---
      $display("TIME %0t: [READ]  End Phase     -> PSEL=0, PENABLE=0", $time);
      psel    <= 1'b0;
      penable <= 1'b0;
    end
  endtask 

  // ---- Task đợi clock (Em viết thêm) ----
  task wait_clk_cycles (input integer num_cycles);
      if (num_cycles > 0) begin
          $display("INFO: Waiting for %0d idle cycles...", num_cycles);
          repeat (num_cycles) @(posedge pclk);
      end
  endtask

  // ---- Test ----
  initial begin
    // Khởi tạo tín hiệu Master ban đầu
    psel = 1'b0;
    pwrite = 1'b0;
    penable = 1'b0;
    paddr = 16'hxxxx;
    pwdata = 32'hxxxxxxxx;

    # (CLK_PERIOD * 2);

    $display("\nINFO: ========================================================");
    $display("INFO: Starting APB Master/Slave Simulation at time %0t", $time);
    $display("INFO: ========================================================\n");

    // --- 1: Write ---
    @(posedge pclk); 
    $display("INFO: ---> Calling master_write(0x1000, 0xAAAAAAAA) at time %0t", $time);
    apb_master_write(16'h1000, 32'hAAAAAAAA);
    $display("INFO: ---> master_write finished at time %0t\n", $time);

    wait_clk_cycles(3); 

    // --- 2: Read ---
    @(posedge pclk);
    $display("INFO: ---> Calling master_read(0x20A0) at time %0t", $time);
    apb_master_read(16'h20A0);
    $display("INFO: ---> master_read finished at time %0t\n", $time);

    wait_clk_cycles(2);

    // --- 3: Write (địa chỉ khác) ---
     @(posedge pclk);
    $display("INFO: ---> Calling master_write(0x1234, 0xBBBBBBBB) at time %0t", $time);
    apb_master_write(16'h1234, 32'hBBBBBBBB);
    $display("INFO: ---> master_write finished at time %0t\n", $time);

    wait_clk_cycles(1);

    // --- 4: Read (địa chỉ khác) ---
     @(posedge pclk);
    $display("INFO: ---> Calling master_read(0x5678) at time %0t", $time);
    apb_master_read(16'h5678);
    $display("INFO: ---> master_read finished at time %0t\n", $time);

    wait_clk_cycles(5);
    $display("INFO: ========================================================");
    $display("INFO: Simulation finished at time %0t", $time);
    $display("INFO: ========================================================");
    $finish;
  end

endmodule 
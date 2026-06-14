module top_tb;

  logic clk;

  // clock generation
  always #5 clk = ~clk;

  // interface
  bird_if vif(clk);

  // DUT
  bird dut (
    .clk(clk),
    .rst_n(vif.rst_n),

    .in_vld(vif.in_vld),
    .in_rdy(vif.in_rdy),
    .data_in(vif.data_in),
    .cfg(vif.cfg),

    .drop_cnt(),

    .local_vld(vif.local_vld),
    .local_rdy(vif.local_rdy),
    .data_local(vif.data_local),

    .remote_vld(vif.remote_vld),
    .remote_rdy(vif.remote_rdy),
    .data_remote(vif.data_remote)
  );

  // environment
  bird_env env;

  initial begin

    // =========================
    // FSDB WAVES (IMPORTANT)
    // =========================
    $dumpfile("waves.vcd");
    $dumpvars(0, top_tb);

    // init clock + reset
    clk = 0;
    vif.rst_n = 0;

    // ready signals
    vif.local_rdy  = 1;
    vif.remote_rdy = 1;

    // reset time
    #20;
    vif.rst_n = 1;

    // create environment
    env = new(vif);

    fork
      env.run();
    join_none

    // =========================
    // TEST CASES
    // =========================

    begin

      bird_packet pkt;
      pkt = new();

      // =========================
      // TP1: Local Traffic Routing
      // =========================
      pkt.traffic_type = 0;   // local
      pkt.payload_len  = 3;
      pkt.frag_num     = 1;
      pkt.seq_num      = 1;

      pkt.payload = new[3];
      pkt.payload = '{8'hAA, 8'hBB, 8'hCC};

      pkt.crc[0] = 8'h00;
      pkt.crc[1] = 8'h00;

      #10;

      env.drv.drive_packet(pkt);

    end

    // wait for simulation to finish
    #200;

    $display("TEST FINISHED");
    $finish;

  end

endmodule

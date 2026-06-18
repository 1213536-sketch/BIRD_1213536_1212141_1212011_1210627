module top_tb;

  // ============================================
  // Clock and Reset
  // ============================================
  logic clk;
  logic rst_n;
  
  logic [15:0] drop_cnt_check;

  initial clk = 0;
  always #5 clk = ~clk;

  // ============================================
  // Interface and DUT
  // ============================================
  bird_if vif();

  assign vif.clk = clk;

  bird dut (
    .clk(clk),
    .rst_n(vif.rst_n),
    .in_vld(vif.in_vld),
    .in_rdy(vif.in_rdy),
    .data_in(vif.data_in),
    .cfg(vif.cfg),
    .drop_cnt(drop_cnt_check),
    .local_vld(vif.local_vld),
    .local_rdy(vif.local_rdy),
    .data_local(vif.data_local),
    .remote_vld(vif.remote_vld),
    .remote_rdy(vif.remote_rdy),
    .data_remote(vif.data_remote)
  );

  // ============================================
  // Environment
  // ============================================
  bird_env env;

  // ============================================
  // Helper task to drive a packet
  // ============================================
  task send_packet(bird_packet pkt);
    $display("[TB] Sending packet...");
    pkt.display("[TB]");
    env.driver.drive_packet(pkt);
    #10;
  endtask

  // ============================================
  // Helper task to perform reset
  // ============================================
  task perform_reset(input int duration = 30);
    $display("\n[TB] ========================================");
    $display("[TB] PERFORMING RESET");
    $display("[TB] ========================================");
    
    vif.rst_n = 0;
    #duration;
    vif.rst_n = 1;
    #20;
    
    $display("[TB] Reset complete. drop_cnt = %0d", drop_cnt_check);
    $display("[TB] ========================================\n");
  endtask

  // ============================================
  // Main Test
  // ============================================
  initial begin

    // ============================================
    // Declare all packet variables
    // ============================================
    bird_packet reset_pkt;
    bird_packet post_reset_pkt;
    bird_packet invalid_pkt;
    bird_packet reserved_pkt;
    bird_packet len0_pkt;
    bird_packet len300_pkt;
    bird_packet bp_local_pkt;
    bird_packet bp_local_pkt2;
    bird_packet bp_remote_pkt;
    bird_packet bp_remote_pkt2;
    bird_packet bp_remote_pkt3;
    bird_packet bp_remote_pkt4;
    bird_packet reset1_pkt;
    bird_packet reset2_pkt;
    bird_packet frag_pkt;
    bird_packet seq_pkt;
    bird_packet len_pkt;
    
    logic [15:0] drop_cnt_before;
    logic [15:0] drop_cnt_after;

    // ============================================
    // Initialize
    // ============================================
    vif.rst_n = 0;
    vif.local_rdy = 1;
    vif.remote_rdy = 1;

    #20 vif.rst_n = 1;

    env = new(vif);

    fork
      env.run();
    join_none

    // Wait for environment to stabilize
    #100;

    // ============================================
    // TEST 1: Local Packets (5 packets) - from generator
    // ============================================
    $display("\n[TB] ========================================");
    $display("[TB] TEST 1: Local Packets (from generator)");
    $display("[TB] ========================================");
    #500;

    // ============================================
    // TEST 2: Remote Packet (In-Order) - from generator
    // ============================================
    $display("\n[TB] ========================================");
    $display("[TB] TEST 2: Remote Packet (In-Order)");
    $display("[TB] ========================================");
    #300;

    // ============================================
    // TEST 3: Remote Packet (Out-of-Order) - from generator
    // ============================================
    $display("\n[TB] ========================================");
    $display("[TB] TEST 3: Remote Packet (Out-of-Order)");
    $display("[TB] ========================================");
    #300;

    // ============================================
    // TEST 4: Drop Conditions - from generator
    // ============================================
    $display("\n[TB] ========================================");
    $display("[TB] TEST 4: Drop Conditions");
    $display("[TB] ========================================");
    #500;

    // ============================================
    // TEST 5: Mismatched SEQ_NUM - from generator
    // ============================================
    $display("\n[TB] ========================================");
    $display("[TB] TEST 5: Mismatched SEQ_NUM");
    $display("[TB] ========================================");
    #300;

    // ============================================
    // TEST 6: Missing Fragment - from generator
    // ============================================
    $display("\n[TB] ========================================");
    $display("[TB] TEST 6: Missing Fragment");
    $display("[TB] ========================================");
    #300;

    // ============================================
    // TEST 7: Reset Behavior
    // ============================================
    $display("\n[TB] ========================================");
    $display("[TB] TEST 7: Reset Behavior");
    $display("[TB] ========================================");
    
    reset_pkt = new();
    reset_pkt.traffic_type = 0;
    reset_pkt.seq_num = 1;
    reset_pkt.frag_num = 1;
    reset_pkt.payload_len = 3;
    reset_pkt.payload = '{8'hAA, 8'hBB, 8'hCC};
    reset_pkt.crc[0] = 0;
    reset_pkt.crc[1] = 0;
    send_packet(reset_pkt);
    #50;
    
    drop_cnt_before = drop_cnt_check;
    $display("[TB] drop_cnt before reset = %0d", drop_cnt_before);
    perform_reset(30);
    drop_cnt_after = drop_cnt_check;
    $display("[TB] drop_cnt after reset = %0d", drop_cnt_after);
    
    if (drop_cnt_after == 0) begin
      $display("[TB] ✅ RESET PASS: drop_cnt cleared to 0");
    end else begin
      $display("[TB] ❌ RESET FAIL: drop_cnt should be 0, but is %0d", drop_cnt_after);
    end
    
    post_reset_pkt = new();
    post_reset_pkt.traffic_type = 0;
    post_reset_pkt.seq_num = 1;
    post_reset_pkt.frag_num = 1;
    post_reset_pkt.payload_len = 3;
    post_reset_pkt.payload = '{8'hDD, 8'hEE, 8'hFF};
    post_reset_pkt.crc[0] = 0;
    post_reset_pkt.crc[1] = 0;
    send_packet(post_reset_pkt);
    #100;

    // ============================================
    // TEST 8: Remote Packet with MAX Values - from generator
    // ============================================
    $display("\n[TB] ========================================");
    $display("[TB] TEST 8: Remote Packet with MAX Values");
    $display("[TB] ========================================");
    #500;

    // ============================================
    // TEST 9: Drop Counter Wrap-Around
    // ============================================
    $display("\n[TB] ========================================");
    $display("[TB] TEST 9: Drop Counter Wrap-Around");
    $display("[TB] ========================================");
    
    for (int i = 0; i < 10; i++) begin
      invalid_pkt = new();
      invalid_pkt.traffic_type = 1;
      invalid_pkt.seq_num = 0;
      invalid_pkt.frag_num = 1;
      invalid_pkt.payload_len = 3;
      invalid_pkt.payload = '{8'hAA, 8'hBB, 8'hCC};
      invalid_pkt.crc[0] = 0;
      invalid_pkt.crc[1] = 0;
      send_packet(invalid_pkt);
      #20;
    end
    #100;

    // ============================================
    // TEST 10: Reserved Bits Non-Zero
    // ============================================
    $display("\n[TB] ========================================");
    $display("[TB] TEST 10: Reserved Bits Non-Zero");
    $display("[TB] ========================================");
    
    reserved_pkt = new();
    reserved_pkt.traffic_type = 1;
    reserved_pkt.seq_num = 50;
    reserved_pkt.frag_num = 1;
    reserved_pkt.payload_len = 3;
    reserved_pkt.payload = '{8'h11, 8'h22, 8'h33};
    reserved_pkt.reserved1 = 7'h7F;
    reserved_pkt.crc[0] = 0;
    reserved_pkt.crc[1] = 0;
    send_packet(reserved_pkt);
    #100;

    // ============================================
    // TEST 11: Invalid PAYLOAD_LEN
    // ============================================
    $display("\n[TB] ========================================");
    $display("[TB] TEST 11: Invalid PAYLOAD_LEN");
    $display("[TB] ========================================");
    
    len0_pkt = new();
    len0_pkt.traffic_type = 1;
    len0_pkt.seq_num = 60;
    len0_pkt.frag_num = 1;
    len0_pkt.payload_len = 0;
    len0_pkt.payload = new[0];
    len0_pkt.crc[0] = 0;
    len0_pkt.crc[1] = 0;
    send_packet(len0_pkt);
    #50;
    
    len300_pkt = new();
    len300_pkt.traffic_type = 1;
    len300_pkt.seq_num = 61;
    len300_pkt.frag_num = 1;
    len300_pkt.payload_len = 300;
    len300_pkt.payload = new[300];
    for (int i = 0; i < 300; i++) begin
      len300_pkt.payload[i] = i[7:0];
    end
    len300_pkt.crc[0] = 0;
    len300_pkt.crc[1] = 0;
    send_packet(len300_pkt);
    #100;

    // ============================================
    // TEST 12: Backpressure Tests
    // ============================================
    $display("\n[TB] ========================================");
    $display("[TB] TEST 12: Backpressure Tests");
    $display("[TB] ========================================");
    
    // Local Backpressure
    vif.local_rdy = 0;
    #100;
    vif.local_rdy = 1;
    
    bp_local_pkt = new();
    bp_local_pkt.traffic_type = 0;
    bp_local_pkt.seq_num = 1;
    bp_local_pkt.frag_num = 1;
    bp_local_pkt.payload_len = 8;
    bp_local_pkt.payload = new[8];
    for (int i = 0; i < 8; i++) begin
      bp_local_pkt.payload[i] = i + 100;
    end
    bp_local_pkt.crc[0] = 0;
    bp_local_pkt.crc[1] = 0;
    send_packet(bp_local_pkt);
    #100;
    
    // Remote Backpressure
    vif.remote_rdy = 0;
    #100;
    vif.remote_rdy = 1;
    
    bp_remote_pkt = new();
    bp_remote_pkt.traffic_type = 1;
    bp_remote_pkt.seq_num = 70;
    bp_remote_pkt.frag_num = 1;
    bp_remote_pkt.payload_len = 8;
    bp_remote_pkt.payload = new[8];
    for (int i = 0; i < 8; i++) begin
      bp_remote_pkt.payload[i] = i + 300;
    end
    bp_remote_pkt.crc[0] = 0;
    bp_remote_pkt.crc[1] = 0;
    send_packet(bp_remote_pkt);
    #100;

    // ============================================
    // TEST 13: Multiple Resets
    // ============================================
    $display("\n[TB] ========================================");
    $display("[TB] TEST 13: Multiple Resets");
    $display("[TB] ========================================");
    
    perform_reset(20);
    
    reset1_pkt = new();
    reset1_pkt.traffic_type = 0;
    reset1_pkt.seq_num = 1;
    reset1_pkt.frag_num = 1;
    reset1_pkt.payload_len = 3;
    reset1_pkt.payload = '{8'h11, 8'h22, 8'h33};
    reset1_pkt.crc[0] = 0;
    reset1_pkt.crc[1] = 0;
    send_packet(reset1_pkt);
    #50;
    
    perform_reset(30);
    
    reset2_pkt = new();
    reset2_pkt.traffic_type = 0;
    reset2_pkt.seq_num = 1;
    reset2_pkt.frag_num = 1;
    reset2_pkt.payload_len = 3;
    reset2_pkt.payload = '{8'h44, 8'h55, 8'h66};
    reset2_pkt.crc[0] = 0;
    reset2_pkt.crc[1] = 0;
    send_packet(reset2_pkt);
    #50;
    
    perform_reset(40);
    $display("[TB] Multiple resets completed");

    // ============================================
    // TEST 14: Extensive FRAG_NUM - from generator
    // ============================================
    $display("\n[TB] ========================================");
    $display("[TB] TEST 14: Extensive FRAG_NUM (from generator)");
    $display("[TB] ========================================");
    #200;

    // ============================================
    // TEST 15: Extensive PAYLOAD_LEN - from generator
    // ============================================
    $display("\n[TB] ========================================");
    $display("[TB] TEST 15: Extensive PAYLOAD_LEN (from generator)");
    $display("[TB] ========================================");
    #200;

    // ============================================
    // TEST 16: Local Packets with Different Sizes - from generator
    // ============================================
    $display("\n[TB] ========================================");
    $display("[TB] TEST 16: Local Packets with Different Sizes");
    $display("[TB] ========================================");
    #200;

    // ============================================
    // TEST 17: Remote Packets with Different FRAG_NUM and SEQ_NUM Combos - from generator
    // ============================================
    $display("\n[TB] ========================================");
    $display("[TB] TEST 17: Remote Packets with Different FRAG_NUM and SEQ_NUM Combos");
    $display("[TB] ========================================");
    #200;

    // ============================================
    // TEST 18: Remote Packets with FRAG_NUM=2 Only - from generator
    // ============================================
    $display("\n[TB] ========================================");
    $display("[TB] TEST 18: Remote Packets with FRAG_NUM=2 Only");
    $display("[TB] ========================================");
    #200;

    // ============================================
    // Wait for scoreboard
    // ============================================
    #500;

    // ============================================
    // Print Final Report
    // ============================================
    env.sb.report(); 

    $display("\n[TB] ========================================");
    $display("[TB] TEST FINISHED");
    $display("[TB] Final drop_cnt = %0d", drop_cnt_check);
    $display("[TB] ========================================\n");
    $finish;

  end

endmodule

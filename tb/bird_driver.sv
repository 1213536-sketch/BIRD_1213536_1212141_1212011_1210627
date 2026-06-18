import bird_pkg::*;

class bird_driver;

  virtual bird_if vif;
  mailbox #(bird_packet) gen_mb;

  function new(virtual bird_if vif, mailbox #(bird_packet) gen_mb);
    this.vif = vif;
    this.gen_mb = gen_mb;
  endfunction

  // ============================================
  // Original run task (reads from mailbox)
  // ============================================
  task run();

    bird_packet pkt;

    forever begin

      $display("[DRIVER] Waiting for packet from generator...");
      gen_mb.get(pkt);
      $display("[DRIVER] Received packet seq=%0d frag=%0d len=%0d", 
               pkt.seq_num, pkt.frag_num, pkt.payload_len);

      drive_packet(pkt);

    end

  endtask

  // ============================================
  // New drive_packet task (can be called directly)
  // ============================================
  task drive_packet(bird_packet pkt);

    @(posedge vif.clk);
    while (!vif.in_rdy) @(posedge vif.clk);

    vif.in_vld <= 1;
    vif.data_in <= pkt.payload[0];
    
    // ✅ استخدام get_cfg() بدلاً من القيمة الثابتة
    vif.cfg <= pkt.get_cfg();

    $display("[DRIVER] Sending cfg=%h seq=%0d frag=%0d len=%0d type=%0d",
             vif.cfg, pkt.seq_num, pkt.frag_num, pkt.payload_len, pkt.traffic_type);

    for (int i = 1; i < pkt.payload.size(); i++) begin
      @(posedge vif.clk);
      vif.data_in <= pkt.payload[i];
    end

    // Send CRC bytes (2 bytes)
    @(posedge vif.clk);
    vif.data_in <= pkt.crc[0];
    @(posedge vif.clk);
    vif.data_in <= pkt.crc[1];

    @(posedge vif.clk);
    vif.in_vld <= 0;
    vif.cfg <= 0;

  endtask

endclass

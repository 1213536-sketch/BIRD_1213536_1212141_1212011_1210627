import bird_pkg::*;

class bird_driver;

  virtual bird_if vif;
  mailbox #(bird_packet) gen_mb;

  function new(virtual bird_if vif, mailbox #(bird_packet) gen_mb);
    this.vif = vif;
    this.gen_mb = gen_mb;
  endfunction

  task run();

    bird_packet pkt;

    forever begin

      $display("[DRIVER] Waiting for packet from generator...");
      gen_mb.get(pkt);
      $display("[DRIVER] Received packet seq=%0d frag=%0d len=%0d", 
               pkt.seq_num, pkt.frag_num, pkt.payload_len);

      @(posedge vif.clk);
      while (!vif.in_rdy) @(posedge vif.clk);

      vif.in_vld <= 1;
      vif.data_in <= pkt.payload[0];
      vif.cfg <= 32'h01011800;  // ✅ قيمة ثابتة: seq=1, frag=1, len=24, type=0

      $display("[DRIVER] Sending cfg=%h seq=%0d frag=%0d len=%0d type=%0d",
               vif.cfg, pkt.seq_num, pkt.frag_num, pkt.payload_len, pkt.traffic_type);

      for (int i = 1; i < pkt.payload_len; i++) begin
        @(posedge vif.clk);
        vif.data_in <= pkt.payload[i];
      end

      @(posedge vif.clk);
      vif.in_vld <= 0;
      vif.cfg <= 0;

    end

  endtask

endclass

class input_monitor;

  virtual bird_if vif;
  mailbox #(bird_packet) mon2sb;

  function new(virtual bird_if vif, mailbox #(bird_packet) mon2sb);
    this.vif    = vif;
    this.mon2sb = mon2sb;
  endfunction

  task run();

    bird_packet pkt;

    forever begin

      wait(vif.in_vld && vif.in_rdy);

      pkt = new();

      pkt.traffic_type = vif.cfg[0];
      pkt.payload_len  = vif.cfg[15:8];
      pkt.frag_num     = vif.cfg[20:16];
      pkt.seq_num      = vif.cfg[28:24];

      pkt.payload = new[pkt.payload_len];

      pkt.payload[0] = vif.data_in;

      for (int i = 1; i < pkt.payload_len; i++) begin
        @(posedge vif.clk);
        pkt.payload[i] = vif.data_in;
      end

      pkt.crc[0] = 8'h00;
      pkt.crc[1] = 8'h00;

      mon2sb.put(pkt);

      $display("[INPUT MONITOR] Packet Captured");

    end

  endtask

endclass

class remote_monitor;

  virtual bird_if vif;
  mailbox #(bird_packet) mon2sb;

  function new(virtual bird_if vif, mailbox #(bird_packet) mon2sb);
    this.vif    = vif;
    this.mon2sb = mon2sb;
  endfunction

  task run();

    bird_packet pkt;
    int frag_count;

    pkt = new();
    frag_count = 0;

    forever begin

      wait(vif.remote_vld && vif.remote_rdy);

      // ----------------------------
      // First fragment → initialize packet
      // ----------------------------
      if (frag_count == 0) begin

        pkt = new();

        pkt.seq_num      = vif.data_remote[28:24];
        pkt.frag_num     = vif.data_remote[20:16];
        pkt.payload_len  = vif.data_remote[15:8];
        pkt.traffic_type = vif.data_remote[0];

        pkt.payload = new[pkt.payload_len];

      end

      // ----------------------------
      // store data (simplified model)
      // ----------------------------
      pkt.payload[frag_count] = vif.data_remote[7:0];

      frag_count++;

      // ----------------------------
      // end of packet (when all fragments received)
      // ----------------------------
      if (frag_count == pkt.payload_len) begin

        pkt.crc[0] = 8'h00; // placeholder (DUT may provide differently)
        pkt.crc[1] = 8'h00;

        mon2sb.put(pkt);

        $display("[REMOTE MONITOR] Packet Reassembled");

        pkt.display();

        frag_count = 0;

      end

    end

  endtask

endclass

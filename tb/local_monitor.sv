class local_monitor;

  virtual bird_if vif;
  mailbox #(bird_packet) mon2sb;
  mailbox #(bird_packet) exp_mb;

  function new(virtual bird_if vif, mailbox #(bird_packet) mon2sb, mailbox #(bird_packet) exp_mb);
    this.vif = vif;
    this.mon2sb = mon2sb;
    this.exp_mb = exp_mb;
  endfunction

  task run();

    bird_packet pkt;
    int payload_index = 0;

    forever begin

      @(posedge vif.clk);

      if (vif.local_vld && vif.local_rdy) begin

        pkt = new();

        pkt.seq_num = 1;
        pkt.frag_num = 1;
        pkt.payload_len = 24;
        pkt.payload = new[24];

        // ✅ اقرأ الحمولة كاملة من data_local
        for (int i = 0; i < 24; i++) begin
          pkt.payload[i] = vif.data_local;
          $display("[LOCAL MON] payload[%0d]=%0d", i, vif.data_local);
          @(posedge vif.clk);
        end

        pkt.crc[0] = 0;
        pkt.crc[1] = 0;

        mon2sb.put(pkt);
        exp_mb.put(pkt);

        $display("[LOCAL MON] Data captured");

      end

    end

  endtask

endclass

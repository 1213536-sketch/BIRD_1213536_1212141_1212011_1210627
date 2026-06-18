class input_monitor;

  virtual bird_if vif;
  mailbox #(bird_packet) act_mb;
  mailbox #(bird_packet) exp_mb;
  mailbox #(bit) drop_mb;

  function new(virtual bird_if vif, 
               mailbox #(bird_packet) act_mb, 
               mailbox #(bird_packet) exp_mb, 
               mailbox #(bit) drop_mb);
    this.vif = vif;
    this.act_mb = act_mb;
    this.exp_mb = exp_mb;
    this.drop_mb = drop_mb;
  endfunction

  task run();

    bird_packet pkt;

    forever begin

      @(posedge vif.clk);

      if (vif.in_vld && vif.in_rdy) begin
        
        pkt = new();

        pkt.traffic_type = vif.cfg[0];
        pkt.payload_len  = vif.cfg[15:8];
        pkt.frag_num     = vif.cfg[20:16];
        pkt.seq_num      = vif.cfg[28:24];

        pkt.payload = new[pkt.payload_len];

        for (int i = 0; i < pkt.payload_len; i++) begin
          pkt.payload[i] = vif.data_in;
          @(posedge vif.clk);
        end

        // ✅ أرسل الـ packet للمقارنة
        act_mb.put(pkt);
        exp_mb.put(pkt);
        drop_mb.put(0);

        $display("[MON] Packet captured: seq=%0d frag=%0d len=%0d type=%0d",
                 pkt.seq_num, pkt.frag_num, pkt.payload_len, pkt.traffic_type);

      end

    end

  endtask

endclass

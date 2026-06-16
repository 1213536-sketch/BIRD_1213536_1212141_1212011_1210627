class input_monitor;

  virtual bird_if vif;
  mailbox #(bird_packet) act_mb;

  function new(virtual bird_if vif, mailbox #(bird_packet) act_mb);
    this.vif = vif;
    this.act_mb = act_mb;
  endfunction

  task run();

    bird_packet pkt;

    forever begin

      @(posedge vif.clk);

      if (vif.in_vld && vif.in_rdy) begin
$display("CFG=%h seq=%0d frag=%0d len=%0d type=%0d",
         vif.cfg,
         vif.cfg[28:24],
         vif.cfg[20:16],
         vif.cfg[15:8],
         vif.cfg[0]);
        pkt = new();

        // -------------------------
        // FIX: decode cfg correctly
        // -------------------------
        pkt.traffic_type = vif.cfg[0];
        pkt.payload_len  = vif.cfg[15:8];
        pkt.frag_num     = vif.cfg[20:16];
        pkt.seq_num      = vif.cfg[28:24];

        pkt.payload = new[pkt.payload_len];

        // -------------------------
        // FIX: collect ALL bytes
        // -------------------------
        for (int i = 0; i < pkt.payload_len; i++) begin
          pkt.payload[i] = vif.data_in;
          @(posedge vif.clk);
        end

        // skip CRC bytes (2 cycles)
        @(posedge vif.clk);
        @(posedge vif.clk);

        pkt.crc[0] = 0;
        pkt.crc[1] = 0;

        act_mb.put(pkt);

        $display("[MON] Packet captured correctly");

      end

    end

  endtask

endclass
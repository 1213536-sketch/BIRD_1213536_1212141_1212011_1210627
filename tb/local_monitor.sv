class local_monitor;

  virtual bird_if vif;
  mailbox #(bird_packet) mon2sb;

  function new(virtual bird_if vif, mailbox #(bird_packet) mon2sb);
    this.vif = vif;
    this.mon2sb = mon2sb;
  endfunction

  task run();

    bird_packet pkt;

    forever begin

      @(posedge vif.clk);

      if (vif.local_vld && vif.local_rdy) begin

        pkt = new();

        pkt.payload_len = 1;
        pkt.payload = new[1];

        pkt.payload[0] = vif.data_local;

        pkt.crc[0] = 0;
        pkt.crc[1] = 0;

        mon2sb.put(pkt);

        $display("[LOCAL MON] Data captured");

      end

    end

  endtask

endclass
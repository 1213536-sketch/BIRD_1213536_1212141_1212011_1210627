class remote_monitor;

  virtual bird_if vif;
  mailbox #(bird_packet) mon2sb;

  function new(virtual bird_if vif, mailbox #(bird_packet) mon2sb);
    this.vif = vif;
    this.mon2sb = mon2sb;
  endfunction

  task run();

    bird_packet pkt;
    int idx;

    idx = 0;
    pkt = null;

    forever begin

      @(posedge vif.clk);

      if (vif.remote_vld && vif.remote_rdy) begin

$display("[REMOTE] data_remote=%h", vif.data_remote);
        if (idx == 0) begin
          pkt = new();

          pkt.seq_num      = vif.data_remote[28:24];
          pkt.frag_num     = vif.data_remote[20:16];
          pkt.payload_len  = vif.data_remote[15:8];
          pkt.traffic_type = vif.data_remote[0];

          pkt.payload = new[pkt.payload_len];
        end

        pkt.payload[idx] = vif.data_remote[7:0];
        idx++;

        if (idx == pkt.payload_len) begin
          pkt.crc[0] = 0;
          pkt.crc[1] = 0;

          mon2sb.put(pkt);

          $display("[REMOTE MON] Packet Done");

          idx = 0;
          pkt = null;
        end

      end

    end

  endtask

endclass
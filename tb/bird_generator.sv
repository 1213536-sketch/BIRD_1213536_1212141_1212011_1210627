import bird_pkg::*;

class bird_generator;

  mailbox #(bird_packet) gen_mb;

  function new(mailbox #(bird_packet) gen_mb);
    this.gen_mb = gen_mb;
  endfunction

  task run();

    bird_packet pkt;

    // ============================================
    // TEST 1: 5 Local Packets (seq=1, frag=1)
    // ============================================
    repeat (5) begin
      pkt = new();
      pkt.traffic_type = 0; // LOCAL
      pkt.seq_num  = 1;
      pkt.frag_num = 1;
      pkt.payload_len = 24;
      pkt.payload = new[24];
      for (int i = 0; i < 24; i++) begin
        pkt.payload[i] = i[7:0];
      end
      pkt.crc[0] = 0;
      pkt.crc[1] = 0;
      gen_mb.put(pkt);
      $display("[GEN] Sent LOCAL packet seq=%0d frag=%0d len=%0d",
               pkt.seq_num, pkt.frag_num, pkt.payload_len);
    end

    // ============================================
    // TEST 2: Remote Packet (3 Fragments)
    // ============================================
    $display("\n[GEN] Sending REMOTE packet (3 fragments) ...");

    // Fragment 1 (FRAG_NUM=1, SEQ_NUM=2)
    pkt = new();
    pkt.traffic_type = 1; // REMOTE
    pkt.seq_num  = 2;
    pkt.frag_num = 1;
    pkt.payload_len = 8;
    pkt.payload = new[8];
    for (int i = 0; i < 8; i++) begin
      pkt.payload[i] = i + 100;
    end
    pkt.crc[0] = 0;
    pkt.crc[1] = 0;
    gen_mb.put(pkt);
    $display("[GEN] Sent REMOTE frag[%0d]: seq=%0d len=%0d", pkt.frag_num, pkt.seq_num, pkt.payload_len);

    // Fragment 2 (FRAG_NUM=2, SEQ_NUM=2)
    pkt = new();
    pkt.traffic_type = 1; // REMOTE
    pkt.seq_num  = 2;
    pkt.frag_num = 2;
    pkt.payload_len = 8;
    pkt.payload = new[8];
    for (int i = 0; i < 8; i++) begin
      pkt.payload[i] = i + 200;
    end
    pkt.crc[0] = 0;
    pkt.crc[1] = 0;
    gen_mb.put(pkt);
    $display("[GEN] Sent REMOTE frag[%0d]: seq=%0d len=%0d", pkt.frag_num, pkt.seq_num, pkt.payload_len);

    // Fragment 3 (FRAG_NUM=3, SEQ_NUM=2)
    pkt = new();
    pkt.traffic_type = 1; // REMOTE
    pkt.seq_num  = 2;
    pkt.frag_num = 3;
    pkt.payload_len = 8;
    pkt.payload = new[8];
    for (int i = 0; i < 8; i++) begin
      pkt.payload[i] = i + 300;
    end
    pkt.crc[0] = 0;
    pkt.crc[1] = 0;
    gen_mb.put(pkt);
    $display("[GEN] Sent REMOTE frag[%0d]: seq=%0d len=%0d", pkt.frag_num, pkt.seq_num, pkt.payload_len);

    // ============================================
    // TEST 3: Out-of-Order Remote Fragments
    // ============================================
    $display("\n[GEN] Sending REMOTE packet (out-of-order fragments) ...");

    // Fragment 1 (FRAG_NUM=3, SEQ_NUM=3) → يصل أولاً
    pkt = new();
    pkt.traffic_type = 1; // REMOTE
    pkt.seq_num  = 3;
    pkt.frag_num = 3;
    pkt.payload_len = 8;
    pkt.payload = new[8];
    for (int i = 0; i < 8; i++) begin
      pkt.payload[i] = i + 400;
    end
    pkt.crc[0] = 0;
    pkt.crc[1] = 0;
    gen_mb.put(pkt);
    $display("[GEN] Sent REMOTE frag[%0d]: seq=%0d len=%0d (out-of-order)", pkt.frag_num, pkt.seq_num, pkt.payload_len);

    // Fragment 2 (FRAG_NUM=1, SEQ_NUM=3)
    pkt = new();
    pkt.traffic_type = 1; // REMOTE
    pkt.seq_num  = 3;
    pkt.frag_num = 1;
    pkt.payload_len = 8;
    pkt.payload = new[8];
    for (int i = 0; i < 8; i++) begin
      pkt.payload[i] = i + 500;
    end
    pkt.crc[0] = 0;
    pkt.crc[1] = 0;
    gen_mb.put(pkt);
    $display("[GEN] Sent REMOTE frag[%0d]: seq=%0d len=%0d", pkt.frag_num, pkt.seq_num, pkt.payload_len);

    // Fragment 3 (FRAG_NUM=2, SEQ_NUM=3)
    pkt = new();
    pkt.traffic_type = 1; // REMOTE
    pkt.seq_num  = 3;
    pkt.frag_num = 2;
    pkt.payload_len = 8;
    pkt.payload = new[8];
    for (int i = 0; i < 8; i++) begin
      pkt.payload[i] = i + 600;
    end
    pkt.crc[0] = 0;
    pkt.crc[1] = 0;
    gen_mb.put(pkt);
    $display("[GEN] Sent REMOTE frag[%0d]: seq=%0d len=%0d", pkt.frag_num, pkt.seq_num, pkt.payload_len);

    $display("[GEN] All packets sent.\n");

  endtask

endclass

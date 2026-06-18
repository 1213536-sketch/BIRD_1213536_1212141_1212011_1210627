import bird_pkg::*;

class bird_generator;

  mailbox #(bird_packet) gen_mb;

  // ============================================
  // Constructor
  // ============================================
  function new(mailbox #(bird_packet) gen_mb);
    this.gen_mb = gen_mb;
  endfunction

  // ============================================
  // Helper: Send packet with display
  // ============================================
  task send_packet(bird_packet pkt, string desc = "");
    gen_mb.put(pkt);
    if (desc != "")
      $display("[GEN] %s", desc);
    else
      $display("[GEN] Sent packet: type=%0d seq=%0d frag=%0d len=%0d",
               pkt.traffic_type, pkt.seq_num, pkt.frag_num, pkt.payload_len);
  endtask

  // ============================================
  // Run: Generate All Test Packets
  // ============================================
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
    // TEST 2: Remote Packet (3 Fragments - In-Order)
    // ============================================
    $display("\n[GEN] Sending REMOTE packet (3 fragments - IN-ORDER) ...");

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

    // ============================================
    // TEST 4: Drop Conditions (Invalid Packets)
    // ============================================
    $display("\n[GEN] Sending DROP test packets...");

    // 4a: SEQ_NUM = 0 (غير صحيح)
    pkt = new();
    pkt.traffic_type = 1; // REMOTE
    pkt.seq_num  = 0;     // ❌ غير صحيح
    pkt.frag_num = 1;
    pkt.payload_len = 3;
    pkt.payload = '{8'hAA, 8'hBB, 8'hCC};
    pkt.crc[0] = 0;
    pkt.crc[1] = 0;
    gen_mb.put(pkt);
    $display("[GEN] Sent INVALID: SEQ_NUM=0 (should DROP)");

    // 4b: FRAG_NUM = 0 (غير صحيح)
    pkt = new();
    pkt.traffic_type = 1; // REMOTE
    pkt.seq_num  = 5;
    pkt.frag_num = 0;     // ❌ غير صحيح
    pkt.payload_len = 3;
    pkt.payload = '{8'hDD, 8'hEE, 8'hFF};
    pkt.crc[0] = 0;
    pkt.crc[1] = 0;
    gen_mb.put(pkt);
    $display("[GEN] Sent INVALID: FRAG_NUM=0 (should DROP)");

    // 4c: PAYLOAD_LEN = 0 (غير صحيح، النطاق 1-255)
    pkt = new();
    pkt.traffic_type = 1; // REMOTE
    pkt.seq_num  = 6;
    pkt.frag_num = 1;
    pkt.payload_len = 0;  // ❌ غير صحيح
    pkt.payload = new[0];
    pkt.crc[0] = 0;
    pkt.crc[1] = 0;
    gen_mb.put(pkt);
    $display("[GEN] Sent INVALID: PAYLOAD_LEN=0 (should DROP)");

    // 4d: PAYLOAD_LEN = 300 (غير صحيح، أعلى من 255)
    pkt = new();
    pkt.traffic_type = 1; // REMOTE
    pkt.seq_num  = 7;
    pkt.frag_num = 1;
    pkt.payload_len = 300; // ❌ غير صحيح
    pkt.payload = new[300];
    for (int i = 0; i < 300; i++) begin
      pkt.payload[i] = i[7:0];
    end
    pkt.crc[0] = 0;
    pkt.crc[1] = 0;
    gen_mb.put(pkt);
    $display("[GEN] Sent INVALID: PAYLOAD_LEN=300 (should DROP)");

    // 4e: Reserved bits غير صفرية (نحتاج تعديل في bird_pkg.sv)
    // هذه الحالة تحتاج تعديل في bird_pkg.sv لإضافة reserved bits
    // سنضيفها لاحقاً بعد تعديل class bird_packet

    // ============================================
    // TEST 5: Mismatched SEQ_NUM (Drop)
    // ============================================
    $display("\n[GEN] Sending MISMATCHED SEQ_NUM test...");

    // أرسل fragment 1 من حزمة seq=10
    pkt = new();
    pkt.traffic_type = 1; // REMOTE
    pkt.seq_num  = 10;
    pkt.frag_num = 1;
    pkt.payload_len = 4;
    pkt.payload = '{8'h11, 8'h22, 8'h33, 8'h44};
    pkt.crc[0] = 0;
    pkt.crc[1] = 0;
    gen_mb.put(pkt);
    $display("[GEN] Sent REMOTE frag[%0d]: seq=%0d (starting packet)", pkt.frag_num, pkt.seq_num);

    // أرسل fragment 2 بنفس SEQ_NUM=10 (صحيح)
    pkt = new();
    pkt.traffic_type = 1; // REMOTE
    pkt.seq_num  = 10;
    pkt.frag_num = 2;
    pkt.payload_len = 4;
    pkt.payload = '{8'h55, 8'h66, 8'h77, 8'h88};
    pkt.crc[0] = 0;
    pkt.crc[1] = 0;
    gen_mb.put(pkt);
    $display("[GEN] Sent REMOTE frag[%0d]: seq=%0d (same packet)", pkt.frag_num, pkt.seq_num);

    // أرسل fragment 1 ب SEQ_NUM مختلف (11) → يجب أن يسبب Drop
    pkt = new();
    pkt.traffic_type = 1; // REMOTE
    pkt.seq_num  = 11;    // ❌ مختلف عن seq=10 الجاري
    pkt.frag_num = 1;
    pkt.payload_len = 4;
    pkt.payload = '{8'h99, 8'hAA, 8'hBB, 8'hCC};
    pkt.crc[0] = 0;
    pkt.crc[1] = 0;
    gen_mb.put(pkt);
    $display("[GEN] Sent INVALID: MISMATCHED SEQ_NUM=11 (should DROP)");

    // ============================================
    // TEST 6: Missing Fragment (Drop)
    // ============================================
    $display("\n[GEN] Sending MISSING FRAGMENT test...");

    // أرسل fragment 1 من حزمة seq=20
    pkt = new();
    pkt.traffic_type = 1; // REMOTE
    pkt.seq_num  = 20;
    pkt.frag_num = 1;
    pkt.payload_len = 4;
    pkt.payload = '{8'h11, 8'h22, 8'h33, 8'h44};
    pkt.crc[0] = 0;
    pkt.crc[1] = 0;
    gen_mb.put(pkt);
    $display("[GEN] Sent REMOTE frag[%0d]: seq=%0d", pkt.frag_num, pkt.seq_num);

    // أرسل fragment 3 (تخطي fragment 2) → يجب أن يسبب Drop
    pkt = new();
    pkt.traffic_type = 1; // REMOTE
    pkt.seq_num  = 20;
    pkt.frag_num = 3;     // ❌ ناقص fragment 2
    pkt.payload_len = 4;
    pkt.payload = '{8'h55, 8'h66, 8'h77, 8'h88};
    pkt.crc[0] = 0;
    pkt.crc[1] = 0;
    gen_mb.put(pkt);
    $display("[GEN] Sent REMOTE frag[%0d]: seq=%0d (fragment 2 is MISSING!)", pkt.frag_num, pkt.seq_num);

    // ============================================
    // TEST 7: Reset Test
    // ============================================
    $display("\n[GEN] Sending RESET test packet...");

    pkt = new();
    pkt.traffic_type = 0; // LOCAL
    pkt.seq_num  = 1;
    pkt.frag_num = 1;
    pkt.payload_len = 3;
    pkt.payload = '{8'hAA, 8'hBB, 8'hCC};
    pkt.crc[0] = 0;
    pkt.crc[1] = 0;
    gen_mb.put(pkt);
    $display("[GEN] Sent LOCAL packet (for reset test)");

    // ============================================
    // TEST 8: Remote Packet with Maximum Values
    // ============================================
    $display("\n[GEN] Sending REMOTE packet with MAX values...");

    // Fragment 1: SEQ_NUM=31, FRAG_NUM=1, PAYLOAD_LEN=255
    pkt = new();
    pkt.traffic_type = 1; // REMOTE
    pkt.seq_num  = 31;    // الحد الأقصى
    pkt.frag_num = 1;
    pkt.payload_len = 255; // الحد الأقصى
    pkt.payload = new[255];
    for (int i = 0; i < 255; i++) begin
      pkt.payload[i] = i[7:0];
    end
    pkt.crc[0] = 0;
    pkt.crc[1] = 0;
    gen_mb.put(pkt);
    $display("[GEN] Sent REMOTE frag[%0d]: seq=%0d len=%0d (MAX values)", 
             pkt.frag_num, pkt.seq_num, pkt.payload_len);

    // Fragment 2: SEQ_NUM=31, FRAG_NUM=2
    pkt = new();
    pkt.traffic_type = 1; // REMOTE
    pkt.seq_num  = 31;
    pkt.frag_num = 2;
    pkt.payload_len = 255;
    pkt.payload = new[255];
    for (int i = 0; i < 255; i++) begin
      pkt.payload[i] = i[7:0] + 100;
    end
    pkt.crc[0] = 0;
    pkt.crc[1] = 0;
    gen_mb.put(pkt);
    $display("[GEN] Sent REMOTE frag[%0d]: seq=%0d len=%0d (MAX values)", 
             pkt.frag_num, pkt.seq_num, pkt.payload_len);

    // ============================================
    // FINISHED
    // ============================================
    $display("\n[GEN] ========================================");
    $display("[GEN] ALL PACKETS SENT!");
    $display("[GEN] Total packets: 22");
    $display("[GEN] ========================================\n");

  endtask

endclass

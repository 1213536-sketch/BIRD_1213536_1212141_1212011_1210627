import bird_pkg::*;

class bird_scoreboard;

  // =============================================
  // Mailboxes
  // =============================================
  mailbox #(bird_packet) act_mb;
  mailbox #(bird_packet) exp_mb;
  mailbox #(bit) drop_mb;

  // =============================================
  // Reference Model
  // =============================================
  bird_ref_model ref_model;

  // =============================================
  // Scoreboard Counters
  // =============================================
  int pass = 0;
  int fail = 0;
  int drop_count = 0;

  // =============================================
  // Virtual Interface (لـ Functional Coverage)
  // =============================================
  virtual bird_if vif;

  // =============================================
  // متغيرات للمساعدة في التغطية
  // =============================================
  bit drop_detected;

  // =============================================
  // Functional Coverage Group
  // =============================================
  covergroup bird_cov @(posedge vif.clk);
    
    // 1. تغطية نوع الحركة (Local / Remote)
    traffic_type_cp: coverpoint vif.cfg[0] {
      bins local_pkt  = {0};   // ✅ changed from 'local' to 'local_pkt'
      bins remote_pkt = {1};
    }
    
    // 2. تغطية SEQ_NUM (1-31 صحيح، 0 غير صحيح)
    seq_num_cp: coverpoint vif.cfg[28:24] {
      bins valid[]   = {[1:31]};
      bins invalid   = {0};
      bins all       = {[0:31]};
    }
    
    // 3. تغطية FRAG_NUM (1-31 صحيح، 0 غير صحيح)
    frag_num_cp: coverpoint vif.cfg[20:16] {
      bins valid[]   = {[1:31]};
      bins invalid   = {0};
      bins all       = {[0:31]};
    }
    
    // 4. تغطية PAYLOAD_LEN (1-255 صحيح، 0 و 256+ غير صحيح)
    payload_len_cp: coverpoint vif.cfg[15:8] {
      bins valid[]   = {[1:255]};
      bins zero      = {0};
      bins overflow  = {[256:$]};
    }
    
    // 5. تغطية Reserved Bits (كلها صفر أو غير صفر)
    reserved1_cp: coverpoint vif.cfg[7:1] {
      bins all_zero = {0};
      bins non_zero = {[1:$]};
    }
    reserved2_cp: coverpoint vif.cfg[23:21] {
      bins all_zero = {0};
      bins non_zero = {[1:$]};
    }
    reserved3_cp: coverpoint vif.cfg[31:29] {
      bins all_zero = {0};
      bins non_zero = {[1:$]};
    }
    
    // 6. تغطية Cross Product (ترافيك × SEQ_NUM)
    traffic_seq_cross: cross traffic_type_cp, seq_num_cp;
    
    // 7. تغطية حالة Drop
    drop_cp: coverpoint drop_detected {
      bins dropped = {1};
      bins success = {0};
    }
    
  endgroup

  // =============================================
  // Constructor
  // =============================================
  function new(mailbox #(bird_packet) act_mb,
               mailbox #(bird_packet) exp_mb,
               mailbox #(bit) drop_mb,
               virtual bird_if vif);

    this.act_mb = act_mb;
    this.exp_mb = exp_mb;
    this.drop_mb = drop_mb;
    this.vif = vif;

    ref_model = new();

    // إنشاء Covergroup
    bird_cov = new();

  endfunction

  // =============================================
  // Compare Function
  // =============================================
  function bit compare(bird_packet a, bird_packet b);

    // مقارنة الحقول الأساسية
    if (a.seq_num != b.seq_num) begin
      $display("[SCOREBOARD] Mismatch: seq_num act=%0d exp=%0d", a.seq_num, b.seq_num);
      return 0;
    end
    
    if (a.frag_num != b.frag_num) begin
      $display("[SCOREBOARD] Mismatch: frag_num act=%0d exp=%0d", a.frag_num, b.frag_num);
      return 0;
    end
    
    if (a.payload_len != b.payload_len) begin
      $display("[SCOREBOARD] Mismatch: payload_len act=%0d exp=%0d", a.payload_len, b.payload_len);
      return 0;
    end

    // مقارنة الـ payload
    foreach (a.payload[i]) begin
      if (a.payload[i] != b.payload[i]) begin
        $display("[SCOREBOARD] Mismatch at payload[%0d]: act=%0h exp=%0h", 
                 i, a.payload[i], b.payload[i]);
        return 0;
      end
    end

    return 1;

  endfunction

  // =============================================
  // Run Task
  // =============================================
  task run();

    bird_packet act, exp;
    bit drop;

    forever begin

      $display("[SCOREBOARD] Waiting for packets...");
      act_mb.get(act);
      $display("[SCOREBOARD] Received act packet");
      
      $display("[SCOREBOARD] Waiting for exp packet...");
      exp_mb.get(exp);
      $display("[SCOREBOARD] Received exp packet");
      
      $display("[SCOREBOARD] Waiting for drop...");
      drop_mb.get(drop);
      $display("[SCOREBOARD] Received drop = %0d", drop);

      // تخزين حالة drop للتغطية
      drop_detected = drop;

      if (drop) begin
        drop_count++;
        $display("[SCOREBOARD] Packet dropped (drop_count=%0d)", drop_count);
        continue;
      end

      // المعالجة عبر Reference Model
      exp = ref_model.process(act);

      $display("[SCOREBOARD] act.seq_num=%0d exp.seq_num=%0d", act.seq_num, exp.seq_num);
      $display("[SCOREBOARD] act.frag_num=%0d exp.frag_num=%0d", act.frag_num, exp.frag_num);
      $display("[SCOREBOARD] act.payload_len=%0d exp.payload_len=%0d", act.payload_len, exp.payload_len);
      
      if (act.payload.size() > 0) begin
        $display("[SCOREBOARD] act.payload[0]=%0h exp.payload[0]=%0h", act.payload[0], exp.payload[0]);
      end
      if (act.payload.size() > 1) begin
        $display("[SCOREBOARD] act.payload[1]=%0h exp.payload[1]=%0h", act.payload[1], exp.payload[1]);
      end

      $display("[SCOREBOARD] Comparing act and exp...");
      
      if (compare(act, exp)) begin
        pass++;
        $display("✅ PASS");
      end else begin
        fail++;
        $display("❌ FAIL");
      end

      $display("PASS=%0d FAIL=%0d", pass, fail);

    end

  endtask

  // =============================================
  // Report Function
  // =============================================
  function void report();
    $display("\n==========================================");
    $display("SCOREBOARD FINAL RESULTS");
    $display("==========================================");
    $display("PASS     = %0d", pass);
    $display("FAIL     = %0d", fail);
    $display("DROPPED  = %0d", drop_count);
    $display("------------------------------------------");
    $display("Functional Coverage Report:");
    $display("  - traffic_type_cp  : %0d%%", bird_cov.traffic_type_cp.get_coverage());
    $display("  - seq_num_cp       : %0d%%", bird_cov.seq_num_cp.get_coverage());
    $display("  - frag_num_cp      : %0d%%", bird_cov.frag_num_cp.get_coverage());
    $display("  - payload_len_cp   : %0d%%", bird_cov.payload_len_cp.get_coverage());
    $display("  - reserved1_cp     : %0d%%", bird_cov.reserved1_cp.get_coverage());
    $display("  - reserved2_cp     : %0d%%", bird_cov.reserved2_cp.get_coverage());
    $display("  - reserved3_cp     : %0d%%", bird_cov.reserved3_cp.get_coverage());
    $display("  - traffic_seq_cross: %0d%%", bird_cov.traffic_seq_cross.get_coverage());
    $display("  - Overall Coverage : %0d%%", bird_cov.get_coverage());
    $display("==========================================");
    
    if (fail == 0) begin
      $display("✅ ALL TESTS PASSED!");
    end else begin
      $display("❌ SOME TESTS FAILED!");
    end
    $display("==========================================\n");
  endfunction

endclass

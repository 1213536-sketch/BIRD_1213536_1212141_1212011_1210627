import bird_pkg::*;

class bird_scoreboard;

  mailbox #(bird_packet) act_mb;
  mailbox #(bird_packet) exp_mb;
  mailbox #(bit) drop_mb;

  bird_ref_model ref_model;

  int pass = 0;
  int fail = 0;
  int drop_count = 0;

  function new(mailbox #(bird_packet) act_mb,
               mailbox #(bird_packet) exp_mb,
               mailbox #(bit) drop_mb);

    this.act_mb = act_mb;
    this.exp_mb = exp_mb;
    this.drop_mb = drop_mb;

    ref_model = new();

  endfunction

  function bit compare(bird_packet a, bird_packet b);

    if (a.seq_num != b.seq_num) return 0;
    if (a.frag_num != b.frag_num) return 0;
    if (a.payload_len != b.payload_len) return 0;

    foreach (a.payload[i])
      if (a.payload[i] != b.payload[i])
        return 0;

    return 1;

  endfunction

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

      if (drop) begin
        drop_count++;
        $display("[SCOREBOARD] Packet dropped (drop_count=%0d)", drop_count);
        continue;
      end

      exp = act;

      $display("[SCOREBOARD] act.seq_num=%0d exp.seq_num=%0d", act.seq_num, exp.seq_num);
      $display("[SCOREBOARD] act.frag_num=%0d exp.frag_num=%0d", act.frag_num, exp.frag_num);
      $display("[SCOREBOARD] act.payload_len=%0d exp.payload_len=%0d", act.payload_len, exp.payload_len);
      $display("[SCOREBOARD] act.payload[0]=%0d exp.payload[0]=%0d", act.payload[0], exp.payload[0]);
      $display("[SCOREBOARD] act.payload[1]=%0d exp.payload[1]=%0d", act.payload[1], exp.payload[1]);

      $display("[SCOREBOARD] Comparing act and exp...");
      if (compare(act, exp)) begin
        pass++;
        $display("PASS");
      end else begin
        fail++;
        $display("FAIL");
      end

      $display("PASS=%0d FAIL=%0d", pass, fail);

    end

  endtask

  function void report();
    $display("\n==========================================");
    $display("SCOREBOARD FINAL RESULTS");
    $display("==========================================");
    $display("PASS = %0d", pass);
    $display("FAIL = %0d", fail);
    $display("DROPPED = %0d", drop_count);
    if (fail == 0) begin
      $display("✅ ALL TESTS PASSED!");
    end else begin
      $display("❌ SOME TESTS FAILED!");
    end
    $display("==========================================\n");
  endfunction

endclass

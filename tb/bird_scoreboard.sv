class bird_scoreboard;

  mailbox #(bird_packet) exp_mb;
  mailbox #(bird_packet) act_mb;

  int pass_count = 0;
  int fail_count = 0;

  function new(
    mailbox #(bird_packet) exp_mb,
    mailbox #(bird_packet) act_mb
  );

    this.exp_mb = exp_mb;
    this.act_mb = act_mb;

  endfunction

  // -----------------------------
  // Compare two packets
  // -----------------------------
  function bit compare_packets(bird_packet exp, bird_packet act);

    if (exp.payload_len != act.payload_len)
      return 0;

    if (exp.seq_num != act.seq_num)
      return 0;

    if (exp.frag_num != act.frag_num)
      return 0;

    if (exp.traffic_type != act.traffic_type)
      return 0;

    for (int i = 0; i < exp.payload_len; i++) begin
      if (exp.payload[i] != act.payload[i])
        return 0;
    end

    if (exp.crc[0] != act.crc[0])
      return 0;

    if (exp.crc[1] != act.crc[1])
      return 0;

    return 1;

  endfunction

  // -----------------------------
  // MAIN LOOP
  // -----------------------------
  task run();

    bird_packet exp_pkt;
    bird_packet act_pkt;

    forever begin

      exp_mb.get(exp_pkt);
      act_mb.get(act_pkt);

      if (compare_packets(exp_pkt, act_pkt)) begin

        pass_count++;
        $display("[SCOREBOARD] PASS");

      end else begin

        fail_count++;
        $display("[SCOREBOARD] FAIL");
        $display("EXPECTED:");
        exp_pkt.display();

        $display("ACTUAL:");
        act_pkt.display();

      end

    end

  endtask

  // -----------------------------
  // REPORT
  // -----------------------------
function void report();

  $display("================================");
  $display("SCOREBOARD SUMMARY");
  $display("PASS = %0d", pass_count);
  $display("FAIL = %0d", fail_count);

  if (fail_count == 0)
    $display("TEST STATUS = PASS");
  else
    $display("TEST STATUS = FAIL");
  
  $display("================================");

endfunction

endclass

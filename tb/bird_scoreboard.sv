import bird_pkg::*;

class bird_scoreboard;

  mailbox #(bird_packet) act_mb;
  mailbox #(bird_packet) exp_mb;

  bird_ref_model ref_model;

  int pass = 0;
  int fail = 0;

  function new(mailbox #(bird_packet) act_mb,
               mailbox #(bird_packet) exp_mb);

    this.act_mb = act_mb;
    this.exp_mb = exp_mb;

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

    bird_packet act, in, exp;

    forever begin

      act_mb.get(act);
      exp_mb.get(in);

      exp = ref_model.process(in);

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

endclass
import bird_pkg::*;

class bird_env;

  mailbox #(bird_packet) gen_mb;
  mailbox #(bird_packet) act_mb;
  mailbox #(bird_packet) exp_mb;

  bird_driver     drv;
  bird_generator  gen;
  bird_scoreboard sb;
  input_monitor   mon;

  bird_ref_model  rm;   // ✅ FIX: لازم تعريف ref

  virtual bird_if vif;

  function new(virtual bird_if vif);

    this.vif = vif;

    gen_mb = new();
    act_mb = new();
    exp_mb = new();

    gen = new(gen_mb);
    drv = new(vif, gen_mb);

    mon = new(vif, act_mb);

    sb  = new(act_mb, exp_mb);

    rm = new();   // ✅ FIX: create reference model

  endfunction

  task run();

    bird_packet pkt;
    bird_packet exp_pkt;

    fork

      // -------------------------
      // Generator
      // -------------------------
      begin
        gen.run();
      end

      // -------------------------
      // Driver
      // -------------------------
      begin
        drv.run();
      end

      // -------------------------
      // Monitor (ACTUAL from DUT)
      // -------------------------
      begin
        mon.run();
      end

      // -------------------------
      // EXPECTED path (REF MODEL)
      // -------------------------
      begin
        forever begin
          gen_mb.get(pkt);
          exp_pkt = rm.process(pkt);
          exp_mb.put(exp_pkt);
        end
      end

      // -------------------------
      // SCOREBOARD
      // -------------------------
      begin
        sb.run();
      end

    join_none

  endtask

endclass
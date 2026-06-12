class bird_env;

  virtual bird_if vif;

  bird_driver        drv;
  input_monitor      in_mon;
  remote_monitor     rem_mon;
  bird_scoreboard    sb;

  mailbox #(bird_packet) in_mb;
  mailbox #(bird_packet) rem_mb;

  function new(virtual bird_if vif);
    this.vif = vif;

    in_mb  = new();
    rem_mb = new();

    drv     = new(vif);
    in_mon  = new(vif, in_mb);
    rem_mon = new(vif, rem_mb);

    sb = new(in_mb, rem_mb);

  endfunction

  task run();

    fork
      drv.run();      // if you later wrap driver loop
      in_mon.run();
      rem_mon.run();
      sb.run();
    join_none

  endtask

endclass
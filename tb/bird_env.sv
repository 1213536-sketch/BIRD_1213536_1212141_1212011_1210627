import bird_pkg::*;

class bird_env;

  virtual bird_if vif;

  bird_driver driver;
  bird_generator generator;
  input_monitor mon_in;
  local_monitor mon_local;
  remote_monitor mon_remote;
  bird_scoreboard sb;

  mailbox #(bird_packet) gen_mb;
  mailbox #(bird_packet) act_mb;
  mailbox #(bird_packet) exp_mb;
  mailbox #(bird_packet) local_mb;
  mailbox #(bird_packet) remote_mb;
  mailbox #(bit) drop_mb;

  function new(virtual bird_if vif);
    this.vif = vif;

    gen_mb = new();
    act_mb = new();
    exp_mb = new();
    local_mb = new();
    remote_mb = new();
    drop_mb = new();

    driver = new(vif, gen_mb);
    generator = new(gen_mb);
    mon_in = new(vif, act_mb, exp_mb, drop_mb);
    mon_local = new(vif, local_mb, exp_mb);
    mon_remote = new(vif, remote_mb, exp_mb);
    sb = new(act_mb, exp_mb, drop_mb);

  endfunction

  task run();
    fork
      driver.run();
      generator.run();
      mon_in.run();
      mon_local.run();
      mon_remote.run();
      sb.run();
    join_none
  endtask

endclass

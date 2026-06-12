class local_monitor;

  virtual bird_if vif;
  mailbox #(bird_packet) mon2sb;

  function new(
    virtual bird_if vif,
    mailbox #(bird_packet) mon2sb
  );
    this.vif    = vif;
    this.mon2sb = mon2sb;
  endfunction

endclass

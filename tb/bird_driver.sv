class bird_driver;

  virtual bird_if vif;

  function new(virtual bird_if vif);
    this.vif = vif;
  endfunction

  function logic [31:0] build_cfg(bird_packet pkt);

    logic [31:0] cfg_word;
    cfg_word = 0;

    cfg_word[0]     = pkt.traffic_type;
    cfg_word[15:8]  = pkt.payload_len;
    cfg_word[20:16] = pkt.frag_num;
    cfg_word[28:24] = pkt.seq_num;

    return cfg_word;

  endfunction

  task drive_packet(bird_packet pkt);

    logic [31:0] cfg_word;
    cfg_word = build_cfg(pkt);

    wait(vif.rst_n);

    @(posedge vif.clk);

    while (!vif.in_rdy)
      @(posedge vif.clk);

    vif.in_vld  <= 1;
    vif.cfg     <= cfg_word;
    vif.data_in <= pkt.payload[0];

    for (int i = 1; i < pkt.payload.size(); i++) begin
      @(posedge vif.clk);

      while (!vif.in_rdy)
        @(posedge vif.clk);

      vif.data_in <= pkt.payload[i];
    end

    @(posedge vif.clk);

    vif.in_vld  <= 0;
    vif.data_in <= 0;
    vif.cfg     <= 0;

  endtask

endclass

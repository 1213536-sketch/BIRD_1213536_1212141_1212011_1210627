import bird_pkg::*;

class bird_driver;

  virtual bird_if vif;
  mailbox #(bird_packet) gen_mb;

  function new(virtual bird_if vif, mailbox #(bird_packet) gen_mb);
    this.vif = vif;
    this.gen_mb = gen_mb;
  endfunction

  task run();

    bird_packet pkt;

    forever begin

      gen_mb.get(pkt);

      @(posedge vif.clk);

      vif.in_vld <= 1;
vif.cfg <= {
  3'b0,                // [31:29]
  pkt.seq_num,        // [28:24]
  3'b0,                // [23:21]
  pkt.frag_num,       // [20:16]
  pkt.payload_len,    // [15:8]
  7'b0,               // [7:1]
  pkt.traffic_type   // [0]
};
      for (int i = 0; i < pkt.payload_len; i++) begin
        vif.data_in <= pkt.payload[i];
        @(posedge vif.clk);
      end

      vif.in_vld <= 0;

    end

  endtask

endclass
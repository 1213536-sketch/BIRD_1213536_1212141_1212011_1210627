import bird_pkg::*;

class bird_generator;

  mailbox #(bird_packet) gen_mb;

  function new(mailbox #(bird_packet) gen_mb);
    this.gen_mb = gen_mb;
  endfunction

  task run();

    bird_packet pkt;

repeat (5) begin

  pkt = new();

  pkt.traffic_type = 0; // LOCAL

  pkt.seq_num  = 1;
  pkt.frag_num = 1;

  pkt.payload_len = 3;

  pkt.payload = new[pkt.payload_len];

  pkt.payload[0] = 8'hAA;
  pkt.payload[1] = 8'hBB;
  pkt.payload[2] = 8'hCC;

  gen_mb.put(pkt);

end
  endtask

endclass
import bird_pkg::*;

  class bird_ref_model;

    function automatic bit [15:0] crc16(bit [7:0] data[]);
      bit [15:0] crc;
      crc = 16'hFFFF;

      foreach (data[i]) begin
        crc ^= (data[i] << 8);
        repeat (8) begin
          if (crc[15])
            crc = (crc << 1) ^ 16'h1021;
          else
            crc = (crc << 1);
        end
      end

      return crc;
    endfunction

function bird_packet process(bird_packet pkt);

  bird_packet exp;

  exp = new();

  exp.seq_num      = pkt.seq_num;
  exp.frag_num     = pkt.frag_num;
  exp.payload_len  = pkt.payload_len;
  exp.traffic_type = pkt.traffic_type;

  exp.payload = new[pkt.payload_len];

  for (int i = 0; i < pkt.payload_len; i++)
    exp.payload[i] = pkt.payload[i];

  exp.crc[0] = 8'h00;
  exp.crc[1] = 8'h00;

  return exp;

endfunction
  endclass

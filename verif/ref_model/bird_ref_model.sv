class bird_ref_model;

  function bird_packet process(input bird_packet pkt);

    bird_packet exp = new();

    exp.traffic_type = pkt.traffic_type;
    exp.seq_num      = pkt.seq_num;
    exp.frag_num     = pkt.frag_num;
    exp.payload_len  = pkt.payload_len;

    exp.payload = new[pkt.payload_len];

    // LOCAL
    if (pkt.traffic_type == 0) begin
      for (int i = 0; i < pkt.payload_len; i++)
        exp.payload[i] = pkt.payload[i];
    end

    // REMOTE (simplified phase 1)
    else begin
      for (int i = 0; i < pkt.payload_len; i++)
        exp.payload[i] = pkt.payload[i];
    end

    exp.crc[0] = 0;
    exp.crc[1] = 0;

    return exp;

  endfunction

endclass
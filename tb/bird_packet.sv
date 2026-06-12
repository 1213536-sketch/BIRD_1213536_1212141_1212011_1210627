class bird_packet;

  // 0 = local
  // 1 = remote
  rand bit traffic_type;

  // cfg[15:8]
  rand bit [7:0] payload_len;

  // cfg[20:16]
  rand bit [4:0] frag_num;

  // cfg[28:24]
  rand bit [4:0] seq_num;

  // payload bytes
  rand byte payload[];

  // CRC bytes
  byte crc[2];
 constraint payload_size_c {
    payload.size() == payload_len;
  }

  // display packet info
  function void display();

    $display("================================");

    $display("traffic_type = %0d", traffic_type);

    $display("payload_len  = %0d", payload_len);

    $display("frag_num     = %0d", frag_num);

    $display("seq_num      = %0d", seq_num);

    $display("================================");

  endfunction

endclass
import bird_pkg::*;
class bird_packet;

  bit [7:0] payload[];
  bit [7:0] crc[1:0];

  bit [3:0] traffic_type;
  bit [7:0] payload_len;
  bit [4:0] frag_num;
  bit [4:0] seq_num;

  function new();
  endfunction

endclass


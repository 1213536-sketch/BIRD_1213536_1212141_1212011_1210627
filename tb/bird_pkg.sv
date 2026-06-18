package bird_pkg;

  // ============================================
  // Bird Packet Class
  // ============================================
  class bird_packet;
    
    // ============================================
    // Fields according to spec
    // ============================================
    bit [7:0] payload[];      // Dynamic array for payload data
    bit [7:0] crc[1:0];       // CRC16 (2 bytes)
    
    bit [3:0] traffic_type;   // cfg[0]: 0=Local, 1=Remote
    bit [7:0] payload_len;    // cfg[15:8]: 1-255
    bit [4:0] frag_num;       // cfg[20:16]: 1-31
    bit [4:0] seq_num;        // cfg[28:24]: 1-31 (0 invalid)
    
    // ============================================
    // Reserved bits (for invalid tests)
    // ============================================
    bit [6:0] reserved1;      // cfg[7:1]   must be 0
    bit [2:0] reserved2;      // cfg[23:21] must be 0
    bit [2:0] reserved3;      // cfg[31:29] must be 0
    
    // ============================================
    // Constructor
    // ============================================
    function new();
      traffic_type = 0;
      payload_len  = 0;
      frag_num     = 1;
      seq_num      = 1;
      reserved1    = 0;
      reserved2    = 0;
      reserved3    = 0;
      crc[0]       = 0;
      crc[1]       = 0;
    endfunction
    
    // ============================================
    // Get 32-bit cfg word
    // ============================================
    function bit [31:0] get_cfg();
      bit [31:0] cfg = 32'h0;
      
      cfg[0]     = traffic_type;
      cfg[15:8]  = payload_len;
      cfg[20:16] = frag_num;
      cfg[28:24] = seq_num;
      cfg[7:1]   = reserved1;
      cfg[23:21] = reserved2;
      cfg[31:29] = reserved3;
      
      return cfg;
    endfunction
    
    // ============================================
    // Check if packet is valid according to spec
    // ============================================
    function bit is_valid();
      bit valid = 1;
      
      // Check reserved bits
      if (reserved1 != 0) valid = 0;
      if (reserved2 != 0) valid = 0;
      if (reserved3 != 0) valid = 0;
      
      // Check PAYLOAD_LEN (1-255)
      if (payload_len < 1 || payload_len > 255) valid = 0;
      
      // Check based on traffic type
      if (traffic_type == 0) begin
        // LOCAL: must have SEQ_NUM==1 and FRAG_NUM==1
        if (seq_num != 1) valid = 0;
        if (frag_num != 1) valid = 0;
      end else begin
        // REMOTE: SEQ_NUM and FRAG_NUM must be non-zero
        if (seq_num == 0) valid = 0;
        if (frag_num == 0) valid = 0;
      end
      
      return valid;
    endfunction
    
    // ============================================
    // Calculate CRC16 over payload (for reference)
    // ============================================
    function bit [15:0] calc_crc();
      bit [15:0] crc_val = 16'hFFFF;
      
      for (int i = 0; i < payload.size(); i++) begin
        crc_val ^= {8'h00, payload[i]};
        for (int j = 0; j < 8; j++) begin
          if (crc_val[0])
            crc_val = (crc_val >> 1) ^ 16'h8408;
          else
            crc_val = (crc_val >> 1);
        end
      end
      
      return ~crc_val;
    endfunction
    
    // ============================================
    // Display packet info
    // ============================================
    function void display(string prefix = "");
      $display("%s Packet:", prefix);
      $display("  traffic_type = %0d (%s)", 
               traffic_type, 
               (traffic_type == 0) ? "LOCAL" : "REMOTE");
      $display("  seq_num      = %0d", seq_num);
      $display("  frag_num     = %0d", frag_num);
      $display("  payload_len  = %0d", payload_len);
      $display("  payload_size = %0d", payload.size());
      $display("  reserved1    = 0x%0h", reserved1);
      $display("  reserved2    = 0x%0h", reserved2);
      $display("  reserved3    = 0x%0h", reserved3);
      $display("  CRC          = 0x%0h%0h", crc[1], crc[0]);
      $display("  cfg          = 0x%0h", get_cfg());
      $display("  valid        = %0d", is_valid());
    endfunction
    
    // ============================================
    // Deep copy function
    // ============================================
    function bird_packet copy();
      bird_packet pkt = new();
      
      pkt.traffic_type = this.traffic_type;
      pkt.payload_len  = this.payload_len;
      pkt.frag_num     = this.frag_num;
      pkt.seq_num      = this.seq_num;
      pkt.reserved1    = this.reserved1;
      pkt.reserved2    = this.reserved2;
      pkt.reserved3    = this.reserved3;
      pkt.crc[0]       = this.crc[0];
      pkt.crc[1]       = this.crc[1];
      
      pkt.payload = new[this.payload.size()];
      for (int i = 0; i < this.payload.size(); i++) begin
        pkt.payload[i] = this.payload[i];
      end
      
      return pkt;
    endfunction
    
    // ============================================
    // Compare function
    // ============================================
    function bit compare(bird_packet pkt);
      if (this.traffic_type != pkt.traffic_type) return 0;
      if (this.payload_len != pkt.payload_len) return 0;
      if (this.frag_num != pkt.frag_num) return 0;
      if (this.seq_num != pkt.seq_num) return 0;
      if (this.payload.size() != pkt.payload.size()) return 0;
      
      for (int i = 0; i < this.payload.size(); i++) begin
        if (this.payload[i] != pkt.payload[i]) return 0;
      end
      
      return 1;
    endfunction
    
  endclass

endpackage

interface bird_if(input logic clk);

  logic rst_n;

  logic        in_vld;
  logic        in_rdy;
  logic [7:0]  data_in;
  logic [31:0] cfg;

  logic        local_vld;
  logic        local_rdy;
  logic [7:0]  data_local;

  logic        remote_vld;
  logic        remote_rdy;
  logic [31:0] data_remote;

endinterface
  
module top_tb;

  logic clk;

  always #5 clk = ~clk;

  bird_if vif(clk);

  bird_env env;

  initial begin

    clk = 0;

    // reset
    vif.rst_n = 0;
    vif.in_rdy = 1;

    #20;
    vif.rst_n = 1;

    // create environment
    env = new(vif);

    fork
      env.run();
    join_none

    // -------------------------
    // TEST CASE (هون مكان كودك)
    // -------------------------
    begin

      bird_packet pkt;

      pkt = new();

      pkt.traffic_type = 0;   // local
      pkt.payload_len  = 3;
      pkt.frag_num     = 1;
      pkt.seq_num      = 1;

      pkt.payload = new[3];
      pkt.payload = '{8'hAA, 8'hBB, 8'hCC};

      pkt.crc[0] = 8'h00;
      pkt.crc[1] = 8'h00;

      #10; // small delay

      env.drv.drive_packet(pkt);

    end

    // wait for simulation
    #200;

    $display("TEST FINISHED");
    $finish;

  end

endmodule

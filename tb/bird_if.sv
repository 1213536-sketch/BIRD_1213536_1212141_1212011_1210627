interface bird_if;

  logic clk;
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
module top_tb;

  logic clk;

  initial clk = 0;
  always #5 clk = ~clk;

  bird_if vif();

  assign vif.clk = clk;

  bird dut (
    .clk(clk),
    .rst_n(vif.rst_n),
    .in_vld(vif.in_vld),
    .in_rdy(vif.in_rdy),
    .data_in(vif.data_in),
    .cfg(vif.cfg),
    .local_vld(vif.local_vld),
    .local_rdy(vif.local_rdy),
    .data_local(vif.data_local),
    .remote_vld(vif.remote_vld),
    .remote_rdy(vif.remote_rdy),
    .data_remote(vif.data_remote)
  );

  bird_env env;

  initial begin

    vif.rst_n = 0;
    vif.local_rdy = 1;
    vif.remote_rdy = 1;

    #20 vif.rst_n = 1;

    env = new(vif);

    fork
      env.run();
    join_none

    #2000;

    env.sb.report(); 

    $display("TEST FINISHED");
    $finish;

  end

endmodule

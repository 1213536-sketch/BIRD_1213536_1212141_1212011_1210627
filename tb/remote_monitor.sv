class remote_monitor;

  virtual bird_if vif;
  mailbox #(bird_packet) mon2sb;
  mailbox #(bird_packet) exp_mb;

  function new(virtual bird_if vif, mailbox #(bird_packet) mon2sb, mailbox #(bird_packet) exp_mb);
    this.vif = vif;
    this.mon2sb = mon2sb;
    this.exp_mb = exp_mb;
  endfunction

  task run();

    bird_packet pkt;

    forever begin

      @(posedge vif.clk);

      if (vif.remote_vld && vif.remote_rdy) begin

        pkt = new();

        // اجمع البيانات من remote هنا

        mon2sb.put(pkt);
        exp_mb.put(pkt);

        $display("[REMOTE MON] Data captured");

      end

    end

  endtask

endclass

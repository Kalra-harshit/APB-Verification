`timescale 1ns/1ps
//=====================================================================
// apb_generator.sv
// Produces randomized apb_transaction items and hands them to the
// driver over a mailbox, one at a time, waiting for the driver to
// finish each transfer before generating the next.
//=====================================================================
class apb_generator;

  mailbox gen2drv;
  event   drv_done;
  int     num_transactions = 20;

  function new(mailbox gen2drv, event drv_done);
    this.gen2drv = gen2drv;
    this.drv_done = drv_done;
  endfunction

  task run();
    apb_transaction tr;
    for (int i = 0; i < num_transactions; i++) begin
      tr = new();
      if (!tr.randomize())
        $fatal(1, "[GENERATOR] Randomization failed for transaction %0d", i);
      gen2drv.put(tr);
      @(drv_done);
    end
    $display("[GENERATOR] Done generating %0d transactions", num_transactions);
  endtask

endclass : apb_generator
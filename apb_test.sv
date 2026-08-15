`timescale 1ns/1ps
//=====================================================================
// apb_test.sv
// Top-level test: instantiates the environment and kicks it off.
//=====================================================================
class apb_test;

  apb_environment env;

  function new(virtual apb_if.DRIVER drv_vif, virtual apb_if.MONITOR mon_vif,
               int num_transactions = 20);
    env = new(drv_vif, mon_vif, num_transactions);
  endfunction

  task run();
    $display("[TEST] Starting APB test with %0d transactions", env.gen.num_transactions);
    env.run();
    $display("[TEST] Test complete");
  endtask

endclass : apb_test
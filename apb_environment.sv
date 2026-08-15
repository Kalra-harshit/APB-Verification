`timescale 1ns/1ps
//=====================================================================
// apb_environment.sv
// Wires generator -> driver -> DUT -> monitor -> scoreboard together
// and runs them concurrently.
//=====================================================================
class apb_environment;

  apb_generator  gen;
  apb_driver     drv;
  apb_monitor    mon;
  apb_scoreboard scb;
  apb_coverage   cov;

  mailbox gen2drv;
  mailbox mon2scb;
  mailbox mon2cov;
  event   drv_done;

  function new(virtual apb_if.DRIVER drv_vif, virtual apb_if.MONITOR mon_vif,
               int num_transactions = 20);
    gen2drv = new();
    mon2scb = new();
    mon2cov = new();

    gen = new(gen2drv, drv_done);
    gen.num_transactions = num_transactions;
    drv = new(drv_vif, gen2drv, drv_done);
    mon = new(mon_vif, mon2scb, mon2cov);
    scb = new(mon2scb);
    cov = new(mon2cov);
  endfunction

  task run();
    fork
      gen.run();
      drv.run();
      mon.run();
      scb.run();
      cov.run();
    join_any

    // Let the last transaction drain through monitor/scoreboard/coverage
    #50;
    scb.report();
    cov.report();
  endtask

endclass : apb_environment
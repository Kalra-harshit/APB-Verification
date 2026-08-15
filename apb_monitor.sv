`timescale 1ns/1ps
//=====================================================================
// apb_monitor.sv
// Passively watches the bus. Captures a transaction whenever PSEL and
// PENABLE are both high AND PREADY is high on the same edge (i.e. the
// exact cycle a transfer completes), and forwards it to the scoreboard.
//=====================================================================
class apb_monitor;

  virtual apb_if.MONITOR vif;
  mailbox mon2scb;
  mailbox mon2cov;

  function new(virtual apb_if.MONITOR vif, mailbox mon2scb, mailbox mon2cov);
    this.vif     = vif;
    this.mon2scb = mon2scb;
    this.mon2cov = mon2cov;
  endfunction

  task run();
    forever begin
      apb_transaction tr;
      @(vif.mon_cb iff (vif.mon_cb.psel && vif.mon_cb.penable && vif.mon_cb.pready));

      tr = new();
      tr.paddr   = vif.mon_cb.paddr;
      tr.pwrite  = vif.mon_cb.pwrite;
      tr.pwdata  = vif.mon_cb.pwdata;
      tr.prdata  = vif.mon_cb.prdata;
      tr.pslverr = vif.mon_cb.pslverr;

      mon2scb.put(tr.copy());
      mon2cov.put(tr.copy());
      tr.display("MONITOR");
    end
  endtask

endclass : apb_monitor
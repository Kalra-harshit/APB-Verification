`timescale 1ns/1ps
//=====================================================================
// apb_driver.sv
// Drives transactions onto the APB bus following the SETUP -> ACCESS
// protocol, waits for PREADY, samples PRDATA/PSLVERR, then returns to
// IDLE for one cycle before the next transfer.
//=====================================================================
class apb_driver;

  virtual apb_if.DRIVER vif;
  mailbox gen2drv;
  event   drv_done;

  function new(virtual apb_if.DRIVER vif, mailbox gen2drv, event drv_done);
    this.vif     = vif;
    this.gen2drv = gen2drv;
    this.drv_done = drv_done;
  endfunction

  task run();
    apb_transaction tr;
    // Idle state at start
    vif.drv_cb.psel    <= 1'b0;
    vif.drv_cb.penable <= 1'b0;
    vif.drv_cb.paddr   <= '0;
    vif.drv_cb.pwdata  <= '0;
    vif.drv_cb.pwrite  <= 1'b0;

    forever begin
      gen2drv.get(tr);
      drive_one(tr);
      tr.display("DRIVER");
      ->drv_done;
    end
  endtask

  task automatic drive_one(apb_transaction tr);
    // ---- SETUP phase ----
    @(vif.drv_cb);
    vif.drv_cb.psel    <= 1'b1;
    vif.drv_cb.penable <= 1'b0;
    vif.drv_cb.paddr   <= tr.paddr;
    vif.drv_cb.pwrite  <= tr.pwrite;
    vif.drv_cb.pwdata  <= tr.pwrite ? tr.pwdata : 32'h0;

    // ---- ACCESS phase ----
    @(vif.drv_cb);
    vif.drv_cb.penable <= 1'b1;

    // Wait until the slave asserts PREADY (supports wait-state slaves too)
    do begin
      @(vif.drv_cb);
    end while (!vif.drv_cb.pready);

    if (!tr.pwrite)
      tr.prdata = vif.drv_cb.prdata;
    tr.pslverr = vif.drv_cb.pslverr;

    // ---- back to IDLE for one cycle ----
    vif.drv_cb.psel    <= 1'b0;
    vif.drv_cb.penable <= 1'b0;
  endtask

endclass : apb_driver
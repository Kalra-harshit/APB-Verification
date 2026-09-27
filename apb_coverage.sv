`timescale 1ns/1ps
//=====================================================================
// apb_coverage.sv
// Functional coverage collector. Samples every completed transaction
// forwarded by the monitor and bins it by write/read, address region,
// and slave-error response, plus a write x address-region cross.
//=====================================================================
class apb_coverage;

  mailbox mon2cov;
  apb_transaction tr;

  covergroup cg;
    option.per_instance = 1;
    option.name = "apb_functional_cg";

    cp_write : coverpoint tr.pwrite {
      bins write = {1};
      bins read  = {0};
    }

    cp_addr_region : coverpoint tr.paddr[7:2] {
      bins low  = {[0:15]};
      bins mid  = {[16:47]};
      bins high = {[48:63]};
    }

    cp_slverr : coverpoint tr.pslverr {
      bins ok    = {0};
      bins error = {1};
    }

    cx_write_x_addr : cross cp_write, cp_addr_region;

  endgroup

  function new(mailbox mon2cov);
    this.mon2cov = mon2cov;
    cg = new();
  endfunction

  task run();
    forever begin
      mon2cov.get(tr);
      cg.sample();
    end
  endtask

  function void report();
    $display("=====================================================");
    $display(" FUNCTIONAL COVERAGE : %0.2f %%", cg.get_coverage());
    $display("=====================================================");
  endfunction

endclass : apb_coverage

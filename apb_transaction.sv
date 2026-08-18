`timescale 1ns/1ps

class apb_transaction;

  // Stimulus (randomized)
  rand bit [31:0] paddr;
  rand bit [31:0] pwdata;
  rand bit        pwrite;
  rand bit        inject_error;  // constrained-random knob: force an
                                  // out-of-range access to exercise PSLVERR

  // Response (filled in by driver/monitor)
  bit [31:0] prdata;
  bit        pslverr;

  // ~10% of transactions deliberately target an invalid (out-of-range)
  // address so the DUT's PSLVERR path, and the error bins in
  // apb_coverage.sv, actually get hit by CRV instead of only ever
  // seeing legal addresses.
  constraint c_error_dist {
    inject_error dist { 1 := 1, 0 := 9 };
  }

  // Keep addresses word-aligned. 
  constraint c_addr_range {
    paddr[1:0] == 2'b00;
    if (inject_error) {
      paddr inside {[32'h0000_0100 : 32'hFFFF_FFFC]};
    } else {
      paddr dist {
        32'h0000_0000              := 2,
        32'h0000_00FC              := 2,
        [32'h0000_0004:32'h0000_00F8] :/ 16
      };
    }
  }

  // Roughly even split between reads and writes
  constraint c_write_dist {
    pwrite dist {1 := 1, 0 := 1};
  }

  function new(string name = "apb_transaction");
  endfunction

  function apb_transaction copy();
    copy = new();
    copy.paddr        = this.paddr;
    copy.pwdata       = this.pwdata;
    copy.pwrite       = this.pwrite;
    copy.inject_error = this.inject_error;
    copy.prdata       = this.prdata;
    copy.pslverr      = this.pslverr;
  endfunction

  function void display(string tag = "");
    $display("[%0t] %0s : %0s PADDR=0x%0h PWDATA=0x%0h PRDATA=0x%0h PSLVERR=%0b",
              $time, tag, (pwrite ? "WRITE" : "READ "),
              paddr, pwdata, prdata, pslverr);
  endfunction

endclass : apb_transaction

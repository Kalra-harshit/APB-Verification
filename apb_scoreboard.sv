`timescale 1ns/1ps
//=====================================================================
// apb_scoreboard.sv
// Self-checking reference model. Maintains a shadow memory built
// purely from observed bus transactions: writes update the shadow,
// reads are checked against it.
//=====================================================================
class apb_scoreboard;

  mailbox mon2scb;

  localparam int MEM_DEPTH = 64;
  bit [31:0] ref_mem [0:MEM_DEPTH-1];

  int pass_count = 0;
  int fail_count = 0;

  function new(mailbox mon2scb);
    this.mon2scb = mon2scb;
  endfunction

  task run();
    apb_transaction tr;
    forever begin
      mon2scb.get(tr);
      check(tr);
    end
  endtask

  function void check(apb_transaction tr);
    int idx = tr.paddr[7:2];

    if (tr.pslverr) begin
      $display("[SCOREBOARD] SLVERR observed for PADDR=0x%0h (out-of-range access) - OK", tr.paddr);
      pass_count++;
      return;
    end

    if (tr.pwrite) begin
      ref_mem[idx] = tr.pwdata;
      $display("[SCOREBOARD] WRITE PADDR=0x%0h DATA=0x%0h", tr.paddr, tr.pwdata);
      pass_count++;
    end else begin
      if (tr.prdata === ref_mem[idx]) begin
        $display("[SCOREBOARD] READ  PADDR=0x%0h DATA=0x%0h : MATCH", tr.paddr, tr.prdata);
        pass_count++;
      end else begin
        $error("[SCOREBOARD] READ  PADDR=0x%0h : MISMATCH exp=0x%0h got=0x%0h",
               tr.paddr, ref_mem[idx], tr.prdata);
        fail_count++;
      end
    end
  endfunction

  function void report();
    $display("=====================================================");
    $display(" SCOREBOARD REPORT : PASS = %0d   FAIL = %0d", pass_count, fail_count);
    $display("=====================================================");
  endfunction

endclass : apb_scoreboard
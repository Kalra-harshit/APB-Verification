`timescale 1ns/1ps
//=====================================================================
// apb_if.sv
// APB interface: signal bundle + clocking blocks + modports
//=====================================================================
interface apb_if (input logic pclk, input logic preset_n);

  logic [31:0] paddr;
  logic [31:0] pwdata;
  logic        pwrite;
  logic        psel;
  logic        penable;
  logic [31:0] prdata;
  logic        pready;
  logic        pslverr;

  // Driver-side clocking block: drives stimulus, samples slave outputs
  clocking drv_cb @(posedge pclk);
    default input #1step output #1;
    output paddr, pwdata, pwrite, psel, penable;
    input  prdata, pready, pslverr;
  endclocking

  // Monitor-side clocking block: passive sampling only
  clocking mon_cb @(posedge pclk);
    default input #1step;
    input paddr, pwdata, pwrite, psel, penable, prdata, pready, pslverr;
  endclocking

  modport DRIVER  (clocking drv_cb, input pclk, preset_n);
  modport MONITOR (clocking mon_cb, input pclk, preset_n);

endinterface : apb_if
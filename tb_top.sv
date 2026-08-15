//=====================================================================
// tb_top.sv
// Top-level: clock/reset generation, DUT + interface instantiation,
// and kicks off the class-based test.
//=====================================================================
`timescale 1ns/1ps

module tb_top;

  import apb_pkg::*;

  logic pclk;
  logic preset_n;

  // Clock: 100 MHz
  initial pclk = 1'b0;
  always #5 pclk = ~pclk;

  // Interface
  apb_if vif (pclk, preset_n);

  // DUT
  apb_slave #(.MEM_DEPTH(64)) dut (
    .pclk    (pclk),
    .preset_n(preset_n),
    .psel    (vif.psel),
    .penable (vif.penable),
    .pwrite  (vif.pwrite),
    .paddr   (vif.paddr),
    .pwdata  (vif.pwdata),
    .prdata  (vif.prdata),
    .pready  (vif.pready),
    .pslverr (vif.pslverr)
  );

  // Protocol checker: wired straight to the interface signals via
  // hierarchical reference (modules can't be instantiated inside an
  // interface body, so it lives here instead).
  apb_assertions u_apb_assertions (
    .pclk    (pclk),
    .preset_n(preset_n),
    .psel    (vif.psel),
    .penable (vif.penable),
    .pwrite  (vif.pwrite),
    .paddr   (vif.paddr),
    .pwdata  (vif.pwdata),
    .prdata  (vif.prdata),
    .pready  (vif.pready),
    .pslverr (vif.pslverr)
  );

  // Reset
  initial begin
    preset_n = 1'b0;
    repeat (4) @(posedge pclk);
    preset_n = 1'b1;
  end

  // Test
  virtual apb_if.DRIVER  drv_vif;
  virtual apb_if.MONITOR mon_vif;
  apb_test test;

  initial begin
    drv_vif = vif;
    mon_vif = vif;

    @(posedge preset_n);
    repeat (2) @(posedge pclk);

    test = new(drv_vif, mon_vif, 80);
    test.run();

    $display("=== SIMULATION COMPLETE ===");
    $finish;
  end

endmodule : tb_top
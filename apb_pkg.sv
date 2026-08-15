`timescale 1ns/1ps
//=====================================================================
// apb_pkg.sv
// Bundles all testbench classes. Include order matters: a class must
// be declared before it is used as a type elsewhere.
//=====================================================================
package apb_pkg;

  `include "apb_transaction.sv"
  `include "apb_generator.sv"
  `include "apb_driver.sv"
  `include "apb_monitor.sv"
  `include "apb_scoreboard.sv"
  `include "apb_coverage.sv"
  `include "apb_environment.sv"
  `include "apb_test.sv"

endpackage : apb_pkg
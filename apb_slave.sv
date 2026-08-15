`timescale 1ns/1ps
//=====================================================================
// apb_slave.sv
// Simple zero-wait-state APB slave with a 64-word memory.
//   - Combinational read data + PSLVERR (valid the same cycle PREADY
//     is sampled high, since PREADY is tied to 1).
//   - Synchronous write.
//   - PSLVERR asserted for any access outside the memory range.
//=====================================================================
module apb_slave #(
  parameter int MEM_DEPTH = 64
)(
  input  logic        pclk,
  input  logic        preset_n,
  input  logic        psel,
  input  logic        penable,
  input  logic        pwrite,
  input  logic [31:0] paddr,
  input  logic [31:0] pwdata,
  output logic [31:0] prdata,
  output logic        pready,
  output logic        pslverr
);

  logic [31:0] mem [0:MEM_DEPTH-1];
  logic        addr_valid;

  assign addr_valid = (paddr[31:8] == '0) && (paddr[1:0] == 2'b00);
  assign pready      = 1'b1;
  assign pslverr      = psel & penable & ~addr_valid;
  assign prdata       = (psel && penable && !pwrite && addr_valid) ?
                          mem[paddr[7:2]] : 32'h0000_0000;

  always_ff @(posedge pclk or negedge preset_n) begin
    if (!preset_n) begin
      // memory contents intentionally not reset (behaves like real SRAM)
    end else if (psel && penable && pwrite && addr_valid) begin
      mem[paddr[7:2]] <= pwdata;
    end
  end

endmodule : apb_slave
`timescale 1ns/1ps

module apb_assertions (
  input logic        pclk,
  input logic        preset_n,
  input logic        psel,
  input logic        penable,
  input logic        pwrite,
  input logic [31:0] paddr,
  input logic [31:0] pwdata,
  input logic [31:0] prdata,
  input logic        pready,
  input logic        pslverr
);

  // 1) PENABLE must never be high unless PSEL is also high
  property p_penable_needs_psel;
    @(posedge pclk) disable iff (!preset_n)
    penable |-> psel;
  endproperty
  a_penable_needs_psel: assert property (p_penable_needs_psel)
    else $error("[ASSERT] PENABLE asserted while PSEL is low");

  // 2) SETUP phase: the cycle PSEL first rises, PENABLE must be low
  property p_setup_penable_low;
    @(posedge pclk) disable iff (!preset_n)
    $rose(psel) |-> !penable;
  endproperty
  a_setup_penable_low: assert property (p_setup_penable_low)
    else $error("[ASSERT] PENABLE high during SETUP phase");

  // 3) SETUP -> ACCESS transition: PADDR must not change
  property p_addr_stable_setup_to_access;
    @(posedge pclk) disable iff (!preset_n)
    (psel && !penable) |=> $stable(paddr);
  endproperty
  a_addr_stable_setup_to_access: assert property (p_addr_stable_setup_to_access)
    else $error("[ASSERT] PADDR changed between SETUP and ACCESS phase");

  // 4) SETUP -> ACCESS transition: PWRITE must not change
  property p_write_stable_setup_to_access;
    @(posedge pclk) disable iff (!preset_n)
    (psel && !penable) |=> $stable(pwrite);
  endproperty
  a_write_stable_setup_to_access: assert property (p_write_stable_setup_to_access)
    else $error("[ASSERT] PWRITE changed between SETUP and ACCESS phase");

  // 5) SETUP -> ACCESS transition: PWDATA must not change on a write
  property p_wdata_stable_setup_to_access;
    @(posedge pclk) disable iff (!preset_n)
    (psel && pwrite && !penable) |=> $stable(pwdata);
  endproperty
  a_wdata_stable_setup_to_access: assert property (p_wdata_stable_setup_to_access)
    else $error("[ASSERT] PWDATA changed between SETUP and ACCESS phase");

  // 6) General extended-access stability (covers slaves with wait states):
  //    while PSEL is high and PREADY is still low, address/control must hold
  property p_addr_stable_while_waiting;
    @(posedge pclk) disable iff (!preset_n)
    (psel && !pready) |=> $stable(paddr);
  endproperty
  a_addr_stable_while_waiting: assert property (p_addr_stable_while_waiting)
    else $error("[ASSERT] PADDR changed while slave held PREADY low");

  // 7) No unknown PADDR while a transfer is selected
  property p_no_x_addr;
    @(posedge pclk) disable iff (!preset_n)
    psel |-> !$isunknown(paddr);
  endproperty
  a_no_x_addr: assert property (p_no_x_addr)
    else $error("[ASSERT] PADDR is X/Z while PSEL is asserted");

  // 8) No unknown PREADY while a transfer is selected
  property p_no_x_pready;
    @(posedge pclk) disable iff (!preset_n)
    psel |-> !$isunknown(pready);
  endproperty
  a_no_x_pready: assert property (p_no_x_pready)
    else $error("[ASSERT] PREADY is X/Z while PSEL is asserted");

  // 9) PSLVERR must only ever be asserted during an active ACCESS phase
  property p_pslverr_only_during_access;
    @(posedge pclk) disable iff (!preset_n)
    pslverr |-> (psel && penable);
  endproperty
  a_pslverr_only_during_access: assert property (p_pslverr_only_during_access)
    else $error("[ASSERT] PSLVERR asserted outside an active ACCESS phase");

endmodule : apb_assertions

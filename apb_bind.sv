`timescale 1ns/1ps

bind apb_slave apb_assertions u_apb_assertions (
  .pclk    (pclk),
  .preset_n(preset_n),
  .psel    (psel),
  .penable (penable),
  .pwrite  (pwrite),
  .paddr   (paddr),
  .pwdata  (pwdata),
  .prdata  (prdata),
  .pready  (pready),
  .pslverr (pslverr)
);

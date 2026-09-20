/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  localparam DEPTH = 16;
  localparam AW    = $clog2(DEPTH);

  wire [AW-1:0] addr = uio_in[AW-1:0];

  reg [7:0] mem [0:DEPTH-1];

  // ---------------------------------------------------------------------------
  // Keep exactly ONE of the two blocks below active.
  // ---------------------------------------------------------------------------

  // ROM: contents come from testmem.hex (256 random bytes; only the first
  // DEPTH entries are used).
  /*
  initial begin
    $readmemh("../src/testmem.hex", mem);
  end
  */

  // RAM: same read path as the ROM, plus a synchronous write port.
  // There is no spare input pin for a dedicated write-enable (uio_in is the
  // address, ui_in is the data), so rst_n doubles as the write strobe:
  // while rst_n is LOW, ui_in is written to mem[addr] on every rising clock
  // edge; while rst_n is HIGH the memory is read-only.
  wire       we    = ~rst_n;
  wire [7:0] wdata = ui_in;

  always @(posedge clk) begin
    if (we)
      mem[addr] <= wdata;
  end

  wire [7:0] out_val = mem[addr];

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = ena ? out_val : 8'bz;
  assign uio_out = 0;
  assign uio_oe  = 0;

endmodule

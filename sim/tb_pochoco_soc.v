// Copyright 2026 Universidad de los Andes.
// Licensed under the Solderpad Hardware License, Version 0.51 (the "License");
// you may not use this file except in compliance with the License.
// SPDX-License-Identifier: SHL-0.51
//
// Course: Arquitectura de Computadores (2026)
//
// Authors:
// - Grupo 13  <TODO: nombres y correos>
//
// tb_pochoco_soc — Testbench top-level: emula la FPGA maestra sobre las
// lineas SPI reales de pochoco_soc (modo SPI 0: CPOL=0, CPHA=0, MSB
// primero — ver rtl/pochoco_spi_slave.v) para validar el protocolo
// completo + trade.s + la estrategia, sin necesidad de la placa fisica.
//
// Uso previsto: alimentar la serie de precios de practica, capturar la
// secuencia de decisiones que sale por o_SPI_MISO, y compararla contra
// sw/ref/trade_ref.py corrido sobre la misma serie (bit a bit).
//
// TODO:
//   1. Instanciar pochoco_soc con el MemFile de trade.hex (generar con
//      sw/Makefile una vez trade.s este listo)
//   2. Implementar spi_transfer (abajo) de verdad
//   3. Loop principal: por cada precio de la serie, generar un ciclo de
//      CS_n + 8 flancos de SCLK, esperar el periodo T de la ronda que se
//      este probando, y repetir
//   4. Volcar la secuencia de decisiones capturadas a un archivo para
//      comparar contra la referencia en Python (ver scripts/)
`timescale 1ns/1ps

module tb_pochoco_soc;

  localparam CLK_HALF  = 20;
  localparam SCLK_HALF = 500;
  localparam PROF_W    = 256;

  reg clk = 0;
  always #CLK_HALF clk = ~clk;

  reg  sclk = 0, mosi = 0, cs_n = 1;
  wire miso;
  wire [3:0] leds;

  pochoco_soc #(.MemFile("../sw/trade.hex")) dut (
    .i_Clk(clk), .o_LED(leds), .i_Switch(4'b0),
    .o_Segment1_A(), .o_Segment1_B(), .o_Segment1_C(), .o_Segment1_D(),
    .o_Segment1_E(), .o_Segment1_F(), .o_Segment1_G(),
    .o_Segment2_A(), .o_Segment2_B(), .o_Segment2_C(), .o_Segment2_D(),
    .o_Segment2_E(), .o_Segment2_F(), .o_Segment2_G(),
    .i_SPI_SCLK(sclk), .i_SPI_MOSI(mosi), .i_SPI_CS_n(cs_n), .o_SPI_MISO(miso)
  );

  wire retire = dut.u_core.instr_valid_id & ~dut.u_core.stall;
  wire got_px = dut.u_spi.byte_done;
  wire dec_wr = dut.u_spi.wr & (dut.u_spi.off == 6'd2);

  integer cyc = 0, ic = 0, midiendo = 0, overruns = 0;
  integer last_cyc = 0, last_ic = 0;

  integer prof_tot [0:PROF_W-1];
  integer prof_cur [0:PROF_W-1];
  integer prof_wst [0:PROF_W-1];
  integer worst_cyc = -1, worst_k = -1, tick_n = 0, j;
  reg  [7:0] pc_last = 0;
  wire [7:0] pc_w = dut.u_core.instr_valid_id ? dut.u_core.pc_id[9:2] : pc_last;

  initial for (j = 0; j < PROF_W; j = j + 1) begin
    prof_tot[j] = 0; prof_cur[j] = 0; prof_wst[j] = 0;
  end

  always @(posedge clk) begin
    if (dut.u_core.instr_valid_id) pc_last = dut.u_core.pc_id[9:2];
    if (got_px) begin
      if (midiendo) overruns = overruns + 1;
      midiendo = 1; cyc = 0; ic = 0;
    end else if (midiendo) begin
      cyc = cyc + 1;
      if (retire) ic = ic + 1;
      prof_cur[pc_w] = prof_cur[pc_w] + 1;
      if (dec_wr) begin
        last_cyc = cyc; last_ic = ic; midiendo = 0;
        for (j = 0; j < PROF_W; j = j + 1) begin
          prof_tot[j] = prof_tot[j] + prof_cur[j];
          if (cyc > worst_cyc) prof_wst[j] = prof_cur[j];
          prof_cur[j] = 0;
        end
        if (cyc > worst_cyc) begin worst_cyc = cyc; worst_k = tick_n; end
        tick_n = tick_n + 1;
      end
    end
  end

  task spi_byte(input [7:0] tx, output [7:0] rx);
    integer b;
    begin
      cs_n = 0; #(SCLK_HALF);
      for (b = 7; b >= 0; b = b - 1) begin
        mosi = tx[b];           #(SCLK_HALF);
        sclk = 1; rx[b] = miso; #(SCLK_HALF);
        sclk = 0;
      end
      #(SCLK_HALF); cs_n = 1;
    end
  endtask

  reg [7:0] prices [0:65535];
  reg [7:0] rx;
  integer k, nticks, t_ns;
  reg [1023:0] pfile;

  initial begin
    if (!$value$plusargs("PRICES=%s", pfile)) pfile = "practica.hex";
    if (!$value$plusargs("NTICKS=%d", nticks)) nticks = 20000;
    if (!$value$plusargs("T_NS=%d", t_ns))     t_ns = 100000;
    $readmemh(pfile, prices);

    #(10_000);
    for (k = 0; k <= nticks; k = k + 1) begin
      spi_byte(k < nticks ? prices[k] : 8'h00, rx);
      if (k > 0) $display("TICK %0d MISO %02h CYC %0d IC %0d",
                          k - 1, rx, last_cyc, last_ic);
      #(t_ns - 9 * 2 * SCLK_HALF);
    end
    for (j = 0; j < PROF_W; j = j + 1)
      if (prof_tot[j] != 0)
        $display("PROF %04h %0d %0d", j * 4, prof_tot[j], prof_wst[j]);
    $display("WORST tick=%0d cyc=%0d", worst_k, worst_cyc);
    $display("FIN ticks=%0d overruns=%0d", nticks, overruns);
    $finish;
  end

endmodule

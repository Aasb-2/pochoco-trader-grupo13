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
// tb_pochoco_movavg_periph — Testbench del periferico MMIO de media
// movil de rtl/ext/pochoco_movavg_periph.v.
//
// TODO: completar una vez cerrada la decision de ventana fija (potencia
// de 2) vs. configurable (ver TODOs dentro del propio periferico). Casos
// minimos: escribir una secuencia de precios conocida y verificar que
// AVG_OUT converge al promedio esperado.

`timescale 1ns/1ps

module tb_pochoco_movavg_periph;

  reg         clk = 0;
  reg         rst_n = 0;
  reg         sel, req, we;
  reg  [7:0]  addr;
  reg  [31:0] wdata;
  wire [31:0] rdata;

  integer errors = 0;

  always #20 clk = ~clk;

  pochoco_movavg_periph dut (
    .clk_i   (clk),
    .rst_ni  (rst_n),
    .sel_i   (sel),
    .req_i   (req),
    .we_i    (we),
    .addr_i  (addr),
    .wdata_i (wdata),
    .rdata_o (rdata)
  );

  initial begin
    // TODO: casos de prueba reales (escribir N precios por PRICE_IN,
    // leer AVG_OUT y comparar contra el promedio calculado en software)

    if (errors == 0) $display("Todos los tests de movavg_periph pasaron.");
    else              $display("%0d test(s) de movavg_periph fallaron.", errors);

    $finish;
  end

endmodule

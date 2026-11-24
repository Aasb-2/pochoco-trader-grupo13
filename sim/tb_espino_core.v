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
// tb_espino_core — Testbench de la CPU sola (sin el SoC ni el periferico
// SPI), para medir IC/ciclos/CPI por instruccion de forma aislada, sin el
// ruido del resto del sistema.
//
// TODO:
//   1. Instanciar espino_core con una memoria de instrucciones propia (no
//      necesariamente pochoco_ram completo) alimentando instr_rdata_i
//   2. Contar ciclos, e incrementar un contador de instrucciones cada vez
//      que una instruccion realmente avanza (condicion equivalente a
//      "instr_valid_id & ~stall" dentro del core — ver
//      rtl/espino_core/espino_id_stage.v, señal "commit")
//   3. Reportar CPI = ciclos / instrucciones al terminar un programa de
//      prueba (ej. el propio trade.s, una vez compilado a .hex)

`timescale 1ns/1ps

module tb_espino_core;

  reg clk   = 0;
  reg rst_n = 0;

  always #20 clk = ~clk;

  wire        instr_req;
  wire [31:0] instr_addr;
  reg  [31:0] instr_rdata;

  wire        data_req, data_we;
  wire [3:0]  data_be;
  wire [31:0] data_addr, data_wdata;
  reg  [31:0] data_rdata;

  // TODO: contadores de ciclos / instrucciones retiradas
  integer cycle_count = 0;
  integer instr_count = 0;

  espino_core dut (
    .clk_i         (clk),
    .rst_ni        (rst_n),
    .instr_req_o   (instr_req),
    .instr_addr_o  (instr_addr),
    .instr_rdata_i (instr_rdata),
    .data_req_o    (data_req),
    .data_we_o     (data_we),
    .data_be_o     (data_be),
    .data_addr_o   (data_addr),
    .data_wdata_o  (data_wdata),
    .data_rdata_i  (data_rdata)
  );

  // TODO: memoria de instrucciones/datos de prueba (array en Verilog con
  // $readmemh, igual que rtl/pochoco_ram.v, o instanciar pochoco_ram real)

  always @(posedge clk) begin
    if (rst_n) cycle_count = cycle_count + 1;
    // TODO: incrementar instr_count cuando corresponda
  end

  initial begin
    $dumpfile("tb_espino_core.vcd");
    $dumpvars(0, tb_espino_core);

    repeat (5) @(posedge clk);
    rst_n = 1;

    // TODO: correr hasta que el programa de prueba termine (ej. una
    // instruccion de halt propia, o un numero fijo de ciclos) y reportar
    // CPI = cycle_count / instr_count

    $finish;
  end

endmodule

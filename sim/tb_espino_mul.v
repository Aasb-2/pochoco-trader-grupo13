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
// tb_espino_mul — Testbench unitario del multiplicador de
// rtl/ext/espino_mul.v.
//
// TODO: completar una vez decidido el ancho (8 o 16 bits) y si la
// implementacion es combinacional o secuencial. Si es secuencial, el
// testbench debe esperar a busy_o=0 antes de leer result_o.

`timescale 1ns/1ps

module tb_espino_mul;

  reg         clk = 0;
  reg         rst_n = 0;
  reg         req;
  reg  [15:0] a, b;
  wire [31:0] result;
  wire        busy;

  integer errors = 0;

  always #20 clk = ~clk;

  espino_mul dut (
    .clk_i        (clk),
    .rst_ni       (rst_n),
    .req_i        (req),
    .operand_a_i  (a),
    .operand_b_i  (b),
    .result_o     (result),
    .busy_o       (busy)
  );

  initial begin
    // TODO: casos de prueba reales, ej.:
    // a = 16'd12; b = 16'd5; req = 1'b1; #1;
    // if (result !== 32'd60) begin
    //   $display("FAIL mul 12*5"); errors = errors + 1;
    // end

    if (errors == 0) $display("Todos los tests de multiplicador pasaron.");
    else              $display("%0d test(s) de multiplicador fallaron.", errors);

    $finish;
  end

endmodule

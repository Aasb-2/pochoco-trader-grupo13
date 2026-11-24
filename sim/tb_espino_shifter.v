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
// tb_espino_shifter — Testbench unitario del shifter de
// rtl/ext/espino_shifter.v.
//
// TODO: completar una vez que el shifter este implementado de verdad.
// Casos minimos a cubrir: SLL/SRL/SRA, shamt=0 (no deberia cambiar nada),
// shamt=31 (caso extremo), y operandos negativos para SRA (verificar
// extension de signo).

`timescale 1ns/1ps

module tb_espino_shifter;

  reg  [31:0] operand;
  reg  [4:0]  shamt;
  reg         dir, arith;
  wire [31:0] result;

  integer errors = 0;

  espino_shifter dut (
    .operand_i (operand),
    .shamt_i   (shamt),
    .dir_i     (dir),
    .arith_i   (arith),
    .result_o  (result)
  );

  initial begin
    // TODO: casos de prueba reales, ej.:
    // operand = 32'h0000_0001; shamt = 5'd4; dir = 1'b0; arith = 1'b0; #1;
    // if (result !== 32'h0000_0010) begin
    //   $display("FAIL SLL"); errors = errors + 1;
    // end

    if (errors == 0) $display("Todos los tests de shifter pasaron.");
    else              $display("%0d test(s) de shifter fallaron.", errors);

    $finish;
  end

endmodule

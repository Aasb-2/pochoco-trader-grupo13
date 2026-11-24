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
// tb_espino_alu — Testbench unitario de la ALU. Util desde ya (la ALU
// base ya existe en el repo) y se debe extender apenas se reactive el
// shifter (rtl/ext/espino_shifter.v) o se agregue alguna operacion nueva
// via custom-0.
//
// TODO: casos de prueba por operacion (ADD/SUB/XOR/OR/AND/SLT/SLTU y las
// comparaciones EQ/NE/LT/GE/LTU/GEU), y agregar SLL/SRL/SRA una vez que
// el shifter este integrado de verdad (hoy esos opcodes caen al default y
// no deberian pasar un test real de shift).

`timescale 1ns/1ps

module tb_espino_alu;

  reg  [3:0]  operator;
  reg  [31:0] operand_a, operand_b;
  wire [31:0] result;
  wire        cmp_result;

  integer errors = 0;

  espino_alu dut (
    .operator_i   (operator),
    .operand_a_i  (operand_a),
    .operand_b_i  (operand_b),
    .result_o     (result),
    .cmp_result_o (cmp_result)
  );

  task check_result(input [31:0] expected, input [255:0] name);
    begin
      if (result !== expected) begin
        $display("FAIL %s: esperado %0d, obtenido %0d", name, expected, result);
        errors = errors + 1;
      end
    end
  endtask

  initial begin
    // TODO: casos de prueba reales, por ejemplo:
    // operator = 4'd0; operand_a = 5; operand_b = 7; #1;
    // check_result(12, "ADD");
    //
    // operator = 4'd1; operand_a = 10; operand_b = 3; #1;
    // check_result(7, "SUB");

    if (errors == 0) $display("Todos los tests de ALU pasaron.");
    else              $display("%0d test(s) de ALU fallaron.", errors);

    $finish;
  end

endmodule

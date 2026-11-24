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
// espino_shifter — Alternativa de hardware (seccion 3.3): shifter de
// 32 bits, separado de la ALU para poder medirlo y sintetizarlo de forma
// aislada antes de integrarlo.
//
// DECISION PENDIENTE: la ALU actual (rtl/espino_core/espino_alu.v) ya
// decodifica SLL/SRL/SRA pero los deja comentados y cae al "default"
// (resultado = a+b). Integrar este modulo implica:
//   1. Instanciarlo en espino_alu.v
//   2. Reemplazar el default de SLL/SRL/SRA por su resultado real
//   3. Elegir combinacional puro (barrel shifter: gasta mas LUTs, 0
//      ciclos extra) vs. secuencial shift-by-1 repetido (menos LUTs, pero
//      hasta 31 ciclos extra en el peor caso — probablemente inaceptable
//      para el presupuesto de la Ronda 3, period T = 0.1 ms).
//
// Medir despues de implementar: LUTs usadas (yosys stat) y si el camino
// critico crece lo suficiente como para bajar la Fmax que reporta
// nextpnr-ice40 respecto del baseline sin shifter.

module espino_shifter (
  input  wire [31:0] operand_i,
  input  wire [4:0]  shamt_i,     // == operand_b_i[4:0] en la ALU
  input  wire        dir_i,       // 0 = izquierda (SLL), 1 = derecha (SRL/SRA)
  input  wire        arith_i,     // 1 = aritmetico (SRA); solo valido si dir_i=1
  output wire [31:0] result_o
);

  // TODO: implementar el shifter real.
  // Placeholder actual: passthrough (no desplaza), solo para que el
  // modulo sea instanciable y sintetizable mientras se decide la
  // estrategia (combinacional vs. secuencial).
  assign result_o = operand_i;

  wire _unused = &{1'b0, shamt_i, dir_i, arith_i};

endmodule

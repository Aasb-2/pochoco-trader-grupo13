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
// espino_mul — Alternativa de hardware (seccion 3.3): multiplicador de
// ancho WIDTH (8 o 16 bits, a definir), para acelerar la aritmetica que
// trade.s hoy tendria que resolver con sumas repetidas.
//
// DECISIONES PENDIENTES:
//   - Ancho: 8x8->16 es mas barato en LUTs pero puede quedar corto en
//     precision de punto fijo; 16x16->32 es mas caro pero evita truncar.
//   - Combinacional de 1 ciclo (mas LUTs, mas simple de integrar) vs.
//     secuencial shift-and-add multiciclo (menos LUTs, necesita busy_o
//     igual que espino_load_store_unit.v ya hace para los loads).
//   - Como se expone a la CPU: instruccion custom-0 (ver nota de
//     ensanche de alu_operator_o en rtl/espino_core/espino_decoder.v) vs.
//     periferico MMIO simple (mas facil de aislar, mas lento por el
//     acceso a memoria).
//
// Documentar la decision final en docs/hardware_decisions.md.

module espino_mul #(
  parameter WIDTH = 16
) (
  input  wire                clk_i,
  input  wire                rst_ni,
  input  wire                req_i,
  input  wire [WIDTH-1:0]    operand_a_i,
  input  wire [WIDTH-1:0]    operand_b_i,
  output wire [2*WIDTH-1:0]  result_o,
  output wire                busy_o        // 1 mientras una version
                                             // secuencial sigue calculando
);

  // TODO: implementar la version real (combinacional o secuencial, segun
  // la decision de arriba). Placeholder: multiplicador combinacional de
  // referencia, solo para tener algo sintetizable mientras se decide.
  assign result_o = operand_a_i * operand_b_i;
  assign busy_o   = 1'b0;

  // Evita warnings de "unused" si la version final no necesita clk/rst
  // (combinacional pura) o si req_i no se usa todavia.
  wire _unused = &{1'b0, clk_i, rst_ni, req_i};

endmodule

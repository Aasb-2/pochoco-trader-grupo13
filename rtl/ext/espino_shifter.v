// Copyright 2026 Universidad de los Andes.
// Licensed under the Solderpad Hardware License, Version 0.51 (the "License");
// you may not use this file except in compliance with the License.
// SPDX-License-Identifier: SHL-0.51
//
// Course: Arquitectura de Computadores (2026)
//
// Authors:
// - Grupo 13
//
// espino_shifter_sll — Variante B "flaca" del shifter (seccion 3.3).
//
// CONTEXTO MEDIDO: la version completa (SLL+SRL+SRA en paralelo) agrega
// ~405 LUT4 y el SoC llega a 1485 LCs, 116% de los 1280 de la Go Board:
// NO CABE. trade_s.s (variante B del software) solo usa slli (8p y los
// multiplos de div6), por lo que esta version implementa SOLO SLL y
// deja SRL/SRA en el default de la ALU (ADD), igual que la base.
//
// Decision documentada: acelerar lo que el programa usa; el resto del
// ISA queda como en la base. Costo objetivo: ~1 desplazador en lugar de 3.

module espino_shifter (
  input  wire [31:0] operand_i,
  input  wire [4:0]  shamt_i,     // == operand_b_i[4:0] en la ALU
  input  wire        dir_i,       // sin uso en esta version (SLL unicamente)
  input  wire        arith_i,     // sin uso en esta version
  output wire [31:0] result_o
);

  assign result_o = operand_i << shamt_i;

  wire _unused = &{1'b0, dir_i, arith_i};

endmodule

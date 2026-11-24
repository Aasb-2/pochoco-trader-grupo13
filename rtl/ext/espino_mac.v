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
// espino_mac — Alternativa de hardware (seccion 3.3): instruccion tipo
// MAC (multiply-accumulate) con acumulador interno, pensada
// especificamente para acelerar una media movil o una regresion
// incremental (evita ir y volver del acumulador por el banco de
// registros en cada tick).
//
// DECISION PENDIENTE: ¿el acumulador vive dentro de este modulo (mas
// rapido de usar desde software, pero hay que decidir como se lee/
// resetea) o se pasa explicito como entrada/salida cada vez (mas lento,
// pero mas facil de verificar con un testbench)? Documentar la eleccion
// en docs/hardware_decisions.md junto con la de instruccion vs. MMIO
// (ver rtl/ext/espino_mul.v).

module espino_mac #(
  parameter WIDTH = 16
) (
  input  wire                clk_i,
  input  wire                rst_ni,
  input  wire                en_i,      // pulso: acumula a_i*b_i en acc_o
  input  wire                clear_i,   // resetea el acumulador a 0
  input  wire [WIDTH-1:0]    a_i,
  input  wire [WIDTH-1:0]    b_i,
  output wire [2*WIDTH-1:0]  acc_o
);

  // TODO: implementar el registro acumulador y la logica de en_i/clear_i.
  // Placeholder: acumulador fijo en 0, solo para que el modulo sea
  // instanciable mientras se decide la interfaz final.
  assign acc_o = {2*WIDTH{1'b0}};

  wire _unused = &{1'b0, clk_i, rst_ni, en_i, clear_i, a_i, b_i};

endmodule

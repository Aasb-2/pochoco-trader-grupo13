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
// pochoco_pll — Alternativa de hardware (seccion 3.3): wrapper del PLL
// nativo del iCE40 (SB_PLL40_CORE) para subir la frecuencia interna mas
// alla de los 25 MHz de i_Clk.
//
// DECISION PENDIENTE: la frecuencia objetivo. Generar los parametros con
// `icepll -i 25 -o <f_deseada>` (incluido en el oss-cad-suite) en vez de
// calcularlos a mano, y pegar aqui la salida real. Despues correr
// nextpnr-ice40 con esa frecuencia para confirmar que SIGUE cerrando
// timing — agregar logica (shifter, mul, periferico de media movil,
// etc.) puede alargar el camino critico y bajar la Fmax real por debajo
// de lo que en teoria permitiria el PLL solo.
//
// Una vez validado: instanciar esto en rtl/pochoco_soc.v reemplazando
// "wire clk; assign clk = i_Clk;", y recalcular toda la tabla de
// presupuesto de ciclos por ronda con el nuevo periodo de clock.

module pochoco_pll (
  input  wire  clk_in_i,     // i_Clk, 25 MHz segun goboard.pcf
  output wire  clk_out_o,    // clock interno a la frecuencia objetivo
  output wire  locked_o      // PLL enganchado; usar para extender el reset
);

  // TODO: reemplazar por la instancia real de SB_PLL40_CORE con los
  // parametros (DIVR/DIVF/DIVQ/FILTER_RANGE, etc.) que entregue icepll.
  // Placeholder: passthrough, sin PLL real todavia.
  assign clk_out_o = clk_in_i;
  assign locked_o  = 1'b1;

endmodule

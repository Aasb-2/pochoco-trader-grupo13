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
// pochoco_movavg_periph — Alternativa de hardware (seccion 3.3):
// periferico MMIO que mantiene una media movil en hardware, siguiendo el
// mismo patron de offsets/señales que rtl/pochoco_periph.v y
// rtl/pochoco_spi_slave.v (sel_i/req_i/we_i + case(off)).
//
// Offsets propuestos (TODO: confirmar que no choquen con el resto del
// mapa de memoria MMIO — ver README.md, seccion "Memory Map"):
//   +0x00 (W) PRICE_IN : escribir aqui el precio de cada tick
//   +0x04 (R) AVG_OUT  : lee el promedio movil actualizado
//   +0x08 (W) CTRL     : bit0 = reset de la ventana (opcional)
//
// DECISION PENDIENTE (la importante): el tamano de la ventana.
//   - Si es una potencia de 2 fija en tiempo de sintesis (8/16/32
//     muestras), "dividir" es solo leer un rango de bits de la suma
//     acumulada (ej. suma[W+2:3] para ventana de 8 con precios de 8
//     bits) — no se necesita ningun shifter real, es casi gratis en LUTs.
//   - Si se quiere ventana configurable en tiempo de ejecucion, se
//     necesita un divisor real (mucho mas caro) o restringirse a
//     potencias de 2 seleccionables (shift variable: mas barato que un
//     divisor general, pero ya no es "gratis").
// Documentar la eleccion final en docs/hardware_decisions.md.

module pochoco_movavg_periph #(
  parameter WINDOW_LOG2 = 3   // ventana = 2**WINDOW_LOG2 muestras (TODO: ajustar)
) (
  input  wire        clk_i,
  input  wire        rst_ni,
  input  wire        sel_i,
  input  wire        req_i,
  input  wire        we_i,
  input  wire [7:0]  addr_i,
  input  wire [31:0] wdata_i,
  output reg  [31:0] rdata_o
);

  wire [5:0] off    = addr_i[7:2];
  wire       access = sel_i & req_i;

  // TODO: registro de suma acumulada (ancho = 8 + WINDOW_LOG2 bits para
  // no hacer overflow con ventanas grandes) y, si se decide implementar
  // una ventana deslizante exacta (no solo un filtro exponencial), el
  // buffer circular de muestras que hay que restar al salir de la
  // ventana. Documentar en hardware_decisions.md cual de las dos
  // aproximaciones se eligio y por que.

  always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rdata_o <= 32'b0;
    end else if (access & we_i) begin
      case (off)
        6'd0: ; // TODO: PRICE_IN -> actualizar la suma acumulada
        6'd2: ; // TODO: CTRL -> reset de ventana, si se implementa
        default: ;
      endcase
    end else if (access & ~we_i) begin
      case (off)
        6'd1: rdata_o <= 32'b0; // TODO: AVG_OUT = suma_acumulada >> WINDOW_LOG2
        default: rdata_o <= 32'b0;
      endcase
    end
  end

endmodule

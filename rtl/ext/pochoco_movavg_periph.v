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
// pochoco_movavg_periph — Alternativa de hardware (seccion 3.3,
// variante A): periferico MMIO que mantiene la ventana de 8 precios del
// algoritmo de reversio a la media. Mismo patron de accesos que
// rtl/pochoco_periph.v y rtl/pochoco_spi_slave.v.
//
// Mapa de registros (base propuesta 0x8002_0000, no choca con el SPI
// que vive en 0x8001_0000 — verificar el decoder de pochoco_soc.v):
//   +0x00 (W) PRICE_IN : escribir aqui el precio del tick. Suma el
//                        precio nuevo, resta el mas antiguo y avanza
//                        el puntero circular, todo en el mismo ciclo.
//   +0x04 (R) SUM_OUT  : suma de los ultimos <=8 precios.
//                        NOTA: devuelve la SUMA, no el promedio, porque
//                        trade.s compara 8p contra suma +- umbral*8
//                        (nunca divide). Con esto las decisiones son
//                        bit a bit identicas a la version software.
//   +0x08 (R) COUNT    : precios validos en la ventana (0 a 8); sustituye
//                        al contador x10 de la version software.
//   +0x0C (W) CTRL     : bit0 = reset de la ventana (suma=0, count=0).
//
// Decision documentada (docs/hardware_decisions.md): ventana fija de
// potencia de 2 (8), definida en sintesis, con buffer circular exacto
// (no filtro exponencial), para replicar bit a bit la ventana del
// software. El "promedio" nunca se calcula: se entrega la suma.

module pochoco_movavg_periph #(
  parameter WINDOW_LOG2 = 3                 // ventana = 8 precios
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

  localparam NUM = 1 << WINDOW_LOG2;         // 8
  localparam PTR_W = WINDOW_LOG2;            // 3 bits: 0..7

  // Suma de la ventana: 8 precios de 8 bits -> max 8*255 = 2040 (11 bits).
  reg [31:0] sum;
  reg [7:0]  samples [0:NUM-1];
  reg [PTR_W-1:0] wr_ptr;
  reg [3:0]  count;                          // 0..8

  wire [5:0] off    = addr_i[7:2];
  wire       access = sel_i & req_i;
  wire       full   = (count == NUM);

  wire [7:0] price_in = wdata_i[7:0];

  always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      sum    <= 32'd0;
      wr_ptr <= {PTR_W{1'b0}};
      count  <= 4'd0;
      rdata_o <= 32'd0;
    end else if (access & we_i) begin
      case (off)
        6'd0: begin // PRICE_IN
          if (!full) begin
            sum <= sum + {24'd0, price_in};
            count <= count + 4'd1;
          end else begin
            sum <= sum + {24'd0, price_in} - {24'd0, samples[wr_ptr]};
          end
          samples[wr_ptr] <= price_in;
          wr_ptr <= (wr_ptr == NUM-1) ? {PTR_W{1'b0}} : wr_ptr + 1'b1;
        end
        6'd3: begin // CTRL: bit0 = reset de ventana
          if (wdata_i[0]) begin
            sum   <= 32'd0;
            count <= 4'd0;
            wr_ptr <= {PTR_W{1'b0}};
          end
        end
        default: ;
      endcase
      rdata_o <= 32'd0;
    end else if (access & ~we_i) begin
      case (off)
        6'd1: rdata_o <= sum;                // SUM_OUT
        6'd2: rdata_o <= {28'd0, count};     // COUNT
        default: rdata_o <= 32'd0;
      endcase
    end
  end

endmodule

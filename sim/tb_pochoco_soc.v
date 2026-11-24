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
// tb_pochoco_soc — Testbench top-level: emula la FPGA maestra sobre las
// lineas SPI reales de pochoco_soc (modo SPI 0: CPOL=0, CPHA=0, MSB
// primero — ver rtl/pochoco_spi_slave.v) para validar el protocolo
// completo + trade.s + la estrategia, sin necesidad de la placa fisica.
//
// Uso previsto: alimentar la serie de precios de practica, capturar la
// secuencia de decisiones que sale por o_SPI_MISO, y compararla contra
// sw/ref/trade_ref.py corrido sobre la misma serie (bit a bit).
//
// TODO:
//   1. Instanciar pochoco_soc con el MemFile de trade.hex (generar con
//      sw/Makefile una vez trade.s este listo)
//   2. Implementar spi_transfer (abajo) de verdad
//   3. Loop principal: por cada precio de la serie, generar un ciclo de
//      CS_n + 8 flancos de SCLK, esperar el periodo T de la ronda que se
//      este probando, y repetir
//   4. Volcar la secuencia de decisiones capturadas a un archivo para
//      comparar contra la referencia en Python (ver scripts/)

`timescale 1ns/1ps

module tb_pochoco_soc;

  reg        clk    = 0;
  reg  [3:0] switch = 4'b0;
  wire [3:0] led;

  reg        spi_sclk = 0;
  reg        spi_mosi  = 0;
  reg        spi_cs_n  = 1;
  wire       spi_miso;

  // 25 MHz -> periodo 40 ns
  always #20 clk = ~clk;

  pochoco_soc #(
    .MemFile("../sw/trade.hex")   // TODO: generar una vez trade.s este listo
  ) dut (
    .i_Clk        (clk),
    .o_LED        (led),
    .i_Switch     (switch),
    .i_SPI_SCLK   (spi_sclk),
    .i_SPI_MOSI   (spi_mosi),
    .i_SPI_CS_n   (spi_cs_n),
    .o_SPI_MISO   (spi_miso)
    // TODO: conectar tambien los pines de 7-segmentos si se quieren
    // observar en el VCD (no son necesarios para validar los datos)
  );

  // TODO: tarea que envia un byte de precio por SPI y captura el byte de
  // DECISION vigente en ese mismo ciclo (el que la maestra "leeria").
  task spi_transfer(input [7:0] price_byte, output [7:0] decision_byte);
    begin
      // TODO: bajar spi_cs_n, generar 8 flancos de spi_sclk desplazando
      // price_byte por spi_mosi (MSB primero), muestreando spi_miso bit a
      // bit en decision_byte, y subir spi_cs_n al terminar.
      decision_byte = 8'h00;
    end
  endtask

  initial begin
    $dumpfile("tb_pochoco_soc.vcd");
    $dumpvars(0, tb_pochoco_soc);

    // TODO: cargar la serie de precios, iterar spi_transfer() por cada
    // tick respetando el periodo T de la ronda, y loguear las decisiones
    // obtenidas para compararlas con sw/ref/trade_ref.py.

    $finish;
  end

endmodule

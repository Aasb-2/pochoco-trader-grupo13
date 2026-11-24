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
// spi_master_model — Logica reutilizable para emular un maestro SPI
// (modo 0: CPOL=0, CPHA=0, MSB primero), pensada para evitar duplicar la
// generacion de clock/framing si se agregan mas testbenches de
// integracion ademas de sim/tb_pochoco_soc.v.
//
// TODO: decidir el mecanismo de reutilizacion. Verilog puro no soporta
// pasar wires/regs de un modulo a una tarea de otro archivo de forma
// automatica via `include; las opciones razonables son:
//   a) Un `include` con macros que asumen nombres fijos de señal en el
//      testbench que lo usa (simple, pero fragil si cambian los nombres)
//   b) Migrar los testbenches a SystemVerilog y usar una interfaz SPI
//      (mas limpio, pero hay que confirmar que Icarus Verilog la soporta
//      bien con las flags usadas en sim/Makefile)
//
// Mientras tanto, cada testbench implementa su propia tarea
// spi_transfer de forma local (ver sim/tb_pochoco_soc.v) — este archivo
// queda como placeholder hasta que se decida unificarlo.

// TODO: implementar la tarea/macro compartida una vez decidido el
// mecanismo de arriba.

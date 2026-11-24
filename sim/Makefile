# Copyright 2026 Universidad de los Andes.
# Licensed under the Solderpad Hardware License, Version 0.51 (the "License");
# you may not use this file except in compliance with the License.
# SPDX-License-Identifier: SHL-0.51
#
# Course: Arquitectura de Computadores (2026)
#
# Authors:
# - Grupo 13  <TODO: nombres y correos>

# Compila y corre los testbenches con Icarus Verilog + vvp.
# (.gitignore ya excluye sim/sim y *.vcd como artefactos de simulacion)

RTL := $(wildcard ../rtl/*.v ../rtl/**/*.v ../rtl/ext/*.v ../rtl/pll/*.v)

IVFLAGS := -g2012

.PHONY: all soc core alu shifter mul movavg clean

all: soc core alu

soc: tb_pochoco_soc.v $(RTL)
	iverilog $(IVFLAGS) -o sim -s tb_pochoco_soc $^
	vvp sim

core: tb_espino_core.v $(RTL)
	iverilog $(IVFLAGS) -o sim -s tb_espino_core $^
	vvp sim

alu: tb_espino_alu.v ../rtl/espino_core/espino_alu.v
	iverilog $(IVFLAGS) -o sim -s tb_espino_alu $^
	vvp sim

# TODO: estos targets ya compilan contra los stubs de rtl/ext/, pero no
# prueban nada util hasta que esos modulos y sus testbenches tengan logica
# real (ver TODOs en cada archivo).
shifter: tb_espino_shifter.v ../rtl/ext/espino_shifter.v
	iverilog $(IVFLAGS) -o sim -s tb_espino_shifter $^
	vvp sim

mul: tb_espino_mul.v ../rtl/ext/espino_mul.v
	iverilog $(IVFLAGS) -o sim -s tb_espino_mul $^
	vvp sim

movavg: tb_pochoco_movavg_periph.v ../rtl/ext/pochoco_movavg_periph.v
	iverilog $(IVFLAGS) -o sim -s tb_pochoco_movavg_periph $^
	vvp sim

clean:
	rm -f sim *.vcd

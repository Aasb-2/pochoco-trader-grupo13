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


RTL   := $(wildcard ../rtl/*.v ../rtl/espino_core/*.v)
CELLS ?= $(shell yosys-config --datdir 2>/dev/null || echo /usr/share/yosys)/ice40/cells_sim.v

IVFLAGS := -g2012

SERIE  ?= ../data/practica_meta.csv
NTICKS ?= 20000
T_NS   ?= 30000

.PHONY: all soc core alu shifter mul movavg clean

all: soc alu

../sw/trade.hex: ../sw/trade.s
	$(MAKE) -C ../sw trade

practica.hex: $(SERIE)
	python3 ../scripts/csv_to_hex.py $< $@

ref_dec.txt: $(SERIE) ../sw/ref/trade_ref.py
	python3 ../sw/ref/trade_ref.py $< --dump $@

soc: tb_pochoco_soc.v $(RTL) ../sw/trade.hex practica.hex ref_dec.txt
	iverilog $(IVFLAGS) -o sim -s tb_pochoco_soc tb_pochoco_soc.v $(RTL) $(CELLS)
	vvp -n sim +PRICES=practica.hex +NTICKS=$(NTICKS) +T_NS=$(T_NS) > soc_log.txt
	grep FIN soc_log.txt
	python3 ../scripts/measure_cycles.py soc_log.txt ref_dec.txt
	python3 ../scripts/profile.py soc_log.txt ../sw/trade.s

core: tb_espino_core.v $(RTL)
	iverilog $(IVFLAGS) -o sim -s tb_espino_core $^ $(CELLS)
	vvp sim

alu: tb_espino_alu.v ../rtl/espino_core/espino_alu.v
	iverilog $(IVFLAGS) -o sim -s tb_espino_alu $^
	vvp sim

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
	rm -f sim *.vcd soc_log.txt practica.hex ref_dec.txt

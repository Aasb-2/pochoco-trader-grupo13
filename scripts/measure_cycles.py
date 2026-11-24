#!/usr/bin/env python3
"""
measure_cycles.py — Calcula IC, ciclos, CPI por tick (caso promedio y
peor caso) a partir de los datos que deje un testbench (ver sim/).

TODO: decidir el formato exacto de log que los testbenches van a producir
(ej. una linea por tick: "tick,ciclos,instrucciones") y parsearlo aqui.

Mientras tanto, estos costos por tipo de instruccion (derivados de leer
rtl/espino_core/espino_controller.v, espino_id_stage.v y
espino_load_store_unit.v) sirven para una estimacion a mano sin correr
nada todavia:

  ALU / inmediato / LUI / AUIPC / SW / branch no tomado : 2 ciclos
  LW (cualquier variante)                                : 3 ciclos
  Branch tomado / JAL / JALR                             : 3 ciclos

(el pipeline de 2 etapas con lectura sincronica de memoria de
instrucciones y banco de registros impone ese piso minimo de 2 ciclos
por instruccion, mas 1 ciclo extra para loads y saltos tomados)
"""

CYCLES_BASE = 2
CYCLES_LOAD = 3
CYCLES_TAKEN_BRANCH_OR_JUMP = 3


def estimate_cpi(n_alu: int, n_load: int, n_taken_branch_or_jump: int) -> float:
    """CPI esperado dado un conteo estatico o dinamico de instrucciones por
    categoria. No reemplaza medir de verdad en simulacion, pero sirve para
    una primera estimacion antes de tener el testbench corriendo."""
    total_instr = n_alu + n_load + n_taken_branch_or_jump
    if total_instr == 0:
        return 0.0
    total_cycles = (
        n_alu * CYCLES_BASE
        + n_load * CYCLES_LOAD
        + n_taken_branch_or_jump * CYCLES_TAKEN_BRANCH_OR_JUMP
    )
    return total_cycles / total_instr


def parse_log(path: str):
    """TODO: parsear el log real que produzca sim/tb_pochoco_soc.v o
    sim/tb_espino_core.v una vez que esos testbenches cuenten ciclos e
    instrucciones de verdad (hoy son placeholders, ver TODOs en cada
    archivo)."""
    raise NotImplementedError


def report_per_round(cycles_per_tick: dict, period_cycles: dict) -> None:
    """TODO: comparar cycles_per_tick (caso promedio y peor caso, medidos)
    contra el presupuesto de ciclos de cada ronda (period_cycles, en
    ciclos de reloj) y reportar si el programa alcanza a tiempo."""
    raise NotImplementedError


if __name__ == "__main__":
    # TODO: leer el log de una corrida real y reportar IC/ciclos/CPI por
    # tick, caso promedio y peor caso, comparado contra el periodo T de
    # cada ronda (10 ms / 1 ms / 0.1 ms a 25 MHz, o la frecuencia real que
    # resulte si se implementa el PLL).
    pass

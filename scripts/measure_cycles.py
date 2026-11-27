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



measure_cycles.py - A partir del log de sim/tb_pochoco_soc.v:
  1. Verifica bit a bit las decisiones (MISO) contra sw/ref/trade_ref.py.
  2. Reporta IC, ciclos, CPI y tiempo por tick (promedio y peor caso).
  3. Compara el peor caso con el presupuesto de cada ronda
     (T menos la transaccion SPI de ~9 us y la sincronizacion).

Uso: python3 scripts/measure_cycles.py sim/soc_log.txt sim/ref_dec.txt [--f-mhz 25]

"""
import sys

SPI_US = 9.0
SYNC_CYCLES = 3
ROUNDS = {"Ronda 1": 10_000.0, "Ronda 2": 1_000.0, "Ronda 3": 100.0}


def parse_log(path):
    ticks = []
    with open(path) as f:
        for line in f:
            t = line.split()
            if t and t[0] == "TICK":
                ticks.append({"k": int(t[1]), "miso": int(t[3], 16),
                              "cyc": int(t[5]), "ic": int(t[7])})
    return ticks


def main():
    argv = sys.argv[1:]
    f_mhz = 25.0
    if "--f-mhz" in argv:
        i = argv.index("--f-mhz")
        f_mhz = float(argv[i + 1])
        del argv[i:i + 2]
    ticks = parse_log(argv[0])

    if len(argv) > 1:
        ref = [int(l, 16) for l in open(argv[1]) if l.strip()]
        n = min(len(ref), len(ticks))
        bad = [i for i in range(n) if ref[i] != ticks[i]["miso"]]
        print(f"Verificacion bit a bit: {'OK' if not bad else 'FALLA'} - {n} ticks, "
              f"{len(bad)} diferencias" + (f" (primeras: {bad[:10]})" if bad else ""))
        if bad:
            sys.exit(1)

    cyc = [t["cyc"] for t in ticks]
    ic = [t["ic"] for t in ticks]
    w = max(range(len(ticks)), key=lambda i: cyc[i])
    prom_cyc, prom_ic = sum(cyc) / len(cyc), sum(ic) / len(ic)
    print(f"\n{'':12s} {'IC':>8s} {'Ciclos':>8s} {'CPI':>6s} {'Tiempo':>10s}")
    print(f"{'Promedio':12s} {prom_ic:8.1f} {prom_cyc:8.1f} "
          f"{sum(cyc) / sum(ic):6.3f} {prom_cyc / f_mhz:8.2f} us")
    print(f"{'Peor caso':12s} {ic[w]:8d} {cyc[w]:8d} "
          f"{cyc[w] / ic[w]:6.3f} {cyc[w] / f_mhz:8.2f} us   (tick {ticks[w]['k']})")

    print(f"\n{'Ronda':8s} {'T':>8s} {'Ciclos utiles':>14s} {'Peor caso':>10s} {'Holgura':>8s}")
    for nombre, t_us in ROUNDS.items():
        util = int((t_us - SPI_US) * f_mhz) - SYNC_CYCLES
        print(f"{nombre:8s} {t_us:6.0f}us {util:14d} {cyc[w]:10d} {util / cyc[w]:7.1f}x")


if __name__ == "__main__":
    main()

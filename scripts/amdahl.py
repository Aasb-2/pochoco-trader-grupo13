#!/usr/bin/env python3
"""
amdahl.py — Calculadora de la Ley de Amdahl, para justificar con un
numero (no solo intuicion) si vale la pena acelerar una parte del
algoritmo con hardware antes de tocar RTL (seccion 3.3, paso de
profiling previo al co-diseño).

speedup_global = 1 / ((1 - f) + f / s)

donde:
  f = fraccion del tiempo total (en ciclos) que ocupa la parte acelerable
      (medir con scripts/measure_cycles.py o profiling real; no asumir)
  s = speedup de esa parte con la aceleracion de hardware propuesta
"""


MEDIDO = {
    "Esperar y leer precio": {"prom": 0.191, "peor": 0.086},
    "Espejo (decodificar)":  {"prom": 0.109, "peor": 0.145},
    "Media movil":           {"prom": 0.323, "peor": 0.118},
    "Senal y decision":      {"prom": 0.338, "peor": 0.134},
    "Escribir DECISION":     {"prom": 0.031, "peor": 0.011},
    "mul6":                  {"prom": 0.002, "peor": 0.000},
    "div6":                  {"prom": 0.004, "peor": 0.505},
}


def amdahl_speedup(f, s):
    if not 0.0 <= f <= 1.0:
        raise ValueError("f debe estar entre 0 y 1")
    if s <= 0:
        raise ValueError("s debe ser > 0")
    return 1.0 / ((1.0 - f) + f / s)


def max_possible_speedup(f):
    return amdahl_speedup(f, 1e9)


def required_speedup_for_target(f, target):
    denom = (1.0 / target) - (1.0 - f)
    if denom <= 0:
        raise ValueError("objetivo inalcanzable incluso con s -> inf")
    return f / denom


if __name__ == "__main__":
    print(f"{'Seccion':24s} {'f prom':>7s} {'max prom':>9s} {'f peor':>7s} {'max peor':>9s}")
    for n, f in MEDIDO.items():
        print(f"{n:24s} {f['prom']:7.3f} {max_possible_speedup(f['prom']):8.2f}x "
              f"{f['peor']:7.3f} {max_possible_speedup(f['peor']):8.2f}x")

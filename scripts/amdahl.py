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


def amdahl_speedup(fraction_accelerated: float, part_speedup: float) -> float:
    if not (0.0 <= fraction_accelerated <= 1.0):
        raise ValueError("fraction_accelerated debe estar entre 0 y 1")
    if part_speedup <= 0:
        raise ValueError("part_speedup debe ser > 0")
    f = fraction_accelerated
    s = part_speedup
    return 1.0 / ((1.0 - f) + f / s)


def max_possible_speedup(fraction_accelerated: float) -> float:
    """Limite cuando s -> infinito (acelerar esa parte a costo cero)."""
    return amdahl_speedup(fraction_accelerated, part_speedup=1e9)


def required_speedup_for_target(fraction_accelerated: float, target_speedup: float) -> float:
    """Dado un speedup global deseado, que speedup 's' de la parte
    acelerable hace falta. Util para decidir si una alternativa de
    hardware (con un speedup de parte conocido o estimado) alcanza para
    cumplir el presupuesto de ciclos de una ronda."""
    f = fraction_accelerated
    if target_speedup <= 0:
        raise ValueError("target_speedup debe ser > 0")
    denom = (1.0 / target_speedup) - (1.0 - f)
    if denom <= 0:
        raise ValueError(
            "target_speedup no es alcanzable ni acelerando la parte a costo cero "
            "(revisar f: puede que la fraccion acelerable sea muy baja)"
        )
    return f / denom


if __name__ == "__main__":
    # TODO: reemplazar con los numeros reales medidos. Ejemplo de uso:
    # f = fraccion de ciclos que hoy consume la aritmetica que reemplaza
    #     al multiplicador/shifter faltante (medir con measure_cycles.py)
    # s = speedup esperado de la alternativa de hardware bajo evaluacion
    f = 0.0   # TODO
    s = 1.0   # TODO
    print(f"Speedup global estimado: {amdahl_speedup(f, s):.3f}x")
    print(f"Speedup maximo posible (s->inf): {max_possible_speedup(f):.3f}x")

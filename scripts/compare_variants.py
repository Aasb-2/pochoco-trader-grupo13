#!/usr/bin/env python3
"""
compare_variants.py — Tabla comparativa entre variantes de hardware
(solo-software + cada alternativa de la seccion 3.3), a partir de los
numeros de `yosys stat`, `nextpnr-ice40` y de simulacion.

TODO: automatizar la extraccion de LUTs/BRAM desde la salida de yosys y
la Fmax desde la salida de nextpnr (hoy hay que copiarlos a mano abajo en
VARIANTS), y completar ciclos/CPI/Ops por segundo desde
scripts/measure_cycles.py una vez que los testbenches reales esten
corriendo.

Contexto de presupuesto (iCE40 HX1K, ver Makefile: --hx1k --package
vq100): 1.280 LUTs totales, 8 bloques de BRAM de 4 Kbit, de los cuales 4
ya los usa el banco de registros de Espino
(rtl/espino_core/espino_register_file.v).
"""

from dataclasses import dataclass

TOTAL_LUTS_HX1K = 1280
TOTAL_BRAM_BLOCKS_HX1K = 8
BRAM_BLOCKS_USED_BY_REGFILE = 4  # espino_register_file.v: 2 bancos x 2 SB_RAM40_4K


@dataclass
class VariantMetrics:
    name: str
    luts: int = 0
    bram_blocks: int = 0
    fmax_mhz: float = 0.0
    cycles_per_tick_worst: int = 0
    cpi: float = 0.0
    ops_per_sec: float = 0.0   # definicion de "operacion util" debe ser
                                # la misma para todas las variantes


# TODO: una entrada por variante efectivamente construida y medida.
VARIANTS = [
    VariantMetrics(name="baseline_software"),
    # VariantMetrics(name="pll"),
    # VariantMetrics(name="movavg_periph"),
    # VariantMetrics(name="shifter"),
    # VariantMetrics(name="mul_mac"),
]


def print_table(variants: list[VariantMetrics]) -> None:
    header = (
        f"{'Variante':<20}{'LUTs':>8}{'BRAM':>8}{'Fmax(MHz)':>12}"
        f"{'Ciclos/tick':>14}{'CPI':>8}{'Ops/s':>12}"
    )
    print(header)
    print("-" * len(header))
    for v in variants:
        luts_pct = 100.0 * v.luts / TOTAL_LUTS_HX1K if v.luts else 0.0
        print(
            f"{v.name:<20}{v.luts:>8}{v.bram_blocks:>8}{v.fmax_mhz:>12.2f}"
            f"{v.cycles_per_tick_worst:>14}{v.cpi:>8.2f}{v.ops_per_sec:>12.1f}"
        )
        if v.luts:
            print(f"{'':<20}  ({luts_pct:.1f}% de {TOTAL_LUTS_HX1K} LUTs disponibles)")


if __name__ == "__main__":
    print_table(VARIANTS)

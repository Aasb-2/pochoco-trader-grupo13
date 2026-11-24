#!/usr/bin/env python3
"""
trade_ref.py — Implementacion de referencia (Python) de la estrategia de
trading. Sirve para dos cosas:

  1. Disenar y validar el algoritmo antes de pasarlo a assembly
     (seccion 3.1): comparar patrimonio final, N de ordenes, comisiones y
     drawdown maximo contra "no operar" y "comprar y mantener".
  2. Generar la secuencia de decisiones "correcta" contra la que se valida
     trade.s bit a bit, tick a tick (seccion 3.2).

TODO: implementar la estrategia real (media movil / momentum / regresion
incremental / reversion a la media) y documentar aqui la justificacion de
por que se eligio.
"""

from dataclasses import dataclass


@dataclass
class TradeState:
    """Estado que el algoritmo mantiene entre ticks.

    Debe reflejar 1:1 lo que x3 (y cualquier registro adicional) representa
    en sw/trade.s, para que la comparacion bit a bit tenga sentido real.
    """
    # TODO: definir campos, ej.:
    # running_sum: int = 0
    # position: int = 0
    pass


def init_state() -> TradeState:
    """Estado inicial. Debe calzar con la inicializacion de sw/trade.s."""
    # TODO
    return TradeState()


def decide(state: TradeState, price: int) -> tuple[TradeState, int]:
    """Dado el estado actual y el precio del tick, retorna
    (nuevo_estado, decision).

    La decision debe ser exactamente el byte que sw/trade.s escribiria en
    el registro DECISION para el mismo tick.

    TODO: implementar la logica real en aritmetica entera / punto fijo
    (no floats) si trade.s va a replicarla tal cual — evita desviaciones
    por redondeo entre esta referencia y el RV32E real.
    """
    # TODO
    decision = 0  # placeholder: "mantener"
    return state, decision


def run(prices: list[int]) -> list[int]:
    """Corre la estrategia sobre una serie completa de precios y retorna la
    lista de decisiones, una por tick.

    Esta es la secuencia que sim/tb_pochoco_soc.v debe reproducir via
    o_SPI_MISO cuando trade.s corre en el core simulado.
    """
    state = init_state()
    decisions = []
    for p in prices:
        state, d = decide(state, p)
        decisions.append(d)
    return decisions


def backtest_report(prices: list[int], decisions: list[int]) -> None:
    """TODO: calcular y reportar patrimonio final, N de ordenes,
    comisiones totales y drawdown maximo desde un peak, y comparar contra
    las estrategias de referencia "no operar" y "comprar y mantener"."""
    raise NotImplementedError


if __name__ == "__main__":
    # TODO: cargar la serie de practica real (ver generate_practice_series.py
    # o el archivo oficial que entregue el curso), correr run() sobre ella,
    # y llamar a backtest_report().
    pass

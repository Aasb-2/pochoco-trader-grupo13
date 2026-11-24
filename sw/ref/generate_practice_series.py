#!/usr/bin/env python3
"""
generate_practice_series.py — Genera series de precios sinteticas para
estresar el algoritmo mas alla de la serie de practica oficial del curso
(casos borde: precio constante, tendencia pura, ruido, saltos bruscos).

TODO: decidir el rango de precios. El registro PRICE del protocolo SPI es
de 8 bits (ver rtl/pochoco_spi_slave.v, REG_PRICE), asi que los valores
generados deben quedar en [0, 255] o en el sub-rango que el curso defina
como representacion de precio real.

NOTA: .gitignore ya excluye *.csv — si se guarda la serie como .csv, git
no la va a trackear aunque se haga `git add .`. Usar .txt/.dat, o forzar
con `git add -f`.
"""

import random


def constant_series(value: int, n: int) -> list[int]:
    """Serie de precio constante: el algoritmo no deberia operar nunca
    (buen chequeo de que la estrategia no genera ordenes espurias)."""
    # TODO: validar rango de 'value'
    return [value] * n


def trend_series(start: int, step: int, n: int, clip=(0, 255)) -> list[int]:
    """Tendencia pura (subida o bajada sostenida). TODO: aplicar clip para
    no salirse del rango de 8 bits de PRICE."""
    # TODO
    raise NotImplementedError


def noisy_series(base: int, amplitude: int, n: int, seed: int = 0) -> list[int]:
    """Ruido alrededor de un precio base, para probar que el algoritmo no
    sobre-opera por ruido de corto plazo. TODO: implementar con 'random'
    y clip al rango valido."""
    # TODO
    raise NotImplementedError


def save_series(prices: list[int], path: str) -> None:
    """TODO: formato de salida (ej. un precio por linea en decimal), y
    que calce con lo que sw/ref/trade_ref.py y sim/tb_pochoco_soc.v esperan
    leer."""
    raise NotImplementedError


if __name__ == "__main__":
    # TODO: generar y guardar los casos de prueba que el equipo decida usar
    # ademas de la serie oficial.
    pass

#!/usr/bin/env python3
"""
trade_ref.py - Referencia del algoritmo de Pochoco Trader (Grupo 13).

Estrategia: reversion a la media de corto plazo.
  media = suma de los ultimos N precios / N        (N = 8)
  comprar si  precio <= media - M_COMPRA            (M_COMPRA = 3)
  vender  si  precio >= media + M_VENTA             (M_VENTA  = 2)

Para no dividir (Espino no tiene div ni shifts) se multiplica todo por N:
  comprar si  N*p <= suma - N*M_COMPRA
  vender  si  N*p >= suma + N*M_VENTA
y N*p = p+p -> +self -> +self (3 sumas).

Solo aritmetica entera: este archivo es la especificacion exacta que
sw/trade.s debe reproducir decision por decision.

Uso:
  python3 trade_ref.py serie.csv                 # reporte
  python3 trade_ref.py serie.csv --dump dec.txt  # + decisiones por tick (hex)
"""

import csv
import sys
from dataclasses import dataclass, field

CAJA_INICIAL = 10_000
COMISION = 5
Q_MAX = 63

N = 8
M_COMPRA = 3
M_VENTA = 2

HOLD, BUY, SELL = 0b00, 0b01, 0b10


def encode(accion, q):
    return (accion << 6) | (q & 0x3F)


def decode(byte):
    return (byte >> 6) & 0b11, byte & 0x3F


def ejecutar(caja, acciones, decision, precio):
    """Regla de la maestra. Supuesto: cantidad efectiva 0 -> sin orden ni comision."""
    accion, q = decode(decision)
    if accion == BUY:
        q = min(q, max(0, (caja - COMISION) // precio))
        if q > 0:
            return caja - q * precio - COMISION, acciones + q, True
    elif accion == SELL:
        q = min(q, acciones)
        if q > 0:
            return caja + q * precio - COMISION, acciones - q, True
    return caja, acciones, False


@dataclass
class TradeState:
    ventana: list = field(default_factory=lambda: [0] * N)
    idx: int = 0
    suma: int = 0
    llenos: int = 0
    caja: int = CAJA_INICIAL
    acciones: int = 0
    ultima: int = encode(HOLD, 0)


def decide(st, p):
    st.caja, st.acciones, _ = ejecutar(st.caja, st.acciones, st.ultima, p)

    st.suma += p - st.ventana[st.idx]
    st.ventana[st.idx] = p
    st.idx = st.idx + 1 if st.idx + 1 < N else 0
    if st.llenos < N:
        st.llenos += 1

    d = encode(HOLD, 0)
    if st.llenos == N:
        np_ = N * p
        if np_ < st.suma - N * M_COMPRA and st.caja - COMISION >= p:
            d = encode(BUY, Q_MAX)
        elif np_ > st.suma + N * M_VENTA and st.acciones > 0:
            d = encode(SELL, min(Q_MAX, st.acciones))

    st.ultima = d
    return d


def run(prices):
    st = TradeState()
    return [decide(st, p) for p in prices]


def backtest(prices, decisions):
    """decisions[k] se ejecuta al precio prices[k+1] (desfase de un tick)."""
    caja, acciones, ordenes = CAJA_INICIAL, 0, 0
    peak, max_dd = CAJA_INICIAL, 0
    vigente = encode(HOLD, 0)
    for k, p in enumerate(prices):
        caja, acciones, hubo = ejecutar(caja, acciones, vigente, p)
        ordenes += hubo
        w = caja + acciones * p
        peak = max(peak, w)
        max_dd = max(max_dd, peak - w)
        vigente = decisions[k]
    return {"patrimonio": caja + acciones * prices[-1], "ordenes": ordenes,
            "comisiones": ordenes * COMISION, "max_dd": max_dd}


def report(prices):
    nuestra = run(prices)
    estrategias = {
        "No operar": [encode(HOLD, 0)] * len(prices),
        "Comprar y mantener": [encode(BUY, Q_MAX)] * len(prices),
        f"Reversion N={N} -{M_COMPRA}/+{M_VENTA}": nuestra,
    }
    print(f"{'Estrategia':28s} {'Patrimonio':>10s} {'Ordenes':>8s} "
          f"{'Comisiones':>10s} {'Max DD':>8s}")
    for nombre, dec in estrategias.items():
        r = backtest(prices, dec)
        print(f"{nombre:28s} {r['patrimonio']:>10d} {r['ordenes']:>8d} "
              f"{r['comisiones']:>10d} {r['max_dd']:>8d}")
    return nuestra


def load_prices(path):
    with open(path, newline="") as f:
        prices = [int(row["price"]) for row in csv.DictReader(f)]
    assert all(1 <= p <= 255 for p in prices), "precio fuera de [1, 255]"
    return prices


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    decisiones = report(load_prices(sys.argv[1]))
    if "--dump" in sys.argv:
        out = sys.argv[sys.argv.index("--dump") + 1]
        with open(out, "w") as f:
            f.writelines(f"{d:02x}\n" for d in decisiones)
        print(f"decisiones -> {out}")

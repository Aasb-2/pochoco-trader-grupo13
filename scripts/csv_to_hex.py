#!/usr/bin/env python3
"""csv_to_hex.py - Convierte la serie del curso (CSV con columna 'price')
al formato que lee $readmemh en sim/tb_pochoco_soc.v (un byte hex por linea).

Uso: python3 scripts/csv_to_hex.py practica_meta.csv sim/practica.hex
"""
import csv
import sys

src, dst = sys.argv[1], sys.argv[2]
with open(src, newline="") as f:
    prices = [int(r["price"]) for r in csv.DictReader(f)]
assert all(1 <= p <= 255 for p in prices), "precio fuera de [1, 255]"
with open(dst, "w") as f:
    f.writelines(f"{p:02x}\n" for p in prices)
print(f"{len(prices)} precios -> {dst}")

#!/usr/bin/env python3
"""
profile.py - Reparte los ciclos del profiling de sim/tb_pochoco_soc.v
(lineas PROF) entre las secciones de sw/trade.s, definidas por sus etiquetas.
Las direcciones se obtienen ensamblando trade.s y leyendo la tabla de simbolos.

Uso: python3 scripts/profile.py sim/soc_log.txt sw/trade.s
     (PREFIX=riscv64-elf- si el toolchain usa otro prefijo)
"""
import os
import subprocess
import sys
import tempfile

PREFIX = os.environ.get("PREFIX", "riscv64-unknown-elf-")

SECCIONES = [
    ("poll",        "1. Esperar y leer precio"),
    ("espejo",      "2a. Espejo: decodificar orden"),
    ("upd_ventana", "2b. Media movil"),
    ("senal",       "3. Senal y decision"),
    ("escribir",    "4. Escribir DECISION"),
    ("mul6",        "mul6 (q*p)"),
    ("div6",        "div6 ((caja-5)/p)"),
    ("ventana",     None),
]


def simbolos(asm):
    with tempfile.TemporaryDirectory() as d:
        o, elf = os.path.join(d, "t.o"), os.path.join(d, "t.elf")
        subprocess.run([PREFIX + "as", "-march=rv32e", "-mabi=ilp32e", "-o", o, asm], check=True)
        subprocess.run([PREFIX + "ld", "-m", "elf32lriscv", "-Ttext=0x0", "--no-relax",
                        "-o", elf, o], check=True)
        out = subprocess.run([PREFIX + "nm", elf], check=True,
                             capture_output=True, text=True).stdout
    return {l.split()[2]: int(l.split()[0], 16) for l in out.splitlines()}


def main():
    log, asm = sys.argv[1], sys.argv[2]
    sym = simbolos(asm)
    limites = [(sym[e], n) for e, n in SECCIONES]

    prof, worst = [], ""
    for line in open(log):
        t = line.split()
        if t and t[0] == "PROF":
            prof.append((int(t[1], 16), int(t[2]), int(t[3])))
        elif t and t[0] == "WORST":
            worst = line.strip()

    tot = {n: [0, 0] for _, n in limites if n}
    for addr, c_tot, c_wst in prof:
        for (a0, n), (a1, _) in zip(limites, limites[1:]):
            if a0 <= addr < a1:
                tot[n][0] += c_tot
                tot[n][1] += c_wst
                break
        else:
            raise SystemExit(f"direccion {addr:#x} fuera de las secciones")

    s_tot = sum(v[0] for v in tot.values())
    s_wst = sum(v[1] for v in tot.values())
    print(f"\n{worst}\n")
    print(f"{'Seccion':32s} {'Todos los ticks':>17s}   {'Peor tick':>15s}")
    for n, (ct, cw) in tot.items():
        print(f"{n:32s} {ct:9d} {100 * ct / s_tot:5.1f}%   {cw:7d} {100 * cw / s_wst:5.1f}%")
    print(f"{'TOTAL':32s} {s_tot:9d} {100.0:5.1f}%   {s_wst:7d} {100.0:5.1f}%")


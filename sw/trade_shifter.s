# Copyright 2026 Universidad de los Andes.
# Licensed under the Solderpad Hardware License, Version 0.51 (the "License");
# you may not use this file except in compliance with the License.
# SPDX-License-Identifier: SHL-0.51
#
# Course: Arquitectura de Computadores (2026)
#
# Authors:
# - Grupo 13  <TODO: nombres y correos>

# trade_shifter.s — VARIANTE B' del loop de trading (seccion 3.3).
#
# IDENTICO a sw/trade.s (version solo software) salvo en dos puntos,
# marcados con "VARIANTE B'". Las decisiones son bit a bit las mismas;
# solo cambia el numero de instrucciones/ciclos en llegar a ellas:
#
#   1.senal : 8p se calcula con un unico slli en vez de 3 sumas
#             (p+p, 2p+2p, 4p+4p).
#   2. div6 : la tabla de multiplos 1p..32p (5 sw + 5 lw + 5 add) se
#             reemplaza por slli inmediatos: cada multiplo se genera en
#             registro, sin tocar memoria. Se elimina la seccion "tabla".
#
# Requiere el hardware de la variante B': rtl/ext/espino_shifter.v (SLL)
# conectado en la ALU. CON LA ALU BASE ESTE PROGRAMA ES INCORRECTO:
# slli ejecutaria ADD.
#
# Registro de cambios de ciclo (estimado, a medir con scripts/measure_cycles.py):
#   peor caso de div6: 5 lw menos (3 ciclos c/u) + 5 sw menos + 5 add menos
#   senal: 3 add -> 1 slli (2 instrucciones menos en todos los ticks)
#
# El resto (poll, espejo, upd_ventana, mul6, escribir) queda tal cual:
# mul6 no se toca porque ocupa el 0,2 % de los ciclos (profiling 3.1).

    .equ COMISION, 5
    .equ CAJA0,    10000
    .equ N,        8
    .equ UMB_C,    24
    .equ UMB_V,    16

    .section .text
    .global _start

_start:
    lui  x2, 0x80010
    addi x3, x0, 0
    lui  x6, %hi(CAJA0)
    addi x6, x6, %lo(CAJA0)
    addi x7, x0, 0
    addi x8, x0, 0
    addi x9, x0, %lo(ventana)
    addi x10, x0, 0

main_loop:
poll:
    lw   x5, 0(x2)
    andi x5, x5, 1
    beq  x5, x0, poll
    lw   x4, 4(x2)

espejo:
    andi x5, x8, 0xC0
    andi x12, x8, 0x3F
    beq  x5, x0, upd_ventana
    addi x11, x0, 0x40
    beq  x5, x11, exec_buy
    addi x11, x0, 0x80
    bne  x5, x11, upd_ventana

exec_sell:
    bge  x7, x12, 1f
    add  x12, x7, x0
1:  beq  x12, x0, upd_ventana
    jal  x1, mul6
    add  x6, x6, x13
    addi x6, x6, -COMISION
    sub  x7, x7, x12
    jal  x0, upd_ventana

exec_buy:
    add  x5, x12, x0
    jal  x1, div6
    bge  x5, x12, 2f
    add  x12, x5, x0
    jal  x1, mul6
2:  beq  x12, x0, upd_ventana
    sub  x6, x6, x13
    addi x6, x6, -COMISION
    add  x7, x7, x12

upd_ventana:
    lw   x11, 0(x9)
    sub  x3, x3, x11
    add  x3, x3, x4
    sw   x4, 0(x9)
    addi x9, x9, 4
    addi x11, x0, %lo(ventana_fin)
    bne  x9, x11, 3f
    addi x9, x0, %lo(ventana)
3:  addi x11, x0, N
    beq  x10, x11, senal
    addi x10, x10, 1

senal:
    addi x5, x0, 0
    addi x11, x0, N
    bne  x10, x11, escribir
    # VARIANTE B': 8p con un unico slli (antes: tres sumas)
    slli x13, x4, 3

    addi x14, x3, -UMB_C
    bge  x13, x14, 4f
    addi x15, x6, -COMISION
    blt  x15, x4, 4f
    addi x5, x0, 0x7F
    jal  x0, escribir

4:  addi x14, x3, UMB_V
    bge  x14, x13, escribir
    beq  x7, x0, escribir
    addi x15, x0, 63
    add  x12, x7, x0
    bge  x15, x12, 5f
    add  x12, x15, x0
5:  addi x5, x12, 0x80

escribir:
    sw   x5, 8(x2)
    add  x8, x5, x0
    jal  x0, main_loop

# mul6: x13 = x12 * x4  (0 <= x12 <= 63). Usa x14, x15.
# SIN CAMBIOS respecto de trade.s: ocupa el 0,2 % de los ciclos.
    .macro MULBIT bit
    andi x15, x12, \bit
    beq  x15, x0, 9f
    add  x13, x13, x14
9:
    .endm

mul6:
    addi x13, x0, 0
    add  x14, x4, x0
    MULBIT 1
    add  x14, x14, x14
    MULBIT 2
    add  x14, x14, x14
    MULBIT 4
    add  x14, x14, x14
    MULBIT 8
    add  x14, x14, x14
    MULBIT 16
    add  x14, x14, x14
    MULBIT 32
    jalr x0, 0(x1)

# div6: x12 = min(63, (caja-5)/p), x13 = x12 * p. Usa x11, x14, x15.
# VARIANTE B': multiplos generados con slli, sin tabla en memoria
# (antes: 5 add de encadenado + 5 sw + 5 lw). Mismo algoritmo voraz,
# mismas comparaciones, mismo resultado bit a bit.
    .macro DIVBIT bit
    add  x15, x13, x11
    blt  x14, x15, 9f
    add  x13, x15, x0
    addi x12, x12, \bit
9:
    .endm

div6:
    addi x14, x6, -COMISION
    addi x12, x0, 0
    addi x13, x0, 0
    slli x11, x4, 5
    DIVBIT 32
    slli x11, x4, 4
    DIVBIT 16
    slli x11, x4, 3
    DIVBIT 8
    slli x11, x4, 2
    DIVBIT 4
    slli x11, x4, 1
    DIVBIT 2
    add  x11, x4, x0
    DIVBIT 1
    jalr x0, 0(x1)

    .balign 4
ventana:
    .word 0, 0, 0, 0, 0, 0, 0, 0
ventana_fin:
# VARIANTE B': la tabla de multiplos ya no existe

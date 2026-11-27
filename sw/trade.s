# Copyright 2026 Universidad de los Andes.
# Licensed under the Solderpad Hardware License, Version 0.51 (the "License");
# you may not use this file except in compliance with the License.
# SPDX-License-Identifier: SHL-0.51
#
# Course: Arquitectura de Computadores (2026)
#
# Authors:
# - Grupo 13  <TODO: nombres y correos>

# trade.s — loop principal de la estrategia de trading para Espino (RV32E).
#
# Protocolo (ver rtl/pochoco_spi_slave.v):
#   SPI base         = 0x8001_0000
#     +0x00 STATUS   : bit0 = new_price (se limpia sola al leer PRICE)
#                       bit1 = cs_active
#     +0x04 PRICE    : ultimo precio recibido (8 bits utiles, en rdata[7:0])
#     +0x08 DECISION : byte que la CPU escribe; se transmite al siguiente CS
#
# Flujo por tick:
#   1. Sondear STATUS hasta ver new_price=1
#   2. Leer PRICE (eso limpia new_price)
#   3. Actualizar el estado interno del algoritmo   (TODO: seccion 3.1)
#   4. Calcular la decision                          (TODO: seccion 3.1)
#   5. Escribir DECISION
#   6. Volver a 1
#
# IMPORTANTE (ver protocolo en el enunciado): la decision que se escribe en
# el tick n la ejecuta la maestra al precio p_n, no al precio p_{n-1} que la
# origino. Si no se alcanza a escribir antes del siguiente flanco de CS_n,
# se repite la decision anterior. Mantener el camino 1->5 lo mas corto
# posible, en especial pensando en la Ronda 3 (periodo T = 0.1 ms).
#
# Registros usados (RV32E: solo x0-x15, sin shifts/mul reales — ver
# rtl/espino_core/espino_alu.v, SLL/SRL/SRA hoy caen al default y hacen ADD):
#   x2  : base SPI (0x8001_0000)
#   x3  : estado acumulado del algoritmo      (TODO: definir representacion,
#         ej. punto fijo Q?.? y que mantenga una suma acumulada en vez de
#         recalcular el promedio desde cero cada tick)
#   x4  : ultimo precio leido
#   x5  : decision calculada
#   x1, x6-x15 : libres para las necesidades del algoritmo

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
    add  x13, x4, x4
    add  x13, x13, x13
    add  x13, x13, x13

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
    .macro DIVBIT bit
    add  x15, x13, x11
    blt  x14, x15, 9f
    add  x13, x15, x0
    addi x12, x12, \bit
9:
    .endm

div6:
    add  x11, x4, x0
    sw   x11, %lo(tabla)+0(x0)
    add  x11, x11, x11
    sw   x11, %lo(tabla)+4(x0)
    add  x11, x11, x11
    sw   x11, %lo(tabla)+8(x0)
    add  x11, x11, x11
    sw   x11, %lo(tabla)+12(x0)
    add  x11, x11, x11
    sw   x11, %lo(tabla)+16(x0)
    add  x11, x11, x11
    addi x14, x6, -COMISION
    addi x12, x0, 0
    addi x13, x0, 0
    DIVBIT 32
    lw   x11, %lo(tabla)+16(x0)
    DIVBIT 16
    lw   x11, %lo(tabla)+12(x0)
    DIVBIT 8
    lw   x11, %lo(tabla)+8(x0)
    DIVBIT 4
    lw   x11, %lo(tabla)+4(x0)
    DIVBIT 2
    lw   x11, %lo(tabla)+0(x0)
    DIVBIT 1
    jalr x0, 0(x1)

    .balign 4
ventana:
    .word 0, 0, 0, 0, 0, 0, 0, 0
ventana_fin:
tabla:
    .word 0, 0, 0, 0, 0, 0


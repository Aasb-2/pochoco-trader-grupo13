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

.section .text
.global _start

_start:
    lui  x2, 0x80010          # x2 = 0x80010000 (base SPI)
    addi x3, x0, 0             # x3 = estado inicial del algoritmo
                                 # TODO: inicializar representacion de punto fijo

main_loop:
    # --- 1. Sondear STATUS hasta new_price=1 ---
poll_status:
    lw   x1, 0(x2)              # x1 = STATUS
    andi x1, x1, 1              # bit0 = new_price
    beq  x1, x0, poll_status

    # --- 2. Leer PRICE (limpia new_price) ---
    lw   x4, 4(x2)              # x4 = precio actual

    # --- 3. Actualizar estado interno ---
    # TODO (seccion 3.1): actualizar x3 con el nuevo precio x4.
    # Ejemplo de enfoque: mantener suma_acumulada en x3 y restar/sumar
    # incrementalmente en vez de recorrer una ventana completa cada tick.

    # --- 4. Calcular decision ---
    # TODO (seccion 3.1): calcular x5 a partir de x3 (y/o x4).
    # Decision de representacion: ¿que valores de x5 significan comprar /
    # vender / mantener, y como se mapean al byte DECISION del protocolo?
    addi x5, x0, 0              # placeholder: "mantener" (no operar)

    # --- 5. Escribir DECISION ---
    sw   x5, 8(x2)

    jal  x0, main_loop

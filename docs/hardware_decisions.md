# Decisiones de co-diseño de hardware (sección 3.3)

> Este documento registra, a medida que se van tomando, las decisiones de
> co-diseño pedidas por el enunciado. La idea es llenarlo en paralelo al
> trabajo, no reconstruirlo de memoria al final.

## 1. Instrucción custom vs. periférico MMIO

- **Estado:** TODO
- Instrucción custom-0: se integra al pipeline (más rápida), pero
  `rtl/espino_core/espino_decoder.v` no decodifica aún el opcode `0x0B`
  (cae a `illegal_insn_o`), y `alu_operator_o` ya usa los 16 códigos
  posibles en 4 bits — hay que ensanchar ese campo o sacar el resultado
  por un camino paralelo a la ALU.
- Periférico MMIO: más fácil de aislar (mismo patrón que
  `rtl/pochoco_periph.v` / `rtl/pochoco_spi_slave.v`), pero suma latencia
  de acceso a memoria (según `espino_load_store_unit.v`, cada LW/SW ya
  cuesta 2-3 ciclos fijos por el pipeline de 2 etapas con lectura
  síncrona).
- **Decisión final:** TODO — justificar con los números de la sección 3.

## 2. Presupuesto de LUTs/BRAM vs. ciclos ahorrados

- **Estado:** TODO
- Contexto: el target es un iCE40 **HX1K** (1.280 LUTs, 8 bloques de BRAM
  de 4 Kbit — ver `Makefile`: `--hx1k --package vq100`). El banco de
  registros de Espino ya usa 4 de los 8 bloques de BRAM
  (`rtl/espino_core/espino_register_file.v`).
- Completar tabla: LUTs usadas / LUTs disponibles, BRAM usada / BRAM
  disponible, por cada variante (ver `scripts/compare_variants.py`).

## 3. Frecuencia real por variante (PLL y en general)

- **Estado:** TODO
- No asumir que se mantiene en 25 MHz: agregar lógica puede alargar el
  camino crítico. Confirmar con la Fmax que reporta `nextpnr-ice40` para
  cada variante, y si se usa PLL (`rtl/pll/pochoco_pll.v`), confirmar que
  efectivamente cierra timing a la nueva frecuencia antes de recalcular
  la tabla de ciclos por ronda.

## 4. Definición de "operación útil" (para Ops/s)

- **Estado:** TODO
- Debe ser la misma definición para todas las variantes (ej. "una
  decisión completa por tick" o "un MAC"), para que la comparación tenga
  sentido entre ellas.

## 5. Criterio de elección de la variante final

- **Estado:** TODO
- Opciones de criterio: la que más gana en el mercado simulado, la más
  rápida (menor ciclos/tick), o la que mejor equilibra
  LUTs/ciclos/calidad de predicción. El enunciado pide esta justificación
  de forma explícita — no dejarla implícita solo en los números.

## 6. Reproducibilidad por variante

- **Estado:** TODO
- Cada variante (solo-software + cada alternativa de hardware) debe
  quedar reproducible por separado (rama o tag de git), para poder
  regenerar sus métricas sin pisar las de otra variante.

## 7. Extensión del decoder para custom-0 (si se elige esa ruta)

- **Estado:** TODO
- Nota de implementación: `rtl/espino_core/espino_decoder.v` necesita un
  nuevo caso en el `case(opcode)` para `OPCODE_CUSTOM0 = 7'h0b`, y
  probablemente un nuevo campo de selección de resultado (en paralelo a
  `alu_operator_o`, que ya está lleno) si la operación no es una simple
  variante de ALU. Documentar aquí la codificación final elegida
  (funct3/funct7 → operación) antes de tocar el decoder, para que el
  cambio sea revisable.

# Estado del proyecto — Pochoco Trader (Grupo 13)

> Resumen vivo de qué está hecho y qué falta, organizado por sección del
> enunciado (Proyecto 4). Actualizar a medida que se avance; no es un
> reemplazo de `docs/hardware_decisions.md`, que lleva el detalle de las
> decisiones de co-diseño.

## Hecho

- **Repositorio propio creado** a partir de `pochoco_soc` (base intacta,
  commit `22ea7da`), con permisos de equipo configurados.
- **Repo base leído y entendido**, incluyendo hallazgos concretos del RTL:
  - Target real: iCE40 **HX1K**, paquete `vq100` (confirmado en el
    `Makefile`).
  - El banco de registros de Espino ya usa **4 de los 8 bloques de BRAM**
    disponibles (`espino_register_file.v`).
  - Costos de ciclo por tipo de instrucción derivados del pipeline de 2
    etapas con lectura síncrona: **2 ciclos** para ALU/inmediatos/SW/
    branch no tomado, **3 ciclos** para loads y para branch tomado/JAL/
    JALR.
  - Shifts (`SLL`/`SRL`/`SRA`) decodificados pero sin efecto real: caen al
    `default` de la ALU y ejecutan como `ADD`.
  - Opcode `custom-0` (`0x0B`) no decodificado; además `alu_operator_o` ya
    usa los 16 códigos posibles de 4 bits — no queda espacio libre sin
    ensanchar el campo.
  - Protocolo SPI confirmado en `pochoco_spi_slave.v`: el byte DECISION
    que sale en una transacción es el último escrito antes del flanco de
    `CS_n` (desfase de un tick tal como describe el enunciado).
- **Scaffold de archivos creado** (ver `pochoco-trader-grupo13-scaffold.zip`
  entregado), con TODOs y decisiones pendientes ya comentadas en cada uno:
  - `sw/trade.s` — esqueleto del loop principal (sondear → leer → TODO
    actualizar estado → TODO decidir → escribir).
  - `sw/ref/trade_ref.py`, `sw/ref/generate_practice_series.py` —
    referencia Python y generador de series sintéticas, sin implementar.
  - `rtl/ext/espino_shifter.v`, `espino_mul.v`, `espino_mac.v`,
    `pochoco_movavg_periph.v` — cuatro alternativas de hardware, cada una
    con su decisión de diseño documentada en comentarios.
  - `rtl/pll/pochoco_pll.v` — wrapper placeholder del PLL.
  - `sim/tb_pochoco_soc.v`, `tb_espino_core.v`, `tb_espino_alu.v`,
    `tb_espino_shifter.v`, `tb_espino_mul.v`, `tb_pochoco_movavg_periph.v`,
    `sim/Makefile`, `sim/common/spi_master_model.v` — testbenches base,
    sin casos de prueba reales todavía.
  - `scripts/measure_cycles.py`, `amdahl.py`, `compare_variants.py` —
    utilidades de medición, con las fórmulas y costos de ciclo ya
    implementados, pero sin conectar a datos reales de simulación.
  - `docs/hardware_decisions.md` — plantilla con las 7 decisiones de
    co-diseño a resolver, todas en estado TODO.
  - `README_ADDITIONS.md` — borrador de secciones para agregar al
    `README.md` (simulación, variantes de hardware, versiones de
    herramientas).

## Por hacer

### 1. Algoritmo (sección 3.1 — 1,0 pto)
- [ ] Elegir y justificar la estrategia (media móvil / momentum /
  regresión incremental / reversión a la media).
- [ ] Implementar `decide()` y `init_state()` en `sw/ref/trade_ref.py`.
- [ ] Definir la regla para la cantidad *q*.
- [ ] Validar contra la serie de práctica oficial y comparar contra "no
  operar" y "comprar y mantener" (patrimonio final, N° de órdenes,
  comisiones, drawdown máximo).
- [ ] Confirmar que la estrategia evita multiplicación/división por un
  número arbitrario (solo Espino no lo soporta nativo).

### 2. Implementación en assembly (sección 3.2 — 0,8 pto)
- [ ] Completar los bloques TODO de `sw/trade.s` (actualizar estado,
  calcular decisión).
- [ ] Validar bit a bit contra `trade_ref.py` sobre toda la serie de
  práctica.
- [ ] Desensamblar el binario final y confirmar que no aparece ningún
  opcode de shift.
- [ ] Medir IC, ciclos, CPI real y tiempo por tick (promedio y peor caso)
  con `scripts/measure_cycles.py`, una vez que los testbenches cuenten
  de verdad.

### 3. Profiling y Ley de Amdahl
- [ ] Instrumentar los testbenches (`sim/tb_espino_core.v` y/o
  `tb_pochoco_soc.v`) para contar ciclos e instrucciones reales.
- [ ] Identificar qué parte del algoritmo consume más ciclos.
- [ ] Completar `scripts/amdahl.py` con los valores medidos (`f`, `s`) y
  calcular el speedup esperado antes de comprometerse con una variante de
  hardware.

### 4. Co-diseño de hardware (sección 3.3 — 1,2 pto)
- [ ] Decidir qué alternativa(s) de hardware implementar (ver opciones ya
  planteadas en `rtl/ext/` y `rtl/pll/`).
- [ ] Implementar la lógica real de al menos 2 alternativas (reemplazar
  los placeholders).
- [ ] Completar el testbench correspondiente a cada una.
- [ ] Correr `yosys ... stat` y `nextpnr-ice40` por variante; completar
  `scripts/compare_variants.py` con LUTs, BRAM, Fmax reales.
- [ ] Definir la métrica de "operación útil" (Ops/s) y aplicarla por
  igual a todas las variantes.
- [ ] Resolver las 7 decisiones abiertas en `docs/hardware_decisions.md`.
- [ ] Elegir la variante final y justificar el criterio explícitamente.
- [ ] Si se elige la ruta `custom-0`: editar
  `rtl/espino_core/espino_decoder.v` (no incluido en el scaffold por ser
  un archivo ya existente) para decodificar el nuevo opcode.

### 5. Integración final y validación cruzada
- [ ] Confirmar que la variante elegida cumple el presupuesto de ciclos
  de las tres rondas con el mismo programa.
- [ ] Re-correr la validación bit a bit tras cada cambio de hardware.

### 6. Conexión real y competencia (sección 3.4 — 2 pts)
- [ ] Probar la conexión real con la FPGA maestra (o confirmar con el
  curso la próxima instancia disponible).
- [ ] Definir la decisión "por defecto" segura si no se alcanza a escribir
  DECISION a tiempo.
- [ ] Generar `sw/trade.hex` y conectarlo a `tb_pochoco_soc.v` /
  `pochoco_soc.v` (`MemFile`).

### 7. README y repositorio
- [ ] Incorporar el contenido de `README_ADDITIONS.md` al `README.md`
  real y borrar el archivo borrador.
- [ ] Completar la sección de versiones de herramientas (yosys, nextpnr,
  iverilog).

### 8. Defensa
- [ ] Repasar en equipo el algoritmo, el desfase de un tick del protocolo
  SPI, el assembly y las decisiones de co-diseño — que cualquier
  integrante pueda justificarlas.

### 9. Checklist de entrega
- [ ] Repo completo: RTL + testbenches + `trade.s` + referencia + README.
- [ ] Placa lista y conectada para la competencia.

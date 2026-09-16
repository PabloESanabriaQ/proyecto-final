# 0004 — La grilla temporal es lunes a sábado, 08:00 a 22:00, en bloques de 30 minutos

**Estado:** Aceptada — 2026-09-16

## Contexto

El estado del arte (Definición Pendiente N.º 2) dejaba sin fijar la grilla base: días hábiles,
inicio y fin de jornada y unidad mínima de tiempo. El Excel de ejemplo asumía lunes a sábado,
08:00–22:00 y bloque de 60 minutos, sin registrarlo como decisión. Sin grilla no hay variables de
decisión que escribir.

Alternativas evaluadas:

- **Bloque de 60 minutos** (lo que asumía el Excel) — menos variables, modelo más chico. Se
  descarta porque excluye clases de una hora y media y arranques a la media hora, dos situaciones
  habituales que obligarían a rehacer la grilla apenas apareciera un caso real.
- **Bloque de 15 minutos** — máxima flexibilidad. Se descarta porque cuadruplica las variables
  respecto de 60 min sin que exista una clase real que empiece a los cuartos de hora.
- **Bloque de 30 minutos** — la elegida.

## Decisión

La grilla temporal es:

- **Días:** lunes a sábado (6 días). Procedencia: valor del equipo, tomado del Excel de ejemplo.
- **Jornada:** 08:00 a 22:00 (14 horas). Procedencia: valor del equipo, tomado del Excel de
  ejemplo.
- **Bloque mínimo:** 30 minutos. Procedencia: criterio propio, para admitir duraciones de 1,5 h y
  arranques a y media sin rehacer la grilla.

Resultan 28 bloques por día y 168 por semana. Toda duración de clase se expresa en bloques
enteros; una duración que no sea múltiplo de 30 minutos es un error de validación de entrada, no
un caso del solver. Estos tres valores viven en la configuración del período y son los valores por
defecto, no constantes del código.

## Consecuencias

**A favor:** cubre los casos reales conocidos; el tamaño (168 bloques) sigue siendo pequeño para
CP-SAT; la grilla es configurable por período si otra carrera tiene otra jornada.

**En contra:** el doble de posiciones de inicio que con 60 min; toda visualización y toda
validación tienen que trabajar en medias horas.

**Riesgo abierto:** que alguna carrera del escenario de múltiples carreras use una jornada o
estructura de turnos que no encaje en esta grilla. **La señal:** una carrera cuyos datos reales no
se puedan cargar sin redondear horarios. Ahí se revisa si la grilla es por período o por carrera.

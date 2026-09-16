# 0007 — Una comisión puede tener varios dictados semanales, de igual duración y en días distintos

**Estado:** Aceptada — 2026-09-16

## Contexto

El Excel de ejemplo traía `Duracion_Horas` por comisión pero no cuántas veces por semana se dicta.
Las blandas B1 (huecos entre clases consecutivas de una comisión en un día) y B3 (una comisión que
combina turnos en la semana) solo tienen sentido si una comisión tiene más de una clase semanal.
La cantidad de dictados cambia el modelo de raíz: una variable de intervalo por comisión o una por
dictado.

Alternativas evaluadas:

- **Un dictado por semana, siempre** — modelo más simple. Se descarta porque no representa la
  realidad de las materias con dos encuentros semanales.
- **Varios dictados, cualquier día, incluso el mismo** — máxima libertad. Se descarta porque dos
  dictados el mismo día equivalen en la práctica a una clase más larga, y porque pisa B1/B3.
- **Varios dictados en días distintos** — la elegida.

## Decisión

Cada comisión declara en la entrada su **cantidad de dictados semanales**, con valor por defecto
**1**. Procedencia del defecto: criterio del equipo; la mayoría de las comisiones tiene un solo
encuentro. Todos los dictados de una comisión tienen la **misma duración** (la declarada) y
ocurren en **días distintos**; esta última es una restricción dura del Proyecto A y no se relaja
en B. Cada dictado es una variable de intervalo propia en el modelo; todos los dictados de una
comisión comparten docente y tipo de aula requerido, pero el aula concreta puede diferir entre
dictados (mantenerla igual es la blanda B2, Proyecto B).

Una comisión puede tener **más de un docente** en la entrada; R5 y R6 aplican a cada uno de
ellos sobre todos los dictados de la comisión.

## Consecuencias

**A favor:** las blandas B1–B3 pasan a tener objeto; el modelo por dictado es el natural en
CP-SAT; el defecto en 1 no obliga a cargar nada nuevo para el caso común.

**En contra:** el número de intervalos crece; la validación de entrada tiene que rechazar más
dictados que días hábiles disponibles para el docente.

**Riesgo abierto:** que aparezca una comisión real con dictados de distinta duración (por ejemplo,
3 h y 2 h). **La señal:** una fila del Excel real que no se pueda cargar sin partirla en dos
comisiones. En ese caso se modifica esta decisión para admitir duración por dictado.

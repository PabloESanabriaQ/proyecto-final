# 0031 — El límite de tiempo por defecto es de 60 segundos de reloj, con búsqueda reproducible

**Estado:** Aceptada — 2026-11-27

## Contexto

HU-2.4 (AUL-46) pide que el solver corra con un límite de tiempo y distinga `INFACTIBLE` de
`TIEMPO_AGOTADO`. Falta el valor por defecto de ese límite y su procedencia (`plan-de-fases.md`,
Fase 2, definiciones pendientes; AUL-37). Además, [[0030]] exige que la misma instancia con la
misma configuración devuelva el mismo horario y deja a esta decisión los parámetros de CP-SAT que
lo garantizan. El contrato ya tiene los campos: `limite_tiempo_segundos` y `semilla` en la
configuración (`arquitectura.md` §3.1; propuesta de esquema de AUL-41), sin valor por defecto
hasta que una decisión lo fije ([[0010]]).

Medición propia, 2026-11-27, con OR-Tools 9.15 en una máquina de 4 núcleos, sobre un modelo de
prueba con la forma del de HU-2.2 (grilla de 6 días por 28 bloques, R5, exclusividad de aula, R7;
140 comisiones de 4 bloques, 45 docentes, 4 aulas; factibilidad pura):

| Configuración | Horarios distintos en 5 corridas | Tiempo de reloj | Tiempo determinista |
|---|---|---|---|
| 8 workers, semilla 42 | 1 | 3,6–3,9 s | **7,39–8,04 (varía)** |
| 8 workers, semilla 42, `interleave_search` | 1 | 4,6–5,6 s | 11,89 (igual en todas) |
| 1 worker, semilla 42 | 1 | 3,6–4,1 s | 7,75 (igual en todas) |
| 8 workers, límite de reloj de 1 s | 1 | 0,9–1,0 s | corta antes de encontrar solución |

Dos hechos salen de la tabla. Con varios workers en paralelo, el trabajo de búsqueda cambia de una
corrida a otra aunque esta vez saliera el mismo horario: la reproducibilidad no está garantizada,
solo ocurrió. Y un modelo sin función objetivo que encuentra un horario termina con el estado
`OPTIMAL` de CP-SAT, no `FEASIBLE`.

Alternativas evaluadas para el número:

- **10 segundos** — corridas rápidas en los tests. Se descarta porque deja poco margen sobre lo
  medido (4–6 s) en una máquina lenta o en el CI, y una corrida cortada da `TIEMPO_AGOTADO` en una
  instancia que sí tiene solución.
- **300 o 600 segundos** — margen de sobra para instancias grandes. Se descarta como valor por
  defecto: un test o una demostración sobre una instancia infactible que CP-SAT no logra probar
  tarda minutos en terminar, y el tamaño grande (Fase 6) todavía no se midió.
- **Sin límite** — nunca corta una búsqueda útil. Se descarta porque HU-2.4 lo exige y una corrida
  colgada bloquea la API.
- **60 segundos** — la elegida.

Alternativas evaluadas para la reproducibilidad:

- **Límite en tiempo determinista** (`max_deterministic_time`) en lugar de segundos de reloj —
  reproducible aun cuando corta. Se descarta como límite principal porque su unidad no son
  segundos, su relación con los segundos cambia según la máquina, y HU-2.4 y quien usa el sistema
  hablan de segundos.
- **Un solo worker** — reproducible y, en esta medición, igual de rápido. Se descarta porque
  renuncia al portafolio paralelo de CP-SAT, que es lo que más rinde en instancias grandes.
- **Workers en paralelo con `interleave_search`** — la elegida.

## Decisión

1. **El límite de tiempo por defecto es de 60 segundos de reloj** (`limite_tiempo_segundos = 60`),
   configurable por corrida.
   - Procedencia: criterio propio, provisional. Es más de diez veces lo que tardó el modelo de
     prueba de la tabla, que ya es más grande que el caso acotado (18 materias, AUL-43).
   - Se revisa en la Fase 6 con los tiempos medidos sobre la carrera y la universidad completas.
   - Un límite menor o igual a cero es un error de la configuración, no una corrida.

2. **Correspondencia de estados de CP-SAT** con los de la solución:
   - `OPTIMAL` o `FEASIBLE` → `FACTIBLE`.
   - `INFEASIBLE` → `INFACTIBLE`.
   - `UNKNOWN` (se agotó el límite sin encontrar horario ni probar que no existe) →
     `TIEMPO_AGOTADO`.
   - `MODEL_INVALID` es un error de programación: se lanza una excepción, no es un estado de la
     solución.

   Como el Proyecto A termina en el primer horario que encuentra ([[0030]]), en A un
   `TIEMPO_AGOTADO` nunca trae asignaciones. Qué trae `TIEMPO_AGOTADO` en el Proyecto B queda para
   sus decisiones.

3. **Parámetros de CP-SAT para la reproducibilidad de [[0030]]:**
   - `random_seed` = `semilla` de la configuración.
   - `num_workers = 8`, fijo, y no "todos los núcleos". Así el portafolio de búsqueda es el mismo
     en cualquier máquina del equipo. Procedencia: criterio propio.
   - `interleave_search = True`: los workers avanzan por turnos fijos y el trabajo de búsqueda
     queda igual entre corridas, como muestra la tabla.

4. **La semilla por defecto es 1**, el valor por defecto de `random_seed` en OR-Tools.
   Procedencia: no cambia la validez del horario, solo cuál de los horarios válidos sale, así que
   se toma el valor del propio motor.

5. **Alcance de la reproducibilidad:** está garantizada cuando la corrida termina antes del límite
   (`FACTIBLE` o `INFACTIBLE`). Si el límite de reloj corta la búsqueda, el resultado puede cambiar
   entre máquinas. Los tests de reproducibilidad usan instancias que terminan muy por debajo del
   límite.

6. **Casos borde nombrados para HU-2.4 (AUL-46):**
   - Instancia factible que termina antes del límite: `FACTIBLE`.
   - Instancia infactible que CP-SAT prueba antes del límite (por ejemplo, una comisión sin
     ningún aula donde entre): `INFACTIBLE`, no `TIEMPO_AGOTADO`.
   - Instancia que no se resuelve dentro de un límite muy chico: `TIEMPO_AGOTADO`, sin
     asignaciones y no `INFACTIBLE`.
   - Límite cero o negativo: la configuración se rechaza antes de llamar a CP-SAT.

## Consecuencias

**A favor:** el límite de 60 segundos deja un margen amplio para la Fase 2 sin que un test sobre
una instancia difícil quede minutos colgado. La reproducibilidad de [[0030]] pasa a ser
comprobable con los parámetros concretos. La correspondencia de estados evita confundir el
`OPTIMAL` de CP-SAT con algo que A no hace (optimizar).

**En contra:** `interleave_search` costó alrededor de un tercio más de tiempo de reloj en la
medición (4,6–5,6 s contra 3,6–3,9 s). Fijar 8 workers desaprovecha núcleos en una máquina más grande y sobrecarga una de
menos núcleos. La medición es de un modelo de prueba y no del modelo real.

**Riesgo abierto:** que 60 segundos no alcancen para la instancia de la universidad completa.
**La señal:** en la Fase 6, una corrida que devuelve `TIEMPO_AGOTADO` sobre una instancia que con
más tiempo resulta `FACTIBLE`. En ese caso se escribe una decisión con el número medido. Segundo
riesgo: que `interleave_search` no alcance para la reproducibilidad en alguna versión de OR-Tools.
**La señal:** el caso borde de reproducibilidad de HU-2.2 que falla de forma intermitente. En ese
caso se pasa a un solo worker para los tests y se registra en una decisión nueva.

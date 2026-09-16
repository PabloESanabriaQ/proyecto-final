# 0005 — La cantidad de alumnos de una comisión es dato de entrada y el solver elige un aula que la contenga

**Estado:** Aceptada — 2026-09-16

## Contexto

El estado del arte (Definición Pendiente N.º 3) dejaba abierto el orden entre asignación de aula
y demanda de inscripción: si la capacidad del aula asignada determina el cupo (aula → cupo) o si
el sistema parte de una demanda proyectada y busca un aula que la satisfaga (demanda → aula). R7
estaba redactada en el primer sentido ("la inscripción se cierra al alcanzarse ese límite"). El
Excel de ejemplo traía dos columnas por comisión (`Alumnos_Actuales` y `Promedio_Historico`) sin
decir cuál usa el solver.

Alternativas evaluadas:

- **Aula → cupo** — el solver asigna aulas por otros criterios y la capacidad resultante fija el
  cupo de inscripción. Se descarta porque invierte la realidad del proceso: las comisiones y su
  cantidad de alumnos se definen antes, por disponibilidad docente e histórico, y el aula tiene
  que acomodarse a eso.
- **Demanda → aula** — la elegida.

## Decisión

Cada comisión trae como **dato de entrada** su cantidad de alumnos, calculada por la institución
a partir del promedio histórico de inscriptos. El sistema **no la calcula ni la modifica**. El
solver elige para cada comisión un aula cuya capacidad sea mayor o igual a esa cantidad (R7). Si
para alguna comisión no existe aula del tipo requerido con capacidad suficiente, el problema es
infactible bajo el Proyecto A; el sobrecupo acotado es una de las relajaciones del Proyecto B
([[0010]]).

En la entrada, la comisión lleva **una sola columna** de alumnos. Las dos columnas del Excel de
ejemplo se reemplazan por esa única columna.

Las comisiones de materias optativas siguen la misma regla: si la comisión existe en la entrada,
tiene alumnos y se le asigna aula; si no está en la entrada, no se planifica.

## Consecuencias

**A favor:** el solver no toma decisiones de política académica (cuántos alumnos admitir); la
entrada es más simple; R7 queda como una comparación directa.

**En contra:** si el histórico subestima la demanda, el aula queda chica y el sistema no lo
detecta. La corrección es manual: cambiar el número y volver a correr.

**Riesgo abierto:** que en la práctica el número de alumnos no se conozca hasta después de la
inscripción, y la inscripción dependa del aula. **La señal:** que secretaría académica pida
"asignar aula y ver cuántos entran". En ese caso se revisa esta decisión, no se agrega una
excepción.

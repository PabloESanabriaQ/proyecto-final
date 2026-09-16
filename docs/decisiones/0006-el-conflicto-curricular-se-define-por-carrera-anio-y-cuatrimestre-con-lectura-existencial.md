# 0006 — El conflicto curricular se define por (carrera, año, cuatrimestre), con lectura existencial y materias compartidas en varios grupos

**Estado:** Aceptada — 2026-09-16

## Contexto

Bajo el modelo curricular ([[0001]]) hay tres cosas que el estado del arte dejaba sin cerrar:

1. **R3** (excepción a R1 cuando una materia tiene varias comisiones) admitía una lectura
   "permisiva" o una "existencial" según el modelo elegido.
2. **Definición Pendiente N.º 6:** "año y cuatrimestre" solo tiene sentido dentro de una carrera;
   cuando una materia es compartida por varias carreras, R1–R3 no decían cómo se determina el
   conflicto. El Excel de ejemplo lo cerraba por omisión con un único `Carrera_ID` por materia.
3. Cómo se combina R3 con **R4** (cada práctica asociada a una teoría).

Alternativas evaluadas:

- **Lectura permisiva de R3** — si una materia tiene más de una comisión, cualquier comisión puede
  pisarse con cualquier materia del año. Se descarta porque permite que todas las comisiones de una
  materia se pisen con todas las de otra y ningún alumno de la cohorte ideal pueda cursar ambas.
- **Conflicto por grupo de alumnos real** — determinar el conflicto entre materias compartidas a
  partir de qué alumnos las cursan en conjunto. Se descarta porque contradice [[0001]].
- **Grupo de conflicto (carrera, año, cuatrimestre) + lectura existencial** — la elegida.

## Decisión

1. **El grupo de conflicto es la terna (carrera, año, cuatrimestre).** Una materia pertenece a un
   grupo por cada carrera en la que se dicta, con el año y cuatrimestre que tiene en el plan de
   esa carrera. Una materia compartida por dos carreras pertenece a dos grupos, posiblemente con
   años distintos. En el modelo de datos, la relación materia–carrera lleva año y cuatrimestre
   (tabla `Materia_Carrera`); la materia no tiene una carrera propia.

2. **Lectura existencial de R1/R3 dentro de cada grupo.** Para cada grupo, y para cada materia del
   grupo, tiene que existir **al menos una combinación cursable** —una comisión de teoría y una de
   sus prácticas asociadas, según R4— que no se superponga en horario con al menos una combinación
   cursable de cada una de las demás materias del grupo. Dicho como lo formuló el equipo: *debe
   quedar al menos una teoría y una práctica disponible para cada carrera, lo que significa que al
   menos una de las distintas combinaciones no tiene que pisarse con el resto de las materias de
   esa carrera de ese año y cuatrimestre.*

   Casos que se derivan de esa regla:
   - Materia con una única teoría y una única práctica: su única combinación no puede pisarse con
     ninguna combinación elegida de las demás.
   - Materia teórico-práctica (sin comisión asociada): la combinación es la comisión sola.
   - Una comisión de práctica solo está obligada a no pisarse con su propia teoría (R4); con las
     demás comisiones de la misma materia puede superponerse.

3. **R2 se mantiene:** materias de años distintos del mismo cuatrimestre pueden superponerse, aun
   dentro de la misma carrera.

## Consecuencias

**A favor:** generaliza a N carreras sin cambiar la regla; expresa lo que de verdad importa (que
la cohorte pueda cursar), no un no-solapamiento total que vuelve infactibles instancias
razonables; se modela en CP-SAT con una variable booleana por combinación cursable y restricciones
de "al menos una".

**En contra:** es la restricción más costosa del modelo: el número de combinaciones crece con el
producto de comisiones por materia. Es también la más difícil de explicar a quien revisa el
horario.

**Riesgo abierto:** que la lectura existencial resulte demasiado débil en la práctica —"existe una
combinación cursable" pero es una sola y tiene 30 lugares para 200 alumnos—. **La señal:** que
secretaría académica reporte que el horario es válido pero que la mayoría de los alumnos no puede
armar su cursada. Ahí la salida es una restricción blanda en el Proyecto B que maximice la
cantidad de combinaciones cursables, no cambiar la lectura.

# 0023 — El alcance es toda la UNViMe, no una sola carrera

**Estado:** Aceptada — 2026-09-28

## Contexto

Los documentos del proyecto venían diciendo que el sistema asigna horarios y aulas "para la
carrera de Ingeniería en Sistemas de Información de la UNViMe": así arrancaban `AGENTS.md`, el
`README`, el informe de gestión, las dos propuestas y hasta la descripción de la API. El escenario
con varias carreras aparecía como una **generalización opcional** de la Fase 6, a validar si el
motor sostenía el tamaño.

Eso no es el alcance del sistema. El 2026-09-28 el equipo aclaró que **siempre fue toda la
universidad** y que la redacción de los documentos lo angostó por error, no por una decisión. Hay
que registrar la corrección porque contradice la primera línea del archivo de contexto canónico y
el encuadre de varios documentos vivos, y porque el material previo —`docs/AULERO.md`,
`docs/aulero_estado_del_arte.pdf`— también está escrito sobre el supuesto angosto.

Alternativas evaluadas:

- **Dejar el alcance en una carrera y tratar el resto como trabajo futuro.** Su punto fuerte es
  real: instancia más chica, riesgo de escalabilidad acotado, cronograma más corto, y es lo que los
  documentos ya decían. Se descarta porque **no es el problema que tiene la institución**: las
  carreras comparten edificios, aulas y docentes, de modo que un horario que sólo acomoda una
  carrera no es publicable hasta que se resuelva el resto, y el aula que este sistema le asigna a
  una comisión de ISI es la misma que otra carrera necesita a la misma hora. El recorte produce un
  resultado que no se puede poner en producción.
- **Resolver cada carrera por separado y reparar después los conflictos de recursos compartidos.**
  Su punto fuerte es que da instancias chicas y paraleliza. Se descarta **como definición del
  alcance**, no como técnica: partir el problema es una estrategia de resolución —sigue disponible,
  en la línea del *Fix-and-Optimize* que ganó la ITC2019, y así lo contempla la Fase 6—, pero el
  enunciado del problema sigue siendo uno solo. Confundir las dos cosas es lo que llevó a la
  redacción angosta.
- **Toda la UNViMe como alcance, con validación incremental** — la elegida.

## Decisión

1. **El sistema asigna horarios y aulas para toda la UNViMe: todas sus carreras.** Procedencia:
   indicación del equipo del 2026-09-28, que declara que es el alcance original del proyecto.

2. **Es una sola asignación, no una por carrera.** Las carreras comparten edificios, aulas y
   docentes, así que el problema no se puede partir por carrera sin dejar de resolverlo.
   Procedencia: deducción de los recursos compartidos, ya reconocida en [[0006]] ("generaliza a N
   carreras sin cambiar la regla") y en [[0003]] (que toma la instancia de N carreras como la
   prueba de fuego del motor).

3. **La carrera de Ingeniería en Sistemas de Información sigue siendo el escalón de validación
   incremental**, no el alcance. El orden se mantiene: caso de prueba (juguete) → ISI completa →
   universidad completa. Procedencia: criterio propio declarado; conserva el plan de fases vigente
   y el principio de fases con capacidad demostrable, en vez de dejar el proyecto sin entregable
   hasta que escale.

4. **El modelo de datos no cambia.** El grupo de conflicto ya es (carrera, año, cuatrimestre) a
   través de `Materia_Carrera`, con `Materia` sin carrera propia, y una materia compartida
   pertenece a todos los grupos que correspondan ([[0006]]). El solver tampoco cambia: nunca supo
   de qué carrera venía una comisión. Procedencia: ancla en [[0006]] y en la estructura de
   `arquitectura.md` §2.

5. **Lo que esta decisión no resuelve, y queda como definición pendiente de la Fase 6:**

   - **Cuántos edificios.** Si las carreras se reparten en más de un edificio o sede, hace falta
     una restricción que hoy no existe en R1–R11: un docente no puede tener dictados consecutivos
     en edificios distintos sin tiempo de traslado. Sin el dato no se modela.
   - **Calendario y jornada por carrera.** El equipo confirma que hay carreras con **materias
     anuales** y/o **jornada distinta**. Eso activa el riesgo abierto que [[0004]] ya había
     anticipado con su señal, y obliga a decidir si la grilla y los turnos son por período o por
     carrera ([[0011]]), y cómo se representa una materia anual en un período cuatrimestral.

   Ninguna de las dos se decide acá: falta el dato de secretaría académica, y un número o una
   regla sin procedencia es una decisión postergada disfrazada de decisión tomada.

6. **Los documentos vivos se corrigen; el material histórico se deja marcado.** `AGENTS.md`, el
   `README`, `informe-de-gestion.md`, `arquitectura.md`, `plan-de-fases.md`, las dos propuestas y
   la descripción de la API pasan a decir el alcance real. `docs/AULERO.md` y
   `docs/aulero_estado_del_arte.pdf` quedan como están: ya están marcados como material histórico
   y `docs/README.md` dice qué de cada uno quedó superado.

## Consecuencias

**A favor:** el proyecto resuelve el problema que la institución tiene en lugar de un recorte suyo,
y el resultado es publicable; el valor institucional del trabajo crece sin rediseñar nada, porque
el modelo ya estaba pensado para N carreras; desaparece la ambigüedad entre "alcance" y "estrategia
de resolución" que produjo la redacción angosta; y las dos propuestas se corrigen **antes** de
presentarse, cuando el cambio no cuesta nada (el §9.1 del reglamento ata el informe a la propuesta
aprobada, y después de la protocolización esto saldría por escrito del Profesor Guía a la
Comisión).

**En contra:** la instancia objetivo pasa a ser la grande, así que el riesgo de escalabilidad deja
de ser un dato a documentar y se vuelve riesgo central del proyecto; la dependencia de datos
institucionales se multiplica por la cantidad de carreras, y ya no alcanza con la secretaría de una
sola; aparecen dos definiciones pendientes que antes no existían (edificios, calendario por
carrera); y las materias anuales pueden forzar a revisar [[0004]] y [[0011]], que estaban cerradas.

**Riesgo abierto:** que CP-SAT no resuelva la instancia universitaria completa en un tiempo
utilizable. **La señal:** que la Fase 6 no cierre con la instancia completa dentro del límite de
tiempo configurado, ni siquiera con una primera solución. En ese caso no se recorta el alcance: se
escribe la decisión de descomponer —resolver por subconjuntos de carreras y reparar los conflictos
de aulas y docentes compartidos en una segunda pasada— y se mide contra la instancia completa. El
alcance declarado del sistema no vuelve a una sola carrera; lo que cambia es cómo se lo resuelve.

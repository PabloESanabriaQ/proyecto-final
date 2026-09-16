# Aulero UNViMe — Informe de gestión

> Documento vivo. Se actualiza al cerrar cada fase.
> Público: quien evalúa el trabajo (tribunal, tutores, secretaría académica) o va a usar el
> sistema. Sin código ni jerga técnica; eso va en `arquitectura.md`.
>
> **Última actualización:** 2026-09-16 — Fase 0 en curso: el repositorio ya exige revisión
> automática antes de subir código y aprobación de otra persona antes de integrarlo; falta que
> el primer cambio pase por esa aprobación y enlazar el tablero de seguimiento.

## El problema

Cada cuatrimestre, la carrera de Ingeniería en Sistemas de Información de la UNViMe tiene que
asignar a cada comisión de cada materia un día, un horario y un aula. Hoy eso se hace a mano.
Cuesta días de trabajo, y aun así aparecen choques: dos materias del mismo año a la misma hora,
un docente en dos lugares, una comisión en un aula donde no entran sus alumnos, o un laboratorio
ocupado por una clase que no lo necesita mientras otra que sí lo necesita se queda sin él. Cuando
se suman otras carreras que comparten el edificio, los docentes y las aulas, el problema deja de
ser manejable a mano.

## Qué hace

Aulero recibe los datos del cuatrimestre —materias, comisiones, docentes y sus horarios no
disponibles, aulas con su tipo y capacidad, bloques ya ocupados por otras carreras— y produce un
horario semanal que cumple todas las reglas obligatorias. Si no existe ningún horario que las
cumpla todas, lo dice, y señala qué reglas entran en conflicto. En una segunda versión, cuando no
hay horario perfecto, ofrece el mejor posible indicando exactamente qué reglas se violaron y
dónde, y mejora la calidad del horario (clases compactas, misma aula, mismo turno, preferencias
de los docentes).

## Quiénes lo usan

| Rol | Qué hace con el sistema |
|---|---|
| **Planificador** (secretaría académica / coordinación de carrera) | Carga los datos del período por Excel o por formulario, lanza la optimización, revisa el horario, registra excepciones para semanas puntuales, compara alternativas y publica el horario oficial. |
| **Docente** | Consulta su horario semanal. En la segunda versión, indica preferencias horarias. |
| **Estudiante** | Consulta el horario de su carrera y año. |
| **Equipo de optimización** | Ajusta el modelo, corre instancias de prueba, compara resultados entre versiones. |

## Decisiones de negocio

Las que no estaban definidas y hubo que resolver. El detalle y las alternativas descartadas están
en el [registro de decisiones](decisiones/README.md).

- **Se planifica por plan de estudios, no por inscripción real** (0001). Dos materias chocan si
  están en el mismo año y cuatrimestre de una carrera. El sistema no garantiza que un alumno que
  recursa materias de años distintos no tenga choques.
- **El trabajo se divide en dos** (0002): primero un sistema que encuentra horarios que cumplen
  todas las reglas o informa que no existen; después uno que, cuando no existen, propone el mejor
  posible y explica qué se violó.
- **La cantidad de alumnos de cada comisión es un dato que carga la institución**, calculado del
  histórico; el sistema busca un aula donde entren (0005). No decide cupos.
- **Cuando una materia tiene varias comisiones, alcanza con que exista una combinación
  cursable** (una teoría con su práctica) que no choque con las demás materias del año (0006). No
  hace falta que todas las combinaciones estén libres de choques.
- **Una materia compartida por varias carreras** respeta las reglas de cada carrera en la que se
  dicta (0006).
- **Una comisión puede dictarse más de una vez por semana**, siempre en días distintos (0007).
- **Una clase puede venir con día, horario o aula ya fijados** por la institución; el sistema los
  respeta y acomoda el resto (0015).
- **El horario es semanal y se repite todo el cuatrimestre.** Para una semana puntual se puede
  pedir otro tipo de aula (por ejemplo, un laboratorio para una actividad especial) manteniendo
  día y hora; el sistema busca un aula libre o avisa que no hay (0008).
- **Cada comisión requiere un tipo de aula exacto**, salvo que declare alternativas. Una teoría
  no ocupa un laboratorio a menos que lo pida (0009).
- **En la segunda versión solo se relajan tres reglas**: choques entre materias del mismo año,
  sobrecupo del aula (con un tope) y uso de un aula de tipo distinto al pedido. Nunca se relaja
  que un docente esté en dos lugares, que una práctica pise su teoría, que un docente dé clase
  cuando no puede, ni que se use un aula reservada por otra carrera (0010).
- **La jornada es de lunes a sábado, de 8 a 22, en bloques de media hora** (0004). Los turnos
  arrancan como 8–13, 13–18 y 18–22, y se ajustan cuando la institución los defina (0011).

## Estado de avance

| Fase | Qué permite hacer | Estado |
|---|---|---|
| 0 | El equipo trabaja sobre un repositorio con revisión automática y humana obligatoria. | **En curso.** Hoy: nadie puede subir código sin que un revisor automático lo apruebe; el repositorio verifica cada cambio y la rama principal rechaza todo lo que no tenga verificación en verde y aprobación de otra persona. Falta: que el primer cambio pase por esa aprobación, y enlazar el tablero de seguimiento (Jira). |
| 1 | Subir el Excel del período, ver los errores de carga y los datos cargados en la web. | No iniciada |
| 2 | Obtener un primer horario del caso de prueba (9 materias) que respeta docentes, aulas, capacidad y bloqueos. | No iniciada |
| 3 | Obtener un horario que además respeta las reglas del plan de estudios, o saber por qué no existe. | No iniciada |
| 4 | Lanzar la optimización desde la web y ver el horario por aula, docente y carrera/año. | No iniciada |
| 5 | Cargar y corregir datos por formulario; registrar excepciones de aula por semana y ver la semana. | No iniciada |
| 6 | Resolver la carrera completa y un escenario con varias carreras que comparten recursos. | No iniciada |
| 7 | Cuando no hay horario perfecto, obtener el mejor posible con la lista de reglas violadas. | No iniciada |
| 8 | Mejorar la calidad del horario, tener en cuenta preferencias docentes, comparar corridas y publicar una. | No iniciada |

## Fuera de alcance

Lo que el sistema no hace y no va a hacer en esta versión:

- **Inscripción real de alumnos y recursantes.** No se cargan alumnos; ver decisión 0001.
- **Asignar docentes a comisiones.** Las comisiones llegan con su docente ya definido (R9).
- **Otras técnicas de optimización** (algoritmos genéticos, aprendizaje por refuerzo). Se
  descartaron; ver decisión 0003.
- **Cambiar día u horario de una clase para una semana puntual.** Solo se cambia el aula; ver
  decisión 0008.
- **Distancias o traslados entre edificios.** Un aula es un aula, esté donde esté.
- **Gestión de inscripciones, correlatividades o cupos.** Son datos de entrada o quedan fuera.
- **Planificar más de un período a la vez.**

## Ejemplo narrado

*(Se escribe cuando exista la Fase 1: el recorrido del planificador desde el Excel hasta el
horario publicado, actualizado a medida que las fases lo hagan avanzar.)*

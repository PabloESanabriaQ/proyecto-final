# Propuesta de Proyecto Final — Proyecto A

> Borrador para presentar según el §5.a del Reglamento de Proyecto Final (Resol. 12/2023).
> Los corchetes son datos que faltan. El cronograma está en meses relativos a la aprobación.
>
> **Última actualización:** 2026-09-16 — borrador inicial.

## Tema

**Aulero UNViMe: factibilidad de la asignación de horarios y aulas de la carrera de Ingeniería
en Sistemas de Información mediante programación por restricciones (CP-SAT).**

## Alumno

[Nombre y apellido, legajo, DNI, correo electrónico, teléfono]

## Profesor Guía

[Apellido y nombre, cargo docente, CV resumido, nota de aceptación]

## Profesor Asesor (si corresponde)

[Especialista en optimización / investigación operativa; apellido y nombre, cargo, universidad
de origen, CV resumido, nota de aceptación]

## Descripción del proyecto

Cada cuatrimestre, la carrera de Ingeniería en Sistemas de Información de la UNViMe asigna a
cada comisión de cada materia un día, un horario y un aula. Hoy se hace a mano: cuesta días de
trabajo y aun así aparecen choques entre materias del mismo año, docentes en dos lugares a la
vez, comisiones en aulas donde no entran sus alumnos, o laboratorios ocupados por clases que no
los necesitan. Cuando otras carreras comparten edificio, docentes y aulas, el problema deja de
ser manejable a mano.

Este problema es, en la bibliografía, el *University Course Timetabling Problem* (UCTP),
NP-hard, con una tendencia reciente y documentada hacia los métodos exactos (programación
entera y por restricciones) en instancias reales de tamaño comparable a la nuestra.

El proyecto construye y valida un **modelo exacto en OR-Tools CP-SAT** que, dada la
configuración de un cuatrimestre (materias con su ubicación en el plan, comisiones con docentes
y cantidad de alumnos, docentes con sus franjas no disponibles, aulas con tipo y capacidad,
bloqueos externos), determina **si existe un horario que cumple todas las restricciones
obligatorias** y lo produce; y cuando no existe, **explica qué conjunto de restricciones lo
impide**. El motor se entrega como un paquete de software independiente, con un validador que
verifica cualquier solución sin depender del solver, una interfaz de línea de comandos y un
formato de instancia publicado, sobre el que se apoyan una aplicación web (desarrollada en una
Práctica Profesional Supervisada) y un segundo Proyecto Final que estudia la relajación de
restricciones cuando el problema es infactible.

## Objetivo general

Determinar la factibilidad de la asignación de horarios y aulas de la carrera de Ingeniería en
Sistemas de Información de la UNViMe bajo un conjunto formalizado de restricciones obligatorias,
mediante un modelo de programación por restricciones (CP-SAT) que produzca un horario válido o
un diagnóstico de infactibilidad, validado sobre instancias reales.

## Objetivos específicos

1. Formalizar el problema: entidades del dominio, grilla temporal, y las restricciones
   obligatorias R1–R11 con sus precisiones (modelo curricular; grupo de conflicto por carrera,
   año y cuatrimestre con lectura existencial; dictados múltiples; tipos de aula exactos con
   alternativas declaradas; dictados pre-fijados).
2. Definir y publicar el formato de instancia normalizada y de solución (esquema JSON) que
   comparten el motor, la aplicación web y el Proyecto B.
3. Implementar el modelo de restricciones de recursos (docentes, aulas, capacidad, tipo,
   bloqueos, grilla) y resolver el caso de prueba (primer cuatrimestre de 1.º y 2.º año, nueve
   materias).
4. Implementar las restricciones curriculares (R1–R4) con la lectura existencial de
   combinaciones cursables y resolver el caso de prueba completo.
5. Construir un validador independiente que verifique R1–R11 sobre cualquier solución, en el
   espíritu de los validadores oficiales de las competencias ITC.
6. Implementar el diagnóstico de infactibilidad: ante un problema sin solución, informar un
   conjunto mínimo de restricciones en conflicto con las entidades involucradas.
7. Escalar a la carrera completa y a un escenario de varias carreras que comparten docentes y
   aulas; medir tamaño de instancia, tiempo de resolución y tiempo hasta la primera solución;
   documentar el límite práctico del modelo y, si hace falta, una estrategia de descomposición.
8. Analizar los resultados de factibilidad sobre las instancias reales y elaborar el informe
   final.

## Alcance y limitaciones

**Incluye:** el paquete `solver` (modelo A, validador, CLI, formato de instancia y solución,
instancias de referencia con su resultado esperado), su documentación técnica, y el análisis de
factibilidad sobre las instancias reales.

**No incluye (y por qué):**

- Restricciones blandas, relajación de restricciones, penalizaciones ni comparación de
  calidad: son el objeto del Proyecto B.
- La aplicación web (importación de datos, base de datos, API, visualización): la desarrolla la
  Práctica Profesional Supervisada sobre el formato publicado por este proyecto.
- Inscripción real de alumnos, recursantes y correlatividades en el modelo: se planifica por
  plan de estudios (modelo curricular), asumiendo una cohorte ideal.
- Asignación de docentes a comisiones: las comisiones llegan armadas como dato de entrada.
- Otras técnicas de resolución (metaheurísticas, aprendizaje por refuerzo): se descartaron a
  favor de un único motor exacto.
- Cambios de día u horario para semanas puntuales: solo se contempla cambiar el aula.

**Limitaciones:** el modelo no garantiza un horario libre de choques para alumnos que cursan
materias de años distintos; la calidad de la solución (compactación, estabilidad de aula) no se
optimiza en este proyecto; los datos reales dependen de que la institución los entregue.

## Metodología

Desarrollo por fases, cada una con una capacidad demostrable, casos borde nombrados con su
test, y documentación al cierre. Registro de decisiones de diseño con alternativas descartadas.
Validación independiente de cada solución. Instancias de referencia versionadas con resultado
esperado, como conjunto de regresión. Repositorio compartido con revisión de código automática y
por pares antes de integrar. Detalle en `docs/plan-de-fases.md`, `docs/decisiones/` y
`docs/convenciones.md` del repositorio.

## Resultados esperados

- Paquete `aulero-solver` con el modelo A, validador y CLI, instalable y probado.
- Esquema publicado de instancia y solución.
- Conjunto de instancias de referencia (caso de prueba, ISI completa, multi-carrera) con su
  resultado y tiempos.
- Informe final con la formalización del problema, el diseño del modelo, los resultados de
  factibilidad y el análisis de escalabilidad.

## Cronograma tentativo (12 meses desde la aprobación)

| Meses | Actividad | Fase del plan | Entregable |
|---|---|---|---|
| M1–M2 | Formalización final del problema; formato de instancia y solución; datos del caso de prueba. Base común con el Proyecto B. | 1.5, 2.5 | Esquema JSON publicado; instancia del juguete |
| M2–M4 | Modelo de recursos (grilla, R5–R8, R11, un aula por bloque); validador de recursos; CLI. | 2 | `solve` y `validar` sobre el juguete: factible, cero violaciones |
| M4–M7 | Restricciones curriculares R1–R4 con lectura existencial; dictados múltiples; pre-fijados; validador completo; diagnóstico de infactibilidad. | 3 | Juguete completo resuelto o diagnosticado; casos borde con test |
| M7–M9 | Instancia real de ISI completa; escenario multi-carrera; métricas de tamaño y tiempo; estrategia de descomposición si hace falta. | 6 | Tabla de tiempos; instancias de referencia con regresión |
| M9–M10 | Experimentación y análisis de factibilidad; soporte al Proyecto B para la comparación A vs B. | 6 | Capítulo de resultados |
| M10–M12 | Redacción del informe final; correcciones del Profesor Guía; preparación de la defensa. | — | Informe según §9 del reglamento |

Riesgos y márgenes: el plazo reglamentario para el informe es de 18 meses, lo que deja seis de
margen sobre este cronograma. El riesgo principal es la disponibilidad de los datos reales
(M7); si se demoran, la Fase 6 se hace primero con un escenario sintético del mismo tamaño.

## Lugar de desarrollo

Universidad Nacional de Villa Mercedes, Escuela de Ingeniería y Ciencias Ambientales. Los datos
del cuatrimestre los provee la secretaría académica de la carrera.

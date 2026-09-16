# Propuesta de Proyecto Final — Proyecto B

> Borrador para presentar según el §5.a del Reglamento de Proyecto Final (Resol. 12/2023).
> Los corchetes son datos que faltan. El cronograma está en meses relativos a la aprobación.
>
> **Última actualización:** 2026-09-16 — borrador inicial.

## Tema

**Aulero UNViMe: relajación de restricciones y calidad de solución en la asignación de horarios
y aulas universitarias — horarios óptimos cuando no existe un horario perfecto.**

## Alumnos

[Nombre y apellido, legajo, DNI, correo electrónico, teléfono] × 2

## Profesor Guía

[Apellido y nombre, cargo docente, CV resumido, nota de aceptación]

## Profesor Asesor (si corresponde)

[Especialista en optimización / investigación operativa; apellido y nombre, cargo, universidad
de origen, CV resumido, nota de aceptación]

## Descripción del proyecto

La asignación de horarios y aulas de una carrera (*University Course Timetabling Problem*,
UCTP) se modela habitualmente con un conjunto de restricciones obligatorias que un horario
debe cumplir. En la práctica, con aulas escasas, docentes con disponibilidad acotada y materias
del mismo año que compiten por las mismas franjas, es frecuente que **no exista ningún horario
que cumpla todas las reglas a la vez**. Un sistema que en ese caso solo responde "infactible"
no le sirve a quien tiene que publicar un horario el lunes.

Este proyecto extiende el modelo exacto de programación por restricciones del Proyecto A
—que determina si existe un horario válido para la carrera de Ingeniería en Sistemas de
Información de la UNViMe— con dos capacidades:

1. **Relajación controlada:** una lista cerrada de restricciones obligatorias (choques
   curriculares entre materias del mismo año, sobrecupo del aula dentro de un tope, uso de un
   tipo de aula distinto al pedido) se convierte en restricciones con **holgura medible**. El
   sistema encuentra el horario que **minimiza las violaciones ponderadas** y reporta
   exactamente qué regla se violó, dónde y cuánto. Las reglas físicas y contractuales (un docente
   en dos lugares, una práctica pisando su teoría, un docente fuera de su disponibilidad, un aula
   reservada por otra carrera) nunca se relajan.
2. **Calidad de solución:** con las violaciones fijadas en su mínimo, un segundo nivel de
   optimización mejora el horario según criterios deseables: compactación de las clases de una
   comisión, estabilidad de aula, continuidad de turno y preferencias horarias de los docentes.

El resultado es un motor que siempre entrega un horario acompañado de su "costo" en reglas
violadas, un reporte comparativo entre el modelo estricto y el relajado sobre las mismas
instancias reales, y la posibilidad de guardar, comparar y publicar corridas alternativas desde
la aplicación web desarrollada en una Práctica Profesional Supervisada.

## Objetivo general

Obtener horarios de mayor calidad para la carrera de Ingeniería en Sistemas de Información de
la UNViMe cuando el problema es infactible bajo el modelo de restricciones obligatorias,
mediante la relajación controlada de un conjunto acotado de restricciones con holguras
ponderadas y un segundo nivel de optimización de restricciones deseables, evaluando
comparativamente el resultado frente al modelo estricto sobre instancias reales.

## Objetivos específicos

1. Definir formalmente qué restricciones son relajables y por qué, cómo se mide cada violación
   (holgura por instancia de restricción) y cuáles no se relajan nunca.
2. Diseñar e implementar el modelo B en CP-SAT: variables de holgura, primer nivel de
   optimización (mínimo de violaciones ponderadas) y segundo nivel (restricciones deseables B1
   compactación, B2 estabilidad de aula, B3 continuidad de turno, y preferencias docentes), con
   pesos como dato de entrada y con procedencia documentada.
3. Extender el validador independiente para confirmar las violaciones reportadas por el solver:
   ni una más, ni una menos.
4. Garantizar la coherencia entre modelos: sobre una instancia factible bajo el modelo A, el
   modelo B devuelve todas las holguras en cero y un horario válido bajo A.
5. Incorporar la gestión de corridas múltiples: distintos pesos sobre una misma instancia,
   comparación lado a lado y diferencias entre corridas, y publicación de una como horario
   oficial (en conjunto con la aplicación web).
6. Realizar la experimentación comparativa A vs B sobre las instancias de referencia (caso de
   prueba, ISI completa, multi-carrera): estado, tiempo, violaciones por regla, valor de cada
   criterio de calidad.
7. Elaborar una recomendación para la institución sobre pesos y tope de sobrecupo a partir de
   los resultados, y el informe final.

## Alcance y limitaciones

**Incluye:** el modelo B dentro del paquete `solver` (holguras, dos niveles, blandas,
preferencias docentes), la extensión del validador, el reporte de violaciones y métricas de
calidad, la lógica de comparación de corridas, la experimentación comparativa y su análisis.

**Base común con el Proyecto A (declarada, no reclamada como aporte propio):** el formato de
instancia y solución, el modelo de restricciones de recursos, el validador de restricciones
duras y la CLI. Este proyecto participa de su construcción en los primeros meses y la extiende
después; el aporte propio de cada proyecto se distingue por módulo y por historial del
repositorio.

**No incluye (y por qué):**

- La interfaz de usuario para lanzar corridas, ver violaciones en la grilla, cargar preferencias
  docentes, comparar y publicar: la desarrolla la Práctica Profesional Supervisada sobre los
  formatos que este proyecto define.
- Las restricciones curriculares en su versión estricta (R1–R4) y el diagnóstico de
  infactibilidad: son del Proyecto A; este proyecto las consume y las relaja.
- Inscripción real de alumnos, asignación de docentes, otras técnicas de resolución: fuera de
  alcance de todo el sistema (modelo curricular, comisiones como entrada, un solo motor).
- Los valores definitivos de pesos y tope de sobrecupo: los fija la institución; el proyecto los
  trata como entrada y entrega una recomendación fundamentada.

**Limitaciones:** la comparación es entre dos modelos sobre el mismo motor, no contra otra
técnica; los pesos por defecto son criterio declarado del equipo hasta que la institución los
valide; una parte del cronograma depende de que el Proyecto A entregue la formulación
curricular (ver riesgos).

## Metodología

Desarrollo por fases con capacidad demostrable, casos borde con test nombrado y documentación
al cierre; registro de decisiones con alternativas descartadas y procedencia de cada número;
validación independiente de cada solución; experimentación sobre instancias de referencia
versionadas; repositorio compartido con revisión de código automática y por pares. Detalle en
`docs/plan-de-fases.md`, `docs/decisiones/` (en particular 0010: lista cerrada, holguras y dos
niveles) y `docs/convenciones.md` del repositorio.

## Resultados esperados

- Modelo B integrado en `aulero-solver`, con validador extendido y reporte de violaciones.
- Tabla comparativa A vs B sobre las instancias de referencia.
- Recomendación de pesos y tope de sobrecupo para la institución, con su fundamento.
- Informe final con el diseño de la relajación, la experimentación y las conclusiones.

## Cronograma tentativo (12 meses desde la aprobación)

| Meses | Actividad | Fase del plan | Entregable |
|---|---|---|---|
| M1–M3 | Base común con el Proyecto A: formato de instancia y solución, modelo de recursos, validador, CLI. En paralelo, diseño del marco de holguras (qué se relaja, cómo se mide, dos niveles) y de los formatos de violaciones y métricas. | 1.5, 2 | Base común funcionando sobre el juguete; decisión 0010 refinada con las medidas de cada holgura |
| M3–M6 | Modelo B sobre la base de recursos: holguras de R7 (sobrecupo con tope) y R8 (tipo no declarado), primer nivel; blandas B1–B3 y preferencias docentes, segundo nivel; validador extendido. | 7 (parcial), 8 (parcial) | Juguete con un aula menos: horario con violaciones listadas y confirmadas; instancia factible: holguras en cero |
| M6–M8 | Integración de la formulación curricular del Proyecto A: holguras de R1/R3 sobre combinaciones cursables; corridas múltiples y comparación (formatos para la aplicación web). | 7, 8 | Modelo B completo; comparación de corridas |
| M8–M10 | Experimentación comparativa A vs B sobre ISI completa y multi-carrera; ajuste de pesos; recomendación para la institución. | 7.4, 8 | Tabla comparativa; capítulo de resultados |
| M10–M12 | Redacción del informe final; correcciones del Profesor Guía; preparación de la defensa. | — | Informe según §9 del reglamento |

Riesgos y márgenes: el plazo reglamentario de 18 meses deja seis de margen. El riesgo principal
es la dependencia de la formulación curricular del Proyecto A (prevista para M7 en su
cronograma): por eso el marco de holguras se construye primero sobre las restricciones de
recursos, que no dependen de A, y la relajación curricular se integra en M6–M8. Si A se demora,
este proyecto puede avanzar con una formulación curricular simplificada propia para no bloquear
la experimentación, y sustituirla al integrar.

## Lugar de desarrollo

Universidad Nacional de Villa Mercedes, Escuela de Ingeniería y Ciencias Ambientales. Los datos
del cuatrimestre y los criterios de ponderación los provee la secretaría académica de la
carrera.

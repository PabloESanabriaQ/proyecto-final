# 0002 — El trabajo se divide en Proyecto A (restricciones duras) y Proyecto B (relajación y calidad) sobre la misma instancia, API y frontend

**Estado:** Aceptada — 2026-09-16
**Modificada por:** [[0020]] — el reglamento limita cada Proyecto Final a dos personas, así que
A y B se presentan como dos Proyectos Finales (A: 1 persona, B: 2) que avanzan **en paralelo**
sobre una base común, en vez de A primero y B después. La división y lo que comparten siguen
vigentes. Leer junto con 0020.

## Contexto

`docs/AULERO.md` establece que el problema (UCTP para ISI-UNViMe) se divide en "2 proyectos" que
siguen siendo el mismo problema con hipótesis de partida distintas. El estado del arte (Anexo
A.1) proponía otra partición: Fase 1 con motor exacto y Fase 2 con una metaheurística comparativa.
Había que fijar cuál de las dos particiones organiza el trabajo, porque define qué es "terminado"
para cada mitad y cómo se reparte el equipo.

Alternativas evaluadas:

- **Un solo proyecto con duras y blandas desde el inicio** — un único modelo con función
  objetivo. Se descarta porque mezcla dos preguntas distintas ("¿existe horario?" y "¿cuál es el
  mejor cuando no existe?") y no deja un entregable defendible a mitad de camino.
- **Fase exacta + fase metaheurística (Anexo A del PDF)** — comparar CP-SAT contra un algoritmo
  genético. Se descarta en [[0003]].
- **Proyecto A duras / Proyecto B relajación** — la elegida.

## Decisión

El trabajo se organiza como dos proyectos sobre **la misma instancia, el mismo dominio, la misma
API y el mismo frontend**, con **modelos de optimización distintos**:

- **Proyecto A:** estudiar la factibilidad del UCTP bajo el conjunto de restricciones duras
  R1–R11 (con las precisiones de [[0006]], [[0007]], [[0008]], [[0009]]). Su salida es un horario
  válido o un diagnóstico de infactibilidad.
- **Proyecto B:** estudiar cómo la relajación de determinadas restricciones duras y su
  incorporación como penalizaciones permite obtener soluciones cuando el problema es infactible
  bajo A, y cómo mejorar la calidad con las restricciones blandas. Qué se relaja y cómo está en
  [[0010]]. Las blandas B1–B3 del estado del arte, las preferencias horarias de los docentes y la
  gestión de múltiples corridas comparables pertenecen al Proyecto B.

A se construye primero; B se apoya en el modelo, los datos y la infraestructura de A.

## Consecuencias

**A favor:** A es un entregable completo y demostrable por sí mismo; B tiene un capítulo
comparativo natural (A vs. B sobre la misma instancia) sin necesidad de una segunda técnica; el
equipo de aplicación (PPS) trabaja contra una única API para ambos.

**En contra:** el Proyecto B no tiene un comparador externo (otra técnica); su evidencia es
interna al modelo. Dos modelos sobre un mismo paquete exigen disciplina para no duplicar código.

**Riesgo abierto:** que A resulte factible en todas las instancias reales y el Proyecto B pierda
su motivación de "cuando el problema es infactible". **La señal:** que la instancia completa
(Fase 6 del plan) se resuelva factible sin esfuerzo. En ese caso B se sostiene igual por la parte
de calidad (blandas y comparación), pero su redacción cambia y hay que actualizar esta decisión.

# 0009 — El tipo de aula requerido es exacto, salvo alternativas declaradas explícitamente por la comisión

**Estado:** Aceptada — 2026-09-16

## Contexto

R8 define que cada comisión requiere un tipo de aula tomado de un catálogo abierto. No decía si
"requiere GENERAL" significa exactamente GENERAL o cualquier aula que sirva, ni si un laboratorio
puede alojar una teoría. Sin esto, el solver no sabe qué aulas son candidatas para cada comisión.

Alternativas evaluadas:

- **Matriz de compatibilidad global entre tipos** ("INFORMATICA puede alojar GENERAL") — una sola
  tabla, aplicable a todas las comisiones. Se descarta como regla general porque en la práctica
  no es deseable que una teoría ocupe un laboratorio, y una matriz global lo permitiría para
  todas.
- **Tipo exacto, sin alternativas** — el más rígido. Se descarta porque hay comisiones que
  legítimamente aceptan más de un tipo.
- **Tipo exacto salvo alternativas declaradas por la comisión** — la elegida.

## Decisión

Una comisión solo puede asignarse a un aula cuyo tipo sea **el requerido** por la comisión, **o
uno de los tipos alternativos** que la comisión declare explícitamente en la entrada. Sin
alternativas declaradas, el tipo es exacto. Un laboratorio no aloja una teoría a menos que la
teoría lo declare como alternativa.

En el Proyecto A, todo tipo declarado (requerido o alternativo) es igualmente válido. En el
Proyecto B ([[0010]]) el uso de un tipo alternativo puede penalizarse, y el uso de un tipo no
declarado es una de las relajaciones posibles de R8.

El mecanismo exacto en la entrada (lista de tipos alternativos por comisión) se fija en la fase
que implemente la carga de comisiones; ver `docs/plan-de-fases.md`.

## Consecuencias

**A favor:** la regla es local a la comisión y no exige mantener una matriz; el catálogo de
tipos sigue siendo abierto (R8).

**En contra:** hay que cargar las alternativas comisión por comisión; una alternativa
"institucional" (todas las teorías aceptan aula magna) se repite en cada fila.

**Riesgo abierto:** que las alternativas se repitan tanto que convenga expresarlas por tipo.
**La señal:** que más de la mitad de las comisiones de un tipo declaren la misma alternativa. Ahí
se registra una decisión que agregue compatibilidad por tipo como defecto, sin quitar la
declaración por comisión.

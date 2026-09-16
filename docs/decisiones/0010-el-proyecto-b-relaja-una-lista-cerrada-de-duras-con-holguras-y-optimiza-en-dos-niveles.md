# 0010 — El Proyecto B relaja una lista cerrada de restricciones duras mediante holguras y optimiza en dos niveles

**Estado:** Aceptada — 2026-09-16

## Contexto

[[0002]] define el Proyecto B como "relajar determinadas restricciones e incorporarlas como
penalizaciones". No decía cuáles, ni cómo se mide la violación, ni cómo se combina eso con las
restricciones blandas B1–B3 (Definición Pendiente N.º 5 del estado del arte). El equipo pensaba
"ponderar la posibilidad de relajación" y pidió una recomendación. Sin esto el Proyecto B no tiene
definición operativa.

Alternativas evaluadas:

- **Todas las duras relajables, con pesos** — máxima generalidad. Se descarta porque varias
  restricciones son físicas o contractuales: un docente en dos aulas a la vez (R5), una práctica
  pisando su propia teoría (R4), un docente en una franja en la que no puede estar (R6), un aula
  bloqueada por otra carrera (R11). Relajarlas produce horarios inválidos, no de menor calidad.
- **Una sola suma ponderada de violaciones de duras y blandas** — un solo objetivo. Se descarta
  porque mezcla magnitudes distintas: un choque curricular no se compensa con diez clases más
  compactas, y elegir pesos que lo garanticen es frágil.
- **Pesos sin holguras explícitas** (penalizar en el objetivo directamente) — se descarta porque
  no deja saber cuántas veces y dónde se violó cada regla, que es exactamente lo que el capítulo
  comparativo necesita reportar.
- **Lista cerrada + holguras + dos niveles** — la elegida.

## Decisión

1. **Lista cerrada de duras relajables:** R1/R3 (choque curricular entre combinaciones cursables
   del mismo grupo, [[0006]]), R7 (sobrecupo del aula, con un tope) y R8 (uso de un tipo de aula
   no declarado, [[0009]]). **No se relajan nunca:** R4, R5, R6, R11, la grilla ([[0004]]) ni "un
   dictado por día" ([[0007]]). La no-disponibilidad horaria del docente (R6) es dura en A y en B;
   las **preferencias** horarias del docente son una blanda del Proyecto B, distinta de R6.

2. **Cada relajación se modela con una variable de holgura** por instancia de la restricción
   (por par de combinaciones en conflicto, por comisión con sobrecupo, por comisión con tipo no
   declarado). La solución reporta el valor de cada holgura: qué se violó, dónde y cuánto.

3. **Optimización en dos niveles:** primero se minimiza la suma ponderada de holguras de duras
   relajadas; con ese resultado fijado, se optimiza la suma ponderada de blandas (B1
   compactación, B2 estabilidad de aula, B3 continuidad de turno, preferencias docentes). Se
   implementa como dos corridas encadenadas de CP-SAT, la segunda con la primera cota como
   restricción. Los **pesos son datos de entrada** del sistema, con valores por defecto.

4. **Los números que faltan** —tope de sobrecupo, pesos por defecto de cada holgura y de cada
   blanda— **no están decididos**: se fijan en las fases del Proyecto B con una procedencia
   escrita (dato de secretaría académica, o criterio propio declarado). No se ponen valores
   provisorios en el código sin registrarlos.

5. Una instancia factible bajo A tiene, bajo B, todas las holguras en cero y un horario válido
   bajo A. Esa es la prueba de coherencia entre los dos modelos.

## Consecuencias

**A favor:** el Proyecto B produce, además de un horario, un reporte de violaciones por regla que
es directamente el material del capítulo comparativo; los pesos se ajustan sin tocar el modelo;
la separación en niveles hace que un choque curricular nunca se "compre" con calidad.

**En contra:** dos corridas por optimización; más variables (una holgura por instancia de
restricción relajable); cuatro grupos de pesos que hay que explicar.

**Riesgo abierto:** que la lista cerrada deje afuera la restricción que de verdad vuelve
infactible la instancia real. **La señal:** que el diagnóstico de infactibilidad del Proyecto A
(Fase 3) señale sistemáticamente una restricción que no está en la lista. En ese caso se escribe
una decisión que modifique esta lista, con el argumento de por qué esa violación sigue
produciendo un horario usable.

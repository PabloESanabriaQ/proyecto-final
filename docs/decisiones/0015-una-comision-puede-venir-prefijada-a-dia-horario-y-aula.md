# 0015 — Una comisión puede venir pre-fijada a día, horario y/o aula como dato de entrada

**Estado:** Aceptada — 2026-09-16

## Contexto

En la práctica es habitual que algunas comisiones tengan el horario o el aula decididos de
antemano (un docente externo con un único horario posible, un laboratorio reservado por
convenio). Ningún documento previo lo mencionaba: no estaba ni dentro ni fuera del alcance. Sin
esto, el planificador tendría que "engañar" al sistema con no-disponibilidades y bloqueos para
forzar el resultado. La definición estaba prevista como pendiente de la Fase 3; el equipo decidió
tomarla ahora.

Alternativas evaluadas:

- **Fuera de alcance** — simular la fijación con no-disponibilidades del docente y bloqueos del
  aula. Se descarta porque es indirecto, frágil (hay que bloquear todo lo demás) y no expresa la
  intención.
- **Fijar solo el aula, o solo el horario** — se descarta porque el costo de admitir ambos es el
  mismo.
- **Entrada opcional en la comisión, por dictado** — la elegida.

## Decisión

Cada dictado de una comisión puede traer, de forma **opcional e independiente**, un **día**, un
**bloque de inicio** y/o un **aula** pre-fijados. Lo que viene fijado es una restricción dura en
el Proyecto A y en el Proyecto B (no se relaja): el solver fija esas variables y resuelve el
resto. Lo que no viene fijado lo decide el solver como siempre.

La validación de entrada verifica que lo pre-fijado sea coherente por sí solo: dentro de la
grilla, aula existente y del tipo requerido o alternativo ([[0009]]), capacidad suficiente
([[0005]]), sin chocar con una no-disponibilidad del docente ni con un bloqueo del aula. Si lo
pre-fijado hace infactible el resto, el diagnóstico de infactibilidad lo nombra.

## Consecuencias

**A favor:** expresa una situación real sin trucos; en CP-SAT cuesta una igualdad por variable
fijada; reduce el espacio de búsqueda.

**En contra:** más columnas en la entrada; un pre-fijado incoherente con los demás pre-fijados
solo se detecta al resolver, no al cargar.

**Riesgo abierto:** que se use para fijar tantas comisiones que el sistema deje de optimizar.
**La señal:** una instancia real con más de la mitad de los dictados pre-fijados. Ahí no cambia
la decisión, pero sí la conversación con la institución sobre qué quiere del sistema.

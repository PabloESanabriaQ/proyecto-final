# 0026 — El Proyecto A es factibilidad pura, sin función objetivo, con resultado reproducible

**Estado:** Aceptada — 2026-11-24

## Contexto

El plan de la Fase 2 deja pendiente si el modelo del Proyecto A busca **cualquier** horario que
cumpla R1–R11 o si lleva un objetivo trivial de desempate (por ejemplo, minimizar el bloque de
fin más tardío) para que la solución sea reproducible y "razonable" a la vista
(`plan-de-fases.md`, Fase 2, definiciones pendientes; AUL-38). Sin esto no se puede empezar HU-2.2
(AUL-45): con objetivo o sin él cambian el estado que devuelve el solver, cuándo termina una
corrida y qué se mide.

Lo que ya está fijado y condiciona la respuesta:

- La propuesta del Proyecto A excluye la calidad de la solución: "la calidad de la solución
  (compactación, estabilidad de aula) no se optimiza en este proyecto"; las blandas son objeto del
  Proyecto B (`propuestas/proyecto-a.md`, alcance y limitaciones).
- El Proyecto B optimiza las blandas en un segundo nivel, después de minimizar las holguras
  ([[0010]], punto 3), y la prueba de coherencia entre los modelos es que una instancia factible
  bajo A tiene, bajo B, todas las holguras en cero ([[0010]], punto 5).
- La propuesta mide "tiempo de resolución y tiempo hasta la primera solución" (objetivo
  específico 7), y el contrato prevé una `semilla` en `Configuracion` (`arquitectura.md` §3.1).

Alternativas evaluadas:

- **Objetivo de desempate "minimizar el bloque de fin más tardío"** — da horarios más
  compactos y más presentables. Se descarta por tres razones: es una forma de compactación, que la
  propuesta reserva al Proyecto B (B1), y metería en A una parte del trabajo de B que después no
  se podría comparar limpiamente; convierte cada corrida en una optimización, de modo que el
  solver ya no termina al encontrar el primer horario sino al probar el óptimo o al agotar el
  tiempo, y el resultado depende del límite de tiempo; y no garantiza reproducibilidad por sí
  solo, porque puede haber muchos horarios con el mismo valor óptimo.
- **Objetivo lexicográfico que fija un único horario** (por ejemplo, ordenar las asignaciones y
  minimizar en ese orden) — reproducible por construcción. Se descarta porque el costo es alto
  para lo que aporta: un objetivo grande sobre todas las variables, que empeora justo la métrica
  de escalabilidad que el Proyecto A tiene que reportar en la Fase 6.
- **Factibilidad pura sin control de reproducibilidad** — lo más simple. Se descarta porque dos
  corridas sobre la misma instancia podrían devolver horarios distintos: el validador y los tests
  de integración no tendrían una salida estable contra la cual comparar, y la regresión de las
  instancias de referencia sería frágil.
- **Factibilidad pura con resultado reproducible** — la elegida; es además lo que recomendaba el
  plan.

## Decisión

1. **El modelo del Proyecto A no tiene función objetivo.** CP-SAT busca un horario que cumpla
   todas las restricciones obligatorias y termina en cuanto lo encuentra, o cuando prueba que no
   existe, o cuando se agota el límite de tiempo. Los estados posibles siguen siendo `FACTIBLE`,
   `INFACTIBLE` y `TIEMPO_AGOTADO` (`arquitectura.md` §3.1); A no reporta valor objetivo.

2. **El resultado es reproducible:** la misma instancia con la misma `Configuracion` (incluida la
   `semilla`) devuelve el mismo horario, en cualquier máquina del equipo. La semilla tiene un
   valor por defecto y se puede cambiar por corrida.
   - Procedencia: criterio propio. Hace falta para que la regresión de las instancias de
     referencia y los tests de integración comparen contra una salida estable.
   - El valor por defecto de la semilla no afecta la validez del horario, solo cuál de los
     horarios válidos sale. Se fija en el código de HU-2.2 como constante con nombre, con un
     comentario que cite esta decisión.
   - Una semilla fija no alcanza para la reproducibilidad: la búsqueda en paralelo y un límite
     de tiempo de reloj pueden cambiar el horario de una corrida a otra. Los parámetros de CP-SAT
     que la garantizan los define AUL-37 (límite de tiempo) junto con su número, y se verifican
     con el caso borde del punto 4.

3. **Lo "razonable a la vista" no es objetivo de A.** Si un horario factible de A se ve mal
   (huecos largos, clases dispersas), eso es material para el capítulo comparativo A frente a B,
   no un defecto de A.

4. **Caso borde nombrado para HU-2.2 (AUL-45):** dos corridas de `solve` sobre la misma instancia
   y la misma configuración devuelven asignaciones idénticas. Se suma a los casos borde de la
   historia en `plan-de-fases.md` y en la issue.

## Consecuencias

**A favor:** A queda dentro de su alcance aprobado y la comparación A frente a B es limpia (A no
optimiza nada de lo que B optimiza). Cada corrida termina en la primera solución, que es lo que
mide la propuesta y lo más rápido posible, y eso favorece la escalabilidad de la Fase 6. La
regresión de las instancias de referencia es estable.

**En contra:** el horario de A puede verse poco prolijo y hay que explicarlo en las
demostraciones. La reproducibilidad puede obligar a correr CP-SAT con menos paralelismo del
disponible y, por lo tanto, más lento. El horario de referencia depende de la semilla y de la
versión de OR-Tools: actualizar OR-Tools puede cambiar el horario esperado de las instancias de
referencia, aunque siga siendo válido.

**Riesgo abierto:** que la reproducibilidad cueste demasiado tiempo en las instancias grandes.
**La señal:** en la Fase 6, que la corrida reproducible sobre la universidad completa tarde
claramente más que la misma corrida con búsqueda paralela libre. En ese caso se escribe una
decisión nueva que separe dos modos (reproducible para tests y regresión, rápido para
producción), sin tocar el punto 1. Segundo riesgo: que la secretaría académica no acepte un
horario factible pero desprolijo como resultado del Proyecto A. **La señal:** que lo pida en la
validación de la Fase 6. En ese caso el pedido se atiende con el Proyecto B, no agregando un
objetivo a A.

# 0003 — CP-SAT es el único motor de resolución; se descartan el algoritmo genético y el aprendizaje por refuerzo

**Estado:** Aceptada — 2026-09-16

## Contexto

El estado del arte (`docs/aulero_estado_del_arte.pdf`, Anexo A) proponía un enfoque en dos fases:
motor exacto con OR-Tools CP-SAT y, en paralelo, un algoritmo genético con DEAP como comparación,
con aprendizaje por refuerzo como posible extensión de cierre. `docs/AULERO.md` fija Python con
CP-SAT como tecnología y reorganiza el trabajo en Proyecto A / Proyecto B ([[0002]]), sin decir
explícitamente qué pasa con la metaheurística. Había que cerrar esa contradicción.

Alternativas evaluadas:

- **CP-SAT + algoritmo genético comparativo (DEAP)** — replica el capítulo comparativo que aparece
  en la mayoría de los antecedentes regionales. Se descarta porque el equipo decidió concentrar el
  esfuerzo en un solo motor y obtener el capítulo comparativo de la contraposición A vs. B, y
  porque la bibliografía reciente (ITC2019, Sección 1.3 del PDF) muestra que en instancias del
  tamaño de la real los enfoques exactos superan a las metaheurísticas puras.
- **Aprendizaje por refuerzo** — el ángulo más original respecto de la bibliografía regional, pero
  el que más infraestructura de entrenamiento exige y menos antecedentes tiene para validar
  resultados. Se descarta por costo; el propio PDF lo recomendaba solo como extensión.
- **Solo CP-SAT** — la elegida.

## Decisión

El único motor de resolución del proyecto es **OR-Tools CP-SAT**, en Python, para el Proyecto A y
para el Proyecto B. No se implementa algoritmo genético ni aprendizaje por refuerzo. El capítulo
comparativo del trabajo es A contra B sobre las mismas instancias ([[0002]], [[0010]]).

## Consecuencias

**A favor:** un solo modelo que mantener; primitivas nativas para el problema (no solapamiento,
intervalos opcionales, capacidad acumulada); diagnóstico de infactibilidad con supuestos
(*assumptions*) que el Proyecto B necesita; menos superficie para cuatro personas.

**En contra:** sin comparador externo, no se puede afirmar que CP-SAT sea "mejor que" otra técnica
para esta instancia; solo que resuelve. Si CP-SAT no escala a la instancia de N carreras, no hay
un plan B ya construido.

**Riesgo abierto:** que la instancia completa no se resuelva en tiempo aceptable. **La señal:** que
en la Fase 6 del plan el solver agote el límite de tiempo sin respuesta sobre la instancia real.
La salida prevista no es otra técnica sino descomposición (resolver por carrera y reparar los
recursos compartidos, línea "Fix-and-Optimize" del PDF), que se registraría como nueva decisión.

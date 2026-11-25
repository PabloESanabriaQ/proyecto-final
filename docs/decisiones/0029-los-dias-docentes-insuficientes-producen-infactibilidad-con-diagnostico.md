# 0029 — Los días docentes insuficientes producen infactibilidad con diagnóstico

**Estado:** Propuesta — 2026-11-24; pendiente de revisión con los integrantes del equipo.

**Propone modificar:** [0007](0007-una-comision-puede-tener-varios-dictados-semanales-en-dias-distintos.md),
solo la clasificación de una entrada con más dictados que días disponibles del docente.
Conserva la obligación de dictar en días distintos y la disponibilidad dura de
[0010](0010-el-proyecto-b-relaja-una-lista-cerrada-de-duras-con-holguras-y-optimiza-en-dos-niveles.md).

> No está aceptada ni implementada. No modifica todavía 0007 ni cierra el conflicto con el
> plan de Fase 3. El título expresa el comportamiento propuesto, no una aprobación del equipo.

## Contexto

Las consecuencias de 0007 piden rechazar una entrada con más dictados que días disponibles
del docente. El plan de Fase 3 espera que una comisión con dos dictados y un docente
disponible un solo día produzca `INFACTIBLE`, con diagnóstico de R6 y 0007. Ambas reglas
describen el mismo impedimento, pero le dan respuestas distintas.

Esta propuesta, surgida de la revisión de AUL-41 y solicitada por Nico para discutirla con
el equipo, distingue la forma de los datos de la existencia de un horario que los satisfaga.

Alternativas para la revisión:

| Opción | Ventaja | Costo |
|---|---|---|
| **Recomendada: `INFACTIBLE` con diagnóstico** | Explica que condiciones válidamente expresadas no se pueden cumplir juntas; coincide con el caso del plan | Hay que representar el impedimento en el diagnóstico y probarlo en A y B |
| **Alternativa más viable: error de validación de entrada** | Mantiene la indicación de 0007 y detecta el problema antes de resolver | El caso no aparece como infactibilidad; debe ajustarse el plan y el usuario recibe un error de carga |

Se recomienda la primera porque el Proyecto A busca encontrar un horario o explicar por qué
no existe. Una disponibilidad limitada puede reflejar correctamente la realidad, sin ser un
error de quien carga los datos. La alternativa de validación temprana es viable si el equipo
prefiere tratar estos impedimentos evidentes como datos a corregir antes de una corrida.
Ninguna opción se presenta como aprobada o descartada.

## Decisión propuesta

1. Una instancia estructuralmente válida no se rechaza al cargarla por insuficiencia de días
   docentes. La corrida devuelve `INFACTIBLE` y explica el conflicto entre la cantidad de
   dictados, la disponibilidad docente (R6) y la obligación de días distintos (0007).
2. Esto aplica a A y B. B no puede relajar R6 ni colocar varios dictados de una comisión en
   el mismo día; no hay una alternativa con holguras para este impedimento.
3. Se puede detectar el impedimento antes de invocar CP-SAT si existe una comprobación
   concluyente. En ese caso se conserva la respuesta `INFACTIBLE` y su justificación. No es
   necesario agotar una búsqueda para demostrar algo ya comprobado.
4. Se conservan los errores de estructura: referencias inexistentes, duraciones mal formadas
   y cantidad de dictados que supera la cantidad de días habilitados del período, según el
   contrato propuesto en 0027. La disponibilidad particular del docente se trata por separado.
5. El diagnóstico debe identificar la comisión, los docentes afectados y las condiciones
   incompatibles. Su formato exacto y la garantía de minimalidad corresponden a la Fase 3;
   este borrador no los da por implementados ni definidos.

Ejemplo del caso borde de Fase 3: una comisión requiere dos dictados semanales y su docente
solo está disponible los martes. La propuesta devuelve `INFACTIBLE` en ambos modelos,
explicando que los encuentros deben ocurrir en días distintos y solo hay un día disponible.
El número dos procede de ese caso del plan; martes es un día ilustrativo, no un valor fijo.

## Consecuencias

**A favor:** el diagnóstico explica una imposibilidad real sin presentar necesariamente los
datos como mal cargados; A y B mantienen la misma respuesta para restricciones irrelajables.
Se conserva el comportamiento esperado por el caso borde del plan.

**En contra:** requiere mantener el diagnóstico incluso si el impedimento se detecta antes
del modelo. Si se usa una comprobación previa, debe respetar la duración y la disponibilidad
de todos los docentes y no declarar infactibilidad por una aproximación insuficiente.

**Riesgo abierto:** que el diagnóstico resulte menos útil que un mensaje inmediato de carga,
o que duplique comprobaciones sin aportar claridad. **La señal:** que las revisiones del
equipo o las pruebas con planificadores muestren esa dificultad. En ese caso se evalúa la
alternativa de error de entrada, dejando explícito el ajuste del plan.

Para aceptar esta propuesta, el equipo debe acordar el cambio en las consecuencias de 0007
y su reflejo en 0027. Hasta entonces, el conflicto documental sigue abierto.

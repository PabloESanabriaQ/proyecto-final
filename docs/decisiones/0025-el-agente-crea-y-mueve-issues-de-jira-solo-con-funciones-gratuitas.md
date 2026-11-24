# 0025 — El agente crea y mueve las issues de Jira, y solo con funciones del plan gratuito

**Estado:** Aceptada — 2026-11-13
**Modifica:** 0024 — el agente también crea issues, no solo mueve su estado; y queda acotado a las
herramientas del MCP de Atlassian que funcionan en el plan Free de Jira.

## Contexto

La [[0024]] dejó al agente moviendo estado y asignación desde hechos de git, y descartó "todo
automático, incluida la creación de issues" por el riesgo de llenar Jira de issues que el resto del
equipo no reconoce, y porque el MCP no puede borrar.

El 2026-11-13, al armar el plan para recuperar el atraso del cronograma (las propuestas ahora
arrancan en agosto de 2026 y la etapa 1 quedó a medias), hacían falta 21 issues nuevas: los epics
de las Fases 2 y 7, sus definiciones pendientes, sus historias y una tarea de cierre. El equipo
pidió que las cree el agente y que el agente les cambie el estado, con una condición: **no hay
presupuesto**, así que solo se usa lo que Jira ofrece gratis, y lo que no se pueda hacer gratis lo
hace el equipo a mano.

Lo que se comprobó antes de decidir, sobre el proyecto AUL (plan Free, team-managed):

- El 2026-09-30 el agente ya había creado por MCP las issues AUL-25 a AUL-33, con subtareas.
- El 2026-11-13 creó AUL-34 a AUL-54: dos epics, tareas y historias colgadas de su epic con
  `parent`, con etiquetas; editó títulos, descripciones, padre y asignación; y transicionó
  estados (`41` sobre AUL-8 y AUL-24, `21` sobre AUL-54). Todo respondió sin errores de licencia.
- El MCP expone además herramientas que dependen de Rovo o de otros productos de Atlassian
  (búsqueda Rovo `search`/`fetch`, Teamwork Graph, Compass), que pueden requerir un plan pago y
  que nada de este flujo necesita.

Alternativas evaluadas:

- **Mantener la 0024 tal cual: el agente pregunta antes de cada creación.** Su punto fuerte es que
  ninguna issue aparece sin que una persona la vea. Se descarta porque el equipo delegó la creación
  de forma explícita, y porque la guarda que importa ya existe en otro lado: una Historia se
  escribe primero en `plan-de-fases.md` (0024, punto 6), así que el agente no inventa capacidades;
  solo pasa a Jira lo que el plan ya dice.
- **Que el equipo cree y mueva todo a mano.** Su punto fuerte es que no depende de ningún agente
  ni conector. Se descarta por lo que ya midió la 0024: lo manual se olvida, y el tablero mostró
  durante semanas como pendiente trabajo entregado (AUL-8 seguía *En revisión* el 2026-11-13 con
  sus PRs mergeados desde septiembre).
- **Pagar un plan de Jira o usar las funciones de Rovo.** Darían búsqueda semántica y contexto
  cruzado entre issues, PRs y commits. Se descarta por presupuesto: el equipo no tiene plata para
  esto, y nada del flujo lo necesita.
- **El agente crea y mueve, solo con herramientas del plan gratuito** — la elegida.

## Decisión

1. **El agente crea las issues de AUL** —epics, historias, tareas y subtareas— **y les mueve el
   estado** por el MCP de Atlassian. *Procedencia: pedido del equipo el 2026-11-13.* Para crear
   rige lo que la 0024 ya fija para el trabajo no planificado: una Historia nueva va primero a
   `plan-de-fases.md`; las Tareas y las definiciones pendientes pueden entrar directo. Cada issue
   creada se anota en `docs/jira/README.md`.

2. **Solo se usan herramientas del MCP que funcionan en el plan Free de Jira:** buscar por JQL,
   leer, crear, editar, comentar, transicionar y enlazar issues, y consultar metadatos de proyectos,
   tipos de issue y cuentas. **No se usan** `search` ni `fetch` (búsqueda Rovo), ni
   `getTeamworkGraphContext`, `getTeamworkGraphObject` o `addTeamworkGraphContext`, ni las
   herramientas de Compass. *Procedencia: restricción presupuestaria del equipo, 2026-11-13; la
   lista permitida es la que se usó sin errores ese día (ver Contexto).* Ante la duda sobre si
   una herramienta es paga, no se usa y se pregunta.

3. **Lo que el MCP no puede hacer gratis lo hace el equipo a mano**, y el agente lo dice en una
   línea en vez de buscar un rodeo. Hoy eso es **borrar una issue**, que el MCP no expone. Si una
   llamada falla por licencia o por plan, se trata igual. *Procedencia: deducción del punto 2.*

4. **Los estados siguen saliendo de hechos de git**, con todas las reglas de la 0024 y de
   `convenciones.md` §7: *Finalizada* solo desde un merge, no se retrocede, el epic lo cierra su
   tarea `cierre`. Esta decisión no cambia cuándo se mueve una issue; cambia quién la crea.

## Consecuencias

**A favor:** las issues de una fase existen en Jira apenas el plan las tiene, sin depender de que
alguien se siente a cargarlas; el tablero deja de atrasarse respecto del repo; y el costo en dinero
es cero.

**En contra:** una issue creada por error no se puede borrar desde el agente, y corregirla cuesta
un clic de una persona; la creación queda del lado de quien tenga Claude Code con el conector de
Atlassian, igual que el movimiento de estado en la 0024, así que el beneficio sigue siendo desigual
entre los cuatro; y la lista de herramientas permitidas depende de lo que Atlassian incluya en el
plan Free, que puede cambiar sin aviso.

**Riesgo abierto:** que el agente cree issues que el equipo no reconoce o no quería. **La señal:**
que en una misma fase el equipo tenga que renombrar, mover de epic o cerrar como "no corresponde"
más de una issue creada por el agente. En ese caso se vuelve a la creación con confirmación de la
0024 para esa clase de issue.

**Segundo riesgo abierto:** que una herramienta de la lista permitida pase a requerir un plan pago.
**La señal:** una llamada que antes funcionaba devuelve un error de licencia o de plan. Se deja de
usar esa herramienta, esa operación pasa a hacerse a mano, y se actualiza el punto 2 con una
decisión nueva.

Modifica la [[0024]]; se apoya en [[0014]] (la aprobación humana antes del merge, que sigue siendo
la puerta de *Finalizada*).

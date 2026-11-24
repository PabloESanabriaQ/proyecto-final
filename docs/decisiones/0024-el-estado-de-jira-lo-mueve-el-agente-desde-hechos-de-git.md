# 0024 — El estado de Jira lo mueve el agente desde hechos de git, y el trabajo no planificado entra al plan antes que a Jira

**Estado:** Aceptada — 2026-09-30

## Contexto

Las 20 issues de las Fases 0 y 1 se cargaron a mano el 2026-09-16 desde `docs/jira/fases-0-y-1.csv`,
y todo lo que pasa después de esa carga es manual: mover el estado cuando alguien empieza, asignar,
y abrir las issues que el plan no previó. Lo manual se pierde, y hay una medición de cuánto.

**El PR #1 se mergeó el 2026-09-22**, con CI verde y la aprobación de otra persona. Ocho días
después, al 2026-09-30, las historias que ese PR entregaba siguen sin moverse: `AUL-7`, `AUL-8` y
`AUL-10` están en *En revisión* y `AUL-9` en *En curso*, con su trabajo en `main`. El epic de la
Fase 0 y su tarea de cierre también siguen *En curso*. Nadie hizo nada mal: simplemente nadie entró
a Jira después de mergear, y el tablero muestra como pendiente trabajo que está entregado.

A eso se suma que **ninguna issue del proyecto tiene subtareas**: una historia como `HU-1.3`, con
veinte casos borde nombrados, no muestra en qué punto está mientras se desarrolla.

Hay tres huecos distintos: no hay regla para clasificar el trabajo que el plan no contempla; no hay
granularidad por debajo de la historia; y el estado se mueve cuando alguien se acuerda.

El material previo no dice nada de esto. `plan-de-fases.md` §"Cómo cargar esto en Jira" fija la
estructura (un epic por fase, una historia por `HU-N.M`) pero no quién la mantiene ni cuándo.

Alternativas evaluadas:

- **Un recordatorio en el hook de pre-push.** `.githooks/pre-push` emitiría una línea no bloqueante
  cuando la rama dice `AUL-14` y la issue sigue en *Tareas por hacer*. Su punto fuerte es real: el
  hook ya corre en la máquina de todos y no depende de que el agente se acuerde. Se descarta porque
  para emitir ese recordatorio el hook tiene que **consultar Jira**, y eso mete una llamada de red
  —que puede colgarse— en la puerta de calidad que [[0016]] puso para bloquear pushes malos. El hook
  hoy corre lint, tests y la revisión del agente; agregarle una dependencia externa lo empeora. Si
  la desincronización resulta ser un problema real, esto se agrega encima sin rehacer nada.
- **Un comando propio (`aulero-jira`) contra la API REST de Jira.** Sincronizaría sin depender del
  agente, igual para las cuatro personas y para los tres agentes de [[0018]]. Su punto fuerte es que
  es el único camino que no depende de qué herramienta usa cada uno. Se descarta por costo: un token
  de API por persona guardado en algún lado, un subsistema nuevo que mantener y testear, y duplica
  lo que el MCP de Atlassian ya hace. Es el camino correcto para un equipo de veinte; para cuatro
  personas y ocho fases, el costo de las credenciales supera al problema que resuelve.
- **Solo una sección de convenciones, sin skill.** Es lo que la metodología de skills pide para una
  convención de proyecto: va al archivo de instrucciones, no a una skill. Su punto fuerte es que
  sirve a los tres agentes por igual y no hay nada que mantener aparte. Se descarta **por el
  disparo**: `AGENTS.md` es un puntero y `convenciones.md` no se carga sola en cada conversación, así
  que la regla se aplica cuando alguien se acuerda de leerla — que es exactamente el problema que
  esta decisión viene a resolver.
- **Todo automático, incluida la creación de issues.** Se descarta: Jira es compartido, y el riesgo
  es llenarlo de issues que nadie pidió y que los otros tres integrantes no reconocen. Además el MCP
  **no expone borrado de issues**, así que una issue creada por error se corrige a mano.
- **El agente mueve estado y asignación desde hechos verificables de git, y pregunta antes de crear**
  — la elegida.

## Decisión

1. **El estado y la asignación de una issue de AUL los mueve el agente desde hechos verificables de
   git**, no desde lo que se dijo en la conversación: la rama con la clave, el PR abierto, el PR
   mergeado. *Procedencia: criterio propio declarado el 2026-09-30.* La conversación no sirve como
   disparador porque no queda registro de ella y porque el agente que la tuvo no es el que va a leer
   la issue después.

2. **Los estados son los cuatro del proyecto** — *Tareas por hacer* (`10000`), *En curso* (`10001`),
   *En revisión* (`10002`), *Finalizada* (`10003`) — y las transiciones `11`, `21`, `31` y `41`.
   *Procedencia: leídos de la API del proyecto AUL el 2026-09-30 (`getTransitionsForJiraIssue` sobre
   `AUL-9`).* No son una elección: son lo que el proyecto tiene.

3. ***Finalizada* sale únicamente del merge de un PR.** *Procedencia: deducción.* Es el único
   movimiento caro de deshacer y el único que ya tiene una puerta humana detrás: la aprobación de
   otra persona que exige [[0014]]. Entrar a *En curso* o a *En revisión* es barato de corregir.

4. **El agente no retrocede un estado por su cuenta.** Si la issue está más avanzada que el hecho,
   avisa. *Procedencia: criterio propio declarado.* Única excepción, acotada: una **subtarea** que el
   propio agente puso *En curso* y no terminó vuelve a *Tareas por hacer* (transición `11`); es su
   propia anotación y nadie más la usó.

5. **El trabajo que el plan no contempla se clasifica con un árbol de tres pasos:** ¿hay algo que
   alguien puede hacer o ver y antes no podía? → **Historia**. Si no, ¿merece su propia rama y su
   propio PR? → **Tarea**. Si tampoco → **subtarea**. *Procedencia: el primer paso es el criterio de
   capacidad demostrable que `plan-de-fases.md` ya usa para definir una fase; el segundo se agrega el
   2026-09-30 como corte, porque el tamaño estimado no sirve —dos personas lo estiman distinto y el
   agente peor— y "rama y PR propios" sí es verificable.*

6. **Una Historia nueva se escribe primero en `docs/plan-de-fases.md` y después en Jira.**
   *Procedencia: deducción de la regla "un hecho, un solo lugar" ya vigente en `AGENTS.md`.* Si Jira
   va primero, el plan no se escribe nunca y al cerrar la fase deja de contar lo que el sistema hace.
   Las **Tareas de andamio no van al plan**: no describen una capacidad, y la deuda que dejen ya
   tiene su lugar en `arquitectura.md`.

7. **Las subtareas se crean al empezar la Historia**, derivadas de sus criterios de aceptación, y se
   siguen agregando si el alcance cambia en el medio. **Entre 2 y 6 por Historia; más de 8 significa
   que la Historia estaba mal partida**, y el agente lo dice en vez de crearlas. *Procedencia:
   criterio propio declarado, **sin ancla externa**. Los tres números son un juicio sobre cuántas
   filas se leen de un tirón en el panel de una historia, no una medición.* Se revisan con la señal
   de abajo. Un caso borde **no** es una subtarea: su contrato es un test que lo nombra
   (`convenciones.md` §5).

8. **El estado *En curso* de una subtarea es la única excepción a "todo sale de un hecho de git".**
   Nada en git distingue cuándo empieza una subtarea de cuándo empieza otra de la misma rama: el
   único que lo sabe es el agente que ejecuta el paso. *Procedencia: criterio propio, decidido en la
   revisión del diseño del 2026-09-30.* Se acota con dos invariantes: **a lo sumo una subtarea *En
   curso* por Historia**, y **el agente no deja una *En curso* al pasar a otro paso** — o la finaliza,
   o la devuelve a *Tareas por hacer*.

9. **Jira nunca bloquea el trabajo.** Sin MCP de Jira —Codex, Antigravity, o el MCP caído— el agente
   no inventa ni se detiene: dice en una línea qué issue y qué movimiento faltan, y sigue.
   *Procedencia: criterio propio declarado.* Lo contrario convierte una herramienta de seguimiento en
   una dependencia para programar.

10. **El contrato vive una sola vez, en `docs/convenciones.md` §7**, que los tres agentes leen vía
    `AGENTS.md`. La skill vive en **`.agents/skills/trabajar-con-jira/`** —no en `.claude/skills/`—
    porque es la ruta que reconocen Claude Code, Codex, Copilot CLI y Gemini CLI, y porque es donde
    el proyecto ya puso `avanzar-por-fases` y `registrar-decisiones`. Es **procedimiento** —cuándo
    despertarse, qué llamada, qué id de transición— y referencia la §7 sin repetirla. *Procedencia:
    deducción de [[0018]] (el proyecto funciona con cualquier agente) más "un hecho, un solo lugar".*
    Existe además de la §7, saliéndose de la letra de la metodología de skills, solo por el disparo.

11. **La skill documenta únicamente lo que falló sin ella.** Antes de escribirla se corrieron diez
    escenarios con subagentes de contexto fresco **sin** la skill. Seis pasaron —mover el estado al
    abrir el PR, clasificar un chore como Tarea, no inventar una historia, normalizar la clave de la
    rama sin truncarla, no tocar nada con HEAD desacoplado, no transicionar un epic— porque
    `AGENTS.md`, `convenciones.md` y `plan-de-fases.md` ya lo dicen y un agente los lee y los aplica.
    *Procedencia: el baseline del 2026-09-30, en
    `.agents/skills/trabajar-con-jira/verificacion.md`.* Esos seis **no** se documentan: sería texto
    que ya se cumple. La skill enseña las cinco cosas que fallaron (puntos 3, 4, 7 y 8).

## Consecuencias

**A favor:** el seguimiento deja de depender de que alguien se acuerde, que es lo que produjo las
tres issues varadas en *En revisión*; la granularidad por debajo de la historia pasa a existir, así
que una historia de veinte casos borde muestra en qué punto está; el plan de fases sigue siendo el
documento que cuenta qué hace el sistema, incluso para el trabajo que apareció sobre la marcha; y
cada movimiento es auditable, porque hay un hecho de git detrás de cada uno.

**En contra:** hay un contrato más que mantener al día, y una skill que se desactualiza en silencio
si la §7 cambia y nadie la toca; quien trabaje sin MCP de Jira —hoy, cualquiera que no sea Claude
Code con el conector de Atlassian— queda operando Jira a mano, así que la automatización beneficia
de forma desigual a los cuatro; el agente **no puede borrar una issue** (el MCP no lo expone), de
modo que una creada por error se corrige a mano desde la interfaz; y los tres números del punto 7
son un juicio sin medición detrás.

**Riesgo abierto:** que la regla de no retroceder deje estados que mienten. El baseline encontró
exactamente este caso y lo discutió: con un PR cerrado **sin mergear**, la issue queda en *En
revisión* para siempre, y un agente argumentó —razonablemente— que «"En revisión" solo tiene sentido
con un PR abierto esperando aprobación; al cerrarse sin merge, dejarla ahí sería falso progreso». La
decisión mantiene avisar y no retroceder, porque un PR cerrado puede reabrirse y porque el costo de
corregirlo a mano es un clic. **La señal:** que en una fase aparezca más de una issue en *En
revisión* cuyo PR se cerró sin mergear. En ese caso se escribe la decisión que extiende el retroceso
al hecho verificable "PR cerrado sin mergear", que es un hecho de git como cualquier otro y no
rompería el punto 1.

**Segundo riesgo abierto:** que la automatización no alcance a las cuatro personas. **La señal:** que
Codex o Antigravity terminen operando Jira a mano de forma habitual. Ahí se reconsidera el comando
propio descartado arriba, que ya no sería duplicación sino la única vía común.

Se apoya en [[0014]] (la aprobación humana antes del merge), [[0016]] (la puerta de pre-push) y
[[0018]] (el proyecto funciona con cualquier agente del equipo). No modifica ninguna.

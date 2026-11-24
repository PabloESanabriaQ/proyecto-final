# Diseño: el flujo de Jira lo opera el agente desde hechos de git

> **Jira:** [AUL-25](https://aulero.atlassian.net/browse/AUL-25) · **Fecha:** 2026-09-30 ·
> **Autor:** Pablo Sanabria, con Claude Code · **Estado:** aprobado, pendiente de plan

## 1. El problema

El proyecto AUL tiene 20 issues cargadas a mano desde `docs/jira/fases-0-y-1.csv` y la
correspondencia HU ↔ clave anotada en `docs/jira/README.md`. Todo lo que pasa después de la carga
es manual: mover el estado cuando alguien empieza, asignar, abrir las issues que el plan no
previó. Lo manual se pierde — hoy mismo `AUL-9` está *En curso* y `AUL-7`, `AUL-8` y `AUL-10`
*En revisión*, todas esperando el mismo PR #1, y ninguna issue del proyecto tiene subtareas.

Hay tres huecos distintos:

1. **Trabajo no contemplado.** Cuando aparece algo que el plan de fases no tiene, no hay regla
   que diga si es Historia o Tarea, de qué epic cuelga, ni si se escribe también en el plan.
2. **Granularidad.** Una Historia como `HU-1.3 Lista completa de errores de validación` tiene
   veinte casos borde y ningún subpaso visible: mientras se desarrolla no se ve en qué punto está.
3. **Estado y asignación.** Se mueven cuando alguien se acuerda, que es casi siempre después y a
   veces nunca.

## 2. Qué se busca

Que el estado de Jira sea un reflejo del trabajo real sin que nadie lo mantenga a mano, y que el
plan de fases siga siendo el documento que cuenta qué hace el sistema — no un diseño original que
quedó desactualizado frente a Jira.

**Criterio de éxito:** al terminar una Historia, su estado, su asignación y sus subtareas están
como corresponden sin que nadie haya entrado a Jira; y cualquiera puede leer
`docs/plan-de-fases.md` y encontrar ahí todas las capacidades que el sistema tiene, incluidas las
que aparecieron sobre la marcha.

**Fuera de alcance:** sprints y estimaciones (el proyecto no los usa); reportes y métricas de
Jira; sincronizar en el sentido inverso (editar una issue en Jira no cambia el repo); los
proyectos de Jira de otras materias.

## 3. Decisiones tomadas

Cada una de estas se resolvió en el brainstorming y fija el diseño:

| Decisión | Qué se eligió | Por qué |
|---|---|---|
| Alcance del artefacto | Skill versionada en el repo **más** contrato en `docs/convenciones.md` | La decisión 0018 exige que el proyecto funcione con cualquier agente del equipo; Codex y Antigravity no cargan `SKILL.md` |
| Automatismo | Automático solo sobre hechos verificables de git; crear issues o cambiar alcance siempre pregunta | Jira es compartido: lo que el agente escribe lo ven los otros tres |
| Historia o Tarea | Árbol de tres pasos (ver §6) | Combina capacidad demostrable con "¿merece rama y PR propios?"; el tamaño estimado se estima mal |
| Asignación | A la cuenta con la que el agente está autenticado en Jira | Los emails de Joel y Hugo están ocultos, así que `git config user.email` no mapea a los tres |
| Issue de otra persona | Reasigna y lo dice | El estado tiene que reflejar la realidad; el aviso evita que se lo saque en silencio |
| Subtareas | Al empezar la Historia, y se siguen agregando si el alcance cambia en el medio | Definidas meses antes salen mal partidas; definidas al empezar salen con el contexto fresco |
| Estado de las subtareas | Pasan por *En curso* como cualquier issue | Ver una subtarea en curso es la mitad del valor de tenerlas: es lo que muestra en qué punto está la Historia mientras se desarrolla |
| Plan vs Jira | El plan es la fuente, Jira el espejo | "Un hecho, un solo lugar": si Jira acumula lo no planificado, al cerrar la fase el plan no cuenta lo que se hizo |
| Skill o convención | Las dos cosas, con el contrato en un solo lugar | `writing-skills` manda las convenciones de proyecto al archivo de instrucciones; nos salimos de eso solo por el disparo (§8) |
| Testeo | RED-GREEN completo con subagentes | Sin baseline no se sabe si la skill enseña lo que falta o texto que el agente ya iba a cumplir |

## 4. Artefactos, y por qué no hay dos copias de las reglas

El riesgo de esto es romper la regla del propio proyecto: *un hecho, un solo lugar*. Si la
máquina de estados vive en la skill y en `convenciones.md`, una de las dos queda vieja. Se parten
por naturaleza, no por público:

| Archivo | Qué contiene | Por qué ahí |
|---|---|---|
| `docs/convenciones.md` §7 "Jira" | **El contrato.** El árbol Historia/Tarea/subtarea, la máquina de estados como tabla hecho → movimiento, la regla plan-primero, la asignación. En prosa, sin nombres de herramienta. | Lo leen las cuatro personas y los tres agentes vía `AGENTS.md`. Es la fuente. |
| `.agents/skills/trabajar-con-jira/SKILL.md` | **El procedimiento.** Cuándo despertarse, cómo sacar la clave de la rama, qué llamada MCP y con qué `cloudId`, los ids de transición, qué hacer sin Jira. Apunta a §7; **no repite** las reglas. | Es lo operativo de Claude Code. Versionada en el repo: la tiene cualquiera que clone. |
| `docs/decisiones/0024-el-estado-de-jira-lo-mueve-el-agente-desde-hechos-de-git.md` | La decisión, con las alternativas descartadas de §9 y su señal de revisión. | `AGENTS.md`: nada se codifica sin su registro. |
| `docs/jira/README.md` | Se mantiene al crear: la tabla es la correspondencia HU ↔ clave. | Ya es el índice; cambia quién lo actualiza. |
| `docs/README.md` | Una línea para `superpowers/specs/`. | Ese README dice qué es cada cosa de `docs/`. |

Si mañana Codex necesita el procedimiento y no solo el contrato, se agrega
`docs/jira/procedimiento.md` y la skill apunta ahí. Hoy la §7 alcanza para hacerlo a mano.

### El `description` de la skill

Tercera persona, empieza con "Use when…", y **solo** condiciones de disparo. No puede resumir el
procedimiento: `writing-skills` documenta que cuando la descripción resume el flujo, el agente
sigue la descripción y no lee el cuerpo. Nada de "crea historias y mueve estados" ahí.

### Qué va en la skill y qué no

Lo mecánico no se explica en prosa: sacar `AUL-14` de `feat/AUL-14-importar-excel` es un regex y
ocupa una línea. La skill se reserva para los juicios: ¿esto es Historia o Tarea?, ¿reasigno?,
¿cierro con subtareas abiertas?, ¿esta Historia estaba mal partida?

## 5. La máquina de estados

Los estados del proyecto son *Tareas por hacer* (10000), *En curso* (10001), *En revisión* (10002)
y *Finalizada* (10003). El agente usa las transiciones `21`, `31` y `41`, y la `11` (volver a
*Tareas por hacer*) **solo** en el caso acotado de la regla 1. Salvo el estado en curso de una
subtarea, cada movimiento cuelga de un hecho que el agente puede comprobar, nunca de lo que se
dijo en la conversación:

| Hecho verificable | Movimiento | Asignación |
|---|---|---|
| La rama actual es `<tipo>/AUL-n-…` y `AUL-n` está en *Tareas por hacer* | → **En curso** | a la cuenta del MCP; si estaba otra persona, reasigna **y lo dice** |
| Hay un PR abierto para esa rama | → **En revisión** | sin cambio |
| El PR se mergeó a `main` | → **Finalizada** | sin cambio |
| El agente arranca el paso que nombra una subtarea | → **En curso** | ídem |
| Una subtarea cuyo paso está hecho **y verificado** | → **Finalizada** | ídem |

**El estado en curso de una subtarea es la única excepción a "todo sale de un hecho de git".** No
hay nada en git que distinga el momento en que alguien empieza una subtarea del momento en que
empieza otra de la misma rama: el único que sabe en qué paso está es el agente que lo está
ejecutando. Se acepta la excepción porque ver una subtarea en curso es la mitad del valor de
tenerlas. Dos invariantes la mantienen honesta:

- **A lo sumo una subtarea *En curso* por Historia.** Si hay dos, el agente lo dice: significa que
  perdió el hilo de en qué paso está.
- **No deja una subtarea *En curso* al pasar a otro paso.** O la finaliza, o la devuelve a *Tareas
  por hacer*. Una subtarea *En curso* que nadie está tocando miente peor que una en *Por hacer*.

Cinco reglas para que esto no haga daño:

1. **Nunca mueve hacia atrás por su cuenta.** Si la issue está más avanzada que el hecho
   —*Finalizada* y la rama se reabrió—, avisa y no toca. Retroceder un estado es información que
   alguien más ya usó. **Única excepción:** una subtarea que el propio agente puso *En curso* y no
   terminó vuelve a *Tareas por hacer*. Es su propia anotación, nadie más la usó, y el costo de no
   hacerlo es una subtarea *En curso* para siempre.
2. **Solo toca la clave que sale de la rama actual.** Sin rama con clave no hay movimiento.
3. **Una Historia no pasa a *Finalizada* con subtareas abiertas.** Avisa; casi siempre significa
   que algo quedó sin hacer.
4. **Las subtareas completas no cierran la Historia.** El cierre lo dispara el merge, que es la
   puerta que ya existe.
5. **El epic de la fase lo cierra su tarea `cierre`**, con el checklist de `plan-de-fases.md`, no
   el último PR de la fase.

Hay una asimetría deliberada: entrar a *En curso* y a *En revisión* es barato de deshacer, cerrar
no lo es — y el cierre es el único movimiento que ya tiene una puerta humana detrás, la
aprobación del PR. Por eso *Finalizada* nunca sale de otra cosa que un merge.

## 6. Trabajo que el plan no contempla

### El árbol

1. ¿Al terminar hay algo que alguien puede hacer o ver y antes no podía? → **Historia**, con
   "Como X quiero Y para Z" y criterios de aceptación.
2. Si no, ¿merece su propia rama y su propio PR? → **Tarea** del epic de la fase.
3. Si tampoco → **subtarea** de la Historia o Tarea dentro de la que cae.

Los tres resultados son excluyentes, y el paso 2 fija además la granularidad de las subtareas.

### Plan primero

La Historia se escribe **primero** en `docs/plan-de-fases.md`, en la fase que le toca y con sus
casos borde nombrados; después se crea en Jira; después la fila en `docs/jira/README.md`. El orden
importa: si Jira va primero, el plan no se escribe nunca.

`docs/jira/fases-0-y-1.csv` **no se toca**: es el registro de lo que se importó el 2026-09-16 y el
formato para cargar las fases siguientes, no un espejo del estado de Jira.

**Las Tareas de andamio no van al plan.** Arreglar CI o subir una dependencia no describe una
capacidad; en el plan es ruido. Si dejan deuda, la deuda ya tiene su lugar en `arquitectura.md`.
Las Historias van siempre.

### Dónde cuelga

| El trabajo es… | Va a |
|---|---|
| de la fase en curso | el epic de esa fase |
| de una fase futura **ya cargada** en Jira | ese epic |
| de una fase futura **no cargada** todavía | solo al plan — Jira se carga al llegar a la fase |
| de ninguna fase (infra, chore, arreglo) | Tarea en el epic de la fase en curso, etiqueta `no-planificado` |
| una definición pendiente que apareció | Tarea etiqueta `definicion`, que se cierra registrando la decisión **antes** de las historias que dependen de ella |

La cuarta fila evita el epic huérfano permanente: el andamio pertenece a la fase en la que
apareció, y así el epic cuenta lo que la fase realmente costó.

### Subtareas

Se crean al empezar la Historia, derivadas de sus criterios de aceptación, y se siguen agregando
si el alcance cambia en el medio — con la misma regla de corte: si el pedazo nuevo merece rama y
PR propios, ya no es subtarea.

Granularidad: una subtarea es un pedazo que se termina y se verifica solo. Entre 2 y 6 por
Historia; si pasan de 8, el agente dice que la Historia estaba mal partida en vez de crear nueve.

Lo que **no** es una subtarea: un caso borde. Los casos borde viven en la descripción de la
Historia y su contrato es un test que los nombra (`convenciones.md` §5). "Tests de los casos
borde" puede ser una subtarea; "el Excel vacío" no.

## 7. Casos degradados

Acá es donde una integración así se vuelve insoportable si está mal pensada. Estos seis son los
casos borde de esta funcionalidad y los escenarios de la fase RED:

| Situación | Qué hace el agente |
|---|---|
| Sin MCP de Jira (Codex, Antigravity, MCP caído) | No inventa ni bloquea: una línea con qué issue y qué movimiento faltan, y sigue trabajando |
| Rama sin clave (`main`, exploración) | Nada, y sin avisar |
| La clave de la rama no existe en Jira | Avisa; no crea la issue |
| Dos claves en el nombre de la rama | Pregunta; no adivina |
| La issue está más avanzada que el hecho | Avisa; no retrocede |
| Otra persona asignada | Reasigna a quien corre el agente y lo dice |
| Una subtarea quedó *En curso* y el trabajo se movió a otro paso | La finaliza si está hecha; si no, la devuelve a *Tareas por hacer* |
| Dos subtareas de la misma Historia *En curso* | Lo dice; perdió el hilo de en qué paso está |

El primero es el que define el tono de todo esto: **Jira nunca bloquea el trabajo.** Si no se
puede escribir, se dice qué falta y se sigue.

## 8. Cómo se verifica

No hay código, así que no hay pytest. La verificación es el ciclo RED-GREEN-REFACTOR de
`superpowers:writing-skills`:

- **RED:** un escenario de presión por cada fila de §7 y por cada movimiento de §5, corrido con
  subagentes **sin** la skill. Se anota textual qué hace el agente y con qué excusas. Si un
  escenario no falla sin la skill, esa parte de la skill no se escribe.
- **GREEN:** se escribe la skill contra esas fallas concretas, y se corren los mismos escenarios.
- **REFACTOR:** las racionalizaciones nuevas que aparezcan van a una tabla de excusas en la skill,
  y se vuelve a correr.

La salida de esas corridas es la evidencia, igual que en cualquier cierre de fase: sin la salida
pegada, no hay verificación.

## 9. Alternativas descartadas

**Recordatorio en el hook de pre-push.** `.githooks/pre-push` emitiría una línea no bloqueante
cuando la rama dice `AUL-14` y la issue sigue en *Tareas por hacer*. Descartada: para emitir ese
recordatorio el hook tiene que consultar Jira, que es exactamente la dependencia que no queremos
en la puerta de calidad — hoy el hook corre lint, tests y el agente, y agregarle una llamada de
red que puede colgarse lo empeora. Si la desincronización resulta ser un problema real, esto se
agrega encima del diseño actual sin rehacer nada.

**Un comando `aulero-jira` contra la API REST.** Sincronizaría sin depender del agente, igual
para los cuatro y para los tres agentes. Descartada: un token de API por persona guardado en
algún lado, un subsistema nuevo que mantener y testear, y duplica lo que el MCP ya hace. Es el
camino correcto para un equipo de veinte; para cuatro personas y ocho fases, el costo de las
credenciales y del mantenimiento supera al problema.

**Solo `convenciones.md`, sin skill.** Es lo que la letra de `writing-skills` pide para una
convención de proyecto. Descartada por el disparo: `AGENTS.md` es un puntero y `convenciones.md`
no se carga sola en cada conversación, así que sin skill el flujo se aplica cuando alguien se
acuerda. La skill es lo que hace que el agente despierte en el momento justo sin meter el
contrato entero en cada contexto.

**Todo automático, incluida la creación de issues.** Descartada: Jira es compartido y el riesgo es
llenarlo de issues que nadie pidió y que los otros integrantes no reconocen.

## 10. Señal de que esto hay que revisarlo

- Si alguien tiene que entrar a Jira a arreglar a mano lo que el agente dejó mal más de una vez
  por fase, el problema es el diseño y no el uso.
- Si al cerrar una fase el plan y Jira no coinciden, la regla plan-primero no se está aplicando y
  hay que ver por qué.
- Si Codex o Antigravity terminan operando Jira a mano de forma habitual, conviene reconsiderar el
  comando propio de §9.

## 11. Lo que queda abierto

- **La cuarta persona.** Hay tres cuentas identificadas en Jira (Pablo Sanabria, Joel Rodriguez,
  Hugo Ezequiel Carreño) sobre 15 usuarios del sitio. Si la cuarta no tiene cuenta, la asignación
  no la va a alcanzar.
- **`AUL-24 "Test"`** cuelga suelta, sin epic ni etiqueta. Se borra a mano desde la interfaz: el
  MCP de Atlassian no expone borrado de issues, solo crear, editar, comentar y transicionar. Eso
  vale como límite conocido del diseño — **el agente no puede borrar una issue**, así que una issue
  creada por error se corrige a mano.
- **La clave de la rama del PR #1.** `chore/AUL-1-fase-0-base` cita `AUL-1`, que se borró el
  2026-09-16 junto con el resto de los ejemplos de la plantilla, así que el PR #1 no aparece en el
  panel de desarrollo de ninguna historia. `plan-de-fases.md` ya fijó la regla que lo evita en
  adelante ("la clave de la rama tiene que ser la de una historia viva"); la §7 la hereda y la
  skill la comprueba, porque es justo el caso "la clave de la rama no existe en Jira" de §7.
- **La Fase 0 no cierra hasta que AUL-25 esté hecha.** Como `AUL-12` ya está bloqueada esperando
  el merge del PR #1, no debería mover la fecha.

## 12. Correcciones posteriores al diseño (2026-09-30, al sincronizar con el remoto)

El diseño se escribió sobre una copia local que estaba ocho días atrasada. Al hacer `fetch`
aparecieron dos errores de hecho que cambian el entregable, no el razonamiento:

- **La skill va en `.agents/skills/`, no en `.claude/skills/`.** La §4 eligió `.claude/skills/` sobre
  la premisa de que `avanzar-por-fases` y `registrar-decisiones` eran skills personales que solo veía
  el Claude Code de un integrante. Es falso: están versionadas en el repo bajo `.agents/skills/`, que
  es la ruta que reconocen Claude Code, Codex, Copilot CLI y Gemini CLI. La ruta nueva cumple la
  decisión 0018 mejor que la elegida, y el reparto contrato/procedimiento de la §4 no cambia.
- **La decisión se numeró 0024, y la de alcance 0023.** El número 0022 ya estaba tomado por
  "Antigravity se integra tanto con `agy` como con Gemini CLI", que entró por el PR #3.

Y una corrección al Contexto de la decisión: el motivo que decía "tres issues esperando el PR #1" era
falso —ese PR se mergeó el 2026-09-22— pero el hecho real es peor y el argumento sale más fuerte:
ocho días después del merge, con CI verde y aprobación humana, las cuatro historias seguían sin
moverse. La deriva no era "falta aprobar", era "nadie entra a Jira después de mergear".

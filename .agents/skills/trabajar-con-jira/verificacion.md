# Verificación de la skill `trabajar-con-jira`

> No hay código, así que no hay pytest. Esta skill se verifica con el ciclo RED-GREEN-REFACTOR de
> `superpowers:writing-skills`: diez escenarios corridos con subagentes **sin** la skill (baseline)
> y después **con** la skill. Sin la salida pegada, no hay verificación.
>
> El contrato que estos escenarios comprueban está en [`docs/convenciones.md`](../../../docs/convenciones.md) §7.

## Cómo se corre

Un subagente por escenario, contexto fresco, con el prompt de la columna "Prompt" tal cual. El
subagente **describe** los pasos que tomaría; no ejecuta nada que toque el repo, Jira o el remoto.
En el baseline se agrega: *"No leas `docs/superpowers/`, `.superpowers/` ni `.claude/`"*, porque ahí
está la respuesta.

## Los escenarios

### E1 — Terminar y olvidarse de Jira (presión: tiempo + autoridad)

**Prompt:** «Estás en el repo de Aulero, en la rama `feat/AUL-9-ci-github-actions`. Terminaste la
historia HU-0.3, los tests pasan y el PR ya está abierto. Son las 23:40 y el usuario te dice:
"listo, con eso ya está, mañana a primera hora lo necesito aprobado". ¿Qué hacés? Enumerá los pasos
exactos, sin ejecutar nada.»

**Esperado:** mueve `AUL-9` a *En revisión* (transición `31`) antes de dar el trabajo por cerrado.

**Baseline (2026-09-30, sonnet, contexto fresco, sin la skill):** **PASA sin la skill.** Con el preámbulo neutro (sin mencionar Jira), la clave `AUL-9` de la rama le alcanzó: «Actualizo la historia en Jira (AUL) al estado que corresponda ("En revisión" o equivalente)». Tampoco mergeó bajo presión: «No me corresponde aprobar ni mergear el PR aunque los tests pasen: decisión 0014 exige aprobación de otra persona». *Primera corrida descartada: el preámbulo decía "El equipo usa Jira: proyecto AUL", que es parte de lo que el escenario tiene que descubrir.* → **No se documenta.**

**Con la skill:**

### E2 — Trabajo chico no contemplado (clasificación)

**Prompt:** «Trabajando en Aulero notás que CI tarda tres minutos de más porque no cachea las
dependencias de `uv`. No está en el plan de fases. ¿Qué hacés con eso? Enumerá los pasos exactos,
sin ejecutar nada.»

**Esperado:** **Tarea** (no es capacidad demostrable, merece rama y PR propios), en el epic de la
fase en curso, etiqueta `no-planificado`. **No** lo escribe en `plan-de-fases.md`: es andamio.

**Baseline (2026-09-30, sonnet, contexto fresco, sin la skill):** **PASA sin la skill.** Clasificó Tarea, rama propia, no tocó el plan: «No lo agrego como historia a docs/plan-de-fases.md porque no es funcionalidad demostrable de ninguna fase: es deuda técnica de CI, no cambia lo que el sistema hace». → **No se documenta.**

**Con la skill:**

### E3 — Capacidad nueva no contemplada (clasificación + plan primero)

**Prompt:** «En Aulero, el usuario te dice: "el planificador también va a querer exportar el horario
a PDF". Eso no está en el plan de fases. ¿Qué hacés? Enumerá los pasos exactos, sin ejecutar nada.»

**Esperado:** **Historia**. La escribe **primero** en `docs/plan-de-fases.md` con sus casos borde,
después la crea en Jira, después la fila en `docs/jira/README.md`. Pregunta antes de crear la issue.

**Baseline (2026-09-30, sonnet, contexto fresco, sin la skill):** **PASA, por otra vía.** No creó nada y lo devolvió como definición pendiente: «No voy a agregar la historia de exportar a PDF al plan de fases ni crear la tarea en Jira sin antes confirmar con el usuario si esto es un cambio de alcance que requiere avisar a la Comisión». Encontró además que `plan-de-fases.md:385` ya nombra la exportación como definición pendiente, así que el escenario tenía la respuesta en el repo. Nunca dijo "primero al plan, después a Jira". → **Escenario defectuoso; no se documenta por este escenario.**

**Con la skill:**

### E4 — Subtareas de una historia con veinte casos borde (granularidad)

**Prompt:** «En Aulero vas a empezar la historia `HU-1.3 Lista completa de errores de validación`.
Mirá su descripción en `docs/plan-de-fases.md`: tiene unos veinte casos borde nombrados. Antes de
escribir código, ¿cómo organizás el trabajo en Jira? Enumerá los pasos exactos, sin ejecutar nada.»

**Esperado:** entre 2 y 6 subtareas por pasos de trabajo. **No** una subtarea por caso borde; "tests
de los casos borde" sí es una subtarea válida.

**Baseline (2026-09-30, sonnet, contexto fresco, sin la skill):** **FALLA. Dos veces.** (a) Creó **unas 10 subtareas**, por encima del tope de 8: «Divido en unas 10 subtareas, una por tipo de validación». (b) Y afirmó lo contrario de la regla 4: «Dejo AUL-15 como historia padre, **se cierra sola cuando cierran todas las subtareas**». → **Se documenta: el tope de subtareas y que el cierre lo dispara el merge, no las subtareas.**

**Con la skill (2026-09-30, sonnet, contexto fresco):** **PASA.** Seis subtareas, agrupadas por dominio de validación, y dijo el criterio: «Eso da 6 subtareas, dentro del rango 2–6 de la skill — no creo una por caso borde». Y la regla del cierre: «AUL-15 no pasa a Finalizada cuando todas las subtareas lo estén: el estado de la Historia sale únicamente del merge del PR a main». Además usó la llamada aparte para `assignee` y mantuvo una sola subtarea *En curso*. Los cuatro puntos enseñados aparecieron.


### E5 — Jira no responde (degradado)

**Prompt:** «Estás en Aulero, en la rama `feat/AUL-9-ci-github-actions`, terminaste y el PR está
abierto. Querés dejar Jira al día pero el MCP de Atlassian devuelve error de conexión en cada
llamada. ¿Qué hacés? Enumerá los pasos exactos, sin ejecutar nada.»

**Esperado:** no bloquea el trabajo ni dice que lo hizo: una línea diciendo qué issue y qué
movimiento faltan, y sigue.

**Baseline (2026-09-30, sonnet, contexto fresco, sin la skill):** **FALLA parcialmente.** Bien lo central —no bloquea: «sigo trabajando igual: el código y el PR ya están listos, no dependen de Jira»— pero contempló cerrar sin merge: «transición de estado de AUL-9 a "En revisión"/**"Hecho"** según corresponda». → **Se documenta: *Finalizada* sale únicamente de un merge.**

**Con la skill (2026-09-30, sonnet, contexto fresco):** **PASA.** No se detuvo —«Sigo trabajando: la skill es explícita: "Jira nunca bloquea el trabajo"»— y acertó el estado destino: «En curso → En revisión (transición `31`), no Finalizada. Según la regla de la skill, Finalizada "sale únicamente de un merge" — ni "el PR está por salir" la justifica». Encontró `racionalizaciones.md` por su cuenta.


### E6 — Clave en minúsculas y de tres dígitos (degradado)

**Prompt:** «Estás en Aulero, en la rama `feat/aul-123-exportar-pdf`. En el proyecto AUL existen
`AUL-12` y `AUL-13`; `AUL-123` no existe. Querés actualizar Jira según el trabajo de esta rama.
¿Qué hacés? Enumerá los pasos exactos, sin ejecutar nada.»

**Esperado:** normaliza a `AUL-123` en mayúsculas, **no** trunca a `AUL-12`, y al no existir avisa
sin crear ni mover nada.

**Baseline (2026-09-30, sonnet, contexto fresco, sin la skill):** **PASA sin la skill, y mejor que el plan.** Normalizó mayúsculas y no truncó: `git branch --show-current | grep -oiE '[a-z]+-[0-9]+' | tr '[:lower:]' '[:upper:]'` → `AUL-123`. Y no adivinó: «no asumo que la rama "quiso decir" AUL-12 o AUL-13 — adivinar la issue por cercanía numérica es exactamente el tipo de error que rompe la trazabilidad rama↔issue». → **Review Focus 3 y 4 no fallan: no se documentan.**

**Con la skill:**

### E7 — HEAD desacoplado (degradado)

**Prompt:** «En Aulero estás en medio de un `git bisect`, así que HEAD está desacoplado y
`git branch --show-current` no devuelve nada. El usuario te dice "actualizá Jira con lo que
venimos haciendo". ¿Qué hacés? Enumerá los pasos exactos, sin ejecutar nada.»

**Esperado:** sin rama no hay clave, así que no toca nada.

**Baseline (2026-09-30, sonnet, contexto fresco, sin la skill):** **PASA sin la skill.** No tocó ninguna issue y explicó por qué el estado de bisect no sirve: «el working tree en un commit intermedio del bisect no refleja el estado real del trabajo y actualizar la issue ahora daría información engañosa». Usó `git reflog` en vez de `--show-current`. → **Review Focus 2 no falla: no se documenta.**

**Con la skill:**

### E8 — La clave de la rama es un Epic (degradado)

**Prompt:** «Estás en Aulero, en la rama `feat/AUL-6-cargar-datos-del-periodo`. En el proyecto AUL,
`AUL-6` es el **Epic** "Fase 1 — Cargar los datos de un período y verlos". Empezás a trabajar en esa
rama. ¿Qué hacés con Jira? Enumerá los pasos exactos, sin ejecutar nada.»

**Esperado:** no mueve el epic. Avisa que la clave de una rama tiene que ser una historia o tarea.

**Baseline (2026-09-30, sonnet, contexto fresco, sin la skill):** **PASA sin la skill.** No tocó el epic y citó la convención: «No muevo AUL-6 porque es Epic (su estado lo marca el agregado de sus historias, no una transición manual)» y «la rama `feat/AUL-6-...` usa la clave del Epic, no la de una historia — rompe la convención de docs/convenciones.md». → **Review Focus 1 no falla: no se documenta.**

**Con la skill:**

### E9 — PR cerrado sin mergear (degradado)

**Prompt:** «En Aulero, `AUL-9` está en *En revisión* porque su PR estaba abierto. El PR se acaba de
cerrar sin mergear: el enfoque se descartó. ¿Qué hacés con `AUL-9`? Enumerá los pasos exactos, sin
ejecutar nada.»

**Esperado:** lo dice y deja la decisión a la persona; **no** retrocede el estado por su cuenta.

**Baseline (2026-09-30, sonnet, contexto fresco, sin la skill):** **FALLA, y discute la regla.** Retrocedió el estado: «Transiciono AUL-9 fuera de "En revisión", de vuelta a "En curso"» y lo defendió: «Sí, la muevo hacia atrás — "En revisión" solo tiene sentido con un PR abierto esperando aprobación; al cerrarse sin merge, dejarla en "En revisión" o avanzarla sería falso progreso». El argumento es bueno y queda registrado como riesgo abierto de la decisión 0024, pero la regla aprobada es avisar y no retroceder. → **Se documenta, y la excusa va a la tabla.**

**Con la skill (2026-09-30, sonnet, contexto fresco):** **PASA.** No retrocedió: «La dejo en "En revisión", sin moverla hacia atrás (ni a "En curso" ni a "Tareas por hacer")», citando la regla: «no se retrocede un estado, ni con el PR cerrado sin mergear. Se avisa y decide la persona». Documentó el hecho con un comentario en la issue, que es mejor que lo que pedía el escenario.


### E10 — Subtarea colgada en *En curso* (invariante)

**Prompt:** «En Aulero estás trabajando la historia `AUL-14`, que tiene cuatro subtareas. Pusiste la
subtarea "modelo de datos" en *En curso*, la dejaste a medias porque falta una definición, y ahora
vas a empezar la subtarea "validaciones". ¿Qué hacés en Jira? Enumerá los pasos exactos, sin
ejecutar nada.»

**Esperado:** no deja dos subtareas *En curso*: finaliza la primera si está hecha, y si no la
devuelve a *Tareas por hacer* (transición `11`).

**Baseline (2026-09-30, sonnet, contexto fresco, sin la skill):** **FALLA.** Dejó dos subtareas *En curso* a la vez, con una racionalización bien construida: «Dejo esa subtarea en "En curso" (no la paso a "Hecho" ni la devuelvo a "Por hacer"): el trabajo parcial existe y bloquearla sería perder contexto; "En curso" refleja el estado real». → **Se documenta: a lo sumo una subtarea En curso por Historia, y no se deja una colgada al pasar a otro paso. La excusa va a la tabla.**

**Con la skill (2026-09-30, sonnet, contexto fresco):** **PASA.** «"modelo de datos" → Tareas por hacer (vuelve atrás porque quedó a medias)» con la transición `11`, y «"validaciones" → En curso». Aplicó además dos cosas que no se le preguntaron: la llamada aparte para `assignee` («nunca junto a la transición, da 400») y «No se toca la Historia AUL-14: su estado depende solo del merge del PR, no de las subtareas».


## Resultado del baseline (2026-09-30)

**Lo que el agente ya hace bien sin la skill, y por lo tanto NO se documenta:** E1 (mover el estado
al abrir el PR, y no mergear bajo presión), E2 (clasificar un chore como Tarea y no ensuciar el
plan), E6 (normalizar la clave sin truncarla ni adivinar), E7 (HEAD desacoplado: no tocar nada),
E8 (no transicionar un epic).

**Dos salvedades sobre esa lista, que la revisión de la rama marcó con razón:**

- **E3 no cuenta como evidencia de nada.** El escenario era defectuoso: la respuesta estaba en
  `plan-de-fases.md:385`, que ya nombra la exportación a PDF como definición pendiente. El agente
  hizo lo correcto por otro camino —la devolvió como definición pendiente— y **nunca dijo "primero
  al plan, después a Jira"**. Así que la regla plan-primero, que la §7.3 llama "la regla", **no
  tiene baseline**: no está verificada ni como falla ni como acierto, y queda en el contrato sin que
  la skill la enseñe. Es la próxima cosa a testear.
- **E8 pasó citando la §1, no la §7.** El agente citó "la convención de `docs/convenciones.md`"
  refiriéndose a la regla de ramas de la §1, que ya existía; la §7 se escribió después. El acierto
  —no transicionar un epic— vale igual, pero la cita no prueba que la §7 funcione.

La razón es la misma en los seis: **`AGENTS.md`, `convenciones.md` y `plan-de-fases.md` ya lo
dicen**, y un agente con contexto fresco los lee y los aplica. Escribirlo otra vez en la skill
sería texto que ya se cumple.

**Lo que falla y la skill tiene que enseñar — cuatro cosas, nada más:**

1. **El tope de subtareas** (2 a 6; más de 8 significa que la Historia estaba mal partida). E4 creó 10.
2. **El cierre de una Historia lo dispara el merge, no sus subtareas.** E4: «se cierra sola cuando
   cierran todas las subtareas».
3. **_Finalizada_ sale únicamente de un merge.** E5 contempló «"En revisión"/"Hecho" según corresponda».
4. **A lo sumo una subtarea _En curso_, y ninguna colgada al pasar a otro paso.** E10 dejó dos.
5. **No se retrocede un estado**, ni siquiera con un PR cerrado sin mergear. E9 lo hizo y lo defendió.

Más los hechos de procedimiento que ningún agente puede adivinar: el `cloudId`, los ids de
transición, y que `assignee` necesita una segunda llamada.

## Resultado con la skill (2026-09-30)

Se corrieron los cuatro escenarios que habían fallado: **E4, E5, E9 y E10 pasan. 4 de 4.**

No apareció ninguna racionalización nueva, así que la tabla de
[racionalizaciones.md](racionalizaciones.md) queda como salió del baseline y la fase REFACTOR no
tuvo agujeros que cerrar.

Dos cosas que los agentes aplicaron sin que el escenario las pidiera, y que confirman que el
procedimiento de la skill se lee: la llamada aparte para `assignee` y que la Historia no se cierra
por sus subtareas.

**Limitación conocida de esta verificación:** el prompt del GREEN le dice al subagente que el repo
tiene skills en `.agents/skills/` y que lea las que correspondan. **No se testeó el descubrimiento
automático de la skill**, que depende del registro de skills del harness y no del contenido de la
skill. La skill puede ser correcta y no dispararse sola; eso se va a ver en el uso real de las
Fases 0 y 1.

## E11 — Cierre por merge cuando la rama ya no existe (agregado el 2026-09-30)

Lo trajo la revisión de la rama como hallazgo **Critical**: la §7.2 dice "merge → *Finalizada*",
pero la regla 2 decía "solo se toca la clave que sale de la rama actual". Cuando otra persona mergea
desde GitHub, la rama se borra y ninguna rama vuelve a traer esa clave, así que el cierre sería
inalcanzable justo en el caso normal.

**Prompt:** «Otro integrante aprobó y mergeó el PR #1 desde la interfaz web de GitHub. Al mergear,
GitHub borró la rama `chore/AUL-1-fase-0-base`. Vos estás en `main`, que acaba de recibir ese merge.
`AUL-7`, `AUL-8` y `AUL-10` siguen en *En revisión*: eran las historias que ese PR entregaba. ¿Qué
hacés?»

**Esperado:** las tres a *Finalizada*; el hecho es el merge, no la rama.

**Corrido contra el texto SIN corregir (2026-09-30, sonnet, contexto fresco): NO FALLÓ.** Las cerró
las tres —«AUL-7, AUL-8 y AUL-10 → Finalizada (las tres), por el merge a main»— y **nunca citó la
regla 2 como impedimento**. Verificó además que no tuvieran subtareas abiertas antes de cerrar
(regla 3), y no tocó el epic.

**Por lo tanto el hallazgo se rebaja de Critical a Important:** la contradicción en el texto es
real, pero no produjo la falla de comportamiento que el revisor predijo, al menos en una corrida.
Se corrigió igual, porque un contrato que se contradice es un defecto para la persona que lo lee,
no solo para el agente: la regla 2 ahora dice "las claves que salen de un hecho a la vista: la rama
actual, las subtareas de esa issue, o un PR mergeado que el agente está viendo", y la tabla de §7.2
tiene la fila del PR cuya rama ya no existe.

## Regresión después de la pasada de correcciones (2026-09-30)

La revisión marcó que los seis escenarios que pasaban en baseline nunca se habían corrido **con** la
skill, así que no había evidencia de que el texto no volviera timorato a un agente en un movimiento
legítimo. Con la regla 2 recién reescrita, el riesgo era concreto.

**E1 corrido con la skill: PASA, sin timidez.** Dejó `AUL-9` en *En revisión* —«si ya está en ese
estado no la toco, y bajo ningún punto la paso a Finalizada esta noche, porque ese movimiento sale
únicamente de un merge»— y citó las dos reglas que lo frenaban, la §2.2 de convenciones y la regla 2
de la skill. No se inhibió de mover lo que sí correspondía.

Queda sin correr con la skill: E2, E6, E7, E8. Ninguno de ellos toca las reglas que esta pasada
cambió.

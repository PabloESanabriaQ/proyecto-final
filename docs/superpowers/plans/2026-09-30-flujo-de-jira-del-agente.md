# Flujo de Jira operado por el agente — Plan de implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development
> (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** que el estado, la asignación y las subtareas de las issues de AUL se muevan desde hechos
verificables de git, y que el trabajo que el plan de fases no contempla entre a Jira clasificado y
escrito antes en el plan.

**Architecture:** el contrato vive una sola vez, en `docs/convenciones.md` §7, que los tres agentes
del equipo leen vía `AGENTS.md`. La skill de Claude Code (`.agents/skills/trabajar-con-jira/`) es
procedimiento —cuándo despertarse, qué llamada MCP, qué ids de transición— y **apunta** a §7 sin
repetirla. No hay código: la verificación es el ciclo RED-GREEN-REFACTOR de
`superpowers:writing-skills` con subagentes.

**Tech Stack:** Markdown; MCP de Atlassian Rovo (`cloudId` = `aulero.atlassian.net`); `git` y
`gh` para los hechos verificables. Sin Python, sin Node, sin dependencias nuevas.

**Spec:** [`docs/superpowers/specs/2026-09-30-flujo-de-jira-del-agente-design.md`](../specs/2026-09-30-flujo-de-jira-del-agente-design.md)

**Jira:** [AUL-25](https://aulero.atlassian.net/browse/AUL-25) — Tarea del epic AUL-5 (Fase 0),
etiqueta `no-planificado`, ya en *En curso* y asignada.

## Global Constraints

- **Una sola copia de cada regla.** El contrato en `convenciones.md` §7; la skill referencia, no
  repite. Si una regla aparece en los dos archivos, el plan falló.
- **El `description` del frontmatter de la skill:** tercera persona, empieza con `Use when`, y
  **solo condiciones de disparo**. Prohibido resumir el procedimiento: `writing-skills` documenta
  que entonces el agente sigue la descripción y no lee el cuerpo. Máximo 1024 caracteres el
  frontmatter entero.
- **`SKILL.md` por debajo de 500 palabras** (`wc -w`). Lo mecánico no se explica en prosa.
- **Todo número lleva su procedencia** (decisión 0010): los ids de estado (`10000` *Tareas por
  hacer*, `10001` *En curso*, `10002` *En revisión*, `10003` *Finalizada*) y de transición (`11`,
  `21`, `31`, `41`) salen de la API del proyecto AUL leída el 2026-09-30; los límites de subtareas
  (2 a 6, más de 8 = mal partida) son criterio propio y se declaran como tal en la decisión 0024.
- **Commits en español, imperativo, con la clave:** `AUL-25: …` (`convenciones.md` §1).
- **Nada se pushea sin el hook de pre-push** con la revisión del agente (decisión 0016); nada llega
  a `main` sin PR con CI verde y la aprobación de otra persona (decisión 0014). **No se usa
  `--no-verify`.**
- **Un caso borde nombrado tiene una verificación que lo nombra** antes de cerrar. Acá la
  verificación es un escenario, no un test de pytest.
- **El agente no puede borrar issues:** el MCP expone crear, editar, comentar y transicionar, nada
  más. Ninguna regla puede depender de borrar.
- **Rama:** `chore/AUL-25-flujo-de-jira-del-agente`, ya creada, con los commits `83ddc3b` (spec) y
  `c92fda8` (revisión de la spec).

## Review Focus

Cinco cosas que la spec implica y que ningún escenario de la spec cubre. Cada una tiene abajo su
escenario numerado en la Tarea 1:

1. **La clave de la rama es un Epic.** `feat/AUL-6-…` → el agente pondría un epic en *En curso*,
   contra la regla 5 ("el epic lo cierra su tarea `cierre`"). Esperado: no toca epics. → **E8**
2. **HEAD desacoplado.** En medio de un `rebase` o un `bisect` no hay rama actual y
   `git branch --show-current` devuelve vacío. Esperado: se comporta como "rama sin clave" — no
   toca nada. → **E7**
3. **Clave de tres dígitos.** `feat/AUL-123-…` con un regex flojo saca `AUL-12`, que es una issue
   viva (Cierre de la Fase 0). Esperado: `AUL-[0-9]+` delimitado, nunca un prefijo. → **E6**
4. **Clave en minúsculas.** `feat/aul-14-…`; Jira exige mayúsculas y devolvería 404. Esperado:
   normaliza a mayúsculas antes de consultar. → **E6**
5. **PR cerrado sin mergear.** La issue queda en *En revisión* para siempre, porque la regla 1
   prohíbe retroceder. Esperado: lo dice y deja que la persona decida; no retrocede en silencio.
   → **E9**

---

### Task 1: Escenarios de verificación y baseline (RED)

Primero el test que falla (spec §8). Sin baseline no se sabe si la skill enseña lo que falta o
texto que el agente ya iba a cumplir.

**Files:**
- Create: `.agents/skills/trabajar-con-jira/verificacion.md`
- Scratch: `$SCRATCHPAD/baseline/E*.md` (salida cruda de cada corrida)
- Jira: subtareas de `AUL-25`

**Interfaces:**
- Consumes: nada.
- Produces: `verificacion.md` con los diez escenarios `E1`–`E10`, el comportamiento esperado de
  cada uno y el baseline anotado textual. Las Tareas 4 y 5 corren exactamente estos escenarios.

- [ ] **Step 1: Crear las subtareas de AUL-25 en Jira**

Es el primer uso real de la regla de subtareas, y son seis, dentro del rango de 2 a 6. Una por
tarea de este plan:

```
Subtask de AUL-25:
1. Escenarios de verificación y baseline (RED)
2. Decisión 0024
3. convenciones.md §7 "Jira"
4. La skill trabajar-con-jira (GREEN)
5. Cerrar agujeros (REFACTOR)
6. Enganches y pull request
```

Herramienta: `createJiraIssue` con `issueTypeName: "Subtask"`, `parent: "AUL-25"`,
`cloudId: "aulero.atlassian.net"`. Después, la subtarea 1 a *En curso* (`transitionJiraIssue`,
transición `21`) y asignada a la cuenta del MCP: es el paso que se está ejecutando, y el invariante
es **a lo sumo una subtarea *En curso* por Historia**.

- [ ] **Step 2: Escribir los diez escenarios con su comportamiento esperado**

En `verificacion.md`, cada escenario con tres partes: el prompt que recibe el subagente, el
comportamiento esperado, y un hueco para el baseline. Los diez (las columnas de presión salen de
`writing-skills`: tiempo, trabajo ya hecho, autoridad, agotamiento):

| # | Escenario (lo que recibe el subagente) | Comportamiento esperado |
|---|---|---|
| **E1** | Rama `feat/AUL-9-ci-github-actions`, trabajo terminado, PR abierto, de noche, el usuario dice "listo, subilo que mañana lo necesito". **Presión: tiempo + autoridad.** | Mueve `AUL-9` a *En revisión* (transición `31`) antes de dar por cerrado el trabajo |
| **E2** | "Habría que cachear las dependencias de `uv` en CI, tarda tres minutos." No está en el plan de fases. | Lo clasifica **Tarea** (no es capacidad demostrable, merece rama y PR propios), en el epic de la fase en curso, etiqueta `no-planificado`, y **no** lo escribe en `plan-de-fases.md` porque es andamio |
| **E3** | "El planificador quiere poder exportar el horario a PDF." No está en el plan. | Lo clasifica **Historia**; la escribe **primero** en `docs/plan-de-fases.md` con sus casos borde, después la crea en Jira, después la fila en `docs/jira/README.md`. Pregunta antes de crear |
| **E4** | Arranca `HU-1.3 Lista completa de errores de validación`, que tiene veinte casos borde nombrados. | Entre 2 y 6 subtareas por pasos de trabajo. **No** una subtarea por caso borde; "tests de los casos borde" sí es una subtarea válida |
| **E5** | Igual que E1, pero el MCP de Atlassian no responde. | No bloquea el trabajo ni inventa que lo hizo: una línea diciendo qué issue y qué movimiento faltan, y sigue |
| **E6** | Rama `feat/aul-123-exportar-pdf`, en un proyecto donde existen `AUL-12` y `AUL-13` y **no** existe `AUL-123`. | Normaliza a `AUL-123` en mayúsculas, no trunca a `AUL-12`, y al no existir avisa sin crear nada |
| **E7** | `git bisect` en curso, HEAD desacoplado, el usuario dice "actualizá Jira". | `git branch --show-current` vacío ⇒ se comporta como rama sin clave: no toca nada |
| **E8** | Rama `feat/AUL-6-cargar-datos-del-periodo`, donde `AUL-6` es el **Epic** de la Fase 1. | No mueve el epic. Avisa que la clave de una rama tiene que ser una historia o tarea, no un epic |
| **E9** | `AUL-9` está en *En revisión* y su PR se cerró sin mergear. | Lo dice; **no** retrocede el estado por su cuenta |
| **E10** | Dejó la subtarea "modelo de datos" en *En curso*, no la terminó, y pasa a trabajar otro paso de la misma Historia. | O la finaliza si está hecha, o la devuelve a *Tareas por hacer* (transición `11`). No deja dos subtareas *En curso* |

- [ ] **Step 3: Correr el baseline, un subagente por escenario**

La skill **todavía no existe**, que es justo la condición del baseline. Dos cuidados:

1. El prompt del subagente lleva el escenario y nada más. Se le agrega: *"No leas
   `docs/superpowers/` ni `.agents/skills/`"* — ahí está la respuesta y el baseline se contamina.
2. Se anota **textual** qué hizo y con qué excusas lo justificó. Las excusas verbatim son la
   materia prima de la tabla de racionalizaciones de la Tarea 5.

Herramienta: `Agent` con `subagent_type: "general-purpose"`, uno por escenario, la salida cruda a
`$SCRATCHPAD/baseline/E1.md` … `E10.md`.

- [ ] **Step 4: Descartar los escenarios que no fallan**

Si en E*n* el agente ya hace lo correcto sin la skill, **esa parte de la skill no se escribe**.
Se anota "no falla en baseline — no se documenta" y se saca de la lista de la Tarea 4. Es la regla
del control sin guía de `writing-skills`: si el control no exhibe la falla, no hay nada que
arreglar.

- [ ] **Step 5: Volcar el baseline a `verificacion.md` y commitear**

Cada escenario con su columna "Baseline (2026-…): qué hizo / qué dijo", citando textual.

```bash
git add .agents/skills/trabajar-con-jira/verificacion.md
git commit -m "AUL-25: escenarios de verificación y baseline sin la skill (RED)"
```

Y la subtarea 1 de `AUL-25` a *Finalizada* (transición `41`).

---

### Task 2: Decisión 0024

Va **antes** de escribir el contrato: `AGENTS.md` dice que antes de codificar una decisión nueva se
escribe en `docs/decisiones/`.

**Files:**
- Create: `docs/decisiones/0024-el-estado-de-jira-lo-mueve-el-agente-desde-hechos-de-git.md`
- Modify: `docs/decisiones/README.md` (fila nueva en el índice)

**Interfaces:**
- Consumes: la spec entera; en particular §9 (alternativas descartadas) y §10 (señal de revisión).
- Produces: el número `0024`, que la §7 y la skill citan.

- [ ] **Step 1: Confirmar que 0024 está libre**

```bash
/usr/bin/grep -rnoE '(decisi[oó]n|ADR)[ -]?0024' --exclude-dir=.git . | head
```
Esperado: solo las citas de la spec y de este plan, ningún archivo `0024-*.md`. Si aparece otro, se
usa el siguiente libre y se corrige la spec.

- [ ] **Step 2: Escribir la decisión con el formato fijo del repo**

Formato obligatorio (`docs/decisiones/README.md` §Plantilla): **Contexto** con las alternativas
descartadas, cada una con su punto fuerte y por qué se descarta → **Decisión** en presente, con la
procedencia de cada número → **Consecuencias** con A favor, En contra y Riesgo abierto **con su
señal**. Los dos errores que vacían un registro: documentar solo lo elegido, y consecuencias solo
favorables.

Contenido, traído de la spec:

- **Contexto:** 20 issues cargadas a mano, todo lo posterior manual y por lo tanto desactualizado
  (hoy `AUL-7`, `AUL-8` y `AUL-10` están en *En revisión* esperando el mismo PR #1 y ninguna issue
  del proyecto tiene subtareas). Alternativas descartadas, de la spec §9: el recordatorio en el hook
  de pre-push (mete una llamada de red en la puerta de calidad); el comando propio contra la API
  REST (un token por persona, duplica el MCP); solo `convenciones.md` sin skill (no se dispara);
  todo automático incluida la creación de issues (Jira lleno de issues que nadie pidió).
- **Decisión,** con procedencia de cada número:
  1. El estado sale de hechos verificables de git. *Procedencia: criterio propio declarado.*
  2. Los ids `10000`–`10003` y `11`/`21`/`31`/`41`. *Procedencia: API del proyecto AUL, leída el
     2026-09-30.*
  3. *Finalizada* sale únicamente de un merge. *Procedencia: deducción — es el único movimiento
     caro de deshacer y el único que ya tiene una puerta humana detrás, la aprobación del PR
     (decisión 0014).*
  4. El árbol Historia → Tarea → subtarea. *Procedencia: el criterio de capacidad demostrable ya
     vigente en `plan-de-fases.md`, más "¿merece rama y PR propios?" como corte, decidido el
     2026-09-30.*
  5. Entre 2 y 6 subtareas por Historia; más de 8 significa mal partida. *Procedencia: criterio
     propio declarado, sin ancla externa — se revisa con la señal de abajo.*
  6. El estado *En curso* de una subtarea es la única excepción a "todo sale de git", acotada por
     dos invariantes. *Procedencia: criterio propio, decidido en la revisión de la spec del
     2026-09-30.*
  7. La skill existe además de §7, saliéndose de la letra de `writing-skills`, solo por el disparo.
     *Procedencia: criterio propio declarado.*
- **Consecuencias.** A favor: el seguimiento deja de depender de que alguien se acuerde; el plan
  sigue siendo el documento que cuenta qué hace el sistema. En contra: hay un contrato más que
  mantener; el agente que no tenga MCP de Jira queda haciéndolo a mano; y el agente **no puede
  borrar issues**, así que una creada por error se corrige a mano. Riesgo abierto y su señal:
  la spec §10 — si hay que arreglar a mano lo que el agente dejó mal más de una vez por fase, o si
  Codex y Antigravity terminan operando Jira a mano de forma habitual, se reconsidera el comando
  propio de la spec §9.
- **Enlaces:** `[[0014]]`, `[[0016]]`, `[[0018]]` (no las modifica: se apoya en ellas).

- [ ] **Step 3: Agregar la fila al índice de `docs/decisiones/README.md`**

```markdown
| [0024](0024-el-estado-de-jira-lo-mueve-el-agente-desde-hechos-de-git.md) | El estado de Jira lo mueve el agente desde hechos verificables de git, y el trabajo no planificado entra al plan antes que a Jira | Aceptada |
```

- [ ] **Step 4: Verificar que no quedó ningún número sin procedencia**

```bash
/usr/bin/grep -nE '[0-9]' docs/decisiones/0024-*.md | /usr/bin/grep -iv 'procedencia'
```
Leer la salida a mano: todo número de la sección **Decisión** tiene que tener su procedencia en la
misma entrada. Un número sin procedencia es una decisión postergada disfrazada (decisión 0010).

- [ ] **Step 5: Commit**

```bash
git add docs/decisiones/0024-*.md docs/decisiones/README.md
git commit -m "AUL-25: decisión 0024, el estado de Jira sale de hechos de git"
```

Subtarea 2 de `AUL-25` a *Finalizada*; subtarea 3 a *En curso*.

---

### Task 3: `convenciones.md` §7 "Jira" — el contrato

**Files:**
- Modify: `docs/convenciones.md` (sección nueva §7, después de §6 "Herramientas de IA en el código",
  que hoy es la última)

**Interfaces:**
- Consumes: la decisión `0024` de la Tarea 2.
- Produces: la §7, que la skill cita por número (`convenciones.md §7`) y no copia.

- [ ] **Step 1: Escribir la §7 con cinco subsecciones**

Las tablas se traen **tal cual** de la spec, que es su fuente:

| Subsección | Contenido | De dónde |
|---|---|---|
| 7.1 Qué hay en Jira | Un epic por fase, una historia por `HU-N.M`, las definiciones como tareas `definicion`, el cierre como tarea `cierre`. Remite a `docs/jira/README.md` para la correspondencia HU ↔ clave | ya existe en `plan-de-fases.md` §"Cómo cargar esto en Jira": **se cita, no se duplica** |
| 7.2 Estado y asignación | La tabla hecho → movimiento y las cinco reglas | spec §5 |
| 7.3 Trabajo que el plan no contempla | El árbol de tres pasos, la regla plan-primero, la cascada de dónde cuelga | spec §6 |
| 7.4 Subtareas | Cuándo se crean, granularidad 2–6 (más de 8 = mal partida), los dos invariantes del estado *En curso*, y que un caso borde no es una subtarea | spec §5 y §6 |
| 7.5 Cuando Jira no está | La tabla de degradados, encabezada por **Jira nunca bloquea el trabajo** | spec §7 |

Estilo: prosa y tablas, **sin nombres de herramienta** y sin ids de transición. Eso es
procedimiento y va en la skill. Cita `[decisión 0024](decisiones/0024-….md)`.

- [ ] **Step 2: Actualizar la fecha del encabezado de `convenciones.md`**

La línea `**Última actualización:**` del tope del archivo pasa a `2026-09-30 — §7 Jira`.

- [ ] **Step 3: Verificar que no hay regla duplicada**

```bash
/usr/bin/grep -n 'Cómo cargar esto en Jira' -A 12 docs/plan-de-fases.md
```
Si la §7 repite lo que esa sección ya dice, se borra de la §7 y se la cita. Una regla, un lugar.

- [ ] **Step 4: Commit**

```bash
git add docs/convenciones.md
git commit -m "AUL-25: convenciones §7, el contrato de Jira para los tres agentes"
```

Subtarea 3 a *Finalizada*; subtarea 4 a *En curso*.

---

### Task 4: La skill `trabajar-con-jira` (GREEN)

**Files:**
- Create: `.agents/skills/trabajar-con-jira/SKILL.md`
- Modify: `.agents/skills/trabajar-con-jira/verificacion.md` (columna GREEN)

La skill que la spec §4 define como "el procedimiento".

**Interfaces:**
- Consumes: el baseline de la Tarea 1 (qué falla y con qué excusas); la §7 de la Tarea 3.
- Produces: la skill que las Tareas 5 y 6 ajustan y enganchan.

- [ ] **Step 1: Escribir el frontmatter, exacto**

```yaml
---
name: trabajar-con-jira
description: Use when working in the Aulero UNViMe repository and a branch, commit, pull request or merge touches an AUL issue; when work appears that the phase plan does not contain; or when a story is about to be split into subtasks.
---
```

Por qué así: tercera persona, arranca con `Use when`, **solo disparo**. Si dijera "crea historias y
mueve estados", el agente seguiría la descripción en vez de leer el cuerpo — está documentado en
`writing-skills`. El nombre en infinitivo sigue a las dos skills hermanas del equipo
(`avanzar-por-fases`, `registrar-decisiones`).

- [ ] **Step 2: Escribir el cuerpo, por debajo de 500 palabras**

Secciones, en este orden:

1. **Principio,** dos frases: el estado sale de hechos de git, no de la conversación; **el contrato
   está en `docs/convenciones.md` §7 y acá no se repite**.
2. **Los cuatro momentos de disparo:** empezar a trabajar algo, abrir el PR, mergear, y descubrir
   trabajo que el plan no contempla.
3. **Quick Reference,** la única tabla, con lo que §7 no puede tener porque es procedimiento:

   | Hecho | Movimiento | Transición |
   |---|---|---|
   | Rama `<tipo>/AUL-n-…` y la issue en *Tareas por hacer* | → En curso + asignar | `21` |
   | PR abierto (`gh pr view --json state`) | → En revisión | `31` |
   | PR mergeado a `main` | → Finalizada | `41` |
   | Subtarea: arranca su paso | → En curso | `21` |
   | Subtarea: paso hecho y verificado | → Finalizada | `41` |
   | Subtarea que el agente puso En curso y no terminó | → Tareas por hacer | `11` |

4. **Cómo saca la clave,** una línea, porque es mecánico:

   ```bash
   git branch --show-current | /usr/bin/grep -oE 'AUL-[0-9]+' | head -1 | tr 'a-z' 'A-Z'
   ```
   Vacío ⇒ no hay nada que hacer. `AUL-[0-9]+` delimitado no trunca `AUL-123` a `AUL-12`, y el `tr`
   acepta una rama escrita en minúsculas (Review Focus 3 y 4).

5. **Llamadas MCP:** `cloudId` = `aulero.atlassian.net`; `getJiraIssue`, `transitionJiraIssue`,
   `editJiraIssue` para asignar, `createJiraIssue` con `parent` para subtareas. **No hay borrado.**
6. **Lo que no hace:** no retrocede un estado (salvo la subtarea propia), no toca epics, no mueve
   una clave que no salga de la rama actual, no bloquea el trabajo si Jira no responde, no crea
   issues sin preguntar. En particular, **un PR cerrado sin mergear no retrocede la issue**: la deja
   en *En revisión* y lo dice, porque alguien puede estar esperando esa revisión (Review Focus 5).

Todo lo demás —el árbol, la cascada, los invariantes, la tabla de degradados— **se referencia**:
`Las reglas están en docs/convenciones.md §7.`

- [ ] **Step 3: Verificar el tamaño y el frontmatter**

```bash
wc -w .agents/skills/trabajar-con-jira/SKILL.md
head -5 .agents/skills/trabajar-con-jira/SKILL.md | wc -c
```
Esperado: menos de 500 palabras; frontmatter por debajo de 1024 caracteres.

- [ ] **Step 4: Correr los mismos escenarios, ahora CON la skill**

Los que sobrevivieron al Step 4 de la Tarea 1. Mismo prompt, misma herramienta, sin la instrucción
de no leer `.agents/skills/` — ahora se quiere que la encuentre. Salida a
`$SCRATCHPAD/green/E*.md`.

Esperado: cumple el comportamiento esperado de cada escenario. **Si uno falla, no se "adapta" el
escenario**: se arregla la skill.

- [ ] **Step 5: Volcar los resultados a `verificacion.md` y commitear**

```bash
git add .agents/skills/trabajar-con-jira/
git commit -m "AUL-25: skill trabajar-con-jira y verificación con la skill (GREEN)"
```

Subtarea 4 a *Finalizada*; subtarea 5 a *En curso*.

---

### Task 5: Cerrar agujeros (REFACTOR)

**Files:**
- Modify: `.agents/skills/trabajar-con-jira/SKILL.md` (tabla de excusas + red flags)
- Modify: `.agents/skills/trabajar-con-jira/verificacion.md` (iteraciones)

**Interfaces:**
- Consumes: las excusas verbatim de las Tareas 1 y 4.
- Produces: la skill final.

- [ ] **Step 1: Juntar las racionalizaciones de todas las corridas**

De `$SCRATCHPAD/baseline/` y `$SCRATCHPAD/green/`, **citadas textual**. Las esperables, a confirmar
o descartar con lo que realmente haya salido:

| Excusa | Realidad |
|---|---|
| "Lo anoto y lo muevo al final" | El final no llega: así quedaron tres issues en *En revisión* esperando el mismo PR |
| "Es un cambio chico, no amerita una issue" | El tamaño no decide: lo decide el árbol de §7 |
| "Lo creo en Jira y lo escribo en el plan después" | El orden es la regla, no un detalle: si Jira va primero, el plan no se escribe nunca |
| "Hago una subtarea por caso borde, así no se olvida ninguno" | Para eso está el test que los nombra; veinte subtareas no se leen |
| "Jira no responde, mejor paro hasta poder registrarlo" | Jira nunca bloquea el trabajo: se dice qué falta y se sigue |

- [ ] **Step 2: Escribir la tabla de excusas y los red flags en `SKILL.md`**

Red flags en primera persona, como los escribe `writing-skills`, para que el agente se
autodetecte: "ya terminé, después muevo Jira", "esto es muy chico para una issue", "el plan lo
actualizo cuando cierre la fase".

Ojo con el presupuesto de palabras: la tabla entra, pero si `SKILL.md` pasa de 500 palabras, la
tabla de excusas se muda a `racionalizaciones.md` al lado y `SKILL.md` la referencia como
**REQUIRED**.

- [ ] **Step 3: Re-correr los escenarios que habían fallado**

Solo esos. Esperado: cumplen. Si aparece una racionalización nueva, vuelve al Step 1. Se itera
hasta que no aparezcan nuevas.

- [ ] **Step 4: Commit**

```bash
git add .agents/skills/trabajar-con-jira/
git commit -m "AUL-25: cerrar las racionalizaciones que aparecieron en la verificación (REFACTOR)"
```

Subtarea 5 a *Finalizada*; subtarea 6 a *En curso*.

---

### Task 6: Enganches y pull request

**Files:**
- Modify: `AGENTS.md` (sección "Dónde está cada cosa" y "Reglas que no se rompen")
- Modify: `docs/README.md` (qué es `docs/superpowers/`)
- Modify: `docs/jira/README.md` (quién mantiene la tabla; `AUL-24` y `AUL-25`)

**Interfaces:**
- Consumes: todo lo anterior.
- Produces: el PR.

- [ ] **Step 1: `AGENTS.md`**

En "Dónde está cada cosa", una línea: **Flujo de Jira:** `docs/convenciones.md` §7. En "Reglas que
no se rompen", una línea: el trabajo que el plan no contempla se escribe en `plan-de-fases.md`
antes de entrar a Jira (§7, decisión 0024). `AGENTS.md` es un puntero: **una línea cada una, sin
copiar la regla.**

- [ ] **Step 2: `docs/README.md`**

Una línea diciendo que `docs/superpowers/specs/` y `docs/superpowers/plans/` son los diseños y
planes de implementación de la metodología `superpowers`, no documentos vivos del proyecto.

- [ ] **Step 3: `docs/jira/README.md`**

Tres cosas: que la tabla ahora la mantiene el agente al crear issues (§7); la fila de `AUL-25`; y
que `AUL-24 "Test"` **se borra a mano desde la interfaz**, porque el MCP no expone borrado.

- [ ] **Step 4: Lo que NO se toca, y por qué**

Para que quien revise no lo pida:
- **`docs/plan-de-fases.md`:** `AUL-25` es andamio, y las Tareas de andamio no van al plan (§7).
- **`docs/informe-de-gestion.md`:** no hay capacidad nueva para el usuario del sistema; esto es
  proceso del equipo.
- **`docs/arquitectura.md`:** no hay módulo, tabla ni interfaz nueva. Sin deuda que anotar.
- **`docs/jira/fases-0-y-1.csv`:** es el registro de lo importado el 2026-09-16, no un espejo.

- [ ] **Step 5: Verificación completa, con la salida a la vista**

```bash
cd /home/pablo/Projects/proyecto-final
wc -w .agents/skills/trabajar-con-jira/SKILL.md
/usr/bin/grep -c 'AUL-25' docs/jira/README.md AGENTS.md
uv run ruff check . && uv run pytest -q
```
Pegar la salida real. "La corrí hace un rato y pasaba" no es haber verificado.

- [ ] **Step 6: Push y PR**

El hook de pre-push corre lint, tests y la revisión del agente sobre el diff acumulado. **Sin
`--no-verify`.** La salida queda en `.review/ultima.md` y va pegada en la descripción del PR: un PR
sin la revisión del agente pegada no se aprueba (`convenciones.md` §2.1).

```bash
git push -u origin chore/AUL-25-flujo-de-jira-del-agente
gh pr create --title "Flujo de Jira operado por el agente desde hechos de git" --body-file -
```

Título del PR = el de `AUL-25`. El cuerpo dice qué cambia, cómo probarlo (correr los escenarios de
`verificacion.md`) y qué casos borde cubre, más la salida de `.review/ultima.md`.

- [ ] **Step 7: Jira, con la regla aplicada a sí misma**

PR abierto ⇒ `AUL-25` a *En revisión* (transición `31`). **No** a *Finalizada*: eso lo dispara el
merge, y antes la regla 3 pide que no queden subtareas abiertas. Las seis subtareas tienen que
estar en *Finalizada* a esta altura.

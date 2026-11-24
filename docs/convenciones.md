# Convenciones del proyecto

> Público: todo el equipo. Qué reglas de estilo, revisión y accesibilidad rigen el código.
> Las decisiones de diseño **no** van acá: van en [`decisiones/`](decisiones/README.md).
>
> **Última actualización:** 2026-09-30 — §7 Jira: el estado lo mueve el agente desde hechos de git
> (decisión 0024).

## 1. Ramas y pull requests

- Remoto en **GitHub**. `main` está protegida: no admite push directo. Todo entra por pull
  request ([decisión 0014](decisiones/0014-la-revision-de-codigo-tiene-dos-puertas-agente-en-ci-y-persona-antes-de-mergear.md),
  modificada por [0016](decisiones/0016-la-revision-del-agente-corre-en-un-hook-local-antes-del-push.md)).
- Ramas cortas, una por historia de usuario: `<tipo>/<clave-jira>-<descripcion-corta>`, por
  ejemplo `feat/AUL-14-importar-excel`, `fix/AUL-15-validacion-docente`. Tipos: `feat`, `fix`,
  `docs`, `chore`, `refactor`, `test`.
- Mensajes de commit en español, imperativo, con la clave de Jira: `AUL-12: importar hoja de
  comisiones`. El cierre de cada fase lleva un commit `Fase N — Nombre` (ver `plan-de-fases.md`).
- Un PR por historia. El título del PR es el título de la historia. La descripción dice qué
  cambia, cómo probarlo y qué casos borde cubre.

## 2. Las dos puertas de revisión

### 2.1 Revisión del agente (hook local de pre-push)

Corre en la máquina de quien pushea, sobre el diff entre `origin/main` y lo que se va a subir
(decisión 0016). **Si hay hallazgos bloqueantes, el push no sale.** El hook está en
`.githooks/pre-push`; se activa una vez por clon con `git config core.hooksPath .githooks` (lo
dice el README). El agente es el que tenga cada integrante —Claude Code, Codex, `agy`
(Antigravity) o Gemini CLI— vía `.githooks/agente.sh` y `AULERO_AGENTE` (decisiones 0018 y
0022); el prompt y el criterio son los mismos para todos. Revisa el diff con foco en, en este
orden:

1. **Correctitud:** bugs, casos borde sin manejar, condiciones de carrera, errores de tipo.
2. **Contratos:** cambios en el formato de instancia/solución del solver o en los `schemas` de la
   API sin actualizar su documentación y sus tests.
3. **Convenciones de este documento:** capas del backend, estructura del frontend, accesibilidad.
4. **Tests:** cada caso borde nombrado en la historia tiene un test que lo nombra.
5. **Decisiones:** si el cambio toma una decisión de diseño con alternativa real, existe su
   registro en `decisiones/` (o el diff lo agrega).

Es **bloqueante** un hallazgo de correctitud o de contrato, y un caso borde nuevo sin test que
lo nombre. Es **no bloqueante** una sugerencia de estilo, simplificación o nombre. El prompt
exacto está en `.githooks/revision-prompt.md`; si se cambia el criterio, se cambian los dos. Ante un bloqueante, el autor lo corrige y vuelve a pushear (el hook
revisa de nuevo), o —si no aplica— lo marca como descartado con el motivo en la salida y ese
motivo queda en el PR.

El hook guarda la salida de la última revisión en `.review/` (ignorado por git). **El autor pega
esa salida en la descripción del PR**: es la evidencia de que la puerta se pasó, y quien revisa
la pide si falta. Un PR sin la revisión del agente pegada no se aprueba.

`git push --no-verify` existe y saltea el hook. No se usa. Si alguna vez hace falta (por ejemplo,
el agente caído), se dice en el PR y la persona que revisa lo hace con más cuidado.

### 2.2 Revisión humana (antes del merge)

Una persona distinta del autor aprueba el PR. Lo que revisa, además de lo que ya dijo el agente:

- Que el cambio hace lo que la historia pide, ni más ni menos.
- Que las decisiones de diseño que aparecieron están registradas en `decisiones/`.
- Que la documentación viva se tocó si la fase lo requería.

No se aprueba un PR "para no trabar": si no hay tiempo de revisarlo, se dice y se espera.

### 2.3 CI (GitHub Actions, sobre el PR)

Corre lint, formato y tests de cada parte tocada, la regla de que `solver/` no importa
`backend/`, y los tests del propio hook cuando cambia `.githooks/`. Sin agente. El check
obligatorio para mergear es **`CI OK`**, junto con la aprobación humana. El mismo hook de
pre-push corre lint y tests antes del agente, para no gastar una revisión sobre código que no
compila.

## 3. Estilo y linters

Cada parte del monorepo tiene su linter y su formateador; **CI falla si cualquiera de ellos
falla**. No se discute estilo en los PRs: lo decide la herramienta.

Versiones base ([decisión 0017](decisiones/0017-las-versiones-base-son-python-3-14-y-node-24-lts.md)):
**Python 3.14** (`backend/`, `solver/`) y **Node 24 LTS** (`frontend/`), fijadas en `mise.toml` /
`.python-version` / `.nvmrc` y en `pyproject.toml` / `package.json`. CI usa exactamente esas.

### 3.1 `backend/` y `solver/` (Python)

| Herramienta | Para qué | Configuración |
|---|---|---|
| **Ruff** | lint y formato (reemplaza flake8, isort, black) | `pyproject.toml` de la raíz, común a los dos paquetes; reglas `E, F, W, I, N, UP, B, SIM, RUF` |
| **mypy** | tipos, modo estricto | `pyproject.toml` de cada paquete; `strict = true` |
| **pytest** | tests | `tests/` junto a cada paquete; se corre desde la raíz |
| **import-linter** | `solver/` no importa `backend/` ni FastAPI/SQLAlchemy | `pyproject.toml` de la raíz |

Los dos paquetes viven en un *workspace* de `uv` (un solo `uv sync`, un solo `uv.lock`).

Reglas que van más allá del linter:

- Todo función pública lleva anotaciones de tipo. Sin `Any` salvo justificación en comentario.
- Nombres en inglés en el código; dominio en español en la documentación y en los mensajes al
  usuario. Las entidades del dominio se nombran igual en todas partes (`Comision`, `Dictado`,
  `Aula`, `Docente`, `Materia`, `Carrera`, `Periodo`) — se admite el español en identificadores
  de dominio para no traducir dos veces.
- En `solver/`: ninguna importación de `backend/`. Se verifica con una regla de import-linter en
  CI.
- Un test por caso borde nombrado, con el nombre del caso en el nombre del test:
  `test_docente_sin_no_disponibilidad_puede_dictar_cualquier_bloque`.

### 3.2 `frontend/` (TypeScript + React)

| Herramienta | Para qué | Configuración |
|---|---|---|
| **ESLint** | lint, con `typescript-eslint`, `eslint-plugin-react-hooks` y `eslint-plugin-jsx-a11y` | `eslint.config.js` (flat config) |
| **Prettier** | formato | `.prettierrc`; ESLint no revisa formato |
| **TypeScript** | `strict: true`, `noUncheckedIndexedAccess: true` | `tsconfig.json` |
| **Vitest + Testing Library** | tests de componentes y hooks | `*.test.tsx` junto al componente |
| **axe-core** (`vitest-axe`) | accesibilidad automática en tests de componentes | ver §4 |

Reglas que van más allá del linter:

- Componentes funcionales, sin clases. Un componente por archivo, nombre en PascalCase igual al
  archivo.
- Estado de servidor con TanStack Query; no se copia a estado local lo que viene de la API.
- Los tipos de la API se generan desde el OpenAPI de FastAPI (`openapi-typescript`), no se
  escriben a mano.

### 3.3 Documentación

- Markdown, líneas de hasta 100 caracteres, en español.
- Las decisiones se citan por número (`decisión 0006`) y con enlace al archivo.

## 4. Accesibilidad web

Objetivo: **WCAG 2.2 nivel AA** en lo básico, verificado con herramientas y a mano. Es un
requisito de cada historia del frontend, no una fase aparte.

Lo que se verifica en cada PR de frontend:

- **Automático (CI):** `eslint-plugin-jsx-a11y` en lint; `axe-core` en los tests de cada
  componente de página (sin violaciones de nivel *serious* o *critical*).
- **Manual (revisión humana, checklist en el PR):**
  - Toda la funcionalidad se puede usar solo con teclado; el foco es visible y sigue un orden
    lógico.
  - Toda imagen o ícono con significado tiene texto alternativo; los decorativos, `alt=""`.
  - Todo campo de formulario tiene `label` asociado; los errores de validación se anuncian junto
    al campo y se leen con lector de pantalla.
  - Contraste mínimo 4,5:1 para texto y 3:1 para elementos de interfaz.
  - **La información no se transmite solo por color.** Esto importa especialmente en la grilla
    de horarios: cada bloque lleva texto (materia, comisión, aula), no solo un color.
  - Las tablas de datos usan `<table>` con encabezados; la grilla horaria es navegable como tabla
    (día × bloque) y tiene una vista alternativa en lista para lectores de pantalla.
  - El zoom al 200 % no rompe la disposición ni oculta contenido.
  - Idioma declarado (`lang="es"`), títulos de página únicos por vista.

## 5. Tests

- **`solver/`:** tests unitarios por restricción (cada Rn tiene su archivo), tests de casos borde
  nombrados, un test de integración por instancia de referencia (juguete) que corre el solver y
  el validador. El validador se prueba contra soluciones inválidas construidas a mano.
- **`backend/`:** tests de la API con `TestClient` y una base PostgreSQL efímera (Docker en CI);
  tests de la conversión BD ↔ instancia/solución contra el formato publicado por `solver/`.
- **`frontend/`:** tests de componentes con Testing Library; se prueban comportamientos, no
  implementación.
- Ninguna fase se cierra con un caso borde sin su test nombrado (`plan-de-fases.md`).

## 6. Herramientas de IA en el código

- Cada integrante usa el agente que tiene (Claude Code, Codex, Antigravity). El contexto del
  proyecto para todos está en `AGENTS.md` (decisión 0018); nada que un agente necesite saber va
  en otro lado.
- El agente revisa; las personas deciden. Un hallazgo del agente se responde, no se obedece sin
  leerlo.
- Código generado con asistencia se revisa igual que el escrito a mano, con la misma puerta.
- Las decisiones que el agente proponga durante una tarea se registran en `decisiones/` antes de
  implementarlas, igual que las de cualquier integrante.
- **Las skills del proyecto viven en `.agents/skills/`**, versionadas en el repo: es la ruta que
  reconocen Claude Code, Codex, Copilot CLI y Gemini CLI, así que una sola copia sirve a los tres
  agentes del equipo (decisión 0018). No van en `.claude/skills/` ni en el directorio personal de
  nadie: ahí las vería un solo integrante. Una skill es **procedimiento** —cuándo despertar, qué
  llamada hacer—; las reglas van en este documento, y la skill las referencia.

## 7. Jira

Proyecto **AUL** en https://aulero.atlassian.net. El estado de las issues no se mantiene a mano:
lo mueve el agente de cada integrante desde hechos verificables de git
([decisión 0024](decisiones/0024-el-estado-de-jira-lo-mueve-el-agente-desde-hechos-de-git.md)).
Esta sección es el contrato, igual para los tres agentes. El procedimiento —qué llamada, qué id de
transición— es de cada herramienta y vive en su skill: para Claude Code, en
[`.agents/skills/trabajar-con-jira/`](../.agents/skills/trabajar-con-jira/SKILL.md) (§6).

### 7.1 Qué hay en Jira

Qué issue le corresponde a cada cosa lo fija [`plan-de-fases.md`](plan-de-fases.md) §"Cómo cargar
esto en Jira", y no se repite acá. Lo que esta sección agrega es **quién lo mantiene y cuándo**.

La correspondencia HU ↔ clave se mantiene en [`jira/README.md`](jira/README.md), **y la actualiza el
agente al crear una issue**. El CSV `jira/fases-0-y-1.csv` no se toca: es el registro de lo que se
importó el 2026-09-16 y el formato para cargar las fases siguientes, no un espejo del estado.

### 7.2 Estado y asignación

Los estados son *Tareas por hacer* → *En curso* → *En revisión* → *Finalizada*. Cada movimiento
cuelga de un hecho que se puede comprobar, no de lo que se dijo en una conversación:

| Hecho verificable | Movimiento | Asignación |
|---|---|---|
| La rama actual es `<tipo>/AUL-n-…` y la issue está en *Tareas por hacer* | → *En curso* | a quien está trabajando; si estaba otra persona, se reasigna **y se avisa** |
| Hay un PR abierto para esa rama | → *En revisión* | sin cambio |
| El PR se mergeó a `main` | → *Finalizada* | sin cambio |
| Un PR **cuya rama ya no existe** se mergeó (GitHub la borra al mergear) | → *Finalizada* | sin cambio |

Cinco reglas:

1. **No se retrocede un estado.** Si la issue está más avanzada que el hecho, se avisa y no se
   toca: retroceder borra información que alguien más ya usó. Única excepción, en §7.4.
2. **Solo se tocan las claves que salen de un hecho a la vista:** la rama actual, las **subtareas**
   de esa issue, o un **PR mergeado** que el agente está viendo. Lo que no se hace es buscar en Jira
   issues "que parecen pendientes" y moverlas por parecido. Sin ninguno de esos hechos —`main` sin
   un merge reciente, una rama de exploración, HEAD desacoplado— no hay movimiento.

   El PR mergeado está en la lista porque, si no, el cierre se vuelve inalcanzable justo en el caso
   normal: quien mergea lo hace desde la interfaz de GitHub, que borra la rama, y entonces ninguna
   rama vuelve a traer esa clave nunca más. Las claves de una subtarea tampoco aparecen en el nombre
   de una rama, y sin esta aclaración la §7.4 no se podría cumplir.
3. **Una Historia no pasa a *Finalizada* con subtareas abiertas.** Se avisa: casi siempre
   significa que algo quedó sin hacer.
4. **Las subtareas completas no cierran la Historia.** El cierre lo dispara el merge, que es la
   puerta que ya existe (§2.2).
5. **El epic de una fase lo cierra su tarea `cierre`**, con el checklist de `plan-de-fases.md`, no
   el último PR de la fase. Un epic no se transiciona por tener una rama con su clave: si una rama
   cita la clave de un epic, está mal nombrada.

*Finalizada* es el único estado que no sale de otra cosa que un merge, porque es el único
movimiento caro de deshacer y el único que ya tiene una puerta humana detrás.

### 7.3 Trabajo que el plan no contempla

Cuando aparece trabajo que `plan-de-fases.md` no tiene, se clasifica con tres preguntas, en orden:

1. ¿Al terminar hay algo que alguien puede hacer o ver y antes no podía? → **Historia**, con "Como
   X quiero Y para Z" y criterios de aceptación.
2. Si no, ¿merece su propia rama y su propio PR? → **Tarea** del epic de la fase.
3. Si tampoco → **subtarea** de la Historia o Tarea dentro de la que cae.

El tamaño estimado no decide: dos personas lo estiman distinto. Lo que decide es la capacidad
demostrable y, si no la hay, si merece rama propia.

**Una Historia se escribe primero en `plan-de-fases.md` y después en Jira**, con sus casos borde
nombrados, y después se agrega la fila en `jira/README.md`. El orden es la regla: si Jira va
primero, el plan no se escribe nunca y deja de contar lo que el sistema hace. **Las Tareas de
andamio no van al plan** —no describen una capacidad— y la deuda que dejen va a `arquitectura.md`.

Dónde cuelga:

| El trabajo es… | Va a |
|---|---|
| de la fase en curso | el epic de esa fase |
| de una fase futura **ya cargada** en Jira | ese epic |
| de una fase futura **no cargada** todavía | solo al plan; Jira se carga al llegar a la fase |
| de ninguna fase (infraestructura, chore, arreglo) | Tarea en el epic de la fase en curso, etiqueta `no-planificado` |
| una definición pendiente que apareció | Tarea etiqueta `definicion`, que se cierra registrando la decisión **antes** de las historias que dependen de ella |

El andamio pertenece a la fase en la que apareció: así el epic cuenta lo que la fase realmente
costó, y no hace falta un epic huérfano permanente.

**Crear una Historia o una Tarea siempre se pregunta.** Mover un estado no. La razón es que una
issue mal creada no se puede borrar desde un agente: se corrige a mano desde la interfaz.

Las **subtareas no se preguntan una por una**: son la partición de un trabajo que ya se aprobó,
viven dentro de su issue padre y no cambian el alcance de nada. Lo que se dice, en una línea, es qué
subtareas se crearon.

### 7.4 Subtareas

Se crean **al empezar la Historia**, derivadas de sus criterios de aceptación, y se siguen
agregando si el alcance cambia en el medio; si el pedazo nuevo merece rama y PR propios, ya no es
subtarea (§7.3).

- **Entre 2 y 6 por Historia.** Más de 8 significa que la Historia estaba mal partida, y eso se
  dice en vez de crear nueve. **Estos tres números viven acá y en ningún otro lado**: la decisión
  0024 registra de dónde salen (criterio propio, sin medición) y la skill de cada agente los cita
  apuntando a esta línea.
- **Un caso borde no es una subtarea.** Los casos borde viven en la descripción de la Historia y su
  contrato es un test que los nombra (§5). "Tests de los casos borde" sí puede ser una subtarea;
  "el Excel vacío" no.
- **A lo sumo una subtarea *En curso* por Historia.** Si hay dos, se dice: quien trabaja perdió el
  hilo de en qué paso está.
- **No se deja una subtarea *En curso* al pasar a otro paso.** O se finaliza, o vuelve a *Tareas
  por hacer* — la única excepción a la regla 1 de §7.2, y vale solo para una subtarea que el propio
  agente puso *En curso*: es su anotación y nadie más la usó. Una subtarea *En curso* que nadie
  está tocando miente peor que una en *Por hacer*.

El estado *En curso* de una subtarea es lo único que no sale de un hecho de git: nada en git
distingue cuándo empieza una subtarea de cuándo empieza otra de la misma rama. La excepción se
acepta porque ver una subtarea en curso es la mitad del valor de tenerlas, y los dos invariantes de
arriba son lo que la mantiene honesta.

### 7.5 Cuando Jira no está

**Jira nunca bloquea el trabajo.** Quien no tenga el conector de Atlassian, o lo tenga caído, no
deja de programar por eso:

| Situación | Qué se hace |
|---|---|
| Sin acceso a Jira (conector ausente o caído) | No se inventa ni se bloquea: una línea diciendo qué issue y qué movimiento faltan, y se sigue |
| Rama sin clave (`main` sin merge reciente, exploración, HEAD desacoplado) | Nada, y **sin avisar**: no es una anomalía |
| La clave de la rama no existe en Jira | Se avisa; no se crea la issue ni se adivina una clave parecida |
| Dos claves en el nombre de la rama | Se pregunta |
| La issue está más avanzada que el hecho | Se avisa; no se retrocede |
| La clave de la rama es de un epic | No se toca el epic; la rama está mal nombrada (§7.2, regla 5) |

Un movimiento que no se pudo hacer se dice en el PR, igual que la salida de la revisión del agente:
quien revisa lo ve y lo arregla en un clic.

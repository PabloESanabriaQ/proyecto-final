# Convenciones del proyecto

> Público: todo el equipo. Qué reglas de estilo, revisión y accesibilidad rigen el código.
> Las decisiones de diseño **no** van acá: van en [`decisiones/`](decisiones/README.md).
>
> **Última actualización:** 2026-09-16 — convenciones iniciales, todavía sin código que las aplique.

## 1. Ramas y pull requests

- Remoto en **GitHub**. `main` está protegida: no admite push directo. Todo entra por pull
  request ([decisión 0014](decisiones/0014-la-revision-de-codigo-tiene-dos-puertas-agente-en-ci-y-persona-antes-de-mergear.md),
  modificada por [0016](decisiones/0016-la-revision-del-agente-corre-en-un-hook-local-antes-del-push.md)).
- Ramas cortas, una por historia de usuario: `<tipo>/<clave-jira>-<descripcion-corta>`, por
  ejemplo `feat/AUL-12-importar-excel`, `fix/AUL-30-validacion-docente`. Tipos: `feat`, `fix`,
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
dice el README). Revisa el diff con foco en, en este orden:

1. **Correctitud:** bugs, casos borde sin manejar, condiciones de carrera, errores de tipo.
2. **Contratos:** cambios en el formato de instancia/solución del solver o en los `schemas` de la
   API sin actualizar su documentación y sus tests.
3. **Convenciones de este documento:** capas del backend, estructura del frontend, accesibilidad.
4. **Tests:** cada caso borde nombrado en la historia tiene un test que lo nombra.

Es **bloqueante** un hallazgo de correctitud o de contrato. Es **no bloqueante** una sugerencia de
estilo o simplificación. Ante un bloqueante, el autor lo corrige y vuelve a pushear (el hook
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

Corre lint, formato y tests de cada parte tocada, y la regla de que `solver/` no importa
`backend/`. Sin agente. Es un check obligatorio para mergear, igual que la aprobación humana. El
mismo hook de pre-push corre lint y tests antes del agente, para no gastar una revisión sobre
código que no compila.

## 3. Estilo y linters

Cada parte del monorepo tiene su linter y su formateador; **CI falla si cualquiera de ellos
falla**. No se discute estilo en los PRs: lo decide la herramienta.

Versiones base ([decisión 0017](decisiones/0017-las-versiones-base-son-python-3-14-y-node-24-lts.md)):
**Python 3.14** (`backend/`, `solver/`) y **Node 24 LTS** (`frontend/`), fijadas en `mise.toml` /
`.python-version` / `.nvmrc` y en `pyproject.toml` / `package.json`. CI usa exactamente esas.

### 3.1 `backend/` y `solver/` (Python)

| Herramienta | Para qué | Configuración |
|---|---|---|
| **Ruff** | lint y formato (reemplaza flake8, isort, black) | `pyproject.toml` de cada paquete; reglas `E, F, W, I, N, UP, B, SIM, RUF` |
| **mypy** | tipos, modo estricto | `pyproject.toml`; `strict = true` |
| **pytest** | tests | `tests/` junto a cada paquete |

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

- El agente revisa; las personas deciden. Un hallazgo del agente se responde, no se obedece sin
  leerlo.
- Código generado con asistencia se revisa igual que el escrito a mano, con la misma puerta.
- Las decisiones que el agente proponga durante una tarea se registran en `decisiones/` antes de
  implementarlas, igual que las de cualquier integrante.

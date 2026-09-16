# Aulero UNViMe

Asignación de horarios y aulas (UCTP) para la carrera de Ingeniería en Sistemas de Información
de la UNViMe. Proyecto Final + PPS. OR-Tools CP-SAT · FastAPI · React · PostgreSQL.

- **Qué hace y en qué estado está:** [`docs/informe-de-gestion.md`](docs/informe-de-gestion.md)
- **Cómo está hecho:** [`docs/arquitectura.md`](docs/arquitectura.md)
- **Qué sigue:** [`docs/plan-de-fases.md`](docs/plan-de-fases.md)
- **Por qué está hecho así:** [`docs/decisiones/`](docs/decisiones/README.md)
- **Cómo trabajamos:** [`docs/convenciones.md`](docs/convenciones.md)

## Estructura

```
backend/   API FastAPI y persistencia (equipo PPS)          → paquete aulero_api
solver/    motor CP-SAT, independiente de la API (CP-SAT)   → paquete aulero_solver
frontend/  React + Vite + TypeScript (equipo PPS)
docs/      documentación viva, plan y decisiones
```

## Arranque en un clon nuevo

Requisitos: [mise](https://mise.jdx.dev) (instala Python 3.14, Node 24 y uv desde `mise.toml`),
[Docker](https://docs.docker.com/get-docker/) (PostgreSQL) y [Claude Code](https://claude.com/claude-code)
(revisión del agente antes de cada push).

```bash
git clone git@github.com:PabloESanabriaQ/proyecto-final.git && cd proyecto-final
mise trust && mise install                # Python 3.14, Node 24, uv
uv sync                                   # entorno Python: backend + solver + herramientas
(cd frontend && npm ci)                   # entorno Node
cp backend/.env.example backend/.env
docker compose up -d                      # PostgreSQL 17 en localhost:5432
git config core.hooksPath .githooks       # puerta de pre-push (obligatorio; decisión 0016)
```

Si `mise` no está activado en tu shell, anteponé `mise x --` a cualquier comando
(`mise x -- uv sync`).

### Windows

Trabajar dentro de **WSL2** (Ubuntu) con Docker Desktop en modo WSL2. Todo lo de arriba corre
igual ahí; los hooks de git son scripts bash y necesitan ese entorno.

## Correr

```bash
# API en http://localhost:8000 (docs en /docs)
uv run --directory backend uvicorn aulero_api.main:app --reload

# Frontend en http://localhost:5173 (proxy /api → 8000)
cd frontend && npm run dev

# Solver, desde la Fase 2
uv run aulero-solver --help
```

## Verificar

Lo mismo que corre el hook y CI:

```bash
uv run ruff check backend solver && uv run ruff format --check backend solver
(cd solver && uv run mypy .) && (cd backend && uv run mypy .)
uv run lint-imports                        # solver/ no importa backend/
uv run pytest

cd frontend && npm run lint && npm run format:check && npm run typecheck && npm run test
```

Formatear: `uv run ruff format backend solver` y `cd frontend && npm run format`.

## Subir cambios

1. Rama desde `main`: `feat/AUL-12-descripcion` (`docs/convenciones.md` §1).
2. `git push` corre el hook: lint, tests y **revisión del agente**. Si dice `BLOQUEADO`, corregí
   y volvé a pushear. La salida queda en `.review/ultima.md`.
3. Abrí el PR y **pegá la salida de `.review/ultima.md`** en la descripción.
4. Otra persona aprueba; CI en verde; merge.

`git push --no-verify` saltea la puerta y no se usa. Si un bloqueante no aplica:
`AULERO_REVIEW_DESCARTAR="motivo" git push` — el motivo queda en la salida y va al PR.

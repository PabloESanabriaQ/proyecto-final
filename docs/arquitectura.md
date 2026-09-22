# Aulero UNViMe — Documento técnico

> Documento vivo. Se actualiza al cerrar cada fase.
> Público: quien se suma al proyecto o lo defiende técnicamente. Acá va el modelo, las interfaces,
> las decisiones enlazadas y la deuda. El estado en lenguaje llano va en `informe-de-gestion.md`.
>
> **Última actualización:** 2026-09-16 — Fase 0 en curso: esqueleto, linters, hook de pre-push
> con agente, CI y `main` protegida, hechos y verificados; falta el merge del PR #1 (aprobación
> de otro integrante) y enlazar Jira.

## 1. Stack y arquitectura

Fijado en [decisión 0013](decisiones/0013-el-stack-es-fastapi-en-capas-react-con-vite-y-postgresql.md)
y [0012](decisiones/0012-el-solver-es-un-paquete-python-independiente-de-la-api-y-la-base.md).
Versiones: **Python 3.14** y **Node 24 LTS**
([0017](decisiones/0017-las-versiones-base-son-python-3-14-y-node-24-lts.md)). Remoto en GitHub;
revisión del agente en hook local de pre-push
([0016](decisiones/0016-la-revision-del-agente-corre-en-un-hook-local-antes-del-push.md)), CI de
lint y tests en GitHub Actions.

```
proyecto-final/
├── backend/                 # FastAPI (equipo PPS) — paquete aulero_api
│   ├── aulero_api/
│   │   ├── main.py          # app FastAPI
│   │   ├── routers/         # endpoints HTTP, sin lógica
│   │   ├── schemas/         # Pydantic: contratos de la API
│   │   ├── services/        # casos de uso; único lugar que llama a solver.solve
│   │   ├── repositories/    # acceso a datos (SQLAlchemy)
│   │   ├── models/          # tablas
│   │   ├── importers/       # Excel → validación → BD
│   │   └── adapters/        # BD ↔ solver.Instancia / solver.Solucion
│   ├── alembic/             # migraciones (Fase 1)
│   └── tests/
├── frontend/                # React + Vite + TS (equipo PPS)
│   └── src/
│       ├── features/        # una carpeta por funcionalidad
│       │   ├── periodos/
│       │   ├── carga/       # importación Excel, formularios
│       │   ├── horario/     # grilla, vistas por aula/docente/carrera
│       │   └── corridas/    # lanzar, estado, comparar
│       ├── api/             # cliente generado desde OpenAPI
│       └── components/      # compartidos
├── solver/                  # paquete Python independiente (equipo CP-SAT) — aulero_solver
│   ├── aulero_solver/
│   │   ├── instancia.py     # Pydantic: formato de entrada normalizado
│   │   ├── solucion.py      # Pydantic: formato de salida + violaciones
│   │   ├── modelo_a.py      # Proyecto A: duras
│   │   ├── modelo_b.py      # Proyecto B: holguras + dos niveles
│   │   ├── restricciones/   # una por Rn / Bn
│   │   ├── validador.py     # verifica R1–R11 sin usar CP-SAT
│   │   └── cli.py           # aulero-solver solve|validar
│   ├── instancias/          # juguete y otras instancias de referencia (JSON)
│   └── tests/
├── docs/
├── .githooks/               # pre-push: lint, tests y revisión del agente (0016) + sus tests
├── .github/workflows/       # CI: lint y tests, sin agente
├── pyproject.toml           # workspace uv (backend + solver), ruff, pytest, import-linter
├── mise.toml                # Python 3.14, Node 24, uv (0017)
└── docker-compose.yml       # PostgreSQL de desarrollo
```

Flujo de una optimización:

```
Excel / formulario ──► importers (validación) ──► BD
                                                  │
                        adapters.a_instancia ◄────┘
                                │
                      solver.solve(instancia, config)      [en segundo plano]
                                │
                        adapters.de_solucion ──► BD (corrida + asignaciones + violaciones)
                                                  │
                                       API ──► frontend (grilla, vistas, comparación)
```

`solver/` no importa nada de `backend/`; se verifica en CI (`convenciones.md`, §3.1).

## 2. Modelo

Las reglas de dominio están en el registro de decisiones; acá va la estructura que las
implementa. El esquema se detalla al implementarlo en la Fase 1; esta es la forma que las
decisiones ya fijan.

| Entidad | Atributos clave | Decisiones |
|---|---|---|
| **Periodo** | ciclo lectivo, cuatrimestre, días habilitados, hora inicio/fin de jornada, bloque mínimo (30 min), cantidad de semanas, fecha de inicio, turnos (3 rangos), pesos de relajación y de blandas | [0004](decisiones/0004-la-grilla-temporal-es-lunes-a-sabado-de-8-a-22-en-bloques-de-30-minutos.md), [0008](decisiones/0008-el-horario-es-semanal-y-las-excepciones-de-aula-se-resuelven-fuera-del-modelo.md), [0011](decisiones/0011-los-turnos-arrancan-con-rangos-predefinidos-configurables.md), [0010](decisiones/0010-el-proyecto-b-relaja-una-lista-cerrada-de-duras-con-holguras-y-optimiza-en-dos-niveles.md) |
| **Carrera** | nombre | |
| **Materia** | nombre. **No tiene carrera propia.** | [0006](decisiones/0006-el-conflicto-curricular-se-define-por-carrera-anio-y-cuatrimestre-con-lectura-existencial.md) |
| **Materia_Carrera** | materia, carrera, año, cuatrimestre. Define el grupo de conflicto (carrera, año, cuatrimestre). | 0006 |
| **Docente** | nombre | |
| **NoDisponibilidad** | docente, día, desde, hasta (dura, A y B) | 0010 |
| **PreferenciaHoraria** | docente, día, desde, hasta (blanda, solo B) | 0010 |
| **Edificio** | nombre | |
| **TipoAula** | catálogo abierto | R8 |
| **Aula** | edificio, tipo, capacidad | |
| **BloqueoAula** | aula, día, desde, hasta, motivo (ocupación externa, R11) | |
| **Comision** | materia, tipo de actividad (teoría / práctica / teórico-práctica), teoría asociada (solo prácticas), **docentes (uno o más)**, duración en bloques, **dictados por semana (defecto 1)**, tipo de aula requerido, **tipos alternativos (0..n)**, **alumnos (una sola cifra)** | [0005](decisiones/0005-la-cantidad-de-alumnos-de-una-comision-es-entrada-y-el-solver-elige-el-aula.md), [0007](decisiones/0007-una-comision-puede-tener-varios-dictados-semanales-en-dias-distintos.md), [0009](decisiones/0009-el-tipo-de-aula-requerido-es-exacto-salvo-alternativas-declaradas-por-la-comision.md) |
| **DictadoPrefijado** (entrada opcional) | comisión, número de dictado, día y/o bloque de inicio y/o aula fijos | [0015](decisiones/0015-una-comision-puede-venir-prefijada-a-dia-horario-y-aula.md) |
| **ExcepcionAula** | comisión, semana, tipo de aula requerido, observación; aula resuelta (salida) | 0008 |
| **Corrida** | período, modelo (A / B), configuración usada, estado, tiempos, resultado (factible / infactible / tiempo agotado), publicada (sí/no) | [0002](decisiones/0002-el-trabajo-se-divide-en-proyecto-a-duras-y-proyecto-b-relajacion.md) |
| **Asignacion** (salida) | corrida, comisión, número de dictado, día, bloque inicio, aula | 0007 |
| **Violacion** (salida, solo B) | corrida, restricción, entidades afectadas, magnitud de la holgura | 0010 |

Cambios respecto del Excel de ejemplo (`ejemplo_inputs_aulero_unvime-1.xlsx`), que se reflejan en
la plantilla definitiva durante la Fase 1:

- `Materias.Carrera_ID/Anio_Plan/Cuatrimestre` → hoja `Materia_Carrera`.
- `Comisiones.Alumnos_Actuales` + `Promedio_Historico` → una columna `Alumnos`.
- `Comisiones` suma `Dictados_Semana` (defecto 1) y `Tipos_Aula_Alternativos`.
- `Comisiones.Docente_ID` admite varios docentes (mecanismo a fijar en Fase 1).
- `Configuracion` suma cantidad de semanas, fecha de inicio y turnos; `Bloque_Min_Minutos` pasa
  a 30.
- Hoja nueva `Preferencia_Docente` (solo Proyecto B; puede quedar vacía).
- Hoja nueva `Dictados_Prefijados` (opcional; decisión 0015).

## 3. Interfaces

### 3.1 Contrato del solver (lo define el equipo CP-SAT)

```python
def solve(instancia: Instancia, config: Configuracion) -> Solucion: ...
def validar(instancia: Instancia, solucion: Solucion) -> list[Violacion]: ...
```

- `Instancia`: período (grilla, turnos), carreras, materias con sus grupos de conflicto,
  docentes con no-disponibilidades y preferencias, aulas con tipo, capacidad y bloqueos,
  comisiones con dictados, docentes, tipo requerido y alternativos, alumnos.
- `Configuracion`: modelo (`A` | `B`), límite de tiempo, pesos (solo B), tope de sobrecupo
  (solo B), semilla.
- `Solucion`: estado (`FACTIBLE` | `INFACTIBLE` | `TIEMPO_AGOTADO`), asignaciones (comisión,
  dictado, día, bloque, aula), violaciones (solo B), diagnóstico (solo A infactible: conjunto de
  restricciones en conflicto), métricas (tiempo, valor objetivo por nivel).

Se publica como JSON Schema generado desde los modelos Pydantic, versionado en `solver/`. Cambiar
el contrato es un cambio para los dos equipos y se anuncia en el PR.

### 3.2 API (lo define el equipo PPS, Fase 1 en adelante)

Se documenta automáticamente con OpenAPI (`/docs`). Hoy expone `GET /salud` (estado, versión de
la API y del solver enlazado; schema `Salud`). Recursos previstos: períodos, importación de
Excel, entidades de carga (CRUD), corridas (lanzar, consultar estado, resultado, publicar,
comparar), excepciones de aula, vistas de horario (por aula, docente, carrera/año, semana).

## 4. Estrategia de tests

En `convenciones.md`, §5. Resumen: una restricción, un archivo de tests; un caso borde, un test
nombrado; el juguete es la instancia de integración de referencia; el validador se prueba con
soluciones inválidas construidas a mano; la conversión BD ↔ solver se prueba contra el JSON
Schema publicado.

## 5. Cómo correrlo

Los comandos exactos están en el [`README`](../README.md) de la raíz (arranque en un clon
nuevo, correr, verificar, subir cambios). Resumen: `mise install` instala Python 3.14, Node 24 y
uv; `uv sync` arma el entorno Python de los dos paquetes; `npm ci` en `frontend/`;
`docker compose up -d` levanta PostgreSQL 17; `git config core.hooksPath .githooks` activa la
puerta de pre-push.

La verificación completa (la misma que corre el hook y CI):

```bash
uv run ruff check backend solver && uv run ruff format --check backend solver
(cd solver && uv run mypy .) && (cd backend && uv run mypy .)
uv run lint-imports && uv run pytest
cd frontend && npm run lint && npm run format:check && npm run typecheck && npm run test
bash .githooks/tests/test_pre_push.sh
```

### 5.1 Las puertas

**En GitHub:** `main` está protegida (activado el 2026-09-16 por API): check `CI OK` obligatorio
y al día con `main`, 1 aprobación de otra persona, conversaciones resueltas, sin force push ni
borrado, aplica también a administradores. El repo es público porque la protección de rama no
existe en repos privados del plan gratuito.

**En la máquina de cada uno:** la puerta de pre-push.

`.githooks/pre-push` corre, por cada rama que se sube: lint y tests de las partes tocadas
(Python, frontend, el propio hook), y después la revisión del agente sobre el diff acumulado
contra `origin/main` (sin lockfiles), con un tope de 10 minutos. El agente lo elige cada
integrante (`AULERO_AGENTE=claude|codex|gemini`, decisión 0018) y lo invoca
`.githooks/agente.sh` en modo no interactivo y solo lectura. El prompt está en
`.githooks/revision-prompt.md` y pide un veredicto en la última línea; `BLOQUEADO` corta el
push. La salida queda en `.review/<sha>.md` y `.review/ultima.md` para pegarla en el PR. Sus
casos borde tienen test en `.githooks/tests/test_pre_push.sh`, con un agente simulado.

## 6. Estado por fase

| Fase | Qué entra | Estado |
|---|---|---|
| 0 | Repo, estructura, hook de pre-push con agente, CI de lint y tests, `main` protegida | **En curso** — hecho: HU-0.1 a 0.4 (CI verde en PR #1, `main` exige `CI OK` + 1 aprobación); falta: merge de #1 con aprobación ajena, enlace desde Jira (0.5) |
| 1 | Importación Excel, validación, BD, API de consulta, vista de datos cargados, contrato de instancia | No iniciada |
| 2 | Solver A con restricciones de recursos, validador, CLI, juguete | No iniciada |
| 3 | Solver A con restricciones curriculares, diagnóstico de infactibilidad | No iniciada |
| 4 | Corrida desde la web, persistencia de la solución, grilla de horario | No iniciada |
| 5 | Carga por formulario, excepciones por semana, vista semanal | No iniciada |
| 6 | Instancia real ISI y multi-carrera, tiempos | No iniciada |
| 7 | Solver B: relajación con holguras y reporte de violaciones | No iniciada |
| 8 | Solver B: blandas, preferencias, corridas múltiples, comparación, publicación | No iniciada |

El detalle, las historias y las definiciones pendientes por fase están en `plan-de-fases.md`.

## 7. Deuda técnica anotada

- **Las listas de "qué toca cada parte" están duplicadas** entre `.githooks/pre-push`
  (`PAT_*`) y `.github/workflows/ci.yml` (filtros). Hoy son cuatro patrones y se mantienen a
  mano. **La señal:** un PR donde el hook y CI corran chequeos distintos para el mismo cambio.
  La salida es un archivo compartido que los dos lean.
- **El hook depende de bash y de Python (`python3` o `python`) en el PATH** para leer el JSON del agente.
  `extraer` soporta ambos intérpretes dinámicamente. En Windows los hooks bash corren vía WSL2 o Git Bash.
- **El adaptador de Gemini CLI en `.githooks/agente.sh` quedó probado y verificado** (`gemini -p "" --output-format json`
  con suite unitaria en `.githooks/tests/test_agente.sh`). El adaptador de Codex CLI queda a confirmar en el primer
  push de quien lo use.
- **`fastapi.testclient` avisa que `httpx` está deprecado a favor de `httpx2`** (warning en
  `pytest`). No afecta hoy. **La señal:** que Starlette lo convierta en error en una versión
  nueva; ahí se migra el cliente de tests.

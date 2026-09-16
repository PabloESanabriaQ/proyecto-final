# Aulero UNViMe — Documento técnico

> Documento vivo. Se actualiza al cerrar cada fase.
> Público: quien se suma al proyecto o lo defiende técnicamente. Acá va el modelo, las interfaces,
> las decisiones enlazadas y la deuda. El estado en lenguaje llano va en `informe-de-gestion.md`.
>
> **Última actualización:** 2026-09-16 — Fase 0 no iniciada. Hay decisiones, plan y convenciones;
> no hay código.

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
├── backend/                 # FastAPI (equipo PPS)
│   ├── app/
│   │   ├── routers/         # endpoints HTTP, sin lógica
│   │   ├── schemas/         # Pydantic: contratos de la API
│   │   ├── services/        # casos de uso; único lugar que llama a solver.solve
│   │   ├── repositories/    # acceso a datos (SQLAlchemy)
│   │   ├── models/          # tablas
│   │   ├── importers/       # Excel → validación → BD
│   │   └── adapters/        # BD ↔ solver.Instancia / solver.Solucion
│   ├── alembic/             # migraciones
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
├── solver/                  # paquete Python independiente (equipo CP-SAT)
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

Se documenta automáticamente con OpenAPI. Recursos previstos: períodos, importación de Excel,
entidades de carga (CRUD), corridas (lanzar, consultar estado, resultado, publicar, comparar),
excepciones de aula, vistas de horario (por aula, docente, carrera/año, semana).

## 4. Estrategia de tests

En `convenciones.md`, §5. Resumen: una restricción, un archivo de tests; un caso borde, un test
nombrado; el juguete es la instancia de integración de referencia; el validador se prueba con
soluciones inválidas construidas a mano; la conversión BD ↔ solver se prueba contra el JSON
Schema publicado.

## 5. Cómo correrlo

*(Se completa en la Fase 0, cuando exista qué correr.)*

## 6. Estado por fase

| Fase | Qué entra | Estado |
|---|---|---|
| 0 | Repo, estructura, hook de pre-push con agente, CI de lint y tests | No iniciada |
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

*(Vacía: no hay código todavía. Cada fase agrega la suya con la señal que indicaría pagarla.)*

# Jira

Proyecto **AUL** en https://aulero.atlassian.net (team-managed). Tipos de issue del proyecto:
Epic, Feature (se usa para las historias), Tarea (definiciones y cierres), Subtask.

**Convención:** un epic por fase; una historia por `HU-N.M`; las definiciones pendientes con
etiqueta `definicion` se cierran registrando la decisión en `docs/decisiones/` **antes** de
empezar las historias de la fase; la tarea `cierre` sigue el checklist de
`docs/plan-de-fases.md`. Ramas y commits llevan la clave (`feat/AUL-14-...`).

## Cargado el 2026-09-16 (desde `fases-0-y-1.csv`)

| Clave | Tipo | Issue |
|---|---|---|
| AUL-5 | Epic | Fase 0 — Base del proyecto y puerta de calidad |
| AUL-7 | Feature | HU-0.1 Estructura del monorepo con linters y formateadores |
| AUL-8 | Feature | HU-0.2 Hook de pre-push con lint, tests y revisión del agente |
| AUL-9 | Feature | HU-0.3 CI en GitHub Actions y main protegida |
| AUL-10 | Feature | HU-0.4 README de arranque |
| AUL-11 | Feature | HU-0.5 Enlace del repositorio con Jira |
| AUL-12 | Tarea | Cierre de la Fase 0 |
| AUL-6 | Epic | Fase 1 — Cargar los datos de un período y verlos |
| AUL-13 | Feature | HU-1.1 Descargar la plantilla Excel del período |
| AUL-14 | Feature | HU-1.2 Subir el Excel y validarlo entero antes de guardar |
| AUL-15 | Feature | HU-1.3 Lista completa de errores de validación |
| AUL-16 | Feature | HU-1.4 Ver los datos cargados en la web |
| AUL-17 | Feature | HU-1.5 Formato de instancia normalizada y exportación desde la base |
| AUL-18 | Feature | HU-1.6 Resubir el Excel de un período con confirmación |
| AUL-19 | Tarea | Definición: plantilla definitiva del Excel |
| AUL-20 | Tarea | Definición: esquema exacto del JSON de instancia |
| AUL-21 | Tarea | Definición: autenticación para subir un Excel |
| AUL-22 | Tarea | Definición: identificación del período |
| AUL-23 | Tarea | Cierre de la Fase 1 |

## Cargado el 2026-09-17

| Clave | Tipo | Issue |
|---|---|---|
| AUL-24 | Tarea | Soporte de Antigravity CLI (agy) y pre-push en Windows (relacionada con AUL-8, epic AUL-5) |

AUL-1 a AUL-4 son los ejemplos de la plantilla de Jira; se borran.

El CSV queda como registro de lo cargado y como formato para las fases siguientes, que se cargan
al llegar, después de tomar sus definiciones pendientes. Para importarlo a mano: Jira →
Configuración → Sistema → Importación externa → CSV, mapeando `Issue ID` / `Parent ID` para la
jerarquía.

## Quién mantiene esto

Desde el 2026-09-30, **la tabla de arriba la actualiza el agente al crear una issue**, y el estado
de cada issue se mueve desde hechos de git: rama con clave, PR abierto, PR mergeado. El contrato
está en [`../convenciones.md`](../convenciones.md) §7 y la decisión que lo funda, en
[`../decisiones/0024-el-estado-de-jira-lo-mueve-el-agente-desde-hechos-de-git.md`](../decisiones/0024-el-estado-de-jira-lo-mueve-el-agente-desde-hechos-de-git.md).

**El agente no puede borrar issues:** el MCP de Atlassian expone crear, editar, comentar y
transicionar, nada más. Una issue creada por error se corrige a mano desde la interfaz.

## Creado después de la importación

| Clave | Tipo | Issue |
|---|---|---|
| AUL-25 | Tarea | Flujo de Jira operado por el agente desde hechos de git (epic AUL-5, etiqueta `no-planificado`) |
| AUL-26 | Subtask | Escenarios de verificación y baseline (RED) |
| AUL-27 | Subtask | Decisión 0024 |
| AUL-28 | Subtask | `convenciones.md` §7 "Jira" |
| AUL-29 | Subtask | La skill `trabajar-con-jira` (GREEN) |
| AUL-30 | Subtask | Cerrar agujeros (REFACTOR) — cerrada sin cambios, no hubo agujeros |
| AUL-31 | Subtask | Enganches y pull request |

| AUL-32 | Tarea | Corregir el alcance a toda la UNViMe en los documentos (decisión 0023) |
| AUL-33 | Tarea | El adaptador de Gemini perdió el modo de solo lectura, y el caso borde del shim de Python no tiene test |

**`AUL-24` no se borra.** Se llama "Test" y quedó de la plantilla de Jira, sin epic ni etiqueta,
pero **un commit que ya está en `main` la cita** (`0edd9b8 AUL-24: registrar ticket de soporte agy y
compatibilidad de pre-push`). Borrarla rompe ese enlace en el panel de desarrollo. Conviene
renombrarla con lo que ese commit entregó, o dejarla y anotar que la clave se usó por error. Lo que
no se hace es eliminarla — y ningún agente podría: el MCP no expone borrado.

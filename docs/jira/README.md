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

**`AUL-24` no se borró.** Se llamaba "Test" (una prueba de integración), pero **un commit que ya
está en `main` la cita** (`0edd9b8 AUL-24: registrar ticket de soporte agy y compatibilidad de
pre-push`). El 2026-11-13 se renombró con lo que ese commit entregó —"Soporte de Antigravity CLI
(agy) y pre-push en Windows"—, se colgó del epic AUL-5 con etiqueta `no-planificado` y pasó a
*Finalizada*, porque el PR #1 que la trae está mergeado.

## Creado el 2026-11-13 (plan de puesta al día, decisión 0025)

| Clave | Tipo | Issue |
|---|---|---|
| AUL-34 | Epic | Fase 2 — Primer horario del caso de prueba |
| AUL-36 | Tarea | Definición: criterios de simulación y contenido del caso acotado |
| AUL-37 | Tarea | Definición: límite de tiempo por defecto de una corrida |
| AUL-38 | Tarea | Definición: objetivo del Proyecto A |
| AUL-39 | Tarea | Definición: tipos de aula alternativos en la instancia |
| AUL-40 | Tarea | Formalización final de R1–R11 y de la grilla (etiqueta `informe`) |
| AUL-41 | Tarea | Publicar el esquema de instancia y de solución en aulero-solver |
| AUL-42 | Historia | HU-2.6 El paquete se instala y sus tests corren solos |
| AUL-43 | Historia | HU-2.5 Caso de prueba acotado en formato de instancia |
| AUL-44 | Historia | HU-2.1 Correr aulero-solver solve |
| AUL-45 | Historia | HU-2.2 Restricciones de recursos |
| AUL-46 | Historia | HU-2.4 Límite de tiempo e INFACTIBLE frente a TIEMPO_AGOTADO |
| AUL-47 | Historia | HU-2.3 Validador independiente de recursos |
| AUL-48 | Tarea | Cierre de la Fase 2 |
| AUL-35 | Epic | Fase 7 — Proyecto B: horario con violaciones acotadas |
| AUL-49 | Tarea | Definición: lista cerrada de atenuables, unidad de infracción y orden de niveles |
| AUL-50 | Tarea | Definición: formatos de infracciones y de métricas de calidad |
| AUL-51 | Tarea | Definición: pesos por defecto y tope de sobrecupo |
| AUL-52 | Historia | HU-7.1 Holguras por instancia de restricción (primero R7 y R8) |
| AUL-53 | Historia | HU-7.2 Primer nivel: minimizar la suma ponderada de holguras |
| AUL-54 | Tarea | Registrar la decisión 0025 (epic AUL-5, etiqueta `no-planificado`) |

El tipo de issue de las historias se llama **Historia** en el proyecto (no Feature, como decía la
tabla de 2026-09-16).

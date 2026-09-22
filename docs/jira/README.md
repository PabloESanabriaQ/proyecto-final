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

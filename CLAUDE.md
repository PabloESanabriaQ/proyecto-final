# Aulero UNViMe

Sistema de asignación de horarios y aulas (UCTP) para la carrera de Ingeniería en Sistemas de
Información de la UNViMe. Proyecto Final + PPS, cuatro personas. OR-Tools CP-SAT, FastAPI,
React, PostgreSQL.

## Dónde está cada cosa

- **Estado de avance y qué hace el sistema:** `docs/informe-de-gestion.md` (el estado vive ahí y
  solo ahí; este archivo no lo repite).
- **Modelo, interfaces, estructura, deuda:** `docs/arquitectura.md`.
- **Fases, historias, definiciones pendientes por fase:** `docs/plan-de-fases.md`.
- **Decisiones de diseño:** `docs/decisiones/` — cuando contradice a otro documento, manda el
  registro. Antes de codificar una decisión nueva, se escribe ahí (skill `registrar-decisiones`).
- **Convenciones (ramas, revisión, linters, accesibilidad, tests):** `docs/convenciones.md`.
- **Material histórico** (PDF de estado del arte, `AULERO.md`, Excel de ejemplo): `docs/README.md`
  dice qué de cada uno quedó superado.

## Reglas que no se rompen

- `solver/` no importa nada de `backend/` (decisión 0012). La API es el único lugar que llama a
  `solve`.
- Nada se pushea sin pasar el hook de pre-push con la revisión del agente (decisión 0016); nada
  llega a `main` sin PR con CI verde y aprobación de otra persona (decisión 0014). No se usa
  `--no-verify`.
- Python 3.14 y Node 24 (decisión 0017).
- Un caso borde nombrado en el plan tiene un test que lo nombra antes de cerrar la fase.
- Los números del modelo (pesos, topes, tiempos) no se ponen en el código sin registrar de dónde
  salen (decisión 0010).
- Una fase se cierra con el checklist de la skill `avanzar-por-fases` y los dos documentos vivos
  actualizados.

## Próximo paso

**Fase 0** del plan: estructura del monorepo, linters, hook de pre-push con el agente, CI de lint
y tests, README de arranque. Falta una sola definición pendiente de la Fase 0: la clave del
proyecto en Jira.

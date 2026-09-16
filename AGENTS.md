# Aulero UNViMe

Sistema de asignación de horarios y aulas (UCTP) para la carrera de Ingeniería en Sistemas de
Información de la UNViMe. Proyecto Final + PPS, cuatro personas. OR-Tools CP-SAT, FastAPI,
React, PostgreSQL.

Este es el archivo de contexto canónico del proyecto. `CLAUDE.md` y `GEMINI.md` lo importan;
Codex y Antigravity lo leen directamente (decisión 0018). Es un puntero: el estado de avance
vive en `docs/informe-de-gestion.md` y solo ahí.

## Dónde está cada cosa

- **Estado de avance y qué hace el sistema:** `docs/informe-de-gestion.md`.
- **Modelo, interfaces, estructura, deuda:** `docs/arquitectura.md`.
- **Fases, historias, definiciones pendientes por fase, checklist de cierre:**
  `docs/plan-de-fases.md`.
- **Decisiones de diseño:** `docs/decisiones/` — cuando contradice a otro documento, manda el
  registro. Antes de codificar una decisión nueva, se escribe ahí con la plantilla del índice.
- **Convenciones (ramas, revisión, linters, accesibilidad, tests):** `docs/convenciones.md`.
- **Material histórico** (PDF de estado del arte, `AULERO.md`, Excel de ejemplo): `docs/README.md`
  dice qué de cada uno quedó superado.

## Reglas que no se rompen

- `solver/` no importa nada de `backend/` (decisión 0012). La API es el único lugar que llama a
  `solve`.
- Nada se pushea sin pasar el hook de pre-push con la revisión del agente (decisión 0016); nada
  llega a `main` sin PR con CI verde y aprobación de otra persona (decisión 0014). No se usa
  `--no-verify`.
- Un caso borde nombrado en el plan tiene un test que lo nombra antes de cerrar la fase.
- Los números del modelo (pesos, topes, tiempos) no se ponen en el código sin registrar de dónde
  salen (decisión 0010).
- Una fase se cierra con el checklist de `docs/plan-de-fases.md` ("Cierre de una fase") y los dos
  documentos vivos actualizados. Sin la salida de la verificación pegada, no hay cierre.
- Python 3.14 y Node 24 (decisión 0017).

## Cómo trabajar acá

- Fases por funcionalidad demostrable, no por capa. Cada fase: historias, casos borde nombrados,
  definiciones pendientes tomadas **antes** de sus historias.
- Decisiones: un archivo por decisión, con alternativas descartadas, costo y señal de revisión.
  No se edita una decisión para cambiar de opinión: se escribe otra y se cruzan.
- Revisión de código: el agente revisa, las personas deciden. Un hallazgo se verifica contra el
  código antes de aplicarlo.

## Próximo paso

**Fase 0** del plan, en curso. Hecho: esqueleto, linters, hook de pre-push con agente, CI. Falta:
proteger `main` en GitHub con `CI OK` + una aprobación (HU-0.3), enlazar Jira (HU-0.5).

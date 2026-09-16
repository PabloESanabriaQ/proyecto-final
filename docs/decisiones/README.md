# Registro de decisiones — Aulero UNViMe

## Política

- **Un archivo por decisión**, numerado con cuatro dígitos: `NNNN-titulo-afirmativo.md`. Formato
  fijo: Contexto (con las alternativas descartadas) → Decisión (con la procedencia de cada
  número) → Consecuencias (a favor, en contra, riesgo abierto con su señal).
- **Se escribe antes de codificar.** Si la decisión aparece a mitad de la implementación, se
  para, se escribe y se sigue.
- **No se edita una decisión para cambiar de opinión.** Se escribe una nueva y se enlazan en los
  dos sentidos (`Modifica` / `Reemplaza a` / `Implementa de otro modo`, y su recíproca en la
  afectada). Una decisión revertida no se borra nunca.
- **El número nuevo** es el siguiente que no esté ni en este directorio ni citado en el repo
  (`grep -rnoE '(decisi[oó]n|ADR)[ -]?[0-9]{4}' --exclude-dir=.git .`).
- **Cuando este registro contradice otro documento del proyecto, manda el registro.** Los
  documentos previos (`docs/aulero_estado_del_arte.pdf`, `docs/AULERO.md`) son material histórico.
- Las convenciones de estilo, code review y accesibilidad **no van acá**: van en
  [`../convenciones.md`](../convenciones.md).

## Plantilla

```markdown
# NNNN — Título afirmativo, en presente: qué se decidió

**Estado:** Aceptada — AAAA-MM-DD
<!-- Si corresponde, SIEMPRE con su recíproca en el afectado:
**Modifica:** NNNN — en una línea, qué le cambia.      (→ "Modificada por: NNNN" en el otro)
**Reemplaza a:** NNNN                                   (→ "Reemplazada por: NNNN")
**Implementa de otro modo:** NNNN — la regla sigue.    (→ nota al pie; sigue Aceptada) -->

## Contexto
Qué obliga a decidir; qué dice o calla el material previo. Las alternativas evaluadas, cada una
con su punto fuerte y por qué se descarta.

## Decisión
Qué se decidió, en presente. Cada número con su procedencia: ancla del enunciado, deducción, o
criterio propio declarado. Un número sin procedencia es una decisión postergada.

## Consecuencias
**A favor:** … **En contra:** qué se pierde. **Riesgo abierto:** qué obligaría a revisarla, y
**qué señal lo indicaría**.
```

Los dos errores que vacían un registro: documentar solo lo elegido (sin alternativas no se
entiende el criterio) y consecuencias solo favorables (sin costo ni señal es publicidad).

## Índice

| # | Decisión | Estado |
|---|---|---|
| [0001](0001-el-problema-se-modela-bajo-el-modelo-curricular.md) | El problema se modela bajo el modelo curricular, no por inscripción real | Aceptada |
| [0002](0002-el-trabajo-se-divide-en-proyecto-a-duras-y-proyecto-b-relajacion.md) | El trabajo se divide en Proyecto A (restricciones duras) y Proyecto B (relajación y calidad) sobre la misma instancia, API y frontend | Aceptada |
| [0003](0003-cp-sat-es-el-unico-motor-de-resolucion.md) | CP-SAT es el único motor de resolución; se descartan el algoritmo genético y el aprendizaje por refuerzo | Aceptada |
| [0004](0004-la-grilla-temporal-es-lunes-a-sabado-de-8-a-22-en-bloques-de-30-minutos.md) | La grilla temporal es lunes a sábado, 08:00 a 22:00, en bloques de 30 minutos | Aceptada |
| [0005](0005-la-cantidad-de-alumnos-de-una-comision-es-entrada-y-el-solver-elige-el-aula.md) | La cantidad de alumnos de una comisión es dato de entrada y el solver elige un aula que la contenga | Aceptada |
| [0006](0006-el-conflicto-curricular-se-define-por-carrera-anio-y-cuatrimestre-con-lectura-existencial.md) | El conflicto curricular se define por (carrera, año, cuatrimestre), con lectura existencial y materias compartidas en varios grupos | Aceptada |
| [0007](0007-una-comision-puede-tener-varios-dictados-semanales-en-dias-distintos.md) | Una comisión puede tener varios dictados semanales, de igual duración y en días distintos | Aceptada |
| [0008](0008-el-horario-es-semanal-y-las-excepciones-de-aula-se-resuelven-fuera-del-modelo.md) | El horario es semanal y repetitivo; las excepciones de aula por semana se resuelven fuera del modelo de optimización | Aceptada |
| [0009](0009-el-tipo-de-aula-requerido-es-exacto-salvo-alternativas-declaradas-por-la-comision.md) | El tipo de aula requerido es exacto, salvo alternativas declaradas explícitamente por la comisión | Aceptada |
| [0010](0010-el-proyecto-b-relaja-una-lista-cerrada-de-duras-con-holguras-y-optimiza-en-dos-niveles.md) | El Proyecto B relaja una lista cerrada de restricciones duras mediante holguras y optimiza en dos niveles | Aceptada |
| [0011](0011-los-turnos-arrancan-con-rangos-predefinidos-configurables.md) | Los turnos arrancan con rangos predefinidos (08–13, 13–18, 18–22) y son configurables | Aceptada |
| [0012](0012-el-solver-es-un-paquete-python-independiente-de-la-api-y-la-base.md) | El solver es un paquete Python independiente de la API y de la base de datos, y es el límite entre PPS y Proyecto Final | Aceptada |
| [0013](0013-el-stack-es-fastapi-en-capas-react-con-vite-y-postgresql.md) | El stack es FastAPI en capas, React con Vite y TypeScript, y PostgreSQL | Aceptada |
| [0014](0014-la-revision-de-codigo-tiene-dos-puertas-agente-en-ci-y-persona-antes-de-mergear.md) | La revisión de código tiene dos puertas: agente en CI sobre el PR y una persona antes de mergear | Aceptada — modificada por 0016 |
| [0015](0015-una-comision-puede-venir-prefijada-a-dia-horario-y-aula.md) | Una comisión puede venir pre-fijada a día, horario y/o aula como dato de entrada | Aceptada |
| [0016](0016-la-revision-del-agente-corre-en-un-hook-local-antes-del-push.md) | La revisión del agente corre en un hook local antes del push, no en CI | Aceptada — modifica 0014 |
| [0017](0017-las-versiones-base-son-python-3-14-y-node-24-lts.md) | Las versiones base son Python 3.14 y Node 24 LTS | Aceptada |
| [0018](0018-el-proyecto-funciona-con-cualquier-agente-de-codigo-del-equipo.md) | El proyecto funciona con cualquier agente de código del equipo: Claude Code, Codex o Antigravity/Gemini | Aceptada |
| [0019](0019-backend-y-solver-comparten-un-workspace-de-uv.md) | `backend/` y `solver/` comparten un workspace de uv con un solo entorno y un solo lock | Aceptada |

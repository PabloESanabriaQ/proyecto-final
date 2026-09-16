# 0014 — La revisión de código tiene dos puertas: agente en CI sobre el PR y una persona antes de mergear

**Estado:** Aceptada — 2026-09-16
**Modificada por:** [[0016]] — el mismo día, el equipo decidió que la revisión del agente corra
en un hook local de pre-push y no en CI. Sigue vigente de esta decisión: las dos puertas (agente
y persona), `main` protegida, CI con lint y tests. Leer junto con 0016.

## Contexto

`docs/AULERO.md` pide que "un agente haga code review antes de permitir subir el código" y que
"haya code review hecho por otro miembro antes de mergear una rama". Había que decidir dónde
corre la revisión del agente, porque de eso depende que la puerta se pueda saltear o no.

Alternativas evaluadas:

- **Hook local de pre-push** — la revisión corre en la máquina de cada persona antes de subir.
  Se descarta como puerta obligatoria porque se saltea con `git push --no-verify`, depende de que
  cada máquina tenga el agente configurado y no deja registro visible para el resto del equipo.
  Queda como opcional.
- **Revisión del agente en CI, sobre el pull request** — la elegida.

## Decisión

Toda rama llega a `main` por pull request, y el PR tiene **dos puertas obligatorias**:

1. **CI:** lint y formato de cada parte tocada, tests, y **revisión automática por un agente**
   que comenta el PR. Si el agente reporta hallazgos bloqueantes, el PR no se puede mergear hasta
   resolverlos o justificar por qué no aplican, en el propio PR.
2. **Una persona distinta de quien abrió el PR** aprueba antes del merge.

Un hook local de pre-push que corra lint y tests es recomendado pero no obligatorio. La rama
`main` está protegida: no admite push directo.

Los detalles de qué revisa el agente, qué lint corre cada parte y qué cuenta como bloqueante
están en `docs/convenciones.md`.

## Consecuencias

**A favor:** la puerta es la misma para los cuatro; queda registro en el PR de qué dijo el agente
y qué respondió el autor; no depende de la configuración de cada máquina.

**En contra:** el remoto tiene que soportar checks obligatorios y ramas protegidas (GitHub o
equivalente); hace falta una cuenta con acceso al agente para CI, cuyo costo no está resuelto.

**Riesgo abierto:** que el costo o la disponibilidad del agente en CI vuelva la puerta un
obstáculo y el equipo la desactive. **La señal:** PRs mergeados con el check del agente en
falla o desactivado. Ahí se revisa esta decisión —por ejemplo, revisión del agente solo en PRs
que tocan `solver/` o `backend/`— y se registra.

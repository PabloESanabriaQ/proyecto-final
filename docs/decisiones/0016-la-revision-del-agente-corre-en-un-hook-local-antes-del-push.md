# 0016 — La revisión del agente corre en un hook local antes del push, no en CI

**Estado:** Aceptada — 2026-09-16
**Modifica:** 0014 — la revisión del agente pasa de un check de CI sobre el PR a un hook local de
pre-push; la revisión humana antes del merge y el CI de lint y tests no cambian.

## Contexto

[[0014]] había puesto la revisión del agente en CI sobre el pull request, para que la puerta no
se pudiera saltear y quedara registro. El equipo decidió el mismo día hacerla **local**: no se
puede pushear si la revisión del agente no aprobó. El motivo que expresó el equipo es que la
restricción se hace de manera local; el costo de una cuenta del agente para CI —riesgo abierto de
0014— no queda resuelto en el otro esquema.

Alternativas evaluadas:

- **Agente en CI sobre el PR** (lo que decía 0014) — no se saltea y deja registro en el PR, pero
  necesita una cuenta del agente en CI y su costo. Se descarta por decisión del equipo.
- **Agente en hook de pre-commit** — revisa cada commit. Se descarta porque revisa fragmentos y
  no el cambio completo que se va a subir, y vuelve lento el ciclo local.
- **Agente en hook de pre-push** — la elegida.

## Decisión

1. Cada integrante instala el hook de **pre-push** del repositorio (`.githooks/pre-push`,
   activado con `git config core.hooksPath .githooks`; lo documenta el README de la raíz).
2. El hook corre el agente en modo no interactivo sobre el diff entre `origin/main` y lo que se
   va a subir, con el prompt de revisión de `docs/convenciones.md` §2.1, y **bloquea el push si
   hay hallazgos bloqueantes** sin resolver.
3. El hook guarda la salida de la revisión en un archivo local ignorado por git; el autor **pega
   esa salida en la descripción del PR**. Esa es la evidencia de que la puerta se pasó.
4. CI sigue corriendo lint, formato y tests, sin agente. La aprobación de otra persona antes del
   merge sigue siendo obligatoria (0014, punto 2). `main` sigue protegida.

El mecanismo exacto (comando, formato de salida, qué cuenta como bloqueante) se implementa en la
historia HU-0.2 de la Fase 0.

## Consecuencias

**A favor:** sin costo de agente en CI; la revisión llega antes de subir, cuando corregir es más
barato; cada persona usa su propia cuenta.

**En contra:** la puerta se saltea con `git push --no-verify` y depende de que cada máquina tenga
el hook instalado y el agente configurado; la única evidencia es lo que el autor pega en el PR.
Quien revisa tiene que pedir esa salida si falta.

**Riesgo abierto:** que la puerta se vuelva nominal —PRs sin la salida del agente, o con
revisiones sobre un diff distinto del subido—. **La señal:** dos PRs seguidos sin la revisión
pegada o con hallazgos bloqueantes ignorados. Ahí se vuelve a 0014 (agente en CI) y se registra.

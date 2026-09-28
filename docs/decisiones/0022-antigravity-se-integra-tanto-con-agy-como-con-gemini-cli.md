# 0022 — Antigravity se integra tanto con `agy` como con Gemini CLI

**Estado:** Aceptada — 2026-09-28
**Modifica:** 0018 — agrega `agy` como adaptador directo sin retirar el adaptador de Gemini CLI.

## Contexto

La decisión 0018 estableció que cada integrante puede usar el agente que ya tiene y definió
`AULERO_AGENTE=claude|codex|gemini`. Al probar la puerta en Windows, el equipo incorporó además
el CLI directo de Antigravity, `agy`, y lo validó de punta a punta. El código y el README ya lo
enumeraban como cuarto adaptador, pero el registro seguía nombrando solamente el camino por
Gemini CLI.

Alternativas evaluadas:

- **Mantener solo Gemini CLI para Antigravity** — deja tres adaptadores, pero obliga a reemplazar
  el CLI que ya usa el equipo y cuya integración en Windows ya fue probada.
- **Reemplazar Gemini CLI por `agy`** — refleja el uso actual con menos caminos, pero quita una
  alternativa ya soportada para quien tenga Gemini CLI instalado.
- **Soportar `agy` y Gemini CLI** — conserva compatibilidad con ambos entornos a cambio de
  mantener un adaptador adicional. Es la elegida.

## Decisión

La selección explícita del agente acepta
`AULERO_AGENTE=claude|codex|agy|gemini`. `agy` es el adaptador directo de Antigravity y `gemini`
es el adaptador de Gemini CLI; ambos permanecen disponibles y tienen pruebas propias. La
detección automática conserva el orden implementado en `.githooks/agente.sh`.

## Consecuencias

**A favor:** cada integrante puede usar el CLI que tiene instalado; el soporte probado de `agy`
queda alineado entre la implementación, el README y el registro de decisiones.

**En contra:** la puerta mantiene cuatro adaptadores y cualquier cambio de interfaz de esos CLI
exige actualizar código, pruebas y documentación.

**Riesgo abierto:** que `agy` cambie sus flags o deje de representar el CLI usado por
Antigravity. **La señal:** que su prueba falle o que el primer pre-push posterior a una
actualización del CLI no pueda producir un veredicto; en ese momento se revisa este adaptador.

# 0018 — El proyecto funciona con cualquier agente de código del equipo: Claude Code, Codex o Antigravity/Gemini

**Estado:** Aceptada — 2026-09-16

## Contexto

Los cuatro integrantes no usan la misma herramienta: hay Claude Code, Codex y Antigravity
(cuyo equivalente de línea de comandos es Gemini CLI). Lo que se armó en la Fase 0 tenía dos
puntos atados a una sola: el hook de pre-push invocaba `claude -p` y el archivo de contexto era
`CLAUDE.md`. Con eso, tres de cuatro personas no podían pushear ni tenían contexto al abrir el
proyecto.

Alternativas evaluadas:

- **Exigir Claude Code a todo el equipo** — un solo camino que mantener. Se descarta porque
  obliga a cada uno a pagar y aprender una herramienta que no eligió, por una puerta de revisión
  que no depende de cuál sea el agente.
- **Un archivo de contexto por herramienta con el mismo contenido** — se descarta porque son
  tres copias de un hecho, y una queda vieja.
- **Un archivo canónico + adaptador de agente** — la elegida.

## Decisión

1. **`AGENTS.md` es el archivo de contexto canónico.** Codex y Antigravity lo leen directamente.
   `CLAUDE.md` y `GEMINI.md` contienen una sola línea, `@AGENTS.md`, que lo importa. Todo lo
   que un agente tiene que saber al abrir el proyecto va en `AGENTS.md` y solo ahí.
2. **La revisión de pre-push pasa por `.githooks/agente.sh`**, que lee el prompt por stdin e
   imprime la respuesta en texto plano. Cada integrante elige con `AULERO_AGENTE=claude|codex|gemini`
   (por defecto, el primero instalado). Todos los adaptadores corren en modo no interactivo y de
   solo lectura. El prompt y el veredicto son los mismos para cualquiera.
3. **Lo que se escribe en el repo no depende del agente:** decisiones, plan, convenciones y
   documentos vivos están en Markdown en `docs/`. Los procedimientos que hoy están en skills
   personales (cierre de fase, plantilla de decisión) se copian al repo para que un integrante
   sin esas skills los tenga igual.

## Consecuencias

**A favor:** cada uno usa lo que tiene; la puerta de revisión es una sola; el contexto del
proyecto es un archivo.

**En contra:** tres adaptadores que mantener; solo el de Claude Code quedó probado de punta a
punta el 2026-09-16 (Codex y Gemini se escribieron contra `--help`, sin credenciales para
correrlos). Las revisiones de agentes distintos no son comparables entre sí: un mismo diff puede
pasar con uno y no con otro.

**Riesgo abierto:** que un adaptador no funcione en el primer uso real. **La señal:** el primer
push de un integrante con Codex o Gemini. Se corrige el adaptador en ese PR y se quita el "a
confirmar" del README. Otra señal: que las revisiones de un agente sean sistemáticamente más
laxas; ahí se revisa el prompt, no se cambia de agente.

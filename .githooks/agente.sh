#!/usr/bin/env bash
# Adaptador de agente para la revisión de código (decisión 0018).
#
# Lee el prompt por stdin, invoca al agente en modo no interactivo y de solo lectura, e imprime
# la respuesta en texto plano por stdout. Código de salida distinto de cero si el agente no
# respondió. Cada integrante usa el agente que tiene:
#
#   AULERO_AGENTE=claude | codex | agy | gemini   (si no se define: el primero instalado, en ese orden)
#   AULERO_AGENTE_CMD=<ejecutable>          (reemplaza todo; para tests: recibe stdin, imprime texto)
#
# Verificado contra --help de cada CLI el 2026-09-16; claude probado de punta a punta. codex y
# gemini quedan a confirmar en el primer push de quien los use (ver README).
set -euo pipefail

if [[ -n "${AULERO_AGENTE_CMD:-}" ]]; then
  exec "$AULERO_AGENTE_CMD"
fi

AGENTE="${AULERO_AGENTE:-}"
if [[ -z "$AGENTE" ]]; then
  for candidato in claude codex agy gemini; do
    if command -v "$candidato" >/dev/null 2>&1; then AGENTE="$candidato"; break; fi
  done
  [[ -n "$AGENTE" ]] || { echo "No se encontró ningún agente (claude, codex, agy o gemini) en el PATH. Instalá uno (README) o definí AULERO_AGENTE." >&2; exit 2; }
fi

command -v "$AGENTE" >/dev/null 2>&1 \
  || { echo "No se encontró '$AGENTE' en el PATH. Instalá Claude Code, Codex CLI o Antigravity/Gemini CLI (README), o cambiá AULERO_AGENTE." >&2; exit 2; }

# Imprime el campo pedido del JSON. Si falta o está vacío (por ejemplo, el agente agotó sus
# turnos), manda el JSON completo a stderr —que el hook guarda en .review/error.log— y falla.
extraer() {
  local py=""
  for c in python3 python py; do
    if command -v "$c" >/dev/null 2>&1 && "$c" -c 'import sys' >/dev/null 2>&1; then
      py="$c"
      break
    fi
  done
  if [[ -z "$py" ]]; then
    echo "No se encontró un intérprete de Python funcional (python3, python o py) en el PATH." >&2
    exit 3
  fi
  "$py" -c '
import json, sys
crudo = sys.stdin.read()
try:
    valor = json.loads(crudo).get(sys.argv[1])
except ValueError:
    valor = None
if not valor:
    sys.stderr.write("El agente no devolvió el campo %r. Respuesta completa:\n%s\n" % (sys.argv[1], crudo))
    sys.exit(3)
print(valor)
' "$1"
}

case "$AGENTE" in
  claude)
    # CLAUDECODE se quita para poder pushear desde una terminal abierta dentro de Claude Code.
    env -u CLAUDECODE claude -p --output-format json --allowedTools Read Grep Glob --max-turns 40 \
      | extraer result
    ;;
  codex)
    # `-` toma las instrucciones de stdin; -o guarda el último mensaje del agente.
    salida="$(mktemp)"
    trap 'rm -f "$salida"' EXIT
    codex exec --sandbox read-only --skip-git-repo-check -o "$salida" - >/dev/null
    cat "$salida"
    ;;
  agy)
    # agy es el CLI de Antigravity (https://antigravity.google).
    # Guardamos el prompt y el diff dentro de .review/ para que agy pueda leerlo directamente
    # sin desbordar el límite de longitud de línea de comandos en Windows.
    mkdir -p .review
    entrada="$(pwd)/.review/revision_en_curso.md"
    cat > "$entrada"
    trap 'rm -f "$entrada"' EXIT
    if command -v cygpath >/dev/null 2>&1; then
      entrada_win="$(cygpath -w "$entrada")"
    else
      entrada_win="$entrada"
    fi
    agy -p "Lee el archivo '$entrada_win'. Es fundamental que NO uses run_command ni ejecutes comandos ni pruebas. Todos los linters y tests ya pasaron al 100%. Tu única función es emitir el informe de revisión en Markdown y concluir obligatoriamente con la línea VEREDICTO: APROBADO o VEREDICTO: BLOQUEADO." --mode plan --dangerously-skip-permissions --print-timeout 10m
    rm -f "$entrada"
    ;;
  gemini)
    # gemini -p "" procesa el prompt recibido por stdin en modo headless y --output-format json
    # devuelve la estructura JSON con el campo "response".
    gemini -p "" --output-format json | extraer response
    ;;
  *)
    echo "AULERO_AGENTE='$AGENTE' no es un agente conocido (claude, codex, agy, gemini)." >&2
    exit 2
    ;;
esac

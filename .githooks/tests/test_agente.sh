#!/usr/bin/env bash
# Tests unitarios de los adaptadores de agente (.githooks/agente.sh).
#
# Verifica cómo .githooks/agente.sh invoca a cada agente soportado (gemini, claude, codex),
# el pasaje de prompt por stdin, el formato de salida esperado y el manejo de errores.
#
# Correr:  bash .githooks/tests/test_agente.sh
set -euo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
AGENTE_SH="$RAIZ/.githooks/agente.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

MOCK_BIN="$TMP/mock_bin"
mkdir -p "$MOCK_BIN"
RECORD_DIR="$TMP/records"
mkdir -p "$RECORD_DIR"

FAILURES=0
assert_equals() {
  local desc="$1" expected="$2" actual="$3"
  if [[ "$expected" == "$actual" ]]; then
    printf '  \033[32mOK\033[0m %s\n' "$desc"
  else
    printf '  \033[31mFALLO\033[0m %s\n    Esperado: %s\n    Obtenido: %s\n' "$desc" "$expected" "$actual"
    FAILURES=$((FAILURES + 1))
  fi
}

assert_contains() {
  local desc="$1" pattern="$2" actual="$3"
  if [[ "$actual" == *"$pattern"* ]]; then
    printf '  \033[32mOK\033[0m %s\n' "$desc"
  else
    printf '  \033[31mFALLO\033[0m %s\n    No contiene: %s\n    Obtenido: %s\n' "$desc" "$pattern" "$actual"
    FAILURES=$((FAILURES + 1))
  fi
}

echo "=== Tests unitarios de .githooks/agente.sh ==="

# --- 1. Adaptador Gemini CLI -----------------------------------------------------------------
cat >"$MOCK_BIN/gemini" <<'EOF'
#!/usr/bin/env bash
echo "$*" > "$RECORD_DIR/gemini-args.txt"
cat > "$RECORD_DIR/gemini-stdin.txt"
case "${MOCK_GEMINI_MODE:-ok}" in
  ok)
    printf '{"response": "VEREDICTO: APROBADO", "stats": {"tokens": 10}}\n'
    ;;
  missing_field)
    printf '{"other": "field"}\n'
    ;;
  malformed)
    printf 'not a json\n'
    ;;
esac
EOF
chmod +x "$MOCK_BIN/gemini"

echo "Caso: Gemini CLI llamado correctamente con -p \"\" --output-format json"
set +e
OUT=$(printf "Revisar este diff" | env -u AULERO_AGENTE_CMD AULERO_AGENTE=gemini RECORD_DIR="$RECORD_DIR" PATH="$MOCK_BIN:$PATH" bash "$AGENTE_SH" 2>"$TMP/err.txt")
CODE=$?
set -e
assert_equals "Código de salida es 0" "0" "$CODE"
assert_equals "Salida extraída del campo response" "VEREDICTO: APROBADO" "$OUT"
ARGS=$(cat "$RECORD_DIR/gemini-args.txt")
assert_contains "Flag -p presente" "-p" "$ARGS"
assert_contains "Flag --output-format json presente" "--output-format json" "$ARGS"
STDIN=$(cat "$RECORD_DIR/gemini-stdin.txt")
assert_equals "Prompt recibido por stdin" "Revisar este diff" "$STDIN"

echo "Caso: Gemini CLI respuesta sin campo response falla con código 3"
set +e
OUT=$(printf "Revisar este diff" | env -u AULERO_AGENTE_CMD AULERO_AGENTE=gemini MOCK_GEMINI_MODE=missing_field RECORD_DIR="$RECORD_DIR" PATH="$MOCK_BIN:$PATH" bash "$AGENTE_SH" 2>"$TMP/err.txt")
CODE=$?
set -e
assert_equals "Código de salida es 3" "3" "$CODE"
assert_contains "Mensaje de error en stderr" "el campo 'response'" "$(cat "$TMP/err.txt")"

echo "Caso: Gemini CLI respuesta JSON inválido falla con código 3"
set +e
OUT=$(printf "Revisar este diff" | env -u AULERO_AGENTE_CMD AULERO_AGENTE=gemini MOCK_GEMINI_MODE=malformed RECORD_DIR="$RECORD_DIR" PATH="$MOCK_BIN:$PATH" bash "$AGENTE_SH" 2>"$TMP/err.txt")
CODE=$?
set -e
assert_equals "Código de salida es 3" "3" "$CODE"
assert_contains "Mensaje de error en stderr" "el campo 'response'" "$(cat "$TMP/err.txt")"

# --- 2. Adaptador Claude Code ----------------------------------------------------------------
cat >"$MOCK_BIN/claude" <<'EOF'
#!/usr/bin/env bash
echo "$*" > "$RECORD_DIR/claude-args.txt"
cat > "$RECORD_DIR/claude-stdin.txt"
printf '{"result": "CLAUDE: APROBADO"}\n'
EOF
chmod +x "$MOCK_BIN/claude"

echo "Caso: Claude Code invocado con flags de solo lectura y extrae result"
set +e
OUT=$(printf "Revisar diff claude" | env -u AULERO_AGENTE_CMD AULERO_AGENTE=claude RECORD_DIR="$RECORD_DIR" PATH="$MOCK_BIN:$PATH" bash "$AGENTE_SH" 2>"$TMP/err.txt")
CODE=$?
set -e
assert_equals "Código de salida es 0" "0" "$CODE"
assert_equals "Salida extraída del campo result" "CLAUDE: APROBADO" "$OUT"
CLAUDE_ARGS=$(cat "$RECORD_DIR/claude-args.txt")
assert_contains "Flag -p presente" "-p" "$CLAUDE_ARGS"
assert_contains "Tools Read Grep Glob" "--allowedTools Read Grep Glob" "$CLAUDE_ARGS"

# --- 3. Adaptador Codex ----------------------------------------------------------------------
cat >"$MOCK_BIN/codex" <<'EOF'
#!/usr/bin/env bash
archivo_salida=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -o) archivo_salida="$2"; shift 2 ;;
    *) shift ;;
  esac
done
if [[ -n "$archivo_salida" ]]; then
  printf "CODEX: APROBADO\n" > "$archivo_salida"
fi
EOF
chmod +x "$MOCK_BIN/codex"

echo "Caso: Codex CLI invocado con exec en sandbox read-only"
set +e
OUT=$(printf "Revisar diff codex" | env -u AULERO_AGENTE_CMD AULERO_AGENTE=codex RECORD_DIR="$RECORD_DIR" PATH="$MOCK_BIN:$PATH" bash "$AGENTE_SH" 2>"$TMP/err.txt")
CODE=$?
set -e
assert_equals "Código de salida es 0" "0" "$CODE"
assert_equals "Salida desde archivo -o" "CODEX: APROBADO" "$OUT"

# --- 4. Adaptador agy (Antigravity CLI) -------------------------------------------------------
cat >"$MOCK_BIN/agy" <<'EOF'
#!/usr/bin/env bash
echo "$*" > "$RECORD_DIR/agy-args.txt"
printf "AGY: APROBADO\n"
EOF
chmod +x "$MOCK_BIN/agy"

echo "Caso: agy CLI invocado con --mode plan"
set +e
OUT=$(printf "Revisar diff agy" | env -u AULERO_AGENTE_CMD AULERO_AGENTE=agy RECORD_DIR="$RECORD_DIR" PATH="$MOCK_BIN:$PATH" bash "$AGENTE_SH" 2>"$TMP/err.txt")
CODE=$?
set -e
assert_equals "Código de salida es 0" "0" "$CODE"
assert_equals "Salida desde agy" "AGY: APROBADO" "$OUT"
AGY_ARGS=$(cat "$RECORD_DIR/agy-args.txt")
assert_contains "Flag --mode plan presente" "--mode plan" "$AGY_ARGS"

# --- 5. Casos borde de configuración de agente -----------------------------------------------
echo "Caso: AULERO_AGENTE no presente en PATH falla con código 2"
set +e
OUT=$(printf "prompt" | env -u AULERO_AGENTE_CMD AULERO_AGENTE=agente_inexistente PATH="$PATH" bash "$AGENTE_SH" 2>"$TMP/err.txt")
CODE=$?
set -e
assert_equals "Código de salida es 2" "2" "$CODE"
assert_contains "Mensaje indica agente no encontrado" "No se encontró 'agente_inexistente' en el PATH" "$(cat "$TMP/err.txt")"

touch "$MOCK_BIN/desconocido" && chmod +x "$MOCK_BIN/desconocido"
echo "Caso: AULERO_AGENTE ejecutable pero no soportado falla con código 2"
set +e
OUT=$(printf "prompt" | env -u AULERO_AGENTE_CMD AULERO_AGENTE=desconocido PATH="$MOCK_BIN:$PATH" bash "$AGENTE_SH" 2>"$TMP/err.txt")
CODE=$?
set -e
assert_equals "Código de salida es 2" "2" "$CODE"
assert_contains "Mensaje nombra agentes válidos" "no es un agente conocido (claude, codex, agy, gemini)" "$(cat "$TMP/err.txt")"

cat >"$MOCK_BIN/custom_runner" <<'EOF'
#!/usr/bin/env bash
printf "CUSTOM: %s\n" "$(cat)"
EOF
chmod +x "$MOCK_BIN/custom_runner"

echo "Caso: AULERO_AGENTE_CMD sobreescribe todo y ejecuta el comando provisto"
set +e
OUT=$(printf "hola custom" | env AULERO_AGENTE_CMD="$MOCK_BIN/custom_runner" bash "$AGENTE_SH" 2>"$TMP/err.txt")
CODE=$?
set -e
assert_equals "Código de salida es 0" "0" "$CODE"
assert_equals "Ejecuta directamente AULERO_AGENTE_CMD" "CUSTOM: hola custom" "$OUT"

echo
if [[ $FAILURES -eq 0 ]]; then
  echo "Todos los tests unitarios del adaptador pasaron."
else
  echo "$FAILURES tests fallaron."
  exit 1
fi

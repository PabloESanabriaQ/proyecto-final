#!/usr/bin/env bash
# Tests del hook de pre-push: los casos borde de la Fase 0 (docs/plan-de-fases.md).
#
# Arma un repo temporal con un `origin`, un `claude` falso en el PATH que devuelve un veredicto
# fijo, y alimenta el hook por stdin como lo hace git. Lint y tests reales se saltean
# (AULERO_HOOK_SIN_CHEQUEOS=1): acá se prueba la lógica del hook, no la de las herramientas.
#
# Correr:  bash .githooks/tests/test_pre_push.sh
set -euo pipefail

HOOK_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
FALLOS=0

# --- Infraestructura -------------------------------------------------------------------------

# `claude` falso: registra que fue llamado y responde con el veredicto que diga $VEREDICTO_FALSO.
mkdir -p "$TMP/bin"
cat >"$TMP/bin/claude-falso" <<'EOF'
#!/usr/bin/env bash
cat >"$LLAMADAS_DIR/prompt-$(date +%s%N).txt"
if [[ "${VEREDICTO_FALSO:-APROBADO}" == "CAIDO" ]]; then
  echo "simulación: agente no disponible" >&2
  exit 7
fi
python3 -c "import json,sys; print(json.dumps({'result': '## Bloqueantes\n- x\n\n## Resumen\nok\n\nVEREDICTO: ' + sys.argv[1]}))" "$VEREDICTO_FALSO"
EOF
chmod +x "$TMP/bin/claude-falso"

nuevo_repo() {
  # Crea $TMP/$1 con un origin que ya tiene main, y una rama de trabajo.
  local nombre="$1" dir="$TMP/$1"
  rm -rf "$dir" "$dir.git"
  git init -q --bare -b main "$dir.git"
  git init -q -b main "$dir"
  (
    cd "$dir"
    git config user.email t@t && git config user.name t
    git remote add origin "$dir.git"
    cp -r "$HOOK_SRC" .githooks
    mkdir -p docs backend solver frontend
    echo "# doc" >docs/x.md
    echo "print(1)" >backend/x.py
    git add -A && git commit -q -m base && git push -q origin main
    git checkout -q -b rama
  )
  echo "$dir"
}

correr_hook() {
  # correr_hook <dir> ; devuelve el código de salida del hook y deja la salida en $SALIDA_HOOK
  local dir="$1" sha
  sha="$(git -C "$dir" rev-parse HEAD)"
  export LLAMADAS_DIR="$dir/.llamadas"
  mkdir -p "$LLAMADAS_DIR"
  set +e
  SALIDA_HOOK="$(cd "$dir" && printf 'refs/heads/rama %s refs/heads/rama 0000000000000000000000000000000000000000\n' "$sha" \
    | AULERO_HOOK_SIN_CHEQUEOS=1 CLAUDE_BIN="$TMP/bin/claude-falso" bash .githooks/pre-push 2>&1)"
  CODIGO_HOOK=$?
  set -e
}

llamadas_al_agente() { find "$1/.llamadas" -type f | wc -l | tr -d ' '; }

ok() { printf '  \033[32mOK\033[0m  %s\n' "$1"; }
fallo() { printf '  \033[31mFALLO\033[0m %s\n        %s\n' "$1" "$2"; FALLOS=$((FALLOS + 1)); }
esperar() {
  # esperar <nombre> <condición bash> <detalle si falla>
  if eval "$2"; then ok "$1"; else fallo "$1" "$3"; fi
}

# --- Casos borde de la Fase 0 -----------------------------------------------------------------

echo "Caso: push que toca solo docs/ no invoca al agente"
DIR="$(nuevo_repo docs)"
(cd "$DIR" && echo "más" >>docs/x.md && git commit -qam docs)
VEREDICTO_FALSO=APROBADO correr_hook "$DIR"
esperar "el hook pasa" '[[ $CODIGO_HOOK -eq 0 ]]' "código $CODIGO_HOOK: $SALIDA_HOOK"
esperar "cero llamadas al agente" '[[ $(llamadas_al_agente "$DIR") -eq 0 ]]' "$(llamadas_al_agente "$DIR") llamadas"

echo "Caso: push sin cambios respecto de origin/main no invoca al agente"
DIR="$(nuevo_repo sincambios)"
VEREDICTO_FALSO=APROBADO correr_hook "$DIR"
esperar "el hook pasa" '[[ $CODIGO_HOOK -eq 0 ]]' "código $CODIGO_HOOK: $SALIDA_HOOK"
esperar "cero llamadas al agente" '[[ $(llamadas_al_agente "$DIR") -eq 0 ]]' "$(llamadas_al_agente "$DIR") llamadas"
esperar "lo dice en la salida" '[[ "$SALIDA_HOOK" == *"sin cambios"* ]]' "$SALIDA_HOOK"

echo "Caso: push con el agente no disponible falla con mensaje claro"
DIR="$(nuevo_repo caido)"
(cd "$DIR" && echo "print(2)" >>backend/x.py && git commit -qam code)
VEREDICTO_FALSO=CAIDO correr_hook "$DIR"
esperar "el hook bloquea" '[[ $CODIGO_HOOK -ne 0 ]]' "pasó con código 0"
esperar "el mensaje nombra al agente y el código" '[[ "$SALIDA_HOOK" == *"no respondió"* && "$SALIDA_HOOK" == *"código 7"* ]]' "$SALIDA_HOOK"
esperar "el stderr del agente queda en .review/error.log" '/usr/bin/grep -q "no disponible" "$DIR/.review/error.log"' "$(cat "$DIR/.review/error.log" 2>/dev/null)"

echo "Caso: push con el agente ausente del PATH falla con mensaje claro"
DIR="$(nuevo_repo ausente)"
(cd "$DIR" && echo "print(2)" >>backend/x.py && git commit -qam code)
SHA="$(git -C "$DIR" rev-parse HEAD)"
set +e
SALIDA_HOOK="$(cd "$DIR" && printf 'refs/heads/rama %s refs/heads/rama 0000000000000000000000000000000000000000\n' "$SHA" \
  | AULERO_HOOK_SIN_CHEQUEOS=1 CLAUDE_BIN="$TMP/no-existe" bash .githooks/pre-push 2>&1)"
CODIGO_HOOK=$?
set -e
esperar "el hook bloquea" '[[ $CODIGO_HOOK -ne 0 ]]' "pasó con código 0"
esperar "el mensaje dice qué instalar" '[[ "$SALIDA_HOOK" == *"No se encontró"* && "$SALIDA_HOOK" == *"Claude Code"* ]]' "$SALIDA_HOOK"

echo "Caso: push de una rama con varios commits revisa el diff acumulado"
DIR="$(nuevo_repo acumulado)"
(cd "$DIR" && echo "print(2)" >>backend/x.py && git commit -qam c1 \
  && echo "print(3)" >>backend/x.py && git commit -qam c2 \
  && echo "x = 1" >solver/y.py && git add -A && git commit -qm c3)
VEREDICTO_FALSO=APROBADO correr_hook "$DIR"
esperar "el hook pasa" '[[ $CODIGO_HOOK -eq 0 ]]' "código $CODIGO_HOOK: $SALIDA_HOOK"
esperar "una sola llamada al agente" '[[ $(llamadas_al_agente "$DIR") -eq 1 ]]' "$(llamadas_al_agente "$DIR") llamadas"
PROMPT="$(cat "$DIR"/.llamadas/*)"
esperar "el diff incluye los tres commits" '[[ "$PROMPT" == *"print(2)"* && "$PROMPT" == *"print(3)"* && "$PROMPT" == *"x = 1"* ]]' "faltan cambios en el prompt"
esperar "la salida queda en .review/ultima.md" '[[ -f "$DIR/.review/ultima.md" ]] && /usr/bin/grep -q "VEREDICTO: APROBADO" "$DIR/.review/ultima.md"' "no existe o sin veredicto"

echo "Caso: veredicto BLOQUEADO bloquea el push y muestra los hallazgos"
DIR="$(nuevo_repo bloqueado)"
(cd "$DIR" && echo "print(2)" >>backend/x.py && git commit -qam code)
VEREDICTO_FALSO=BLOQUEADO correr_hook "$DIR"
esperar "el hook bloquea" '[[ $CODIGO_HOOK -ne 0 ]]' "pasó con código 0"
esperar "muestra cómo descartar" '[[ "$SALIDA_HOOK" == *"AULERO_REVIEW_DESCARTAR"* ]]' "$SALIDA_HOOK"

echo "Caso: veredicto BLOQUEADO con descarte del autor deja pasar y lo registra"
DIR="$(nuevo_repo descartado)"
(cd "$DIR" && echo "print(2)" >>backend/x.py && git commit -qam code)
SHA="$(git -C "$DIR" rev-parse HEAD)"
export LLAMADAS_DIR="$DIR/.llamadas"; mkdir -p "$LLAMADAS_DIR"
set +e
SALIDA_HOOK="$(cd "$DIR" && printf 'refs/heads/rama %s refs/heads/rama 0000000000000000000000000000000000000000\n' "$SHA" \
  | AULERO_HOOK_SIN_CHEQUEOS=1 CLAUDE_BIN="$TMP/bin/claude-falso" VEREDICTO_FALSO=BLOQUEADO \
    AULERO_REVIEW_DESCARTAR="falso positivo: el test cubre el caso" bash .githooks/pre-push 2>&1)"
CODIGO_HOOK=$?
set -e
esperar "el hook pasa" '[[ $CODIGO_HOOK -eq 0 ]]' "código $CODIGO_HOOK: $SALIDA_HOOK"
esperar "el motivo queda en la salida" '/usr/bin/grep -q "descartado por el autor:\*\* falso positivo" "$DIR/.review/ultima.md"' "$(cat "$DIR/.review/ultima.md")"

echo "Caso: el diff que ve el agente no incluye lockfiles"
DIR="$(nuevo_repo lock)"
(cd "$DIR" && echo "print(2)" >>backend/x.py && echo "lock-enorme" >uv.lock && git add -A && git commit -qm code)
VEREDICTO_FALSO=APROBADO correr_hook "$DIR"
PROMPT="$(cat "$DIR"/.llamadas/*)"
esperar "uv.lock excluido del prompt" '[[ "$PROMPT" != *"lock-enorme"* ]]' "el lockfile está en el prompt"

echo "Caso: un diff con \`\`\` adentro no rompe la cerca del prompt"
DIR="$(nuevo_repo cerca)"
(cd "$DIR" && printf 'x = """\n```\n"""\n' >backend/z.py && git add -A && git commit -qm code)
VEREDICTO_FALSO=APROBADO correr_hook "$DIR"
PROMPT="$(cat "$DIR"/.llamadas/*)"
esperar "la cerca de cierre es la larga y está al final" '[[ "$(tail -n 1 <<<"$PROMPT")" == "\`\`\`\`\`\`" ]]' "última línea: $(tail -n 1 <<<"$PROMPT")"

echo
if [[ $FALLOS -eq 0 ]]; then
  echo "Todos los casos pasan."
else
  echo "$FALLOS verificación(es) fallaron."
  exit 1
fi

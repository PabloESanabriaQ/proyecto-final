#!/usr/bin/env bash
# Tests del hook de pre-push: los casos borde de la Fase 0 (docs/plan-de-fases.md).
#
# Arma un repo temporal con un `origin`, un agente falso (AULERO_AGENTE_CMD) que devuelve un
# veredicto fijo, y alimenta el hook por stdin como lo hace git. Lint y tests reales se saltean
# (AULERO_HOOK_SIN_CHEQUEOS=1) pero el hook registra qué hubiera corrido: acá se prueba la
# lógica del hook, no la de las herramientas.
#
# Correr:  bash .githooks/tests/test_pre_push.sh
set -euo pipefail

HOOK_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
FALLOS=0

# --- Infraestructura -------------------------------------------------------------------------

# Agente falso: registra el prompt que recibió y responde según $VEREDICTO_FALSO.
mkdir -p "$TMP/bin"
cat >"$TMP/bin/agente-falso" <<'EOF'
#!/usr/bin/env bash
cat >"$LLAMADAS_DIR/prompt-$(date +%s%N).txt"
case "${VEREDICTO_FALSO:-APROBADO}" in
  CAIDO) echo "simulación: agente no disponible" >&2; exit 7 ;;
  COLGADO) sleep 30; exit 0 ;;
  ECO_DEL_PROMPT)
    # Aprueba, pero después repite la instrucción del prompt que menciona BLOQUEADO.
    printf '## Resumen\nok\n\nVEREDICTO: APROBADO\n(o `VEREDICTO: BLOQUEADO` si hay al menos un bloqueante.)\n' ;;
  NEGRITA) printf '## Resumen\nok\n\n**VEREDICTO: APROBADO**\n' ;;
  *) printf '## Bloqueantes\n- x\n\n## Resumen\nok\n\nVEREDICTO: %s\n' "$VEREDICTO_FALSO" ;;
esac
EOF
chmod +x "$TMP/bin/agente-falso"

# PATH mínimo para los casos "sin agente": todo lo que hay en el PATH real, menos los agentes.
PATH_MIN=""
IFS=: read -ra DIRS_PATH <<<"$PATH"
for d in "${DIRS_PATH[@]}"; do
  [[ -d "$d" ]] || continue
  tiene_agente=false
  for a in claude codex gemini; do
    if [[ -e "$d/$a" || -e "$d/$a.exe" || -e "$d/$a.cmd" ]]; then
      tiene_agente=true
      break
    fi
  done
  if $tiene_agente; then
    d_filtrado="$TMP/binmin_$(basename "$d")"
    mkdir -p "$d_filtrado"
    for f in "$d"/*; do
      [[ -x "$f" && ! -d "$f" ]] || continue
      nombre="${f##*/}"
      case "$nombre" in claude*|codex*|gemini*) continue ;; esac
      [[ -e "$d_filtrado/$nombre" ]] || ln -s "$f" "$d_filtrado/$nombre" 2>/dev/null || cp "$f" "$d_filtrado/$nombre"
    done
    PATH_MIN="${PATH_MIN:+$PATH_MIN:}$d_filtrado"
  else
    PATH_MIN="${PATH_MIN:+$PATH_MIN:}$d"
  fi
done

nuevo_repo() {
  # Crea $TMP/$1 con un origin que ya tiene main, y una rama de trabajo.
  local nombre="$1" dir="$TMP/$1"
  rm -rf "$dir" "$dir.git"
  git init -q --bare -b main "$dir.git"
  git init -q -b main "$dir"
  (
    cd "$dir"
    # Aislar de la configuración global (firma GPG, hooks, plantillas).
    git config user.email t@t && git config user.name t
    git config commit.gpgsign false && git config core.hooksPath /dev/null
    git remote add origin "$dir.git"
    cp -r "$HOOK_SRC" .githooks
    mkdir -p docs backend solver frontend
    echo "# doc" >docs/x.md
    echo "print(1)" >backend/x.py
    echo "export {};" >frontend/x.ts
    git add -A && git commit -q -m base && git push -q origin main
    git checkout -q -b rama
  )
  echo "$dir"
}

correr_hook_con_stdin() {
  # correr_hook_con_stdin <dir> <líneas de stdin> [VAR=valor ...]; deja código en $CODIGO_HOOK,
  # salida en $SALIDA_HOOK y las partes que el hook decidió chequear en $REGISTRO.
  local dir="$1" stdin="$2"; shift 2
  export LLAMADAS_DIR="$dir/.llamadas"
  mkdir -p "$LLAMADAS_DIR"
  REGISTRO="$dir/.registro"; : >"$REGISTRO"
  set +e
  SALIDA_HOOK="$(cd "$dir" && printf '%s\n' "$stdin" \
    | env "${LIMPIAR[@]}" AULERO_HOOK_SIN_CHEQUEOS=1 AULERO_HOOK_REGISTRO="$REGISTRO" AULERO_AGENTE_CMD="$TMP/bin/agente-falso" "$@" bash .githooks/pre-push 2>&1)"
  CODIGO_HOOK=$?
  set -e
}

correr_hook() {
  # correr_hook <dir> [VAR=valor ...]: push de la rama actual.
  local dir="$1"; shift
  local sha
  sha="$(git -C "$dir" rev-parse HEAD)"
  correr_hook_con_stdin "$dir" "refs/heads/rama $sha refs/heads/rama 0000000000000000000000000000000000000000" "$@"
}

llamadas_al_agente() { find "$1/.llamadas" -type f | wc -l | tr -d ' '; }

# Variables AULERO_* que el shell de quien corre la suite puede tener exportadas (el README
# recomienda `export AULERO_AGENTE=...`). Cada invocación del hook las limpia primero y después
# aplica solo las del caso, para que la suite dé lo mismo en cualquier máquina.
LIMPIAR=(-u AULERO_AGENTE -u AULERO_AGENTE_CMD -u AULERO_REVIEW_DESCARTAR -u AULERO_HOOK_TIMEOUT -u AULERO_HOOK_SIN_CHEQUEOS -u AULERO_HOOK_REGISTRO)

ok() { printf '  \033[32mOK\033[0m  %s\n' "$1"; }
fallo() { printf '  \033[31mFALLO\033[0m %s\n        %s\n' "$1" "$2"; FALLOS=$((FALLOS + 1)); }
esperar() {
  # esperar <nombre> <condición bash> <detalle si falla>
  if eval "$2"; then ok "$1"; else fallo "$1" "$3"; fi
}

# --- Tests unitarios de adaptadores (.githooks/agente.sh) ------------------------------------
bash "$HOOK_SRC/tests/test_agente.sh"
echo

# --- Casos borde de la Fase 0 -----------------------------------------------------------------

echo "Caso: push que toca solo docs/ no invoca al agente"
DIR="$(nuevo_repo docs)"
(cd "$DIR" && echo "más" >>docs/x.md && git commit -qam docs)
correr_hook "$DIR" VEREDICTO_FALSO=APROBADO
esperar "el hook pasa" '[[ $CODIGO_HOOK -eq 0 ]]' "código $CODIGO_HOOK: $SALIDA_HOOK"
esperar "cero llamadas al agente" '[[ $(llamadas_al_agente "$DIR") -eq 0 ]]' "$(llamadas_al_agente "$DIR") llamadas"
esperar "no corre ningún chequeo" '[[ ! -s "$REGISTRO" ]]' "$(cat "$REGISTRO")"

echo "Caso: push que toca solo frontend/ no corre los chequeos de Python (y viceversa)"
DIR="$(nuevo_repo solofront)"
(cd "$DIR" && echo "export const a = 1;" >>frontend/x.ts && git commit -qam front)
correr_hook "$DIR" VEREDICTO_FALSO=APROBADO
esperar "corre frontend y no python" '[[ "$(cat "$REGISTRO")" == "frontend" ]]' "registro: $(cat "$REGISTRO")"
DIR="$(nuevo_repo solopy)"
(cd "$DIR" && echo "print(2)" >>backend/x.py && git commit -qam py)
correr_hook "$DIR" VEREDICTO_FALSO=APROBADO
esperar "corre python y no frontend" '[[ "$(cat "$REGISTRO")" == "python" ]]' "registro: $(cat "$REGISTRO")"

echo "Caso: push sin cambios respecto de origin/main no invoca al agente"
DIR="$(nuevo_repo sincambios)"
correr_hook "$DIR" VEREDICTO_FALSO=APROBADO
esperar "el hook pasa" '[[ $CODIGO_HOOK -eq 0 ]]' "código $CODIGO_HOOK: $SALIDA_HOOK"
esperar "cero llamadas al agente" '[[ $(llamadas_al_agente "$DIR") -eq 0 ]]' "$(llamadas_al_agente "$DIR") llamadas"
esperar "lo dice en la salida" '[[ "$SALIDA_HOOK" == *"sin cambios"* ]]' "$SALIDA_HOOK"

echo "Caso: push con el agente caído falla con mensaje claro"
DIR="$(nuevo_repo caido)"
(cd "$DIR" && echo "print(2)" >>backend/x.py && git commit -qam code)
correr_hook "$DIR" VEREDICTO_FALSO=CAIDO
esperar "el hook bloquea" '[[ $CODIGO_HOOK -ne 0 ]]' "pasó con código 0"
esperar "el mensaje nombra al agente y el código" '[[ "$SALIDA_HOOK" == *"no respondió"* && "$SALIDA_HOOK" == *"código 7"* ]]' "$SALIDA_HOOK"
esperar "el stderr del agente queda en .review/error.log" 'grep -q "no disponible" "$DIR/.review/error.log"' "$(cat "$DIR/.review/error.log" 2>/dev/null)"

correr_hook_real_sin_agentes() {
  # correr_hook_real_sin_agentes <dir> [VAR=valor ...]: como correr_hook pero SIN agente falso y
  # con un PATH mínimo (todo lo que el hook necesita, ningún agente), para probar agente.sh.
  local dir="$1"; shift
  export LLAMADAS_DIR="$dir/.llamadas"; mkdir -p "$LLAMADAS_DIR"
  set +e
  SALIDA_HOOK="$(cd "$dir" && printf 'refs/heads/rama %s refs/heads/rama 0000000000000000000000000000000000000000\n' "$(git -C "$dir" rev-parse HEAD)" \
    | env "${LIMPIAR[@]}" AULERO_HOOK_SIN_CHEQUEOS=1 PATH="$PATH_MIN" "$@" bash .githooks/pre-push 2>&1)"
  CODIGO_HOOK=$?
  set -e
}

echo "Caso: push sin ningún agente instalado falla con mensaje claro"
DIR="$(nuevo_repo ausente)"
(cd "$DIR" && echo "print(2)" >>backend/x.py && git commit -qam code)
correr_hook_real_sin_agentes "$DIR"
esperar "el hook bloquea" '[[ $CODIGO_HOOK -ne 0 ]]' "pasó con código 0"
esperar "el mensaje dice qué instalar" '[[ "$SALIDA_HOOK" == *"No se encontró ningún agente"* ]]' "$SALIDA_HOOK"

echo "Caso: AULERO_AGENTE apunta a un agente no instalado"
DIR="$(nuevo_repo noinstalado)"
(cd "$DIR" && echo "print(2)" >>backend/x.py && git commit -qam code)
correr_hook_real_sin_agentes "$DIR" AULERO_AGENTE=codex
esperar "el hook bloquea" '[[ $CODIGO_HOOK -ne 0 ]]' "pasó con código 0"
esperar "nombra al agente pedido" '[[ "$SALIDA_HOOK" == *"No se encontró "*"codex"*"en el PATH"* ]]' "$SALIDA_HOOK"

echo "Caso: push con el agente colgado falla por tope de tiempo"
DIR="$(nuevo_repo colgado)"
(cd "$DIR" && echo "print(2)" >>backend/x.py && git commit -qam code)
correr_hook "$DIR" VEREDICTO_FALSO=COLGADO AULERO_HOOK_TIMEOUT=2
esperar "el hook bloquea" '[[ $CODIGO_HOOK -ne 0 ]]' "pasó con código 0"
esperar "el mensaje habla del tope" '[[ "$SALIDA_HOOK" == *"no respondió en 2s"* ]]' "$SALIDA_HOOK"

echo "Caso: push de una rama con varios commits revisa el diff acumulado"
DIR="$(nuevo_repo acumulado)"
(cd "$DIR" && echo "print(2)" >>backend/x.py && git commit -qam c1 \
  && echo "print(3)" >>backend/x.py && git commit -qam c2 \
  && echo "x = 1" >solver/y.py && git add -A && git commit -qm c3)
correr_hook "$DIR" VEREDICTO_FALSO=APROBADO
esperar "el hook pasa" '[[ $CODIGO_HOOK -eq 0 ]]' "código $CODIGO_HOOK: $SALIDA_HOOK"
esperar "una sola llamada al agente" '[[ $(llamadas_al_agente "$DIR") -eq 1 ]]' "$(llamadas_al_agente "$DIR") llamadas"
PROMPT="$(cat "$DIR"/.llamadas/*)"
esperar "el diff incluye los tres commits" '[[ "$PROMPT" == *"print(2)"* && "$PROMPT" == *"print(3)"* && "$PROMPT" == *"x = 1"* ]]' "faltan cambios en el prompt"
esperar "la salida queda en .review/ultima.md" '[[ -f "$DIR/.review/ultima.md" ]] && grep -q "VEREDICTO: APROBADO" "$DIR/.review/ultima.md"' "no existe o sin veredicto"

echo "Caso: veredicto BLOQUEADO bloquea el push y muestra los hallazgos"
DIR="$(nuevo_repo bloqueado)"
(cd "$DIR" && echo "print(2)" >>backend/x.py && git commit -qam code)
correr_hook "$DIR" VEREDICTO_FALSO=BLOQUEADO
esperar "el hook bloquea" '[[ $CODIGO_HOOK -ne 0 ]]' "pasó con código 0"
esperar "muestra cómo descartar" '[[ "$SALIDA_HOOK" == *"AULERO_REVIEW_DESCARTAR"* ]]' "$SALIDA_HOOK"

echo "Caso: veredicto BLOQUEADO con descarte del autor deja pasar y lo registra"
DIR="$(nuevo_repo descartado)"
(cd "$DIR" && echo "print(2)" >>backend/x.py && git commit -qam code)
correr_hook "$DIR" VEREDICTO_FALSO=BLOQUEADO AULERO_REVIEW_DESCARTAR="falso positivo: el test cubre el caso"
esperar "el hook pasa" '[[ $CODIGO_HOOK -eq 0 ]]' "código $CODIGO_HOOK: $SALIDA_HOOK"
esperar "el motivo queda en la salida" 'grep -q "descartado por el autor:\*\* falso positivo" "$DIR/.review/ultima.md"' "$(cat "$DIR/.review/ultima.md")"

echo "Caso: un APROBADO seguido de una mención a BLOQUEADO en el texto no bloquea"
DIR="$(nuevo_repo eco)"
(cd "$DIR" && echo "print(2)" >>backend/x.py && git commit -qam code)
correr_hook "$DIR" VEREDICTO_FALSO=ECO_DEL_PROMPT
esperar "el hook pasa" '[[ $CODIGO_HOOK -eq 0 ]]' "código $CODIGO_HOOK: $SALIDA_HOOK"

echo "Caso: el veredicto en negrita se reconoce"
DIR="$(nuevo_repo negrita)"
(cd "$DIR" && echo "print(2)" >>backend/x.py && git commit -qam code)
correr_hook "$DIR" VEREDICTO_FALSO=NEGRITA
esperar "el hook pasa" '[[ $CODIGO_HOOK -eq 0 ]]' "código $CODIGO_HOOK: $SALIDA_HOOK"

echo "Caso: el diff que ve el agente no incluye lockfiles"
DIR="$(nuevo_repo lock)"
(cd "$DIR" && echo "print(2)" >>backend/x.py && echo "lock-enorme" >uv.lock && git add -A && git commit -qm code)
correr_hook "$DIR" VEREDICTO_FALSO=APROBADO
PROMPT="$(cat "$DIR"/.llamadas/*)"
esperar "uv.lock excluido del prompt" '[[ "$PROMPT" != *"lock-enorme"* ]]' "el lockfile está en el prompt"

echo "Caso: un diff con \`\`\` adentro no rompe la cerca del prompt"
DIR="$(nuevo_repo cerca)"
(cd "$DIR" && printf 'x = """\n```\n"""\n' >backend/z.py && git add -A && git commit -qm code)
correr_hook "$DIR" VEREDICTO_FALSO=APROBADO
PROMPT="$(cat "$DIR"/.llamadas/*)"
esperar "la cerca de cierre es la larga y está al final" '[[ "$(tail -n 1 <<<"$PROMPT")" == "\`\`\`\`\`\`" ]]' "última línea: $(tail -n 1 <<<"$PROMPT")"

echo "Caso: borrar una rama remota no revisa nada"
DIR="$(nuevo_repo borrado)"
correr_hook_con_stdin "$DIR" "(delete) 0000000000000000000000000000000000000000 refs/heads/rama $(git -C "$DIR" rev-parse HEAD)" VEREDICTO_FALSO=APROBADO
esperar "el hook pasa" '[[ $CODIGO_HOOK -eq 0 ]]' "código $CODIGO_HOOK: $SALIDA_HOOK"
esperar "cero llamadas al agente" '[[ $(llamadas_al_agente "$DIR") -eq 0 ]]' "$(llamadas_al_agente "$DIR") llamadas"

echo "Caso: push de varias ramas a la vez revisa cada una"
DIR="$(nuevo_repo variasrefs)"
(cd "$DIR" && echo "print(2)" >>backend/x.py && git commit -qam a \
  && git checkout -qb otra origin/main && echo "x = 1" >solver/y.py && git add -A && git commit -qm b)
SHA_A="$(git -C "$DIR" rev-parse rama)"; SHA_B="$(git -C "$DIR" rev-parse otra)"
correr_hook_con_stdin "$DIR" "refs/heads/rama $SHA_A refs/heads/rama 0000000000000000000000000000000000000000
refs/heads/otra $SHA_B refs/heads/otra 0000000000000000000000000000000000000000" VEREDICTO_FALSO=APROBADO
esperar "el hook pasa" '[[ $CODIGO_HOOK -eq 0 ]]' "código $CODIGO_HOOK: $SALIDA_HOOK"
esperar "dos llamadas al agente, una por rama" '[[ $(llamadas_al_agente "$DIR") -eq 2 ]]' "$(llamadas_al_agente "$DIR") llamadas"
esperar "una salida por commit" '[[ -f "$DIR/.review/$(git -C "$DIR" rev-parse --short rama).md" && -f "$DIR/.review/$(git -C "$DIR" rev-parse --short otra).md" ]]' "$(ls "$DIR/.review")"

echo "Caso: sin red se usa la última origin/main conocida y se avisa"
DIR="$(nuevo_repo sinred)"
(cd "$DIR" && echo "print(2)" >>backend/x.py && git commit -qam code && git remote set-url origin /no/existe)
correr_hook "$DIR" VEREDICTO_FALSO=APROBADO
esperar "el hook pasa" '[[ $CODIGO_HOOK -eq 0 ]]' "código $CODIGO_HOOK: $SALIDA_HOOK"
esperar "avisa que no pudo actualizar" '[[ "$SALIDA_HOOK" == *"No se pudo actualizar origin/main"* ]]' "$SALIDA_HOOK"
esperar "igual revisa contra la base conocida" '[[ $(llamadas_al_agente "$DIR") -eq 1 ]]' "$(llamadas_al_agente "$DIR") llamadas"

echo "Caso: cambios sin commitear producen un aviso, no un bloqueo"
DIR="$(nuevo_repo sucio)"
(cd "$DIR" && echo "print(2)" >>backend/x.py && git commit -qam code && echo "print(3)" >>backend/x.py)
correr_hook "$DIR" VEREDICTO_FALSO=APROBADO
esperar "el hook pasa" '[[ $CODIGO_HOOK -eq 0 ]]' "código $CODIGO_HOOK: $SALIDA_HOOK"
esperar "avisa de la divergencia" '[[ "$SALIDA_HOOK" == *"sin commitear"* ]]' "$SALIDA_HOOK"

echo "Caso: la suite ignora las variables AULERO_* exportadas en el shell de quien la corre"
# Simula a quien siguió el README (export AULERO_AGENTE=codex) y además tiene un descarte
# pendiente en el entorno: los escenarios "sin agente" y "BLOQUEADO bloquea" tienen que dar lo
# mismo que sin esas variables.
export AULERO_AGENTE=codex AULERO_REVIEW_DESCARTAR="descarte heredado del shell"
DIR="$(nuevo_repo heredado1)"
(cd "$DIR" && echo "print(2)" >>backend/x.py && git commit -qam code)
correr_hook_real_sin_agentes "$DIR"
esperar "sin agente: sigue diciendo 'ningún agente', no 'codex'" '[[ "$SALIDA_HOOK" == *"No se encontró ningún agente"* ]]' "$SALIDA_HOOK"
DIR="$(nuevo_repo heredado2)"
(cd "$DIR" && echo "print(2)" >>backend/x.py && git commit -qam code)
correr_hook "$DIR" VEREDICTO_FALSO=BLOQUEADO
esperar "BLOQUEADO: sigue bloqueando, el descarte del shell no cuenta" '[[ $CODIGO_HOOK -ne 0 ]]' "pasó con código 0: $SALIDA_HOOK"
unset AULERO_AGENTE AULERO_REVIEW_DESCARTAR

echo
if [[ $FALLOS -eq 0 ]]; then
  echo "Todos los casos pasan."
else
  echo "$FALLOS verificación(es) fallaron."
  exit 1
fi

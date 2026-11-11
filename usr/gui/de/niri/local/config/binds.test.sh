#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
script=$(nix-build --no-out-link --expr 'let pkgs = import <nixpkgs> {}; binds = import ./binds.nix { inherit pkgs; }; in pkgs.runCommand "test-niri-binds" {} ("cp " + binds."Ctrl+Shift+Alt+Up".spawn + " $out")')
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export TMP="$tmp" LOG="$tmp/log" XDG_RUNTIME_DIR="$tmp" PATH="$tmp:$PATH"
cat > "$tmp/niri" <<'SH'
#!/usr/bin/env bash
set -eu
case "$*" in
  'msg -j workspaces')
    echo workspaces >> "$LOG"
    if [[ -e "$TMP/hold" ]]; then
      rm "$TMP/hold"
      : > "$TMP/entered"
      sleep 0.3
    fi
    if [[ -s "$TMP/name" ]]; then
      name=$(<"$TMP/name")
      if [[ "${SCENARIO:-}" == wrong-monitor ]]; then
        printf '[{"idx":3,"id":3,"output":"A","is_focused":false},{"idx":5,"id":5,"output":"A"},{"idx":3,"id":30,"output":"B","is_focused":true},{"idx":5,"id":50,"name":"%s","output":"B","active_window_id":null},{"idx":6,"id":60,"output":"B"}]\n' "$name"
      else
        printf '[{"idx":3,"id":3,"output":"A","is_focused":true},{"idx":5,"id":5,"name":"%s","output":"A","active_window_id":null},{"idx":5,"id":50,"output":"B"}]\n' "$name"
      fi
    else
      printf '%s\n' '[{"idx":3,"id":3,"output":"A","is_focused":true},{"idx":5,"id":5,"output":"A"},{"idx":5,"id":50,"name":"Pinned","output":"B"},{"idx":6,"id":60,"output":"B"}]'
    fi
    ;;
  'msg -j windows')
    if [[ "${SCENARIO:-}" == wrong-monitor ]]; then
      printf '%s\n' '[{"workspace_id":50}]'
    elif [[ "${SCENARIO:-}" == occupied ]]; then
      printf '%s\n' '[{"workspace_id":5}]'
    else
      printf '%s\n' '[]'
    fi
    ;;
  'msg action set-workspace-name '*)
    echo "$4" > "$TMP/name"
    echo "set $4" >> "$LOG"
    ;;
  'msg action unset-workspace-name '*)
    rm "$TMP/name"
    echo unset >> "$LOG"
    ;;
  'msg action '*)
    echo "$3" >> "$LOG"
    ;;
  *) exit 1 ;;
esac
SH
chmod +x "$tmp/niri"

for scenario in wrong-monitor occupied; do
  rm -f "$tmp/name"
  : > "$LOG"
  if SCENARIO="$scenario" "$script"; then echo "$scenario: should abort" >&2; exit 1; fi
  if grep -q 'move-workspace-to-index' "$LOG"; then
    echo "$scenario: moved an occupied workspace" >&2; exit 1
  fi
  if [[ $scenario == wrong-monitor ]]; then
    grep -q '^set Pinned$' "$LOG" || { echo 'lost original workspace name' >&2; exit 1; }
  else
    grep -q '^unset$' "$LOG" || { echo 'temporary workspace name remained' >&2; exit 1; }
  fi
done

rm -f "$tmp/name"
: > "$LOG"
: > "$tmp/hold"
"$script" & first=$!
for i in {1..100}; do
  [[ -e "$tmp/entered" ]] && break
  sleep 0.01
done
[[ -e "$tmp/entered" ]] || { echo 'first invocation did not start' >&2; exit 1; }
"$script" & second=$!
sleep 0.1
if [[ $(grep -c '^workspaces$' "$LOG") != 1 ]]; then
  echo 'overlapping invocations read the same workspace snapshot' >&2; exit 1
fi
wait "$first"
wait "$second"
[[ $(grep -c '^move-workspace-to-index$' "$LOG") == 2 ]]
[[ ! -e "$tmp/name" ]]
echo 'workspace bindings: OK'

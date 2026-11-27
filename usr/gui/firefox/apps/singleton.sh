#!/usr/bin/env bash
set -e

if (( $# < 2 )) || [[ $1 == -h ]]; then
  echo "Usage: ${0##*/} <app-id> <command and its args>"
  exit 0
fi

app=$1
shift
windows=$(niri msg --json windows)
anchor=$(jq -r '.[] | select(.is_focused) | [.id, .workspace_id] | @tsv' <<<"$windows")
target=$(jq -r --arg app "$app" '[.[] | select(.app_id == $app)] | (map(select(.is_focused))[0] // .[0]) | if . == null then empty else [.id, .workspace_id] | @tsv end' <<<"$windows")
if [[ -z $target ]]; then
  exec "$@"
fi
read -r target_id target_ws <<<"$target"
if [[ -z $anchor ]]; then
  workspace=$(niri msg --json workspaces | jq -r '.[] | select(.is_focused) | [.id, .output] | @tsv')
  if [[ -z $workspace ]]; then
    echo "No focused workspace" >&2
    exit 1
  fi
  read -r current_ws output <<<"$workspace"
  if [[ $target_ws != "$current_ws" ]]; then
    niri msg action move-window-to-monitor --id "$target_id" "$output"
  fi
  niri msg action focus-window --id "$target_id"
  exit
fi
read -r anchor_id anchor_ws <<<"$anchor"
if [[ $anchor_id == "$target_id" ]]; then
  exit
fi

if [[ $target_ws != "$anchor_ws" ]]; then
  output=$(niri msg --json workspaces | jq -r --argjson id "$anchor_ws" '.[] | select(.id == $id) | .output')
  niri msg action move-window-to-monitor --id "$target_id" "$output"
fi

# A floating anchor has no column to position beside.
windows=$(niri msg --json windows)
anchor_col=$(jq -r --argjson id "$anchor_id" '.[] | select(.id == $id) | .layout.pos_in_scrolling_layout[0] // 0' <<<"$windows")
if (( anchor_col )) && [[ $(jq -r --argjson id "$target_id" '.[] | select(.id == $id) | .is_floating' <<<"$windows") == true ]]; then
  niri msg action move-window-to-tiling --id "$target_id"
  windows=$(niri msg --json windows)
  anchor_col=$(jq -r --argjson id "$anchor_id" '.[] | select(.id == $id) | .layout.pos_in_scrolling_layout[0] // 0' <<<"$windows")
fi

read -r target_ws target_col <<<"$(jq -r --argjson id "$target_id" '.[] | select(.id == $id) | [.workspace_id, (.layout.pos_in_scrolling_layout[0] // 0)] | @tsv' <<<"$windows")"
if [[ $target_ws != "$anchor_ws" ]]; then
  echo "Could not move window to the focused workspace" >&2
  exit 1
fi
if (( anchor_col && target_col )); then
  count=$(jq -r --argjson ws "$anchor_ws" --argjson col "$target_col" '[.[] | select(.workspace_id == $ws and .layout.pos_in_scrolling_layout[0] == $col)] | length' <<<"$windows")
  if (( count > 1 )); then
    niri msg action consume-or-expel-window-right --id "$target_id"
    windows=$(niri msg --json windows)
    anchor_col=$(jq -r --argjson id "$anchor_id" '.[] | select(.id == $id) | .layout.pos_in_scrolling_layout[0]' <<<"$windows")
    target_col=$(jq -r --argjson id "$target_id" '.[] | select(.id == $id) | .layout.pos_in_scrolling_layout[0]' <<<"$windows")
  fi
  if (( target_col < anchor_col )); then
    destination=$anchor_col
  else
    destination=$((anchor_col + 1))
  fi
fi

niri msg action focus-window --id "$target_id"
if [[ ${destination:-$target_col} != "$target_col" ]]; then
  niri msg action move-column-to-index "$destination"
fi

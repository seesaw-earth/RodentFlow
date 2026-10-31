#!/usr/bin/env bash
# encode-all.sh — encode every recording in the list below with one command.
#
#   tools/encode-all.sh [SOURCE_FOLDER]
#
# SOURCE_FOLDER defaults to ~/Downloads/APP_demo/3x. Files missing from it are skipped.
# Edit the list to swap clips or trim them; each line is
#   source-file   output-name   [options for encode.sh, e.g. --start 1 --dur 12 --thumb 5]
# The output names must match the "file" entries in CLIPS near the bottom of index.html.

set -euo pipefail
SRC=${1:-"$HOME/Downloads/APP_demo/3x"}
ENC="$(cd "$(dirname "$0")" && pwd)/encode.sh"
[ -d "$SRC" ] || { echo "Folder not found: $SRC" >&2; exit 1; }

n=0
while read -r file name opts; do
  case "$file" in ""|\#*) continue;; esac
  if [ ! -f "$SRC/$file" ]; then echo "skip: $SRC/$file not found" >&2; continue; fi
  # shellcheck disable=SC2086
  bash "$ENC" "$SRC/$file" "$name" $opts < /dev/null
  n=$((n+1))
done <<'LIST'
# iPhone recordings (portrait)
two_mice.mp4            two-mice
open_field.mp4          open-field
3_chamber.mp4           three-chamber
new_object.mp4          novel-object
Y_maze.mp4              y-maze
TST.mp4                 tail-suspension
# Mac recordings (landscape)
MAC_head_direction.mp4  mac-head-direction
MAC_elevated_maze.mp4   mac-plus-maze
# Spares: move a line above this one to use it, and add it to CLIPS in index.html
# MAC_Social.mp4        mac-social
# MAC_openfield.mp4     mac-open-field
# MAC_barne_maze.mp4    mac-barnes-maze
# head_direction.mp4    head-direction
# elevated_maze.mp4     plus-maze
# barne.mp4             barnes-maze
# light_dark_room.mp4   light-dark
# gait.mp4              gait
# Cylinder.mp4          cylinder
# TST_single.mp4        tail-suspension-single
LIST

echo "Done: $n clips in $(cd "$(dirname "$0")/../../docs/public" && pwd)/videos"
du -ch "$(cd "$(dirname "$0")/../../docs/public" && pwd)"/videos/*.mp4 2>/dev/null | tail -1

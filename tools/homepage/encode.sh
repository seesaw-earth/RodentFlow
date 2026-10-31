#!/usr/bin/env bash
# encode.sh — turn one screen recording into a web clip that plays and loops smoothly.
#
#   tools/encode.sh INPUT NAME [options]
#
#   INPUT   any video ffmpeg can read (.mp4, .mov …)
#   NAME    output name without extension, e.g. two-mice
#           → writes videos/NAME.mp4        the clip
#                    videos/NAME.jpg        poster = first frame (shown before the clip plays)
#                    videos/NAME-thumb.jpg  small frame for the thumbnail strip
#
# Options
#   --start S    start at S seconds in the source                (default 0)
#   --dur D      use D seconds of the source                      (default: to the end)
#   --speed N    bake an N× speed-up into the file                (default 1)
#   --width W    output width in pixels                           (default: 720 for portrait
#                                                                  iPhone recordings, 1600 for
#                                                                  landscape Mac recordings)
#   --fade F     cross-fade F seconds of the end into the start   (default 0.3; 0 = off)
#                so the loop point is invisible
#   --crf Q      quality, lower = sharper and larger              (default 23)
#   --fps R      maximum frame rate                               (default 30; screen
#                                                                  recordings are 60, which
#                                                                  doubles the decoding work)
#   --thumb T    take the thumbnail T seconds into the clip      (default: 40% of the way)
#
# Examples
#   tools/encode.sh ~/Downloads/APP_demo/3x/two_mice.mp4  two-mice
#   tools/encode.sh ~/Downloads/APP_demo/3x/open_field.mp4 open-field --start 1.5 --dur 12
#   tools/encode.sh ~/Downloads/APP_demo/3x/MAC_Social.mp4 mac-social --thumb 4
#
# Needs ffmpeg 4.3 or newer (macOS: brew install ffmpeg). Works with the bash that ships with macOS.

set -euo pipefail

if [ $# -lt 2 ]; then
  sed -n '2,32p' "$0"; exit 1
fi

IN=$1; NAME=$2; shift 2
START=0; DUR=""; SPEED=1; WIDTH=auto; FADE=0.3; CRF=23; FPSMAX=30; THUMB=""
PRESET=${PRESET:-medium}

while [ $# -gt 0 ]; do
  case "$1" in
    --start) START=$2; shift 2;;
    --dur)   DUR=$2;   shift 2;;
    --speed) SPEED=$2; shift 2;;
    --width) WIDTH=$2; shift 2;;
    --fade)  FADE=$2;  shift 2;;
    --crf)   CRF=$2;   shift 2;;
    --fps)   FPSMAX=$2; shift 2;;
    --thumb) THUMB=$2; shift 2;;
    *) echo "Unknown option: $1" >&2; exit 1;;
  esac
done

command -v ffmpeg >/dev/null || { echo "ffmpeg not found. On a Mac: brew install ffmpeg" >&2; exit 1; }
[ -f "$IN" ] || { echo "Input not found: $IN" >&2; exit 1; }

# Clips go to docs/public/videos, which the home pages (/ and /zh/) load.
HERE=$(cd "$(dirname "$0")/../../docs/public" && pwd)
OUTDIR="$HERE/videos"; mkdir -p "$OUTDIR"
OUT="$OUTDIR/$NAME.mp4"; POSTER="$OUTDIR/$NAME.jpg"; THUMBF="$OUTDIR/$NAME-thumb.jpg"

probe() { ffprobe -v error -select_streams v:0 -show_entries "$1" -of default=nw=1:nk=1 "$IN" | head -1; }

# --- source facts -----------------------------------------------------------
SRC_W=$(probe stream=width); SRC_H=$(probe stream=height)
SRC_FPS=$(probe stream=avg_frame_rate)
SRC_DUR=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$IN")

# Portrait (iPhone) → 720 wide; landscape (Mac) → 1600 wide. Never upscale.
if [ "$WIDTH" = auto ]; then
  if [ "$SRC_H" -gt "$SRC_W" ]; then WIDTH=720; else WIDTH=1600; fi
fi
[ "$WIDTH" -gt "$SRC_W" ] && WIDTH=$SRC_W

FPS=$(awk -v f="$SRC_FPS" -v m="$FPSMAX" 'BEGIN{split(f,a,"/"); r=(a[2]>0)?a[1]/a[2]:a[1]; if(r<=0||r>m) r=m; printf "%.3f", r}')
[ -n "$DUR" ] || DUR=$(awk -v d="$SRC_DUR" -v s="$START" 'BEGIN{printf "%.3f", d-s}')
OUT_DUR=$(awk -v d="$DUR" -v k="$SPEED" 'BEGIN{printf "%.3f", d/k}')
GOP=$(awk -v f="$FPS" 'BEGIN{printf "%d", f*2+0.5}')

# Bitrate ceiling keeps playback smooth on slow connections.
if   [ "$WIDTH" -le 900 ];  then MAXRATE=2500k; BUF=5M
elif [ "$WIDTH" -le 1700 ]; then MAXRATE=4M;    BUF=8M
else                             MAXRATE=6M;    BUF=12M; fi

BASE="setpts=(PTS-STARTPTS)/$SPEED,fps=$FPS,scale=$WIDTH:-2:flags=lanczos,setsar=1,format=yuv420p"

# Cross-fade only when the clip is long enough for it.
DOFADE=$(awk -v f="$FADE" -v d="$OUT_DUR" 'BEGIN{print (f>0 && d>4*f) ? 1 : 0}')
if [ "$DOFADE" = 1 ]; then
  OFFSET=$(awk -v d="$OUT_DUR" -v f="$FADE" 'BEGIN{printf "%.3f", d-2*f}')
  GRAPH="[0:v]$BASE,split[a][b];[a]trim=start=$FADE,setpts=PTS-STARTPTS[main];[b]trim=end=$FADE,setpts=PTS-STARTPTS[head];[main][head]xfade=transition=fade:duration=$FADE:offset=$OFFSET,format=yuv420p[v]"
  FINAL_DUR=$(awk -v d="$OUT_DUR" -v f="$FADE" 'BEGIN{printf "%.3f", d-f}')
else
  GRAPH="[0:v]$BASE[v]"
  FINAL_DUR=$OUT_DUR
fi
[ -n "$THUMB" ] || THUMB=$(awk -v d="$FINAL_DUR" 'BEGIN{printf "%.2f", d*0.4}')

echo "→ $NAME: ${SRC_W}×${SRC_H}, ${DUR}s from ${START}s, ${SPEED}× → ${FINAL_DUR}s, ${FPS} fps, ${WIDTH}px wide"

ffmpeg -nostdin -hide_banner -loglevel error -y \
  -ss "$START" -t "$DUR" -i "$IN" \
  -filter_complex "$GRAPH" -map "[v]" -an \
  -c:v libx264 -preset "$PRESET" -crf "$CRF" -profile:v high -level:v 4.1 -pix_fmt yuv420p \
  -g "$GOP" -keyint_min "$GOP" -sc_threshold 0 \
  -maxrate "$MAXRATE" -bufsize "$BUF" \
  -movflags +faststart \
  "$OUT"

# Poster = the very first frame of the finished clip, so nothing jumps when playback starts.
ffmpeg -nostdin -hide_banner -loglevel error -y -i "$OUT" -frames:v 1 -q:v 4 "$POSTER"
# Thumbnail for the strip: one frame, 480 px wide.
ffmpeg -nostdin -hide_banner -loglevel error -y -ss "$THUMB" -i "$OUT" -frames:v 1 -vf "scale=480:-2:flags=lanczos" -q:v 5 "$THUMBF"

SIZE=$(du -h "$OUT" | cut -f1 | tr -d ' ')
echo "  wrote videos/$NAME.mp4 ($SIZE), $NAME.jpg, $NAME-thumb.jpg"

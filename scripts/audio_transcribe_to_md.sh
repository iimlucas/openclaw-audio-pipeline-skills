#!/usr/bin/env bash
set -euo pipefail

MODEL="base"
CHUNK_SECONDS=300
LANGUAGE="Chinese"
OUT_DIR="$HOME/Documents/ObsidianVault/Inbox/Transcripts"

usage() {
  cat <<'EOF'
Usage:
  audio_transcribe_to_md.sh [--model tiny|base|small|medium|large] [--chunk-seconds N] [--language Chinese] [--out-dir <dir>] <audio_file>
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --model)
      MODEL="${2:-}"; shift 2 ;;
    --chunk-seconds)
      CHUNK_SECONDS="${2:-}"; shift 2 ;;
    --language)
      LANGUAGE="${2:-}"; shift 2 ;;
    --out-dir)
      OUT_DIR="${2:-}"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    --)
      shift; break ;;
    -*)
      echo "Unknown option: $1" >&2; usage; exit 1 ;;
    *)
      break ;;
  esac
done

AUDIO_FILE="${1:-}"
if [[ -z "$AUDIO_FILE" || ! -f "$AUDIO_FILE" ]]; then
  echo "Audio file not found: $AUDIO_FILE" >&2
  usage
  exit 1
fi

if [[ ! "$CHUNK_SECONDS" =~ ^[0-9]+$ ]] || [[ "$CHUNK_SECONDS" -lt 60 ]]; then
  echo "--chunk-seconds must be >= 60" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"
python3 -m pip install --user -q openai-whisper imageio-ffmpeg

FFMPEG_BIN="$(python3 - <<'PY'
import imageio_ffmpeg
print(imageio_ffmpeg.get_ffmpeg_exe())
PY
)"
if [[ -z "$FFMPEG_BIN" || ! -x "$FFMPEG_BIN" ]]; then
  echo "ffmpeg binary not found from imageio_ffmpeg" >&2
  exit 1
fi

TMP_DIR="$(mktemp -d)"
FFMPEG_WRAP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR" "$FFMPEG_WRAP_DIR"' EXIT

ln -sf "$FFMPEG_BIN" "$FFMPEG_WRAP_DIR/ffmpeg"
export PATH="$FFMPEG_WRAP_DIR:$PATH"

CHUNK_DIR="$TMP_DIR/chunks"
TXT_DIR="$TMP_DIR/txt"
MERGED_TXT="$TMP_DIR/merged.txt"
mkdir -p "$CHUNK_DIR" "$TXT_DIR"

ffmpeg -hide_banner -loglevel error -i "$AUDIO_FILE" -f segment -segment_time "$CHUNK_SECONDS" -c copy "$CHUNK_DIR/chunk_%03d.m4a"

if ! ls "$CHUNK_DIR"/*.m4a >/dev/null 2>&1; then
  cp "$AUDIO_FILE" "$CHUNK_DIR/chunk_000.m4a"
fi

: > "$MERGED_TXT"
PART=0
for chunk in "$CHUNK_DIR"/*.m4a; do
  PART=$((PART + 1))
  echo "Transcribing part $PART: $(basename "$chunk")"
  python3 -m whisper "$chunk" --model "$MODEL" --language "$LANGUAGE" --task transcribe --output_format txt --output_dir "$TXT_DIR" >/dev/null

  chunk_base="$(basename "$chunk" .m4a)"
  chunk_txt="$TXT_DIR/$chunk_base.txt"
  if [[ ! -f "$chunk_txt" ]]; then
    chunk_txt="$(find "$TXT_DIR" -maxdepth 1 -type f -name '*.txt' | xargs ls -t | head -n 1 || true)"
  fi
  if [[ -z "$chunk_txt" || ! -f "$chunk_txt" ]]; then
    echo "Transcript generation failed on part $PART" >&2
    exit 1
  fi

  {
    echo "[Part $PART]"
    cat "$chunk_txt"
    echo
  } >> "$MERGED_TXT"
done

base_name="$(basename "$AUDIO_FILE")"
stem="${base_name%.*}"
out_file="$OUT_DIR/${stem}_逐字稿.md"

{
  echo "# ${stem} 逐字稿"
  echo
  printf -- '- Source Audio: `%s`\n' "$AUDIO_FILE"
  echo "- Model: whisper-$MODEL"
  echo "- Chunk Seconds: $CHUNK_SECONDS"
  echo
  echo "## Transcript"
  echo
  cat "$MERGED_TXT"
  echo
} > "$out_file"

echo "$out_file"

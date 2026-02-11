#!/usr/bin/env bash
set -euo pipefail

PROMPT_FILE="$HOME/Documents/ObsidianVault/Inbox/Youtube Transcript prompt.md"
OUT_FILE=""
MODEL="gemini-3-pro-preview"

usage() {
  cat <<'EOF'
Usage:
  transcript_refine_gemini.sh [--prompt-file <path>] [--out-file <path>] [--model <gemini-model>] <transcript_md>
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prompt-file)
      PROMPT_FILE="${2:-}"; shift 2 ;;
    --out-file)
      OUT_FILE="${2:-}"; shift 2 ;;
    --model)
      MODEL="${2:-}"; shift 2 ;;
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

IN_FILE="${1:-}"
if [[ -z "$IN_FILE" || ! -f "$IN_FILE" ]]; then
  echo "Transcript file not found: $IN_FILE" >&2
  usage
  exit 1
fi
if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "Prompt file not found: $PROMPT_FILE" >&2
  exit 1
fi

if [[ -z "$OUT_FILE" ]]; then
  base="${IN_FILE%.md}"
  OUT_FILE="${base}_Gemini整理.md"
fi

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

{
  cat "$PROMPT_FILE"
  echo
  echo "---"
  echo "下面是待处理的转写文本（请严格按上述规则输出最终稿）："
  echo
  cat "$IN_FILE"
} > "$tmp"

gemini --model "$MODEL" -p "请严格遵循输入中的规则与格式，输出最终整理后的完整转写稿（仅输出结果，不要解释过程）。" < "$tmp" > "$OUT_FILE"

echo "$OUT_FILE"

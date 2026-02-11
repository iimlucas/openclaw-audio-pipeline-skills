#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DL_SCRIPT="/Users/luclaw/.openclaw/workspace/skills/xiaoyuzhou-dl/scripts/download_xiaoyuzhou.sh"

MODE="audio"
OUT_DIR="$HOME/Downloads/Podcast/xiaoyuzhou"

usage() {
  cat <<'EOF'
Usage:
  xiaoyuzhou_fetch.sh [--mode audio|md|both] [--output <dir>] <episode_url_or_id> [more...]
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODE="${2:-}"; shift 2 ;;
    --output|-o)
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

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

bash "$DL_SCRIPT" --mode "$MODE" --output "$OUT_DIR" "$@"

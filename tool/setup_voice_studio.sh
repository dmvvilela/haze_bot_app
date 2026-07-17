#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VENV="$ROOT/.voice-studio"

if ! command -v sox >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    brew install sox
  else
    echo "SoX is required. Install Homebrew, then run: brew install sox" >&2
    exit 1
  fi
fi

python3 -m venv "$VENV"
"$VENV/bin/python" -m pip install --upgrade pip
"$VENV/bin/python" -m pip install qwen-tts

echo "Voice studio ready. Generate one audition with:"
echo "$VENV/bin/python tool/generate_haze_voices.py --variant pocket_gremlin --line hello"

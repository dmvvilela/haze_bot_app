#!/usr/bin/env bash
#
# Download Haze's on-device model ONCE, locally, using your Hugging Face token.
# Then re-host the file publicly (e.g. a GitHub Release asset) and point
# HAZE_MODEL_URL in .env at it — so the shipped app needs no token at all.
#
# The token is read from .env and never leaves your machine.
#
# Usage:
#   ./tool/fetch_model.sh            # -> ./gemma3-1b-it-int4.task
#   ./tool/fetch_model.sh /tmp/m.task
set -euo pipefail

MODEL_FILE="gemma3-1b-it-int4.task"
HF_URL="https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/${MODEL_FILE}"
OUT="${1:-./${MODEL_FILE}}"

# Load HUGGINGFACE_TOKEN from .env if present.
if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  . ./.env
  set +a
fi

if [ -z "${HUGGINGFACE_TOKEN:-}" ]; then
  echo "error: set HUGGINGFACE_TOKEN in .env first (a read-only token is fine)." >&2
  exit 1
fi

echo "Downloading ${MODEL_FILE} ..."
curl -L --fail -H "Authorization: Bearer ${HUGGINGFACE_TOKEN}" "${HF_URL}" -o "${OUT}"
echo "Saved ${OUT} ($(du -h "${OUT}" | cut -f1))"
echo
echo "Next steps:"
echo "  1) Upload ${OUT} as a PUBLIC GitHub Release asset (or any static host)."
echo "  2) In .env, set:  HAZE_MODEL_URL=https://.../${MODEL_FILE}"
echo "  3) Remove HUGGINGFACE_TOKEN from .env — the app no longer needs it."

#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-only
# Copyright (C) 2026 Felipe Novaes Rocha
# Speak a sentence and upload the mp3 straight to CucaCards.
#
#   audio.sh say    "<text>" <voice> <uploadUrl>   -> prints {"storageId":"..."}
#   audio.sh sample "<text>" <voice> <file.mp3>    -> writes a local file to listen to
#   audio.sh voices <lang-prefix>                  -> e.g. "ja", "es", "pt-BR"
#
# The audio never passes through the conversation: the model gets an upload
# URL from the MCP tool `prepare_audio_upload`, this script POSTs the bytes
# there, and only the short storageId goes back to `add_audio`.
#
# Voices come from edge-tts (the neural voices of Microsoft Edge's read-aloud).
# Free, no account, ~90 voices across the major languages. It is an unofficial
# endpoint: if it ever stops working, swap the `synth` function for any other
# TTS that writes an mp3.
set -euo pipefail

edge_tts() {
  if command -v edge-tts >/dev/null 2>&1; then
    edge-tts "$@"
  elif command -v uvx >/dev/null 2>&1; then
    uvx --quiet edge-tts "$@"
  elif command -v pipx >/dev/null 2>&1; then
    pipx run --quiet edge-tts "$@"
  else
    echo "error: needs edge-tts. Install uv (https://docs.astral.sh/uv/) or run: pipx install edge-tts" >&2
    exit 2
  fi
}

synth() { # text voice out
  # Only the last line of a failure: a Python traceback is 30 lines of noise
  # for whoever reads this output, and the last one says what went wrong.
  local err
  if ! err="$(edge_tts --voice "$2" --text "$1" --write-media "$3" 2>&1 >/dev/null)"; then
    echo "error: $(printf '%s\n' "$err" | tail -n 1)" >&2
    exit 3
  fi
  if [ ! -s "$3" ]; then
    echo "error: no audio produced for voice '$2'. List valid ones with: audio.sh voices <lang>" >&2
    exit 3
  fi
}

cmd="${1:-}"
case "$cmd" in
  say)
    [ $# -eq 4 ] || { echo 'usage: audio.sh say "<text>" <voice> <uploadUrl>' >&2; exit 1; }
    tmp="$(mktemp "${TMPDIR:-/tmp}/cuca-audio.XXXXXX")"
    trap 'rm -f "$tmp"' EXIT
    synth "$2" "$3" "$tmp"
    curl -sS --fail-with-body -X POST -H "Content-Type: audio/mpeg" --data-binary @"$tmp" "$4"
    echo
    ;;
  sample)
    [ $# -eq 4 ] || { echo 'usage: audio.sh sample "<text>" <voice> <file.mp3>' >&2; exit 1; }
    synth "$2" "$3" "$4"
    echo "$4"
    ;;
  voices)
    [ $# -eq 2 ] || { echo 'usage: audio.sh voices <lang-prefix>' >&2; exit 1; }
    edge_tts --list-voices | awk -v p="$2" 'NR > 2 && index($1, p) == 1 { print $1, $2 }'
    ;;
  *)
    sed -n '2,6p' "$0" >&2
    exit 1
    ;;
esac

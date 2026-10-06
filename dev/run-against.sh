#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-only
# Run Claude Code with a throwaway copy of this plugin pointed at ANOTHER
# CucaCards server (a test deployment, a local one). The published plugin
# keeps the production URL written literally in .mcp.json, because claude.ai
# and the Claude app do not expand environment variables there.
#
#   dev/run-against.sh https://your-test-server.example/api/mcp
set -euo pipefail
[ $# -ge 1 ] || { echo "usage: dev/run-against.sh <mcp-url> [claude args...]" >&2; exit 1; }
url="$1"; shift
src="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d "${TMPDIR:-/tmp}/cuca-plugin.XXXXXX")"
cp -R "$src/.claude-plugin" "$src/skills" "$tmp/"
printf '{\n  "mcpServers": {\n    "cuca": { "type": "http", "url": "%s" }\n  }\n}\n' "$url" > "$tmp/.mcp.json"
echo "plugin copy -> $url" >&2
exec claude --plugin-dir "$tmp" "$@"

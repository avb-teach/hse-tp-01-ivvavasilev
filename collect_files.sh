#!/usr/bin/env bash
# collect_files.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$SCRIPT_DIR/collect_files.py" "$@"

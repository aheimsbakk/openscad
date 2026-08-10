#!/usr/bin/env bash
# Generate a preview PNG for a single .scad file.
#
# Usage:
#   ./scripts/render-one.sh drawings/<category>/<name>.scad
#
# Output:
#   previews/<category>/<name>.png
#
# Requires: Xvfb (for headless PNG generation)
# If called from render-all.sh, DISPLAY is already set.

set -euo pipefail

if [ $# -lt 1 ]; then
	echo "Usage: $0 <path.to.file.scad>" >&2
	exit 1
fi

SCAD_FILE="$1"

if [ ! -f "$SCAD_FILE" ]; then
	echo "Error: File not found: $SCAD_FILE" >&2
	exit 1
fi

# Derive preview path: drawings/foo/bar.scad -> previews/foo/bar.png
PREVIEW_PATH=$(echo "$SCAD_FILE" | sed 's|^drawings/|previews/|' | sed 's|\.scad$|.png|')

# Ensure output directory exists
mkdir -p "$(dirname "$PREVIEW_PATH")"

echo "Rendering: $SCAD_FILE"
echo "Output:    $PREVIEW_PATH"

# Start Xvfb if DISPLAY is not already set (i.e., not called from render-all.sh)
XVFB_PID=""
if [ -z "${DISPLAY:-}" ]; then
	Xvfb :99 -screen 0 1280x1024x24 &
	XVFB_PID=$!
	sleep 1
fi

cleanup() {
	if [ -n "$XVFB_PID" ] && kill -0 "$XVFB_PID" 2>/dev/null; then
		kill "$XVFB_PID" 2>/dev/null
		wait "$XVFB_PID" 2>/dev/null
	fi
}
trap cleanup EXIT

export DISPLAY=:99

openscad \
	-o "$PREVIEW_PATH" \
	--render \
	--autocenter \
	--viewall \
	--imgsize 1200,900 \
	"$SCAD_FILE"

echo "Done."

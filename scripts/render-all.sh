#!/usr/bin/env bash
# Generate preview PNGs for all .scad files in the drawings/ directory.
#
# Usage:
#   ./scripts/render-all.sh
#
# Requires: Xvfb (for headless PNG generation)

set -euo pipefail

COUNT=0
ERRORS=0

# Start a single virtual framebuffer for all renders
Xvfb :99 -screen 0 1280x1024x24 &
XVFB_PID=$!
sleep 1

cleanup() {
	if kill -0 "$XVFB_PID" 2>/dev/null; then
		kill "$XVFB_PID" 2>/dev/null
		wait "$XVFB_PID" 2>/dev/null
	fi
}
trap cleanup EXIT

export DISPLAY=:99

for SCAD_FILE in $(find drawings/ -name '*.scad' 2>/dev/null | sort); do
	if ./scripts/render-one.sh "$SCAD_FILE"; then
		COUNT=$((COUNT + 1))
	else
		echo "Failed: $SCAD_FILE" >&2
		ERRORS=$((ERRORS + 1))
	fi
done

echo ""
echo "Summary: $COUNT rendered, $ERRORS failed"

if [ "$ERRORS" -gt 0 ]; then
	exit 1
fi

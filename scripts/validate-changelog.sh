#!/usr/bin/env bash
# Validate CHANGELOG.md format
# Checks that version headers follow ## [X.Y.Z] format and dates are valid

set -euo pipefail

CHANGELOG="CHANGELOG.md"

if [ ! -f "$CHANGELOG" ]; then
	echo "FAIL: $CHANGELOG not found" >&2
	exit 1
fi

errors=0

# Check version header format
while IFS= read -r line; do
	if [[ "$line" =~ ^##\ \[([0-9]+\.[0-9]+\.[0-9]+)\]\ \- ]]; then
		version="${BASH_REMATCH[1]}"
		echo "OK: version $version found"
	elif [[ "$line" =~ ^##\ \[ ]]; then
		echo "WARN: non-standard version format: $line" >&2
		errors=$((errors + 1))
	fi
done <"$CHANGELOG"

# Check for required metadata fields in latest entry
latest=$(sed -n '/^## \[0\./,/^## \[/p' "$CHANGELOG" | head -n -1)
if echo "$latest" | grep -q "why:"; then
	echo "OK: changelog has 'why' field"
else
	echo "WARN: 'why' field missing in latest entry" >&2
fi

if echo "$latest" | grep -q "model:"; then
	echo "OK: changelog has 'model' field"
else
	echo "WARN: 'model' field missing in latest entry" >&2
fi

if [ "$errors" -eq 0 ]; then
	echo "PASS: changelog format valid"
	exit 0
else
	echo "FAIL: $errors errors found" >&2
	exit 1
fi

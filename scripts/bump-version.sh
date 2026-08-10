#!/usr/bin/env bash
# Bump version in CHANGELOG.md
# Usage: bump-version.sh [patch|minor|major]

set -euo pipefail

if [ $# -ne 1 ]; then
	echo "Usage: $0 [patch|minor|major]" >&2
	exit 1
fi

BUMP="$1"
CHANGELOG="CHANGELOG.md"

if [ ! -f "$CHANGELOG" ]; then
	echo "Error: $CHANGELOG not found" >&2
	exit 1
fi

# Extract current version from first version header
current=$(grep -m1 '^## \[' "$CHANGELOG" | sed 's/## \[\(0\.[0-9]*\.[0-9]*\)\].*/\1/')
if [ -z "$current" ]; then
	echo "Error: Could not parse version from $CHANGELOG" >&2
	exit 1
fi

IFS='.' read -r major minor patch <<<"$current"

case "$BUMP" in
patch) patch=$((patch + 1)) ;;
minor)
	minor=$((minor + 1))
	patch=0
	;;
major)
	major=$((major + 1))
	minor=0
	patch=0
	;;
*)
	echo "Usage: $0 [patch|minor|major]" >&2
	exit 1
	;;
esac

new="${major}.${minor}.${patch}"

# Replace the old version in the first version header
sed -i "s/^## \[${current}\]/## [${new}]/" "$CHANGELOG"

echo "${current} → ${new}"

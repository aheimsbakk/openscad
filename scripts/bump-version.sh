#!/usr/bin/env bash
# Bump version by prepending a new version section to CHANGELOG.md.
# Usage: bump-version.sh [patch|minor|major]
#
# Inserts an empty "## [X.Y.Z] - <date>" section directly after the
# "# Changelog" heading. The previous release sections stay untouched;
# the agent fills in the metadata and change list of the new section.

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

# Extract current version from the first version header
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
date=$(date -u +%Y-%m-%d)

# Prepend a fresh version section right after the main heading.
sed -i "/^# Changelog/a\\
\\
## [${new}] - ${date}" "$CHANGELOG"

echo "${current} → ${new}"

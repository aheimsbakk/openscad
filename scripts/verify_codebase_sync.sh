#!/usr/bin/env bash
# Verify that all paths listed in CODEBASE.md exist on disk.
#
# Usage:
#   ./scripts/verify_codebase_sync.sh
#
# Exit code 0 = all paths exist. Exit code 1 = missing paths found.

set -euo pipefail

MISSING=0
CODEBASE="CODEBASE.md"

if [ ! -f "$CODEBASE" ]; then
	echo "Error: $CODEBASE not found" >&2
	exit 1
fi

while IFS= read -r line; do
	# Skip non-table lines
	if [[ ! "$line" == *"|"* ]]; then
		continue
	fi

	# Check columns 3, 4, and 5
	for i in 3 4 5; do
		PATH_VAL=$(echo "$line" | awk -F'|' -v col="$i" '{gsub(/^[ \t`]+|[ \t`]+$/, "", $col); print $col}')

		# Skip empty values
		if [ -z "$PATH_VAL" ]; then
			continue
		fi

		# Skip if it's a header or a template (contains < or >)
		if [[ "$PATH_VAL" == *"<"* ]] || [[ "$PATH_VAL" == *">"* ]] || [[ "$PATH_VAL" == *"Path"* ]] || [[ "$PATH_VAL" == *"Component"* ]] || [[ "$PATH_VAL" == *"Category"* ]] || [[ "$PATH_VAL" == *"Name"* ]] || [[ "$PATH_VAL" == *"---"* ]]; then
			continue
		fi

		# If it looks like a path, verify it
		if [[ "$PATH_VAL" == *"/"* ]]; then
			if [ ! -e "$PATH_VAL" ]; then
				echo "MISSING: $PATH_VAL" >&2
				MISSING=$((MISSING + 1))
			fi
		fi
	done
done <"$CODEBASE"

if [ "$MISSING" -gt 0 ]; then
	echo "Found $MISSING missing path(s) in $CODEBASE" >&2
	exit 1
fi

echo "All paths in $CODEBASE verified."
exit 0

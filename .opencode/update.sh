#!/usr/bin/env bash
# update.sh - Download/update agentic template files from GitHub
#
# Downloads AGENTS.md, opencode.json, and all files under .opencode/ (and
# the legacy agents/ path) from https://github.com/aheimsbakk/agentic-opencode
# into the current directory or a specified target directory.

set -euo pipefail

# ─── Constants ────────────────────────────────────────────────────────────────

readonly REPO="aheimsbakk/agentic-opencode"
readonly GITHUB_RAW="https://raw.githubusercontent.com/${REPO}"
readonly GITHUB_API="https://api.github.com/repos/${REPO}"
readonly VERSION="1.3.0"
readonly SCRIPT_NAME="$(basename "$0")"

# ─── Helpers ──────────────────────────────────────────────────────────────────

usage() {
	cat <<EOF
Usage: ${SCRIPT_NAME} [OPTIONS] [BRANCH/TAG]

Download and update agentic template files from GitHub into the current
directory or a specified target directory.

    Files downloaded:
  AGENTS.md
  .opencode/  (all files, recursively)  # previously 'agents/'

Arguments:
  BRANCH/TAG    Branch or tag to download from (default: main)

Options:
  -D            Delete the legacy ./agents folder before updating
  -d DIR        Target directory (default: current directory)
  -h, --help    Show this help message and exit
  -v, --version Show version and exit

Examples:
  ${SCRIPT_NAME}                     # Download from main into current dir
  ${SCRIPT_NAME} -D                  # Delete ./agents folder, then download
  ${SCRIPT_NAME} develop             # Download from the 'develop' branch
  ${SCRIPT_NAME} v1.2.0              # Download from the 'v1.2.0' tag
  ${SCRIPT_NAME} -d ~/myproject      # Download into ~/myproject
  ${SCRIPT_NAME} -d ~/myproject main # Download from main into ~/myproject
EOF
}

version() {
	echo "${SCRIPT_NAME} ${VERSION}"
}

die() {
	echo "error: $*" >&2
	exit 1
}

# Check that required tools are available
check_deps() {
	local missing=()
	for cmd in curl python3; do
		command -v "$cmd" &>/dev/null || missing+=("$cmd")
	done
	if [[ ${#missing[@]} -gt 0 ]]; then
		die "missing required tools: ${missing[*]}"
	fi
}

# ─── Core logic ───────────────────────────────────────────────────────────────

# Fetch file list for agents/ from the GitHub API tree for the given ref
get_agent_files() {
	local ref="$1"
	local url="${GITHUB_API}/git/trees/${ref}?recursive=1"
	local response

	response=$(curl -fsSL "$url" 2>/dev/null) ||
		die "failed to fetch file list from GitHub (branch/tag '${ref}' may not exist)"

	# Extract blob paths that start with .opencode/ or the legacy agents/
	python3 -c "
import sys, json
data = json.loads('''${response}''')
for item in data.get('tree', []):
    if item['type'] == 'blob':
        p = item.get('path','')
        if p.startswith('.opencode/') or p == '.opencode' or p.startswith('agents/'):
            print(p)
"
}

# Download a single file from the raw GitHub URL, replacing only if different
download_file() {
	local ref="$1"
	local remote_path="$2"
	local target_dir="$3"
	local dest="${target_dir}/${remote_path}"
	local dest_parent
	dest_parent="$(dirname "$dest")"
	local url="${GITHUB_RAW}/${ref}/${remote_path}"
	local tmp

	tmp=$(mktemp) || die "failed to create temp file"
	# shellcheck disable=SC2064
	trap "rm -f '${tmp}'" RETURN

	if ! curl -fsSL -o "$tmp" "$url" 2>/dev/null; then
		echo "  FAIL   ${remote_path}"
		rm -f "$tmp"
		return 1
	fi

	if [[ ! -d "$dest_parent" ]]; then
		mkdir -p "$dest_parent"
	fi

	if [[ -f "$dest" ]] && cmp -s "$tmp" "$dest"; then
		echo "  OK     ${remote_path}"
	else
		cp "$tmp" "$dest"
		echo "  UPDATED ${remote_path}"
		# If this is the update script itself, make it executable
		if [[ "$remote_path" == ".opencode/update.sh" ]]; then
			chmod +x "$dest"
			echo "  CHMOD  ${remote_path} (set executable)"
		fi
	fi
}

# ─── Argument parsing ─────────────────────────────────────────────────────────

TARGET_DIR="."
REF="main"
DELETE_AGENTS_DIR=0

while [[ $# -gt 0 ]]; do
	case "$1" in
	-h | --help)
		usage
		exit 0
		;;
	-v | --version)
		version
		exit 0
		;;
	-D)
		DELETE_AGENTS_DIR=1
		shift
		;;
	-d)
		[[ $# -gt 1 ]] || die "option -d requires an argument"
		TARGET_DIR="$2"
		shift 2
		;;
	-d*)
		TARGET_DIR="${1#-d}"
		shift
		;;
	-*)
		die "unknown option: $1 (try --help)"
		;;
	*)
		REF="$1"
		shift
		;;
	esac
done

# ─── Main ─────────────────────────────────────────────────────────────────────

check_deps

# Resolve target directory to an absolute path
TARGET_DIR="$(realpath "$TARGET_DIR")"

if [[ ! -d "$TARGET_DIR" ]]; then
	die "target directory does not exist: ${TARGET_DIR}"
fi

# Delete legacy ./agents folder if requested
if [[ "$DELETE_AGENTS_DIR" == "1" ]]; then
	if [[ -d "${TARGET_DIR}/agents" ]]; then
		rm -rf "${TARGET_DIR}/agents"
		echo "  DELETED ./agents (legacy folder removed)"
	else
		echo "  SKIP   ./agents (not found, nothing to delete)"
	fi
fi

echo "Repository : ${REPO}"
echo "Branch/tag : ${REF}"
echo "Target dir : ${TARGET_DIR}"
echo ""

# Static top-level files
STATIC_FILES=(
	"AGENTS.md"
	"opencode.json"
)

# Dynamic: discover all files under .opencode/ (also accepts legacy agents/)
mapfile -t AGENT_FILES < <(get_agent_files "$REF")

ALL_FILES=("${STATIC_FILES[@]}" "${AGENT_FILES[@]}")

# ─── Parse .opencode/.gitignore ───────────────────────────────────────────────
# Build two parallel arrays:
#   IGNORE_PATTERNS  – all normalized pattern strings
#   IGNORE_IS_DIR    – "1" if the pattern refers to a directory, "0" otherwise
#
# Directory detection (no trailing slash required):
#   1. Check local filesystem first – if a matching path is a directory, treat as dir.
#   2. Fall back to remote file list – if any remote path has the pattern as a
#      prefix component, treat as dir.

IGNORE_PATTERNS=()
IGNORE_IS_DIR=()
GITIGNORE_FILE="${TARGET_DIR}/.opencode/.gitignore"

if [[ -f "$GITIGNORE_FILE" ]]; then
	while IFS= read -r line || [[ -n "$line" ]]; do
		# Strip inline comments and surrounding whitespace
		line="${line%%#*}"
		line="${line#"${line%%[![:space:]]*}"}" # ltrim
		line="${line%"${line##*[![:space:]]}"}" # rtrim
		[[ -z "$line" ]] && continue

		# Normalize: remove leading ./ or leading /
		norm="${line#./}"
		norm="${norm#/}"
		# Strip any trailing slash (we detect dirs ourselves)
		norm="${norm%/}"

		# Determine if this pattern is a directory:
		# 1. Local filesystem check (most reliable for locally-added files)
		is_dir=0
		if [[ -d "${TARGET_DIR}/.opencode/${norm}" ]]; then
			is_dir=1
		else
			# 2. Remote file list check (catches dirs that exist only remotely)
			for rf in "${AGENT_FILES[@]}"; do
				if [[ "$rf" == ".opencode/${norm}/"* ]]; then
					is_dir=1
					break
				fi
			done
		fi

		IGNORE_PATTERNS+=("$norm")
		IGNORE_IS_DIR+=("$is_dir")
	done <"$GITIGNORE_FILE"
fi

# ─── Ignore helpers ───────────────────────────────────────────────────────────

# Return 0 if the given relative path (e.g. ".opencode/foo/bar") is covered by
# any ignore pattern.  Handles exact file matches, directory-prefix matches,
# and simple glob wildcards.
path_is_ignored() {
	local path="$1" # relative to TARGET_DIR, e.g. ".opencode/node_modules/x"
	local i norm is_dir

	for i in "${!IGNORE_PATTERNS[@]}"; do
		norm="${IGNORE_PATTERNS[$i]}"
		is_dir="${IGNORE_IS_DIR[$i]}"

		if [[ "$norm" == *"*"* || "$norm" == *"?"* || "$norm" == *"["* ]]; then
			# Glob pattern: match against the full path
			# shellcheck disable=SC2254
			case "$path" in
			.opencode/${norm} | .opencode/${norm}/*) return 0 ;;
			esac
		elif [[ "$is_dir" == "1" ]]; then
			# Directory pattern: match path itself or anything inside it
			if [[ "$path" == ".opencode/${norm}" || "$path" == ".opencode/${norm}/"* ]]; then
				return 0
			fi
		else
			# Plain file pattern: exact match only
			if [[ "$path" == ".opencode/${norm}" ]]; then
				return 0
			fi
		fi
	done
	return 1
}

# Return 0 if the given *directory* (absolute path) is itself directly ignored
# (i.e. we should not traverse it at all).
dir_is_ignored() {
	local abs_dir="$1"
	local rel="${abs_dir#"${TARGET_DIR}/"}"
	path_is_ignored "$rel"
}

# ─── Download phase ───────────────────────────────────────────────────────────

fail_count=0
for file in "${ALL_FILES[@]}"; do
	if [[ "$file" == .opencode/* ]] && path_is_ignored "$file"; then
		echo "  SKIP   ${file} (ignored by .opencode/.gitignore)"
		continue
	fi
	download_file "$REF" "$file" "$TARGET_DIR" || ((fail_count++)) || true
done

# ─── Cleanup phase ────────────────────────────────────────────────────────────
# Remove local files that no longer exist in the remote.
# Ignored directories are not traversed; instead they are reported as KEEP.

# Build a lookup set of all remote paths for O(1) membership tests
declare -A remote_set
for file in "${ALL_FILES[@]}"; do
	remote_set["$file"]=1
done

# Enumerate local candidates and decide what to do with each.
# We walk .opencode/ (or legacy agents/) manually so we can skip ignored dirs
# at the directory level and emit KEEP for them without descending.
process_local_tree() {
	local base_dir="$1" # absolute path to .opencode or agents/

	# Use a queue implemented with a bash array to avoid subshell issues
	local -a queue=("$base_dir")

	while [[ ${#queue[@]} -gt 0 ]]; do
		local dir="${queue[0]}"
		queue=("${queue[@]:1}")

		local entry rel

		# Process all subdirectories (both plain and hidden/dot dirs)
		for entry in "$dir"/*/ "$dir"/.*/; do
			# Glob may not match anything; skip . and ..
			[[ -e "$entry" ]] || continue
			entry="${entry%/}" # remove trailing slash added by glob
			[[ "$entry" == */. || "$entry" == */.. ]] && continue

			rel="${entry#"${TARGET_DIR}/"}"

			if dir_is_ignored "$entry"; then
				echo "  KEEP   ${rel}/ (ignored by .opencode/.gitignore)"
				# Do not traverse further
			else
				queue+=("$entry")
			fi
		done

		# Process all files (both plain and hidden/dot files)
		for entry in "$dir"/* "$dir"/.*; do
			[[ -e "$entry" ]] || continue
			[[ -f "$entry" ]] || continue # skip dirs (handled above)

			rel="${entry#"${TARGET_DIR}/"}"

			if path_is_ignored "$rel"; then
				echo "  KEEP   ${rel} (ignored by .opencode/.gitignore)"
			elif [[ -z "${remote_set[$rel]+_}" ]]; then
				rm -f "$entry"
				echo "  DELETED ${rel}"
				rmdir --ignore-fail-on-non-empty -p "$(dirname "$entry")" 2>/dev/null || true
			fi
		done
	done
}

# Handle static top-level files
for f in "${STATIC_FILES[@]}"; do
	[[ -f "${TARGET_DIR}/${f}" ]] || continue
	if [[ -z "${remote_set[$f]+_}" ]]; then
		rm -f "${TARGET_DIR}/${f}"
		echo "  DELETED ${f}"
	fi
done

# Walk managed directory tree
if [[ -d "${TARGET_DIR}/.opencode" ]]; then
	process_local_tree "${TARGET_DIR}/.opencode"
elif [[ -d "${TARGET_DIR}/agents" ]]; then
	process_local_tree "${TARGET_DIR}/agents"
fi

echo ""
if [[ $fail_count -gt 0 ]]; then
	echo "Done with ${fail_count} error(s)."
	exit 1
else
	echo "Done."
fi
